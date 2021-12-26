typedef int q2[$][$];

function automatic q2 permute( int nums[$] );
  int ret[$][$];
  int tmp[$][$];
  int l[$];

  if (nums.size() == 1) begin
    ret.push_back( nums );
    return ret;
  end
  $display("nums=%p",nums);
  
  foreach( nums[i] ) begin
    if ( i == 0 )
      tmp = permute( nums[1:$] );
    else if (i == nums.size()-1)
      tmp = permute( nums[0:i-1] );
    else begin
      tmp = permute( { nums[0:i-1], nums[i+1:$] } );
    end
    foreach(tmp[j]) begin
      l = { nums[i], tmp[j] };
      ret = { ret, l };
    end
  end
  return ret;
endfunction


module test;
  int nums[$] = '{1,2,3};

  initial begin
    
    $display("%p",permute(nums));
    
  end
endmodule
