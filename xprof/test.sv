// xrun test.sv -snprofilecpu -xprof
//
// 

function void a();
  int x;
  x = $urandom_range(1);
endfunction

function void b();
  int x;
  x = $urandom()%2;
endfunction

function void c();
  bit x;
  randomize(x);
endfunction
function void d();
  bit x;
  randcase
    1: x = 0;
    1: x = 1;
  endcase
endfunction

module tb;

  initial begin
    for (int i = 0;  i < 1000000; i++) a();
    for (int i = 0;  i < 1000000; i++) b();
    //for (int i = 0;  i < 1000000; i++) c();
    for (int i = 0;  i < 1000000; i++) d();
  end

endmodule

