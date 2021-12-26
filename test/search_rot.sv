
module test;
  int nums[] = '{ 4,5,6,7,0,1,2 };
  int l,m,h;
  int x = 0;
  initial begin
    l = 0; h = nums.size()-1;
    $display("%0d,%0d",l,h);

    while ( l < h ) begin
      m = (l+h)/2;
      $display( "%0d,%0d,%0d nums[m]=%0d",l,m,h,nums[m]);
      if ( nums[m] == x ) break;

      if ( nums[l] <= nums[m] ) begin
        if ( nums[l] <= x && x < nums[m] ) 
          h = m - 1;
        else
          l = m + 1;
      end else begin 
        if ( nums[m] < x && x <= nums[h] ) 
          l = m + 1;
        else
          h = m - 1;
      end 
    end

    $display(" m=%0d",m);
    $finish;
  end
endmodule
