`timescale 1ns/1ns
module TestBench();

	parameter NUMBER_OF_TESTS = 750;

	reg clk = 1, rst = 0;
	reg start;
	wire [8*62-1:0] inputLayer;
	wire [3:0] result;
	wire ready;
	
	reg [7:0] testData[0:NUMBER_OF_TESTS-1][0:61];
	reg [3:0] testLabel[0:NUMBER_OF_TESTS-1];

	integer m;
	genvar i,j;
	real correctLabelsNum = 0;

	NeuralNetwork neural_network(
		.clk(clk), 
		.rst(rst), 
		.start(start), 
		.inputLayer(inputLayer), 
		.result(result), 
		.ready(ready)
		);

	integer cyclenum = 0;
	always #150 clk = ~clk;
	always #300 cyclenum = cyclenum + 1;

	//Choose what test to put on input line
	reg [15:0] selTest = 0;
	generate
		for (i = 0; i < 62; i = i+1) begin : gen_input_layer
			assign inputLayer[i*8+7 : i*8] = testData[selTest][i];
		end
	endgenerate

	initial begin
		$readmemh("Input\ and\ Parameters/te_data_sm.dat", testData);
		$readmemh("Input\ and\ Parameters/te_lable_sm.dat", testLabel);
		$readmemh("Input\ and\ Parameters/b1_sm.dat", neural_network.datapath.Bh_Array);
		$readmemh("Input\ and\ Parameters/b2_sm.dat", neural_network.datapath.Bo_Array);
		$readmemh("Input\ and\ Parameters/w1_sm.dat", neural_network.datapath.Wh_Array);
		$readmemh("Input\ and\ Parameters/w2_sm.dat", neural_network.datapath.Wo_Array);
		rst = 0;
		start = 0;
		#200
		rst = 1;
		#400
		rst = 0;
		#400
	
		for (m = 0; m < NUMBER_OF_TESTS; m = m+1) begin
			selTest = m;
			#500
			start = 1;
			#500
			start = 0;
			#100
			while (!ready) #100;
			#500
			if (result == testLabel[m]) begin
				$display("test[%0d]\t\t: result=%0d\tCorrectLabel=%0d\t\t\tcorrect", m, result, testLabel[m]);
				correctLabelsNum = correctLabelsNum + 1;
			end
			else
				$display("test[%0d]\t\t: result=%0d\tCorrectLabel=%0d\t\t\tWRONG_RESULT", m, result, testLabel[m]);
		end

		$display("\nCorrect: %0d out of %0d", correctLabelsNum , NUMBER_OF_TESTS);
		$display("Accuracy: %.2f percent", (correctLabelsNum / NUMBER_OF_TESTS)*100);
		$stop;
	end


endmodule

