
class Packet;
  rand bit a;
  rand bit [1:0] mode;
  
  //constraint c1 { mode inside {0,1}; }
  //constraint c1 { mode < 3; }
  //constraint c3 { (a==0) -> mode == 3; solve a before mode; }
  constraint c3 { (a==1) -> mode inside {0}; solve a before mode; }

endclass


module tb;
  Packet pkt;
  initial begin
    pkt = new();
    repeat (10) begin
      assert(pkt.randomize());
      $display("a=%d mode=%d",pkt.a,pkt.mode);
    end
    assert(pkt.randomize());
    $display("mode=%d",pkt.mode);
  end
endmodule  
