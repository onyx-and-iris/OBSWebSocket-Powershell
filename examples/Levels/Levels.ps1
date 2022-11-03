Import-Module OBSWebSocket

function InputVolumeMeters($data) {
    $data.inputs | ForEach-Object {
        if ($_.inputName -eq "Desktop Audio") {
            if ($_.inputLevelsMul) { Write-Host $_.inputLevelsMul }
        }
    }
}

function InputMuteStateChanged($data) {
    if ($data.inputName -eq "Desktop Audio") {
        $data.inputName + " mute toggled" | Write-Host
    }
}

function ConnFromFile {
    $configpath = Join-Path $PSScriptRoot "config.psd1"
    return Import-PowerShellDataFile -Path $configpath
}

function main {
    try {
        $conn = ConnFromFile
        $r_client = Get-OBSRequest -hostname $conn.hostname -port $conn.port -pass $conn.password
        $resp = $r_client.getVersion()
        Write-Host "obs version:", $resp.obsVersion
        Write-Host "websocket version:", $resp.obsWebSocketVersion

        $subs = $($(Get-OBSLowVolume) -bor $(Get-OBSSubs)::INPUTVOLUMEMETERS)
        $e_client = Get-OBSEvent -hostname $conn.hostname -port $conn.port -pass $conn.password -subs $subs
        $callbacks = @(
            @("InputMuteStateChanged", ${function:InputMuteStateChanged}),
            @("InputVolumeMeters", ${function:InputVolumeMeters})
        )
        $e_client.Register($callbacks)
    }
    finally { 
        $r_client.TearDown()
        $e_client.TearDown()
    }
}

if ($MyInvocation.InvocationName -ne '.') { main }
