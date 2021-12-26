
module tb;
  reg wr,wr_p,rd,rd_p,clk,rstn;
  reg [2:0] wptr,rptr;
  reg [63:0] data, addr;

  MMIO mmio( clk,rstn, wr, addr,wptr,wr_p,data,rd,rd_p,rptr );

  always #5 clk = ~clk;

  //always @(posedge clk && rstn) $display("%t clk=%d rstn=%d",$time,clk,rstn);
  //assert property( @(posedge clk && rstn) !fir);

  always @(posedge wr) begin
    $display("%0t: wr=%d wptr=%d wr_p=%d addr=%0x",$time, wr, wptr, wr_p, addr);
  end

  initial begin
    { clk,rstn,wr,wr_p,wptr,data } <= 0;
    #10 rstn <= 1;
    $monitor("%0t: rd=%d, rd_p=%d, rptr=%0x", $time, rd,rd_p,rptr);
    #10 wr <= 1; wptr <= 0; wr_p <= 1; addr <= 1;
    #10 wr <= 0; wr_p <= 0;
    //#20 rd <= 1; rptr <= 0; rd_p <= 1;
    //#10 rd <= 0; rd_p <= 0;
    #100 $finish;
  end 

endmodule





