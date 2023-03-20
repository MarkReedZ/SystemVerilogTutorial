
class LL;
  int val;
  LL n;
  
  function new(int v);
    val = v; n = null;
  endfunction
endclass

module test;
  LL t,a,b,c, root;
  int i,carry, sum;

  initial begin
    a = new(2);
    t = new(4);
    a.n = t;
    t = new(3);
    a.n.n = t;  // 2 4 3  342

    b = new(5);
    t = new(6);
    b.n = t; // 5 6  -  65
    t = new(4);
    //b.n.n = t;

    sum = a.val + b.val;
    carry = sum/10;
    c = new( sum%10 );
    a = a.n;
    b = b.n;
    root = c;
    while( a != null || b != null ) begin
      if (a != null) begin
        carry += a.val;
        a = a.n;
      end
      if (b != null) begin 
        carry += b.val;
        b = b.n;
      end
      t = new( carry%10 );
      carry = carry / 10;
      c.n = t;
      c = c.n;
    end

    if ( carry )    
      c.n = new(1);
   

    $display(root.n.n.val); 
    $display(root.n.val); 
    $display(root.val); 
    
  end
endmodule
