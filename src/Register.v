module Register #(parameter WIDTH = 8) (clk, rst, d, en, init, q);
input clk;
input rst;
input [WIDTH-1:0] d;
input en;
input init;
output reg [WIDTH-1:0] q;

	always @(posedge clk or posedge rst) begin
		if (rst)
			q <= {WIDTH{1'b0}};
		else if (init)
			q <= {WIDTH{1'b0}};
		else if (en)
			q <= d;
	end

endmodule

