
// Top-level module:
//   - Generates a 10 MHz clock  (period = 100 ns)
//   - Instantiates the interface
//   - Instantiates the DUT  (my_mem) connected via dut_mp modport
//   - Instantiates the test program (mem_test) connected via tb_mp modport

`timescale 1ns/1ps

module top;
initial begin
  $fsdbDumpfile("waves.fsdb"); 
  $fsdbDumpvars(0, top);      
end
  logic clk;
  initial clk = 1'b0;
  always #50 clk = ~clk;    // toggle every 50 ns -> 100 ns period = 10 MHz


  mem_if dut_if (.clk(clk));

  my_mem dut ( .mif (dut_if.dut_mp) );

  mem_test test_prog (.tb (dut_if.tb_mp) );

endmodule : top
