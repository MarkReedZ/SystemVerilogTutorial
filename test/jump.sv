

module test;
  int a[] = '{3,2,1,0,4};
  int i,last;

  initial begin

    last = a.size()-1;
    for (i = a.size()-1; i >= 0; i--) begin
      if (i+a[i] >= last)
        last = i;
    end

    if ( last == 0 ) 
      $display("yay");
    else
      $display("nope");
     
  end


endmodule
