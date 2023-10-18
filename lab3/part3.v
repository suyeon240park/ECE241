module part3(A, B, Function, ALUout);
	parameter N = 4;	
	input [N-1:0] A, B;
	input [1:0] Function;
	output reg [(N-1)*2+1:0] ALUout;
	
	always @(*)
	begin
		case (Function)
			2'b00: ALUout = A + B;
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