module ALU (SW, KEY, LEDR, HEX0, HEX2, HEX3, HEX4);
	input [7:0] SW;
	input [1:0] KEY;
	output [7:0] LEDR;
	output HEX0, HEX2, HEX3, HEX4;

	part2 p0 (
		.A (SW[7:4]),
		.B (SW[3:0]),
		.Function (~KEY), //pressed = 0, released = 1
		.ALUout (LEDR[7:0])
	);

	hex_decoder u0 (LEDR[7:4], HEX4);
	hex_decoder u2 (LEDR[3:0], HEX3);
	hex_decoder u3 (SW[7:4], HEX2);
	hex_decoder u4 (SW[3:0], HEX0);
	
endmodule

module part2(A, B, Function, ALUout);
	input [3:0] A, B;
	input [1:0] Function;
	output [7:0] ALUout;
	reg [7:0] ALUout;
	wire [4:0] RCAout;

	RCA_4_bits p1 (A [3:0], B [3:0], RCAout [4:0]);
	
	always @(*)
	begin
		case (Function)
			2'b00: ALUout = RCAout;
			2'b01: begin
				if (|{A, B}) 
					ALUout = 8'b00000001;
				else 
					ALUout = 8'b00000000;
				end
			2'b10: begin
				if (&{A, B})
					ALUout = 8'b00000001;
				else 
					ALUout = 8'b00000000;
				end
			2'b11: ALUout = {A, B};
			default: ALUout = 8'b00000000;
		endcase
	end
	
	
endmodule


//4-bits Ripple Carry Adder
module RCA_4_bits (A, B, RCAout);
	input [3:0] A, B;
	output [4:0] RCAout;
	wire w1, w2, w3;
	
	FA u0 (.a(A[0]), .b(B[0]), .c_in(1'b0), .s(RCAout[0]), .c_out(w1) );
	FA u1 (.a(A[1]), .b(B[1]), .c_in(w1), .s(RCAout[1]), .c_out(w2) );
	FA u2 (.a(A[2]), .b(B[2]), .c_in(w2), .s(RCAout[2]), .c_out(w3) );
	FA u3 (.a(A[3]), .b(B[3]), .c_in(w3), .s(RCAout[3]), .c_out(RCAout[4]) );
endmodule

//Each block of Ripple Carry Adder
module FA (a, b, c_in, s, c_out);
	input a, b, c_in;
	output s, c_out;
	
	assign s = a ^ b ^ c_in;
	assign c_out = (a & b) | (a & c_in) | (b & c_in);
endmodule 

module hex_decoder (c, display);
	input [3:0] c;
	output [6:0] display;
	assign c0 = c[0];
	assign c1 = c[1];
	assign c2 = c[2];
	assign c3 = c[3];

	assign display[0] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
	
	assign display[1] = (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
	
	assign display[2] = (~c3 & ~c2 & c1 & ~c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
	
	assign display[3] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0) + (c3 & ~c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
	
	assign display[4] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0);
	
	assign display[5] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & ~c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
	
	assign display[6] = (~c3 & ~c2 & ~c1 & ~c0) + (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0);
endmodule
