// tb_sweep.v - test suite for Sweep.v, focused on the phase_out sync flag.
//
// Checks:
//   1. While on_in=0: phase_out=0 and signal_out=0.
//   2. While sweeping: whenever signal_out is rising, phase_out (sampled the
//      cycle that produced that step) is 1; whenever falling, it is 0. The
//      triangle must exhibit both rising and falling segments.
//   3. After on_in is deasserted: phase_out returns to 0.
//
// signal_out and phase_out are both registered from current_val_f/state_f on
// the same edge, so they share a generation; the step from sig[i-1]->sig[i] is
// governed by the direction captured in phase[i-1]. We therefore compare each
// delta against the *previous* cycle's phase (prev_phase).

`timescale 1ns / 1ps

module tb_sweep;
    localparam SZ = 16;

    reg                     clk = 0;
    reg                     on  = 0;
    reg  signed [15:0]      minv = -16'sd100;
    reg  signed [15:0]      maxv =  16'sd100;
    reg         [31:0]      step = 32'd655360;   // 10 raw units/cycle (10 << 16)

    wire signed [SZ+1:0]    sig;
    wire                    phase;

    integer errors = 0, n_up = 0, n_dn = 0, i;
    reg signed [SZ+1:0]     prev_sig;
    reg                     prev_phase;

    always #5 clk = ~clk;

    Sweep #(.SIGNAL_OUT_SIZE(SZ)) dut (
        .clk_in(clk), .on_in(on),
        .minval_in(minv), .maxval_in(maxv), .stepsize_in(step),
        .signal_out(sig), .phase_out(phase)
    );

    initial begin
        // --- Test 1: disabled -> phase low, output zero ---
        on = 1'b0;
        repeat (10) @(posedge clk);
        #1;
        if (phase !== 1'b0) begin
            errors = errors + 1; $display("FAIL: phase_out not 0 while off (=%b)", phase);
        end
        if (sig !== 0) begin
            errors = errors + 1; $display("FAIL: signal_out not 0 while off (=%0d)", sig);
        end

        // --- Test 2: sweeping -> phase tracks ramp direction ---
        on = 1'b1;
        @(posedge clk); #1;
        prev_sig = sig; prev_phase = phase;
        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk); #1;
            if (sig > prev_sig) begin
                n_up = n_up + 1;
                if (prev_phase !== 1'b1) begin
                    errors = errors + 1;
                    $display("FAIL@%0d rising (%0d->%0d) but phase was %b", i, prev_sig, sig, prev_phase);
                end
            end else if (sig < prev_sig) begin
                n_dn = n_dn + 1;
                if (prev_phase !== 1'b0) begin
                    errors = errors + 1;
                    $display("FAIL@%0d falling (%0d->%0d) but phase was %b", i, prev_sig, sig, prev_phase);
                end
            end
            prev_sig = sig; prev_phase = phase;
        end
        if (n_up < 5) begin errors = errors + 1; $display("FAIL: too few rising samples (%0d)", n_up); end
        if (n_dn < 5) begin errors = errors + 1; $display("FAIL: too few falling samples (%0d)", n_dn); end

        // --- Test 3: disable again -> phase low ---
        on = 1'b0;
        repeat (3) @(posedge clk); #1;
        if (phase !== 1'b0) begin
            errors = errors + 1; $display("FAIL: phase_out not 0 after off (=%b)", phase);
        end

        if (errors == 0)
            $display("RESULT: ALL PASS (%0d rising, %0d falling samples)", n_up, n_dn);
        else
            $display("RESULT: %0d FAIL", errors);
        $finish;
    end
endmodule
