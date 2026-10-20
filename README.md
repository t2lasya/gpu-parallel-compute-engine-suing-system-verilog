# GPU-Inspired Parallel Compute Engine (SystemVerilog)

A small, educational RTL prototype with two arithmetic compute units, round-robin dispatch, a shared scratchpad RAM, a simple DMA-style copy engine, and performance counters.

> **Scope / limitations:** This is a synthesizable learning prototype, not a GPU, AXI/AXI-Stream DMA implementation, cache-coherent system, or production-ready bus fabric. The top-level command path dispatches one arithmetic command at a time. The scheduler is independently testable and supports simultaneous requests. The scratchpad and DMA are simple single-clock interfaces. Timing, throughput, and synthesis results must be measured in your selected simulator/FPGA flow; none are fabricated here.

## Repository layout

- `rtl/` — synthesizable SystemVerilog modules
- `tb/` — self-checking testbenches
- `docs/` — architecture, timing, verification and measurement notes
- `scripts/` — example simulator commands
- `reports/` — place actual simulator/synthesis reports here
- `constraints/` — optional FPGA constraints template

## Arithmetic operation encoding

| `op` | Operation | Result |
|---|---|---|
| `3'd0` | ADD | `a + b` |
| `3'd1` | SUB | `a - b` |
| `3'd2` | MUL | low `DATA_W` bits of `a*b` |
| `3'd3` | MAC | `a*b + c`, low `DATA_W` bits |
| `3'd4` | XOR | `a ^ b` |
| `3'd5` | AND | `a & b` |
| `3'd6` | OR | `a | b` |
| `3'd7` | PASS A | `a` |

Arithmetic wraps modulo `2**DATA_W`; MUL/MAC intentionally return the low `DATA_W` bits.

## Quick start

1. Extract the ZIP.
2. Open the folder in Vivado or Questa.
3. Add all `rtl/*.sv` files as design sources.
4. Add `tb/tb_parallel_compute_top.sv` as a simulation source and set it as simulation top.
5. Run simulation and inspect the self-checking PASS/FAIL message.

For Questa, from the repository root:

```sh
vlib work
vlog -sv rtl/*.sv tb/tb_parallel_compute_top.sv
vsim -c tb_parallel_compute_top -do "run -all; quit -f"
```

For Vivado, create an RTL project, add sources, then run Behavioral Simulation. Simulator command syntax can vary by installed version.

## Current test coverage

The top testbench checks reset, arithmetic results, result backpressure, and a small randomized arithmetic sequence against a software-style reference function. The scheduler testbench checks simultaneous requests and alternating grant priority. The shared-memory and DMA modules have clean standalone interfaces and should also be tested independently before treating the design as complete.

## Important design notes

- Commands are accepted when `cmd_valid && cmd_ready`.
- Results remain valid until `result_ready` is asserted.
- The top-level scheduler assigns each accepted command to one of two compute units. Each compute unit has a one-entry result holding register.
- The shared memory is a single-port synchronous scratchpad. Read data is registered.
- The DMA controller copies one word per accepted memory read/write phase using the provided simple memory-side handshake.
- Counter values are exposed as hardware outputs; clear them with `perf_clear`.
- A successful compile/simulation is not proof of timing closure or hardware correctness. Save actual logs and synthesis reports under `reports/`.

## Suggested next steps

1. Add independent self-checking tests for `shared_memory` and `dma_controller`.
2. Add assertions for handshake stability, no duplicate dispatch, and scheduler fairness.
3. Add a proper bus protocol (e.g. AXI4-Lite control + AXI DMA) if the project scope requires it.
4. Synthesize for a specific FPGA part and record LUT/FF/BRAM/DSP and Fmax.
5. Compare one-unit and two-unit configurations using identical randomized workloads and report measured cycle counts.
