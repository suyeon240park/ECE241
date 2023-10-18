module part2(Clock, Reset_b, Data, Function, ALUout);

	input [1:0] Function;
	input [3:0] Data;
	input Reset_b;
	input Clock;

	output [7:0] ALUout;
	wire [7:0] pre_reg_ALUout;
	
	register reg1(Clock, Reset_b, pre_reg_ALUout, ALUout);
	ALU alu1(Data, ALUout[3:0],  Function, ALUout, pre_reg_ALUout);
	
			
endmodule 



module ALU (A, B, Func, pre, alu_out,);

input  [3:0] A,B;
input [1:0] Func;
input [7:0] pre;
output reg [7:0] alu_out;


always@(*)
	begin
			case (Func)
				2'b00: alu_out= A+B;

				2'b01: alu_out=A*B;

				2'b10:  alu_out=B<<A;

				2'b11: alu_out=pre;

				default: alu_out= 8'b0;
			endcase
	end
endmodule



module register (clk ,reset_b ,
							regin, regout,) ;
							
	input wire[7:0] regin;		
	input wire reset_b;
	input wire clk;
	output reg [7:0] regout;	

	always@ ( posedge clk )
	begin
			if ( reset_b ) regout <= 8'b0;
			else regout <= regin  ;
	end
endmodule 