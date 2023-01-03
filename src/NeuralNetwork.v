module NeuralNetwork (clk, rst, start, inputLayer, result, ready);
input clk;
input rst;
input start;
input [8*62-1:0] inputLayer;
output [3:0] result;
output ready;
	
	wire initNeurons, enCounter62, enCounter30, enMac, enReLU, enOutputLayerReg, coCounter62, coCounter30;
	wire [1:0] selStage;
	wire [2:0] enHiddenLayerReg;

	NeuralNetwork_Datapath datapath(
			.clk(clk), 
			.rst(rst), 
			.inputLayer(inputLayer),
			.selStage(selStage), 
			.initNeurons(initNeurons), 
			.enCounter62(enCounter62), 
			.enCounter30(enCounter30), 
			.enMac(enMac), 
			.enReLU(enReLU), 
			.enHiddenLayerReg(enHiddenLayerReg), 
			.enOutputLayerReg(enOutputLayerReg), 
			.coCounter62(coCounter62), 
			.coCounter30(coCounter30), 
			.result(result)
			);

	NeuralNetwork_Controller controller (
			.clk(clk), 
			.rst(rst), 
			.start(start), 
			.coCounter62(coCounter62), 
			.coCounter30(coCounter30), 
			.selStage(selStage), 
			.initNeurons(initNeurons), 
			.enCounter62(enCounter62), 
			.enCounter30(enCounter30), 
			.enMac(enMac), 
			.enReLU(enReLU), 
			.enHiddenLayerReg(enHiddenLayerReg), 
			.enOutputLayerReg(enOutputLayerReg), 
			.ready(ready)
			);

endmodule 