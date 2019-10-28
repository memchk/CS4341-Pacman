`default_nettype none
import project::coord_t;
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
    parameter H_FRONT_PORCH = 40,
    parameter H_BACK_PORCH = 88,
    parameter H_PULSE = 128 
)(
    input logic i_clk, i_rst,
    output logic o_hsync, o_vsync, o_vblank, o_hblank, o_blank,
    output coord_t o_screen
);

localparam H_TOTAL = H_FRONT_PORCH + H_BACK_PORCH + H_PULSE + ACTIVE_WIDTH;
localparam V_TOTAL = V_FRONT_PORCH + V_BACK_PORCH + V_PULSE + ACTIVE_HEIGHT;

// Taken from https://stackoverflow.com/a/5276596
// Function to calculate ceil(log2(x)) of a number,
// useful for determining bit widths for registers.
function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
endfunction

// Pixel and line counters.
logic [clogb2(V_TOTAL-1):0] r_line_cnt;
logic [clogb2(H_TOTAL-1):0] r_pix_cnt;

assign o_screen.x = r_pix_cnt[clogb2(ACTIVE_WIDTH)-1:0];
assign o_screen.y = r_line_cnt[clogb2(ACTIVE_HEIGHT)-1:0];

// This is a strobe signal that is high 1-clock cycle before eol,
// allowing us to enable our registers off of it.
logic r_eol;

// o_blank is anytime we are not in the active area of the display.
assign o_blank = o_hblank || o_vblank;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_line_cnt <= '0;
        r_pix_cnt <= '0;
    end else begin
        r_pix_cnt <= r_pix_cnt + 1;

        // EOL Strobe Generator. Anything that happens on the EOL for the screen is keyed off of this.
        // This prevents expensive equality logic from being duplicated everywhere, and reduces WNS.
        if (r_pix_cnt == H_TOTAL - 2) begin
            r_eol <= 1'b1;
        end else begin
            r_eol <= 1'b0;
        end

        // On the EOL increment the line counter, reset the pixel counter, and disable hblank.
        if (r_eol) begin
            r_line_cnt <= r_line_cnt + 1;
            r_pix_cnt <= '0;
            o_hblank <= '0;
        end

        // Enable H blanking at the end of the active width.
        if (r_pix_cnt == ACTIVE_WIDTH - 1) begin
            o_hblank <= 1'b1;
        end

        // Handle the H Sync pulse appropriately.
        if (r_pix_cnt == ACTIVE_WIDTH + H_FRONT_PORCH - 1) begin
            o_hsync <= 1'b0;
        end

        if (r_pix_cnt == ACTIVE_WIDTH + H_FRONT_PORCH + H_PULSE - 1) begin
            o_hsync <= 1'b1;
        end

        // Vertical Reset, blanking.
        if (r_eol && r_line_cnt == V_TOTAL - 1) begin
            r_line_cnt <= '0;
            o_vblank <= '0;
        end

        // This mirrors the horizontal code above, except it is triggered by the eol to ensure
        // proper line timings.
        if (r_eol && r_line_cnt == ACTIVE_HEIGHT + V_FRONT_PORCH - 1) begin
            o_vsync <= 1'b0;
        end

        if (r_eol && r_line_cnt == ACTIVE_HEIGHT + V_FRONT_PORCH + V_PULSE - 1) begin
            o_vsync <= 1'b1;
        end

        if (r_eol && r_line_cnt == ACTIVE_HEIGHT - 1) begin
            o_vblank <= 1'b1;
        end
        
    end
end

endmodule