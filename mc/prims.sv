
module FIFO 
  #(parameter W=64,
    parameter AW=4) 
  ( input clk,rstn,wr,rd,
    input [W-1:0] din,
    output reg empty,
    output reg [W-1:0] dout);

  reg [W-1:0] q[2**(AW-1)];
  reg [AW:0] wptr,rptr;

  always @(negedge rstn) begin
    wptr = 0; rptr = 0;
    q = '{default:0};
  end

  always @(posedge clk) begin

      if (wr) begin
        q[wptr[AW-2:0]] = din;
        wptr = wptr + 1;          
      end
      if (rd) begin
        rptr = rptr + 1;
      end
     
  end

  assign dout = q[rptr[AW-2:0]];
  assign empty = rptr == wptr;

endmodule

/*
module tb;
  parameter W = 32;
  parameter AW = 4;

  reg clk,rstn,wr,rd;
  reg [W-1:0] wdata,rdata;

  FIFO #(.W(W),.AW(AW)) fifo(clk,rstn,wr,rd,wdata,rdata);

  always #5 clk = ~clk;

  initial begin
    {clk,rstn,wr,rd,wdata} <= 0;
    #20 rstn <= 1;
    $monitor("%0t: wr=%d wdata=%0x rd=%d rdata=%0x",$time, wr, wdata, rd, rdata);
    #10 wr <= 1; wdata <= 1;
    #10 wdata <= 2;
    #10 wdata <= 3;
    #10 wdata <= 4;
    #10 wr <= 0; rd <= 1;
    #10;
    #10;
    #10;
    #10 rd <= 0;
    #100 $finish;
  end

  
endmodule


*/
