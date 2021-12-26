
module tb;
  reg clk,rstn,req,resp_vld,respb_vld,respc_vld,resp_a,resp_b,resp_c;
  reg [7:0] resp_tag, respb_tag, respc_tag;

  always #5 clk = ~clk;

  default disable iff (!rstn);

  property resp;
    logic [7:0] tag;

    @(posedge clk) (resp_vld,tag=resp_tag,$display("    tag=%d",resp_tag)) |-> (respb_vld && (respb_tag==tag))[->1] ##1 (respc_vld && (respc_tag==tag))[->1]; 
  endproperty
  assert property(resp)
         $display("    tag completed");
    else $error("    Did not see 3 responses for tag");

  initial begin
    {clk,rstn,req,resp_vld,respb_vld,respc_vld,resp_a,resp_b,resp_c,resp_tag,respb_tag,respc_tag} <= 0;
    $monitor("clk=%0d req=%0d resp_vld=%0d respb_vld=%0d respc_vld=%0d tag=%0d btag=%0d ctag=%0d",clk,req,resp_vld,respb_vld,respc_vld,resp_tag,respb_tag, respc_tag);



    rstn <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); rstn <= 1;
    @(posedge clk); req <= 1;
    @(posedge clk); req <= 0; 
    @(posedge clk); resp_vld <= 1; resp_a <= 1; resp_tag <= 1;
    @(posedge clk); resp_vld <= 1; resp_a <= 1; resp_tag <= 2;
    @(posedge clk); {resp_vld,resp_a,resp_tag} <= 0;
    @(posedge clk); 
    @(posedge clk); 
    @(posedge clk); respb_vld <= 1; respb_tag <= 1; resp_b <= 1;
    @(posedge clk); {respb_vld,resp_b,respb_tag} <= 0;
    @(posedge clk); respb_vld <= 1; respb_tag <= 2; resp_b <= 1;
    @(posedge clk); {respb_vld,resp_b,respb_tag} <= 0;
    @(posedge clk); respc_vld <= 1; respc_tag <= 2; resp_c <= 1;
    @(posedge clk); respc_vld <= 1; respc_tag <= 1; resp_c <= 1;
    @(posedge clk); {respc_vld,resp_c,respc_tag} <= 0;
    @(posedge clk); 
    @(posedge clk); 
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule

