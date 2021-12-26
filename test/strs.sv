
module test;
  string q[$] = '{ "10", "5", "0", "20", "15"};
  string qq[$];
  int x;

  initial begin
    $display( "%p", q.sum(s) with ( s.atoi ) );
  end
endmodule
