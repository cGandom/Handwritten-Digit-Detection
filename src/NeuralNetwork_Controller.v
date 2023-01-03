module NeuralNetwork_Controller (clk, rst, start, coCounter62, coCounter30, selStage, initNeurons, 
	enCounter62, enCounter30, enMac, enReLU, enHiddenLayerReg, enOutputLayerReg, ready);
input clk;
input rst;
input start;
input coCounter62;
input coCounter30;
output reg [1:0] selStage;
output reg initNeurons;
output reg enCounter62;
output reg enCounter30;
output reg enMac;
output reg enReLU;
output reg [2:0] enHiddenLayerReg;
output reg enOutputLayerReg;
output reg ready;

	reg [4:0] ns;
	wire [4:0] ps;

	parameter Idle = 5'd0, 
		Stage0_Init = 5'd1, Stage0_Mac = 5'd2, Stage0_ReLU = 5'd3, Stage0_Save = 5'd4, 
		Stage1_Init = 5'd5, Stage1_Mac = 5'd6, Stage1_ReLU = 5'd7, Stage1_Save = 5'd8,
		Stage2_Init = 5'd9, Stage2_Mac = 5'd10, Stage2_ReLU = 5'd11, Stage2_Save = 5'd12,
		Stage3_Init = 5'd13, Stage3_Mac = 5'd14, Stage3_ReLU = 5'd15, Stage3_Save = 5'd16;

	always @* begin
		ns = 5'b0;
		case(ps) 
		Idle: ns = start? Stage0_Init: Idle;
		
		Stage0_Init: ns = Stage0_Mac;
		Stage0_Mac: ns = coCounter62? Stage0_ReLU: Stage0_Mac;
		Stage0_ReLU: ns = Stage0_Save;
		Stage0_Save: ns = Stage1_Init;

		Stage1_Init: ns = Stage1_Mac;
		Stage1_Mac: ns = coCounter62? Stage1_ReLU: Stage1_Mac;
		Stage1_ReLU: ns = Stage1_Save;
		Stage1_Save: ns = Stage2_Init;

		Stage2_Init: ns = Stage2_Mac;
		Stage2_Mac: ns = coCounter62? Stage2_ReLU: Stage2_Mac;
		Stage2_ReLU: ns = Stage2_Save;
		Stage2_Save: ns = Stage3_Init;

		Stage3_Init: ns = Stage3_Mac;
		Stage3_Mac: ns = coCounter30? Stage3_ReLU: Stage3_Mac;
		Stage3_ReLU: ns = Stage3_Save;
		Stage3_Save: ns = Idle;
		
		default: ns = Idle;
		endcase
	end

	always @(ps) begin
		selStage = 2'b0; enHiddenLayerReg = 3'b0;
		{initNeurons, enCounter62, enCounter30, 
		  enMac, enReLU, enOutputLayerReg, ready} = 9'b0;
		
		case(ps)
		Idle: ready = 1'b1;

		Stage0_Init: begin selStage=2'b00; initNeurons = 1'b1; end
		Stage0_Mac: begin selStage=2'b00; {enCounter62, enMac} = 2'b11; end
		Stage0_ReLU: begin selStage=2'b00; enReLU = 1'b1; end
		Stage0_Save: begin selStage=2'b00; enHiddenLayerReg[0] = 1'b1; end

		Stage1_Init: begin selStage=2'b01; initNeurons = 1'b1; end
		Stage1_Mac: begin selStage=2'b01; {enCounter62, enMac} = 2'b11; end
		Stage1_ReLU: begin selStage=2'b01; enReLU = 1'b1; end
		Stage1_Save: begin selStage=2'b01; enHiddenLayerReg[1] = 1'b1; end

		Stage2_Init: begin selStage=2'b10; initNeurons = 1'b1; end
		Stage2_Mac: begin selStage=2'b10; {enCounter62, enMac} = 2'b11; end
		Stage2_ReLU: begin selStage=2'b10; enReLU = 1'b1; end
		Stage2_Save: begin selStage=2'b10; enHiddenLayerReg[2] = 1'b1; end

		Stage3_Init: begin selStage=2'b11; initNeurons = 1'b1; end
		Stage3_Mac: begin selStage=2'b11; {enCounter30, enMac} = 2'b11; end
		Stage3_ReLU: begin selStage=2'b11; enReLU = 1'b1; end
		Stage3_Save: begin selStage=2'b11; enOutputLayerReg = 1'b1; end
		
		endcase
		
	end

	Register #(.WIDTH(5)) stateReg(
			.clk(clk), 
			.rst(rst), 
			.d(ns), 
			.en(1'b1), 
			.init(1'b0), 
			.q(ps)
			);

endmodule

