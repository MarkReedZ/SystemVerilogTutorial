
class HSCA;
  rand int Comp0;
  rand int Comp1;
endclass

class pkt;
  rand bit[3:0] addr;
  rand bit[3:0] data;

  rand int hsum[32][2];
  rand int hsum2[32][2];
  rand HSCA hscale[9][32];
  rand bit signed [13:0] coeff_2d[3][2][9];

  function new();
    foreach (hscale[ii,jj]) begin
      hscale[ii][jj] = new();
    end
  endfunction

  function void print();
    foreach (hsum[ii,jj]) begin
      $display(" %d,%d == %d ", ii, jj, hsum[ii][jj]);
    end
  endfunction


    constraint coeff_c {
         foreach(coeff_2d[i,j,k]) {
             coeff_2d[i][j][k]  inside {[-8191:8191]};
	           //coeff_2d[i][j].sum() with(32'(item)) == 32'h1000;
             //coeff_2d[i][j].sum() == 32'h1000;
             coeff_2d[i][j].sum() == 14'sh1000;
         }
    }

/*
    constraint sum1_c {
        foreach (hsum[ii,]) {
            hsum[ii][0] == (
                int'(hscale[0][ii].Comp0) +
                int'(hscale[1][ii].Comp0) +
                int'(hscale[2][ii].Comp0) +
                int'(hscale[3][ii].Comp0) +
                int'(hscale[4][ii].Comp0) +
                int'(hscale[5][ii].Comp0) +
                int'(hscale[6][ii].Comp0) +
                int'(hscale[7][ii].Comp0) +
                int'(hscale[8][ii].Comp0));
            hsum[ii][1] == (
                int'(hscale[0][ii].Comp1) +
                int'(hscale[1][ii].Comp1) +
                int'(hscale[2][ii].Comp1) +
                int'(hscale[3][ii].Comp1) +
                int'(hscale[4][ii].Comp1) +
                int'(hscale[5][ii].Comp1) +
                int'(hscale[6][ii].Comp1) +
                int'(hscale[7][ii].Comp1) +
                int'(hscale[8][ii].Comp1));
        }
    }
    constraint sum2_c {
        foreach( hsum2[ii,] ) {
          hsum2[ii][0] == hscale.sum() with (int'(item[ii].Comp0)); 
          hsum2[ii][1] == hscale.sum() with (int'(item[ii].Comp1)); 
        }
    }

    constraint scale_c {

        foreach (hscale[ii,jj]) {
            hscale[ii][jj].Comp0 inside {[-32768 : 32767]};
            hscale[ii][jj].Comp1 inside {[-32768 : 32767]};
        }


  }
*/
endclass

module top;
  pkt pk = new();

  initial begin
    repeat ( 5000 ) begin
      void'(pk.randomize());
    end
    //pk.print();    
/*
    foreach( pk.coeff_2d[i,j,] ) begin
        
      	$display(" %d ", pk.coeff_2d[i][j].sum() );
    end
    foreach( pk.hsum[ii,j] ) begin
      if ( pk.hsum[ii][j] != pk.hsum2[ii][j] ) begin
      	$display(" %d != %d ", pk.hsum[ii][j], pk.hsum2[ii][j]);
      end
      //$display(" %d == %d ", pk.hsum[0][0], pk.hsum2[0][0]);
    end
*/
  end
endmodule
