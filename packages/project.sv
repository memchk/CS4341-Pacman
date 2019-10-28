`ifndef PACKAGE_PROJECT
`define PACKAGE_PROJECT

package project;

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

parameter SCREEN_WIDTH = 800;
parameter SCREEN_HEIGHT = 600;

typedef logic [clogb2(SCREEN_WIDTH)-1:0] s_width_t;
typedef logic [clogb2(SCREEN_HEIGHT)-1:0] s_height_t;

typedef struct packed {
    s_height_t y;
    s_width_t x;
} coord_t;

typedef struct packed {
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
} rgb_t;

endpackage;
`endif