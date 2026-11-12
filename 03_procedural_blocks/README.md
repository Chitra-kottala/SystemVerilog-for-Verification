# 03 · Procedural Blocks

## 🧭 Big picture

**Procedural block:** a container for code. Inside it, lines run **in order, top to bottom**.

- Every block sits **directly inside the module**. No block goes inside another.
- All blocks **run in parallel**, like separate pieces of hardware.
- What makes them different is **when** they run.

```
 inputs ──► [ gates ] ──► [ flip-flops ] ──► outputs
           always_comb      always_ff
        (changes instantly) (changes only on clock edge)
                                ▲
                               clk
```

---

## 🤔 Which one should I use?

| If you are writing... | Use | Runs |
|---|---|---|
| Testbench steps | `initial` | once, at time 0 |
| Gates (no clock) | `always_comb` | every time an input changes |
| Flip-flops (with clock) | `always_ff` | on every clock edge |
| Latches (with enable) | `always_latch` | while enable is 1 |

---

## 👥 How they work together

**Think of it as:** workers in the same room, all working at the same time.

| Block | Job |
|---|---|
| `always #5 clk = ~clk;` | **Clock maker** — flips the clock every 5 time units, forever |
| `always_comb` / `always_ff` / `always_latch` | **Hardware** — produces the output |
| `initial` | **Tester** — changes the inputs, prints the output |

**Remember:** `initial` changes the inputs. `always` blocks produce the outputs.

---

## 1. initial

**Think of it as:** A one-time script.

**Definition:** Starts at time 0, runs its lines once from top to bottom, then stops. Never repeats.

```systemverilog
initial begin
  $display("Step 1");
  $display("Step 2");
end
```

**Output:** `Step 1`, `Step 2`

**Remember:** Testbench only. `begin`/`end` group more than one line.

---

## 2. always_comb

**Think of it as:** A gate. Output changes the moment an input changes.

**Definition:** Describes combinational logic. No clock, no memory.

```systemverilog
always_comb y = a & b;
```

**Output:** `a=1 b=0 → y=0`, then `a=1 b=1 → y=1`

**Remember:** No clock. Use `=`.

---

## 3. always_ff

**Think of it as:** A flip-flop. Waits for the clock.

**Definition:** Describes sequential logic. On the rising clock edge, it captures input `d` and copies it to output `q`.

```systemverilog
always_ff @(posedge clk) q <= d;
```

**Output:** before clock `q=x`, after clock `q=1`

**Remember:** Has a clock. Use `<=`. Before the first clock edge, `q` is X (unknown).

---

## 4. always_latch

**Think of it as:** A door. Open while `en` = 1, locked when `en` = 0.

**Definition:** Describes a latch. When `en` = 1, `lq` follows `ld`. When `en` = 0, `lq` holds its last value. No clock edge.

```systemverilog
always_latch if (en) lq <= ld;
```

**Output:** `en=1 → lq follows ld`, `en=0 → lq holds`

**Remember:** No `else` here on purpose. When `en` = 0, nothing assigns `lq`, so it **remembers**. Hardware that remembers = latch.

---

### ⚠️ Accidental latch: forgetting `else`

A gate (`always_comb`) must **never remember**. Its output must be assigned in **every** case.

If you forget `else`, there's a case where the output is not assigned. The tool has to remember the old value, so it builds a **latch you didn't want**.

```systemverilog
// ❌ Forgot else → when sel = 0, y is not assigned → accidental latch
always_comb
  if (sel) y = a;

// ✅ With else → y assigned in every case → pure gate (mux)
always_comb
  if (sel) y = a;
  else     y = b;
```

**Remember:** In `always_comb`, every `if` needs an `else`, and every `case` needs a `default`. Otherwise you get a latch.

---

## 5. Blocking `=` vs Non-blocking `<=`

**Think of it as:**
- `=` → one step after another, like a recipe
- `<=` → take a photo of all old values first, then everyone updates together

**Definition:**
- **Blocking** `=` updates immediately. The next line sees the new value.
- **Non-blocking** `<=` updates at the end of the time step. All lines see the old values.

```systemverilog
x1 = 1; x2 = 2;
x1 = x2;  x2 = x1;     // blocking → x1=2, x2=2 (swap fails)

y1 = 1; y2 = 2;
y1 <= y2; y2 <= y1;    // non-blocking → y1=2, y2=1 (swap works)
```

**Remember:** `always_comb` → `=`. `always_ff` and `always_latch` → `<=`.

---

### Why `<=` for flip-flops?

**Real flip-flops all grab their input at the same moment.** `<=` copies that behavior.

Two flip-flops in a chain: `d → q1 → q2`
Start: d = 5, q1 = 0, q2 = 0. One clock edge happens.

| | Code | q1 | q2 | Result |
|---|---|:---:|:---:|---|
| ✅ Non-blocking | `q1 <= d; q2 <= q1;` | 5 | 0 | 5 moves **one step** per clock |
| ❌ Blocking | `q1 = d; q2 = q1;` | 5 | 5 | 5 jumps **two steps** in one clock |

---

## ⏱️ Useful testbench words

| Code | Meaning |
|---|---|
| `#1` | Wait 1 time unit (not one clock) |
| `always #5 clk = ~clk;` | Flip the clock every 5 time units |
| `@(posedge clk)` | Wait until the clock rises |
| `$finish` | Stop the simulation. Needed when something runs forever, like a clock |

---

## ▶️ Expected output

```
always_comb: a=1 b=0 y=0
always_comb: a=1 b=1 y=1
always_ff before clock: d=1 q=x
always_ff after clock:  d=1 q=1
always_latch en=1: ld=1 lq=1 (follows)
always_latch en=0: ld=0 lq=1 (holds)
blocking:     x1=2 x2=2
non-blocking: y1=2 y2=1
```

---

## 📋 Quick revision

| Block | Clock? | Assignment | Describes |
|---|:---:|:---:|---|
| `initial` | No | `=` | Testbench steps |
| `always_comb` | No | `=` | Gates |
| `always_ff` | Yes | `<=` | Flip-flops |
| `always_latch` | No (enable) | `<=` | Latches |

---

## 🎯 Interview questions

**Q: What is a procedural block?**
A container where lines run in order. Different blocks run in parallel.

**Q: Blocking vs non-blocking?**
Blocking updates immediately. Non-blocking updates at the end of the time step, so all lines read old values.

**Q: Why use `<=` in always_ff?**
Real flip-flops all grab their input at the same moment. `<=` copies that.

**Q: Why is q = x before the clock?**
The flip-flop hasn't been clocked or reset yet, so its value is unknown.

**Q: initial vs always?**
initial runs once. always repeats every time its trigger happens.

**Q: How does an accidental latch happen?**
In `always_comb`, an `if` without `else` (or a `case` without `default`) leaves the output unassigned in some case, so the tool builds a latch to remember it.

**Q: Latch vs flip-flop?**
A flip-flop updates only on the clock edge. A latch follows its input the whole time enable is 1.

---

## ▶️ Run it
Paste [`procedural_blocks.sv`](procedural_blocks.sv) into [EDA Playground](https://www.edaplayground.com) → Synopsys VCS → Run
