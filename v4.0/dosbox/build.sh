#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create an empty 1.44M floppy disk image
dd if=/dev/zero of=msdos.img bs=512 count=2880

# create a config file for dosbox
cat >builddos.conf <<EOF
[autoexec]
mount a $SCRIPT_DIR/msdos.img  -t floppy
mount d $SCRIPT_DIR/..
d:
cd src
call setenv
nmake
cpy a:\\
EOF

# GO!
dosbox --nolocalconf --noprimaryconf --conf builddos.conf