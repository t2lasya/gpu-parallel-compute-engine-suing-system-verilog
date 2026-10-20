@echo off
vlib work
vlog -sv rtl\*.sv tb\tb_round_robin_scheduler.sv
vsim -c tb_round_robin_scheduler -do "run -all; quit -f"
vlog -sv rtl\*.sv tb\tb_parallel_compute_top.sv
vsim -c tb_parallel_compute_top -do "run -all; quit -f"
