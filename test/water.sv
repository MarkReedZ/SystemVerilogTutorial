/*
    1
    1              1      
    1              1     1
    1  1           1     1
    1  1     1     1     1
    1  1     1     1     1
    1  1     1  1  1     1
    1  1     1  1  1  1  1
    1  1  1  1  1  1  1  1
 1  1  1  1  1  1  1  1  1
----------------------------
*/
module test;
  int ht[] = '{1,9,6,2,5,4,8,3,7};
  int l,r,w,max,area;

  initial begin

    w = ht.size()-1; l = 0; r = w; max = 0;

    for (; w>1; w--) begin
      if ( ht[l] < ht[r] ) begin
        l = l + 1;
        area = l*w;
        if ( area > max ) max = area;
      end else begin
        r = r - 1;
        area = r*w;
        if ( area > max ) max = area;
      end
    end

    $display("max=%d",max);
     
  end


endmodule
