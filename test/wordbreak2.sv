
class node;
  int c[string] = '{default:0};
  int isWord;
  function new();
    isWord = 0;
  endfunction
endclass

module test;
  string s = "catsanddog";
  string words[$] = '{"cat","cats","and","sand","dog"};

  // recursive func
  // loop words substr ==
  //  
  // catsanddog
  // sanddog
  // dog
  //
  // map of first char to q of words
  //   we only look at words that match

  initial begin
         
  end

endmodule
