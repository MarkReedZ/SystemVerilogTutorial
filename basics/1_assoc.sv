
module hello;
  int map[string];

  initial begin
    string key = "a";
    map = '{ "a":0, "b":1, "c":2 };

    // k will hold the keys
    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

    $display("num=%0d",map.num());

    if ( map.exists(key) ) begin
      map.delete(key);
    end

    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

  end

endmodule

