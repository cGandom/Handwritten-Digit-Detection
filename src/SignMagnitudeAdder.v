module SignMagnitudeAdder #(parameter WIDTH_A = 32, parameter WIDTH_B = 32, parameter WIDTH_RESULT = 32) (A, B, result);
input [WIDTH_A - 1:0] A;
input [WIDTH_B - 1:0] B;
output [WIDTH_RESULT - 1:0] result;

	
	assign result[WIDTH_RESULT-2:0] = (A[WIDTH_A-1] ~^ B[WIDTH_B-1])? A[WIDTH_A-2:0] + B[WIDTH_B-2:0] //same sign
				:(A[WIDTH_A-2:0] > B[WIDTH_B-2:0])? A[WIDTH_A-2:0] - B[WIDTH_B-2:0] //abs(A) bigger, result sign = sign(A)
				: B[WIDTH_B-2:0] - A[WIDTH_A-2:0]; //abs(B) bigger, result sign = sign(B)
	assign result[WIDTH_RESULT-1] = (A[WIDTH_A-1] ~^ B[WIDTH_B-1])? A[WIDTH_A-1]
				:(A[WIDTH_A-2:0] > B[WIDTH_B-2:0])? A[WIDTH_A-1]
				: B[WIDTH_B-1];


endmodule 