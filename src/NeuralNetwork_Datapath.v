module NeuralNetwork_Datapath (clk, rst, inputLayer, selStage, initNeurons, 
	enCounter62, enCounter30, enMac, enReLU, enHiddenLayerReg, enOutputLayerReg, 
	coCounter62, coCounter30, result);
input clk; 
input rst;
input [8*62-1:0] inputLayer;
input [1:0] selStage; //stage0=hiddenLayer[0:9]  stage1=hiddenLayer[10:19]  stage2=hiddenLayer[20:29] stage3=outputLayer
input initNeurons;
input enCounter62;
input enCounter30;
input enMac; 
input enReLU;
input [2:0] enHiddenLayerReg; //one en signal for each 10
input enOutputLayerReg;
output coCounter62;
output coCounter30;
output reg [3:0] result;

	/*========= Naming Wires And Variables =========*/
	genvar i,j,k;
	integer m;

	wire [7:0] inputLayer_Array[0:61];
	generate //converting flatten inputLayer to Array inputLayer;
		for (i = 0; i < 62; i = i+1) begin : flat_to_arr_input
			assign inputLayer_Array[i] = inputLayer[i*8+7 : i*8];
		end
	endgenerate

	/*========= Weights And Biases Memories =========*/
	reg [7:0] Bh_Array[0:29], Bo_Array[0:9];
	reg [7:0] Wh_Array[0:29][0:61], Wo_Array[0:9][0:29];
	
	/*========= Counters =========*/
	wire [5:0] counter62count;
	CounterN #(.WIDTH(6), .N(62)) counter62 (
			.clk(clk), 
			.rst(rst), 
			.en(enCounter62), 
			.count(counter62count), 
			.co(coCounter62)
			);

	wire [5:0] counter30count;
	CounterN #(.WIDTH(6), .N(30)) counter30 (
			.clk(clk), 
			.rst(rst), 
			.en(enCounter30), 
			.count(counter30count), 
			.co(coCounter30)
			);

	/*========= Layers Results Registers =========*/
	//Hidden Layer (Layer 2)
	wire [7:0] hiddenLayerRegIn[0:29], hiddenLayerRegOut[0:29];
	generate
		for (i = 0; i < 10; i = i+1) begin : hidden_layer_regs_stage0
			Register #(.WIDTH(8)) HiddenLayerReg (
				.clk(clk),
				.rst(rst),
				.d(hiddenLayerRegIn[i]),
				.en(enHiddenLayerReg[0]),
				.init(1'b0),
				.q(hiddenLayerRegOut[i])
				);
		end
		for (i = 10; i < 20; i = i+1) begin : hidden_layer_regs_stage1
			Register #(.WIDTH(8)) HiddenLayerReg (
				.clk(clk),
				.rst(rst),
				.d(hiddenLayerRegIn[i]),
				.en(enHiddenLayerReg[1]),
				.init(1'b0),
				.q(hiddenLayerRegOut[i])
				);
		end
		for (i = 20; i < 30; i = i+1) begin : hidden_layer_regs_stage2
			Register #(.WIDTH(8)) HiddenLayerReg (
				.clk(clk),
				.rst(rst),
				.d(hiddenLayerRegIn[i]),
				.en(enHiddenLayerReg[2]),
				.init(1'b0),
				.q(hiddenLayerRegOut[i])
				);
		end
	endgenerate

	//Output Layer (Layer 3)
	wire [7:0] outputLayerRegIn[0:9], outputLayerRegOut[0:9];
	generate
		for (i = 0; i < 10; i = i+1) begin : output_layer_regs_stage3
			Register #(.WIDTH(8)) OutputLayerReg (
				.clk(clk),
				.rst(rst),
				.d(outputLayerRegIn[i]),
				.en(enOutputLayerReg),
				.init(1'b0),
				.q(outputLayerRegOut[i])
				);
		end
	endgenerate

	/*========= Neurons Inputs Multiplexers =========*/
	wire [7:0] neuronDataInput, neuronWeightInput[0:9], neuronBiasInput[0:9];
	wire [7:0] stage0DataMuxOut, stage1DataMuxOut, stage2DataMuxOut, stage3DataMuxOut;
	wire [7:0] stage0WeightMuxOut[0:9], stage1WeightMuxOut[0:9], stage2WeightMuxOut[0:9], stage3WeightMuxOut[0:9];
	wire [7:0] stage0BiasMuxOut[0:9], stage1BiasMuxOut[0:9], stage2BiasMuxOut[0:9], stage3BiasMuxOut[0:9];

	//data//
	assign stage0DataMuxOut = inputLayer_Array[counter62count];
	assign stage1DataMuxOut = stage0DataMuxOut;
	assign stage2DataMuxOut = stage0DataMuxOut;
	assign stage3DataMuxOut = hiddenLayerRegOut[counter30count];
	Mux4x1 #(.WIDTH(8)) NeuronDataInputMux (
		.inp0(stage0DataMuxOut),
		.inp1(stage1DataMuxOut),
		.inp2(stage2DataMuxOut),
		.inp3(stage3DataMuxOut),
		.sel(selStage),
		.out(neuronDataInput)
		);
	
	//weight//
	generate
		for (i = 0; i < 10; i = i+1) begin : gen_weight_inputs
			assign stage0WeightMuxOut[i] = Wh_Array[i][counter62count];
			assign stage1WeightMuxOut[i] = Wh_Array[10+i][counter62count];
			assign stage2WeightMuxOut[i] = Wh_Array[20+i][counter62count];
			assign stage3WeightMuxOut[i] = Wo_Array[i][counter30count];	
			Mux4x1 #(.WIDTH(8)) NeuronWeightInputMux (
				.inp0(stage0WeightMuxOut[i]),
				.inp1(stage1WeightMuxOut[i]),
				.inp2(stage2WeightMuxOut[i]),
				.inp3(stage3WeightMuxOut[i]),
				.sel(selStage),
				.out(neuronWeightInput[i])
				);	
		end
	endgenerate
	
	//bias//
	generate
		for (i = 0; i < 10; i = i+1) begin : gen_bias_inputs
			assign stage0BiasMuxOut[i] = Bh_Array[i];
			assign stage1BiasMuxOut[i] = Bh_Array[10+i];
			assign stage2BiasMuxOut[i] = Bh_Array[20+i];
			assign stage3BiasMuxOut[i] = Bo_Array[i];
			Mux4x1 #(.WIDTH(8)) NeuronBiasInputMux (
				.inp0(stage0BiasMuxOut[i]),
				.inp1(stage1BiasMuxOut[i]),
				.inp2(stage2BiasMuxOut[i]),
				.inp3(stage3BiasMuxOut[i]),
				.sel(selStage),
				.out(neuronBiasInput[i])
				);	
		end
	endgenerate
	
	/*========= Neurons =========*/
	wire [7:0] neuronResult[0:9];
	generate
		for (i = 0; i < 10; i = i+1) begin : gen_neurons
			Neuron neuron (
				.clk(clk), 
				.rst(rst), 
				.init(initNeurons), 
				.enMac(enMac), 
				.enReLU(enReLU), 
				.data(neuronDataInput), 
				.weight(neuronWeightInput[i]), 
				.bias(neuronBiasInput[i]), 
				.neuronResult(neuronResult[i])
				);
			assign hiddenLayerRegIn[i] = neuronResult[i];
			assign hiddenLayerRegIn[10+i] = neuronResult[i];
			assign hiddenLayerRegIn[20+i] = neuronResult[i];
			assign outputLayerRegIn[i] = neuronResult[i];
		end
	endgenerate

	/*========= Classify Result =========*/
	reg [7:0] maxOutputData;
	always @* begin
		result = 4'b0;
		maxOutputData = outputLayerRegOut[0];
		for (m = 1; m < 10; m = m+1) begin
			if (maxOutputData < outputLayerRegOut[m]) begin
				result = m[3:0];
				maxOutputData = outputLayerRegOut[m];
			end
		end		
	end

endmodule 