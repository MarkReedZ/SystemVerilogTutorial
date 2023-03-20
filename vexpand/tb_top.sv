

module tb_top;

    //*****************************************************************************
    // Group: Instrumentation logic

    //*****************************************************************************
    // Group: Clocks & Resets
    wire clk, rst_n;


    /* harness_intf AUTO_TEMPLATE (
         .valid (foo.vld),
         .ack   (foo.ack),
     );*/
     harness_intf harness_i(/*AUTOINST*/
                            // Inputs
                            .clk                (clk),
                            .reset_n            (reset_n),
                            .push               (push),
                            .pop                (pop),
                            .valid              (foo.vld),       // Templated
                            .ready              (ready),
                            .ack                (foo.ack),       // Templated
                            .x                  (x),
                            .y                  (y),
                            .xone               (xone),
                            .xtwo               (xtwo));

endmodule

// Local Variables:
// verilog-indent-level: 4
// verilog-indent-lists: nil
// verilog-library-directories: (
//   "."
//   "./intf"
//   "./design"
// )
// End:
