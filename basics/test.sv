
module hello;
  int map[string];
  bit [3:0] hstate;
  bit [3:0] odd_hstate;

  initial begin

    map = '{ "a":0, "b":1, "c":2 };

    hstate = '0;
    odd_hstate = '0;
    hstate[1] = 0;
    odd_hstate[1] = 1;
    
    $display("DELME %x", |(hstate & odd_hstate));

    // k will hold the keys
    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

  end

endmodule

