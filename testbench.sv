`timescale 1ns/1ns

`include "uvm_macros.svh"
import uvm_pkg::*;
 `include "interface.sv"
`include "seq_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"

module top;
  logic clk;

  fifo_intf intf(.clk(clk));

  sync_fifo DUT (
  .clk(clk),
  .rst(intf.rst),
  .wr_en(intf.wr_en),
  .rd_en(intf.rd_en),
  .data_in(intf.data_in),
  .data_out(intf.data_out),
  .empty(intf.empty),
  .full(intf.full)
  );
  // Share the interface handle with UVM components through the configuration DB.
  initial begin
    uvm_config_db#(virtual fifo_intf)::set(null, "*", "vif", intf);
    run_test("fifo_test");
  end
  initial 
    clk = 0;
  always #5 clk=~clk;
    initial begin
    $monitor("%0t clk = %0d", $time, clk);
    end
      // Reset DUT
  initial begin
    intf.rst = 1;
    intf.wr_en = 0;
    intf.rd_en = 0;
    intf.data_in = '0;

    repeat(2) @(posedge clk);
    @(negedge clk);
    intf.rst = 0;
  end
       initial begin
  $dumpfile("dump.vcd");
         $dumpvars(0, DUT);
end               
  endmodule
