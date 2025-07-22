# BluetoothLibraryPatcher
# hexpatch script
# by 3arthur6

qcom=`$bb grep -qw androidboot.hardware=qcom /proc/cmdline && echo 'true' || echo 'false'`

# default(mostly arm64 exynos)=1   arm=2   qcom=3
var=`if ! $IS64BIT || [[ $API -le 25 ]] ; then echo 2 ; elif $qcom && [[ $API -ge 28 ]] && [[ $API -le 30 ]] ; then echo 3 ; else echo 1 ; fi`

hex=( \
# default
[136]=00122a0140395f01086b00020054 [1136]=00122a0140395f01086bde030014 \
[135]=480500352800805228 [1135]=530100142800805228 \
[134]=6804003528008052 [1134]=2b00001428008052 \
[133]=6804003528008052 [1133]=2a00001428008052 \
[132]=........f9031f2af3031f2a41 [1132]=1f2003d5f9031f2af3031f2a48 \
[131]=........f9031f2af3031f2a41 [1131]=1f2003d5f9031f2af3031f2a48 \
[130]=........f3031f2af4031f2a3e [1130]=1f2003d5f3031f2af4031f2a3e \
[129]=........f4031f2af3031f2ae8030032 [1129]=1f2003d5f4031f2af3031f2ae8031f2a \
[128]=88000034e8030032 [1128]=1f2003d5e8031f2a \
[127]=88000034e8030032 [1127]=1f2003d5e8031f2a \
[126]=88000034e8030032 [1126]=1f2003d5e8031f2a \
# arm
[234]=4e7e4448bb [1234]=4e7e4437e0 \
[233]=4e7e4440bb [1233]=4e7e4432e0 \
[231]=20b14ff000084ff000095ae0 [1231]=00bf4ff000084ff0000964e0 \
[230]=18b14ff0000b00254a [1230]=00204ff0000b002554 \
[229]=..b100250120 [1229]=00bf00250020 \
[228]=..b101200028 [1228]=00bf00200028 \
[227]=09b1012032e0 [1227]=00bf002032e0 \
[226]=08b1012031e0 [1226]=00bf002031e0 \
[225]=087850bbb548 [1225]=08785ae1b548 \
[224]=007840bb6a48 [1224]=0078c4e06a48 \
# qcom
[330]=88000054691180522925c81a69000037 [1330]=1f2003d5691180522925c81a1f2003d5 \
[329]=88000054691180522925c81a69000037 [1329]=1f2003d5691180522925c81a1f2003d5 \
[328]=7f1d0071e91700f9e83c0054 [1328]=7f1d0071e91700f9e7010014 \
# what is happening samsung
[429]=....0034f3031f2af4031f2a....0014 [1429]=1f2003d5f3031f2af4031f2a47000014 \
# A137F
[531]=10b1002500244ce0 [1531]=00bf0025002456e0 \
# what again (T510)
[530]=18b100244ff0000b4d [1530]=002000244ff0000b57 \
[529]=44387810b1002400254a [1529]=44387800200024002556 \
# ... (T595)
[629]=90387810b1002400254a [1629]=90387800200024002558 )

if [[ "$var" == "3" ]] && ! `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[$var$API]}` ; then
  if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[1$var$API]}` ; then
    hex[$var$API]=already
  else
    var=1
  fi
fi
if ( [[ "$var" == "1" ]] && [[ $API -ge 29 ]] ) || ( [[ "$var" == "2" ]] && [[ $API -ge 28 ]] && [[ $API -le 29 ]] ) ; then
  hex[$var$API]=`$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -om1 ${hex[$var$API]}`
fi
if ! `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[$var$API]}` ; then
  if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[1$var$API]}` ; then
    hex[$var$API]=already
  elif [[ "$var" == "1" ]] && [[ "$API" == "29" ]] && hex[4$API]=`$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -om1 ${hex[4$API]}` && [[ ! -z ${hex[4$API]} ]] ; then
    var=4
  elif [[ "$var" == "2" ]] ; then
    if [[ $API -ge 29 ]] && [[ $API -le 31 ]] ; then
      if `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[5$API]}` ; then
        var=5
      elif `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[6$API]}` ; then
        var=6
      fi
    elif [[ "$API" == "27" ]] && `$bb xxd -p $lib|$bb tr -d '\n'|$bb grep -qm1 ${hex[${var}26]}` ; then
      hex[$var$API]=${hex[${var}26]}
      hex[1$var$API]=${hex[1${var}26]}
    fi
  fi
fi
echo -e "pre_hex=${hex[$var$API]}\npost_hex=${hex[1$var$API]}\nvar=$var\nchip=`$bb grep -o androidboot.hardware=.* /proc/cmdline|$bb cut -d ' ' -f1|$bb cut -d '=' -f2`\nbl=`$bb grep -o androidboot.bootloader=.* /proc/cmdline|$bb cut -d ' ' -f1|$bb cut -d '=' -f2`" >> $TMPDIR/tmp
