
`include "enums.svh"

class Entry;
  bit [7:0] own;
  bit ex;
  bit dirty;
  bit [31:0] data;

  function new();
    {own, ex, dirty, data} = 0;
  endfunction
endclass

class MemXac;
  int core;
  int cmd;
  bit [31:0] data;
  bit [31:0] addr;

  function new();
    {core,cmd,data,addr} = 0;
  endfunction
  function void copy(MemXac rhs);
    this.core = rhs.core;
    this.cmd  = rhs.cmd;
    this.data = rhs.data;
    this.addr = rhs.addr;
  endfunction
  virtual function MemXac clone();
    clone = new();
    clone.copy(this);
  endfunction
endclass

module L2 
  ( input rstn, clk, 

    // 8 Cores
    input [7:0] vld,
    input [7:0][2:0] cmd,
    input [7:0][31:0] addr,
    input [7:0][31:0] wdata,
    // 8 Cores
    output reg [7:0]       resp_vld,
    output reg [7:0][2:0]  resp,
    output reg [7:0][31:0] rdata,
    // Memory
    input m_rsp_vld,
    input [31:0] m_rsp_data,

    output reg mvld,
    output reg mcmd,
    output reg [31:0] maddr,
    output reg [31:0] mdata
  );

  int cur, free, num;

  // RefMdl
  Entry map [int];

  // Memory
  MemXac mem_out[$];
  MemXac mem_resp[$];

  // Invalidates
  int inv_cores[8][$]; // Addresses of invalidates we need to send out

  always @(posedge clk) begin
    if ( !rstn ) begin
      free = 8; 
      cur = 0;
      {mvld,mcmd} = 0;
    end
    resp_vld <= 0; 

    // Handle incoming cmds
    foreach ( vld[i] ) begin
      if (vld[i] === 1) begin
        case (cmd[i])
          READSHARED: read_shared(i);
          READUNIQUE: read_unique(i);
        endcase
      end 
    end

    // Handle mem responses
    if ( m_rsp_vld == 1 ) 
      handle_mem_resp();

    // Send out mem cmds
    if ( mem_out.size() > 0 ) begin
      send_mem_cmd();
    end else begin
      mvld <= 0;
    end

    // Send out invalidates if the response bus to the core is free
    foreach( inv_cores[c] ) begin
      int adr;
      if ( inv_cores[c].size() > 0 ) begin
        if ( resp_vld[c] == 0 ) begin
          adr = inv_cores[c].pop_front();
          resp_vld[c] <= 1;
          resp[c]     <= INVALIDATE;
          rdata[c]    <= adr; // Send the addr on the data bus
        end
      end
    end
    
  end

  task read_shared(int c);
    int adr;
    MemXac mx;
    adr  = addr[c];

    if ( map.exists(adr) ) begin
      resp_vld[c] <= 1; resp[c] <= READDATA; rdata[c] <= map[adr].data;

      // If a core has the line EX we have to invalidate
      if ( map[adr].ex == 1 ) begin
        foreach( map[adr].own[i] ) begin
          if ( map[adr].own[i] == 1 && i != c ) 
            inv_cores[i].push_back( adr ); 
        end
        map[adr].ex = 0;
      end

      map[adr].own[c] = 1;
    end else begin
      if ( num < 99999 ) begin // TODO Handle L2 castouts

        mx = new();
        mx.core = c;
        mx.cmd = 0;
        mx.addr = adr;
        mem_out.push_back( mx );

      end else begin
        // Evict
        $display("TODO evict");
      end
    end
  endtask

  task send_mem_cmd();
    MemXac mx;
    mx = mem_out.pop_front();
    mem_resp.push_back(mx);
    mvld <= 1;
    mcmd <= mx.cmd;
    maddr <= mx.addr;
  endtask

  task handle_mem_resp();
    MemXac mx;
    mx = mem_resp.pop_front();

    map[mx.addr] = new();
    map[mx.addr].own = 0; 
    map[mx.addr].own[mx.core] = 1;
    map[mx.addr].data = m_rsp_data;
    num = num + 1;

    resp_vld[mx.core]   <= 1;
    resp[mx.core]   <= READDATA;
    rdata[mx.core] <= m_rsp_data;
    //$display("%0t: setting resp vld for core %0d", $time, mx.core);

    //$display("DELME m rsp data %0h map data %0h", m_rsp_data, map[mx.addr].data);
    
  endtask

  task read_unique(int c);
    int adr;
    MemXac mx;
    adr  = addr[c];

    // TODO This can't go back until all other cores are invalidated
    if ( map.exists(adr) ) begin
      resp_vld[c] <= 1; resp[c] <= READDATA; rdata[c] <= map[adr].data;

      foreach( map[adr].own[i] ) begin
        if ( map[adr].own[i] == 1 && i != c ) 
          inv_cores[i].push_back( adr ); 
      end
      map[adr].own = 0;
      map[adr].ex = 1;
      map[adr].own[c] = 1;
      
    end else begin
      if ( num < 99999 ) begin // TODO Handle L2 castouts

        mx = new();
        mx.core = c;
        mx.cmd = 0;
        mx.addr = adr;
        mem_out.push_back( mx );

      end else begin
        // Evict
        $display("TODO evict");
      end
    end

  endtask

endmodule

/*
        if ( free > 0 ) begin
          mem[addr] = wdata;
          addr_valid[addr] = 1;
          addrs[ cur ] = addr;
          vlds[ cur ] = 1;
          cur = (cur+1) % N;
          free = free - 1;
          $display(" free is now %d", free);
        end else begin
          mem[addr] = wdata;
          addr_valid[addr] = 1;
          addr_valid[ addrs[cur] ] = 0; // LRU
          addrs[ cur ] = addr;
          vlds[ cur ] = 1;
          cur = (cur+1) % N;
          $display(" free %d cur %d", free, cur);
        end
*/
