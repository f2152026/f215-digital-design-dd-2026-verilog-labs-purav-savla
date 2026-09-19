# Lab 2 — Written Answers

## Task 1 — Nets vs. registers

**Bugs:** `mux_df.v` declared `Y` as `output reg` but drove it with `assign`; `mux_beh.v` declared `Y` as `output wire` but assigned it inside `always`. Fixed by swapping them: `wire` for dataflow, `reg` for behavioral.

- **Why dataflow needs a net:** `assign` describes a continuous connection. A net has no storage — its value is whatever its driver computes at every instant, which is exactly what a continuous assignment is.
- **Why behavioral needs a `reg`:** a procedural block only runs when triggered, so between executions the output must *hold* its last value. Only a variable (`reg`) can remember a value between assignments.
- **What confuses the simulator:** with the bug, it's asked to continuously drive a variable (which is only allowed to change from procedural code), or to procedurally store a value into a net (which has no storage to write into). Neither has a meaning, so compilation fails.

## Task 2 — ROM

`mem[i] = i*i` is loaded in an `initial` block with a `for` loop (runs once at time 0), and `dout` is read with `always @(*) dout = mem[sel];`. The testbench overrides the parameters with `#(.WIDTH(8), .DEPTH(8))`, so `sel` becomes `$clog2(8) = 3` bits wide, and checks all 8 addresses. The testbench waits `#1` before the first read so the ROM's `initial` block has finished loading at time 0.

## Task 3 — Comparator

**(a)** The self-checking testbench reported **12/16 passed**. The four failures were exactly the cases **A == B** (00/00, 01/01, 10/10, 11/11), where the output was `GT=1, EQ=1` — two outputs high at once. The pattern pointed at the GT expression.

**(b)** Bug: `GT = (A >= B)` also fires when equal. Fix: `GT = (A > B)`. Re-running the same testbench: **16/16 passed**.

## Task 4 — Delays

The testbench changes inputs every **2** time units. The expected output of an AND gate with delay *d* is `a & b` shifted right by *d*. With a real gate, any pulse shorter than *d* is also absorbed.

| Delay | `assign #d` (dataflow) | `#d y = a & b` (before) | `y = #d a & b` (intra) |
|---|---|---|---|
| 1 | Correct | Correct | Correct |
| 2 | Correct (output = input shifted by 2) | **Wrong** — stuck at 0 | **Wrong** — goes to 1 and stays 1 |
| 3 | Correct — every 2-unit-wide pulse is shorter than the delay, so it's filtered out and `y` stays 0 (inertial delay) | **Wrong** — stuck at 0 | **Wrong** — goes to 1 at t=7 and stays 1 |

**(d) Explanation.**
- **Dataflow `assign #d`** uses an *inertial* delay. Every input change schedules a new output value *d* later and cancels any pending one. It never misses an event, and pulses narrower than *d* get absorbed, which is how a real gate behaves.
- **Delay before the assignment:** the `always` block is stuck at `#d` while waiting. Input changes during that time can't retrigger it, because it isn't waiting at `@(*)`. When it wakes up, it samples whatever `a & b` is *at that moment*. Then it re-arms `@(*)` and waits for the *next* change. Once *d* ≥ the input period, it keeps sampling at the wrong times and misses events, so here it stays at 0.
- **Intra-assignment delay:** it samples `a & b` right away, but the block is still blocked for *d* before it can see another event. Changes during that window are lost. Here it caught `1 & 1`, wrote 1 after the delay, and then missed the edges that should have brought it back to 0.
- With *d* = 1 (smaller than the 2-unit input period), no event arrives while a block is waiting, so all three agree.

**(e) Takeaway.** A delay inside an `always` block *suspends the process*, so the model goes blind to inputs for that time. That's not how hardware behaves. To model propagation delay in combinational logic, use continuous-assignment delays (`assign #d`), which behave like real inertial gate delays. If you do use procedural delays, the stimulus must change more slowly than the delay, or the simulation silently gives wrong results. Delays are simulation-only anyway: synthesis ignores them.

## Task 5 — ALU

The self-checking testbench (fixed-operand op toggles, varied subtractions, plus an exhaustive sweep of all 512 a/b/op combinations) first reported **261/520 passed**.

1. **Sensitivity-list bug:** `always @(a, b)` left out `op`. With a=5, b=3, switching `op` from 0 to 1 left `result` stuck at 8 (the sum) instead of 2. Fix: `always @(a, b, op)`.
2. **Blocking/non-blocking bug:** the subtract path used `<=` for `b_inv → b_twos → result`. Each step read the *old* value of the previous one, so the chain ran one evaluation behind (e.g. 8−2 gave `x`, and 15−1 gave 13 instead of 14). Fix: blocking `=` for all three, since this is combinational logic where each statement feeds the next.

After both fixes: **520/520 passed**.
