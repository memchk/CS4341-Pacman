import project::clogb2;
import project::coord_t;
import project::rgb_t;

module map_sprite(
    input logic i_clk, i_rst, i_en,
    input coord_t i_screen,
    output logic o_valid,
    output rgb_t o_color
);

logic [5:0] ram_addr_x;
logic [4:0] ram_addr_y;

logic tile_value, addr_valid;
assign o_valid = tile_value && addr_valid;

map_ram mr (
    .i_clk(i_clk),
    .i_en(i_en),
    .i_write(1'b0),
    .i_tile_x(ram_addr_x),
    .i_tile_y(ram_addr_y),
    .o_tile_value(tile_value)
);

always_comb begin
    if(o_valid) begin
        o_color = '0;
        o_color.b = {8{tile_value}};
    end else begin
        o_color = '0;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        ram_addr_x <= '0;
        ram_addr_y <= '0;
    end else if (i_en) begin
        ram_addr_x <= 6'((i_screen.x >> 4));
        ram_addr_y <= 5'((i_screen.y >> 4));
        
        if(i_screen.y <= 10'b0111111111) begin
            addr_valid <= 1'b1;
        end else begin
            addr_valid <= 1'b0;
        end
    end
end

endmodule