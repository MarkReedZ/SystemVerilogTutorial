
module tb;
  integer fd;
  string s;
  logic [7:0] mem[256];
  logic [7:0] mem2[256];
  int i, ret;
  int m[int];
  
  initial begin
    for (i=0;i<256;i++)
      mem[i] = $urandom();
    $display( "mem[0]=0x%0x", mem[0] );

    $sformat(s, "%0t", $time);
    fd = $fopen("delme.txt", "w");
    $fdisplay(fd, s);
    $fdisplay(fd, "12");
    $fdisplay(fd, "13");
    $fdisplay(fd, "14");
    $fclose(fd);

    fd = $fopen("delme.txt","r");
    while (!$feof(fd)) begin
      ret = $fgets(s,fd);
      $display("read: %s", s);
    end
    $fclose(fd);

    fd = $fopen("delme.txt","r");
    while (!$feof(fd)) begin
      ret = $fscanf(fd, "%s",s);
      $display("read: %s", s);
    end
    $fclose(fd);

    $writememh("memh", mem);
    $readmemh("memh", mem2);
    $display( "mem2[0]=0x%0x", mem2[0] );

    i = 0;
    fd = $fopen("memh","r");
    while (!$feof(fd)) begin
      ret = $fgets(s,fd);
      $display("read: %s %0x", s, s.atohex());
      i = i + 1;
      if (i > 8) break;
    end
    $fclose(fd);

    m[2] = 22;
    m[3] = 32;
    m[4] = 42;
    m[5] = 52;
    m[6] = 62;
    $writememh("maph", m);

  end

endmodule
