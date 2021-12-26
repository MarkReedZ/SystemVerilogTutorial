
class BTreeNode;
  int val;
  BTreeNode l,r;

  function new(int v);
    val = v; l = null; r = null;
  endfunction

endclass

module tb;

  initial begin
    BTreeNode root = new(5);
    $display("root.val=%0d",root.val);
  end

endmodule

