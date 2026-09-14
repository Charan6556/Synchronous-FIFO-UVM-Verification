class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor);
  virtual fifo_intf intf;
  uvm_analysis_port #(fifo_seq_item) item_collected_port;
  fifo_seq_item tx;
  
  //constructor(standard)
  function new(string name = "fifo_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("monitor class","constructor",UVM_MEDIUM);
  endfunction
  //buildphase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
     item_collected_port = new("item_collected_port",this);                    
        `uvm_info ("monitor class", "constructor", UVM_MEDIUM)
    if(!uvm_config_db#(virtual fifo_intf)::get(this,"","vif", intf))
            `uvm_fatal("NO_INTF_MON", "Virtual interface get failed in monitor")
        endfunction
      // Continuously sample DUT activity and publish observed transactions.
              task run_phase(uvm_phase phase);
                forever begin
                tx = fifo_seq_item::type_id::create("tx");
                wait(!intf.rst);
                
                // Capture request and pre-edge status used to decide acceptance.
                @(posedge intf.clk);
                tx.rst = intf.rst;
                tx.wr_en = intf.wr_en;
                tx.rd_en = intf.rd_en;
                tx.data_in = intf.data_in;
                tx.empty = intf.empty;  
                tx.full = intf.full;

                // Sample registered read data after nonblocking assignments settle.
                #1step;
                tx.data_out = intf.data_out;
                item_collected_port.write(tx);

                end
              endtask
      
      endclass
