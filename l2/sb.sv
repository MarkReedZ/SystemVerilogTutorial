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
