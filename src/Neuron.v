module Neuron (clk, rst, init, enMac, enReLU, data, weight, bias, neuronResult); // in charge of ReLU(mac + b_i)
input clk;
input rst;
input init;
input enMac;
input enReLU;
input [7:0] data;
input [7:0] weight;
input [7:0] bias;
output [7:0] neuronResult;

	wire [20:0] macResult;
	MAC mac (
		.clk(clk), 
		.rst(rst), 
		.init(init), 
		.enMac(enMac),
		.data(data), 
		.weight(weight), 
		.macResult(macResult)
		); 
	
	wire [20:0] alignedBias; //Bias alignment
	assign alignedBias[19:0] = bias[6:0] * 8'b0111_1111;
	assign alignedBias[20] = bias[7];

	wire [20:0] BiasedMac; //macResult + alignedBias

	SignMagnitudeAdder #(.WIDTH_A(21), .WIDTH_B(21), .WIDTH_RESULT(21)) macAndBiasAdder (
		.A(macResult), 
		.B(alignedBias), 
		.result(BiasedMac)
		);

	wire [20:0] ShiftedBiasedMac; //shift result
	assign ShiftedBiasedMac[19:0] = BiasedMac[19:0] >> 9;
	assign ShiftedBiasedMac[20] = BiasedMac[20];

	wire [20:0] ReLUresult; //Apply Activition Function 
	assign ReLUresult = ShiftedBiasedMac[20]? 21'd0: ShiftedBiasedMac;

	wire [7:0] saturatedResult; //check for saturation and shrink to 8 bit
	assign saturatedResult = (|ReLUresult[19:7])? //is there any overflow or underflow?
					(ReLUresult[20]? 8'b1111_1111 /*for underflow*/ :8'b0111_1111 /*for overflow*/) 
				: {ReLUresult[20], ReLUresult[6:0]};

	Register #(.WIDTH(8)) macReg (
			.clk(clk),
			.rst(rst),
			.d(saturatedResult),
			.en(enReLU),
			.init(init),
			.q(neuronResult)
			);

endmodule

