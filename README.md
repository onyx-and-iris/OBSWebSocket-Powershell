# OBSWebSocket-Powershell

## Requirements

-   [OBS Studio](https://obsproject.com/)
-   [OBS Websocket v5 Plugin](https://github.com/obsproject/obs-websocket/releases/tag/5.0.0)
    -   With the release of OBS Studio version 28, Websocket plugin is included by default. But it should be manually installed for earlier versions of OBS.
-   Powershell 5.1+ or Powershell 7.2+

## Installation

#### PowerShellGet:

In Powershell as admin:

`Install-Module OBSWebSocket`

In Powershell as current user:

`Install-Module -Name OBSWebSocket -Scope CurrentUser`

You may be asked to install NuGet provider required by PowerShellGet if you don't have it already.

When prompted you will need to accept PSGallery as a trusted repository.

More Info:

-   [PowerShellGet](https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget?view=powershell-7.1)
-   [NuGet](https://www.powershellgallery.com/packages/NuGet/1.3.3)
-   [PSGallery](https://docs.microsoft.com/en-gb/powershell/scripting/gallery/overview?view=powershell-7.1)

#### Direct download:

`git clone https://github.com/onyx-and-iris/OBSWebSocket-Powershell.git`

All examples in this readme assume you've installed as a module.
If you direct download you'll have to dot source the module like so: `Import-Module .\lib\OBSWebSocket.psm1`

## Use

### Requests

```powershell
Import-Module OBSWebSocket

try {
    $r_client = Get-OBSRequest -hostname "localhost" -port 4455 -pass "mystrongpassword"
    $resp = $r_client.GetVersion()
    Write-Host "obs version:", $resp.obsVersion
    Write-Host "websocket version:", $resp.obsWebSocketVersion
} finally { $r_client.TearDown() }
```

For a full list of requests refer to [Requests](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests)

### Events

Unfortunately, the Events client is blocking which means if you do use it, it will need to be at the end of your script. I attempted to get
it running in a runspace but then it was unable to invoke script blocks I passed it. If anyone knows a good solution I would like to hear from you =).

```powershell
Import-Module OBSWebSocket

function CurrentProgramSceneChanged($data) {
    "Switched to scene: " + $data.sceneName | Write-Host
}

try {
    $e_client = Get-OBSEvent -hostname "localhost" -port 4455 -pass "mystrongpassword"
    $callbacks = @("CurrentProgramSceneChanged", ${function:CurrentProgramSceneChanged})
    $e_client.Register($callbacks)
} finally { $e_client.TearDown() }
```

When registering callbacks you must pass both the name of the function plus a reference to the script block in a single array.

`$e_client.Register` also accepts arrays of arrays, for example:

```powershell
$callbacks = @(
    @("InputMuteStateChanged", ${function:InputMuteStateChanged}),
    @("InputVolumeMeters", ${function:InputVolumeMeters})
)
$e_client.Register($callbacks)
```

Since `Register()` is blocking you must register all callbacks in one go.

For a full list of events refer to [Events](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#events)

### Official Documentation

For the full documentation:

-   [OBS Websocket SDK](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#obs-websocket-501-protocol)
