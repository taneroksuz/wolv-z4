#!/bin/bash
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

rm -f $BASEDIR/sim/input/*.bin
rm -f $BASEDIR/sim/input/*.dat
rm -f $BASEDIR/sim/input/*.host

rm -f $BASEDIR/sim/input/*.reg
rm -f $BASEDIR/sim/input/*.csr
rm -f $BASEDIR/sim/input/*.mem
rm -f $BASEDIR/sim/input/*.vcd
rm -f $BASEDIR/sim/input/*.freg

rm -rf $BASEDIR/sim/output/*

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cd $BASEDIR/sim/work

start=`date +%s`

$VERILATOR --binary --trace --trace-structs --Wno-UNSIGNED --Wno-UNOPTFLAT --top tb_soc -f $BASEDIR/sim/files.f 2>&1 > /dev/null

for FILE in $BASEDIR/sim/input/*; do
  ${RISCV}/bin/riscv32-unknown-elf-nm -A $FILE | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > ${FILE%.*}.host
  ${RISCV}/bin/riscv32-unknown-elf-objcopy -O binary $FILE ${FILE%.*}.bin
  $PYTHON $BASEDIR/py/bin2dat.py --input $FILE --address 0x0 --offset 0x100000
  cp ${FILE%.*}.dat ram.dat
  cp ${FILE%.*}.host host.dat
  if [ "$DUMP" = "1" ]
  then
    obj_dir/Vtb_soc +MAXTIME=$MAXTIME +REGFILE=${FILE%.*}.reg +CSRFILE=${FILE%.*}.csr +MEMFILE=${FILE%.*}.mem +FREGFILE=${FILE%.*}.freg +FILENAME=${FILE%.*}.vcd
    cp ${FILE%.*}.reg $BASEDIR/sim/output/.
    cp ${FILE%.*}.csr $BASEDIR/sim/output/.
    cp ${FILE%.*}.mem $BASEDIR/sim/output/.
    cp ${FILE%.*}.vcd $BASEDIR/sim/output/.
    cp ${FILE%.*}.freg $BASEDIR/sim/output/.
  else
    obj_dir/Vtb_soc +MAXTIME=$MAXTIME
  fi
done

end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
