#!/bin/bash

DIR="./waveforms" 

iverilog -g2012 -o alu_tb.out \
    rtl/*.v \
    tb/alu_tb.sv

if ! [-d "$DIR" ]; then
    mkdir "waveforms"
fi

vvp alu_tb.out