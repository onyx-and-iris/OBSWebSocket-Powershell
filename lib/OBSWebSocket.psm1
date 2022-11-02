. $PSScriptRoot\requests.ps1
. $PSScriptRoot\events.ps1


Function Get-Request {
    param($hostname, $port = 4455, $pass)
    return [Request]::new($hostname, $port, $pass)
}

Function Get-Event {
    param($hostname, $port = 4455, $pass, $subs = $(Get-LowVolume))
    return [Event]::new($hostname, $port, $pass, $subs)
}

Export-ModuleMember -Function Get-Request, Get-Event, Get-Subs, Get-LowVolume, Get-HighVolume, Get-All
