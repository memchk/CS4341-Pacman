`include "environment.sv"

module vga_to_hdmi(
    input logic i_pix_clk, i_ser_clk, i_rst,
    input logic i_hsync, i_vsync, i_blanking,
    input logic [7:0] i_r, i_g, i_b,
    output logic o_channel_0, o_channel_1, o_channel_2
);

logic [9:0] c_channel_0, c_channel_1, c_channel_2;

tmds_encoder channel_O (
    .i_clk           (i_pix_clk),
    .i_rst           (i_rst),
    .i_ctrl_valid    (i_blanking),
    .i_ctrl          ({i_vsync, i_hsync}),
    .i_data          (i_r),
    .o_tmds          (c_channel_0)
);

tmds_encoder channel_1 (
    .i_clk           (i_pix_clk),
    .i_rst           (i_rst),
    .i_ctrl_valid    ('0),
    .i_ctrl          ('0),
    .i_data          (i_g),
    .o_tmds          (c_channel_1)
);

tmds_encoder channel_2 (
    .i_clk           (i_pix_clk),
    .i_rst           (i_rst),
    .i_ctrl_valid    ('0),
    .i_ctrl          ('0),
    .i_data          (i_b),
    .o_tmds          (c_channel_2)
);

endmodule