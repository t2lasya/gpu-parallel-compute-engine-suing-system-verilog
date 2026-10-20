# Verification plan and traceability

| Requirement | Planned / included check | Status |
|---|---|---|
| Reset and initialization | Top and scheduler reset in testbenches | Included |
| Simultaneous scheduler requests | Scheduler TB drives req0=req1=1 | Included |
| Correct arithmetic | Reference function checks all 8 opcodes | Included |
| Memory read/write | Add dedicated `shared_memory` test | TODO |
| DMA copy correctness | Add memory model and DMA test | TODO |
| Scheduler fairness | Tie requests repeatedly and check alternating grants | Basic test included |
| Backpressure | Top interface has ready/valid; extend TB to randomize `result_ready` | Partial |
| Random transactions | Fixed-seed random arithmetic sequence | Included |
| Reference-model comparison | Expected queue checked against outputs | Included |
| One vs two compute units | Build parameterized 1/2 CU variants and compare cycles | TODO |
| Assertions / coverage | Add SVA and functional coverage | TODO |

Do not describe TODO items as completed in a report. Save simulator transcript and tool/version information with the submission.
