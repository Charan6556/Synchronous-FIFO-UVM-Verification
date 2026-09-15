class fifo_scoreboard extends uvm_scoreboard;
  localparam int DATA_WIDTH = 8;
  localparam int DEPTH      = 16;

  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) item_collected_export;

  bit [DATA_WIDTH-1:0] ref_queue[$];
  int num_writes;
  int num_reads;
  int num_items;

  function new(string name = "fifo_scoreboard",
               uvm_component parent);
    super.new(name, parent);
    `uvm_info("scoreboard class", "constructor", UVM_MEDIUM)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction

  function void write(fifo_seq_item tx);
    bit [DATA_WIDTH-1:0] expected;
    int pre_size;

    num_items++;

    // Reference occupancy before this DUT cycle. Legal operations are
    // determined from this independent state, never from DUT flags.
    pre_size = ref_queue.size();

    if (tx.rd_en && pre_size > 0) begin
      expected = ref_queue.pop_front();
      num_reads++;

      if (tx.data_out === expected)
        `uvm_info("SCB",
          $sformatf("PASS READ: expected=%0h actual=%0h",
                    expected, tx.data_out),
          UVM_LOW)
      else
        `uvm_error("SCB",
          $sformatf("FAIL READ: expected=%0h actual=%0h",
                    expected, tx.data_out))
    end

    if (tx.wr_en && pre_size < DEPTH) begin
      ref_queue.push_back(tx.data_in);
      num_writes++;

      `uvm_info("SCB",
        $sformatf("WRITE: data=%0h", tx.data_in),
        UVM_LOW)
    end

    // DUT status outputs are checked against the resulting model occupancy.
    // They never control the reference model.
    if (tx.full !== (ref_queue.size() == DEPTH))
      `uvm_error("SCB",
        $sformatf("FULL mismatch: DUT=%0b expected=%0b queue_size=%0d",
                  tx.full, (ref_queue.size() == DEPTH), ref_queue.size()))

    if (tx.empty !== (ref_queue.size() == 0))
      `uvm_error("SCB",
        $sformatf("EMPTY mismatch: DUT=%0b expected=%0b queue_size=%0d",
                  tx.empty, (ref_queue.size() == 0), ref_queue.size()))
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (num_items == 0)
      `uvm_error("SCB", "Scoreboard received no transactions at all")

    if (num_writes == 0)
      `uvm_error("SCB", "No accepted writes were observed")

    if (num_reads == 0)
      `uvm_error("SCB", "No accepted reads were observed")

    if (ref_queue.size() != 0)
      `uvm_error("SCB",
        $sformatf("Test ended with %0d item(s) still in reference queue",
                  ref_queue.size()))

    `uvm_info("SCB",
      $sformatf("FINAL: items=%0d writes=%0d reads=%0d leftover=%0d",
                num_items, num_writes, num_reads, ref_queue.size()),
      UVM_LOW)
  endfunction

endclass
