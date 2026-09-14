class fifo_scoreboard extends uvm_scoreboard;
localparam int DATA_WIDTH = 8;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) item_collected_export;

  bit [DATA_WIDTH-1:0] ref_queue[$];

  // Constructor
  function new(string name = "fifo_scoreboard",
               uvm_component parent);
    super.new(name, parent);
    `uvm_info("scoreboard class", "constructor", UVM_MEDIUM)
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_collected_export =
      new("item_collected_export", this);
  endfunction

  // Write method
  function void write(fifo_seq_item tx);

    bit [DATA_WIDTH-1:0] expected;

    // WRITE
    if (tx.wr_en && !tx.full) begin

      ref_queue.push_back(tx.data_in);

      `uvm_info("SCB",
        $sformatf("Data pushed = %0h", tx.data_in),
        UVM_LOW)
    end

    // READ
    if (tx.rd_en && !tx.empty) begin

      if (ref_queue.size() > 0) begin

        expected = ref_queue.pop_front();

        if (tx.data_out == expected)
          `uvm_info("SCB",
            $sformatf("PASS: expected=%0h actual=%0h",
                      expected, tx.data_out),
            UVM_LOW)
        else
          `uvm_error("SCB",
            $sformatf("FAIL: expected=%0h actual=%0h",
                      expected, tx.data_out))

      end
      else begin
        `uvm_error("SCB", "Reference queue is empty")
      end

    end

  endfunction

endclass