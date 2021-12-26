
function automatic longint seq(int n);//, ref int q[$]);
  //$display("    %0d,%0d",a,b);
  if (n < 0) return -1;
  if (n == 0) return 1;
  return (4*n-2)*seq(n-1)/(n+1) ;
  
endfunction
module test;
  int q[$] = '{};
  initial begin
    $display("%0d", seq(5));

    if ( 4'b0110 ==? 4'b01xx ) $display("YAY");
  end
endmodule
