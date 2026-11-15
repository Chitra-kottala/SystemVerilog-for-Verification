# 07 · UVM Flow & Scheduling

> How a UVM testbench works from start to finish, and when each part acts around a clock edge.

---

## 🔄 Full UVM flow, step by step

1. **tb_top** (the only module) makes the clock, creates the interface, connects the DUT, stores a **virtual interface handle** in `config_db`, and calls `run_test()`.
2. **Test** builds the **env**. Env builds the **agent** and **scoreboard**. Agent builds the **sequencer**, **driver**, **monitor**.
3. **Driver** and **monitor** each get a copy of the vif handle from `config_db`. Both point to the same real interface.
4. **Test** starts the **sequence** on the sequencer.
5. **Sequence** creates a **sequence item** (e.g. addr = 5, data = 42), randomizes it, and sends it.
6. **Sequencer** passes the item to the **driver** when the driver asks for the next one.
7. **Driver** writes the item's values through `vif.cb`, so the real signals change **just after the clock edge**.
8. **DUT** samples its inputs and updates its outputs **at the clock edge**.
9. **Monitor** samples DUT outputs through `vif.cb` in the **preponed region**, builds a transaction, and sends it through its analysis port.
10. **Scoreboard** compares actual vs expected: pass or error.
11. Steps 5–10 repeat for every item.

**In one line:** sequence makes items → sequencer passes → driver drives pins → DUT responds → monitor rebuilds transactions → scoreboard checks.

---

## 📦 Sequence item vs sequence vs sequencer

| | What it is | Where it sits |
|---|---|---|
| **Sequence item** | One transaction (addr, data). Only data, no signals. | Travels between components |
| **Sequence** | Creates, randomizes and sends items | Not a component. The test starts it on the sequencer |
| **Sequencer** | Passes items from the sequence to the driver | Inside the agent |

**Remember:** sequence **makes**, sequencer **passes**, driver **drives**.

---

## 🔗 How classes reach the interface

- The **real interface** stays in tb_top.
- tb_top stores a **virtual interface** handle in `config_db`:
  ```systemverilog
  uvm_config_db#(virtual bus_if)::set(null, "*", "vif", bif);
  ```
- Driver and monitor **get** a copy of that handle, so all point to the same wires.
- Only the **driver and monitor** touch the interface, so only they use the clocking block.

---

## ⏱️ Who does what around one clock edge

| When | Who | Does what |
|---|---|---|
| **Preponed** (very start of time step) | Monitor | Samples DUT outputs (stable values) |
| **At the edge** | DUT | Samples inputs, updates outputs |
| **Just after the edge** (output skew) | Driver | Drives DUT inputs |

**Clocking block directions are from the TB's view:**
- `input` in cb = what the TB reads = **DUT outputs**
- `output` in cb = what the TB drives = **DUT inputs**

---

## 🕐 Simulation regions

Every time step runs through regions in this order:

**Preponed → Active → Inactive → NBA → Observed → Reactive → Postponed**

| Region | What happens there |
|---|---|
| **Preponed** | Very start, before anything changes. Clocking blocks sample here (`#1step`) |
| **Active** | Blocking `=` runs. Right side of `<=` is read. `$display` prints |
| **NBA** | All `<=` updates are written, together |
| **Postponed** | Very end, values settled. `$strobe` and `$monitor` print |

**Remember:** active **reads**, NBA **writes**.

### Example: `q1 <= d; q2 <= q1;` (d = 5, q1 = 0)

| Region | What happens |
|---|---|
| Active | Reads d = 5 and q1 = 0. Nothing changes yet |
| NBA | Writes q1 = 5, q2 = 0, at the same time |

That's why `<=` models flip-flops correctly: all read old values first, then all update together.

⚠️ **UVM monitor ≠ `$monitor`**
- **UVM monitor** = a class that samples in **preponed**
- **`$monitor`** = a print task that prints in **postponed**

---

## 🎯 Interview questions

**Q: Explain the UVM testbench flow.**
tb_top creates the interface and DUT and starts the test. The test builds the env, agent and scoreboard. A sequence creates items, the sequencer passes them to the driver, the driver drives them through the virtual interface, the monitor samples the DUT and sends transactions to the scoreboard, which checks them.

**Q: How does the driver get the interface?**
tb_top stores a virtual interface handle in `config_db`. The driver gets a copy of it in its build phase.

**Q: Sequence vs sequencer?**
The sequence creates and randomizes items. The sequencer passes them to the driver.

**Q: When does the monitor sample and the driver drive?**
The monitor samples in the preponed region. The driver drives just after the clock edge.

**Q: What are the active and NBA regions?**
In the active region, blocking assignments execute and the right side of non-blocking assignments is evaluated. In the NBA region, all non-blocking updates are applied together.

**Q: Name the simulation regions in order.**
Preponed, active, inactive, NBA, observed, reactive, postponed.
