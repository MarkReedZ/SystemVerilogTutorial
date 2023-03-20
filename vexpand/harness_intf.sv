


interface harness_intf (/*AUTOARG*/
   // Inputs
   clk, reset_n, push, pop, valid, ready, ack, x, y, xone, xtwo
   );
  /*AUTOINOUTIN("block")*/
  // Beginning of automatic in/out/inouts (from specific module)
  input                 clk;
  input                 reset_n;
  input                 push;
  input                 pop;
  input                 valid;
  input                 ready;
  input                 ack;
  input                 x;
  input                 y;
  input                 xone;
  input                 xtwo;
  // End of automatics

  valid_intf valid_i (/*AUTOINST*/
                      // Inputs
                      .clk              (clk),
                      .reset_n          (reset_n),
                      .valid            (valid),
                      .ack              (ack));

endinterface

// Local Variables:
// verilog-indent-level: 4
// verilog-indent-lists: nil
// verilog-library-directories: (
//   "."
//   "./intf"
//   "./design"
// )
// End:

