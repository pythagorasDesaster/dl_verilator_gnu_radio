module counter(input clk, input reset, output reg [3:0] cnt);

	always @(posedge clk) begin
		if (reset) begin
			cnt <= 4'b0;
		end else begin
			cnt <= cnt + 4'd1;
		end
	end

endmodule

