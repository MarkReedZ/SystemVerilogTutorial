
# SV Hello World

Try your first run


```
xrun hello.sv
```

SystemVerilog is an extension of Verilog that adds many features useful for verification.  Verilog is a Hardware Description Language. 

Modules are blocks of code and can contain other modules.

The initial block is one of the procedural blocks in verilog.  It starts at time 0 and is run once.  

```
module hello;
  int x;

  initial begin

    $display("Hello World. x is %d", x);

  end

endmodule
```

Try changing the value of x and play around with the display.



