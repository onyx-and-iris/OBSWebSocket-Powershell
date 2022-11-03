## About

Demonstrates the Event client listening on a custom event and the Request client firing off a custom event.

## Use

This example assumes the existence of a `config.psd1`, placed next to `Consumer.ps1`:

```psd1
@{
    hostname = "localhost"
    port     = 4455
    password = "mystrongpassword"
}
```

First run `Consumer.ps1` this will intiate the Events client and listen for a Custom Event.

Then run `Producer.ps1` to fire off a Custom Event.

Closing OBS will end the script the `Consumer` script.
