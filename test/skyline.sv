
// Current ht.  Move x to the edge of the next bldg.
//


module test;
  int bldgs[][] = '{ '{2,9,10}, '{3,7,15}, '{5,12,12}, '{15,20,10}, '{19,24,8} };
  int x,ht,nht;
  int pts[$][2];
  int bs[][];

  initial begin

    x = bldgs[0][0];
    ht = 0;
    while ( x <= (bldgs[bldgs.size()-1][1]+1) ) begin
      bs = bldgs.find(b) with (b[0]<=x && b[1]>=x); bs = bs.max(b) with (b[2]);
      if (bs.size()==0) nht = 0;
      else              nht = bs[0][2];
      if (nht != ht) begin
        pts.push_back( {x,ht} );
        ht = nht;
        pts.push_back( {x,ht} );
      end
      x++;
    end
    $display("%p",pts);

  end

endmodule
