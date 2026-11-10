# 01 · SystemVerilog Data Types

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

## 🔍 Each type explained

### 1. `logic` — "Can it say *I don't know*?"

In real hardware, a flip-flop holds a random value when power turns on, until reset clears it. The simulator shows that "unknown" value as **X**. **Z** means nobody is driving the wire, like an unplugged cable.

`logic` is a **4-state** type: it can hold 0, 1, X and Z. It starts as X. So if the design forgets to reset a signal, you will see X in your waveform and catch the bug.

```systemverilog
logic a;
$display("a = %b", a);   // a = x
a = 1'bz;
$display("a = %b", a);   // a = z
```

👉 Use `logic` for every signal connected to the DUT.

---

### 2. `bit` — "Always 0 or 1, even when it's wrong"

`bit` is a **2-state** type: it can only hold 0 or 1. It starts as 0. If you put X or Z into a `bit`, it silently becomes 0 — no error, no warning.

That makes it faster for the simulator, but it can hide bugs. If the DUT sends X and your variable is a `bit`, you'll see 0 and think everything is fine.

```systemverilog
bit b;
$display("b = %b", b);   // b = 0
b = 1'bz;
$display("b = %b", b);   // b = 0  (Z was lost)
```

👉 Use `bit` only for variables that live inside the testbench, like flags.

---

### 3. Signed vs unsigned — "Same bits, different meaning"

A variable is just a row of bits. The type decides how those bits are read as a number.

- **Unsigned** reads all bits as positive. 8 bits → 0 to 255.
- **Signed** lets the number be negative. 8 bits → −128 to 127.

For an 8-bit signed variable, anything above 127 is read as **value − 256**. So 255 becomes −1, and 200 becomes −56.

```systemverilog
byte      s = 200;   // signed   → -56
bit [7:0] u = 200;   // unsigned → 200
```

| Bits `1100_1000` | Read as |
|---|---|
| unsigned (`bit [7:0]`) | 200 |
| signed (`byte`) | −56 |

👉 Use unsigned for addresses and data buses. Use signed for counters and math.

---

### 4. `byte` and `int` — "Ready-made signed numbers"

`byte` is an 8-bit signed number. `int` is a 32-bit signed number. Both are 2-state and start at 0.

`int` is the one you'll use most — for loop counters, number of transactions, error counts. Don't confuse it with `integer`: same size, but `integer` is 4-state and starts as X.

```systemverilog
int count = 10;
for (int i = 0; i < count; i++) ...
```

👉 Use `int` for counting things in the testbench.

---

### 5. `enum` — "Names instead of numbers"

An FSM has states like IDLE, BUSY, DONE. Inside hardware they are just numbers (0, 1, 2). `enum` lets you give those numbers names, so your code and logs are easy to read.

The first name gets 0, the next gets 1, and so on. `.name()` prints the name instead of the number.

```systemverilog
typedef enum {IDLE, BUSY, DONE} state_t;
state_t s = BUSY;
$display("s = %s, value = %0d", s.name(), s);   // s = BUSY, value = 1
```

👉 Use `enum` for FSM states and opcodes. Logs show `BUSY` instead of `1`.

---

### 6. `struct` — "One form with many fields"

A transaction on a bus has several parts, like an address and data. Instead of keeping two separate variables, a `struct` groups them into one, like a shipping label that keeps address and contents together.

`packed` means the fields are stored side by side as one long vector. So addr = AB and data = CD together become ABCD.

```systemverilog
typedef struct packed {
  bit [7:0] addr;
  bit [7:0] data;
} pkt_t;

pkt_t p;
p.addr = 8'hAB;
p.data = 8'hCD;
$display("p = %h", p);   // p = abcd
```

👉 Use `struct` to describe one transaction. In UVM, this idea becomes a sequence item class.

---

### 7. `string` — "Text for humans"

`string` stores text, like messages and test names. Its size grows automatically as you add text, and it has built-in functions like `.len()`.

```systemverilog
string msg = "Hello DV";
$display("%s, length = %0d", msg, msg.len());   // Hello DV, length = 8
```

👉 Use `string` for log messages, test names and error reports.

---

## 📋 Quick revision

| Type | States | Signed | Size | Starts as |
|---|:---:|:---:|:---:|:---:|
| logic | 4 | No | any | X |
| bit | 2 | No | any | 0 |
| byte | 2 | Yes | 8 | 0 |
| int | 2 | Yes | 32 | 0 |
| integer | 4 | Yes | 32 | X |

---

## 🎯 Interview questions

**Q: logic vs bit?**
logic is 4-state (starts X), bit is 2-state (starts 0). Use logic for DUT signals so X/Z bugs are visible.

**Q: int vs integer?**
Both 32-bit signed. int is 2-state, integer is 4-state.

**Q: What happens when X is assigned to a bit?**
It becomes 0, with no warning.

**Q: What is a packed struct?**
Fields stored side by side as one vector.

**Q: Default value of an enum variable?**
The first name in the list (value 0).

---
