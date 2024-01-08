// square falling down
module fallingSquare(	
		CLOCK_50,						//	On Board 50 MHz
		SW, 								// On Board Switches
		KEY,							   // On Board Keys
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						   //	VGA Blue[9:0]
	);

	input		    CLOCK_50;			//	50 MHz
	input	 [3:0] KEY;					// Keys
	input  [9:0] SW;					// Switches
	output		 VGA_CLK;   		//	VGA Clock
	output		 VGA_HS;				//	VGA H_SYNC
	output		 VGA_VS;				//	VGA V_SYNC
	output		 VGA_BLANK_N;		//	VGA BLANK
	output		 VGA_SYNC_N;		//	VGA SYNC
	output [7:0] VGA_R;   			//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output [7:0] VGA_G;	 			//	VGA Green[7:0]
	output [7:0] VGA_B;   			//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	wire go, erase, plotEn, update, reset;
	
	wire [5:0] plotCounter;
	wire [7:0] xCounter;
	wire [6:0] yCounter;
	wire [25:0] freq;

	// Create an Instance of a VGA controller 
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(go),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	controlPath c(CLOCK_50, resetn, plotCounter, 
					  xCounter, yCounter, freq,
					  go, erase, update, plotEn, reset);
	
	dataPath d(CLOCK_50, resetn, plotEn, go, erase, update, reset,
				  x, y, colour, plotCounter, xCounter, yCounter, freq);
endmodule

module controlPath(input clk, resetn,
    input [5:0] plotCounter,
    input [7:0] xCounter,
    input [6:0] yCounter,
    input [25:0] freq,
    output reg go, erase, update, plotEn, reset);
    
    reg [2:0] currentSt, nextSt;
    
    localparam RESET = 3'b0,
        DRAW = 3'b001,
        WAIT = 3'b010,
        UPDATE = 3'b100,
        CLEAR = 3'b101;

    always @(*)
    begin
        case(currentSt)
            RESET: nextSt = DRAW;
            DRAW: begin
                if (plotCounter <= 6'd15) nextSt = DRAW;
                else nextSt = WAIT;
            end
            WAIT: begin
                if (freq < 26'd12499999) nextSt = WAIT;
                else nextSt = UPDATE;
            end
            UPDATE: nextSt = DRAW;
            CLEAR: nextSt = (yCounter == 7'd120) ? RESET : CLEAR;
            default: nextSt = RESET;
        endcase
    end

    always @(*)
    begin
        go = 1'b0;
        update = 1'b0;
        reset = 1'b0;
        erase = 1'b0;
        plotEn = 1'b0;
        
        case(currentSt)
            RESET: reset = 1'b1;
            DRAW: begin
                go = 1'b1;
                erase = 1'b0;
                plotEn = 1'b1;
            end
            UPDATE: update = 1'b1;
            CLEAR: begin
                erase = 1'b1;
                go = 1'b1;
            end
        endcase
    end

    always @(posedge clk)
    begin
        if (!resetn) currentSt <= CLEAR;
        else currentSt <= nextSt;
    end 
endmodule

module dataPath(input clk, resetn, plotEn, go, erase, update, reset,
    output reg [7:0] X,
    output reg [6:0] Y,
    output reg [2:0] CLR,
    output reg [5:0] plotCounter,
    output reg [7:0] xCounter,
    output reg [6:0] yCounter,
    output reg [25:0] freq);

    always @(posedge clk)
    begin
        if (reset || !resetn) begin
            X <= 8'd156;
            Y <= 7'b0;
            plotCounter <= 6'b0;
            xCounter <= 8'b0;
            yCounter <= 7'b0;
            CLR <= 3'b100;
            freq <= 25'd0;
        end
        else begin
            if (freq == 26'd12499999) freq <= 26'd0;
            else freq <= freq + 1;
            
            if (plotEn) begin
                CLR <= 3'b100;
                if (plotCounter == 6'b10000) plotCounter <= 6'b0;
                else plotCounter <= plotCounter + 1;
                X <= 8'd156;
                Y <= yCounter + plotCounter[3:0];
            end
            if (update) begin
                yCounter <= Y;
            end
        end
    end
endmodule
