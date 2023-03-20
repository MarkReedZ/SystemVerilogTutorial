
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

