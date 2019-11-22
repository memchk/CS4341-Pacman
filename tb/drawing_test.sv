`default_nettype none
import project::rgb_t;
import project::coord_t;
import project::s_width_t;
import project::s_height_t;

module drawing_test (
    input logic i_clk, i_rst,
    input logic [3:0] i_joystick,
    output logic o_hsync, o_vsync,
    output s_width_t screen_x,
    output s_height_t screen_y,
    output logic [7:0] o_r, o_g, o_b
);
    logic vtg_hsync, vtg_vsync;
    coord_t vtg_screen;

    logic [1:0] hsync_dly, vsync_dly;
    coord_t screen_dly [1:0];

    coord_t pacman;
    logic [2:0] pacman_dir;

    rgb_t va_vport [1:0];
    logic [1:0] va_req;

    // assign o_hsync = hsync_dly[1];
    // assign o_vsync = vsync_dly[1];    
    assign screen_x = screen_dly[1][9:0];
    assign screen_y = screen_dly[1][19:10];

    logic vblank, hblank, blank;

    vtg #(
        .H_POL(0),
        .V_POL(0)
    ) vtg(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .o_hsync(vtg_hsync),
        .o_vsync(vtg_vsync),
        .o_vblank(vblank),
        .o_hblank(hblank),
        .o_blank(blank),
        .o_screen(vtg_screen)
    );

    game_state state (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(vblank),
        .i_joystick(i_joystick),
        .o_pacman(pacman),
        .o_pacman_dir(pacman_dir)
    ); 

    video_arbiter va (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_vport(va_vport),
        .i_req(va_req),
        .i_hsync(hsync_dly[1]),
        .i_vsync(vsync_dly[1]),
        .o_hsync(o_hsync),
        .o_vsync(o_vsync),
        .o_vport({o_r, o_g, o_b})
    );

    bekman_sprite bs (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(~blank),
        .i_pacman(pacman),
        .i_screen(vtg_screen),
        .o_color(va_vport[1]),
        .i_rotate(pacman_dir),
        .o_valid(va_req[1])
    );

    map_sprite mp (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(~blank),
        .i_screen(vtg_screen),
        .o_color(va_vport[0]),
        .o_valid(va_req[0])
    );

    // Delay by one since the video layer takes a clock cycle of delay.
    always_ff @(posedge i_clk) begin
        vsync_dly <= {vsync_dly[0], vtg_vsync};
        hsync_dly <= {hsync_dly[0], vtg_hsync};

        screen_dly[0] <= vtg_screen;
        screen_dly[1] <= screen_dly[0];
    end

endmodule