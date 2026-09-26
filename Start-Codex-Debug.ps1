$ErrorActionPreference = "Stop"

Get-Process |
Where-Object {$_.ProcessName -match 'ChatGPT|Codex|OpenAI'} |
Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Milliseconds 800

if (-not ("StoreAppLauncher" -as [type])) {
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

[Flags]
public enum ActivateOptions { None = 0 }

[ComImport]
[Guid("2e941141-7f97-4756-ba1d-9decde894a3d")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IApplicationActivationManager
{
    [PreserveSig]
    int ActivateApplication(
        [MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
        [MarshalAs(UnmanagedType.LPWStr)] string arguments,
        ActivateOptions options,
        out uint processId);
}

[ComImport]
[Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")]
public class ApplicationActivationManager {}

public static class StoreAppLauncher
{
    public static uint Launch(string aumid, string arguments)
    {
        var manager =
            (IApplicationActivationManager)new ApplicationActivationManager();

        uint processId;

        int hr = manager.ActivateApplication(
            aumid,
            arguments,
            ActivateOptions.None,
            out processId);

        if (hr < 0)
            Marshal.ThrowExceptionForHR(hr);

        return processId;
    }
}
"@
}

$pkg = Get-AppxPackage OpenAI.Codex
if (-not $pkg) {
    throw "OpenAI.Codex package was not found."
}

$manifest = Get-AppxPackageManifest $pkg
$appId = @($manifest.Package.Applications.Application)[0].Id
$aumid = "$($pkg.PackageFamilyName)!$appId"

$pidCodex = [StoreAppLauncher]::Launch(
    $aumid,
    "--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1"
)

Write-Host "Codex started. PID = $pidCodex"
Write-Host "If the UI keeps spinning, run Fix-Codex.ps1."
