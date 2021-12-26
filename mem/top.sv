
`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;
  reg clk;
  parameter AW=4;
  parameter DW=16;

  IF_MEM vif (clk);

  MEM #(.AW(AW), .DW(DW)) mem(clk,mif.wr,mif.rd,mif.addr,mif.wdata,mif.rdata);
  
  always #5 clk = ~clk;

  initial begin
    clk <= 0;
    uvm_config_db#(virtual IF_MEM)::set(null,"top","vif", vif);
    start_test("base_test");
  end

  
endmodule;

interface IF_MEM (input clk);
  logic wr,rd;
  logic [tb.AW-1:0] addr;
  logic [tb.DW-1:0] wdata,rdata;


endinterface

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new (string name="monitor", uvm_component parent = null);
    super.new(name,parent);
  endfunction

endclass;

class Item
endclass

class seq extends uvm_sequence;
endclass

class driver extends uvm_driver #(Item);
endclass


class sb extends uvm_scoreboard;
endclass

class agent extends uvm_agent;
endclass

class env extends uvm_env;
endclass

class base_test extends uvm_test;
endclass


