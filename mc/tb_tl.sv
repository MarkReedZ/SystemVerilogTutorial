

module tb;

  reg clk, rstn;
  reg [1:0] cmd;
  reg [63:0] addr;
  reg [63:0] data;
  reg wr,wr_p;
  reg [2:0] ptr;
  reg [63:0] tlxr_wdf_data;

  TL tl(clk, rstn, cmd, addr, data, wr, wr_p, ptr, tlxr_wdf_data );

  always #5 clk = ~clk;

  initial begin
    {clk,rstn,cmd,addr,data} <= 0;
    #20 rstn <= 1;
    $monitor("%0t: cmd %d data %x tlxr_wdf_wr %d data %0x", $time, cmd, data , wr, tlxr_wdf_data);
    cmd <= 1; addr <= 2; data <= 8'hFF;
    #10 cmd <= 0;
    #100 $finish;    
  end

endmodule
