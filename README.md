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

Important: if you do not run pimatic as root your user must be a member of the `gpio` group, and you may need to configure udev with the following rule (assuming Raspberry Pi 3):

```console
$ cat >/etc/udev/rules.d/20-gpiomem.rules <<EOF
SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
EOF
```

## Usage

1. Assign transmitting pin in plugin config. This plugin uses _physical_ pin numbering so by default _pin 22_ is used which is GPIO25 pin for raspberry pi 3.

2. Add a livolo remote device which is similar to standard buttons device. Assign a device a remote id (see above) and a key code to every button.

3. Make your switches learn a newly created remote device.

Livolo plugin also supports `livolo switch` action to activate different buttons on a device.