# Sound Control

## Description

Script to control PulseAudio sound server.

Implemented sound control commands:

- Get Input Status \
  This shows whether the mic is on or off.
- Toggle Input Status \
  This toggles the state of the mic.
- Get Output Status \
  This shows whether the output on the speaker or headphone.
- Toggle Output Status \
  This toggles the output between speaker and headphone.
- Get Volume Level \
  This shows the volume level.
- Set Volume Level \
  This sets the volume level.
- Get Sound Status \
  This shows the state of the input and output also the volume level in JSON format.
- Set Sound Default \
  This sets the default volume of both speaker and headphone.

## Help Message

```bash
Script to control PulseAudio sound server.
Usage: sound-ctl.sh OPTION [EXTRA_ARGS]

OPTION:
  gi  : get input status
  i   : toggle input status
  go  : get output status
  o   : toggle output status
  gv  : get volume level
  sv  : set volume level
  s   : get sound status
  d   : set sound default

EXTRA_ARGS is needed for OPTION:
  sv  : volume level between 0-100
```

### Note

Tested with Linux Mint 20.2 and PulseAudio 13.99.1

### See Also

[Having both speakers and headphones plugged in and switching in software on-the-fly](https://wiki.archlinux.org/title/PulseAudio/Examples#Having_both_speakers_and_headphones_plugged_in_and_switching_in_software_on-the-fly)
