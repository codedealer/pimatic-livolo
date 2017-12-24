# Livolo pimatic plugin

Plugin for [pimatic](https://pimatic.org/) to support livolo remote switches. Requires 433 MHz transmitter connected to raspberry pi.

The plugin emulates livolo 433 MHz remote control, so you will need actual values for remote Id and also key codes. If you don't have those you can use these:

Remote Ids:
* 6400; 19303; 10550; 8500; 7400

Key codes (buttons on remote):
```
#1: 0, #2: 96, #3: 120, #4: 24, #5: 80, #6: 48, #7: 108, #8: 12, #9: 72; #10: 40, #OFF: 106
```

## Installation
```
npm install pimatic-livolo
```