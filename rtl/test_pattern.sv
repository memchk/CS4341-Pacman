import project::coord_t;
import project::rgb_t;

module test_pattern (
    input logic i_clk, i_rst,
    input coord_t i_screen,
    output rgb_t o_color
);

    coord_t r_screen;

    always_ff @(posedge i_clk) begin
        if(i_rst) begin
            o_color <= '0;
            r_screen <= '0;
        end else begin
            r_screen <= i_screen;
            o_color <= '0;

            if(r_screen.x == 0 || r_screen.y == 0) begin
                o_color <= '1;
            end

            if(r_screen.x == 799 || r_screen.y == 599) begin
                o_color <= '1;
            end
        end
    end

endmodule