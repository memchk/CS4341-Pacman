import project::rgb_t;
import project::coord_t;

module drawing_test (
    input logic i_clk, i_rst,
    output logic o_hsync, o_vsync,
    output coord_t o_screen,
    output logic [7:0] o_r, o_g, o_b
);
    logic vtg_hsync, vtg_vsync;
    coord_t vtg_screen;

    logic [1:0] hsync_dly, vsync_dly;
    coord_t screen_dly [1:0];

    coord_t pacman;

    assign o_hsync = hsync_dly[1];
    assign o_vsync = vsync_dly[1];    
    assign o_screen = screen_dly[1];

    logic blank;

    vtg vtg(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .o_hsync(vtg_hsync),
        .o_vsync(vtg_vsync),
        .o_vblank(blank),
        .o_screen(vtg_screen)
    );

    game_state state (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(blank),
        .i_joystick(4'b0100),
        .o_pacman(pacman)
    ); 

    bekman_sprite bs (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(~blank),
        .i_pacman(pacman),
        .i_screen(vtg_screen),
        .o_color({o_r, o_g, o_b})
    );

    // Delay by one since the video layer takes a clock cycle of delay.
    always_ff @(posedge i_clk) begin
        vsync_dly <= {vsync_dly[0], vtg_vsync};
        hsync_dly <= {hsync_dly[0], vtg_hsync};

        screen_dly[0] <= vtg_screen;
        screen_dly[1] <= screen_dly[0];
    end

endmodule