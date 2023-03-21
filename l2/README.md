
# Cache Coherency Verification

Here we have an L2 that handles coherency for a cluster of 8 cores following the ACE protocol.  

# Run

```
xrun top.sv l2.sv
```

# ACE Protocol

https://developer.arm.com/documentation/ihi0022/e/ACE-Protocol-Specification/About-ACE/Coherency-overview?lang=en

### Coherency Model

The ACE protocol enables master components to determine whether a cache line is the only copy of a particular memory location, or if there might be other copies of the same location, so that:

- if a cache line is the only copy, a master component can change the value of the cache line without notifying any other master components in the system

- if a cache line might also be present in another cache, a master component must notify the other caches, using an appropriate transaction.

### Cache States

The cache line characteristics are:

- Valid, Invalid
When valid, the cache line is present in the cache. When invalid, the cache line is not present in the cache.

- Unique, Shared
When unique, the cache line exists only in one cache. When shared, the cache line might exist in more than one cache, but this is not guaranteed.

- Clean, Dirty
When clean, the cache does not have responsibility for updating main memory. When dirty, the cache line has been modified with respect to main memory, and this cache must ensure that main memory is eventually updated.

### Cache State Rules

The rules that apply to the cache states are:

- A line in a Unique state must only be in one cache.
- A line that is in more than one cache must be in a Shared state in every cache it is in.
- When a cache obtains a new copy of a line, other caches that also have a copy of the line, and might have the line in a Unique state, must be notified to hold the line in a Shared state.
- When a cache discards a copy of a line, there is no requirement to inform other caches that also have a copy of the line. This means that a line in a Shared state might be held in only one cache.
- A line that has been updated, relative to main memory, must be in a Dirty state in one cache.
- A line that has been updated, relative to main memory, and is in more than one cache, must be in a Dirty state in only one cache.

# TODO

- Switch to AXI / ACE
- Handle dirty lines with L1 castouts 
- Handle L2 full - currently the L2 has an infinite size
- Driver - Delays, Overlapping 



