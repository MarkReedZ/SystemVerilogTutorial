module tb;
  reg clk,rstn,req,ack,dv,taken,done;

  always #5 clk = ~clk;

  default disable iff (!rstn);
    // Reset
    assert property(disable iff (0) @(posedge clk) !rstn |-> !{req,ack});

    // Req
    //assert property(@(posedge clk) req |-> req[*1:$] ##0 ack ##1 !req)
    assert property(@(posedge clk) req |-> (req throughout ack[->1]) ##1 !req)
         $display("    req held until ack then dropped!");
      else $error("    req must hold until ack then drop for at least 1 cycle");

    // Ack
    assert property(@(posedge clk) ack |=> !ack)
      else $error("    ack on for more than one cycle");
    assert property(@(posedge clk) !req |-> !ack)
      else $error("    ack on without req");

    // dv
    assert property(@(posedge clk) (req && ack) |-> ##1 ((dv) throughout taken[->4]) ##1 done)
         $display("    Data taken 4 times then done!");
      else $error("    Data not taken 4 times followed by done");
    assert property(@(posedge clk) (req && ack) |=> (dv&&taken)[->4] ##1 (!dv && done))
         $display("    Data taken 4 times then done!");
      else $error("    Data not taken 4 times followed by done");
    //assert property(@(posedge clk) dv |-> !req);

    // Done
    assert property(@(posedge clk) done |=> !done)
      else $error("    done on for more than one cycle");
    assert property(@(posedge clk) done |-> $past(taken))
      else $error("    done on without taken last cycle");

    // Taken
    assert property( @(posedge clk) taken |-> dv );

    sequence btb_req;
      @(posedge clk) (req && ack) ##1 !ack ##1 (req,$display("YAY"));
    endsequence
    btbreq: cover property(btb_req);

    sequence tst;
      @(posedge clk) dv ##1 (dv,$display("YAY"));
    endsequence
    dvdv: cover property(tst);

    cover property(@(posedge clk) dv |=> (dv,$display("YAY2")));

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

    {clk,rstn,req,ack,dv,taken,done} <= 0;
    $monitor("clk=%0d req=%0d ack=%0d dv=%0d taken=%0d done=%0d",clk,req,ack,dv,taken,done);



    rstn <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); rstn <= 1;
    @(posedge clk); req <= 1; taken <= 1; dv <= 1; done <= 0;
    @(posedge clk); req <= 1; taken <= 0; dv <= 0; done <= 1;
    @(posedge clk); req <= 1; done <= 0;
    @(posedge clk); 
    @(posedge clk); 
    @(posedge clk); req <= 1; ack <= 1;
    @(posedge clk); {ack,req} <= 0; dv <= 1;
    @(posedge clk); req <= 1;
    @(posedge clk); ack <= 1;
    @(posedge clk); {ack,req} <= 0;
    @(posedge clk);
    @(posedge clk); taken <= 1;
    @(posedge clk); taken <= 0; dv <= 1;
    @(posedge clk); taken <= 1; dv <= 1;
    @(posedge clk); taken <= 0;
    @(posedge clk); taken <= 1;
    @(posedge clk); taken <= 0;
    @(posedge clk); taken <= 1; 
    @(posedge clk); taken <= 0; dv <= 0; done <= 1;
    @(posedge clk); done <= 0;
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule

