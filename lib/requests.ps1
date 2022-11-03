. $PSScriptRoot\base.ps1


class OBSWebSocketError : Exception {
    [string]$msg

    OBSWebSocketError ([string]$msg) {
        $this.msg = $msg
    }

    [string] ErrorMessage () {
        return $this.msg
    }
}


class Request {
    [object]$base

    Request ([string]$hostname, [int]$port, [string]$pass) {
        $this.base = Get-Base -hostname $hostname -port $port -pass $pass
        if (!($this.base.RunHandler() -eq 2)) { 
            $this.Teardown()
            throw [OBSWebSocketError]::new("Failed to identify $this client with server")
            exit
        }
        "Successfully identified $this client with server" | Write-Debug 
    }

    [object] Send($Payload) {
        $this.base.send_queue.Enqueue($($Payload | ConvertTo-Json -Depth 5))
        do {
            $response = $this.base.RunHandler()
        } until ($this.base.data.op -eq 7)
        return $response
    }

    [object] Call($cmd) {
        $id = Get-Random -Maximum 1000
        $Payload = @{
            op = 6
            d  = @{
                requestType = $cmd
                requestId   = $id
            }
        }
        return $this.Send($Payload)
    }

    [object] Call($cmd, $data) {
        $id = Get-Random -Maximum 1000
        $Payload = @{
            op = 6
            d  = @{
                requestType = $cmd
                requestId   = $id
                requestData = $data
            }
        }
        return $this.Send($Payload)
    }
    
    [object] GetVersion() {
        return $this.Call("GetVersion")
    }

    [object] GetStats() {
        return $this.Call("GetStats")
    }

    [void] BroadcastCustomEvent($data) {
        $this.Call("BroadcastCustomEvent", $data)
    }

    [object] GetSceneList() {
        return $this.Call("GetSceneList")
    }
    
    [object] GetCurrentProgramScene() {
        return $this.Call("GetCurrentProgramScene")
    }

    [void] SetCurrentProgramScene($name) {
        $data = @{ sceneName = $name }
        $this.Call("SetCurrentProgramScene", $data)
    }

    [void] TearDown() {
        $this.base.Teardown()
    }
}
