
interface my_intf (/*AUTOARG*/
   // Inputs
   clk, reset_n, push, pop, valid, ready, ack, x, y, xone, xtwo
   );
/*AUTOINOUTIN("block")*/
// Beginning of automatic in/out/inouts (from specific module)
input logic             clk;
input logic             reset_n;
input logic             push;
input logic             pop;
input logic             valid;
input logic             ready;
input logic             ack;
input logic             x;
input logic             y;
input logic             xone;
input logic             xtwo;
// End of automatics
endinterface

module test;
  /* my_intf AUTO_TEMPLATE "\(.*\)_my_i" (
      .clk       (clk_@),
      .reset_n   (reset_n_@),
      .\(.*\)    (),
  )*/
  
  my_intf a_my_i ( /*AUTOINST*/);
  my_intf b_my_i ( /*AUTOINST*/);

endmodule


// Local Variables:
// verilog-auto-wire-type:"logic"
// verilog-typedef-regexp: "[_est]$"
// verilog-library-directories: ("design")
// End:

