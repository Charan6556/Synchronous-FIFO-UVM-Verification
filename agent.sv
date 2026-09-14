class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent);
  fifo_driver drv;
  fifo_sequencer seqr;
  fifo_monitor mon;
  //constructor standard
  function new(string name = "fifo_agent", uvm_component parent);
    super.new(name,parent);
    `uvm_info("agent class","constructor",UVM_MEDIUM)
  endfunction
  
  //build phase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    mon=fifo_monitor::type_id::create("mon",this);
    
    if (is_active == UVM_ACTIVE) begin
      drv=fifo_driver::type_id::create("drv",this);
      seqr=fifo_sequencer::type_id::create("seqr",this);
    end
  endfunction
  //connect phase
   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);    
     `uvm_info("agent class","connect phase",UVM_MEDIUM)
     if (is_active == UVM_ACTIVE)
       drv.seq_item_port.connect(seqr.seq_item_export);
     
  endfunction
endclass
