
# VEXPAND

Vexpand is a wrapper around the open source tool verilog-mode

    https://seg-confluence.csg.apple.com/pages/viewpage.action?pageId=35137657
    https://www.veripool.org/verilog-mode/help/

Some useful examples:

## Add all IOs from a block as interface inputs

The following will pull all IOs from block.sv and add them as inputs to the interface.

```v
interface my_intf (/*AUTOARG*/);
/*AUTOINOUTIN("block")*/
endinterface
// Local Variables:
// verilog-auto-wire-type:"logic"
// verilog-typedef-regexp: "[_est]$"
// verilog-library-directories: (".")
// End:
```

Run vexpand and check intf.sv against block.sv

```
vexpand intf.sv
```


##  Changing signal binding based on interface name

If you have to bind multiple interfaces you can use a regex and @ to modify signal names per instance

```
vexpand signal_intf.sv
```

```v
module test;
  /* my_intf AUTO_TEMPLATE "\(.*\)_my_i" (
      .clk       (clk_@),
      .reset_n   (reset_n_@),
      .\(.*\)    (),
  )*/

  my_intf a_my_i ( /*AUTOINST*/ );
  my_intf b_my_i ( /*AUTOINST*/ );

endmodule
```

Gives you:

```v
  my_intf a_my_i ( /*AUTOINST*/
                  // Inputs
                  .clk                  (clk_a),                 // Templated
                  .reset_n              (reset_n_a),             // Templated
                  .x                    (),                      // Templated
                  .y                    (),                      // Templated
                  .xtwo                 ());                      // Templated
  my_intf b_my_i ( /*AUTOINST*/
                  // Inputs
                  .clk                  (clk_b),                 // Templated
                  .reset_n              (reset_n_b),             // Templated
                  .x                    (),                      // Templated
                  .y                    (),                      // Templated
                  .xtwo                 ());                      // Templated
```

If you remove the regex then @ will refer to the first number in the intf name

```
vexpand signal_intf_num.sv
```

```v
module test;
  /* my_intf AUTO_TEMPLATE  (
      .clk       (clk_@),
      .reset_n   (reset_n_@),
      .\(.*\)    (),
  )*/

  my_intf my_0_i ( /*AUTOINST*/ );
  my_intf my_1_i ( /*AUTOINST*/ );
```

Gives clk_0 and clk_1 respectively



## Change signal case

The following will update the bind with all inputs converted to uppercase for the dut signals

```v
// var: case_i
/* case_intf AUTO_TEMPLATE (
  .clk  (clk)
  .\(.*\)  (X@"(upcase \\"\1\\")"),
); */

bind block
  case_intf case_i(/*AUTOINST*/);

// Local Variables:
// verilog-library-directories: (".")
// End:
```


## Auto state ascii

Its nice to have a string for the state name during debug

```v
        //== State enumeration
        parameter [2:0] // auto enum state_info
                           SM_IDLE =  3\='b000,
                           SM_SEND =  3\='b001,
                           SM_WAIT1 = 3\='b010;
        //== State variables
        reg [2:0]  /* auto enum state_info */
                   state_r;  /* auto state_vector state_r */
        reg [2:0]  /* auto enum state_info */
                   state_e1;

        /*AUTOASCIIENUM("state_r", "state_ascii_r", "SM_")*/
```

Turns into 

```v
        /*AUTOASCIIENUM("state_r", "state_ascii_r", "SM_")*/
        // Beginning of automatic ASCII enum decoding
        reg [39:0]              state_ascii_r;          // Decode of state_r
        always @(state_r) begin
           case ({state_r})
                SM_IDLE:  state_ascii_r = "idle ";
                SM_SEND:  state_ascii_r = "send ";
                SM_WAIT1: state_ascii_r = "wait1";
                default:  state_ascii_r = "%Erro";
           endcase
        end
        // End of automatics
```
