// 04 - Operators
// ==, ===, ==?, &, &&, reduction, inside, unique/priority case, streaming

module operators_tb;

  logic [3:0] a, b;
  logic [1:0] sel;
  logic [7:0] x, y;

  initial begin
    // ---------- == vs === ----------
    a = 4'b10x1;  b = 4'b10x1;
    $display("a == b   -> %b", a == b);
    $display("a === b  -> %b", a === b);

    // ---------- ==? (wildcard) ----------
    a = 4'b1011;
    $display("a ==? 10xx -> %b", a ==? 4'b10xx);

    // ---------- & vs && ----------
    a = 4'b1010;  b = 4'b1100;
    $display("a & b  = %b", a & b);
    $display("a && b = %b", a && b);

    // ---------- reduction ----------
    $display("&a=%b  |a=%b  ^a=%b", &a, |a, ^a);

    // ---------- inside ----------
    a = 5;
    if (a inside {[1:6], 9}) $display("a=%0d is inside the list", a);

    // ---------- unique case ----------
    sel = 2'b01;
    unique case (sel)
      2'b00: $display("unique case: sel=00 -> A");
      2'b01: $display("unique case: sel=01 -> B");
      2'b10: $display("unique case: sel=10 -> C");
    endcase

    // ---------- priority case ----------
    sel = 2'b11;
    priority casez (sel)
      2'b1?: $display("priority case: first match -> top bit is 1");
      2'b?1: $display("priority case: second match (never reached here)");
    endcase

    // ---------- streaming ----------
    x = 8'b1100_0001;
    y = {<<{x}};
    $display("x = %b, reversed = %b", x, y);
  end

endmodule
