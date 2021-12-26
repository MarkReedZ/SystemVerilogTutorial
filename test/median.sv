


module test;
  int a[$] = '{1,3,5};
  int b[$] = '{2,4};
  int c[$];
  int h;

  initial begin
    c = {a,b};
    c.sort();

    h = c.size()/2;
    if ( c.size() & 1 ) $display("%d",c[h]);
    else                $display("%d", (c[h]+c[h-1])/2);
    $display( "%p", c );

    
  end
endmodule
