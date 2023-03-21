class env extends uvm_env;
  `uvm_component_utils(env)
  function new( string name = "env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  core_l2_agent ag;
  l2_core_monitor l2_core_mon; 
  mem_agent mem_ag;

  L2Sb l2_sb;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag = core_l2_agent::type_id::create("ag",this);
    mem_ag = mem_agent::type_id::create("mem_ag",this);
    l2_core_mon = l2_core_monitor::type_id::create("l2_core_mon",this);
    l2_sb = L2Sb::type_id::create("l2_sb",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ag.mon.ap.connect(l2_sb.imp_core_l2);
    l2_core_mon.ap.connect(l2_sb.imp_l2_core);
    mem_ag.mon.l2_mem_ap.connect(l2_sb.imp_l2_mem);
    mem_ag.mon.mem_l2_ap.connect(l2_sb.imp_mem_l2);

    // mem_driver needs the L2->Mem transactions to respond to them
    mem_ag.mon.l2_mem_ap.connect( mem_ag.drv.imp );
  endfunction

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    //uvm_report_server rs = uvm_report_server::get_server();
    //$display(" fatal %d eror %d", rs.get_severity_count(UVM_FATAL), rs.get_severity_count(UVM_ERROR));
  endfunction

endclass
