
class node;
  int val;
  node l,r;

  function new(int v);
    val = v; l = null; r = null;
  endfunction

endclass

function automatic void print_inorder( node n );
  if (n == null) return;
  print_inorder( n.l );
  $display("%d",n.val);
  print_inorder( n.r );
endfunction
function automatic void print_postorder( node n );
  if (n == null) return;
  print_postorder( n.l );
  print_postorder( n.r );
  $display("%d",n.val);
endfunction

function automatic node build_tree( int in[$], ref int post[$] );
  node root;
  int i;
  int q[$];
  int index[int];

  $display( "in=%p post=%p",in,post);

  if ( in.size()==0 || post.size()==0 ) return null;

  foreach( in[i] ) index[in[i]] = i; 
  
  root = new( post.pop_back() );  
  //q = in.find_index(v) with ( v == root.val );
  //i = q[0];
  i = index[root.val];

  //root.r = build_tree( in[i+1:in.size()-1], post );
  root.r = build_tree( in[i+1:$], post );
  root.l = build_tree( in[0:i-1], post );

  return root;
     
endfunction

module test;
  int in[$] = '{9,3,15,20,7};
  int post[$] = '{9,15,7,20,3};
  node root;

  initial begin
    root = build_tree(in, post);
    
    print_inorder(root);
    print_postorder(root);
  end 

endmodule

