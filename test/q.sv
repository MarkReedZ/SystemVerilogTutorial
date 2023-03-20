

module tb;
  int q[$] = '{3,2,8,1,5};

  initial begin
    q.push_back(6); q.sort();
    foreach (q[i]) begin
      $display( "%0d", q[i] );
    end
  end
endmodule
