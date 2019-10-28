`default_nettype none
/* 
    DESCRIPTION: 
    Encodes Input Data + Control Signals into 10-bit TMDS encoded signals.
    Parts of this algorithm were taken from: http://hamsterworks.co.nz/mediawiki/index.php/DVI-D_Serdes#TMDS_encoder.vhd,
    principally the numeric trick to calculate disparity. This implementaton improves on the cited reference by introducing
    a register in between the computation stages, in order to reduce WNS. In addition, this implementation is in SysVerilog
    instead of VHDL.

    DELAY: ???
*/
module tmds_encoder(
    input logic i_clk, i_rst,
    input logic i_ctrl_valid,
    input logic [1:0] i_ctrl,
    input logic [7:0] i_data,
    output logic [9:0] o_tmds
);

logic [7:0] c_xnor, c_xor;
logic [8:0] r_sel;
logic signed [3:0] r_bias;

// Piplining Logic.
logic r_ctrl_valid;
logic [1:0] r_ctrl;

/* verilator lint_off UNOPTFLAT */
/* UNOPTFLAT is ignored here as verilator has a hard time checking the appropriate
 * access through loops.
 */
logic [3:0] c_count_ones;
logic signed [3:0] c_disparity;
/* verilator lint_on UNOPTFLAT */

/* 
 * STAGE 1: 
 * Minimization computation.
 *
 * DESCRIPTION:
 * As part of transisition minimization, the system calculates
 * the sequential XOR and XNOR of the channel in parallel.
 */
always_comb begin
    c_xor[0] = i_data[0];
    c_xnor[0] = i_data[0];

    /* verilator lint_off ALWCOMBORDER */
    /*- Verilator has a hard time with loops, this is why we explicitly ignore warnings here. */
    foreach ( i_data[i] ) begin
        c_count_ones += {3'b000, i_data[i]};
    end

    for (int i=1; i<8; i++) begin
        c_xor[i] = i_data[i] ^ c_xor[i - 1];
        c_xnor[i] = i_data[i] ~^ c_xnor[i - 1];
    end
    /* verilator lint_on ALWCOMBORDER */
end


/* 
 * STAGE 1R: Transision minimization selection
 * Description: Either the XORed or XNORed version of the data is selected,
 * the criteria being which ever produces the lowest number of resulting
 * transistions on the output. This result is then clocked into a register
 * to minimize the long-path caused by the sequential calculation above.
 */
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_sel <= '0;
    end else begin
        if (c_count_ones > 4'd4 || (c_count_ones == 4'd4 && !i_data[0])) begin
            r_sel <= {1'b0, c_xnor};
        end else begin
            r_sel <= {1'b1, c_xor};
        end

        // Piplining the ctrl variables to the next stage.
        r_ctrl_valid <= i_ctrl_valid;
        r_ctrl <= i_ctrl;
    end
end

/* 
 * STAGE 2: Disparity calculation 
 */
always_comb begin
    c_disparity = 4'b1100;
    foreach ( r_sel[i] ) begin
        c_disparity += {3'b000, r_sel[i]};
    end
end

/*
 * STAGE 2R: Inversion selection and output.
 */
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_tmds <= '0;
    end else begin
        if (r_ctrl_valid) begin
            case (r_ctrl)
                2'b00 : o_tmds <= 10'b0010101011;
                2'b01 : o_tmds <= 10'b0010101010;
                2'b10 : o_tmds <= 10'b1101010100;
                2'b11 : o_tmds <= 10'b1101010101;
            endcase
            // All of the control symbols are balanced, so we reset the bias.
            r_bias <= '0;
        end else begin
            if (r_bias == '0 || c_disparity == '0) begin
                if (!r_sel[8]) begin
                    o_tmds <= {2'b10, ~r_sel[7:0]};
                    r_bias <= r_bias - c_disparity;
                end else begin
                    o_tmds <= {2'b01, r_sel[7:0]};
                    r_bias <= r_bias + c_disparity;
                end
            end else if (c_disparity[3] ~^ r_bias[3]) begin
                o_tmds <= {1'b1, r_sel[8], ~r_sel[7:0]};
                r_bias <= r_bias + {3'b000, r_sel[8]} - c_disparity;
            end else begin
                o_tmds <= {1'b0, r_sel[8], r_sel[7:0]};
                r_bias <= r_bias - {3'b000, ~r_sel[8]} + c_disparity;
            end
        end
    end
end
endmodule