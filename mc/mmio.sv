
module MMIO ( input clk,rstn, 
            input tlxr_mmio_wr,
            input [63:0] tlxr_mmio_addr,
            input [2:0] tlxr_mmio_wptr,
            input tlxr_mmio_wr_p,
            input [63:0] wdf_mmio_data,
            output reg mmio_wdf_rd,
            output reg mmio_wdf_rd_p,
            output reg [2:0] mmio_wdf_rptr);

  reg tlxr_mmio_perr;

  reg [63:0] wdf_cfg;
  parameter FIFO_WIDTH=8;
  parameter FIFO_AW=4;

  reg fifo_wr,fifo_rd, fifo_empty;
  reg [FIFO_WIDTH-1:0] fifo_din,fifo_dout;

  FIFO #(.W(FIFO_WIDTH),.AW(FIFO_AW)) fifo(clk,rstn,fifo_wr,fifo_rd,fifo_din, fifo_empty,fifo_dout);

  initial begin
    wdf_cfg = { 3'd3, 61'd0 };
  end

  //assert property( @(posedge clk) tlxr_wdf_wrbuf_wr |=> !tlxr_wdf_wrbuf_wr);
  //assert property( @(posedge clk && rstn) ~^{tlxr_wdf_wrbuf_wr,tlxr_wdf_wrbuf_wr_p, tlxr_wdf_wrbuf_ptr});

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      {mmio_wdf_rd,mmio_wdf_rptr, mmio_wdf_rd_p} <= 0;
    end
    tlxr_mmio_perr = ^{tlxr_mmio_wr, tlxr_mmio_wptr, tlxr_mmio_wr_p};

    //$display("wr=%d",tlxr_wdf_wrbuf_wr);

  end

  always @(*) begin
  //always @(tlxr_mmio_wr && !rstn) begin
    $display("%0t: wr=%d fifo_din=%0x", $time, tlxr_mmio_wr, fifo_din);
    fifo_wr = tlxr_mmio_wr; fifo_din = { tlxr_mmio_addr[3:0], tlxr_mmio_wptr };
    mmio_wdf_rd = tlxr_mmio_wr;
    mmio_wdf_rptr = tlxr_mmio_wptr;
    mmio_wdf_rd_p = ~^{ tlxr_mmio_wr, tlxr_mmio_wptr };
  end


endmodule

/*
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
*/




