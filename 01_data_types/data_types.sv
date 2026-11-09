// 01 - SystemVerilog Data Types
// Shows 2-state vs 4-state types, signed/unsigned, enum, struct, string

module data_types_tb;

  // 4-state (0,1,X,Z) vs 2-state (0,1) types
  logic       l4;          // 4-state: starts as X
  bit         b2;          // 2-state: starts as 0

  // Signed vs unsigned
  byte        sb = 8'hFF;  // byte is signed  -> -1
  bit [7:0]   ub = 8'hFF;  // bit vector is unsigned -> 255
  int         count = 10;  // 32-bit signed, 2-state

  // Enum: named states (used in FSMs)
  typedef enum {IDLE, BUSY, DONE} state_t;
  state_t state;

  // Packed struct: group related fields (like a transaction)
  typedef struct packed {
    logic [7:0]  addr;
    logic [31:0] data;
  } packet_t;
  packet_t pkt;

  string msg = "Hello DV";

  initial begin
    $display("--- 2-state vs 4-state ---");
    $display("logic default = %b (X = unknown)", l4);
    $display("bit   default = %b (2-state, no X)", b2);
    l4 = 1'bz;  b2 = 1'bz;
    $display("logic = z -> %b, bit = z -> %b", l4, b2);

    $display("--- signed vs unsigned ---");
    $display("byte 8'hFF  = %0d", sb);
    $display("bit[7:0] FF = %0d", ub);
    $display("int count   = %0d", count);

    $display("--- enum ---");
    state = BUSY;
    $display("state = %s (value %0d)", state.name(), state);

    $display("--- struct ---");
    pkt.addr = 8'h10;
    pkt.data = 32'hDEAD_BEEF;
    $display("addr = %h, data = %h", pkt.addr, pkt.data);

    $display("--- string ---");
    $display("%s, length = %0d", msg, msg.len());
  end

endmodule
