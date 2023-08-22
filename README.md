# Bluetooth Library Patcher

## Description

This module attends to avoid losing bluetooth pairings after reboot or airplane mode switch on rooted samsung devices.

It patches on the fly the bluetooth library and should support most of samsung devices on android Nougat, Oreo, Pie, 10, 11, 12 and 13.

This patch is NOT applicable with an aosp rom, only samsung stock/based.

## Galaxy Watch devices support

Due to limitations in Magisk, a manual step is required to fix pairing issues with Galaxy Watch devices. After installing the Magisk module, use a command line (like Terminal Emulator or Termux) to run the following commands, then reboot:

*Beware! /!\ Starting from the S21 serie you can not use these commands (or you have to be SURE your vendor partition isn't read only or full) and must instead use the zip bellow to flash using TWRP. The commands below could brick your device /!\*

```bash
$ su
$ mount -o remount,rw /vendor
$ for i in `grep -lr 'security.wsm' /vendor/etc/vintf`; do [ ! -z $i ] && sed -i "$((`awk '/security.wsm/ {print FNR}' $i`-1)),/<\/hal>/d" $i; done
$ mount -o remount,ro /vendor
```

Alternatively with Android 12L and below, instead of installing the Magisk module and running the commands, flash the zip file from [this Github repo releases](https://github.com/3arthur6/BluetoothLibraryPatcher/releases) (BluetoothLibraryPatcher_twrp_X.X.X.zip) meant for TWRP recovery.

## Credits

- @topjohnwu for magisk
- @afaneh92 for the partition resizing script

## Source code

[Github](https://github.com/Magisk-Modules-Repo/BluetoothLibraryPatcher)

## Support

[XDA](https://forum.xda-developers.com/galaxy-note-9/development/zip-libbluetooth-patcher-fix-losing-t4017735)

## Changelog

### v2.6.4

- Add A14 support
- Fix some issue with S23

### v2.6.3

- Add A137F support & fix regressions
- TWRP zip: Apply gear watch fix first

### v2.6.2

- Add support for arm devices on A13
- Process 7z only on A13

### v2.6.1

- Fix OTA survival script on Android 13

### v2.6

- Adding back support for Android 13

### v2.5.1

- Add support for arm devices on A12

### v2.5

- Bring back support for Android 12L (API 32)
- Drop support for Android 13 (API 33) and above

### v2.4.4

- Optimize hex sequences
- Fix support for some old mediatek devices
- Revert adding support for Android 13, module not needed anymore

### v2.4.3

- Fix qcom detection logic
- Add gear watch patch support for Magisk Delta fork
- Fix twrp patch

### v2.4.2

- Add support to Android 13
- Optimize debug stuff

### v2.4.1

- Fix broken qcom patch

### v2.4.0

- Update for Magisk v24.0
- Misc updates

### v2.3.1

- Fix qcoms on Android 12
- Add A105F on Android 11

### v2.3

- Android 12 support
- Handle few specific devices

### v2.2.3

- Handle library changes from latest A505FN firmware and possibly others devices

### v2.2.2

- Fix OTA survival script

### v2.2.1

- Misc fixes

### v2.2

- Large rewrite
- Detect now OTAs and reapply the patch if needed

### v2.1.1

- Divers Android 11 fixes

### v2.1

- Android 11 support
- Android Nougat support
- Misc optimizations

### v2.0

- Support more devices
- Misc optimizations

### v1.9

- Support more arm devices
- Auto create tar with needed files in internal storage to fix unsupported devices

### v1.8

- Add support for A6, A10, A80, some S10e and N10 variants
- Apply the only known qcom fix to all of them
- Add some checks to avoid false negatives

### v1.7

- Add support for chinese/global snapdragon on Pie
- Add support for chinese/global S/N9 snapdragon on Q & simplify the hexpatch

### v1.6

- Fix brand and model detection for magisk manager and recovery installation

### v1.5

- Check we try to apply the patch on a Samsung device & add missing chinese Note10+ 5G variant

### v1.4

- Add support for chinese variants

### v1.3

- Modify hexpatch (more safer patch)

### v1.2

- Add recovery installation support

### v1.1

- Add verification point, to know if we successfully hexpatch

### v1.0

- Initial release
