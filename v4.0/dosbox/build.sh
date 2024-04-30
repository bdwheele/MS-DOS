#!/bin/bash
# Build DOS using DOSBOX
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create a temporary directory and do the work there...
TMPDIR=/tmp/dos400-$$.tmp
mkdir -p $TMPDIR/dos400
cp -av $SCRIPT_DIR/../src $TMPDIR


# create a config file for dosbox
cat >$TMPDIR/builddos.conf <<EOF
[speaker]
pcspeaker=false
[mixer]
nosound=true
[autoexec]
mount d $TMPDIR
mount c $TMPDIR/dos400
d:
cd src
call setenv
nmake
call cpy c:\\
exit
EOF

# GO!
dosbox --nolocalconf --noprimaryconf --conf $TMPDIR/builddos.conf --exit

# gather the artifacts
pushd $TMPDIR
zip -r $SCRIPT_DIR/dos400.zip dos400
popd

# clean up
rm -rf $TMPDIR
