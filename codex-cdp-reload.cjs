(async () => {
  const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

  const version = await fetch("http://127.0.0.1:9222/json/version")
    .then(r => {
      if (!r.ok) throw new Error(`Cannot read /json/version: HTTP ${r.status}`);
      return r.json();
    });

  if (!version.webSocketDebuggerUrl) {
    throw new Error("Browser WebSocket endpoint not found.");
  }

  const ws = new WebSocket(version.webSocketDebuggerUrl);

  await new Promise((resolve, reject) => {
    ws.addEventListener("open", resolve, { once: true });
    ws.addEventListener("error", reject, { once: true });
  });

  let id = 1;
  const pending = new Map();

  ws.addEventListener("message", event => {
    let msg;
    try {
      msg = JSON.parse(event.data);
    } catch {
      return;
    }

    if (msg.id && pending.has(msg.id)) {
      const p = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) p.reject(new Error(JSON.stringify(msg.error)));
      else p.resolve(msg.result);
    }
  });

  function call(method, params = {}, sessionId) {
    return new Promise((resolve, reject) => {
      const callId = id++;
      pending.set(callId, { resolve, reject });

      const message = { id: callId, method, params };
      if (sessionId) message.sessionId = sessionId;

      ws.send(JSON.stringify(message));
    });
  }

  await call("Target.setDiscoverTargets", { discover: true });
  await sleep(500);

  const result = await call("Target.getTargets");

  const target = result.targetInfos.find(
    t => t.type === "page" && t.url === "app://-/index.html"
  );

  if (!target) {
    throw new Error("Codex main renderer target app://-/index.html was not found.");
  }

  const attached = await call("Target.attachToTarget", {
    targetId: target.targetId,
    flatten: true
  });

  await call("Page.enable", {}, attached.sessionId);
  await call("Page.reload", { ignoreCache: true }, attached.sessionId);

  console.log("Codex renderer reloaded successfully.");

  await sleep(1000);
  ws.close();
})().catch(err => {
  console.error("Codex reload failed:");
  console.error(err?.message || err);
  process.exitCode = 1;
});
