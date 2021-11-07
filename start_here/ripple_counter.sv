

module dff ( input clk, rstn, d,
             output reg q,
             output qn);
  always @(posedge clk or negedge rstn) begin
    if (!rstn) q <= 0;
    else       q <= d;
  end
  assign qn = ~q;
endmodule

module rip #(parameter N=4) ( input clk, rstn, 
            output [N-1:0] out );
  logic [N-1:0] q, qn;

  dff d0 ( clk,  rstn, qn[0], q[0],qn[0] );
  genvar i;
  generate
    for (i=1; i<N; i=i+1) begin
      dff d1 ( q[i-1], rstn, qn[i], q[i],qn[i] );
    end
  endgenerate

  assign out = qn;
endmodule

module tb;
  parameter N=3;
  reg clk, rstn;
  reg [N-1:0] q;

  always #5 clk = ~clk;
  
  rip #(.N(N)) rip( clk, rstn, q );

  initial begin
    clk = 0; rstn = 0;
    $monitor("%t q=%d", $time, q);
    #20 rstn = 1;
    #200 $finish;
  end
endmodule

