
# Cache Coherency Verification

Here we have an L2 that handles coherency for a cluster of 8 cores following the ACE protocol.  

# Run

```
xrun top.sv l2.sv
```

# TODO

- Switch to AXI / ACE
- Handle dirty lines with L1 castouts 
- Handle L2 full - currently the L2 has an infinite size

