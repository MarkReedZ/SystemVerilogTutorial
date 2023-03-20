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
