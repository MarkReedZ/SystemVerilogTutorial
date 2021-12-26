

module TL(input clk,rstn,
          input [1:0]  dl_tl_cmd,
          input [63:0] dl_tl_addr, 
          input [63:0] dl_tl_data,
          output reg tlxr_srq_wr,
          output reg tlxr_srq_wr_p,
          output reg [2:0] tlxr_srq_ptr,
          output reg [63:0] tlxr_srq_addr,
          output reg tlxr_wdf_wr,
          output reg tlxr_wdf_wr_p,
          output reg [2:0] tlxr_wdf_ptr,
          output reg [63:0] tlxr_wdf_data);

  reg [2:0] wptr,nptr;
  //reg tlxr_mmio_wr;
  //reg [63:0] tlxr_mmio_addr;
  //reg [2:0] tlxr_mmio_wptr;
  //reg tlxr_mmio_wr_p;
  reg wr;
  reg [63:0] addr;
  reg [63:0] data;

  always @(posedge clk) begin
    wr <= (dl_tl_cmd==1);
    if ( dl_tl_cmd == 1 ) begin // Write
      wptr <= nptr;
      nptr = nptr + 1;
      data <= dl_tl_data;
      addr <= dl_tl_addr;
    end

    tlxr_srq_wr <= wr;
    tlxr_srq_ptr <= wptr;
    tlxr_srq_addr <= addr;
    
    tlxr_wdf_wr <= wr;
    tlxr_wdf_ptr <= wptr;
    tlxr_wdf_data <= data;
    tlxr_wdf_wr_p <= ^{tlxr_wdf_wr, tlxr_wdf_ptr};
    // Write to memory
    //if ( dl_tl_cmd == 1 ) begin
      
    //end 
  end

  always @(negedge rstn) begin
    wptr = 1; nptr = 1;
  end

endmodule

