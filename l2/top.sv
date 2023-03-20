
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "enums.svh"

module tb;
  reg clk, rstn;

  core_l2_if core_l2_vif (clk);
  l2_core_if l2_core_vif (clk);
  l2_mem_if l2_mem_vif (clk);
  mem_l2_if mem_l2_vif (clk);

  L2 l2i(rstn, clk, 
         core_l2_vif.vld, core_l2_vif.cmd, core_l2_vif.addr, core_l2_vif.data,
         l2_core_vif.resp_vld, l2_core_vif.resp, l2_core_vif.data, 
         mem_l2_vif.m_rsp_vld,
         mem_l2_vif.m_rsp_data, 
         l2_mem_vif.mvld, l2_mem_vif.mcmd, l2_mem_vif.maddr, l2_mem_vif.mdata);

  always #5 clk = ~clk;

  initial begin
    //$fsdbDumpfile("dump.fsdb");
    //$fsdbDumpvars(0, l2i, "+all");
    //$monitor("%0t:     DELME resp vld=0x%0h", $time, l2_core_vif.resp_vld);
    clk <= 0; 
    uvm_config_db#(virtual core_l2_if)::set(null,"uvm_test_top","core_l2_if", core_l2_vif);
    uvm_config_db#(virtual l2_core_if)::set(null,"uvm_test_top","l2_core_if", l2_core_vif);
    uvm_config_db#(virtual l2_mem_if)::set(null,"uvm_test_top","l2_mem_if", l2_mem_vif);
    uvm_config_db#(virtual mem_l2_if)::set(null,"uvm_test_top","mem_l2_if", mem_l2_vif);
    run_test("base_test");
  end

  
endmodule

interface core_l2_if ( input clk );
    logic [7:0] vld;
    logic [7:0] [2:0] cmd;
    logic [7:0] [31:0] addr;
    logic [7:0] [31:0] data;
endinterface

interface l2_core_if ( input clk );
    logic [7:0]        resp_vld;
    logic [7:0] [2:0]  resp;
    logic [7:0] [31:0] data;
endinterface

interface mem_l2_if ( input clk );
    logic m_rsp_vld;
    logic [31:0] m_rsp_data;
endinterface

interface l2_mem_if ( input clk );
    logic mvld;
    logic mcmd;
    logic [31:0] maddr;
    logic [31:0] mdata;
endinterface

class CoreXac extends uvm_sequence_item;
  `uvm_object_utils(CoreXac)

  // Core -> L2
  bit vld;
  rand bit [2:0]  cmd;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand int core;

  // L2 -> Core
  bit resp_vld;
  bit [2:0] resp;
  // data 

  virtual function string str();
    if ( vld )
      return $sformatf("C%0d->L2  cmd=%0d adr=%0x data=%0x", core,cmd,addr,data);
    else if ( resp_vld ) 
      return $sformatf("L2->C%0d  rsp=%0d data=%0x", core, resp, data);
    else
      return "";
  endfunction

  function new(string name = "CoreXac");
    super.new(name);
  endfunction

  constraint cmd_c { cmd inside {[0:1]}; }
  constraint core_c { core > 0; core < 8; }
  constraint addr_c { addr < 4; }
  constraint data_c { 
    (cmd == 0) -> data == 0; 
    (cmd == 1) -> data == 5;
  }
endclass

class L2MemXac extends uvm_sequence_item;
  `uvm_object_utils(L2MemXac)

  // L2 -> Mem
  bit vld;
  bit cmd;
  bit [31:0] addr;
  bit [31:0] data;

  //  Mem -> L2
  bit rsp_vld;
  // data

  virtual function string str();
    if ( vld )
      return $sformatf("L2->Mem cmd=%0d adr=%0x data=%0x", cmd,addr,data);
    else if ( rsp_vld ) 
      return $sformatf("Mem->L2 data=%0x", data);
    else
      return "";
  endfunction

  function new(string name = "L2MemXac");
    super.new(name);
  endfunction
endclass

class l2_core_monitor extends uvm_monitor;
  `uvm_component_utils(l2_core_monitor)
  function new(string name = "l2_core_monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(CoreXac) ap;
  virtual l2_core_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual l2_core_if)::get(this, "", "l2_core_if", vif)) `uvm_fatal("MON", "Could not get vif")
    ap = new ("l2_core_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    for (int i=0; i < 8; i++ ) begin
      fork 
        int c = i; 
        monitor_core(c);
      join_none
    end
  endtask

  task monitor_core(int i);
        forever begin
          @(posedge vif.clk) begin
            if ( vif.resp_vld[i] ) begin
              CoreXac xac = CoreXac::type_id::create("xac");
              xac.resp_vld = 1;
              xac.core = i;
              xac.resp = vif.resp[i];
              xac.data = vif.data[i];
              ap.write(xac);
              $display("%0t: %s", $time, xac.str());
            end
          end
        end
  endtask
endclass

class core_l2_monitor extends uvm_monitor;
  `uvm_component_utils(core_l2_monitor)
  function new(string name = "core_l2_monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(CoreXac) ap;
  virtual core_l2_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual core_l2_if)::get(this, "", "core_l2_if", vif)) `uvm_fatal("MON", "Could not get vif")
    ap = new ("core_l2_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    for (int i=0; i < 8; i++ ) begin
      fork 
        int c = i; 
        monitor_core(c);
      join_none
    end
  endtask

  task monitor_core(int i);
    forever begin
      @(posedge vif.clk) begin
        if ( vif.vld[i] ) begin
          CoreXac xac = CoreXac::type_id::create("xac");
          xac.vld = 1;
          xac.cmd = vif.cmd[i];
          xac.addr = vif.addr[i];
          xac.data = vif.data[i];
          xac.core = i;
          ap.write(xac);
          $display("%0t: %s", $time, xac.str());
          //`uvm_info("MON", $sformatf("dl_tl cmd %d data %0x", dl_if.dl_tl_cmd, dl_if.dl_tl_data), UVM_HIGH)
        end
      end
    end
  endtask
endclass

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

class mem_monitor extends uvm_monitor;
  `uvm_component_utils(mem_monitor)
  function new(string name = "mem_monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(L2MemXac) l2_mem_ap;
  uvm_analysis_port #(L2MemXac) mem_l2_ap;
  virtual l2_mem_if lvif;
  virtual mem_l2_if mvif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual l2_mem_if)::get(this, "", "l2_mem_if", lvif)) `uvm_fatal("MON", "Could not get vif")
    if (!uvm_config_db#(virtual mem_l2_if)::get(this, "", "mem_l2_if", mvif)) `uvm_fatal("MON", "Could not get vif")
    l2_mem_ap = new ("l2_mem_ap",this);
    mem_l2_ap = new ("mem_l2_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
        // Response from memory
        forever begin
          @(posedge mvif.clk) begin
            if ( mvif.m_rsp_vld == 1 ) begin
              L2MemXac xac = L2MemXac::type_id::create("xac");
              xac.rsp_vld = 1;
              xac.data = mvif.m_rsp_data;
              mem_l2_ap.write(xac);
              $display("%0t: %s", $time, xac.str());
            end
          end
        end

        forever begin
          @(posedge lvif.clk) begin
            if ( lvif.mvld ) begin
              L2MemXac xac = L2MemXac::type_id::create("xac");
              xac.vld  = 1;
              xac.cmd  = lvif.mcmd;
              xac.addr = lvif.maddr;
              xac.data = lvif.mdata;
              l2_mem_ap.write(xac);
              $display("%0t: %s", $time, xac.str());
            end
          end
        end
    join
  endtask
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


class L2Sb extends uvm_scoreboard;
  `uvm_component_utils(L2Sb)
  function new(string name = "l2_sb", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  CoreXac core_q[8][$];
  L2MemXac mem_q[$];

  int mem_fth_addr_q[$]; // Expected addresses to be fetched from memory

  class Entry;
    bit [7:0] own;
    bit ex;
    bit dirty;
    bit [31:0] data;

    bit mem_fetch_pending;
  
    function new();
      {own, ex, dirty, data, mem_fetch_pending} = 0;
    endfunction
  endclass
  Entry refmdl[int];

  bit exp_invalidates[8][int];

  `uvm_analysis_imp_decl(_l2_core)
  `uvm_analysis_imp_decl(_core_l2)
  `uvm_analysis_imp_decl(_l2_mem)
  `uvm_analysis_imp_decl(_mem_l2)
  uvm_analysis_imp_l2_core #(CoreXac,  L2Sb) imp_l2_core;
  uvm_analysis_imp_core_l2 #(CoreXac,  L2Sb) imp_core_l2;
  uvm_analysis_imp_l2_mem  #(L2MemXac, L2Sb) imp_l2_mem;
  uvm_analysis_imp_mem_l2  #(L2MemXac, L2Sb) imp_mem_l2;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp_l2_core  = new("imp_l2_core",this);
    imp_core_l2  = new("imp_core_l2",this);
    imp_l2_mem   = new("imp_l2_mem", this);
    imp_mem_l2   = new("imp_mem_l2", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  function void write_core_l2(CoreXac xac);
    if ( xac.cmd == READSHARED ) begin
      core_q[xac.core].push_back(xac);
      if ( !refmdl.exists(xac.addr) ) begin
        Entry e = new();
        e.mem_fetch_pending = 1;
        e.own[xac.core] = 1;
        refmdl[xac.addr] = e;
        mem_fth_addr_q.push_back(xac.addr);
      end else begin
        // Hit in refmdl

        // A RO fetch that hits EX has to invalidate the EX core
        if ( refmdl[xac.addr].ex == 1 ) begin
          foreach( refmdl[xac.addr].own[i] ) begin
            if ( refmdl[xac.addr].own[i] == 1 )
              exp_invalidates[i][xac.addr] = 1;
          end
          
          refmdl[xac.addr].ex = 0; 
        end

        refmdl[xac.addr].own[xac.core] = 1; // TODO what if the bit was already set


        // Nothing needs to be done.  We're expecting a response to the core and will check the data.

      end
    end

    // Exclusive fetches have to invalidate all other caches
    if ( xac.cmd == READUNIQUE ) begin
      core_q[xac.core].push_back(xac);

      if ( !refmdl.exists(xac.addr) ) begin
        Entry e = new();
        e.mem_fetch_pending = 1;
        e.own[xac.core] = 1;
        e.ex = 1;
        refmdl[xac.addr] = e;
        mem_fth_addr_q.push_back(xac.addr);
      end else begin

        // Hit in refmdl
        // We have to send invalidates to the other caches
        foreach( refmdl[xac.addr].own[i] ) begin
          if ( refmdl[xac.addr].own[i] == 1 )
            exp_invalidates[i][xac.addr] = 1;
        end
       
        // We'll set the refmdl now to exclusive to this core
        refmdl[xac.addr].own[xac.core] = 1; 
        refmdl[xac.addr].ex = 1;



      end

    end
  endfunction

  function void write_l2_core(CoreXac in_xac);
    CoreXac xac;

    if ( in_xac.resp == READDATA ) begin
      if ( core_q[in_xac.core].size() == 0 ) begin
          `uvm_error("L2SB", $sformatf("We saw an unexpected l2->C%0d response\n  %s", in_xac.core, in_xac.str()) )
          return;
      end
      xac = core_q[in_xac.core].pop_front();

      if ( !refmdl.exists(xac.addr) ) begin
        `uvm_error("L2SB", $sformatf("We saw a read data response on l2->C%0d, but the refmdl doesn't have this address\n  %s", xac.core, xac.str()) )
        return;
      end
      if ( refmdl[xac.addr].mem_fetch_pending == 1 ) 
        `uvm_error("L2SB", $sformatf("We saw a read data response on l2->C%0d, but there is a fetch to memory outstanding for this address\n  %s", xac.core, xac.str()) )
      if ( refmdl[xac.addr].data != in_xac.data ) begin
        `uvm_error("L2SB", $sformatf("Data miscompare exp %0h act %0h\n  %s", refmdl[xac.addr].data, xac.data, xac.str()) )
      end
    end 

    if ( in_xac.resp == INVALIDATE ) begin
      int adr = in_xac.data;
      if ( !refmdl.exists(adr) ) begin
        `uvm_error("L2SB", $sformatf("We saw an invalidate on l2->C%0d, but the refmdl doesn't have this address ro for this core\n  %s", in_xac.core, in_xac.str()) )
        return;
      end
      if ( !exp_invalidates[in_xac.core].exists(adr) ) begin
        `uvm_error("L2SB", $sformatf("Saw an unexpected invalidate on l2->C%0d\n  %s", in_xac.core, in_xac.str()) )
      end else begin
          exp_invalidates[in_xac.core].delete(adr);
      end
      refmdl[in_xac.data].own[in_xac.core] = 0;
    end
  endfunction


  function void write_l2_mem(L2MemXac xac);
    mem_q.push_back(xac);
  endfunction

  function void write_mem_l2(L2MemXac xac);
    int addr;
    if ( mem_q.size() == 0 ) return; // TODO
    void'(mem_q.pop_front());
    addr = mem_fth_addr_q.pop_front(); 

    if ( !refmdl.exists(addr) ) begin
        `uvm_error("L2SB", $sformatf("TB ERROR - mem response, but the address doesn't exist in the ref mdl"))
        return;
    end

    refmdl[addr].data = xac.data;
    refmdl[addr].mem_fetch_pending = 0;
  endfunction

/*
  function void write_tl_wdf( TlWdfItem it );
    Item dlxac;
    $display(" L2Sb: tl_wdf %s",it.str());
    if ( writeQ.size() == 0 ) begin
        `uvm_error("SB", "Saw tl_wdf with no matching dl_tl write")
        return;
    end
    dlxac = writeQ.pop_front();

  endfunction
*/
  virtual function void check_phase(uvm_phase phase);
    foreach( core_q[i] ) begin
      if ( core_q[i].size() ) begin
        `uvm_error("SB_HANG","There are still cmds from the core that we haven't responded to. Cmds:")
        foreach( core_q[i][j] ) begin
          `uvm_info("MON", $sformatf("    %s", core_q[i][j].str() ), UVM_NONE)
          
        end
      end
    end
  endfunction

endclass

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

