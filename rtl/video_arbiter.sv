`default_nettype none

import project::clogb2;
import project::coord_t;
import project::rgb_t;

module video_arbiter(
    input logic i_clk, i_rst,
    input logic i_vsync, i_hsync,
    input logic [1:0] i_req,
    input rgb_t i_vport [1:0],
    output rgb_t o_vport,
    output logic o_vsync, o_hsync
);

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            o_vport <= '0;
            o_vsync <= '0;
            o_hsync <= '0;
        end else begin
            case (1'b1)
                i_req[1]:
                    o_vport <= i_vport[1];
                i_req[0]:
                    o_vport <= i_vport[0];
                default:
                    o_vport <= '0;
            endcase

            o_hsync <= i_hsync;
            o_vsync <= i_vsync;
        end
    end

endmodule