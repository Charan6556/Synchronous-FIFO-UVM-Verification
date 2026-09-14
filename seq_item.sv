class fifo_seq_item extends uvm_sequence_item;
localparam int DATA_WIDTH = 8;
  bit rst;

  rand bit                  wr_en;
  rand bit                  rd_en;
  rand bit [DATA_WIDTH-1:0] data_in;

       bit [DATA_WIDTH-1:0] data_out;
       bit                  full;
       bit                  empty;
     
   constraint fifo_ctrl_c {
    {wr_en, rd_en} dist {
      2'b10 := 40,
      2'b01 := 40,
      2'b11 := 15,
      2'b00 := 5
    };
  }
  
  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(rst,      UVM_ALL_ON)
    `uvm_field_int(wr_en,    UVM_ALL_ON)
    `uvm_field_int(rd_en,    UVM_ALL_ON)
    `uvm_field_int(data_in,  UVM_ALL_ON)
    `uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_field_int(full,     UVM_ALL_ON)
    `uvm_field_int(empty,    UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction

endclass