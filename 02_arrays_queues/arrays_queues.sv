// 02 - Arrays and Queues
// Fixed array, dynamic array, associative array, queue, array methods

module arrays_queues_tb;

  int fixed_arr[4];      // fixed size: always 4 elements
  int dyn[];             // dynamic: size set at run time
  int assoc[int];        // associative: only stores the keys you use
  int q[$];              // queue: add/remove at front or back
  int found[$];          // queue to hold search results

  initial begin
    // ---------- Fixed array ----------
    fixed_arr = '{10, 20, 30, 40};
    $display("fixed_arr = %p, size = %0d", fixed_arr, $size(fixed_arr));

    // ---------- Dynamic array ----------
    dyn = new[3];
    dyn = '{1, 2, 3};
    $display("dyn = %p, size = %0d", dyn, dyn.size());
    dyn = new[5](dyn);                 // grow to 5, keep old values
    $display("dyn resized = %p", dyn);
    dyn.delete();
    $display("dyn after delete, size = %0d", dyn.size());

    // ---------- Associative array ----------
    assoc[5]    = 50;
    assoc[1000] = 99;
    $display("assoc = %p, entries = %0d", assoc, assoc.num());
    if (assoc.exists(5)) $display("key 5 exists");

    // ---------- Queue ----------
    q = '{1, 2, 3};
    q.push_back(4);
    q.push_front(0);
    $display("q = %p", q);
    $display("pop_front = %0d", q.pop_front());
    $display("pop_back  = %0d", q.pop_back());
    $display("q = %p, size = %0d", q, q.size());

    // ---------- Array methods ----------
    $display("sum of fixed_arr = %0d", fixed_arr.sum());
    found = fixed_arr.find with (item > 15);
    $display("items > 15 = %p", found);
  end

endmodule
