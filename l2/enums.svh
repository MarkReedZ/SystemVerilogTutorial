
`ifndef __ENUMS_SV_
`define __ENUMS_SV_
typedef enum { READSHARED = 0,
               READUNIQUE = 1,
               MAKEUNIQUE = 2 } cmd_t;

typedef enum { READDATA = 0,
               INVALIDATE = 1
             } resp_t;
`endif
