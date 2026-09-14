class fifo_driver extends uvm_driver#(fifo_seq_item);
  `uvm_component_utils(fifo_driver)
  virtual fifo_intf intf;
    fifo_seq_item tx;
  //constructor (standard)
  function new(string name = "fifo_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("driver class","constructor",UVM_MEDIUM)
  endfunction
  //connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info ("driver class", "connect phase", UVM_MEDIUM)
      if(!uvm_config_db#(virtual fifo_intf)::get(this,"","vif",intf))
         `uvm_fatal("no_intf in driver","virtual interface get failed from config db");
          endfunction
    //run phase
    task run_phase(uvm_phase phase);
      forever begin
        `uvm_info ("driver class", "run phase", UVM_MEDIUM)
        seq_item_port.get_next_item(tx);
        drive(tx);
        seq_item_port.item_done();
      end
    endtask
    // Drive on the falling edge so the DUT can sample stable inputs at posedge.
    task drive(fifo_seq_item tx);
     @(negedge intf.clk)
      intf.wr_en<=tx.wr_en;
      intf.rd_en <=tx.rd_en;
      intf.data_in<=tx.data_in;
    endtask
    
    endclass
