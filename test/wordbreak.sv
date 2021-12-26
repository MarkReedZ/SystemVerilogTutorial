
class node;
  node c[string] = '{default:null};
  int isWord;
  function new();
    isWord = 0;
  endfunction
endclass

class Trie;
  node root;
  int cache[string];

  function new();
    root = new();
  endfunction

  function void addWord(string s);
    node n = root;
    node t;
    int l = s.len()-1;
    $display("l=%d",l);
    foreach(s[i]) begin
      if ( !n.c.exists(s[i]) ) begin
        t = new();
        if ( i == l ) t.isWord = 1;
        n.c[s[i]] = t;
      end else begin
        if ( i == l ) n.c[s[i]].isWord = 1;
      end
      $display(" s=%s i %d isWord %d", s.substr(0,i), i, n.c[s[i]].isWord );
      n = n.c[s[i]];
    end
  endfunction

  function automatic int search(string s);
    node n = root;

    if ( cache.exists(s) ) return cache[s];

    if ( s.len() < 1 ) return 1;
    foreach(s[i]) begin
      if ( n.c[s[i]] == null ) 
        return 0;
      n = n.c[s[i]];
      $display(" s=%s char %s isWord %d %p", s.substr(0,i), s[i], n.isWord, n.c );
      if ( n.isWord ) 
        if ( search( s.substr(i+1,s.len()-1) ) ) begin cache[s] = 1; return 1; end
    end 
  endfunction

endclass

module test;

  string s = "catsanddog";
  string words[$] = '{"cat","cats","and","sand","dog"};
  Trie trie;

  initial begin
    trie = new();
    foreach (words[i]) begin
      trie.addWord(words[i]); 
    end     
    $display("s=%s search=%d", s, trie.search(s));
  end

endmodule















