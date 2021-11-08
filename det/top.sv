
`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;
  reg clk;

  always #10 clk = ~clk;

  dut_if _if (clk);

  detector dut ( .clk(clk),
                 .rstn(_if.rstn),
                 .in(_if.in),
                 .out(_if.out) );

  initial begin
    clk <= 0;
    uvm_config_db#(virtual dut_if)::set(null, "uvm_test_top", "dut_vif", _if);
    run_test("base_test");
  end
endmodule

interface dut_if (input bit clk);
  logic rstn;
  logic in;
  logic out;

  clocking cb @(posedge clk);
    default input #1step output #3ns;
      input out;
      output in;
  endclocking
endinterface

class Item extends uvm_sequence_item;
  `uvm_object_utils(Item)
  rand bit  in;
  bit       out;

  virtual function string str();
    return $sformatf("in=%0d, out=%0d", in, out);
  endfunction

  function new(string name = "Item");
    super.new(name);
  endfunction

  constraint c1 { in dist {0:/20, 1:/80}; }
endclass


class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name = "gen_item_seq");
    super.new(name);
  endfunction

  rand int num;

  constraint c1 { soft num inside {[10:20]}; }

  virtual task body();
    for (int i = 0; i < num; i++ ) begin
      Item it = Item::type_id::create("it");
      start_item(it);
      assert(it.randomize());
      `uvm_info("SEQ", $sformatf("New item: %s", it.str()), UVM_HIGH)
      finish_item(it);
    end
    `uvm_info("SEQ", "Done", UVM_LOW)
  endtask

endclass


class driver extends uvm_driver #(Item);
  `uvm_component_utils(driver)
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual dut_if vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
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
    @(vif.cb) begin;
      vif.cb.in <= it.in;
    end
  endtask

endclass 

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  function new(string name = "mon", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_analysis_port #(Item) mon_ap;
  virtual dut_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", vif))
      `uvm_fatal("MON", "Could not get vif")
    mon_ap = new ("mon_ap",this);
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(vif.cb) begin
        if (vif.rstn) begin
          Item item = Item::type_id::create("item");
          item.in = vif.in;
          item.out = vif.cb.out;
          mon_ap.write(item);
          `uvm_info("MON", $sformatf("Saw item %s", item.str()), UVM_HIGH) 
        end
      end
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name = "scoreboard", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  bit[3:0]  pattern;
  bit[3:0]  act;
  bit       exp;

  uvm_analysis_imp #(Item, scoreboard) imp;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp",this);
    if (!uvm_config_db#(bit[3:0])::get(this, "*", "ref_pattern", pattern))
      `uvm_fatal("SB", "No ref_pattern")
  endfunction

  virtual function write(Item it);
    act = act << 1 | it.in;
    `uvm_info("SB", $sformatf("in=%0d out=%0d exp=0b%0b act=0b%0b", it.in, it.out, exp, act), UVM_LOW)
    if ( it.out != exp ) begin
      `uvm_error("SB", $sformatf("ERROR act=%0d exp=%0d", it.out, exp))
    end else begin
      `uvm_info("SB", $sformatf("PASS act=%0d exp=%0d", it.out, exp),UVM_HIGH)
    end

    if ( !(pattern ^ act) ) begin
      `uvm_info("SB", $sformatf("Pattern found so expect 1"),UVM_LOW)
      exp = 1;
    end else begin
      `uvm_info("SB", $sformatf("Pattern not found so expect 0"),UVM_LOW)
      exp = 0;
    end
  endfunction
  
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  function new(string name="agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  uvm_sequencer #(Item) seq;
  driver drv;
  monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = uvm_sequencer#(Item)::type_id::create("seq",this);
    drv = driver::type_id::create("drv",this);
    mon = monitor::type_id::create("mon",this);
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
  scoreboard sb;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag = agent::type_id::create("ag",this);
    sb = scoreboard::type_id::create("sb",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ag.mon.mon_ap.connect(sb.imp);
  endfunction

endclass



class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new( string name="base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  env  test_env;
  bit [3:0]       pattern = 4'b1011;
  gen_item_seq    seq;  
  virtual dut_if  vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    test_env = env::type_id::create("test_env",this);

    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", vif))
      `uvm_fatal("TEST", "Did not get vif")
    uvm_config_db#(virtual dut_if)::set(this, "test_env.ag.*", "dut_vif", vif);

    uvm_config_db#(bit[3:0])::set(this, "*", "ref_pattern", pattern);

    seq = gen_item_seq::type_id::create("seq");
    assert(seq.randomize() with { num inside {[100:200]}; });

    pattern = 4'b1011;

  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apply_reset();
    seq.start(test_env.ag.seq);
    #200;
    phase.drop_objection(this);
  endtask

  virtual task apply_reset();
    vif.rstn <= 0;
    vif.in <= 0;
    repeat(5) @ (posedge vif.clk);
    vif.rstn <= 1;
    repeat(10) @ (posedge vif.clk);
  endtask

endclass

















 

