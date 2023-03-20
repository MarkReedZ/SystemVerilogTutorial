class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new( string name="base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  env  test_env;
  basic_seq seq;
  virtual l2_core_if  l2_core_if;
  virtual core_l2_if  core_l2_if;
  virtual l2_mem_if  l2_mem_if;
  virtual mem_l2_if  mem_l2_if;

  //dl_monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    test_env = env::type_id::create("env",this);

    if (!uvm_config_db#(virtual l2_core_if)::get(this, "", "l2_core_if", l2_core_if)) `uvm_fatal("TEST", "Did not get l2_core_if")
    if (!uvm_config_db#(virtual core_l2_if)::get(this, "", "core_l2_if", core_l2_if)) `uvm_fatal("TEST", "Did not get core_l2_if")
    if (!uvm_config_db#(virtual l2_mem_if)::get(this, "", "l2_mem_if", l2_mem_if)) `uvm_fatal("TEST", "Did not get l2_mem_if")
    if (!uvm_config_db#(virtual mem_l2_if)::get(this, "", "mem_l2_if", mem_l2_if)) `uvm_fatal("TEST", "Did not get mem_l2_if")
    uvm_config_db#(virtual core_l2_if)::set(this, "env.ag.*", "core_l2_if", core_l2_if);
    uvm_config_db#(virtual mem_l2_if)::set(this, "env.mem_ag.*", "mem_l2_if", mem_l2_if);
    uvm_config_db#(virtual l2_mem_if)::set(this, "env.mem_ag.*", "l2_mem_if", l2_mem_if);
    uvm_config_db#(virtual l2_core_if)::set(this, "env.l2_core_mon", "l2_core_if", l2_core_if);

    //uvm_config_db#(bit[3:0])::set(this, "*", "ref_pattern", pattern);

    seq = basic_seq::type_id::create("seq");
    //assert(seq.randomize() with { num inside {[1:5]}; });
    assert(seq.randomize() with { num == 10; });

  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apply_reset();
    seq.start(test_env.ag.seq);
    //$monitor("%0t tst: cmd %d addr %0x data %0x", $time, dl_if.dl_tl_cmd, dl_if.dl_tl_addr, dl_if.dl_tl_data);
    //dl_if.dl_tl_cmd <= 1; dl_if.dl_tl_addr <= 2; dl_if.dl_tl_data <= 8'hFF;
    //#10 dl_if.dl_tl_cmd <= 0;
    #4000;
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    repeat(5) @(posedge core_l2_if.clk);
  endtask

endclass

