`default_nettype none
/* 
    DESCRIPTION:
    Is responsible for taking data from the state layer and appropriate yielding pixels for Bek-Man
    when appropriate. Supports "rotating" the sprite in the 4 cardinal directions.

    DELAY: ???
*/
import project::clogb2;
import project::coord_t;
import project::rgb_t;

module becman_sprite(
    input logic i_clk, i_rst, i_en,
    input [2:0] i_rotate,
    input coord_t i_pacman, i_screen,
    output logic o_valid,
    output rgb_t o_color
);

logic [3:0] r_pix_count;
logic [3:0] r_line_count;

logic xvalid, yvalid, rom_valid;

assign rom_valid = xvalid & yvalid;
assign o_valid = rom_valid & rom_value;

reg [15:0] sprite_rom [4][16];

logic [3:0] rom_r, rom_c;
logic [1:0] rom_sel;

logic rom_value;

initial begin
    sprite_rom[0][00] = 16'b0000011111000000;
    sprite_rom[0][01] = 16'b0001111111110000;
    sprite_rom[0][02] = 16'b0001111111111000;
    sprite_rom[0][03] = 16'b0000111111111100;
    sprite_rom[0][04] = 16'b0000011111111100;
    sprite_rom[0][05] = 16'b0000001111111110;
    sprite_rom[0][06] = 16'b0000000111111110;
    sprite_rom[0][07] = 16'b0000000111111110;
    sprite_rom[0][08] = 16'b0000000111111110;
    sprite_rom[0][09] = 16'b0000001111111110;
    sprite_rom[0][10] = 16'b0000011111111100;
    sprite_rom[0][11] = 16'b0000111111111100;
    sprite_rom[0][12] = 16'b0001111111111000;
    sprite_rom[0][13] = 16'b0001111111110000;
    sprite_rom[0][14] = 16'b0000011111000000;
    sprite_rom[0][15] = 16'b0000000000000000;
end

initial begin
    sprite_rom[1][00] = 16'b0000011111000000;
    sprite_rom[1][01] = 16'b0001111111110000;
    sprite_rom[1][02] = 16'b0011111111111000;
    sprite_rom[1][03] = 16'b0011111111111100;
    sprite_rom[1][04] = 16'b0001111111111100;
    sprite_rom[1][05] = 16'b0000111111111110;
    sprite_rom[1][06] = 16'b0000011111111110;
    sprite_rom[1][07] = 16'b0000001111111110;
    sprite_rom[1][08] = 16'b0000011111111110;
    sprite_rom[1][09] = 16'b0000111111111110;
    sprite_rom[1][10] = 16'b0001111111111100;
    sprite_rom[1][11] = 16'b0011111111111100;
    sprite_rom[1][12] = 16'b0011111111111000;
    sprite_rom[1][13] = 16'b0001111111110000;
    sprite_rom[1][14] = 16'b0000011111000000;
    sprite_rom[1][15] = 16'b0000000000000000;
end

initial begin
    sprite_rom[2][00] = 16'b0000011111000000;
    sprite_rom[2][01] = 16'b0001111111110000;
    sprite_rom[2][02] = 16'b0011111111111000;
    sprite_rom[2][03] = 16'b0111111111111100;
    sprite_rom[2][04] = 16'b0011111111111100;
    sprite_rom[2][05] = 16'b0001111111111110;
    sprite_rom[2][06] = 16'b0000111111111110;
    sprite_rom[2][07] = 16'b0000011111111110;
    sprite_rom[2][08] = 16'b0000111111111110;
    sprite_rom[2][09] = 16'b0001111111111110;
    sprite_rom[2][10] = 16'b0011111111111100;
    sprite_rom[2][11] = 16'b0111111111111100;
    sprite_rom[2][12] = 16'b0011111111111000;
    sprite_rom[2][13] = 16'b0001111111110000;
    sprite_rom[2][14] = 16'b0000011111000000;
    sprite_rom[2][15] = 16'b0000000000000000;
end

initial begin
    sprite_rom[3][00] = 16'b0000011111000000;
    sprite_rom[3][01] = 16'b0001111111110000;
    sprite_rom[3][02] = 16'b0011111111111000;
    sprite_rom[3][03] = 16'b0111111111111100;
    sprite_rom[3][04] = 16'b0111111111111100;
    sprite_rom[3][05] = 16'b1111111111111110;
    sprite_rom[3][06] = 16'b1111111111111110;
    sprite_rom[3][07] = 16'b1111111111111110;
    sprite_rom[3][08] = 16'b1111111111111110;
    sprite_rom[3][09] = 16'b1111111111111110;
    sprite_rom[3][10] = 16'b0111111111111100;
    sprite_rom[3][11] = 16'b0111111111111100;
    sprite_rom[3][12] = 16'b0011111111111000;
    sprite_rom[3][13] = 16'b0001111111110000;
    sprite_rom[3][14] = 16'b0000011111000000;
    sprite_rom[3][15] = 16'b0000000000000000;
end


always_comb begin

    // Rotate 90 degreeish.
    if (i_rotate[0]) begin
        rom_c = r_line_count;
        rom_r = r_pix_count;
    end else begin
        rom_r = r_line_count;
        rom_c = r_pix_count;
    end
   
end

// Break this out to help infer RAMs.
always_ff @(posedge i_clk) begin
    rom_value <= sprite_rom[rom_sel][rom_r][rom_c];
end

always_comb begin
    if(rom_valid) begin
        o_color.r = {8{rom_value}};
        o_color.g = {8{rom_value}};
        o_color.b = {8{rom_value}};
    end else begin
        o_color = '0;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_pix_count <= '0;
        r_line_count <= '0;
        xvalid <= '0;
        yvalid <= '0;
        rom_sel <= '0;
    end else if (i_en) begin
        if (i_screen.x == i_pacman.x) begin
            xvalid <= 1'b1;
            if (i_screen.y == i_pacman.y) begin
                yvalid <= 1'b1;
            end
        end

        if (i_screen == '0) begin
            rom_sel <= rom_sel + 1;
        end

        if (xvalid) begin
            if (i_rotate[1]) begin
                r_pix_count <= r_pix_count - 1;
            end else begin
                r_pix_count <= r_pix_count + 1;
            end
        end

        if (r_pix_count == 15) begin
            xvalid <= 1'b0;
            if (r_line_count == 15) begin
                yvalid <= 1'b0;
            end
            if (yvalid) begin
                if (i_rotate[2]) begin
                    r_line_count <= r_line_count - 1;
                end else begin
                    r_line_count <= r_line_count + 1;
                end
            end
        end
    end
end

endmodule