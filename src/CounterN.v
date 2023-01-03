module CounterN #(parameter WIDTH = 8, parameter N = 10) (clk, rst, en, count, co);
input clk;
input rst;
input en;
output reg [WIDTH-1:0] count;
output co;

	always @(posedge clk or posedge rst) begin
		if (rst)
			count <= {WIDTH{1'b0}};
		else if (en) begin
			if (count == N-1)
				count <= {WIDTH{1'b0}};
			else
				count <= count + 1'b1;
		end
	end
	
	assign co = (count == N-1);

endmodule 

