`timescale 1ns/1ps

interface alu_if;
	logic [15:0] operand_a;
	logic [15:0] operand_b;
	logic [4:0] operation;
	logic [15:0] result;
	logic carry_in;
	logic carry_out;
	logic stub_nBo;
	logic stub_nGo;
	
	modport tb (
		input operand_a, operand_b, carry_in, operation,
		output result, stub_nBo, stub_nGo, carry_out
	);

endinterface

// carry_out, carry_in are postive low
module alu_tb;
	reg	[15:0] expected;
	reg cout;
	integer passed_tests, all_tests;
	
	
	alu_if alu_intf();
	
	`include "tb/opcodes.vh"
	top_alu_16 alu_instance(
		.a(alu_intf.operand_a),
		.b(alu_intf.operand_b),
		.Cin(alu_intf.carry_in),
		.mode(alu_intf.operation[4]),
		.sel(alu_intf.operation[3:0]),
		.result(alu_intf.result),
		.Cout(alu_intf.carry_out),
		.nBo(alu_intf.stub_nBo),
		.nGo(alu_intf.stub_nGo)
	);
	

	
	task init;
		begin
			$dumpfile("waveforms/waveform.vcd");
			$dumpvars(0, alu_instance);
			alu_intf.operand_a = 16'b0;
			alu_intf.operand_b = 16'b0;
			alu_intf.carry_in = 1'b0;
			alu_intf.operation = 5'b0;
			passed_tests = 0;
			all_tests = 0;
			$display("%s", "=====	START TEST	=====");
		end
	endtask

	task run_tests;
		begin
			a_plus_a_test();
			a_plus_a_and_b_task();
			task_add_test();
			task_sub_test();
			task_or_test();
			task_xor_test();
			task_and_test();
			b_inv_task();
		end
	endtask
	
	task task_sub_test;
		begin
			$display("%s", "------ SUB TEST ------");
			do_test(16'hFFFF, 16'h0001, 1'b1, SUB_OP);
			do_test(16'h8000, 16'h0001, 1'b0, SUB_OP);
			do_test(16'h7FFF, 16'hFFFF, 1'b1, SUB_OP);
			do_test(16'h1234, 16'h1234, 1'b0, SUB_OP);
			do_test(16'hCAFE, 16'hBABE, 1'b1, SUB_OP);
			do_test(16'h0000, 16'h0001, 1'b0, SUB_OP);
			$display("%s", "------ SUB TEST ------");
		end
	endtask
	
	task task_add_test;
		begin
			$display("%s", "------ SUM TEST ------");
			do_test(16'h0001, 16'h0001, 1'b0, ADD_OP);
			do_test(16'h00FF, 16'h0001, 1'b0, ADD_OP);
			do_test(16'hAAAA, 16'h5555, 1'b1, ADD_OP);
			do_test(16'hFFFF, 16'h0001, 1'b0, ADD_OP);
			do_test(16'h7FFF, 16'h0001, 1'b0, ADD_OP);
			do_test(16'hCAFE, 16'hBABE, 1'b1, ADD_OP);
			$display("%s", "------ SUM TEST ------");
		end
	endtask
	
	task task_and_test;
		begin
			$display("%s", "------ AND TEST ------");
			do_test(16'h0001, 16'h0001, 1'b0, AND_OP);
			do_test(16'hcafe, 16'hbabe, 1'b0, AND_OP);
			do_test(16'hdead, 16'hbeef, 1'b0, AND_OP);
			do_test(16'h0101, 16'h1010, 1'b1, AND_OP);
			do_test(16'h1101, 16'h0010, 1'b1, AND_OP);
			do_test(16'haabb, 16'hccff, 1'b1, AND_OP);
			$display("%s", "------ AND TEST ------");
		end
	endtask
	
	task task_or_test;
		begin
			$display("%s", "------ OR TEST	------");
			do_test(16'h0000, 16'h0000, 1'b0, OR_OP);
			do_test(16'hFFFF, 16'h1234, 1'b0, OR_OP);
			do_test(16'h0F0F, 16'hF0F0, 1'b1, OR_OP);
			do_test(16'hAAAA, 16'h5555, 1'b1, OR_OP);
			do_test(16'hC0DE, 16'h00FF, 1'b1, OR_OP);
			do_test(16'hA5A5, 16'h0FF0, 1'b0, OR_OP);
			$display("%s", "------ OR TEST	------");
		end
	endtask
	
	task task_xor_test;
		begin
			$display("%s", "------ XOR TEST ------");
			do_test(16'h0000, 16'hFFFF, 1'b1, XOR_OP);
			do_test(16'hAAAA, 16'h5555, 1'b0, XOR_OP);
			do_test(16'hF0F0, 16'h0F0F, 1'b1, XOR_OP);
			do_test(16'hFFFF, 16'hFFFF, 1'b0, XOR_OP);
			do_test(16'h0001, 16'h0001, 1'b1, XOR_OP);
			do_test(16'hDEAD, 16'hBEEF, 1'b0, XOR_OP);
			$display("%s", "------ XOR TEST ------");
		end
	endtask
	
	task a_plus_a_test;
		begin
			$display("%s", "------ A_PLUS_A_OP TEST ------");
			do_test(16'h5432, 16'h0000, 1'b1, A_PLUS_A_OP);
			do_test(16'hAAAA, 16'h0000, 1'b0, A_PLUS_A_OP);
			do_test(16'hF1F1, 16'h0000, 1'b1, A_PLUS_A_OP);
			do_test(16'hFEEF, 16'h0000, 1'b0, A_PLUS_A_OP);
			do_test(16'h0101, 16'h0000, 1'b1, A_PLUS_A_OP);
			do_test(16'hDAED, 16'h0000, 1'b0, A_PLUS_A_OP);
			$display("%s", "------ A_PLUS_A_OP TEST ------");
		end
	endtask
	
	task b_inv_task;
		begin
			$display("%s", "------ INV_B TEST ------");
			do_test(16'h0000, 16'h0A0A, 1'b1, INV_B_OP);
			do_test(16'h0000, 16'hB0B0, 1'b0, INV_B_OP);
			do_test(16'h0000, 16'h0C0C, 1'b1, INV_B_OP);
			do_test(16'h0000, 16'h1111, 1'b0, INV_B_OP);
			do_test(16'h0000, 16'hFFFF, 1'b1, INV_B_OP);
			do_test(16'h0000, 16'hEEEE, 1'b0, INV_B_OP);
			$display("%s", "------ INV_B TEST ------");
		end
	endtask
	
	task a_plus_a_and_b_task;
		begin
			$display("%s", "------ A + AB TEST ------");
			do_test(16'h1234, 16'hFFFF, 1'b0, A_PLUS_A_AND_B_OP);
			do_test(16'hAAAA, 16'h5555, 1'b1, A_PLUS_A_AND_B_OP);
			do_test(16'hF0F0, 16'h0F0F, 1'b0, A_PLUS_A_AND_B_OP);
			do_test(16'h3333, 16'hCCCC, 1'b1, A_PLUS_A_AND_B_OP);
			do_test(16'h8001, 16'h7FFF, 1'b0, A_PLUS_A_AND_B_OP);
			do_test(16'hDEAD, 16'hBEEF, 1'b1, A_PLUS_A_AND_B_OP);
			$display("%s", "------ A + AB TEST ------");
		end
	endtask
	
	task do_test(
		input [15:0] operand1,
		input [15:0] operand2,
		input Cin,
		input [4:0] code
		);
	
		begin
			alu_intf.operand_a = operand1;
			alu_intf.operand_b = operand2;
			alu_intf.operation = code;
			alu_intf.carry_in = ~Cin;
			
			all_tests += 1;
			#10;
			case (code)
				A_PLUS_A_AND_B_OP: begin
					{cout, expected} = operand1 + (operand1 & operand2) + Cin;
					if ({cout, expected} == {~alu_intf.carry_out, alu_intf.result}) begin
						$display("Calucalation is correct: %d + %d & %d + %d (carry_in) = %d (carry_out: %d)", 
							operand1, operand1, operand2, Cin, alu_intf.result, ~alu_intf.carry_out);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: %d + %d & %d + %d (carry_in) = (carry_out: %d, result: %d) (cout: %d, expected: %d)", 
							operand1, operand1, operand2, Cin, ~alu_intf.carry_out, alu_intf.result, cout, expected);
					end
				end
				A_PLUS_A_OP: begin
					{cout, expected} = operand1 + operand1 + Cin;
					if ({cout, expected} == {~alu_intf.carry_out, alu_intf.result}) begin
						$display("Calucalation is correct: %d + %d + %d (carry_in) = %d (carry_out: %d)", 
							operand1, operand1, Cin, alu_intf.result, ~alu_intf.carry_out);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: %d + %d + %d (carry_in) = (carry_out: %d, result: %d) (cout: %d, expected: %d)", 
							operand1, operand1, Cin, ~alu_intf.carry_out, alu_intf.result, cout, expected);
					end
				end
				ADD_OP: begin
					{cout, expected} = operand1 + operand2 + Cin;
					if ({cout, expected} == {~alu_intf.carry_out, alu_intf.result}) begin
						$display("Calucalation is correct: %d + %d + %d (carry_in) = %d (carry_out: %d)", 
							operand1, operand2, Cin, alu_intf.result, ~alu_intf.carry_out);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: %d + %d + %d (carry_in) = (carry_out: %d, result: %d) (cout: %d, expected: %d)", 
							operand1, operand2, Cin, ~alu_intf.carry_out, alu_intf.result, cout, expected);
					end
				end
				SUB_OP: begin
					{cout, expected} = operand1 + ~operand2 + Cin;
					cout = ~cout;
					if ({cout, expected} == {~alu_intf.carry_out, alu_intf.result}) begin
						$display("Calucalation is correct: %d - %d - %d (carry_in) = %d (carry_out: %d)", 
							$signed(operand1), $signed(operand2), ~Cin, $signed(alu_intf.result), ~alu_intf.carry_out);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: %d - %d - %d (carry_in) = (carry_out: %d, result: %d) (cout: %d, expected: %d)", 
							$signed(operand1), $signed(operand2), ~Cin, ~alu_intf.carry_out, $signed(alu_intf.result), cout, expected);
					end
				end
				AND_OP: begin
					expected = operand1 & operand2;
					if (expected == alu_intf.result) begin
						$display("Calucalation is correct: 0b%b & 0b%b = 0b%b (carry_in: %b)",
							operand1, operand2, alu_intf.result, Cin);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: 0b%b & 0b%b = 0b%b (carry_in: %b) {expected: 0b%b}",
							operand1, operand2, alu_intf.result, Cin, expected);
					end
				end
				OR_OP: begin
					expected = operand1 | operand2;
					if (expected == alu_intf.result) begin
						$display("Calucalation is correct: 0b%b | 0b%b = 0b%b (carry_in: %b)",
							operand1, operand2, alu_intf.result, Cin);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: 0b%b | 0b%b = 0b%b (carry_in: %b) {expected: 0b%b}",
							operand1, operand2, alu_intf.result, Cin, expected);
					end
				end
				XOR_OP: begin
					expected = operand1 ^ operand2;
					if (expected == alu_intf.result) begin
						$display("Calucalation is correct: 0b%b ^ 0b%b = 0b%b (carry_in: %b)",
							operand1, operand2, alu_intf.result, Cin);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: 0b%b ^ 0b%b = 0b%b (carry_in: %b) {expected: 0b%b}",
							operand1, operand2, alu_intf.result, Cin, expected);
					end
				end
				INV_B_OP: begin
					expected = ~operand2;
					if(expected == alu_intf.result) begin
						$display("Calucalation is correct: ~0b%b = 0b%b (carry_in: %b)",
							operand2, alu_intf.result, Cin);
						passed_tests += 1;
					end else begin
						$display("Calucalation error: ~0b%b = 0b%b (carry_in: %b) {expected: 0b%b}",
							operand2, alu_intf.result, Cin, expected);
					end
				end
				
				default: $display("Not tested!");
			endcase
		end
	endtask
	
	task end_message;
		$display("Passed_tests: %d, All tests: %d", passed_tests, all_tests);
		$display("%s", "=====	END TEST  	=====");
	endtask
	
	initial begin
		init();
		run_tests();
		end_message();
		$stop;
	end
	
endmodule