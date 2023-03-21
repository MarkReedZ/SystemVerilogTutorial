
interface core_l2_if ( input clk );
    logic [7:0] vld;
    logic [7:0] [2:0] cmd;
    logic [7:0] [31:0] addr;
    logic [7:0] [31:0] data;
endinterface

interface l2_core_if ( input clk );
    logic [7:0]        resp_vld;
    logic [7:0] [2:0]  resp;
    logic [7:0] [31:0] data;
endinterface

interface mem_l2_if ( input clk );
    logic m_rsp_vld;
    logic [31:0] m_rsp_data;
endinterface

interface l2_mem_if ( input clk );
    logic mvld;
    logic mcmd;
    logic [31:0] maddr;
    logic [31:0] mdata;
endinterface

