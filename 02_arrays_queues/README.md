# 02 · Arrays & Queues

## 🧭 Big picture

**Ask one question: how many items, and how do I add or remove them?**

| If... | Use |
|---|---|
| Size never changes | Fixed array |
| Size decided while test runs | Dynamic array |
| Huge range, only a few used | Associative array |
| Add/remove at the ends, in order | Queue |

---

## 1. Fixed array

**Think of it as:** A shelf with a fixed number of boxes.

**Definition:** An array whose size is set in the code and never changes.

```systemverilog
int a[4];
a = '{10, 20, 30, 40};
```

**Output:** `a = '{10, 20, 30, 40}`

**Remember:** Fixed size. Use for register banks.

---

## 2. Dynamic array

**Think of it as:** A shelf you build while the test runs.

**Definition:** An array whose size is set at run time using `new[]`.

```systemverilog
int d[];
d = new[3];        // size 3
d = new[5](d);     // size 5, old values kept
d.delete();        // size 0
```

**Output:** `'{1, 2, 3}` → `'{1, 2, 3, 0, 0}` → empty

**Remember:** Needs `new[]`. Use for packets with random length.

---

## 3. Associative array

**Think of it as:** A dictionary. Only stores the words you use.

**Definition:** An array that stores only the indexes you write to.

```systemverilog
int m[int];
m[5]    = 50;
m[1000] = 99;
```

**Output:** `entries = 2`

**Remember:** Saves memory. Use for memory models.

---

## 4. Queue

**Think of it as:** A line at a ticket counter.

**Definition:** An array that grows and shrinks automatically. Add or remove at the front or back.

```systemverilog
int q[$];
q = '{1, 2, 3};
q.push_back(4);    // '{1, 2, 3, 4}
q.push_front(0);   // '{0, 1, 2, 3, 4}
q.pop_front();     // removes 0
q.pop_back();      // removes 4
```

**Output:** `q = '{1, 2, 3}`

**Remember:** No `new[]` needed. Use in scoreboards.

---

## 5. Array methods

**Think of it as:** Built-in shortcuts, so you don't write loops.

| Method | Does |
|---|---|
| `size()` | Count items |
| `sum()` | Add all items |
| `sort()` | Sort small to big |
| `find with (item > 15)` | Get items that match |

**Remember:** `item` means "the current element".

---

## 📋 Quick revision

| Type | Declare | Remember |
|---|---|---|
| Fixed | `int a[4];` | fixed size |
| Dynamic | `int d[];` | needs `new[]` |
| Associative | `int m[int];` | only stores used indexes |
| Queue | `int q[$];` | push and pop |

---

## 🎯 Interview questions

**Q: Dynamic array vs queue?**
Dynamic needs `new[]` to resize. Queue grows by itself.

**Q: When to use associative array?**
Huge range, few used, like a memory model.

**Q: Which one is used in a scoreboard?**
Queue, because items go in and come out in order.

**Q: How to check if a key exists?**
`m.exists(key)`
