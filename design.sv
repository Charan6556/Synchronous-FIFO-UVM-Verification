module sync_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 16
)(
  input  logic                  clk,
  input  logic                  rst,
  input  logic                  wr_en,
  input  logic                  rd_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic                  full,
  output logic                  empty
);

  localparam PTR_WIDTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1;
  localparam COUNT_WIDTH = $clog2(DEPTH + 1);

  logic [PTR_WIDTH-1:0]   wr_ptr;
  logic [PTR_WIDTH-1:0]   rd_ptr;
  logic [COUNT_WIDTH-1:0] count;

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin

    if (rst) begin
      wr_ptr   <= '0;
      rd_ptr   <= '0;
      count    <= '0;
      data_out <= '0;
    end

    else begin

      // Write
      if (wr_en && !full) begin
        mem[wr_ptr] <= data_in;
        wr_ptr      <= (wr_ptr == DEPTH-1) ? '0 : wr_ptr + 1'b1;
      end

      // Read
      if (rd_en && !empty) begin
        data_out <= mem[rd_ptr];
        rd_ptr   <= (rd_ptr == DEPTH-1) ? '0 : rd_ptr + 1'b1;
      end

      // Count control
      case ({wr_en && !full, rd_en && !empty})

        2'b10:
          count <= count + 1'b1;

        2'b01:
          count <= count - 1'b1;

        2'b11:
          count <= count;

        default:
          count <= count;

      endcase

    end

  end

  assign empty = (count == 0);
  assign full  = (count == DEPTH);
  
  // 1. FIFO cannot be full and empty at the same time
property p_not_full_and_empty;
  @(posedge clk)
  disable iff (rst)
  !(full && empty);
endproperty

assert property (p_not_full_and_empty)
else $error("FIFO cannot be full and empty at the same time");


// 2. Count must stay within FIFO depth
property p_count_range;
  @(posedge clk)
  disable iff (rst)
  count <= DEPTH;
endproperty

assert property (p_count_range)
else $error("FIFO count exceeded DEPTH");


// 3. Write pointer must not move when FIFO is full
property p_no_write_when_full;
  @(posedge clk)
  disable iff (rst)
  (full && wr_en) |=> $stable(wr_ptr);
endproperty

assert property (p_no_write_when_full)
else $error("Write pointer changed while FIFO was full");


// 4. Read pointer must not move when FIFO is empty
property p_no_read_when_empty;
  @(posedge clk)
  disable iff (rst)
  (empty && rd_en) |=> $stable(rd_ptr);
endproperty

assert property (p_no_read_when_empty)
else $error("Read pointer changed while FIFO was empty");


// 5. Write-only operation must increment count
property p_write_increments_count;
  @(posedge clk)
  disable iff (rst)
  (wr_en && !full && !rd_en)
  |=> count == $past(count) + 1;
endproperty

assert property (p_write_increments_count)
else $error("Count did not increment after valid write");


// 6. Read-only operation must decrement count
property p_read_decrements_count;
  @(posedge clk)
  disable iff (rst)
  (rd_en && !empty && !wr_en)
  |=> count == $past(count) - 1;
endproperty

assert property (p_read_decrements_count)
else $error("Count did not decrement after valid read");


// 7. Simultaneous valid read/write keeps count unchanged
property p_simultaneous_count_stable;
  @(posedge clk)
  disable iff (rst)
  (wr_en && !full && rd_en && !empty)
  |=> count == $past(count);
endproperty

assert property (p_simultaneous_count_stable)
else $error("Count changed during simultaneous read/write");


// 8. Reset must clear FIFO state
property p_reset;
  @(posedge clk)
  rst |=> (wr_ptr == 0 &&
           rd_ptr == 0 &&
           count  == 0);
endproperty

assert property (p_reset)
else $error("FIFO did not reset correctly");

endmodule
