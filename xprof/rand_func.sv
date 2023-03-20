// xrun test.sv -snprofilecpu -xprof
//
// 

class RandTest;
  int q1[$];
  int q2[$];
  int q3[$];
  int sel;
  bit q1_empty, q2_empty, q3_empty;

  function void setup();
    for (int i = 0;  i < $urandom()%100; i++) q1.push_back( $urandom() );
    for (int i = 0;  i < $urandom()%100; i++) q2.push_back( $urandom() );
    for (int i = 0;  i < $urandom()%100; i++) q3.push_back( $urandom() );
    q1_empty = q1.size() == 0;
    q2_empty = q2.size() == 0;
    q3_empty = q3.size() == 0;
  endfunction

  function void bad();
    void'(std::randomize(sel) with{
                        sel inside {[0:2]};
                        (q1.size() > 0  && q2.size() == 0 && q3.size() == 0) ->  sel == 1 ;
                        (q1.size() == 0 && q2.size() > 0  && q3.size() == 0) ->  sel == 0 ;
                    });
  endfunction

  function void good();
    void'(std::randomize(sel) with{
                        sel inside {[0:2]};
                        ( !q1_empty  &&  q2_empty && q3_empty) ->  sel == 1 ;
                        (  q1_empty  && !q2_empty && q3_empty) ->  sel == 0 ;
                    });
  endfunction

endclass

module tb;
  RandTest rt = new();

  initial begin
    rt.setup();
    for (int i = 0;  i < 100; i++) rt.bad();
    for (int i = 0;  i < 100; i++) rt.good();
  end

endmodule

