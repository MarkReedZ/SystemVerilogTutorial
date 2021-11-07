
module MEM 
  # (parameter AW=4,
     parameter DW=32,
     parameter N=16)
  ( input clk,cs,we,re,
    input [AW-1:0] addr,
    inout [DW-1:0] data );

  reg [DW-1:0] tmp;
  reg [DW-1:0] mem [N];
  
  assign data = (cs & re & !we) ? mem[addr] : 1'bz;

  always @(cs or we) begin
    if (cs & we) begin
      mem[addr] = data;
      $display("YAY a=%d mem=%h %h", addr, mem[addr], data);
    end
  end

endmodule

module tb;
  parameter AW=2;
  parameter DW=8;
  parameter N=16;

  reg clk,cs,we,re;
  reg [AW-1:0] addr;
  wire [DW-1:0] data;
  reg [DW-1:0] wdata;

  MEM #( .AW(AW), .DW(DW), .N(N) ) mem( clk,cs,we,re,addr,data );

  always #5 clk = ~clk;

  initial begin
    {clk,cs,we,re,addr,wdata} <= 0;
    repeat (2) @(posedge clk);
    cs <= 1;
    $monitor("%t a=%d we=%d re=%d wdata=%h rdata=%h m0=%h",$time, addr, we,re, wdata, data, mem.mem[0] ); 

    for (integer i=0; i< 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 1; cs <= 1; re <= 0; wdata <= $random;
      repeat (1) @(posedge clk) cs <= 0;
    end
    for (integer i=0; i< 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 0; cs <= 1; re <= 1; 
    end
   
  #20 $finish; 
  end  

endmodule
