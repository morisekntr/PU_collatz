//61919734 Morise Kentaro
`include "pu.vh"
module imem( // Instruction Memory
	input [`PCS:0] pc,
	output logic [`CMDS:0] o);
	always_comb
		case(pc)
		// synopsys full_case parallel_case
		5'h00: o = 16'b0000_0000_0000_0000; // NOP
		5'h01: o = 16'b1000_0001_0110_0100; // LIL r0 8'01100100 //入力100
		// 5'h01: o = 16'b1000_0001_1110_1000; // LIL r0 8'01100100 //入力1000
		// 5'h01: o = 16'b1000_0001_1110_1001; // LIL r0 8'01100100 //入力1001
		// 5'h01: o = 16'b1000_0001_1111_1111; // LIL r0 8'01100100 //入力65535(2^16-1)
		5'h02: o = 16'b1000_0010_0000_0000; // LIH r0 8'00000000 //入力100
		// 5'h02: o = 16'b1000_0010_0000_0011; // LIH r0 8'00000000 //入力1000
		// 5'h02: o = 16'b1000_0010_0000_0011; // LIH r0 8'00000000 /入力1001
		// 5'h02: o = 16'b1000_0010_1111_1111; // LIH r0 8'00000000 ////入力65535(2^16-1)
		5'h03: o = 16'b0010_1000_0000_0100; // SM col[r1]=r0 //初期値r1=0
		//	for{
		5'h04: o = 16'b0000_0000_1000_0000; // CDM 0 //colにアクセス
		5'h05: o = 16'b0011_0010_0000_0001; // LM r2=col[r1] //col[i-1]を読出
		5'h06: o = 16'b1101_0010_0111_0000; // EVA CAL BTS {8{r2[0]}}; // Bit Test  //col[i-1] 奇数ならOD=1
		5'h07: o = 16'b0101_1111_0000_0100; // JP/BR PO(positive odd) jp->pc+4 //col[i-1](r2)奇数ならジャンプ{0x0b}
		//		even
		5'h08: o = 16'b0000_0111_1010_0001; // RSR r2=r2>>1  //col[i-1]偶数なら2で割る
		5'h09: o = 16'b1011_0110_0000_0001; // SM col[r1+1]=r2 //計算結果を保存
		5'h0a: o = 16'b0101_1000_0000_0100; // JP/BR UC jp->pc+4 //奇数の後の総和処理へジャンプ{0x0e}
		//		odd
		5'h0b: o = 16'b1100_1010_1100_0011; // CAL MUL r2 = r2*3 MV //col[i-1]奇数なら3を掛ける
		5'h0c: o = 16'b0000_0100_1010_0001; // INC r2 = r2 + 1 //1を足す　
		5'h0d: o = 16'b1011_0110_0000_0001; // SM col[r1+1]=r2 //計算結果を保存
		//		sum
		5'h0e: o = 16'b0000_0000_1000_0001; // CDM 1 //sumにアクセス
		5'h0f: o = 16'b0011_0011_0000_0001; // LM r3=sum[r1] //直前までの総和sum[i-1]を読出
		5'h10: o = 16'b0000_1011_0000_1011; // CAL ADD r3=r2+r3 //直前までの総和とi回目の値を足す
		5'h11: o = 16'b0000_0100_0101_0001; // INC r1=r1+1 //メモリの番地を1つ増やす
		5'h12: o = 16'b0010_1000_0000_0111; // SM sum[r1]=r3 //i回目までの総和を保存
		//		judge
		5'h13: o = 16'b1101_0010_0001_0001; // EVA CAL SUB r2-1  //col[i] 1ならZF=1
		5'h14: o = 16'b0100_1010_0000_0100; // JP/BR NZ(negative zero) jp->4 //ZFが0のとき、ループの最初へジャンプ{0x04}
		//	}
		5'h15: o = 16'b0000_0000_0000_0001; // HALT
		endcase
endmodule

/*
F E D C B A 9 8 7 6 5 4 3 2 1 0
0 0 0 0 0 0 0 0 0 * * * * * * 0 ; NOP (0) DSTB
0 0 0 0 0 0 0 0 0 * * * * * * 1 ; HALT (1)
0 0 0 0 0 0 0 0 1 * * * ch----> ; CDM ch
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
*/

/*
NOP
LIL r0 8'01100100 //入力100
LIH r0 8'00000000 //入力100
SM col[r1]=r0 //初期値r1=0
CDM 0 //colにアクセス
LM r2=col[r1] //col[i-1]を読出
EVA CAL BTS {8{r2[0]}}; // Bit Test  //col[i-1] 奇数ならOD=1
JP/BR PO(positive odd) jp->pc+4 //col[i-1](r2)奇数ならジャンプ{0x0b}
RSR r2=r2>>1  //col[i-1]偶数なら2で割る
SM col[r1+1]=r2 //計算結果を保存
JP/BR UC jp->pc+4 //奇数の後の総和処理へジャンプ{0x0e}
CAL MUL r2 = r2*3 MV //col[i-1]奇数なら3を掛ける
INC r2 = r2 + 1 //1を足す　
SM col[r1+1]=r2 //計算結果を保存
CDM 1 //sumにアクセス
LM r3=sum[r1] //直前までの総和sum[i-1]を読出
CAL ADD r3=r2+r3 //直前までの総和とi回目の値を足す
INC r1=r1+1 //メモリの番地を1つ増やす
SM sum[r1]=r3 //i回目までの総和を保存
EVA CAL SUB r2-1  //col[i] 1ならZF=1
JP/BR NZ(negative zero) jp->4 //ZFが0のとき、ループの最初へジャンプ{0x04}
*/