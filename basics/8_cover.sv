
class pkt;
  rand bit[3:0] addr;
  rand bit[3:0] data;
endclass

module top;
  pkt p;
  p=new();

  covergroup cg;
    ADDR:coverpoint p.addr;
    DATA:coverpoint p.data;
  endgroup

  initial begin
    cg c;
    c = new();
    repeat (5) begin
      p.randomize();
      c.sample();
    end
  end
endmodule

