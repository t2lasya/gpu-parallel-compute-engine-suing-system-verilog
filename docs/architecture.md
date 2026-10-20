# Architecture

```text
Host / testbench
      |
      v
command_controller (one-entry command buffer)
      |
      v
round_robin_scheduler ----> compute_unit 0 ----+
      |                                        |
      +--------------------> compute_unit 1 ---+--> result interface
                                               |
                                      performance_counters

shared_memory <---- simple single-port interface ----> dma_controller
```

The arithmetic command path and DMA/scratchpad path are included as separate blocks in this prototype. The DMA is not yet connected to the command stream or top-level memory port; integrate them if a single end-to-end memory-fed workload is required.

## Handshake timing

A transfer occurs on a rising clock edge when `valid && ready` are both high. Producers must keep payload stable while `valid=1` and `ready=0`. Reset is active-low and asynchronous for control registers. The scratchpad uses synchronous read data.

## Scheduler policy

When both requests are asserted, the scheduler grants the requester selected by `prefer1`. After an accepted grant, it prefers the opposite requester on the next tie. If only one requester is active, that requester is granted.
