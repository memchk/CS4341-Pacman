import project::coord_t;
import project::clogb2;

/* 
    DESCRIPTION: 
    Produces VGA timing signals based upon the configured parameters. Outputs
    additional blanking signals for timing the rest of the project.

    DELAY: N/A.
*/
module vtg #(
    parameter ACTIVE_WIDTH = 800,
    parameter ACTIVE_HEIGHT = 600,
    parameter V_FRONT_PORCH = 1,
    parameter V_BACK_PORCH = 23,
    parameter V_PULSE = 4,
    parameter logic V_POL = 1,
    parameter H_FRONT_PORCH = 40,
    parameter H_BACK_PORCH = 88,
    parameter H_PULSE = 128,
    parameter logic H_POL = 1
)(
    input logic i_clk, i_rst,
    output logic o_hsync, o_vsync, o_vblank, o_hblank, o_blank,
    output coord_t o_screen
);

localparam H_TOTAL = H_FRONT_PORCH + H_BACK_PORCH + H_PULSE + ACTIVE_WIDTH;
localparam V_TOTAL = V_FRONT_PORCH + V_BACK_PORCH + V_PULSE + ACTIVE_HEIGHT;

// Pixel and line counters.
logic [clogb2(V_TOTAL-1):0] r_line_cnt;
logic [clogb2(H_TOTAL-1):0] r_pix_cnt;

assign o_screen.x = r_pix_cnt[clogb2(ACTIVE_WIDTH)-1:0];
assign o_screen.y = r_line_cnt[clogb2(ACTIVE_HEIGHT)-1:0];

// This is a strobe signal that is high 1-clock cycle before eol,
// allowing us to enable our registers off of it.
logic r_end_fporch;

// o_blank is anytime we are not in the active area of the display.
assign o_blank = o_hblank || o_vblank;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_pix_cnt <= '0;
        r_end_fporch <= '0;
    end else begin
        if (r_pix_cnt == ACTIVE_WIDTH + H_FRONT_PORCH - 2) begin
            r_end_fporch <= 1'b1;
        end else begin
            r_end_fporch <= 1'b0;
        end
        
        if (r_end_fporch) begin
            o_hsync <= H_POL;
        end

        if (r_pix_cnt == ACTIVE_WIDTH + H_FRONT_PORCH + H_PULSE - 1) begin
            o_hsync <= ~H_POL;
        end

        if (r_pix_cnt == ACTIVE_WIDTH - 1) begin
            o_hblank <= 1'b1;
        end

        if (r_pix_cnt == H_TOTAL - 1) begin
            o_hblank <= 1'b0;
            r_pix_cnt <= '0;
        end else begin
            r_pix_cnt <= r_pix_cnt + 1;
        end
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_line_cnt <= '0;
    end else begin

        if (r_end_fporch) begin
            if(r_line_cnt == V_TOTAL - 1) begin
                r_line_cnt <= '0;
                o_vblank <= 1'b0;
            end else begin
                r_line_cnt <= r_line_cnt + 1;
            end
        end

        if (r_end_fporch && r_line_cnt == ACTIVE_HEIGHT - 1) begin
            o_vblank <= 1'b1;
        end

        if (r_end_fporch && r_line_cnt == ACTIVE_HEIGHT + V_FRONT_PORCH - 1) begin
            o_vsync <= V_POL;
        end

        if (r_end_fporch && r_line_cnt == ACTIVE_HEIGHT + V_FRONT_PORCH + V_PULSE - 1) begin
            o_vsync <= ~V_POL;
        end
    end
end

endmodule