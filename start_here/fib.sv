


module fib( input clk,rstn,
            input [7:0] n,
            output reg done,
            output [15:0] out );
  reg [15:0] prev,cur;
  reg [5:0] cnt;

  always @(negedge rstn) begin
    cnt  <= 1;
    prev <= 0;
    cur  <= 1;    
    done <= 0;
  end  

  always @(posedge clk) begin
    if (!done) begin
      cnt  <= cnt + 1;
      cur  <= cur + prev;
      prev <= cur; 

      if ( cnt == n-2 ) 
        done <= 1;
    end
  end

  assign out = cur;

endmodule

module tb;
  reg clk, rstn;
  reg [7:0] n;
  logic done;
  logic [15:0] out;

  always #5 clk = ~clk;

  fib fib(clk,rstn,n,done,out);

  initial begin
    clk = 0; rstn = 0; n = 0;
    $monitor("%t done=%d val=%d", $time, done, out);
    #20 rstn = 1; n = 5;
    #200 rstn = 0;
    #20 rstn = 1; n = 8;
    #200 $finish;
  end

endmodule


