
module shift_reg #(parameter N=4) ( input clk, rstn, d, en,
                                    output reg [N-1:0] out);

  always @(posedge clk) begin
    if ( !rstn ) 
      out <= 0;
    else begin
      if (en)   
        out <= { out[N-2:0],d };
      else
        out <= out;
    end
  end
endmodule

module tb;
  parameter N = 8;
  reg clk, rstn, d, en;
  logic [N-1:0] out;

  shift_reg #(.N(N)) sr(clk,rstn,d,en,out);

  always #5 clk = ~clk;

  initial begin
    clk = 0; rstn = 0; d = 0; en = 0;
    $monitor("%t out=%b", $time, out);

    #20 rstn = 1; en = 1;
    repeat (10) @(posedge clk)
      d = ~d;
    repeat (3) @(posedge clk)

    d = 1;

    #50 $finish;

  end
endmodule
