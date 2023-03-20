
`include "uvm_macros.svh"
import uvm_pkg::*;


module tb;
  reg clk,rstn;

  DL_IF dl_if(clk);

  TOP top( clk,rstn, dl_if.dl_tl_cmd, dl_if.dl_tl_addr, dl_if.dl_tl_data );

  TL_WDF_IF tl_wdf_if(clk, rstn, top.tlxr_wdf_wr, top.tlxr_wdf_wr_p, top.tlxr_wdf_ptr, top.tlxr_wdf_data);
  SRQ_WDF_IF srq_wdf_if(clk, rstn, top.srq_wdf_rd, top.srq_wdf_p, top.srq_wdf_ptr);
  DFI_IF dfi_if(clk, rstn, top.srq_dfi_wr, top.wdf_dfi_data);


  always #5 clk = ~clk;

  //always @(posedge clk && rstn) $display("%t clk=%d rstn=%d",$time,clk,rstn);
  //assert property( @(posedge clk && rstn) !fir);

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,top);
    //$recordfile("sv_wave");
    //$recordvars("depth=all",top);

    { clk,rstn,dl_if.dl_tl_cmd,dl_if.dl_tl_addr,dl_if.dl_tl_data } <= 0;
    uvm_config_db#(virtual DL_IF)::set(null, "uvm_test_top", "dl_if", dl_if);
    uvm_config_db#(virtual TL_WDF_IF)::set(null, "uvm_test_top", "tl_wdf_if", tl_wdf_if);
    uvm_config_db#(virtual SRQ_WDF_IF)::set(null, "uvm_test_top", "srq_wdf_if", srq_wdf_if);
    uvm_config_db#(virtual DFI_IF)::set(null, "uvm_test_top", "dfi_if", dfi_if);
    run_test("base_test");

    //#100 $finish;
  end 

endmodule

typedef enum { READ= 2'b00,
              WRITE= 2'b01 } cmd_t;
class Item extends uvm_sequence_item;
  `uvm_object_utils(Item)
  rand bit [1:0]  cmd;
  rand bit [63:0] addr;
  rand bit [63:0] data;
  rand int idx;
 
  rand bit [0:2] size; 
  rand bit [63:0] arr[];

  int q[$];

  virtual function string str();
    return $sformatf("cmd=%0d adr=%0x  data=%0x", cmd,addr,data);
  endfunction

  function new(string name = "Item");
    super.new(name);
    q.push_back(5);
    q.push_back(6);
    q.push_back(7);
  endfunction

  //constraint cIdx { idx inside {[0:q.size()-1]}; }
  constraint c1 { cmd dist {READ:/0, WRITE:/80}; }
  constraint c2 { addr dist {1:/50, 2:/50}; }
  //constraint c2 { addr == q[idx];           solve idx before addr; }
  //constraint c3 { (idx == 2) -> (cmd == 2); solve idx before cmd; }
  //constraint c4 { (idx == 1) -> (cmd == 2); solve idx before cmd; }
  constraint c_sz  { size inside {1,2,4,8}; }
  constraint c_arr { arr.size() == size; solve size before arr; }
  
endclass

class TlWdfItem extends uvm_sequence_item;
  `uvm_object_utils(TlWdfItem)
  rand bit wr;
  rand bit wr_p;
  rand bit [2:0] wptr;
  rand bit [63:0] data;

  virtual function string str();
    return $sformatf("wr=%0d ptr=%0x  data=%0x", wr,wptr,data);
  endfunction

  function new(string name = "TlWdfItem");
    super.new(name);
  endfunction

  //constraint c1 { cmd dist {0:/0, 1:/80}; }
  //constraint c2 { addr dist {1:/50, 2:/50}; }
endclass

class SrqWdfItem extends uvm_sequence_item;
  `uvm_object_utils(SrqWdfItem)
  rand bit rd;
  rand bit rd_p;
  rand bit [2:0] ptr;

  virtual function string str();
    return $sformatf("rd=%0d ptr=%0x", rd,ptr);
  endfunction

  function new(string name = "SrqWdfItem");
    super.new(name);
  endfunction

  //constraint c1 { cmd dist {0:/0, 1:/80}; }
  //constraint c2 { addr dist {1:/50, 2:/50}; }
endclass

class DfiItem extends uvm_sequence_item;
  `uvm_object_utils(DfiItem)
  rand bit wr;
  rand bit [63:0] data;

  virtual function string str();
    return $sformatf("wr=%0d data=%0x", wr,data);
  endfunction

  function new(string name = "DfiItem");
    super.new(name);
  endfunction

  //constraint c1 { cmd dist {0:/0, 1:/80}; }
  //constraint c2 { addr dist {1:/50, 2:/50}; }
endclass


interface DL_IF (input bit clk);
  logic rstn;
  logic [1:0] dl_tl_cmd;
  logic [63:0] dl_tl_addr;
  logic [63:0] dl_tl_data;

  clocking cb @(posedge clk);
    default input #1 output #1;
      output dl_tl_cmd;
      output dl_tl_addr;
      output dl_tl_data;
  endclocking

  dl_checker dl (.*);
endinterface

interface dl_checker ( input clk, rstn,
                       input [1:0] dl_tl_cmd,
                       input [63:0] dl_tl_addr,
                       input [63:0] dl_tl_data );
  assert property( @(posedge clk) dl_tl_cmd |=> !dl_tl_cmd );
endinterface

interface TL_WDF_IF (input clk, 
                    input rstn,
                    input tlxr_wdf_wr,
                    input tlxr_wdf_wr_p,
                    input [2:0] tlxr_wdf_ptr,
                    input [63:0] tlxr_wdf_data );
  //logic rstn;
  //logic tlxr_wdf_wr;
  //logic tlxr_wdf_wr_p;
  //logic [2:0] tlxr_wdf_ptr;
  //logic [63:0] tlxr_wdf_data;

  clocking cb @(posedge clk);
    default input #1 output #1;
      output tlxr_wdf_wr;
      output tlxr_wdf_wr_p;
      output tlxr_wdf_ptr;
      output tlxr_wdf_data;
  endclocking
endinterface

interface SRQ_WDF_IF (input clk, 
                    input rstn,
                    input srq_wdf_rd,
                    input srq_wdf_p,
                    input [2:0] srq_wdf_ptr );

  clocking cb @(posedge clk);
    default input #1 output #1;
      output srq_wdf_rd;
      output srq_wdf_p;
      output srq_wdf_ptr;
  endclocking
endinterface

interface DFI_IF (input clk, 
                    input rstn,
                    input srq_dfi_wr,
                    input [63:0] wdf_dfi_data );

  clocking cb @(posedge clk);
    default input #1 output #1;
      output srq_dfi_wr;
      output wdf_dfi_data;
  endclocking
endinterface

class dl_monitor extends uvm_monitor;
  `uvm_component_utils(dl_monitor)
  function new(string name = "mon", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(Item) dl_ap;
  virtual DL_IF dl_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual DL_IF)::get(this, "", "dl_if", dl_if)) `uvm_fatal("MON", "Could not get dl_if")
    dl_ap = new ("dl_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(dl_if.cb) begin
        if ( dl_if.dl_tl_cmd ) begin
          Item item = Item::type_id::create("item");
          item.cmd = dl_if.dl_tl_cmd;
          item.addr = dl_if.dl_tl_addr;
          item.data = dl_if.dl_tl_data;
          dl_ap.write(item);
          $display("%0t: dl_tl %s", $time, item.str());
          `uvm_info("MON", $sformatf("dl_tl cmd %d data %0x", dl_if.dl_tl_cmd, dl_if.dl_tl_data), UVM_HIGH)
        end
      end
    end
  endtask
endclass

class tl_wdf_monitor extends uvm_monitor;
  `uvm_component_utils(tl_wdf_monitor)
  function new(string name = "tl_wdf_mon", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(TlWdfItem) tl_wdf_ap;
  virtual TL_WDF_IF tl_wdf_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual TL_WDF_IF)::get(this, "", "tl_wdf_if", tl_wdf_if)) `uvm_fatal("MON", "Could not get tl_wdf_if")
    tl_wdf_ap = new ("tl_wdf_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      @(tl_wdf_if.cb) begin
        if ( tl_wdf_if.tlxr_wdf_wr ) begin
          TlWdfItem item = TlWdfItem::type_id::create("item");
          item.wr   = tl_wdf_if.tlxr_wdf_wr;
          item.wr_p = tl_wdf_if.tlxr_wdf_wr_p;
          item.wptr = tl_wdf_if.tlxr_wdf_ptr;
          item.data = tl_wdf_if.tlxr_wdf_data;
          tl_wdf_ap.write(item);
          $display("%0t: tl_wdf %s", $time, item.str());
          //`uvm_info("MON", $sformatf("dl_tl cmd %d data %0x", tl_wdf_if.dl_tl_cmd, tl_wdf_if.dl_tl_data), UVM_HIGH)
        end
      end
    end

  endtask
endclass

class srq_wdf_monitor extends uvm_monitor;
  `uvm_component_utils(srq_wdf_monitor)
  function new(string name = "srq_wdf_mon", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(SrqWdfItem) srq_wdf_ap;
  virtual SRQ_WDF_IF srq_wdf_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual SRQ_WDF_IF)::get(this, "", "srq_wdf_if", srq_wdf_if)) `uvm_fatal("MON", "Could not get srq_wdf_if")
    srq_wdf_ap = new ("srq_wdf_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      @(srq_wdf_if.cb) begin
        if ( srq_wdf_if.srq_wdf_rd ) begin
          SrqWdfItem item = SrqWdfItem::type_id::create("item");
          item.rd   = srq_wdf_if.srq_wdf_rd;
          item.rd_p = srq_wdf_if.srq_wdf_p;
          item.ptr  = srq_wdf_if.srq_wdf_ptr;
          srq_wdf_ap.write(item);
          $display("%0t: srq_wdf %s", $time, item.str());
        end
      end
    end

  endtask
endclass

class dfi_monitor extends uvm_monitor;
  `uvm_component_utils(dfi_monitor)

  function new(string name="dfi_monitor",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(DfiItem) dfi_ap;
  virtual DFI_IF dfi_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual DFI_IF)::get(this,"","dfi_if",dfi_if)) `uvm_fatal("MON", "Could not get dfi_if")
    dfi_ap = new ("dfi_ap",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      @(dfi_if.cb) begin
        if (dfi_if.srq_dfi_wr) begin
          DfiItem item = DfiItem::type_id::create("item");
          item.wr = 1;
          item.data = dfi_if.wdf_dfi_data;
          dfi_ap.write(item);
          $display("%0t: dfi wr %s", $time, item.str());
        end
      end
    end

  endtask
endclass

class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name = "gen_item_seq");
    super.new(name);
  endfunction

  rand int num;
  Item it;

  constraint c1 { soft num inside {[2:5]}; }

  virtual task body();
    for (int i = 0; i < num; i++ ) begin
      `uvm_do(it)
/*
      Item it = Item::type_id::create("it");
      start_item(it);
      assert(it.randomize());
      `uvm_info("SEQ", $sformatf("New item: %s", it.str()), UVM_HIGH)
      finish_item(it);
*/
    end
    //`uvm_info("SEQ", "Done", UVM_LOW)
  endtask

endclass

class driver extends uvm_driver #(Item);
  `uvm_component_utils(driver)
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual DL_IF dl_if;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("drv build");
    if (!uvm_config_db#(virtual DL_IF)::get(this, "", "dl_if", dl_if))
      `uvm_fatal("DRV", "Could not get dl_if")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      Item it;
      `uvm_info("DRV", "Waiting for item", UVM_HIGH)
      seq_item_port.get_next_item(it);
      drive_item(it);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_item(Item it);
    @(dl_if.cb) begin;
      dl_if.cb.dl_tl_cmd <= it.cmd;
      dl_if.cb.dl_tl_addr <= it.addr;
      dl_if.cb.dl_tl_data <= it.data;
      $display("%0t: DRV dl_tl %s", $time, it.str());
    end
    repeat(1) @ (posedge dl_if.clk);
    dl_if.cb.dl_tl_cmd <= 0;
    repeat(1) @ (posedge dl_if.clk);
  endtask

endclass



class WdfSb extends uvm_scoreboard;
  `uvm_component_utils(WdfSb)
  function new(string name="WdfSb", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  `uvm_analysis_imp_decl(_tl_wdf)
  uvm_analysis_imp_tl_wdf #(TlWdfItem, WdfSb) imp_tl_wdf;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp_tl_wdf = new("imp_tl_wdf",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  //function void write_dl_tl( Item it );
    //$display(" WdfSb: dl_tl %s",it.str());
  //endfunction
  function void write_tl_wdf( TlWdfItem it );
    $display(" WdfSb: tl_wdf %s",it.str());
  endfunction

  virtual function void check_phase(uvm_phase phase);
    //if ( writeQ.size() ) 
      //`uvm_error("SB_HANG","There are still writes in the Q")
  endfunction

endclass

class TlSb extends uvm_scoreboard;
  `uvm_component_utils(TlSb)
  function new(string name = "TlSb", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  Item writeQ[$];

  `uvm_analysis_imp_decl(_dl_tl)
  `uvm_analysis_imp_decl(_tl_wdf)
  uvm_analysis_imp_dl_tl  #(Item, TlSb) imp_dl_tl;
  uvm_analysis_imp_tl_wdf #(TlWdfItem, TlSb) imp_tl_wdf;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp_dl_tl  = new("imp_dl_tl",this);
    imp_tl_wdf = new("imp_tl_wdf",this);
    //if (!uvm_config_db#(bit[3:0])::get(this, "*", "ref_pattern", pattern))
      //`uvm_fatal("SB", "No ref_pattern")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function write_dl_tl(Item it);
    //$display("    SB: dl_tl  %s",it.str());
    if ( it.cmd == 1 ) writeQ.push_back(it);
  endfunction

  function void write_tl_wdf( TlWdfItem it );
    Item dlxac;
    $display(" TlSb: tl_wdf %s",it.str());
    if ( writeQ.size() == 0 ) begin
        `uvm_error("SB", "Saw tl_wdf with no matching dl_tl write")
        return;
    end
    dlxac = writeQ.pop_front();

  endfunction

  virtual function void check_phase(uvm_phase phase);
    if ( writeQ.size() ) 
      `uvm_error("SB_HANG","There are still writes in the Q")
  endfunction

/*
  virtual function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name != "run" ) return;
  
    if ( writeQ.size() ) begin
      phase.raise_objection(this);
      fork
        wait
    end
  endfunction
*/

endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  function new(string name="agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_sequencer #(Item) seq;
  driver drv;
  dl_monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("ag build");
    seq = uvm_sequencer#(Item)::type_id::create("seq",this);
    drv = driver::type_id::create("drv",this);
    mon = dl_monitor::type_id::create("mon",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seq.seq_item_export);
  endfunction


endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  function new( string name = "env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  agent ag;
  TlSb tl_sb;
  WdfSb wdf_sb;
  tl_wdf_monitor tl_wdf_mon;
  srq_wdf_monitor srq_wdf_mon;
  dfi_monitor dfi_mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag = agent::type_id::create("ag",this);
    tl_sb  = TlSb ::type_id::create("tl_sb",this);
    wdf_sb = WdfSb::type_id::create("wdf_sb",this);
    tl_wdf_mon = tl_wdf_monitor::type_id::create("tl_wdf_mon",this);
    srq_wdf_mon = srq_wdf_monitor::type_id::create("srq_wdf_mon",this);
    dfi_mon = dfi_monitor::type_id::create("dfi_mon",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ag.mon.dl_ap.connect(tl_sb.imp_dl_tl);
    tl_wdf_mon.tl_wdf_ap.connect(tl_sb.imp_tl_wdf);
    tl_wdf_mon.tl_wdf_ap.connect(wdf_sb.imp_tl_wdf);
  endfunction

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    //uvm_report_server rs = uvm_report_server::get_server();
    //$display(" DELME fatal %d eror %d", rs.get_severity_count(UVM_FATAL), rs.get_severity_count(UVM_ERROR));
  endfunction

endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new( string name="base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  env  test_env;
  //bit [3:0]       pattern = 4'b1011;
  gen_item_seq    seq;
  virtual DL_IF  dl_if;
  virtual TL_WDF_IF  tl_wdf_if;
  virtual SRQ_WDF_IF  srq_wdf_if;
  virtual DFI_IF  dfi_if;
  //dl_monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    test_env = env::type_id::create("env",this);

    if (!uvm_config_db#(virtual DL_IF)::get(this, "", "dl_if", dl_if)) `uvm_fatal("TEST", "Did not get dl_if")
    if (!uvm_config_db#(virtual TL_WDF_IF)::get(this, "", "tl_wdf_if", tl_wdf_if)) `uvm_fatal("TEST", "Did not get tl_wdf_if")
    if (!uvm_config_db#(virtual SRQ_WDF_IF)::get(this, "", "srq_wdf_if", srq_wdf_if)) `uvm_fatal("TEST", "Did not get srq_wdf_if")
    if (!uvm_config_db#(virtual DFI_IF)::get(this, "", "dfi_if", dfi_if)) `uvm_fatal("TEST", "Did not get dfi_if")
    uvm_config_db#(virtual DL_IF)::set(this, "env.ag.*", "dl_if", dl_if);
    uvm_config_db#(virtual TL_WDF_IF)::set(this, "env.*", "tl_wdf_if", tl_wdf_if);
    uvm_config_db#(virtual SRQ_WDF_IF)::set(this, "env.*", "srq_wdf_if", srq_wdf_if);
    uvm_config_db#(virtual DFI_IF)::set(this, "env.*", "dfi_if", dfi_if);

    //uvm_config_db#(bit[3:0])::set(this, "*", "ref_pattern", pattern);

    seq = gen_item_seq::type_id::create("seq");
    assert(seq.randomize() with { num inside {[1:5]}; });


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
    #400;
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    dl_if.rstn <= 0;
    repeat(5) @ (posedge dl_if.clk);
    dl_if.rstn <= 1;
    repeat(10) @ (posedge dl_if.clk);
  endtask

endclass
