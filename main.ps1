Import-Module .\lib\OBSWebSocket.psm1

function CurrentProgramSceneChanged($data) {
    $resp = $r_client.getCurrentProgramScene()
    "Switched to scene: " + $resp.currentProgramSceneName | Write-Host
}

function ConnFromFile {
    $configpath = Join-Path $PSScriptRoot "config.psd1"
    return Import-PowerShellDataFile -Path $configpath
}

function main {
    try {
        $conn = ConnFromFile
        $r_client = Get-Request -hostname $conn.hostname -port $conn.port -pass $conn.password
        $resp = $r_client.GetVersion()
        Write-Host "obs version:", $resp.obsVersion
        Write-Host "websocket version:", $resp.obsWebSocketVersion

        $e_client = Get-Event -hostname $conn.hostname -port $conn.port -pass $conn.password
        $callbacks = @("CurrentProgramSceneChanged", ${function:CurrentProgramSceneChanged})
        $e_client.Register($callbacks)
    }
    finally { 
        $r_client.TearDown()
        $e_client.TearDown()
    }
}

if ($MyInvocation.InvocationName -ne '.') { main }
