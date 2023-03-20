
  //  s...
  //  ###.
  //  #...
  //  e.##

module test;
  int m[][] = '{ '{0,0,0,0}, '{1,1,1,0}, '{1,0,0,0}, '{0,0,1,1} };
  int dirs[][] = '{ '{-1,-1}, '{0,-1}, '{1,-1}, '{-1,0}, '{1,0}, '{-1,1}, '{0,1}, '{1,1} };
  int q[$][];
  int pos[];
  int x,y,nx,ny;
  int n = 4;
  int seen[4][4] = '{ default:0 };

  initial begin
    if ( m[0][0] == 1 ) $display("-1");
    q.push_back( {1,0,0} );
    while ( q.size() > 0 ) begin
      pos = q.pop_front();
      if ( pos[1] == 3 && pos[2] == 0 ) begin $display("%0d",pos[0]); break; end
      foreach (dirs[i]) begin
        nx = pos[1]+dirs[i][0];
        ny = pos[2]+dirs[i][1];
        if ( nx >= 0 && nx <  n &&
             ny >= 0 && ny <  n &&
             m[ nx ][ ny ] == 0 &&
             !seen[nx][ny] ) begin
          seen[nx][ny] = 1;
          q.push_back( { pos[0]+1, nx, ny } );
        end
      end
    end
    $finish;
  end
endmodule
