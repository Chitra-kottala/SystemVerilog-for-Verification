// 05 - Tasks and Functions
// function, void function, task, input/output/ref, static vs automatic

module tasks_functions_tb;

  logic clk = 0;
  always #5 clk = ~clk;

  // Function: returns a value, zero time
  function int add(int a, int b);
    return a + b;
  endfunction

  // Void function: does something, returns nothing
  function void print_pkt(int addr, int data);
    $display("pkt: addr=%0d data=%0d", addr, data);
  endfunction

  // Task: can wait for clocks
  task wait_clocks(int n);
    repeat (n) @(posedge clk);
    $display("waited %0d clocks, time=%0t", n, $time);
  endtask

  // Task with output arguments
  task get_sum_diff(input int a, b, output int sum, diff);
    sum  = a + b;
    diff = a - b;
  endtask

  // ref: changes the caller's variable
  function automatic void increment(ref int x);
    x = x + 1;
  endfunction

  // Static task: one shared variable
  task static_wait(int n);
    #n $display("static:    n=%0d at time %0t", n, $time);
  endtask

  // Automatic task: each call has its own variable
  task automatic auto_wait(int n);
    #n $display("automatic: n=%0d at time %0t", n, $time);
  endtask

  initial begin
    int s, d, count;

    // ---------- function ----------
    $display("add(3,4) = %0d", add(3, 4));
    print_pkt(10, 99);

    // ---------- task ----------
    wait_clocks(2);

    // ---------- output ----------
    get_sum_diff(10, 3, s, d);
    $display("sum=%0d diff=%0d", s, d);

    // ---------- ref ----------
    count = 5;
    increment(count);
    $display("count after increment = %0d", count);

    // ---------- static vs automatic ----------
    fork
      static_wait(10);
      static_wait(20);
    join
    fork
      auto_wait(10);
      auto_wait(20);
    join

    $finish;
  end

endmodule
