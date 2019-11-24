import project::rgb_t;
import project::coord_t;
import project::s_width_t;
import project::s_height_t;

module drawing_test (
    input logic i_clk, i_rst,
    input logic [3:0] i_joystick,
    output logic o_hsync, o_vsync,
    output logic [7:0] o_r, o_g, o_b
);
    logic vtg_hsync, vtg_vsync;
    coord_t vtg_screen;

    logic [1:0] hsync_dly, vsync_dly;

    coord_t becman;
    logic [2:0] becman_dir;

    rgb_t va_vport [1:0];
    logic [1:0] va_req;

    // assign o_hsync = hsync_dly[1];
    // assign o_vsync = vsync_dly[1];    

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
        .o_becman(becman),
        .o_becman_dir(becman_dir)
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

    becman_sprite bs (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(~blank),
        .i_becman(becman),
        .i_screen(vtg_screen),
        .o_color(va_vport[1]),
        .i_rotate(becman_dir),
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
    end

endmodule