
module hello;
  int q[$] = '{1,2,3,4,5,6,7};

  initial begin
    int a,b;

    q.push_back(8);
    q.push_front(0);

    foreach (q[i]) begin
      $display("q[%0d]=%0d",i,q[i]);
    end

    a = q.pop_front();
    b = q.pop_back();
    
    $display("q size = %0d ", q.size());
    q.delete();
    $display("q size = %0d ", q.size());

  end

endmodule

