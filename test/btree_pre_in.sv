

class node;
  int v;
  node l,r;
  function new(int val);
    v = val; l=null; r=null;
  endfunction
endclass

function automatic void print_inorder(node n);
  if (n==null) return;
  print_inorder(n.l);
  $display("%d",n.v);
  print_inorder(n.r);
endfunction

function automatic node build ( int in[$], ref int pre[$] );
  int index[int];
  node n;
  int i;

  $display("in=%p pre=%p",in,pre);

  if ( in.size()==0 || pre.size()==0 ) return null;

  foreach( in[i] ) index[in[i]] = i;

  n = new( pre.pop_front() );
  i = index[n.v];

  n.l = build( in[0:i-1], pre );
  n.r = build( in[i+1:$], pre );
  return n;

endfunction

module test;

  int pre[$] = '{3,9,20,15,7}; // val l r
  int in[$]  = '{9,3,15,20,7}; // l val r 

  node root,n;
  int i,j;

  initial begin
    root = build( in,pre );
    $display("root v=%d",root.v);
    print_inorder(root);    
  end


endmodule




