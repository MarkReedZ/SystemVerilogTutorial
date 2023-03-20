
module test;
    //== State enumeration
    parameter [2:0] // auto enum state_info
                       SM_IDLE =  3\='b000,
                       SM_SEND =  3\='b001,
                       SM_WAIT1 = 3\='b010;
    //== State variables
    reg [2:0]  /* auto enum state_info */
               state_r;  /* auto state_vector state_r */
    reg [2:0]  /* auto enum state_info */
               state_e1;

    /*AUTOASCIIENUM("state_r", "state_ascii_r", "SM_")*/
endmodule

