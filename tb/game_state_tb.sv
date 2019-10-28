module game_state_tb (
    input logic i_clk, i_rst,
    input logic [3:0] i_joystick
);

    logic vtg_vblank;

    game_state state (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(vtg_vblank),
        .i_joystick(i_joystick)
    );

    vtg vtg (
        .i_clk(i_clk),
        .i_rst('0),
        .o_vblank(vtg_vblank)
    );

endmodule