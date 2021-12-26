


module test;
  int graph[][] = '{ '{1,2,3}, '{0}, '{0}, '{0} };
  int q[$][]; // { node, mask }
  int done_mask;
  int msk, n, steps;
  int item[];
  
  initial begin
    done_mask = (1<<graph.size())-1;
    steps = 0;

    foreach(graph[i]) begin
      q.push_back( '{ i, 1<<i } );
    end

    while ( q.size() ) begin
      // Loop all nodes reachable from this node
      for( int i=0; i<q.size(); i++ ) begin
        item = q.pop_front();
        n = item[0];
        msk = item[1] | (1 << n);
        $display("msk %0x done %0x",msk,done_mask);
        if ( msk == done_mask ) begin
          $display("steps=%0d",steps+1); 
          break;
        end

        // Add all neighbors
        foreach( graph[n][i] ) begin
          q.push_back( '{ graph[n][i], msk } );
        end

      end
      if ( msk == done_mask ) break;

      steps += 1;
    end 
  end


    
    
endmodule
