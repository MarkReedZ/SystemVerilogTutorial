
class node;
  int v;
  node l,r;
  function new(int val);
    v = val; l = null; r = null;
  endfunction
  
endclass

function automatic void inorder( node n, ref int ret[$] );
  if (n == null) return;

  inorder(n.l,ret);
  ret.push_back(n.v);
  inorder(n.r,ret);

endfunction


module test;
  int ret[$];
  node root;

  initial begin
    root = new(1);
    root.r = new(2);
    root.r.l = new(3);

    inorder(root, ret);
    $display("%p", ret);
    
  end
endmodule
