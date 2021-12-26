
// Level traversal for btree

class Node;
  int v;
  Node l,r;
  function new(int val);
    v = val; l = null; r = null;
  endfunction
endclass

class Tree;
  int ret[$][$];
  Node r;
  int q[$];

  function new();
  endfunction

  function void level( Node n );
    ret = '{};
    r = n;
    trav( n, 0 );
  endfunction 

  function void trav( Node n, int depth );
    if ( n == null ) return;
    if ( ret.size() == depth ) ret.push_back( '{} );
    ret[depth].push_back( n.v );
    trav( n.l, depth+1 );
    trav( n.r, depth+1 );
  endfunction

  function void inorder( Node n );
    if ( n == null ) return;
    q.push_back( n.v );
    inorder( n.l );
    inorder( n.r ); 
  endfunction

endclass

module test;
  Node r,n;
  Tree t;
  
  initial begin
    r = new(3);
    r.l = new(9);
    r.r = new(20);
    r.r.l = new(15);
    r.r.r = new(7);
    t = new();
    t.level(r);
    $display( "%p", t.ret );

    t.inorder(r);
    $display( "%p", t.q );
    
  end
endmodule
