module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire oPlot;       // Pixel draw enable
   output wire oDone;       // goes high when finished drawing frame
   wire oLoadX, oLoadY, oLoadC, adderEn, blackEn;
   wire [5:0] count;
   wire [7:0] countX;
   wire [6:0] countY;
	
   control c0 (iClock, iBlack, iResetn, iLoadX, iPlotBox, count, countX, countY, oLoadX, oLoadY, oLoadC, oPlot, adderEn, oDone, blackEn);
   datapath d0 (iClock, iResetn, oLoadX, oLoadY, oLoadC, oPlot, adderEn, oDone, blackEn, count, iXY_Coord, iColour, oX, countX, oColour, oY, countY);
endmodule

module control (
	input iClock, iBlack, iResetn, iLoadX, iPlotBox,
	input [5:0] count,
	input [7:0] countX,
	input [6:0] countY,
	output reg oLoadX, oLoadY, oLoadC, oPlot, adderEn, oDone, blackEn);

	reg [2:0] PS, NS;

	localparam  X_load	= 3'd0, // load x
		    X_wait	= 3'd1, // wait for next clk cycle
		    Y_load	= 3'd2, // load y
		    Y_wait	= 3'd3,
		    Plot	= 3'd4, // Plot the box
		    Out		= 3'd5,
		    Black	= 3'd6;

	always@ (*)
	begin: state_table
		case (PS)
			X_load: NS = iLoadX ? X_wait : X_load;
			X_wait: NS = iLoadX ? X_wait : Y_load;
			Y_load: NS = iPlotBox ? Y_wait : Y_load;
			Y_wait: NS = iPlotBox ? Y_wait : Plot;
			Plot: NS = (count <= 6'd15) ? Plot : Out;
			Out: NS = X_load;
			Black: begin
				if (countX != 8'd160 & countY != 7'd120) NS = Black;
				else NS = Plot;
			end
		endcase
	end

	always@ (*)
	begin: enable_signals
		oLoadX = 1'b0;
		oLoadY = 1'b0;
		oLoadC = 1'b0;
		oPlot = 1'b0;
		adderEn = 1'b0;
		blackEn = 1'b0;
		oDone = 1'b0;

		case (PS)
			X_load: begin
				oLoadX = 1'b1;
			end
			Y_load: begin
				oLoadY = 1'b1;
				oLoadC = 1'b1;
			end
			Plot: begin
				oPlot = 1'b1;
				oLoadC = 1'b1;
				adderEn = 1'b1;
			end
			Out: begin
				oDone = 1'b1;
			end
			Black: begin
				oPlot = 1'b1;
				blackEn = 1'b1;
			end
		endcase
	end

	always@ (posedge iClock)
	begin
		if (!iResetn)
			PS <= X_load;
		else if (!Black) PS <= Black;
		else
			PS <= NS;
	end
endmodule


module datapath (
	input iClock, iResetn, oLoadX, oLoadY, oLoadC, oPlot, adderEn, oDone, blackEn,
	output reg [5:0] count,
	input [6:0] iXY_Coord,
	input [2:0] iColour,
	output reg [7:0] x, countX,
	output reg [2:0] colour,
	output reg [6:0] y, countY);

	reg [7:0] tempX;
	reg [6:0] tempY;
	
	always@ (posedge iClock)
	begin
		if (!iResetn) begin
			x <= 8'b0;
			y <= 7'b0;
			colour <= 3'b0;
			count <= 6'b0;
			countX <= 8'b0;
			countY <= 7'b0;
		end
		else begin
			if (oLoadX) begin
				tempX[7] <= 1'b0;
				tempX[6:0] <= iXY_Coord;
			end
			if (oLoadY) begin
				tempY <= iXY_Coord;
			end
			if (oLoadC) begin
				colour <= iColour;
			end
			if (adderEn) begin
				if (count == 6'b10000) count <= 6'b0;
				else count <= count + 1;
				x <= tempX + count[1:0];
				y <= tempY + count[3:2];
			end
			if (blackEn) begin
				if (countX == 8'd160 & countY != 7'd120) begin
					countX <= 8'b0;
					countY <= countY + 1;
				end
				else countX <= countX + 1;
				x <= countX;
				y <= countY;
				colour <= 3'b0;
			end
		end
	end

endmodule

