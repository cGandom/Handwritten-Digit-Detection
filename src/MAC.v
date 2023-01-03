module MAC (clk, rst, init, enMac, data, weight, macResult); // in charge of Sum(W_i * x_i)
input clk;
input rst;
input init;
input enMac;
input [7:0] data;
input [7:0] weight;
output [20:0] macResult;

	wire [14:0] multiplyResult; //data * weight
	assign multiplyResult[13:0] = data[6:0] * weight[6:0];
	assign multiplyResult[14] = data[7] ^ weight[7];

	wire [20:0] accumulation; //macResult + multiplyResult

	SignMagnitudeAdder #(.WIDTH_A(21), .WIDTH_B(15), .WIDTH_RESULT(21)) accumulateAdder (
		.A(macResult), 
		.B(multiplyResult), 
		.result(accumulation)
		);

	Register #(.WIDTH(21)) macReg (
			.clk(clk),
			.rst(rst),
			.d(accumulation),
			.en(enMac),
			.init(init),
			.q(macResult)
			);

endmodule 