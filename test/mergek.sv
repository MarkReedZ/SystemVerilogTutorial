
class node;
  int v;
  node n;
  function new(int val);
    v = val; n = null;
  endfunction

endclass

module test;
  node lists[3];
  node n[3];
  node t;
  int i,k;
  node root;
  int arr[];
  node q[$];
  int iq[$];

  
  initial begin
    k = 3;
    t = new(2); lists[0] = t;
    t = new(1); lists[1] = t;
    t = new(1); lists[2] = t;
    t = new(4); lists[0].n = t;
    t = new(3); lists[1].n = t;
    t = new(6); lists[2].n = t;
    t = new(5); lists[0].n.n = t;
    t = new(4); lists[1].n.n = t;

    for(i=0;i<k;i++) begin
      
      while (lists[i] != null) begin
        q.push_back(lists[i]);
        lists[i] = lists[i].n;
      end
    end

    q.sort(n) with ( n.v );

    root = q[0];
    t = root;
    for(i=1;i<q.size();i++) begin
      t.n = q[i];
      t = t.n; 
    end

    iq = {};
    while( root != null ) begin
      iq.push_back(root.v);
      root = root.n;
    end

    $display( "%p", iq );

  end
endmodule





