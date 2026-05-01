
// Interface
// Includes:
//   - Clocking block 
//   - Modport for DUT (no clocking block)
//   - Modport for testbench (uses clocking block)
//   - Checker: prevents simultaneous read and write

interface mem_if (input logic clk);

  logic        write;
  logic        read;
  logic [7:0]  data_in;
  logic [15:0] address;
  logic [8:0]  data_out;


  clocking cb @(posedge clk);
    default input  #1step   // sample just before posedge
            output #1;      // drive 1 time-unit after posedge

    output write;
    output read;
    output data_in;
    output address;
    input  data_out;
  endclocking : cb


  modport dut_mp (
    input  clk,
    input  write,
    input  read,
    input  data_in,
    input  address,
    output data_out
  );

  modport tb_mp (
    clocking cb,
    input    clk       
  );

  // Checker
  // Flags an error if both are high simultaneously.
  property check_rw;
    @(posedge clk) not (write && read);
  endproperty

  assert_no_sim_rw : assert property (check_rw)
    else $error("[CHECKER] Time=%0t | ILLEGAL: read and write asserted simultaneously! (addr=0x%04h)",
                $time, address);

endinterface : mem_if
