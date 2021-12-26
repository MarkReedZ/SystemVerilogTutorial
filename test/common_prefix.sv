

module test;
  string strs[] = '{"aabc", "aabcd", "aaf"};
  string min,max;
  int i;

  initial begin
    strs.sort();
    min = strs[0];
    max = strs[strs.size()-1];
    $display("min=%s",min);
    $display("max=%s",max);
    i = 0; 
    while( i < min.len() ) begin
      if ( min[i] != max[i] ) break; 
      i++;
    end
   
    $display("i=%0d",i); 
    if (i == 0) 
      $display("\"\"");
    else
      $display("%s",min.substr(0,i-1));
  end

endmodule
