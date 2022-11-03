Import-Module OBSWebSocket.psm1

function ConnFromFile {
    $configpath = Join-Path $PSScriptRoot "config.psd1"
    return Import-PowerShellDataFile -Path $configpath
}

function main {
    try {
        $conn = ConnFromFile
        $r_client = Get-OBSRequest -hostname $conn.hostname -port $conn.port -pass $conn.password
        $resp = $r_client.GetVersion()

        Start-Sleep 1

        $Payload = @{
            eventData = @{
                obsVersion = "obs version: $($resp.obsVersion)"
                wsVersion = "websocket version: $($resp.obsWebSocketVersion)"
            }
        }
        $r_client.BroadcastCustomEvent($Payload)
    }
    finally { 
        $r_client.TearDown()
    }
}

if ($MyInvocation.InvocationName -ne '.') { main }
