# Design review checklist

- [ ] Compile with the selected simulator and resolve all errors/warnings.
- [ ] Verify reset behavior and ready/valid stability under backpressure.
- [ ] Fix/verify result ordering when both compute units have outstanding results.
- [ ] Add independent memory and DMA testbenches.
- [ ] Define simultaneous read/write semantics and address-range behavior.
- [ ] Add parameter checks (`DATA_W`, memory depth/address width).
- [ ] Add one-CU and two-CU configurations for a fair performance comparison.
- [ ] Run lint, assertions, randomized tests, and regression.
- [ ] Synthesize for a named FPGA part and save reports.
- [ ] Update README with actual test logs and measured data.
