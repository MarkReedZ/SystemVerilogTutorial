# SystemVerilogTutorial


```
module FIFO (input clk,rstn, wr, rd,
             input [7:0] din,
             output [7:0] dout,
             output full, empty );
  reg [2:0] wptr, rptr;
  reg [7:0] mem[8];
  integer count;
  logic inc_rd;
  
  always @(negedge rstn) begin
    for (count=0; count<8; count++) mem[count] = 0;
    count = 0; wptr = 0; rptr = 0;
  end

  always @(posedge clk) begin
    //if ( inc_rd ) 
      //rptr = rptr + 1;
    if (wr && count < 8) begin
      count = count + 1;
      mem[wptr] = din;
      $display("%4t: wr di=%02x", $time, din);
      wptr = wptr + 1;
    end
    if (rd && (count>0)) begin
      count = count - 1;
      //inc_rd = 1;
      rptr = rptr + 1;
      $display("%4t: rd do=%02x", $time, mem[rptr-1]);
    end //else 
      //inc_rd = 0;
  end
  
  assign dout = rd ? mem[rptr-1] : 'hz;
  assign full = count==8;
  assign empty = count==0;
  
endmodule
```
