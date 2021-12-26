

module test;
  int a,b,c,n;

  initial begin

    n = 4;
    for (int i=0; i<n; i++ ) begin
      c = a; a = b; b = b+c;
    end 
    $display(a);
  end
endmodule
