
module TOP (input clk,rstn,
            input [1:0] dl_tl_cmd,
            input [63:0] dl_tl_addr,
            input [63:0] dl_tl_data);

  reg tlxr_mmio_wr;
  reg [63:0] tlxr_mmio_addr;
  reg [2:0] tlxr_mmio_wptr;
  reg tlxr_mmio_wr_p;

  reg [63:0] wdf_mmio_data;
  reg mmio_wdf_rd;
  reg mmio_wdf_rd_p;
  reg [2:0] mmio_wdf_rptr;

  reg tlxr_srq_wr,tlxr_srq_wr_p;
  reg [2:0] tlxr_srq_ptr;
  reg [63:0] tlxr_srq_addr;

  reg srq_wdf_rd;
  reg [2:0] srq_wdf_ptr;
  reg srq_wdf_p;

  reg tlxr_wdf_wr,tlxr_wdf_wr_p;
  reg [2:0] tlxr_wdf_ptr;
  reg [63:0] tlxr_wdf_data;

  reg srq_dfi_wr;
  reg [63:0] wdf_dfi_data;
  
  MMIO mmio(clk,rstn, tlxr_mmio_wr, tlxr_mmio_addr, tlxr_mmio_wptr, tlxr_mmio_wr_p, wdf_mmio_data, mmio_wdf_rd, mmio_wdf_rd_p, mmio_wdf_rptr);
  WDF  wdf(clk,rstn, tlxr_wdf_wr, tlxr_wdf_wr_p, tlxr_wdf_ptr, tlxr_wdf_data, srq_wdf_rd, srq_wdf_ptr, srq_wdf_p, mmio_wdf_rd, mmio_wdf_rptr, mmio_wdf_rd_p, wdf_mmio_data, wdf_dfi_data);
  TL   tl(clk, rstn, dl_tl_cmd, dl_tl_addr, dl_tl_data, tlxr_srq_wr,tlxr_srq_wr_p, tlxr_srq_ptr, tlxr_srq_addr, tlxr_wdf_wr, tlxr_wdf_wr_p, tlxr_wdf_ptr, tlxr_wdf_data );
  SRQ  srq(clk,rstn, tlxr_srq_wr,tlxr_srq_wr_p,tlxr_srq_ptr,tlxr_srq_addr,srq_dfi_wr,srq_wdf_rd,srq_wdf_ptr,srq_wdf_p);




endmodule


