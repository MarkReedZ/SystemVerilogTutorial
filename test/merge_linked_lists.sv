
class LL;
  int val;
  LL n;

  function new(int v);
    val = v; n = null;
  endfunction
endclass

module test;
  LL t,a,b, ret;

  initial begin
    a = new(1);
    t = new(2); a.n = t;
    t = new(4); a.n.n = t;
    b = new(1);
    t = new(3); b.n = t;
    t = new(4); b.n.n = t;

    ret = new(99);
    t = ret;
    while ( a != null && b != null ) begin
      if ( a == null ) begin
        t.n = new( b.val );
        t = t.n; b = b.n;
        continue;
      end else if ( b == null ) begin
        t.n = new( a.val );
        t = t.n; a = a.n;
        continue;
      end

      if ( a.val <= b.val ) begin
        t.n = new( a.val );
        t = t.n; a = a.n;
      end else begin
        t.n = new( b.val );
        t = t.n; b = b.n;
      end

    end

    t = ret.n;
    while ( t != null ) begin
      $display( "%d", t.val); 
      t = t.n;
    end
 
  end
endmodule
