
// cabac
//function string getPal( string s, int i, int j );
    
  //return "";
//endfunction

module test;
  string s = "bcbzbcadfcdf";
  //int cnt[string] = '{default:0};
  int ispal[20][20];
  int i,j,mi,mj,maxlen;
  int cnt;

  initial begin
    cnt = 0;
    ispal = '{default:0};

    for (i=0;i<s.len()-1;i++) begin
      ispal[i][i] = 1;
    end

    maxlen = 1; mi = 0; mj = 0;

    for (i = s.len()-2; i >= 0; i--) begin
      for (j=i+1; j<s.len(); j++) begin
        cnt += 1;
        if (s[i] == s[j]) begin
          if ( (j-i)==1 || ispal[i+1][j-1]) begin
            ispal[i][j] = 1;
            if ( j-i+1 > maxlen ) begin
              maxlen = j-i+1; mi = i; mj = j;
            end
          end
        end
      end
       
    end 

    $display("longest palin is %s",s.substr(mi,mj));
    $display("cnt=%0d",cnt);

/*
    foreach(s[i]) begin
      if (cnt.exists(s[i])) nodups = 0;
      cnt[s[i]]++; 
    end

    if (nodups) begin
      $display("%s",s[0]);
      $finish;
    end

     
    foreach(s[i]) begin
      if ( cnt[s[i]] > 1 ) begin
        t = getPal( s.substr(i,s.len()-1) );
      end
    end
*/
    
     
  end
endmodule
