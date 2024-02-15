# BluetoothLibraryPatcher
# by 3arthur6

check() {
  samsung=`grep -Eqw "androidboot.odin_download|androidboot.warranty_bit|sec_debug" /proc/cmdline && echo 'true' || echo 'false'`
  if [[ ! -z $KSU_VER ]] ; then
    ui_print "- KernelSU Manager installation"
    sys=/system
  elif $BOOTMODE ; then
    ui_print "- Magisk Manager installation"
    if [[ $MAGISK_VER == *-alpha ]] || [[ $MAGISK_VER == *-kitsune ]]; then
      ui_print "- Magisk Alpha/Kitsune fork detected"
      sys=/system
    else
      sys=`magisk --path`/.magisk/mirror/system
    fi
  else
    ui_print "- Recovery installation"
    sys=`dirname $(find / -mindepth 2 -maxdepth 3 -path "*system/build.prop"|head -1)`
  fi
  if ! $samsung ; then
    ui_print "- Only for Samsung devices!"
    abort
  elif ! `grep -qw ro.build.type=user $sys/build.prop` ; then
    ui_print "- Only for Samsung stock based roms!"
    ui_print "- Not relevant for aosp roms!"
    abort
  elif [[ $API -lt 24 ]] ; then
    ui_print "- Only for Android 7.0 (Nougat) and above"
    abort
  fi
}

search() {
  ui_print "- Searching for relevant hex byte sequence"
  $IS64BIT && bits=64
  unzip -q $ZIPFILE hexpatch.sh -d $TMPDIR
  chmod 755 $TMPDIR/hexpatch.sh
  # Executed through bash for array handling
  unzip -p $ZIPFILE bash$bits.tar.xz|tar x -J -C $TMPDIR bash
  chmod 755 $TMPDIR/bash
  if [[ $API -le 32 ]] ; then
    lib=`find $sys/lib*|grep -E "\/(libbluetooth|bluetooth\.default)\.so$"|tail -n 1`
  else
    unzip -p $ZIPFILE 7z$bits.tar.xz|tar x -J -C $TMPDIR 7z
    chmod 755 $TMPDIR/7z
    unzip -q $sys/apex/com.android.btservices.apex apex_payload.img -d $TMPDIR
    $TMPDIR/7z x -y -bso0 $TMPDIR/apex_payload.img lib$bits/libbluetooth_jni.so -o$TMPDIR/system
    lib=$TMPDIR/system/lib$bits/libbluetooth_jni.so
  fi
  if [[ ! -z $KSU_VER ]] ; then
    bb=/data/adb/ksu/bin/busybox
  elif $BOOTMODE ; then
    bb=`magisk --path`/.magisk/busybox/busybox
  else
    unzip -p $ZIPFILE busybox.tar.xz|tar x -J -C $TMPDIR busybox
    chmod 755 $TMPDIR/busybox
    bb=$TMPDIR/busybox
  fi
  export TMPDIR API IS64BIT lib bb
  $TMPDIR/bash $TMPDIR/hexpatch.sh
}

patchlib() {
  ui_print "- Applying patch"
  pre=`grep pre_hex $TMPDIR/tmp|cut -d '=' -f2`
  post=`grep post_hex $TMPDIR/tmp|cut -d '=' -f2`
  if [[ $pre == already ]] ; then
    if [[ $MAGISK_VER == *-alpha ]] || [[ $MAGISK_VER == *-kitsune ]] ; then
      ui_print "- You are using Magisk Alpha/Kitsune fork"
      ui_print "- Try to uninstall the module, reboot and install it again"
      ui_print "- Or maybe the library is already (system-ly) patched"
    else
      ui_print "- Library already (system-ly) patched!"
      ui_print "- You don't need this Magisk module"
    fi
    abort
  elif [[ -f $lib ]] && [[ ! -z $pre ]] ; then
    mod_path=$MODPATH/`echo $lib|grep -o system.*`
    mkdir -p `dirname $mod_path`
    xxd -p -c `stat -c %s $lib` $lib|sed "s/$pre/$post/"|xxd -pr -c `stat -c %s $lib` > $mod_path
  fi
  if [[ -f $lib ]] && `xxd -p $mod_path|tr -d ' \n'|grep -qm1 $post` ; then
    ui_print "- Successfully patched!"
  else
    ui_print "- Patch failed!"
    echo -e "BOOTMODE=$BOOTMODE\nAPI=$API\nIS64BIT=$IS64BIT\nlib=$lib" >> $TMPDIR/tmp
    cp -f $lib $TMPDIR
    tar c -f /sdcard/BluetoothLibPatcher-files.tar -C $TMPDIR `ls $TMPDIR|sed -E '/bash|hexpatch\.sh|7z/d'`
    ui_print " "
    ui_print "- Opening support webpage in 10 seconds"
    (sleep 10 && am start -a android.intent.action.VIEW -d https://github.com/3arthur6/BluetoothLibraryPatcher/blob/master/SUPPORT.md >/dev/null) &
    abort
  fi
}

otasurvival() {
  if [[ $MAGISK_VER == *-alpha ]] || [[ $MAGISK_VER == *-kitsune ]] ; then
    rm -rf $MODPATH/service.sh
  else
    ui_print "- Creating OTA survival service"
    cp -f $ZIPFILE $MODPATH/module.zip
    if [[ $API -le 32 ]] ; then
      sed -i -e "s@previouslibmd5sum_tmp@previouslibmd5sum=`md5sum $lib|cut -d ' ' -f1`@" \
             -e "s@post_path@`echo $lib|grep -o lib.*.so`@" $MODPATH/service.sh
    else
      sed -i -e "s@previouslibmd5sum_tmp@previouslibmd5sum=`md5sum $sys/apex/com.android.btservices.apex|cut -d ' ' -f1`@" \
             -e "s@post_path@apex/com.android.btservices.apex@" $MODPATH/service.sh
    fi
    if [[ ! -z $KSU_VER ]] ; then
      sed -i 's@$(magisk --path)/.magisk/mirror@@' $MODPATH/service.sh
    fi
   fi
}

deltafork() {
  if [[ $MAGISK_VER == *-delta ]] || [[ $MAGISK_VER == *-kitsune ]] ; then
    ui_print "- Magisk Delta/Kitsune fork detected"
    ui_print "- Applying gear watch fix"
    if `grep "$(magisk --path)/.magisk/early-mount.d" /proc/mounts | grep -q '^early-mount.d/v2'` ; then
      earlymountdir=$MODPATH/early-mount
    else
      earlymountdir=`magisk --path`/.magisk/mirror/early-mount
    fi
    mkdir -p $earlymountdir/system/vendor/vintf/manifest
    for i in `grep -lr 'security.wsm' /vendor/etc/vintf`
    do
      if [[ ! -z $i ]] ; then
        rm -f $earlymountdir/system$i
        cp -af $i $earlymountdir/system$i
        sed -i $((`awk '/security.wsm/ {print FNR}' $i`-1)),/<\/hal>/d $earlymountdir/system$i
      fi
    done
    ui_print "- Adding com.android.bluetooth to SuList"
    magiskhide add com.android.bluetooth 2>/dev/null
    fi
  fi
}

check
search
patchlib
otasurvival
deltafork
