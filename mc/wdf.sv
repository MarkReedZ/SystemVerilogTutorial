
module WDF ( input clk,rstn, 
            input tlxr_wdf_wr,
            input tlxr_wdf_wr_p,
            input [2:0] tlxr_wdf_ptr,
            input [63:0] tlxr_wdf_data,
            input srq_wdf_rd,
            input [2:0] srq_wdf_ptr,
            input srq_wdf_p,
            input mmio_wdf_rd,
            input [2:0] mmio_wdf_rptr,
            input mmio_wdf_rd_p,
            output [63:0] wdf_mmio_data,
            output [63:0] wdf_dfi_data);

  reg tlxr_wdf_perr, srq_wdf_perr;

  reg [63:0] cfg,wdelay,mmio_wdelay;

  reg [63:0] wbuf[8];

  initial begin
    cfg = { 3'd3, 61'd0 };
  end

  assert property( @(posedge clk) tlxr_wdf_wr |=> !tlxr_wdf_wr);

  assert property( @(posedge clk && rstn) ~^{tlxr_wdf_wr,tlxr_wdf_wr_p, tlxr_wdf_ptr});

  always @(negedge rstn) begin
    wdelay = '0;
  end
  always @(posedge clk) begin
    tlxr_wdf_perr = ^{tlxr_wdf_wr, tlxr_wdf_wr_p, tlxr_wdf_ptr};
    srq_wdf_perr = ^{srq_wdf_rd, srq_wdf_p, srq_wdf_ptr};

    wdelay[ 59:0 ] = wdelay [63:4];
    if ( wdelay[3] ) begin
      $display("%0t: wdf_dfi_data=%0x",$time,wdf_dfi_data);
    end
    if ( wdf_dfi_data != 0 ) begin
      $display("%0t: wdf_dfi_data=%0x",$time,wdf_dfi_data);
    end

  end

  always @(posedge clk && tlxr_wdf_wr) begin
    wbuf[ tlxr_wdf_ptr ] = tlxr_wdf_data;  
  end

  always @(posedge clk && srq_wdf_rd) begin
    wdelay[ 11:8 ] = {1'b1, srq_wdf_ptr};
  end
  always @(posedge clk && mmio_wdf_rd) begin
    mmio_wdelay[ 11:8 ] = {1'b1, mmio_wdf_rptr};
  end

  assign fir = tlxr_wdf_perr | srq_wdf_perr;
  assign wdf_dfi_data = wdelay[3] ? wbuf[wdelay[2:0]] : '0;
  assign wdf_mmio_data = mmio_wdelay[3] ? wbuf[mmio_wdelay[2:0]] : 0;
  
endmodule

/*
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

*/



