
class basic_seq extends uvm_sequence;
  `uvm_object_utils(basic_seq)
  function new(string name = "basic_seq");
    super.new(name);
  endfunction

  rand int num;
  CoreXac it;

  constraint c1 { soft num inside {[2:50]}; }

  virtual task body();
    for (int i = 0; i < num; i++ ) begin
      // `uvm_do(it)
      it = CoreXac::type_id::create("xac");
      start_item(it);
      assert(it.randomize() with { it.addr == 2; } );
      `uvm_info("SEQ", $sformatf("New item: %s", it.str()), UVM_HIGH)
      finish_item(it);
    end
  endtask

endclass

class core_l2_driver extends uvm_driver #(CoreXac);
  `uvm_component_utils(core_l2_driver)
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual core_l2_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("drv build");
    if (!uvm_config_db#(virtual core_l2_if)::get(this, "", "core_l2_if", vif))
      `uvm_fatal("DRV", "Could not get core_l2_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    foreach( vif.vld[c] ) begin
      vif.vld[c]  = 0;
      vif.cmd[c]  = 0;
      vif.addr[c] = 0;
      vif.data[c] = 0;
    end

    forever begin
      CoreXac it;
      `uvm_info("DRV", "Waiting for item", UVM_HIGH)
      seq_item_port.get_next_item(it);
      drive_item(it);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_item(CoreXac xac);
    int c;
    c = xac.core;
    @(vif.clk) begin;
      vif.vld[c]  <= 1;
      vif.cmd[c]  <= xac.cmd;
      vif.addr[c] <= xac.addr;
      vif.data[c] <= xac.data;
    end
    @(vif.clk);
    vif.vld[c] <= 0;
    @(vif.clk);
    @(vif.clk);
    @(vif.clk);
    @(vif.clk);
  endtask

endclass

class core_l2_agent extends uvm_agent;
  `uvm_component_utils(core_l2_agent)
  function new(string name="core_l2_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_sequencer #(CoreXac) seq;
  core_l2_driver drv;
  core_l2_monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = uvm_sequencer#(CoreXac)::type_id::create("seq",this);
    drv = core_l2_driver::type_id::create("drv",this);
    mon = core_l2_monitor::type_id::create("mon",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seq.seq_item_export);
  endfunction

endclass



class mem_driver extends uvm_driver #(L2MemXac);
  `uvm_component_utils(mem_driver)
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual mem_l2_if vif;

  uvm_analysis_imp #(L2MemXac, mem_driver) imp;

  L2MemXac q[$];

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mem_l2_if)::get(this, "", "mem_l2_if", vif))
      `uvm_fatal("DRV", "Could not get mem_l2_if")
    imp = new("imp",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    vif.m_rsp_vld   = 0;
    vif.m_rsp_data  = 0;

    forever begin
      L2MemXac xac;

      wait ( q.size() > 0 );

      xac = q.pop_front();
      drive_item(xac);

    end
  endtask

  function void write( L2MemXac xac );
    xac.data = 2; // TODO data from ref mdl
    q.push_back(xac);
  endfunction

  virtual task drive_item(L2MemXac xac);
    @(vif.clk) begin;
      vif.m_rsp_vld  <= 1;
      vif.m_rsp_data <= xac.data;
    end
    @(vif.clk);
    vif.m_rsp_vld <= 0;
    @(vif.clk);
  endtask

endclass

class mem_agent extends uvm_agent;
  `uvm_component_utils(mem_agent)
  function new(string name="mem_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_sequencer #(L2MemXac) seq;
  mem_driver drv;
  mem_monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = mem_driver::type_id::create("drv",this);
    mon = mem_monitor::type_id::create("mon",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
endclass
