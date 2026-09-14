class fifo_sequence extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_sequence)

  fifo_seq_item tx;

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (10) begin
      tx = fifo_seq_item::type_id::create("tx");

      start_item(tx);

      if (!tx.randomize())
        `uvm_error("FIFO_SEQ", "Transaction randomization failed")

      finish_item(tx);
    end
  endtask
endclass

class fifo_fill_sequence extends uvm_sequence #(fifo_seq_item);

  `uvm_object_utils(fifo_fill_sequence)

  fifo_seq_item tx;

  function new(string name = "fifo_fill_sequence");
    super.new(name);
  endfunction

  task body();

    repeat (18) begin

      tx = fifo_seq_item::type_id::create("tx");

      start_item(tx);

      tx.wr_en = 1;
      tx.rd_en = 0;
      tx.data_in = $urandom;

      finish_item(tx);

    end

  endtask

endclass

class fifo_drain_sequence extends uvm_sequence #(fifo_seq_item);

  `uvm_object_utils(fifo_drain_sequence)

  fifo_seq_item tx;

  function new(string name = "fifo_drain_sequence");
    super.new(name);
  endfunction

  task body();

    repeat (18) begin

      tx = fifo_seq_item::type_id::create("tx");

      start_item(tx);

      tx.wr_en = 0;
      tx.rd_en = 1;
      tx.data_in = '0;

      finish_item(tx);

    end

  endtask

endclass