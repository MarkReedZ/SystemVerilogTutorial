
module hello;
  int map[string];

    typedef enum int {
        BACK = 'h1,
        SYNC = 'h2,
        FRONT = 'h4,
        ACTIVE = 'h8,
        IDLESUBFRAME = 'h10,
        SLAVEIDLE = 'h20,
        EXT_VFP = 'h40,
        AUX_RUNIN = 'h80,
        IDLE = 'h0
    } vftg_state_t;

  int smap[int];

  initial begin
    static string key = "a";
    map = '{ "a":0, "b":1, "c":2 };

    smap[BACK] = 1;
    if ( smap.exists(BACK) ) $display("BACK exists");

    // k will hold the keys
    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

    $display("num=%0d",map.num());
    $display("no key %0d",map["nope"]);

    if ( map.exists(key) ) begin
      map.delete(key);
    end

    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

    map.delete();

    $display("Size after delete %d", map.size());
    foreach (map[k]) begin
      $display("map[%s] = %0d", k, map[k]);
    end

  end

endmodule

