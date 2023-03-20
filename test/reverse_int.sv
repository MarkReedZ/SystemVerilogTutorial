


module tb;
  int digits[$];
  int n;

  initial begin

    n = 123;
    while (n > 0) begin
      digits.push_back( n % 10 );
      n = n / 10;
    end

    foreach(digits[i]) begin
      $display("%d",digits[i]);
    end
    
  end

endmodule
