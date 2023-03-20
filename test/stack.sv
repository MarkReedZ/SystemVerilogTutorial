
class stack #(type T=int);
  T items[$];
  task push( T a );
    items.push_front(a);
  endtask
  task pop( ref T a );
    a = items.pop_front();
  endtask
  function void print();
    foreach( items[i] )
      $display(" items[%0d] : %s", i, items[i]);
  endfunction
endclass

module test;
  stack #(string) stk = new;
  string s = "yay";

  initial begin
    stk.push("1");    
    stk.push("2");    
    stk.push("3");    
    stk.print();
    stk.pop(s);
    $display(" s=%s",s);
    stk.print();
  end
endmodule

class fart #(type T=int);
  T q[$];
  task push( T a );
    q.push_front(a);
  endtask
  task pop( ref T a );
    a = q.pop_front();
  endtask
endclass
