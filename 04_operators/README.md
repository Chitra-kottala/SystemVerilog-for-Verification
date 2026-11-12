# 04 · Operators

## 🧭 Big picture

Operators are how you **compare and check** values. In verification you do this all the time: did the DUT output match what I expected?

The tricky part is **X**. Some operators handle it, some don't.

---

## 🤔 Which one should I use?

| If you want to... | Use |
|---|---|
| Compare in a testbench check | `===` |
| Match a pattern, ignoring some bits | `==?` |
| AND bits together | `&` |
| Check a condition in `if` | `&&` |
| Check all bits / any bit of a vector | `&a` / `\|a` |
| Check if a value is in a list | `inside` |
| Only one case should ever match | `unique case` |
| First match wins | `priority case` |
| Reverse or pack bits | `{<<{x}}` |

---

## 1. `==` vs `===`

**Think of it as:**
- `==` → "I see an X, so I don't know"
- `===` → "compare exactly, X must match X"

**Definition:** `==` returns X if either side has X or Z. `===` compares X and Z too, and always returns 0 or 1.

```systemverilog
a = 4'b10x1;  b = 4'b10x1;
a == b     // x
a === b    // 1
```

**Remember:** Use `===` in testbench checks, so X never slips through.

---

## 2. `==?` (wildcard equality)

**Think of it as:** Pattern matching. X on the right means "don't care".

**Definition:** Compares only the bits that are not X or Z on the right-hand side.

```systemverilog
a = 4'b1011;
a ==? 4'b10xx    // 1 → only the top two bits are checked
```

**Remember:** `===` matches exactly. `==?` ignores X bits on the right.

---

## 3. `&` vs `&&`

**Think of it as:**
- `&` → AND each pair of bits, gives back a vector
- `&&` → is the whole thing true (non-zero)? Gives 1 or 0

**Definition:** `&` is bitwise. `&&` is logical.

```systemverilog
a = 4'b1010;  b = 4'b1100;
a & b      // 1000
a && b     // 1  (both non-zero)
```

**Remember:** `&` for bits. `&&` for conditions in `if`.

---

## 4. Reduction operators

**Think of it as:** Squash a whole vector into one bit.

**Definition:** Put the operator in front of **one** vector. It combines all its bits.

```systemverilog
a = 4'b1010;
&a     // 0 → are ALL bits 1?
|a     // 1 → is ANY bit 1?
^a     // 0 → XOR of all bits (parity)
```

**Remember:** `|bus == 0` checks if a bus is all zeros. `^data` gives parity.

---

## 5. `inside`

**Think of it as:** "Is it in this list?"

**Definition:** Returns 1 if the value matches any item or range in the list.

```systemverilog
a = 5;
a inside {[1:6], 9}    // 1 → 5 is between 1 and 6
```

**Remember:** Cleaner than `(a >= 1 && a <= 6) || a == 9`. Used a lot in constraints.

---

## 6. `unique case` and `priority case`

**Think of it as:** A promise you make about your `case`, and the simulator checks it.

| Keyword | You promise | Simulator warns if... |
|---|---|---|
| `unique` | Exactly one item matches, no overlap | none match, or more than one matches |
| `priority` | Check in order, first match wins | none match |

```systemverilog
unique case (sel)
  2'b00: y = a;
  2'b01: y = b;
  2'b10: y = c;
endcase        // sel = 11 → warning: no item matched

priority casez (sel)
  2'b1?: y = a;   // sel = 11 → this one wins
  2'b?1: y = b;
endcase
```

**Remember:** These catch bugs where a value nobody planned for shows up.

---

## 7. Streaming operators `{>>{}}` and `{<<{}}`

**Think of it as:** Pouring bits out in a line.
- `>>` → left to right, order stays the same
- `<<` → right to left, order is **reversed**

**Definition:** Packs or unpacks bits as one stream.

```systemverilog
x = 8'b1100_0001;
y = {<<{x}};      // 1000_0011 → bits reversed
```

**Remember:** Used to reverse bits, or to pack a transaction into a bit stream for a bus.

---

## ▶️ Expected output

```
a == b   -> x
a === b  -> 1
a ==? 10xx -> 1
a & b  = 1000
a && b = 1
&a=0  |a=1  ^a=0
a=5 is inside the list
unique case: sel=01 -> B
priority case: first match -> top bit is 1
x = 11000001, reversed = 10000011
```

---

## 📋 Quick revision

| Operator | Means | Example result |
|---|---|---|
| `==` | equal, X gives X | `10x1 == 10x1` → x |
| `===` | exactly equal | `10x1 === 10x1` → 1 |
| `==?` | equal, X on right = don't care | `1011 ==? 10xx` → 1 |
| `&` | bitwise AND | `1010 & 1100` → 1000 |
| `&&` | logical AND | `1010 && 1100` → 1 |
| `&a` / `\|a` / `^a` | all / any / parity | `1010` → 0 / 1 / 0 |
| `inside` | in the list? | `5 inside {[1:6]}` → 1 |
| `{<<{x}}` | reverse bits | `11000001` → `10000011` |

---

## 🎯 Interview questions

**Q: `==` vs `===`?**
`==` gives X if there's an X or Z. `===` compares X and Z exactly and always gives 0 or 1.

**Q: `===` vs `==?`?**
`===` matches every bit exactly. `==?` treats X and Z on the right as don't care.

**Q: `&` vs `&&`?**
`&` ANDs each bit. `&&` checks if both sides are true and gives 1 or 0.

**Q: What is a reduction operator?**
An operator on one vector that combines all its bits into one bit, like `&a` or `|a`.

**Q: unique vs priority case?**
unique means exactly one match and no overlap. priority means first match wins. Both warn if nothing matches.

**Q: How do you reverse the bits of a vector?**
`y = {<<{x}};`

---

## ▶️ Run it
Paste [`operators.sv`](operators.sv) into [EDA Playground](https://www.edaplayground.com) → Synopsys VCS → Run
