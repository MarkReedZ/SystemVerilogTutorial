
module tb;
 
  initial tsk();
 
  initial begin
    $display("tb start");
    #30 disable tsk.BLKA;
  end

  task tsk();
    begin : BLKA
      #100 $display("A done");
    end
    
    begin : BLKB
      #10 $display("B start");
      #50 $display("B done");
    end
  endtask
endmodule
