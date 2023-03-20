
// leetcode zigzag-conversion

module tb;

  string s = "PAYPALISHIRING";  
  int n = 4;
  int x,i;
  string arr[][$];

  initial begin
    arr = new[n];
 
    x = 0; 
    while ( i < s.len() ) begin
      //$display(" %s ", s[i] );

      while ( x < n ) begin
        arr[x].push_back(s[i]);
        x += 1; i += 1;
      end
      x -= 2;
      while ( x >= 0 ) begin
        arr[x].push_back(s[i]);
        i += 1; x -= 1;
      end
      x = 1;
      
    end 

    foreach ( arr[i,j] ) begin

        $display( " %d: %s", i, arr[i][j] );
    end
    
    
  end

endmodule
