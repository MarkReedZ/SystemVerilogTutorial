
module tb;
  reg clk,rstn,a,done, start;

  always #5 clk = ~clk;

  default disable iff (!rstn);

  sequence s1;
    a ##1 a ##1 !a ##1 !a;
  endsequence

  assert property( @(posedge clk) start |=> s1[*5:20] ##1 done );
  //assert property( @(posedge clk) $rose(a) |-> (a ##1 a ##1 !a ##1 !a)[*20] );

/*
sequence burst_rule;
  @(posedge clk)
    $fell(burst_mode) ##0
    ((!burst_mode) throughout (##2 ((trdy==0)&&(irdy==0)) [*7]));
endsequence

 !trdy[*7] within ($fell(irdy) ##1 !idy[*8])

|-> implies
#-# followed by
*/
  initial begin
    {clk,rstn,a,start,done} <= 0;
    $monitor("%03t: start=%0d a=%0d end=%0d",$time, start, a, done );

    #10 rstn <= 1; 
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    repeat (18) begin
      a <= 1; 
      @(posedge clk); @(posedge clk);
      a <= 0;
      @(posedge clk); @(posedge clk);
    end
    done <= 1;
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule

