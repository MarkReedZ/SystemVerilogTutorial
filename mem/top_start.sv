
`include "uvm_macros.svh"
import uvm_pkg::*;

module tb;
  reg clk;
  parameter AW=4;
  parameter DW=16;

  MEM #(.AW

  always #5 clk = ~clk;

  
endmodule;

interface
endinterface

class Item
endclass

class seq extends uvm_sequence;
endclass

class driver extends uvm_driver #(Item);
endclass

class monitor extends uvm_monitor;
endclass;

class sb extends uvm_scoreboard;
endclass

class agent extends uvm_agent;
endclass

class env extends uvm_env;
endclass

class base_test extends uvm_test;
endclass


