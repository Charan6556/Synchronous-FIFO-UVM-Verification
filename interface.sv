interface fifo_intf#(parameter DATA_WIDTH = 8)
  (input logic clk);
  logic rst;
  logic wr_en;
  logic rd_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full;
  logic empty;
endinterface