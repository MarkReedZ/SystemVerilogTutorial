
module signal_intf;
  /* my_intf AUTO_TEMPLATE (
      .clk       (clk[@]),
      .reset_n   (reset_n_@),
      .\(.*\)    (),
  )*/
  
  my_intf my_0_i ( /*AUTOINST*/
                  // Inputs
                  .clk                  (clk),                   // Templated
                  .reset_n              (reset_n_),              // Templated
                  .x                    (),                      // Templated
                  .y                    (),                      // Templated
                  .xtwo                 ());                      // Templated
  my_intf my_1_i ( /*AUTOINST*/
                  // Inputs
                  .clk                  (clk),                   // Templated
                  .reset_n              (reset_n_),              // Templated
                  .x                    (),                      // Templated
                  .y                    (),                      // Templated
                  .xtwo                 ());                      // Templated

endmodule
