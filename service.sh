# BluetoothLibraryPatcher
# ota survival script
# by 3arthur6

MODDIR=${0%/*}
previouslibmd5sum_tmp

if `echo $(magisk -v)|grep -q '-delta'` ; then
  magiskhide add com.android.bluetooth 2>/dev/null
fi

if [[ $previouslibmd5sum != `md5sum $(magisk --path)/.magisk/mirror/system/post_path|cut -d " " -f1` ]] ; then
  magisk --install-module $MODDIR/module.zip
else
  exit
fi
