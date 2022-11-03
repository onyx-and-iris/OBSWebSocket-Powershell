. $PSScriptRoot\requests.ps1
. $PSScriptRoot\events.ps1


Function Get-OBSRequest {
    param($hostname, $port = 4455, $pass)
    return [Request]::new($hostname, $port, $pass)
}

Function Get-OBSEvent {
    param($hostname, $port = 4455, $pass, $subs = $(Get-LowVolume))
    return [Event]::new($hostname, $port, $pass, $subs)
}

Export-ModuleMember -Function Get-OBSRequest, Get-OBSEvent, Get-Subs, Get-LowVolume, Get-HighVolume, Get-All
