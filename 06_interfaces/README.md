# 06 · Interfaces

> An interface bundles DUT signals into one connection. It holds three things: **signals**, **modports**, and a **clocking block**.

---

<img width="1346" height="1126" alt="image" src="https://github.com/user-attachments/assets/00da8e7f-b704-4830-be51-2b9322b9ef2f" />


## 📌 Interface

**Definition (say this in interviews):**
> An interface is a construct that **bundles related signals** into one unit, so they can be passed between the DUT and testbench as a single connection.

```systemverilog
interface bus_if(input logic clk);
  logic [7:0] data;
  logic       valid;
endinterface

bus_if bif(clk);          // create
dut u_dut(.bus(bif));     // connect in one line
```

**Why:** Add or change a signal in one place, not in every file.

---

## 📌 Modport

**Definition:**
> A modport defines the **direction of each signal** from one side's point of view.

```systemverilog
modport DUT (input clk, data, valid);
modport TB  (clocking cb);
```

**Why:** Stops a side from driving a signal it shouldn't. The tool gives an error.

---

## 📌 Clocking block

**Definition (say this in interviews):**
> A clocking block groups signals synchronous to a clock and defines **when the testbench samples and drives them** using input and output skew. It **avoids race conditions** between the testbench and the DUT.

```systemverilog
clocking cb @(posedge clk);
  default input #1 output #1;
  output data, valid;
endclocking
```

### Why is there a race?
At the clock edge, the **DUT samples** and the **TB drives** at the same instant. The simulator's order isn't fixed, so the DUT may see the old or the new value.

### How skew fixes it
```
 time:    9          10          11
       TB READS    CLOCK EDGE   TB WRITES
     (input skew)  DUT works   (output skew)
       edge − 1                 edge + 1
```

| Who | Does what | When |
|---|---|---|
| Driver | drives inputs through `cb` | edge **+ 1** |
| DUT | samples inputs, updates outputs | **at** the edge |
| Monitor | samples outputs through `cb` | edge **− 1** |

**Key points**
- Only the **TB** uses the clocking block. The DUT never does.
- The DUT is real hardware with `always_ff` + `<=`, so it's already race-free.
- Drive through `cb` with `<=`: `bif.cb.data <= 42;`

---

## 📌 Virtual interface

**Definition:**
> A virtual interface is a **handle to a real interface**, so classes like the driver and monitor can access DUT signals.

```systemverilog
virtual bus_if vif;
vif.cb.data <= 42;
```

**Why:** Classes can't contain an interface directly, only a handle to one.

---

## ▶️ Expected output

```
[15] DUT got data = 42
```

**Why 15, not 5?** The TB drives at time 6 (edge 5 + 1). The DUT samples at the **next** edge, 15.

---

## 🎯 Interview questions

**Q: What is an interface and why use it?**
A bundle of signals passed as one connection. Changing a signal is done in one place.

**Q: What does an interface contain?**
Signals, modports, and clocking blocks. It can also hold tasks, functions and assertions.

**Q: What is a modport?**
It defines signal directions from each side's view, like DUT vs TB.

**Q: What is a clocking block and why use it?**
It defines when the TB samples and drives signals relative to the clock edge using skews. It prevents race conditions.

**Q: What is input skew vs output skew?**
Input skew: TB samples before the edge. Output skew: TB drives after the edge.

**Q: Does the DUT use the clocking block?**
No. Only the testbench does. The DUT connects through its modport.

**Q: What is a virtual interface?**
A handle to a real interface, so classes can access DUT signals.

---

## ▶️ Run it
Paste [`interfaces.sv`](interfaces.sv) into [EDA Playground](https://www.edaplayground.com) → Synopsys VCS → Run
