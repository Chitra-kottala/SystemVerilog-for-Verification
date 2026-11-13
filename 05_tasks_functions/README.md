# 05 · Tasks & Functions

## 🧭 Big picture

When you write the same lines again and again, put them in one place and **call** them by name, like a recipe you reuse.

| | Function | Task |
|---|---|---|
| **Think of it as** | A calculator: instant answer | A chore: can take time |
| **Can wait (`#`, `@posedge`)?** | ❌ No | ✅ Yes |
| **Returns a value?** | ✅ Yes (or `void`) | ❌ No (uses `output`) |
| **Used for** | Calculating expected values | Driving signals to the DUT |

---

## 1. Function

**Think of it as:** A calculator.

**Definition:** Finishes in zero time. Returns a value. Cannot use `#` or `@`.

```systemverilog
function int add(int a, int b);
  return a + b;
endfunction

add(3, 4)    // 7
```

**Remember:** Zero time. No waiting.

---

## 2. void function

**Think of it as:** A function with no answer to give back.

**Definition:** A function that does something but returns nothing.

```systemverilog
function void print_pkt(int addr, int data);
  $display("pkt: addr=%0d data=%0d", addr, data);
endfunction
```

**Remember:** `void` = returns nothing.

---

## 3. Task

**Think of it as:** A chore that takes time.

**Definition:** Can wait for time or clocks. Does not return a value, but can send results back through `output`.

```systemverilog
task wait_clocks(int n);
  repeat (n) @(posedge clk);
endtask
```

**Remember:** Use a task when you need to wait, like a driver sending data to the DUT one clock at a time.

---

## 4. Who can call whom?

| Caller | Can call a function? | Can call a task? |
|---|:---:|:---:|
| Task | ✅ | ✅ |
| Function | ✅ | ❌ (only inside `fork ... join_none`) |

**Why:** A function must finish in zero time. A task might wait.
`fork ... join_none` starts the task in the background and doesn't wait for it, so the function still finishes in zero time.

```systemverilog
function void start_driver();
  fork
    wait_clocks(5);    // runs in the background
  join_none
endfunction
```

---

## 5. Argument directions

| Direction | Think of it as | Meaning |
|---|---|---|
| `input` | A photocopy | Value goes in. Your original is safe. Default. |
| `output` | A result handed back | Value comes out when it finishes |
| `ref` | The original | Changes inside also change your variable |

```systemverilog
task get_sum_diff(input int a, b, output int sum, diff);
  sum  = a + b;
  diff = a - b;
endtask

function automatic void increment(ref int x);
  x = x + 1;
endfunction

count = 5;
increment(count);    // count is now 6
```

**Remember:** Without `ref`, your original is safe. With `ref`, your original changes.

---

## 6. Static vs automatic

**Think of it as:**
- **Static** → one shared whiteboard. Everyone writes on the same one.
- **Automatic** → each call gets its own sheet of paper.

**Definition:**
- **Static** (default in modules): all calls share the same variables.
- **Automatic**: every call gets its own fresh variables.

```systemverilog
task static_wait(int n);            // shared n
  #n $display("n=%0d", n);
endtask

fork
  static_wait(10);
  static_wait(20);
join
// both print n=20 ❌ (second call overwrote n)
```

With `task automatic`, they print 10 and 20 ✅

**Use automatic when:**
- You use `ref`
- The function calls itself (recursion)
- Calls run at the same time (`fork`)

**Remember:** Inside classes, everything is automatic by default.

---

## ▶️ Expected output

```
add(3,4) = 7
pkt: addr=10 data=99
waited 2 clocks, time=15
sum=13 diff=7
count after increment = 6
static:    n=20 at time 25
static:    n=20 at time 35
automatic: n=10 at time 45
automatic: n=20 at time 55
```

(Exact times depend on when each fork starts. Look at the **n** values: static prints 20 twice, automatic prints 10 and 20.)

---

## 📋 Quick revision

| | Function | Task |
|---|:---:|:---:|
| Takes time? | No | Yes |
| Returns value? | Yes / void | No (`output`) |
| Can call a task? | Only in `fork join_none` | Yes |

| Direction | Meaning |
|---|---|
| `input` | photocopy |
| `output` | result back |
| `ref` | original |

---

## 🎯 Interview questions

**Q: Task vs function?**
A function finishes in zero time and returns a value. A task can take time and returns results through output arguments.

**Q: Can a function call a task?**
Not directly, because a task may take time. It can start one inside `fork ... join_none`.

**Q: What is `ref`?**
It passes the original variable, so changes inside the function also change the caller's variable. Needs `automatic`.

**Q: Static vs automatic?**
Static shares variables across all calls. Automatic gives each call its own variables.

**Q: When do you need automatic?**
With `ref`, recursion, or calls running in parallel.

**Q: What does void mean?**
The function returns nothing.

---

## ▶️ Run it
Paste [`tasks_functions.sv`](tasks_functions.sv) into [EDA Playground](https://www.edaplayground.com) → Synopsys VCS → Run
