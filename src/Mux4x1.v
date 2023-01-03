module Mux4x1 #(parameter WIDTH = 8) (inp0, inp1, inp2, inp3, sel, out);
input [WIDTH-1:0] inp0;
input [WIDTH-1:0] inp1;
input [WIDTH-1:0] inp2;
input [WIDTH-1:0] inp3;
input [1:0] sel;
output [WIDTH-1:0] out;

	assign out = (sel == 2'd0)? inp0:
			(sel == 2'd1)? inp1:
			(sel == 2'd2)? inp2:
			(sel == 2'd3)? inp3:
			{WIDTH{1'bz}};

endmodule 

