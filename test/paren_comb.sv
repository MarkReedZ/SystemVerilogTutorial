

function automatic void perm( string s, int left, int right, ref string ret[$] );
  if (left)         perm( {s, "("}, left-1, right  , ret );
  if (left < right) perm( {s, ")"}, left  , right-1, ret );
  if ( right == 0 ) ret.push_back(s);
endfunction

module test;
  string ret[$];

  initial begin
    perm( "", 3, 3, ret );
    $display("%p",ret); 
  end
endmodule
