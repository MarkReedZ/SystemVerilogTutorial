

module test;
  string s = "accccfbcabcab";
  string p = "a*c?b*cab*cab";
  string pats[$];
  int i,j,start;
  int star, mat;

  // Split pattern on *s.  O(p+s)
  // Match first and last pattern
  // loop the rest matching on first match

  //  "accccfbcabcab"; "a*c?b*cab*cab";
  //  "ccccfbcabcab"; "*c?b*cab*cab";
  //  "ccccfbcab"; "*c?b*cab*";
  //  "cab"; "*cab*";
  //  ""; "*"; match

  initial begin

    i = 0; start = 0;
    pats.push_back("");
    foreach(p[k]) begin
      if (p[k] == "*") begin
        pats.push_back("");
        i++;
      end else begin
        pats[i] = {pats[i] , p[k] };
      end
    end

    $display("pats=%p",pats);

    j = 0; star = 0;
    foreach(pats[i]) begin
      if (pats[i].size()==0) begin
        star = 1; continue;
      end
      if ( !star ) begin
        if ( pats[i] != s.substr(0,pats[i].size()+j-1) ) begin
          $display("no match");
          $finish;
        end
        s = s.substr(pats[i].size(),s.len()-1);
      end else begin
        j = 0; mat = 0;
        while (j+pats[i].size() < s.len()) begin
          if ( pats[i] == s.substr(j,j+pats[i].size()-1) ) begin
            mat = 1; break; 
          end
        end
      end
    end

    
/* 

    // split pattern by first *[+] last
    foreach(p[i]) begin
      if (p[i] == "*") break;
      f.push_back(p[i]);
    end 
    for(i=p.len()-1;i>0;i--) begin
      if (p[i] == "*") break;
      l.push_front(p[i]);
    end

    $display("f=%p l=%p",f,l);

    // Does the first match?
    diff = 0;
    if ( f.size() ) begin
      foreach(s[i]) begin
        if ( i >= f.size() ) break;
        if (s[i] != f[i]) begin
          if (f[i] != "?") begin
            diff = 1;
            break;
          end
        end
      end
    end

    if (diff) begin
      $display("no match");
      $finish;
    end
    s = s.substr(f.size(),s.len()-1);
    $display("after first s=%s",s);
    if (s.len() == 0 ) begin
      $display("match");
      $finish;
    end

    // Does the last match?
    diff = 0;
    if ( l.size() ) begin
      j = l.size();
      for(i=s.len()-1;i>=0;i--) begin
        j--;
        if (j<0) break;
        if (s[i] != l[j]) begin
          if (l[j] != "?") begin
            diff = 1;
            break;
          end
        end
      end
    end

    if (diff) begin
      $display("no match");
      $finish;
    end

    s = s.substr(0,s.len()-l.size()-1);
    $display("after last s=%s",s);
  */       
  end


endmodule
