

module SRQ ( input clk,rstn,
            input tlxr_srq_wr,
            input tlxr_srq_wr_p,
            input [2:0] tlxr_srq_ptr,
            input [63:0] tlxr_srq_addr,
            output reg srq_dfi_wr,
            output reg srq_wdf_rd,
            output reg [2:0] srq_wdf_ptr,
            output srq_wdf_p );

  parameter FIFO_WIDTH=80;
  parameter FIFO_AW=4;

  int busy;

  reg fifo_wr,fifo_rd, fifo_empty;
  reg [FIFO_WIDTH-1:0] fifo_din,fifo_dout;
  reg wdf_rd;
  reg [7:0] dfi_wr_delay;

  FIFO #(.W(FIFO_WIDTH),.AW(FIFO_AW)) fifo(clk,rstn,fifo_wr,fifo_rd,fifo_din,fifo_empty, fifo_dout);

  always @(posedge clk) begin

    fifo_wr = tlxr_srq_wr; fifo_din = { tlxr_srq_addr, tlxr_srq_ptr };
    if ( fifo_wr ) 
      $display("%0t: SRQ wr=%d fifo_din=%0x", $time, fifo_wr, fifo_din);

    if ( busy ) busy = busy - 1;

    wdf_rd <= !fifo_empty && !busy;
    fifo_rd <= !fifo_empty && !busy;
    srq_wdf_rd <= wdf_rd;
    dfi_wr_delay[3] = wdf_rd;
    if (wdf_rd) srq_wdf_ptr <= fifo_dout[2:0];

    if ( !fifo_empty && !busy ) begin
      busy = 8;
    end

    dfi_wr_delay >>= 1;

    //$display("%0t: SRQ busy %d empty %d", $time, busy, fifo_empty );
  end
  always @(negedge rstn) begin
    busy = 30; wdf_rd = 0;
    dfi_wr_delay = '0;
  end

  assign srq_dfi_wr = dfi_wr_delay[0];

endmodule

