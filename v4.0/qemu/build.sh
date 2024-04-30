#!/bin/bash
# Build DOS using QEMU (requires mtools)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create temporary directory
TMPDIR=/tmp/dos400-$$.tmp
mkdir -p $TMPDIR
pushd $TMPDIR

# grab a freedos boot floppy
wget https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-FloppyEdition.zip
unzip FD13-FloppyEdition.zip 144m/x86BOOT.img
mv 144m/x86BOOT.img boot.img
wget https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/repositories/1.3/base/fdapm.zip
unzip fdapm.zip BIN/FDAPM.COM
mcopy -i boot.img BIN/FDAPM.COM ::
wget https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/repositories/1.3/base/himemx.zip
unzip himemx.zip BIN/HIMEMX.EXE
mcopy -i boot.img BIN/HIMEMX.EXE ::
cat >FDAUTO.BAT <<EOF
pause
set PATH=a:\\freedos\\bin
c:
cd src
call \\setenv
loadfix nmake
copy bios\\io.sys \\
copy dos\\msdos.sys \\
copy cmd\\command\\command.com \\
cmd\sys\sys b:
rem call cpy b:\\
rem a:\\fdapm poweroff
EOF
mdel -i boot.img ::FDAUTO.BAT
mcopy -i boot.img FDAUTO.BAT ::
cat > FDCONFIG.SYS <<EOF
VERSION=4.0
DEVICE=HIMEMX.EXE
DOS=HIGH,UMB
DOSDATA=UMB
SHELLHIGH=\\FREEDOS\\BIN\\COMMAND.COM /E:1024 /P=\\FDAUTO.BAT
EOF
mdel -i boot.img ::FDCONFIG.SYS
mcopy -i boot.img FDCONFIG.SYS ::

# create our destination floppy
dd if=/dev/zero of=dos400.img bs=512 count=2880
mformat -i dos400.img ::

# create a hard disk image for the build and populate it
dd if=/dev/zero of=disk0.img bs=1M count=30
mformat -i disk0.img
mcopy -i disk0.img -s $SCRIPT_DIR/../src ::
# the SETENV.BAT script assumes the source is on D, not C.
cat $SCRIPT_DIR/../src/SETENV.BAT | sed -e "s/BAKROOT=d:/BAKROOT=c:/" > SETENV.BAT
mcopy -i disk0.img SETENV.BAT ::


qemu-system-i386 -accel kvm -m 16M  -fda boot.img -fdb dos400.img -hda disk0.img  -boot a



