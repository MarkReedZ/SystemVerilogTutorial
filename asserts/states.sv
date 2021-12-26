

`define IS_IDLE (curState == idle)
`define IS_S1   (curState == s1)
`define IS_S2   (curState == s2)
`define IS_S3   (curState == s3)
`define IS_S4   (curState == s4)
`define IS_S5   (curState == s5)
`define IS_S6   (curState == s6)
`define IS_S7   (curState == s7)

module FSM(input clk, rstn, start);
  typedef enum logic[6:0] { idle = 7'b000_0000,
                              s1 = 7'b000_0001,
                              s2 = 7'b000_0010,
                              s3 = 7'b000_0100,
                              s4 = 7'b000_1000,
                              s5 = 7'b001_0000,
                              s6 = 7'b010_0000,
                              s7 = 7'b100_0000} state_t;
  state_t curState;
  state_t nextState;

  always_ff @(posedge clk) begin
    if (!rstn) 
      curState = idle;
    else
      curState = nextState;
  end

  always_comb begin
    nextState = curState;

    case (curState)
      idle:     if (start) nextState <= s1;
      s1:       nextState <= s2; 
      s2:       nextState <= s3; 
      s3:       nextState <= s4;
      s4:       nextState <= s5; 
      s5:       nextState <= s6; 
      s6:       nextState <= idle;
    endcase
  end

  default disable iff (!rstn);

  assert property( disable iff (0) @(posedge clk) !rstn ##1 !rstn |-> (curState == idle));

  covergroup cgFSM @(posedge clk);
    START: coverpoint start;
    STATE: coverpoint curState {
      bins s1 = ( idle => s1 );
      bins s2 = ( s1   => s2 );
      bins s3 = ( s2   => s3 );
      bins s4 = ( s3   => s4 );
      bins s5 = ( s4   => s5 );
      bins s6 = ( s5   => s6 );
      bins s6_idle = ( s6 => idle );
    }
    STXST: cross START,STATE;
    
  endgroup

  assert property(@(posedge clk) $onehot0(curState));

  assert property(@(posedge clk) `IS_IDLE && start |=> `IS_S1)
    else $error("Failed to transition from idle to s1 on start");
  assert property(@(posedge clk) `IS_S1 |=> `IS_S2)
    else $error("Failed to transition from s1 to s2");
  assert property(@(posedge clk) `IS_S2 |=> `IS_S3)
    else $error("Failed to transition from s2 to s3");
  assert property(@(posedge clk) `IS_S3 |=> `IS_S4)
    else $error("Failed to transition from s3 to s4");
  assert property(@(posedge clk) `IS_S4 |=> `IS_S5)
    else $error("Failed to transition from s4 to s5");
  assert property(@(posedge clk) `IS_S5 |=> `IS_S6)
    else $error("Failed to transition from s5 to s6");
  assert property(@(posedge clk) `IS_S6 |=> `IS_IDLE)
    else $error("Failed to transition from s6 to idle");

endmodule


module tb;
  reg clk,rstn,start;
 
  always #5 clk = ~clk;
 
  FSM fsm(clk,rstn,start);

  initial begin
    {clk,rstn,start} <= 0;
    $monitor("%03t: start=%0d state=%0x",$time, start, fsm.curState);
    #20 rstn <= 1;
    @(posedge clk);
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $finish;
  end
endmodule
