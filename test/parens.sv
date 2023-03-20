

module test;
  string s = "[][()]";
  //string s = "[";
  string stk[$];
  int ret = 1;
  string map[string];

  initial begin
    map["["] = "]";
    map["("] = ")";
    
    foreach(s[i]) begin
      if (s[i] == "[" || s[i] == "(") begin
        stk.push_back(s[i]);
      end
      if ( s[i] == ")" || s[i] == "]") begin
        $display("stk=%p s=%s",stk,s[i]);
       
        if (stk.size() == 0) begin 
          ret = 0;
          break;
        end
        if ( map[stk.pop_back()] != s[i] ) begin    
          ret = 0;
          break;
        end
      end
    end

    if ( stk.size() > 0 ) ret = 0;

    $display("ret=%d",ret);
     
  end


endmodule
