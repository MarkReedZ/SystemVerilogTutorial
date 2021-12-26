

function automatic void mergeSort( ref int list[$] );
  int mid,i,j,k;
  int left[$];
  int right[$];
  if (list.size() < 2) return;

  mid = list.size()/2;
  left = list[0:mid-1];
  right = list[mid:list.size()-1];

  mergeSort(left); mergeSort(right);

  i = 0; j = 0; k = 0;

  while ( i < left.size() && j < right.size() ) begin
    if ( left[i] <= right[j] ) list[k++] = left[i++];
    else                       list[k++] = right[j++];
  end
  
  while ( i < left.size()  ) list[k++] = left[i++];
  while ( j < right.size() ) list[k++] = right[j++];
  
endfunction

module test;
  int l[$] = '{5,2,4,9,6,2,7,43,1};

  initial begin
    mergeSort(l); 
    $display("Sorted: %p",l);
  end
endmodule
