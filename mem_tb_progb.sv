
// Test Program block – generates stimulus, drives DUT through clocking block,
// monitors outputs, and checks results.
//
// Four tasks communicate through queues
//   1. gen_transactions  – creates Transaction objects, pushes to drv_queue
//   2. drive_transactions – pops from drv_queue, drives CB, pushes copy to chk_queue
//   3. collect_output    – pops from chk_queue (after read), samples data_out,
//                          pushes to mon_queue
//   4. check_results     – pops from mon_queue, calls Transaction::check_data


`include "mem_pkg.sv"

program mem_test
  import mem_pkg::*;
  (mem_if.tb_mp tb);      


  Transaction drv_queue [$];    // generator  -> driver
  Transaction chk_queue [$];    // driver     -> collector  (write transactions carry expected data)
  Transaction mon_queue [$];    // collector  -> checker

  // Number of write/read test pairs to run
  parameter int NUM_TRANSACTIONS = 20;

  // Task 1 – gen_transactions
  // Creates NUM_TRANSACTIONS Transaction objects with random address / data_in.
  // Computes expected_data (parity + data) and pushes into drv_queue.

  task gen_transactions();
    Transaction t;
    $display("\n[GEN] ===== Starting transaction generation =====");
    repeat (NUM_TRANSACTIONS) begin
      t = new();                          // constructor randomizes addr & data_in
      // Pre-compute expected read-back value (even parity in bit [8])
      t.expected_data = {^t.data_in, t.data_in};
      $display("[GEN]  Time=%0t | addr=0x%04h  data_in=0x%02h  expected=0b%09b",
               $time, t.address, t.data_in, t.expected_data);
      drv_queue.push_back(t);
    end
    $display("[GEN] ===== Generation complete: %0d transactions =====\n", NUM_TRANSACTIONS);
  endtask : gen_transactions

  // Task 2 – drive_transactions
  // Pops each transaction from drv_queue.
  //   a) Issues a WRITE cycle through the clocking block.
  //   b) Issues a READ  cycle through the clocking block.
  //   c) Pushes a deep copy (with expected_data) to chk_queue for the monitor.
  // All driving / observing is done exclusively through tb.cb (clocking block).

  task drive_transactions();
    Transaction t, t_copy;
    $display("[DRV] ===== Starting drive task =====");

    while (drv_queue.size() > 0) begin
      t = drv_queue.pop_front();

      // ---- WRITE cycle ----
      @(tb.cb);                           // align to next posedge clk
      tb.cb.write   <= 1'b1;
      tb.cb.read    <= 1'b0;
      tb.cb.address <= t.address;
      tb.cb.data_in <= t.data_in;
      $display("[DRV]  WRITE: Time=%0t | addr=0x%04h  data_in=0x%02h",
               $time, t.address, t.data_in);

      @(tb.cb);                           // deassert after one clock
      tb.cb.write   <= 1'b0;
      tb.cb.read    <= 1'b0;

      // ---- READ cycle ----
      @(tb.cb);
      tb.cb.read    <= 1'b1;
      tb.cb.write   <= 1'b0;
      tb.cb.address <= t.address;
      $display("[DRV]  READ:  Time=%0t | addr=0x%04h", $time, t.address);

      // Push copy to chk_queue BEFORE releasing read
      t_copy = t.deep_copy();
      chk_queue.push_back(t_copy);

      @(tb.cb);                           // hold read for one clock (DUT latches on posedge)
      tb.cb.read    <= 1'b0;
    end

    $display("[DRV] ===== Drive task complete =====\n");
  endtask : drive_transactions

  // Task 3 – collect_output
  // Pops each entry from chk_queue; waits one extra cycle so data_out is valid,
  // then samples it through the clocking block and pushes to mon_queue.

  task collect_output();
    Transaction t;
    $display("[MON] ===== Starting monitor task =====");

    // Wait until driver has populated the queue for the first time
    wait (chk_queue.size() > 0);

    while (chk_queue.size() > 0 || drv_queue.size() > 0) begin
      // Wait for something to appear if queue is momentarily empty
      if (chk_queue.size() == 0) begin
        @(tb.cb);
        continue;
      end

      t = chk_queue.pop_front();

      // data_out is registered on posedge clk; the READ was driven one cycle ago.
      // The clocking block input samples at #1step before the next posedge, so
      // waiting one cb cycle here gives us valid data.
      @(tb.cb);
      @(tb.cb);
      t.data_out = tb.cb.data_out;        // sample through clocking block

      $display("[MON]  Time=%0t | addr=0x%04h  data_out=0b%09b",
               $time, t.address, t.data_out);
      t.print_data_out();

      mon_queue.push_back(t);
    end

    $display("[MON] ===== Monitor task complete =====\n");
  endtask : collect_output

  // Task 4 – check_results
  // Pops each entry from mon_queue and calls the Transaction check method. 
  // Prints a final summary using the static print_error function.

  task check_results();
    Transaction t;
    $display("[CHK] ===== Starting checker task =====");

    // Wait for monitor to produce results
    wait (mon_queue.size() > 0);

    // Process all entries; loop until monitor is also done
    while (mon_queue.size() > 0 || chk_queue.size() > 0 || drv_queue.size() > 0) begin
      if (mon_queue.size() == 0) begin
        @(tb.cb);
        continue;
      end
      t = mon_queue.pop_front();
      t.check_data();
    end

    // Drain any remaining entries after all tasks are done
    while (mon_queue.size() > 0) begin
      t = mon_queue.pop_front();
      t.check_data();
    end

    $display("[CHK] ===== Checker task complete =====");
    Transaction::print_error();           // static function call
  endtask : check_results

  // Main program flow
  // Run all four tasks in parallel using fork…join

  initial begin
    // Initialise interface signals through CB before clock starts toggling
    tb.cb.write   <= 1'b0;
    tb.cb.read    <= 1'b0;
    tb.cb.address <= 16'h0000;
    tb.cb.data_in <= 8'h00;

    // Wait a couple of clocks for reset settling
    repeat (2) @(tb.cb);

    // ----- Run all four tasks in parallel -----
    fork
      gen_transactions();
      drive_transactions();
      collect_output();
      check_results();
    join

    // Allow final signals to propagate
    repeat (4) @(tb.cb);

    // ---- Additional directed tests ----
    $display("\n[TEST] ===== Running additional directed / corner-case tests =====");

    // Test: Write 0x00 (all zeros, parity = 0)
    @(tb.cb);
    tb.cb.write <= 1'b1; tb.cb.read <= 1'b0;
    tb.cb.address <= 16'hFFFF; tb.cb.data_in <= 8'h00;
    @(tb.cb); tb.cb.write <= 1'b0;

    @(tb.cb);
    tb.cb.read <= 1'b1; tb.cb.write <= 1'b0;
    tb.cb.address <= 16'hFFFF;
    @(tb.cb); tb.cb.read <= 1'b0;
    @(tb.cb);
    $display("[TEST] addr=0xFFFF data=0x00 expected=0b000000000 got=0b%09b  %s",
             tb.cb.data_out,
             (tb.cb.data_out === 9'b000000000) ? "PASS" : "FAIL");

    // Test: Write 0xFF (all ones, parity = 0 ? even)
    @(tb.cb);
    tb.cb.write <= 1'b1; tb.cb.read <= 1'b0;
    tb.cb.address <= 16'h0001; tb.cb.data_in <= 8'hFF;
    @(tb.cb); tb.cb.write <= 1'b0;

    @(tb.cb);
    tb.cb.read <= 1'b1; tb.cb.write <= 1'b0;
    tb.cb.address <= 16'h0001;
    @(tb.cb); tb.cb.read <= 1'b0;
    @(tb.cb);
    $display("[TEST] addr=0x0001 data=0xFF expected=0b011111111 got=0b%09b  %s",
             tb.cb.data_out,
             (tb.cb.data_out === 9'b011111111) ? "PASS" : "FAIL");

    // Test: Write 0x01 (one '1' bit, parity = 1)
    @(tb.cb);
    tb.cb.write <= 1'b1; tb.cb.read <= 1'b0;
    tb.cb.address <= 16'h0002; tb.cb.data_in <= 8'h01;
    @(tb.cb); tb.cb.write <= 1'b0;

    @(tb.cb);
    tb.cb.read <= 1'b1; tb.cb.write <= 1'b0;
    tb.cb.address <= 16'h0002;
    @(tb.cb); tb.cb.read <= 1'b0;
    @(tb.cb);
    $display("[TEST] addr=0x0002 data=0x01 expected=0b100000001 got=0b%09b  %s",
             tb.cb.data_out,
             (tb.cb.data_out === 9'b100000001) ? "PASS" : "FAIL");

    $display("\n[SIM] ===== Simulation complete =====");
    Transaction::print_error();
    $finish;
  end

endprogram : mem_test
