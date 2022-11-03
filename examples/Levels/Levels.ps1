Import-Module OBSWebSocket

enum Channel {
    LEFT = 0
    RIGHT = 1
}

enum LevelTypes {
    VU = 0
    POSTFADER = 1
    PREFADER = 2
}

function Convert($x) {
    if ($x -gt 0) { [math]::Round(20 * [Math]::Log10($x), 1) } else { return -200.0 }
}

function InputVolumeMeters($data) {
    $data.inputs | ForEach-Object {
        if ($_.inputName -eq "Desktop Audio") {
            if ($_.inputLevelsMul) {
                $left = $_.inputLevelsMul[[Channel]::LEFT]
                $right = $_.inputLevelsMul[[Channel]::RIGHT]
                @(
                    "L: " + $(Convert($left[[LevelTypes]::POSTFADER])), 
                    "R: " + $(Convert($right[[LevelTypes]::POSTFADER]))
                ) -Join " " | Write-host
            }
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
