

module tb;
  reg wr,wr_p,rd,rd_p,clk,rstn;
  reg [2:0] wptr,rptr;
  reg [63:0] data;
  wire fir;
  wire [63:0] dfi_data;

  WDF wdf( clk,rstn,wr,wr_p,wptr,data,rd,rptr,rd_p,fir,dfi_data );

  always #5 clk = ~clk;

  //always @(posedge clk && rstn) $display("%t clk=%d rstn=%d",$time,clk,rstn);
  assert property( @(posedge clk && rstn) !fir);

  always @(posedge wr) begin
    $display("%0t: wr=%d wptr=%d wr_p=%d data=%0x",$time, wr, wptr, wr_p, data);
  end
  always @(posedge clk && rd) begin
    $display("%0t: rd=%d rptr=%d rd_p=%d data=%0x",$time, rd, rptr, rd_p, dfi_data);
  end

  initial begin
    { clk,rstn,wr,wr_p,wptr,data,rd,rptr,rd_p } <= 0;
    #10 rstn <= 1;
    $monitor("%0t: dfi_data=%0x", $time, dfi_data);
    #10 wr <= 1; wptr <= 0; wr_p <= 1; data <= $urandom();
    #10 wr <= 0; wr_p <= 0;
    #20 rd <= 1; rptr <= 0; rd_p <= 1;
    #10 rd <= 0; rd_p <= 0;
    #100 $finish;
  end 

endmodule

