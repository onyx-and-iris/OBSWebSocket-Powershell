Import-Module OBSWebSocket

function ConnFromFile {
    $configpath = Join-Path $PSScriptRoot "config.psd1"
    return Import-PowerShellDataFile -Path $configpath
}

function main {
    try {
        $conn = ConnFromFile
        $r_client = Get-OBSRequest -hostname $conn.hostname -port $conn.port -pass $conn.password
        $resp = $r_client.GetSceneList()
        $resp.scenes | Sort-Object { (--$script:i) } | ForEach-Object {
            "Switching to scene " + $_.sceneName | Write-Host
            $r_client.SetCurrentProgramScene($_.sceneName)
            Start-Sleep 0.5
        }
    }
    finally {
        $r_client.TearDown()
    }
}

if ($MyInvocation.InvocationName -ne '.') { main }
