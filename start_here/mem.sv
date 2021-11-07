module MEM 
  # (parameter AW=4,
     parameter DW=32,
     parameter N=16)
  ( input clk,cs,we,re,
    input [AW-1:0] addr,
   input [DW-1:0] wdata,
   output [DW-1:0] rdata );

  reg [DW-1:0] tmp;
  reg [DW-1:0] mem [N];
  

  always @(posedge clk) begin
    if (cs & we) begin
      mem[addr] = wdata;
    end
  end
  
  assign rdata = (cs & re & !we) ? mem[addr] : 'hz;

endmodule

module tb;
  parameter AW=2;
  parameter DW=8;
  parameter N=16;

  reg clk,cs,we,re;
  reg [AW-1:0] addr;
  wire [DW-1:0] data;
  reg [DW-1:0] wdata;
  integer i;

  MEM #( .AW(AW), .DW(DW), .N(N) ) mem( clk,cs,we,re,addr,wdata,data );

  always #5 clk = ~clk;
  assign data = !re ? wdata : 'hz;
  

  initial begin
    {clk,cs,we,re,addr,wdata} <= 0;
    repeat (2) @(posedge clk);
    cs <= 1;
    $monitor("%t a=%d we=%d re=%d wdata=%h rdata=%h m0=%h",$time, addr, we,re, wdata, data, mem.mem[0] ); 

    for (i=0; i< 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 1; cs <= 1; re <= 0; wdata <= $random;
    end
    for (i=0; i< 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 0; cs <= 1; re <= 1; 
    end
   
  #20 $finish; 
  end  

endmodule
