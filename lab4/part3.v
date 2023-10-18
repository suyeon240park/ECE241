module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [3:0] Data_IN;
	output [3:0] Q;
	wire [3:0] w;
	wire ASClock = clock & ~(RotateRight & ASRight);
	sub_circuit s0(Data_IN[0], RotateRight, ParallelLoadn, Q[3], Q[1], clock, reset, Q[0]); 
	sub_circuit s1(Data_IN[1], RotateRight, ParallelLoadn, Q[0], Q[2], clock, reset, Q[1]); 
	sub_circuit s2(Data_IN[2], RotateRight, ParallelLoadn, Q[1], Q[3], clock, reset, Q[2]); 
	sub_circuit s3(Data_IN[3], RotateRight, ParallelLoadn, Q[2], Q[0], ASClock, reset, Q[3]);
endmodule
	
//collection of mux
module sub_circuit(Data_IN, RotateRight, ParallelLoadn, right, left, clock, reset, Q);
	input Data_IN, RotateRight, ParallelLoadn, right, left, clock, reset;
	output Q;
	wire [1:0] c;
	
	//two mux 2 to 1
	mux_2_to_1 m0 (right, left, RotateRight, c[0]);
	mux_2_to_1 m1 (Data_IN, c[0], ParallelLoadn, c[1]);

	d_ff d0 (reset, clock, c[1], Q);
endmodule 
	
module mux_2_to_1(x, y, s, m);
	input x, y, s;
	output m;
	
	assign m = s ? y : x;
endmodule 

module d_ff(reset, clock, Data, Q);
	input reset, clock, Data;
	output reg Q;

	always @ (posedge clock)
	begin 
		if (reset)
			Q <= 1'b0;
		else
			Q <= Data;
	end
endmodule
