

module test;
  //int hts[] = '{0,1,0,2,1,0,1,3,2,1,2,1};
  int hts[] = '{4,2,0,3,2,5};
  int sum,l,r,ht,sum2, lv, min;
  initial begin
    sum = hts.sum();

    l = 0; r = hts.size()-1; ht = 0; sum2 = 0; lv = 0;
    while ( l < r ) begin
     
      min = (hts[l] > hts[r]) ? hts[l]: hts[r];
       
      if ( min > lv ) begin
        sum2 += (min-lv)*(r-l);
        lv = min;
      end
      
      if ( hts[l] < hts[r] ) l++; 
      else if ( hts[r] < hts[l] ) r--; 
      else if ( hts[r] == hts[l] ) begin r--; l++; end
      
    end
    $display("sum=%0d sum2=%0d",sum,sum2);
  end
endmodule
