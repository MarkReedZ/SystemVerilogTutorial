
class Node;
  int isWord;
  Node c[string];
  function new();
    isWord = 0; c = '{default:null};
  endfunction
endclass

class Trie;
  Node root;

  function new();
    root = new();
  endfunction

  function void add(string w);
    Node n = root;
    foreach (w[i]) begin
      if ( !n.c.exists(w[i])) n.c[ w[i] ] = new();
      n = n.c[w[i]];
      if ( i == w.len()-1 ) begin
        n.isWord=1;
      end
    end
  endfunction

endclass

// Does this make sense to you? 
// Trie the words
// Loop the board from the top left. Try each letter and each dir until trie
// hits null and if hit a word save it



function automatic void move( int x, int y, string s, Node rt, ref string bd[][], int bd_used[][], string ret[$] );
  string c;
  int dx[] = '{ -1,0,1,0 };
  int dy[] = '{ 0,1,0,-1 };
  Node n;

  if (x < 0 || x > 3) return;
  if (y < 0 || y > 3) return;
  if ( bd_used[y][x] ) return;
  c = bd[y][x];

  s = {s,c};
  bd_used[y][x] = 1;
  n = rt.c[c];
  if (n == null) return;
  
  if ( n.isWord ) begin
    $display("DELME isw %s",s);
    ret.push_back(s);
  end

  foreach( dx[i] ) begin
    move( x+dx[i], y+dy[i], s, n, bd, bd_used, ret );
  end
endfunction

module test;
  string bd[][];
  int bd_used[][];
  string words[];
  string ret[$];
  Trie t;
  int x,y;
  string wd;

  initial begin
    t = new();
    bd = '{ '{"o","a","a","n"}, '{"s","t","a","e"}, '{"i","h","k","r"}, '{"i","f","l","v"} };
    bd_used = '{ 4{ '{4{0}}}};
    ret = '{};
    words = '{ "oath", "pea", "eat", "rain", "eats" };

    foreach(words[i]) begin
      t.add(words[i]); 
    end

    for ( y=0; y<4; y++ ) begin
      for ( x=0; x<4; x++ ) begin
        wd = "";
        bd_used = '{ 4{ '{4{0}}}};
        move( x, y,wd, t.root, bd, bd_used,ret );
      end
    end
    $display("ret=%p",ret);
    
  end
endmodule
