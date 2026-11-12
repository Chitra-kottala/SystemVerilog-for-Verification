// 03 - Procedural Blocks
// initial, always_comb, always_ff, blocking vs non-blocking

module procedural_blocks_tb;

  logic clk = 0;
  logic a, b, y;       // for always_comb
  logic d, q;          // for always_ff
  int   x1, x2;        // for blocking
  int   y1, y2;        // for non-blocking

  // Clock: flips every 5 time units
  always #5 clk = ~clk;

  // Combinational logic: AND gate
  always_comb y = a & b;

  // Sequential logic: flip-flop
  always_ff @(posedge clk) q <= d;

  initial begin
    // ---------- always_comb ----------
    a = 1; b = 0; #1;
    $display("always_comb: a=%b b=%b y=%b", a, b, y);
    b = 1; #1;
    $display("always_comb: a=%b b=%b y=%b", a, b, y);

    // ---------- always_ff ----------
    d = 1;
    $display("always_ff before clock: d=%b q=%b", d, q);
    @(posedge clk); #1;
    $display("always_ff after clock:  d=%b q=%b", d, q);

    // ---------- blocking ----------
    x1 = 1; x2 = 2;
    x1 = x2;  x2 = x1;
    $display("blocking:     x1=%0d x2=%0d", x1, x2);

    // ---------- non-blocking ----------
    y1 = 1; y2 = 2;
    y1 <= y2;  y2 <= y1;
    #1 $display("non-blocking: y1=%0d y2=%0d", y1, y2);

    $finish;
  end

endmodule
