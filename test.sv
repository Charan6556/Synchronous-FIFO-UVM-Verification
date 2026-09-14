class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test)
  fifo_environment env;
  fifo_fill_sequence  fill_seq;
  fifo_drain_sequence drain_seq;


  //constructor (standard)
  function new(string name = "fifo_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("test class","constructor",UVM_MEDIUM)
  endfunction
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = fifo_environment::type_id::create("env",this);
  endfunction
  
  //connect phase
   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);    
     `uvm_info("test class","connect phase",UVM_MEDIUM)

  endfunction
  
  //end of eloboration phase
  function void end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  `uvm_info("Test class", "end of elaboration phase", UVM_MEDIUM)
  uvm_top.print_topology();
  endfunction 
  //run phase
  task run_phase(uvm_phase phase);
    `uvm_info("test class","run phase",UVM_MEDIUM);
     // Keep run_phase alive until the sequence finishes.
          phase.raise_objection(this);
         
       fill_seq = fifo_fill_sequence::type_id::create("fill_seq");
       drain_seq = fifo_drain_sequence::type_id::create("drain_seq");

       fill_seq.start(env.agent.seqr);
       drain_seq.start(env.agent.seqr);
            phase.drop_objection(this);
          endtask
      endclass