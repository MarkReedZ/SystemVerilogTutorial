
module Fifo (input clk,rstn,wr,rd,
            input [7:0] din,
            output [7:0] dout,
            output empty,full);
  reg [7:0] mem[8];
  reg [2:0] wptr,rptr;
  integer cnt;

  always @(negedge rstn) begin
    for(cnt=0;cnt<8;cnt++) mem[cnt] = 0;
    cnt = 0; wptr = 0; rptr = 0;
    mem[rptr-1] = '0;
    $display("YAY %0x", mem[rptr-1]);
  end

  always @(posedge clk) begin
    if ( wr && cnt<8 ) begin
      mem[wptr] = din;
      wptr = wptr + 1;
      cnt = cnt + 1;
    end
    if ( rd && cnt>0 ) begin
      rptr = rptr + 1;
      cnt = cnt - 1;
    end
  end

  assign empty = cnt==0;
  assign full  = cnt==8;
  assign dout  = mem[rptr-1];

  default disable iff !rstn;

  assert property (@(posedge clk) disable iff (0) !rstn |-> (!{wptr,rptr,full,cnt} && empty) );
  
  assert property ( @(posedge clk) (wr&&(cnt<8)) |=> (wptr == $past(wptr)+1))
    else $error("    wptr did not increment wr and cnt=%0d wptr=%0d past wptr=%d",$sampled(cnt), $sampled(wptr), $past(wptr));
  assert property ( @(posedge clk) (rd&&cnt) |=> (rptr == $past(rptr)+1))
    else $error("    rptr must increment after non empty rd rptr=%0d past rptr=%0d",rptr, $past(rptr));

  property read;
    logic [7:0] data;
    @(posedge clk) (wr, data=din) ##0 rd[->1] |=> dout===data;
  endproperty

  assert property(read);


endmodule

module tb;
  reg clk,rstn,wr,rd;
  wire empty,full;
  reg [7:0] din;
  wire [7:0] dout; 

  Fifo fifo(clk,rstn, wr,rd,din,dout,empty,full);

  always #5 clk = ~clk;

  covergroup cg @(posedge clk);
    coverpoint full;
    coverpoint empty;
    //coverpoint din;// = {[0:8'hFF]};
    wr_rd: coverpoint {wr,rd};
    F_E: coverpoint {full,empty}  {
      bins fe = ( 2'b10 => 2'b01 );
      bins ef = ( 2'b01 => 2'b10 );
      bins tf = ( 2'b00 => 2'b10 );
    }
  endgroup

  cg cg_inst;

  initial begin
    cg_inst = new();
    //$dumpfile("wave.vcd");
    //$dumpvars(0,fifo);

    $monitor("%03t: wr=%0d rd=%0d din=%0x dout=%0x empty=%0d full=%0d", $time, wr,rd,din,dout,empty,full);

    {clk,rstn,wr,rd,din} <= 0; rstn <= 1;
    #5  rstn <= 0;
    #15 rstn <= 1;

    @(posedge clk);
    @(posedge clk); wr <= 1; din <= 1; rd <= 1;
    @(posedge clk); wr <= 1; din <= 2; rd <= 0;
    @(posedge clk); wr <= 1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); wr <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); rd <= 1; 
    @(posedge clk); rd <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $display("Cov = %0.2f %%", cg_inst.get_coverage());
    $finish;

  end

endmodule

