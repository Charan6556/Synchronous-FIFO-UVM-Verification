class fifo_environment extends uvm_env;
  `uvm_component_utils(fifo_environment);
  
   fifo_agent agent;
   fifo_scoreboard scoreboard;
  
  //constructor standard
  function new(string name = "fifo_environment", uvm_component parent);
    super.new(name,parent);
    `uvm_info("environment class","constructor",UVM_MEDIUM);
  endfunction
  
  //build phase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
     agent = fifo_agent::type_id::create("agent", this);
      scoreboard = fifo_scoreboard::type_id::create("scoreboard",this);
      endfunction
  //connect phase
   function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info ("environment class", "connect phase", UVM_MEDIUM)
        agent.mon.item_collected_port.connect(scoreboard.item_collected_export);
          endfunction
        endclass
    
