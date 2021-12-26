
module test;
  int q[$];

  function void add(int n);
    q.push_back(n);
  endfunction

  function real median();
    q.sort();
    if (q.size()&1)
      return q[q.size()/2];
    else
      return real'(q[q.size()/2]+q[q.size()/2-1])/2;
  endfunction

  initial begin
    add(1);
    add(1);
    $display("med=%f", median());
    add(3);
    add(1);
    add(5);
    $display("med=%f", median());
  end

endmodule
