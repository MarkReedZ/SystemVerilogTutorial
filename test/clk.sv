
module tb;
  reg [2:0] state;
  reg clk, div2, div3;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    div2 <= ~div2;
  end
  always @(posedge clk or negedge clk) begin
    if (state == 3 ) begin
      div3 <= ~div3;
      state = 0;
    end;

    state = state + 1;
  end

  initial begin
    { clk, div2, div3, state } = 0;
    $monitor("clk=%d d2=%d d3=%d", clk,div2,div3);
    #100 $finish;
  end
endmodule
