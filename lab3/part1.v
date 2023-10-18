module top_entity (LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;
    adder4bit p1 (
	.a (SW[7:4]),
	.b (SW[3:0]),
	.c_in (SW[8]),
	.s (LEDR[3:0]),
	.c_out (LEDR[9:6])
    );
endmodule

module part1 (a, b, c_in, s, c_out);
    input [3:0] a, b;
    input c_in;
    output [3:0] s, c_out;
    wire w1, w2, w3;

    adder4bit u0 (a[0], b[0], c_in, s[0], w1);
    adder4bit u1 (a[1], b[1], w1, s[1], w2);
    adder4bit u2 (a[2], b[2], w2, s[2], w3);
    adder4bit u3 (a[3], b[3], w3, s[3], c_out[3]);

    assign c_out[0] = w1;
    assign c_out[1] = w2;
    assign c_out[2] = w3;
endmodule

module adder4bit (a, b, c_in, s, c_out);
    input a, b, c_in;
    output s, c_out;

    assign s = a^b^c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
endmodule


