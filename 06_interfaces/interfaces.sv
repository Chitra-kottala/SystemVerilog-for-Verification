// 06 - Interfaces
// interface, modport, clocking block

// ---------- Interface: bundle of signals ----------
interface bus_if(input logic clk);
  logic [7:0] data;
  logic       valid;

  // Clocking block: TB drives 1 unit after edge, samples 1 unit before
  clocking cb @(posedge clk);
    default input #1 output #1;
    output data, valid;
  endclocking

  // Modports: direction from each side's view
  modport DUT (input clk, data, valid);
  modport TB  (clocking cb);
endinterface

// ---------- DUT: uses the DUT modport ----------
module dut(bus_if.DUT bus);
  always @(posedge bus.clk)
    if (bus.valid) $display("[%0t] DUT got data = %0d", $time, bus.data);
endmodule

// ---------- Top: creates interface, connects DUT, runs test ----------
module tb;
  logic clk = 0;
  always #5 clk = ~clk;

  bus_if bif(clk);          // create the interface
  dut    u_dut(.bus(bif));  // connect DUT in one line

  initial begin
    @(bif.cb);              // edge at time 5
    bif.cb.data  <= 42;     // driven at time 6
    bif.cb.valid <= 1;
    @(bif.cb);              // edge at time 15 → DUT samples 42
    bif.cb.valid <= 0;
    #20 $finish;
  end
endmodule
