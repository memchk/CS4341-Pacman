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
    input logic [2:0] i_rotate,
    input coord_t i_becman, i_screen,
    output logic o_valid,
    output rgb_t o_color
);

logic [3:0] r_pix_count;
logic [3:0] r_line_count;

logic xvalid, yvalid, rom_valid;
logic rom_value;

assign rom_valid = xvalid & yvalid;
assign o_valid = rom_valid & rom_value;

reg [15:0] sprite_rom [63:0];

logic [3:0] rom_r, rom_c;
logic [1:0] rom_sel;

initial begin
    sprite_rom[00] = 16'b0000011111000000;
    sprite_rom[01] = 16'b0001111111110000;
    sprite_rom[02] = 16'b0001111111111000;
    sprite_rom[03] = 16'b0000111111111100;
    sprite_rom[04] = 16'b0000011111111100;
    sprite_rom[05] = 16'b0000001111111110;
    sprite_rom[06] = 16'b0000000111111110;
    sprite_rom[07] = 16'b0000000111111110;
    sprite_rom[08] = 16'b0000000111111110;
    sprite_rom[09] = 16'b0000001111111110;
    sprite_rom[10] = 16'b0000011111111100;
    sprite_rom[11] = 16'b0000111111111100;
    sprite_rom[12] = 16'b0001111111111000;
    sprite_rom[13] = 16'b0001111111110000;
    sprite_rom[14] = 16'b0000011111000000;
    sprite_rom[15] = 16'b0000000000000000;

    sprite_rom[16] = 16'b0000011111000000;
    sprite_rom[17] = 16'b0001111111110000;
    sprite_rom[18] = 16'b0011111111111000;
    sprite_rom[19] = 16'b0011111111111100;
    sprite_rom[20] = 16'b0001111111111100;
    sprite_rom[21] = 16'b0000111111111110;
    sprite_rom[22] = 16'b0000011111111110;
    sprite_rom[23] = 16'b0000001111111110;
    sprite_rom[24] = 16'b0000011111111110;
    sprite_rom[25] = 16'b0000111111111110;
    sprite_rom[26] = 16'b0001111111111100;
    sprite_rom[27] = 16'b0011111111111100;
    sprite_rom[28] = 16'b0011111111111000;
    sprite_rom[29] = 16'b0001111111110000;
    sprite_rom[30] = 16'b0000011111000000;
    sprite_rom[31] = 16'b0000000000000000;

    sprite_rom[32] = 16'b0000011111000000;
    sprite_rom[33] = 16'b0001111111110000;
    sprite_rom[34] = 16'b0011111111111000;
    sprite_rom[35] = 16'b0111111111111100;
    sprite_rom[36] = 16'b0011111111111100;
    sprite_rom[37] = 16'b0001111111111110;
    sprite_rom[38] = 16'b0000111111111110;
    sprite_rom[39] = 16'b0000011111111110;
    sprite_rom[40] = 16'b0000111111111110;
    sprite_rom[41] = 16'b0001111111111110;
    sprite_rom[42] = 16'b0011111111111100;
    sprite_rom[43] = 16'b0111111111111100;
    sprite_rom[44] = 16'b0011111111111000;
    sprite_rom[45] = 16'b0001111111110000;
    sprite_rom[46] = 16'b0000011111000000;
    sprite_rom[47] = 16'b0000000000000000;

    sprite_rom[48] = 16'b0000011111000000;
    sprite_rom[49] = 16'b0001111111110000;
    sprite_rom[50] = 16'b0011111111111000;
    sprite_rom[51] = 16'b0111111111111100;
    sprite_rom[52] = 16'b0111111111111100;
    sprite_rom[53] = 16'b1111111111111110;
    sprite_rom[54] = 16'b1111111111111110;
    sprite_rom[55] = 16'b1111111111111110;
    sprite_rom[56] = 16'b1111111111111110;
    sprite_rom[57] = 16'b1111111111111110;
    sprite_rom[58] = 16'b0111111111111100;
    sprite_rom[59] = 16'b0111111111111100;
    sprite_rom[60] = 16'b0011111111111000;
    sprite_rom[61] = 16'b0001111111110000;
    sprite_rom[62] = 16'b0000011111000000;
    sprite_rom[63] = 16'b0000000000000000;
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
    rom_value <= sprite_rom [{rom_sel, rom_r}][rom_c];
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
        if (i_screen.x == i_becman.x) begin
            xvalid <= 1'b1;
            if (i_screen.y == i_becman.y) begin
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