
// The bit map isn't needed - we only do 1 compare at start and after use
// a lookup

class tst;
  string wl[];
  int map[string] = '{default:-1};
  bit [31:0] bl[$];
  int letterIndex[string];
  int shortestPaths[$][$];

  function new( string wlist[] );
    string lets = "abcdefghijklmnopqrstuvwxyz";
    wl = wlist;
    // Get bit maps for each word in the list
    foreach (lets[i]) begin
      letterIndex[lets[i]] = i;
    end
    foreach(wl[i]) begin
      bl.push_back( getBits(wl[i]) );
      map[wl[i]] = i; 
      shortestPaths.push_back({});
    end

    // Generate shortest path from each word in the list to each other
    
  endfunction

  function bit[31:0] getBits(string s);
    bit [31:0] ret = 0;
    foreach (s[i]) begin
      ret[letterIndex[s[i]]] = 1; 
    end
    return ret;
  endfunction

  function int shortest( string a, string b );
    if ( map[b] == -1 ) return 0;
    // Are we one off from a word in the list?

    // If so return the shortest path
    
  endfunction

endclass

module test;
  tst t;

  initial begin
    t = new( '{"hot","dot","dog","lot","log","cog"} );
    $display(" hit-pot: %0d", t.shortest("hit","pot"));
    
  end
endmodule

