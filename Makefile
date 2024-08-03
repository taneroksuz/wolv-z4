default: simulate

export VERILATOR ?= /opt/verilator/bin/verilator
export PYTHON ?= /usr/bin/python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export RISCV ?= /opt/rv32imfcb/
export ARCH ?= rv32imfc_zba_zbb_zbc_zbs_zicsr_zifencei
export ABI ?= ilp32f
export CPU ?= wolv-z4

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

program:
	serial/transfer.sh
