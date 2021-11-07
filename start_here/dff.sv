

module dff (input clk, rstn, d,
            output reg q);
  always @(posedge clk or negedge rstn) begin
    if (!rstn) q <= 0;
    else       q <= d; 
  end
endmodule

module tb;
  reg clk, rstn, d;
  logic q;

  dff dff (clk,rstn,d,q);
  
  always #5 clk = ~clk;

  initial begin
    clk = 0; rstn = 0; d = 0;
    $monitor("%t d=%d q=%d", $time, d, q);
    #20 rstn = 1;
    #10 d = 0;
    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
    #10 d = 0;

    #50 $finish;
  end
endmodule
