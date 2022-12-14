Import-Module .\lib\OBSWebSocket.psm1

function CurrentProgramSceneChanged($data) {
    "Switched to scene: " + $data.sceneName | Write-Host
}

function ConnFromFile {
    $configpath = Join-Path $PSScriptRoot "config.psd1"
    return Import-PowerShellDataFile -Path $configpath
}

function main {
    try {
        $conn = ConnFromFile
        $r_client = Get-OBSRequest -hostname $conn.hostname -port $conn.port -pass $conn.password
        $resp = $r_client.GetVersion()
        Write-Host "obs version:", $resp.obsVersion
        Write-Host "websocket version:", $resp.obsWebSocketVersion

        $e_client = Get-OBSEvent -hostname $conn.hostname -port $conn.port -pass $conn.password
        $callbacks = @("CurrentProgramSceneChanged", ${function:CurrentProgramSceneChanged})
        $e_client.Register($callbacks)
    }
    finally { 
        $r_client.TearDown()
        $e_client.TearDown()
    }
}

if ($MyInvocation.InvocationName -ne '.') { main }
