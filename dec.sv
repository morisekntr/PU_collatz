//61919734 Morise Kentaro
`include "pu.vh"

`define UC 2'b00
`define ZE 2'b01
`define CA 2'b10
`define OD 2'b11
//`define SG 2'b11

module dec( // Decoder
	input [`CMDS:0] o,
	output logic h, we,
	output logic [`RASB:0] wad,
	output logic [`ALUOPS:0] op,
	output logic [`RASB:0] rb, ra,
	output logic [`IMXOPS:0] liop,
	output logic [`HALFWIDTH:0] iv,
	output logic pcwe, dmwe, dms, pcs, sr,
	output logic [`CHM:0] ch,
	output logic chs,
	input ze, ca, sg, od);

/*
F E D C B A 9 8 7 6 5 4 3 2 1 0
0 0 0 0 0 0 0 0 0 * * * * * * 0 ; NOP (0) DSTB
0 0 0 0 0 0 0 0 0 * * * * * * 1 ; HALT (1)
0 0 0 0 0 0 0 0 1 * * * ch----> ; CDM iv
0 0 0 0 0 0 0 1 0 0 rw> 0 0 0 0 ; RESET rw (LI rw=0)
0 0 0 0 0 0 1 0 rw> a-> iv----> ; BST rw = ra|(1<<iv)
0 0 0 0 0 0 1 1 rw> a-> iv----> ; BRT rw = ra&(~(1<<iv))
0 0 0 0 0 1 0 0 rw> a-> iv----> ; INC rw = ra+iv
0 0 0 0 0 1 0 1 rw> a-> iv----> ; DEC rw = ra-iv
0 0 0 0 0 1 1 0 rw> a-> iv----> ; RSL rw = ra<<iv
0 0 0 0 0 1 1 1 rw> a-> iv----> ; RSR rw = ra>>iv
0 0 0 0 1 0 rw> op----> a-> b-> ; CAL rw=ra,rb MV
0 0 0 0 1 1 * * op----> a-> b-> ; EVA CAL ra,rb /CMP ra,rb
0 0 0 1 0 f f p op----> a-> b-> ; JP/BR fp [ra op rb] (ff:NC,Z,C,O)
0 0 1 0 1 F rw> op----> a-> b-> ; SM [rw]=rb / SM [rw] = [ra op rb]
0 0 1 1 0 F rw> op----> a-> b-> ; LM rw=[rb] / LM rw=[ra op rb]
0 1 0 0 0 0 b-> im------------> ; SM [(s)im]=rb
0 1 0 0 1 f f p im------------> ; JP/BR fp [(s)im]
0 1 0 1 1 f f p im------------> ; JP/BR fp [PC + (s)im]
0 1 1 a-> f f p im------------> ; JP/BR fp [ra + (s)im]
1 0 0 0 rw> 0 0 0 0 0 0 O S C Z ; LI rw,SR O:odd S:sign C:carry Z:zero
1 0 0 0 rw> 0 1 im------------> ; LIL rw,im (rw=rb)
1 0 0 0 rw> 1 0 im------------> ; LIH rw,im (rw=rb)
1 0 0 0 rw> 1 1 im------------> ; LI rw,(s)im (rw=rb) lidx=o[9:8]
1 0 0 1 0 0 b-> * * * * * * * * ; LI O, S, C, Z = rb
1 0 0 1 0 1 rw> im------------> ; LM rw=[im]
1 0 1 0 rw> a-> im------------> ; LM rw=[ra + (s)im]
1 0 1 1 a-> b-> im------------> ; SM [ra + (s)im]=rb
1 1 0 0 rw> a-> op----> iv----> ; CAL rw = ra op iv MV
1 1 0 1 * * a-> op----> iv----> ; EVA CAL ra,iv /CMP ra,iv
1 1 1 rw> f f p op----> iv----> ; CAL fp rw = rw op iv MV
*/

/*
r0:入力値
r1:メモリ番地および処理回数
r2:処理結果
r3:直前の総和

UC 2'b00 //uncondition
ZE 2'b01 //zero flag
CA 2'b10 //caryy flag
OD 2'b11 //odd flag
//SG 2'b11 //sign flag //今回は使わない

OPのときにフラグを立てる（毎回更新される）

ADD 4'b0000 SUB 4'b0001 ASR 4'b0010 RSR 4'b0011
RSL 4'b0100 BST 4'b0101 BRT 4'b0110 BTS 4'b0111
AND 4'b1000 OR  4'b1001 NAD 4'b1010 XOR 4'b1011
MUL 4'b1100 EXT 4'b1101 THA 4'b1110 THB 4'b1111

IMS
LIL 2'b00 LIH 2'b01 IMM 2'b10 THU 2'b11

COND(ALU)
UC 2'b00 ZE 2'b01 CA 2'b10 SG 2'b11

pf
P/N (p) 0::N(!=) 1:P(==)
ex) Positive Zero -> PZ
*/

	logic pf;
	always @* begin
		pf = `NEGATE;
		case(o[10:9])
		// synopsys full_case parallel_case
		`UC: begin
			pf = `ASSERT;
		end
		`ZE: begin
			pf = ~ze^o[8];
		end
		`CA: begin
			pf = ~ca^o[8];
		end
		`OD: begin
			pf = ~od^o[8];
		end
		endcase
	end
	always@* begin
		h = `NEGATE;
		ra = 0;
		rb = 0;
		op = `THB;
		we = `NEGATE;
		wad = 0;
		liop = `THU;
		iv = 0;
		ch = 0;
		pcwe = `NEGATE;
		dmwe = `NEGATE;
		dms = `NEGATE;
		pcs = `NEGATE;
		sr = `NEGATE;
		chs = `NEGATE;

		casex(o)
		// synopsys full_case parallel_case
//F E D C B A 9 8 7 6 5 4 3 2 1 0
//0 0 0 0 0 0 0 0 0 0 0 0 * * * 0 ; NOP
		16'b0000_0000_0000_xxx0: begin

		end
//F E D C B A 9 8 7 6 5 4 3 2 1 0
//0 0 0 0 0 0 0 0 0 0 0 0 * * * 1 ; HALT
		16'b0000_0000_0000_xxx1: begin
			h = `ASSERT;

		end
//0 0 0 0 0 0 0 0 1 * * * ch----> ; CDM iv
		16'b0000_0000_1xxx_xxxx: begin
			chs = `ASSERT;
			ch = o[3:0];
		end
// 0 0 0 0 0 0 0 1 0 0 rw> 0 0 0 0 ; RESET rw (LI rw=0)
		16'b0000_0001_00xx_0000: begin
			we = `ASSERT;
			wad = o[5:4];
			iv = 0;
			liop = `IMM;
		end
// 0 0 0 0 0 0 1 0 rw> a-> iv----> ; BST rw = ra|(1<<iv)
		16'b0000_0010_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `BST;
			liop = `IMM;
		end
// 0 0 0 0 0 0 1 1 rw> a-> iv----> ; BRT rw = ra&(~(1<<iv))
		16'b0000_0011_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `BRT;
			liop = `IMM;
		end
// 0 0 0 0 0 1 0 0 rw> a-> iv----> ; INC rw = ra+iv
		16'b0000_0100_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `ADD;
			liop = `IMM;
		end
// 0 0 0 0 0 1 0 1 rw> a-> iv----> ; DEC rw = ra-iv
		16'b0000_0101_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `SUB;
			liop = `IMM;
		end
// 0 0 0 0 0 1 1 0 rw> a-> iv----> ; RSL rw = ra<<iv
		16'b0000_0110_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `RSL;
			liop = `IMM;
		end
// 0 0 0 0 0 1 1 1 rw> a-> iv----> ; RSR rw = ra>>iv
		16'b0000_0111_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			ra = o[5:4];
			wad = o[7:6];
			op = `RSR;
			liop = `IMM;
		end
// 0 0 0 0 1 0 rw> op----> a-> b-> ; CAL rw=ra,rb MV
		16'b0000_10xx_xxxx_xxxx: begin
			we = `ASSERT;
			rb = o[1:0];
			ra = o[3:2];
			op = o[7:4];
			wad = o[9:8];
		end
// F E D C B A 9 8 7 6 5 4 3 2 1 0
// 0 0 0 0 1 1 * * op----> a-> b-> ; EVA CAL ra,rb /CMP ra,rb
		16'b0000_11xx_xxxx_xxxx: begin
			rb = o[1:0];
			ra = o[3:2];
			op = o[7:4];

		end
// 0 0 0 1 0 f f p op----> a-> b-> ; JP/BR fp [ra op rb] (ff:NC,Z,C,O)
		16'b0001_0xxx_xxxx_xxxx: begin
			if(pf) begin
				pcwe = `ASSERT;
				rb = o[1:0];
				ra = o[3:2];
				op = o[7:4];
			end
		end
// 0 0 1 0 1 F rw> op----> a-> b-> ; SM [ra]=rb / SM [rw] = ra op rb
		16'b0010_1xxx_xxxx_xxxx: begin
			dmwe = `ASSERT;
			rb = o[1:0];
			ra = o[3:2];
			op = `THA;
			// if(o[10]) begin
			// 	we = `ASSERT;
			// 	op = o[7:4];
			// 	wad = o[9:8]
			// end
		end
// 0 0 1 1 0 F rw> op----> a-> b-> ; LM rw=[rb] / LM rw=[ra op rb]
		16'b0011_0xxx_xxxx_xxxx: begin
			we = `ASSERT;
			dms = `ASSERT;
			rb = o[1:0];
			wad = o[9:8];
			// if(o[10]) begin
			// 	ra = o[3:2];
			// 	op = o[7:4];
			// end
		end
// 0 1 0 0 0 0 b-> im------------> ; SM [(s)im]=rb
		16'b0100_00xx_xxxx_xxxx: begin
			dmwe = `ASSERT;
			iv = o[7:0];
			rb = o[9:8];
			liop = `IMM;
		end
// 0 1 0 0 1 f f p im------------> ; JP/BR fp [(s)im]
		16'b0100_1xxx_xxxx_xxxx: begin
			if(pf) begin
				pcwe = `ASSERT;
				iv = o[7:0];
				liop = `IMM;
			end
		end
// 0 1 0 1 1 f f p im------------> ; JP/BR fp [PC + (s)im]
		16'b0101_1xxx_xxxx_xxxx: begin
			if(pf) begin
				pcwe = `ASSERT;
				pcs = `ASSERT;
				iv = o[7:0];
				op = `ADD;
				liop = `IMM;
			end
		end
// 0 1 1 a-> f f p im------------> ; JP/BR fp [ra + (s)im]
		16'b011x_xxxx_xxxx_xxxx: begin
			if(pf) begin
				pcwe = `ASSERT;
				iv = o[7:0];
				ra = o[12:11];
				op = `ADD;
				liop = `IMM;
			end
		end
// 1 0 0 0 rw> 0 0 0 0 0 0 O S C Z ; LI rw,SR O:odd S:sign C:carry Z:zero
		16'b1000_xx00_0000_xxxx: begin
			we = `ASSERT;
			sr = `ASSERT;
			iv = o[7:0];
			wad = o[11:10];
			liop = `IMM;
		end
// 1 0 0 0 rw> 0 1 im------------> ; LIL rw,im (rw=rb)
		16'b1000_xx01_xxxx_xxxx: begin
			if(pf) begin
				we = `ASSERT;
				iv = o[7:0];
				wad = o[11:10];
				liop = `LIL;
			end
		end
// 1 0 0 0 rw> 1 0 im------------> ; LIH rw,im (rw=rb)
		16'b1000_xx10_xxxx_xxxx: begin
			if(pf) begin
				we = `ASSERT;
				iv = o[7:0];
				wad = o[11:10];
				liop = `LIH;
			end
		end
// 1 0 0 0 rw> 1 1 im------------> ; LI rw,(s)im (rw=rb) lidx=o[9:8]
		16'b1000_xx11_xxxx_xxxx: begin
			if(pf) begin
				we = `ASSERT;
				iv = o[7:0];
				wad = o[11:10];
				liop = `IMM;
			end
		end
// 1 0 0 1 0 0 b-> * * * * * * * * ; LI O, S, C, Z = rb
		16'b0100_00xx_xxxx_xxxx: begin
			sr = `ASSERT;
			rb = o[9:8];
		end
// 1 0 0 1 0 1 rw> im------------> ; LM rw=[im]
		16'b1001_01xx_xxxx_xxxx: begin
			we = `ASSERT;
			dms = `ASSERT;
			iv = o[7:0];
			wad = o[9:8];
			liop = `IMM;
		end
// 1 0 1 0 rw> a-> im------------> ; LM rw=[ra + (s)im]
		16'b1010_xxxx_xxxx_xxxx: begin
			we = `ASSERT;
			dms = `ASSERT;
			iv = o[7:0];
			ra = o[9:8];
			wad = o[11:0];
			op = `ADD;
			liop = `IMM;
		end
// 1 0 1 1 a-> b-> im------------> ; SM [ra + (s)im]=rb
		16'b1011_xxxx_xxxx_xxxx: begin
			dmwe = `ASSERT;
			iv = o[7:0];
			rb = o[9:8];
			ra = o[11:10];
			op = `ADD;
			liop = `IMM;
		end
// 1 1 0 0 rw> a-> op----> iv----> ; CAL rw = ra op iv MV
		16'b1100_xxxx_xxxx_xxxx: begin
			we = `ASSERT;
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			op = o[7:4];
			ra = o[9:8];
			wad = o[11:10];
			liop = `IMM;
		end
// 1 1 0 1 * * a-> op----> iv----> ; EVA CAL ra,iv /CMP ra,iv
		16'b1101_xxxx_xxxx_xxxx: begin
			iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
			op = o[7:4];
			ra = o[9:8];
			liop = `IMM;
		end
// 1 1 1 rw> f f p op----> iv----> ; CAL fp rw = rw op iv MV
		16'b111x_xxxx_xxxx_xxxx: begin
			if(pf) begin
				we = `ASSERT;
				iv = {{(`HALFWIDTH-`QUATWIDTH){1'b0}},o[3:0]};
				op = o[7:4];
				wad = o[12:11];
				liop = `IMM;
			end
		end

		endcase
	end
endmodule
