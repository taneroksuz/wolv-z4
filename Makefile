default: simulate

export VERILATOR ?= verilator
export VERIBLE ?= verible
export PYTHON ?= python3
export SERIAL ?= /dev/ttyUSB0
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export RISCV ?= /opt/rv32imfcb
export ARCH ?= rv32imfc_zba_zbb_zbc_zbs_zicsr_zifencei
export ABI ?= ilp32f
export CPU ?= wolv-z4

export MAXTIME ?= 10000000
export DUMP ?= 0# "1" on, "0" off

simulate:
	sim/run.sh

compile:
	benchmark/benchmarks.sh
	benchmark/coremark.sh
	benchmark/dhrystone.sh
	benchmark/isa.sh
	benchmark/whetstone.sh
	benchmark/free-rtos.sh

parse:
	check/run.sh

program:
	serial/transfer.sh
