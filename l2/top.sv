
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


`include "intf.sv"
`include "transactions.sv"
`include "monitors.sv"
`include "agents.sv"

`include "sb.sv"

`include "env.sv"
`include "test.sv"
