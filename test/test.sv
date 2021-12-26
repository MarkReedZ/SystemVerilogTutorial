
module AND_N #(parameter N=4) ( input i, output o );
  assign o = i;
endmodule

module test;
  wire a;
  wire b;

  //a <= 0;

  AND_N #(.N(8)) inst(.i(a),.o(b));

  //#10;
  //a <= 1;
  //#10;
  //a <= 0;
  //$finish;

//Associative array indexed with integer
function void test_assoc_array();
  //An associative array of integers indexed with some string
  int assoc_test[string];

  string indx;
  assoc_test["A"] = 1; 
  assoc_test["B"] = 2; 
  assoc_test["C"] = 3; 
  if(assoc_test.first(indx)) begin
    do begin
      $display("assoc_test[%s]=%0d",indx,assoc_test[indx]);
    end while (assoc_test.next(indx));
  end  
endfunction

function void test_bit_count();
  static int n = $urandom();
  static int cnt;
  static int x = n;
  while (x) begin
    cnt = cnt + (x&1);
    x = (x >> 1); 
  end

  $display("n: 32'h%0h",n);
  $display("n: 32'b%b",n);
  $display("cnt: %0d", cnt);

endfunction

class wid;
  int id;
  bit b;
endclass : wid

function void test_q();
  wid q[$];
  static reg x = 32'b1111;

    wid w;
    static int n = $urandom_range(20,40);
    for (int i=0; i<n; i++ ) begin
      w = new;
      w.id = i;
      w.b = $urandom_range(0,1);
      q.push_back(w);
      $display("id:%02d b:%b", q[$].id, q[$].b);
     

    end

    for (int i=0; i < q.size(); i++) begin
      if ( q[i].b ) 
        q.delete(i--);
    end 

    foreach (q[i]) begin
      $display("id:%02d b:%b", q[i].id, q[i].b);
      assert(!q[i].b) else $fatal;
      if ( q[i].b )
        $display("ERROR queue has an item with b1");
    end

  $display( "~x = %b", ~x );
  $display( "!x = %b", !x );
 
endfunction

  string num = "0x100";
  int washex[int];

  semaphore key;

  int arr[10] = '{ 0,1,2,3,4,5,6,7,8,9 };
  int res[$];
  int dyn[];

initial begin

  dyn = new [5];
  $display("%p",dyn);
  //test_assoc_array();
  //test_bit_count();
  //test_q();

  //static int q[$:10] = { 1,2,3,4,5 }; 
  //q = { q, 6 };

  //foreach (q[i]) begin
    //$display("q %d", q[i]);
  //end  
/*
  static string a[] = { "0x10", "12", "22" };
  static int num[] = { 0, 0, 0 };

  static mailbox mbx = new(2);

  key = new (1);

  foreach (a[i]) begin
    if ( a[i][1] == "x" ) begin
      num[i] = a[i].atohex();
      washex[i] = 1;
    end else begin
      num[i] = a[i].atoi(); 
      washex[i] = 0;
    end
  end

  foreach (num[i]) begin
    $display("num %d", num[i]);
  end  

  key.get(1);
  key.put(1);        

  res = arr.find(x) with (x>3);
  $display("rest: %p", res);    

  //$display("num %s %d %0x", num, num.atohex(), num.atohex());
  
*/
  
end

endmodule
