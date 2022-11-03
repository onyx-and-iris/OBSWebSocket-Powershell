## About

Prints POSTFADER level values for audio device `Desktop Audio`. If mute toggled prints mute state changed notification.

## Use

This example assumes the existence of a `config.psd1`, placed next to `Levels.ps1`:

```psd1
@{
    hostname = "localhost"
    port     = 4455
    password = "mystrongpassword"
}
```

Closing OBS will end the script.
