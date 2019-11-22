module game_state_tb (
    input logic i_clk, i_rst, i_en,
    input logic [3:0] i_joystick,
    output [9:0] pacman_x, pacman_y
);
    game_state state (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en),
        .i_joystick(i_joystick),
        .o_pacman({pacman_y, pacman_x}),
        .o_pacman_dir()
    );
endmodule