
module MEM #(parameter AW=4,
             parameter DW=32 )
  ( input clk, wr, rd,
    input [AW-1:0] addr,
    input [DW-1:0] wdata,
    output [DW-1:0] rdata );

  reg [DW-1:0] mem [2**AW];

  always @(posedge clk) begin
    if (wr)
      mem[addr] = wdata;
  end

  assign rdata = (rd & !wr) ? mem[addr] : 'hz;

endmodule

module tb;

  parameter AW=4;
  parameter DW=16;
  parameter N=2**AW;

  reg clk,wr,rd;
  reg [AW-1:0] addr;
  wire [DW-1:0] rdata;
  reg [DW-1:0] wdata;
  integer i;

  MEM #(.AW(AW), .DW(DW)) mem(clk,wr,rd,addr,wdata,rdata);
  
  always #5 clk = ~clk;

  initial begin
    {clk,wr,rd,addr,wdata} <= 0;
    #20;
    $monitor("%t a=%d wdata=%h rdata=%h wr=%d rd=%d", $time, addr,wdata,rdata,wr,rd);

    for(i=0; i < 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; wr <= 1; wdata <=$random;
    end
    for(i=0; i < 2**AW; i=i+1) begin
      repeat (1) @(posedge clk) addr <= i; wr <= 0; rd <= 1; 
    end
    #100 $finish;    
    
  end 
endmodule
