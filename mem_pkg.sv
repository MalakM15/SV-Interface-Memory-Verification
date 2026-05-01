
package mem_pkg;

  class Transaction;
    // Class variables
    
    rand logic [15:0] address;      // 16-bit address (64K locations)
    rand logic [7:0]  data_in;      // 8-bit write data
    logic      [8:0]  data_out;     // 9-bit read data (data + parity)
    logic      [8:0]  expected_data;// Expected 9-bit data (data + parity)

    static int error = 0;

    function new();
      if (!this.randomize()) begin
        $display("[TRANSACTION] Randomization failed at time %0t", $time);
      end
    endfunction

    function void print_data_out();
      $display("[TRANSACTION] Time=%0t | data_out = 0b%09b  (parity=%0b, data=0x%02h)",
               $time,
               data_out,
               data_out[8],
               data_out[7:0]);
    endfunction

    static function void print_error();
      $display("[TRANSACTION] Time=%0t | Total Errors = %0d", $time, error);
    endfunction

    function void check_data();
      if (data_out !== expected_data) begin
        $display("[ERROR] Time=%0t | MISMATCH: expected=0b%09b  got=0b%09b",
                 $time, expected_data, data_out);
        error++;
      end else begin
        $display("[PASS]  Time=%0t | MATCH:    expected=0b%09b  got=0b%09b",
                 $time, expected_data, data_out);
      end
    endfunction

    // returns a new Transaction that is a deep copy of this one
    function Transaction deep_copy();
      Transaction t = new();
      t.address       = this.address;
      t.data_in       = this.data_in;
      t.data_out      = this.data_out;
      t.expected_data = this.expected_data;
      return t;
    endfunction

  endclass : Transaction

endpackage : mem_pkg
