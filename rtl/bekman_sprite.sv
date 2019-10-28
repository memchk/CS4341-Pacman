`default_nettype none


import project::clogb2;
import project::coord_t;
import project::rgb_t;

module bekman_sprite(
    input logic i_clk, i_rst, i_en,
    input coord_t i_pacman, i_screen,
    output logic o_valid,
    output rgb_t o_color
);

logic [3:0] pix_count;
logic [3:0] line_count;

logic xvalid, yvalid;

assign o_valid = xvalid & yvalid;

reg [15:0] sprite_rom [15:0];


initial begin
    sprite_rom[00] = 16'b0000011111000000;
    sprite_rom[01] = 16'b0001111111110000;
    sprite_rom[02] = 16'b0011111111111000;
    sprite_rom[03] = 16'b0111111111111100;
    sprite_rom[04] = 16'b0111111111111100;
    sprite_rom[05] = 16'b1111111111111110;
    sprite_rom[06] = 16'b1111111111111110;
    sprite_rom[07] = 16'b1111111111111110;
    sprite_rom[08] = 16'b1111111111111110;
    sprite_rom[09] = 16'b1111111111111110;
    sprite_rom[10] = 16'b0111111111111100;
    sprite_rom[11] = 16'b0111111111111100;
    sprite_rom[12] = 16'b0011111111111000;
    sprite_rom[13] = 16'b0001111111110000;
    sprite_rom[14] = 16'b0000011111000000;
    sprite_rom[15] = 16'b0000000000000000;
end

always_ff @(posedge i_clk) begin
    if(o_valid) begin
        o_color.r <= {8{(sprite_rom[line_count][pix_count])}};
        o_color.g <= {8{(sprite_rom[line_count][pix_count])}};
        o_color.b <= '0;
    end else begin
        o_color <= '0;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        pix_count <= '0;
        line_count <= '0;
        xvalid <= '0;
        yvalid <= '0;
    end else if (i_en) begin
        if (i_screen.x == i_pacman.x) begin
            xvalid <= 1'b1;
            if (i_screen.y == i_pacman.y) begin
                yvalid <= 1'b1;
            end
        end

        if (xvalid) begin
            pix_count <= pix_count + 1;
        end

        if (pix_count == 15) begin
            pix_count <= '0;
            xvalid <= 1'b0;

            if (line_count == 15) begin
                line_count <= '0;
                yvalid <= 1'b0;
            end else if (yvalid) begin
                line_count <= line_count + 1;
            end
        end
    end
end

endmodule