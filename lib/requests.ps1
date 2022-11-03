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

    [void] BroadcastCustomEvent($payload) {
        $this.Call("BroadcastCustomEvent", $payload)
    }

    [object] GetHotkeyList() {
        return $this.Call("GetHotkeyList")
    }

    [object] TriggerHotkeyByName($name) {
        $payload = @{ hotkeyName = $name }
        return $this.Call("TriggerHotkeyByName", $payload)
    }

    [void] TriggerHotkeyByKeySequence($keyId, $pressShift, $pressCtrl, $pressAlt, $pressCmd) {
        $payload = @{
            keyId = $keyId
            keyModifiers = @{
                shift = $pressShift
                control = $pressCtrl
                alt = $pressAlt
                cmd = $pressCmd
          }
        }
        $this.Call("TriggerHotkeyByKeySequence", $payload)        
    }

    [void] Sleep($sleepMillis, $sleepFrames) {
        $payload = @{
            sleepMillis = $sleepMillis
        }
        $this.Call("Sleep", $payload)
    }

    [object] GetPersistentData($realm, $slotName) {
        $payload = @{ 
            realm = $realm
            slotName = $slotName
        }
        return $this.Call("GetPersistentData", $payload)
    }

    [void] SetPersistentData($realm, $slotName, $slotValue) {
        $payload = @{ 
            realm = $realm
            slotName = $slotName
            slotValue = $slotValue
        }
        $this.Call("SetPersistentData", $payload)
    }

    [object] GetSceneCollectionList() {
        return $this.Call("GetSceneCollectionList")
    }

    [void] SetCurrentSceneCollection($name) {
        $payload = @{ sceneCollectionName = $name }
        $this.Call("SetCurrentSceneCollection", $payload)
    }

    [void] CreateSceneCollection($name) {
        $payload = @{ sceneCollectionName = $name }
        $this.Call("CreateSceneCollection", $payload)
    }

    [object] GetProfileList() {
        return $this.Call("GetProfileList")
    }

    [void] SetCurrentProfile($name) {
        $payload = @{ profileName = $name }
        $this.Call("SetCurrentProfile", $payload)
    }

    [void] CreateProfile($name) {
        $payload = @{ profileName = $name }
        $this.Call("CreateProfile", $payload)
    }

    [void] RemoveProfile($name) {
        $payload = @{ profileName = $name }
        $this.Call("RemoveProfile", $payload)
    }

    [object] GetProfileParameter($category, $name) {
        $payload = @{ 
            parameterCategory = $category
            parameterName = $name 
        }
        return $this.Call("GetProfileParameter", $payload)
    }

    [void] SetProfileParameter($category, $name, $value) {
        $payload = @{
            parameterCategory = $category
            parameterName = $name
            parameterValue = $value
        }
        $this.Call("SetProfileParameter", $payload)        
    }

    [object] GetVideoSettings() {
        return $this.Call("GetVideoSettings")
    }

    [void] SetVideoSettings($numerator, $denominator, $baseWidth, $baseHeight, $outWidth, $outHeight) {
        $payload = @{
            fpsNumerator = $numerator
            fpsDenominator = $denominator
            baseWidth = $baseWidth
            baseHeight = $baseHeight
            outputWidth = $outWidth
            outputHeight = $outHeight
        }
        $this.Call("SetVideoSettings", $payload)        
    }

    [object] GetStreamServiceSettings() {
        return $this.Call("GetStreamServiceSettings")
    }

    [void] SetStreamServiceSettings($ssType, $ssSettings) {
        $payload = @{
            streamServiceType = $ssType
            streamServiceSettings = $ssSettings
        }
        $this.Call("SetStreamServiceSettings", $payload)        
    }

    [object] GetRecordDirectory() {
        return $this.Call("GetRecordDirectory")
    }

    [object] GetSourceActive($name) {
        $payload = @{ sourceName = $name }
        return $this.Call("GetSourceActive", $payload)
    }

    [object] GetSourceScreenshot($name, $imgFormat, $width, $height, $quality) {
        $payload = @{
            sourceName = $name
            imageFormat = $imgFormat
            imageWidth = $width
            imageHeight = $height
            imageCompressionQuality = $quality
        }
        return $this.Call("GetSourceScreenshot", $payload)        
    }

    [object] SaveSourceScreenshot($name, $imgFormat, $filePath, $width, $height, $quality) {
        $payload = @{
            sourceName = $name
            imageFormat = $imgFormat
            imageFilePath = $filePath
            imageWidth = $width
            imageHeight = $height
            imageCompressionQuality = $quality
        }
        return $this.Call("SaveSourceScreenshot", $payload)      
    }

    [object] GetSceneList() {
        return $this.Call("GetSceneList")
    }

    [object] GetGroupList() {
        return $this.Call("GetGroupList")
    }
    
    [object] GetCurrentProgramScene() {
        return $this.Call("GetCurrentProgramScene")
    }

    [void] SetCurrentProgramScene($name) {
        $payload = @{ sceneName = $name }
        $this.Call("SetCurrentProgramScene", $payload)
    }

    [void] SetCurrentPreviewScene() {
        $this.Call("SetCurrentPreviewScene")
    }

    [void] CreateScene($name) {
        $payload = @{ sceneName = $name }
        $this.Call("CreateScene", $payload)
    }

    [void] RemoveScene($name) {
        $payload = @{ sceneName = $name }
        $this.Call("RemoveScene", $payload)
    }

    [void] SetSceneName($oldName, $newName) {
        $payload = @{ 
            sceneName = $oldName
            newSceneName = $newName 
        }
        $this.Call("SetSceneName", $payload)
    }

    [object] GetSceneSceneTransitionOverride($name) {
        $payload = @{ sceneName = $name }
        return $this.Call("GetSceneSceneTransitionOverride", $payload)     
    }

    [void] SetSceneSceneTransitionOverride($sceneName, $trName, $trDuration) {
        $payload = @{
            sceneName = $sceneName
            transitionName = $trName
            transitionDuration = $trDuration
        }
        $this.Call("SetSceneSceneTransitionOverride", $payload)        
    }

    [object] GetInputList($kind) {
        $payload = @{ inputKind = $kind }
        return $this.Call("GetInputList", $payload)
    }

    [object] GetInputKindList($unversioned) {
        $payload = @{ unversioned = $unversioned }
        return $this.Call("GetInputKindList", $payload)
    }

    [object] GetSpecialInputs() {
        return $this.Call("GetSpecialInputs")
    }

    [object] CreateInput($sceneName, $inputName, $inputKind, $inputSettings, $sceneItemEnabled) {
        $payload = @{
          sceneName = $sceneName
          inputName = $inputName
          inputKind = $inputKind
          inputSettings = $inputSettings
          sceneItemEnabled = $sceneItemEnabled
        }
        return $this.Call("CreateInput", $payload)        
    }

    [void] RemoveInput($name) {
        $payload = @{ inputName = $name }
        $this.Call("RemoveInput", $payload)
    }

    [void] SetInputName($oldName, $newName) {
        $payload = @{ 
            inputName = $oldName
            newInputName = $newName 
        }
        $this.Call("SetInputName", $payload)
    }

    [object] GetInputDefaultSettings($kind) {
        $payload = @{ inputKind = $kind }
        return $this.Call("GetInputDefaultSettings", $payload)
    }

    [object] GetInputSettings($kind) {
        $payload = @{ inputKind = $kind }
        return $this.Call("GetInputSettings", $payload)
    }

    [void] SetInputSettings($name, $settings, $overlay) {
        $payload = @{ 
            inputName = $name
            inputSettings = $settings
            overlay = $overlay 
        }
        $this.Call("SetInputSettings", $payload)
    }

    [object] GetInputMute($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputMute", $payload)
    }

    [void] SetInputMute($name, $muted) {
        $payload = @{ 
            inputName = $name
            inputMuted = $muted
        }
        $this.Call("SetInputMute", $payload)
    }

    [object] ToggleInputMute($name) {
        $payload = @{ inputName = $name }
        return $this.Call("ToggleInputMute", $payload)
    }

    [object] GetInputVolume($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputVolume", $payload)
    }

    [void] SetInputVolume($name, $volMul, $volDb) {
        $payload = {
            inputName = $name
            inputVolumeMul = $volMul
            inputVolumeDb = $volDb
        }
        $this.Call("SetInputVolume", $payload)        
    }

    [object] GetInputAudioBalance($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputAudioBalance", $payload)
    }

    [void] SetInputAudioBalance($name, $balance) {
        $payload = @{ 
            inputName = $name
            inputAudioBalance = $balance
        }
        $this.Call("SetInputAudioBalance", $payload)
    }

    [object] GetInputAudioSyncOffset($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputAudioSyncOffset", $payload)
    }

    [void] SetInputAudioSyncOffset($name, $offset) {
        $payload = @{ 
            inputName = $name
            inputAudioSyncOffset = $offset
        }
        $this.Call("SetInputAudioSyncOffset", $payload)
    }

    [object] GetInputAudioMonitorType($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputAudioMonitorType", $payload)
    }

    [void] SetInputAudioMonitorType($name, $monType) {
        $payload = @{ 
            inputName = $name
            monitorType = $monType 
        }
        $this.Call("SetInputAudioMonitorType", $payload)
    }

    [object] GetInputAudioTracks($name) {
        $payload = @{ inputName = $name }
        return $this.Call("GetInputAudioTracks", $payload)
    }

    [void] SetInputAudioTracks($name, $track) {
        $payload = @{ 
            inputName = $name
            inputAudioTracks = $track
        }
        $this.Call("SetInputAudioTracks", $payload)
    }

    [object] GetInputPropertiesListPropertyItems($inputName, $propName) {
        $payload = @{ 
            inputName = $inputName
            propertyName = $propName
        }
        return $this.Call("GetInputPropertiesListPropertyItems", $payload)
    }

    [void] PressInputPropertiesButton($inputName, $propName) {
        $payload = @{ 
            inputName = $inputName
            propertyName = $propName
        }
        $this.Call("PressInputPropertiesButton", $payload)
    }

    [object] GetTransitionKindList() {
        return $this.Call("GetTransitionKindList")
    }

    [object] GetSceneTransitionList() {
        return $this.Call("GetSceneTransitionList")
    }

    [object] GetCurrentSceneTransition($name) {
        return $this.Call("GetCurrentSceneTransition")
    }

    [void] SetCurrentSceneTransition($name) {
        payload = @{ transitionName = $name }
        $this.Call("SetCurrentSceneTransition")
    }

    [void] SetCurrentSceneTransitionDuration($duration) {
        payload = @{ transitionDuration = $duration  }
        $this.Call("SetCurrentSceneTransitionDuration")
    }

    [void] SetCurrentSceneTransitionSettings($settings, $overlay = $null) {
        payload = @{ 
            transitionSettings = $settings
            overlay = $overlay
        }
        $this.Call("SetCurrentSceneTransitionSettings")
    }

    [object] GetCurrentSceneTransitionCursor() {
        return $this.Call("GetCurrentSceneTransitionCursor")
    }

    [void] TriggerStudioModeTransition() {
        $this.Call("TriggerStudioModeTransition")
    }

    [void] SetTBarPosition($pos, $release = $null) {
        $payload = @{ 
            position = $pos 
            release = $release 
        }
        $this.Call("SetTBarPosition", $payload)        
    }

    [void] TearDown() {
        $this.base.Teardown()
    }
}
