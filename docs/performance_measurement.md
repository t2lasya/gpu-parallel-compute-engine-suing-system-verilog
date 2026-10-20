# Performance measurement protocol

Do not insert estimated or invented numbers into the report. Measure both configurations under identical conditions.

1. Choose one fixed command sequence and reset the DUT before each run.
2. Count cycles from first accepted command to last accepted result.
3. Record total commands, elapsed cycles, stall cycles, and throughput = commands / elapsed cycles.
4. Repeat with one compute unit and two compute units. A one-unit build can be created by adding a `NUM_CU` parameter and generating only CU0; that parameterization is a recommended extension, not implemented in the current top.
5. For Vivado synthesis, record FPGA part, Vivado version, clock constraint, LUTs, FFs, BRAMs, DSPs, and timing slack/Fmax.
6. Explain that a single in-order command/result stream and one-entry compute-unit result buffers may limit parallel speedup.

| Metric | 1 compute unit | 2 compute units |
|---|---:|---:|
| Commands | Fill with measured value | Same workload |
| Total cycles | Measure | Measure |
| Throughput (commands/cycle) | Calculate | Calculate |
| Stall cycles | Measure | Measure |
| LUT / FF / BRAM / DSP | Synthesis report | Synthesis report |
| Timing slack / Fmax | Timing report | Timing report |
