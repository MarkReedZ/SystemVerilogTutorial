

module test;
  int nums[] = '{3,4,-1,1};
  int m[int] = '{default:0};
  int min = 1;
  int n;

  initial begin
    n = nums.size();
    foreach(nums[i]) begin
      if ( nums[i] <= 0 || nums[i] >= n )
        nums[i] = 0;
    end
    foreach(nums[i]) begin
      nums[ nums[i]%n ] += n;
    end

/*
    foreach(nums[i]) begin
      m[nums[i]] = 1;
      if ( nums[i] == min ) begin
        while( m[min] == 1 ) min++;
      end      
    end
*/
    $display("min=%0d",min);
     
  end


endmodule
