
module tb;
  reg clk,rstn,req,ack;

  always #5 clk = ~clk;

  //default disable iff (!rstn);
    //assert property(@(posedge clk) !rstn |-> !req);
    assert property(@(posedge clk) !rstn |-> !{req,ack});

    assert property(@(posedge clk) req |-> req[*1:$] ##0 ack ##1 !req)
         $display("    req held until ack then dropped!");
      else $error("    req must hold until ack then drop for at least 1 cycle");
    assert property(@(posedge clk) ack |=> !ack)
      else $error("    ack on for more than one cycle");
    assert property(@(posedge clk) !req |-> !ack)
      else $error("    ack on without req");

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
    {clk,rstn,req,ack} <= 0;
    $monitor("clk=%0d req=%0d ack=%0d",clk,req,ack);



    rstn <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); rstn <= 0;
    @(posedge clk); req <= 1;
    @(posedge clk); 
    @(posedge clk); 
    @(posedge clk); 
    @(posedge clk); req <= 1; ack <= 1;
    @(posedge clk); {ack,req} <= 0;
    @(posedge clk);
    @(posedge clk); req <= 1;
    @(posedge clk); ack <= 1;
    @(posedge clk); {ack,req} <= 0;
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule

