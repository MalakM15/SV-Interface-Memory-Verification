module my_mem (
mem_if.dut_mp mif
);

// Declare a 9-bit associative array using the logic data type
logic [8:0] mem_array[int];

always @ (posedge mif.clk) begin
if (mif.write)
mem_array [mif.address] = {^mif.data_in, mif.data_in};
else if (mif.read)
mif.data_out = mem_array [mif.address] ;
end

endmodule