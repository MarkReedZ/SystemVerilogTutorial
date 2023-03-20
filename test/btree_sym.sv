
class node;
  int v;
  node l,r;
  function new(int val);
    v = val; l = null; r = null;
  endfunction
endclass

function int isSym( node root );
  if ( root == null ) return 1;

  return isMirror( root.l, root.r );

endfunction

function automatic int isMirror( node l, node r );
  if ( l == null && r == null ) return 1;
  if ( l == null || r == null ) return 0;

  if ( l.v == r.v ) begin
    return isMirror( l.l, r.r ) && isMirror( l.r, r.l );
  end else
    return 0;
endfunction


module test;
  node root,n;

  initial begin
    root = new(1);
    n = root;
    n.l = new(2);
    n.r = new(2);
    n.l.l = new(3);
    n.l.r = new(4);
    n.r.l = new(4);
    n.r.r = new(3);
    n.l.l.l = new(5);
    n.l.l.r = new(6);
    n.l.r.l = new(7);
    n.l.r.r = new(8);
    n.r.l.l = new(8);
    n.r.l.r = new(7);
    n.r.r.l = new(6);
    n.r.r.r = new(5);

    $display("sym=%0d", isSym(root));
     
  end


endmodule

