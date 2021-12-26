

module test;
  string wds[] = '{"eat","tea","ate","nat","tan","bat"};

  initial begin

    $display( "%s", wds[0].sort() );
  end
endmodule
