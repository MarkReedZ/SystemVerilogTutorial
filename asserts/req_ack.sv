
module tb;
  reg clk,rstn,req,ack;

  always #5 clk = ~clk;

  //default disable iff (!rstn);
    //assert property(@(posedge clk) !rstn |-> !req);
    //assert property(@(posedge clk) !rstn |-> !{req,ack});

    assert property(@(posedge clk) $rose(req) |-> req[*1:$] ##0 ack ##1 !req)
      else $error("    req must hold until ack then drop for at least 1 cycle");
    assert property(@(posedge clk) ack |=> !ack)
      else $error("    ack on for more than one cycle");
    assert property(@(posedge clk) !req |-> !ack)
      else $error("    ack on without req");
    assert property(@(posedge clk) $rose(req) ##1 ack[->1] |=> !req)
         $display("    Great! req held until ack then dropped!");
      else $error("    Req must drop at least one cycle after the ack");

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
    @(posedge clk); req <= 1; //ack <= 1;
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

