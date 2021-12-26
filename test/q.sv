
module tb;
  int q [$] = {1,2,3,4};

  initial begin
    q.push_back(2);
    $display("%p",q);
    q.sort();
    $display("%p",q);
    //foreach(q[i]) 
      //$display("%d",q[i]);
  end
endmodule
