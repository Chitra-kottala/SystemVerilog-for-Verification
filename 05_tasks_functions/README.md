# 05 · Tasks & Functions

> Subroutines let you write code once and reuse it. SystemVerilog has two kinds: **functions** (zero time) and **tasks** (can consume time).

---

## 📌 Function

**Definition (say this in interviews):**
> A function is a subroutine that executes in **zero simulation time** and can **return a value**. It cannot contain timing controls such as `#`, `@`, or `wait`.

**Key points**
- Returns a single value, or nothing if declared `void`
- Can be used inside an expression: `y = add(a, b);`
- Can call other functions, but cannot call a task directly
- Used for calculations, like computing expected values in a scoreboard

**Example**
```systemverilog
function int add(int a, int b);
  return a + b;
endfunction

$display("%0d", add(3, 4));   // 7
```

---

## 📌 void function

**Definition:**
> A void function is a function that **does not return a value**. It is called as a statement, not used in an expression.

**Example**
```systemverilog
function void print_pkt(int addr, int data);
  $display("addr=%0d data=%0d", addr, data);
endfunction
```

**Key point:** Used when you want the zero-time guarantee of a function but don't need a return value (printing, updating variables).

---

## 📌 Task

**Definition (say this in interviews):**
> A task is a subroutine that **can consume simulation time**. It can contain timing controls like `#`, `@(posedge clk)`, and `wait`. It does not return a value, but can pass results back through **output** or **ref** arguments.

**Key points**
- Called as a statement, not inside an expression
- Can call both functions and other tasks
- Used for anything that spans clock cycles, like a driver sending a transaction to the DUT

**Example**
```systemverilog
task wait_clocks(int n);
  repeat (n) @(posedge clk);
endtask
```

---

## 📌 Function vs Task

| | Function | Task |
|---|---|---|
| Simulation time | Zero time | Can consume time |
| Timing controls (`#`, `@`, `wait`) | ❌ Not allowed | ✅ Allowed |
| Return value | ✅ Yes (or `void`) | ❌ No (use `output`/`ref`) |
| Used in an expression | ✅ Yes | ❌ No |
| Can call a task | ❌ No (except `fork…join_none`) | ✅ Yes |
| Can call a function | ✅ Yes | ✅ Yes |
| Typical use | Calculations, checks | Driving signals, waiting for events |

---

## 📌 Calling a task from a function

**Definition:**
> A function cannot directly call a task because a task may consume time. However, a function **can start a task inside `fork…join_none`**, because `join_none` does not wait for the task to finish, so the function still completes in zero time.

```systemverilog
function void start_bg();
  fork
    wait_clocks(5);   // runs in the background
  join_none
endfunction
```

---

## 📌 Argument directions

**Definition:**
> Arguments can be `input`, `output`, `inout`, or `ref`. `input` passes a copy. `ref` passes the original variable.

| Direction | What happens to the caller's variable |
|---|---|
| `input` | Not changed (default) |
| `output` | Gets the value when the task ends |
| `inout` | Goes in, comes back changed when the task ends |
| `ref` | Changes immediately, while the task runs |
| `const ref` | Passed without copying, but can't be changed |

**Example**
```systemverilog
function automatic void increment(ref int x);
  x = x + 1;
endfunction

count = 5;
increment(count);   // count = 6
```

**Key points**
- `ref` needs `automatic`
- `inout` updates at the end, `ref` updates immediately
- `const ref` is used to pass big arrays without copying them

---

## 📌 Static vs Automatic

**Definition (say this in interviews):**
> In a **static** subroutine, all calls share the **same memory** for arguments and local variables. In an **automatic** subroutine, **each call gets its own copy**, allocated on a stack. Tasks and functions in modules are static by default; in classes they are automatic by default.

**Why it matters**
If two calls to a static task run at the same time (for example, in a `fork`), the second call overwrites the first call's variables.

```systemverilog
task static_wait(int n);          // shared n
  #n $display("n=%0d", n);
endtask

fork
  static_wait(10);
  static_wait(20);
join
// both calls can print n=20 ❌ — the second call overwrote n
```

With `task automatic`, each call keeps its own `n`, so they print 10 and 20 ✅

**Use automatic when**
- Using `ref` arguments
- Recursion (a function calling itself)
- The same task runs in parallel threads

---

## ▶️ Expected output

```
add(3,4) = 7
pkt: addr=10 data=99
waited 2 clocks, time=15
sum=13 diff=7
count after increment = 6
static:    n=20 ...
static:    n=20 ...
automatic: n=10 ...
automatic: n=20 ...
```

---

## 🎯 Interview questions

**Q: What is the difference between a task and a function?**
A function executes in zero time, cannot have timing controls, and can return a value. A task can consume time, can have timing controls, and returns results through output or ref arguments.

**Q: Can a function call a task?**
Not directly, because a task may consume time. It can start a task inside `fork…join_none`, since that doesn't wait.

**Q: Can a task call a function?**
Yes.

**Q: What is a void function?**
A function that returns no value. It's called as a statement.

**Q: What is the difference between `input` and `ref`?**
`input` passes a copy, so the caller's variable is not changed. `ref` passes the original variable, so any change is seen by the caller immediately.

**Q: Why use `const ref`?**
To pass large data like arrays efficiently without copying, while preventing the subroutine from changing it.

**Q: What is the difference between static and automatic?**
Static subroutines share one copy of variables across all calls. Automatic subroutines allocate new variables for each call.

**Q: When must you use automatic?**
When using `ref` arguments, recursion, or calling the same task from parallel threads.

**Q: What is the default lifetime of tasks in a module vs a class?**
Static in a module. Automatic in a class.

**Q: Where are tasks used in a UVM testbench?**
In the driver and monitor, to drive and sample signals over clock cycles, like `run_phase`.

---

## ▶️ Run it
Paste [`tasks_functions.sv`](tasks_functions.sv) into [EDA Playground](https://www.edaplayground.com) → Synopsys VCS → Run
