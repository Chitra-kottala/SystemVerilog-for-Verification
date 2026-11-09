# 01 · SystemVerilog Data Types

> **TL;DR** — Use `logic` for anything that touches the DUT. Use `bit`, `int`, `enum`, `struct`, `string` for variables that live only inside the testbench.

---

## 🧭 Big picture

A testbench has two kinds of variables:

```
        TESTBENCH                                   DUT
 ┌───────────────────────────┐               ┌──────────────┐
 │  int    count   → loops   │               │              │
 │  string msg     → logs    │    logic      │     RTL      │
 │  enum   state   → FSMs    │ ────────────► │    being     │
 │  struct pkt     → txns    │  addr, data   │   verified   │
 │  bit    flag    → TB only │ ◄──────────── │              │
 └───────────────────────────┘  valid, ready └──────────────┘
      inside the TB only            the wires between them
```

1. **Wires between TB and DUT** → must show real hardware values, including X and Z → **`logic`**
2. **Variables inside the TB** → just need to be fast and readable → **2-state types**

---

## 🤔 Which type should I use?

| If your variable is... | Use |
|---|---|
| Connected to the DUT | `logic` |
| A counter or loop index | `int` |
| Text | `string` |
| An FSM state | `enum` |
| A group of fields (addr + data) | `struct` |
| A simple flag inside the TB | `bit` |

---

## 📋 Cheat sheet

| Type | Values | Starts as |
|---|---|:---:|
| `logic` | 0, 1, X, Z | X |
| `bit` | 0, 1 | 0 |
| `byte` | 8-bit number (can be negative) | 0 |
| `int` | 32-bit number (can be negative) | 0 |

> **Remember:** only `logic` can show X and Z.

---

## 🔍 Each type explained

### 1. `logic` vs `bit` — "Can it say *I don't know*?"

In real hardware, a flip-flop holds a random value when power turns on until reset clears it. The simulator shows that “unknown” as X. Z means nobody is driving the wire (like an unplugged cable).

logic can show X/Z → you see the problem
bit turns X/Z into 0 → the problem hides
```

✅ **Why it matters:** if the DUT forgets to reset a signal, `logic` shows **X** in your waveform. A `bit` would show **0**, and you'd never notice the bug.

---

### 2. Signed vs unsigned — "Same bits, different meaning"

```systemverilog
byte      sb = 8'hFF;   // signed   → -1
bit [7:0] ub = 8'hFF;   // unsigned → 255
```

```
byte 8'hFF  = -1
bit[7:0] FF = 255
```

| Bits `1111_1111` | Read as |
|---|---|
| unsigned (`bit [7:0]`) | 255 |
| signed (`byte`) | -1 |

✅ **Signed** (`byte`, `int`) → counters, math
✅ **Unsigned** (`bit [N:0]`, `logic [N:0]`) → addresses, data buses

---

### 3. `enum` — "Names instead of numbers"

```systemverilog
typedef enum {IDLE, BUSY, DONE} state_t;   // IDLE=0, BUSY=1, DONE=2
state_t state = BUSY;
$display("state = %s (value %0d)", state.name(), state);
```

```
state = BUSY (value 1)
```

✅ Logs and waveforms show **`BUSY`** instead of **`1`** → much faster debugging of FSMs

---

### 4. `struct` — "One form with many fields"

> 💡 **Analogy:** like a shipping label — address and contents travel together.

```systemverilog
typedef struct packed {
  logic [7:0]  addr;
  logic [31:0] data;
} packet_t;

packet_t pkt;
pkt.addr = 8'h10;
pkt.data = 32'hDEAD_BEEF;
```

```
addr = 10, data = deadbeef
```

✅ Describes **one transaction**. In UVM, this idea grows into a **sequence item class**.
📝 `packed` = fields stored back-to-back as one 40-bit vector, so it can be sent on a bus.

---

### 5. `string` — "Text for humans"

```systemverilog
string msg = "Hello DV";
msg.len();   // 8
```

✅ Used for **log messages, test names, error reports**

---

## ⚠️ Common mistakes

| ❌ Mistake | 💥 What happens | ✅ Fix |
|---|---|---|
| Using `bit` for DUT outputs | X becomes 0 → bug hidden | Use `logic` |
| Putting `8'hFF` in a `byte`, expecting 255 | You get -1 | Use `bit [7:0]` |
| Printing an enum with `%d` | Shows `1`, not `BUSY` | Use `.name()` with `%s` |
| Assuming `int` and `integer` are the same | `integer` is 4-state, starts as X | Use `int` in TB code |

---

## 🎯 Interview questions

<details>
<summary><b>Q1. What is the difference between <code>logic</code> and <code>bit</code>?</b></summary>

`logic` is 4-state (0, 1, X, Z) and starts as X. `bit` is 2-state (0, 1) and starts as 0. Use `logic` for DUT signals so X/Z problems are visible; use `bit` in the TB for speed.
</details>

<details>
<summary><b>Q2. What is the difference between <code>int</code> and <code>integer</code>?</b></summary>

Both are 32-bit signed. `int` is 2-state (default 0); `integer` is 4-state (default X).
</details>

<details>
<summary><b>Q3. What happens when you assign X or Z to a <code>bit</code>?</b></summary>

It is converted to 0 — no warning. This can hide bugs.
</details>

<details>
<summary><b>Q4. Packed vs unpacked struct?</b></summary>

Packed: all fields stored as one continuous vector — can be assigned, sliced, or sent on a bus like a normal signal. Unpacked: fields stored separately; can't be treated as one vector.
</details>

<details>
<summary><b>Q5. What is the default base type of an <code>enum</code>?</b></summary>

`int` (32-bit, 2-state). The first name gets 0, the next 1, and so on, unless you assign values.
</details>

---

---

**Next →** [02 · Arrays & Queues](../02_arrays_queues)
