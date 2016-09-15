// 337 TA Provided Lab 2 Testbench
// This code serves as a test bench for the 1 bit adder design 

`timescale 1ns / 100ps

module tb_adder_16bit
();
	// Define local parameters used by the test bench
	localparam NUM_INPUT_BITS			= 16;
	localparam NUM_OUTPUT_BITS		= NUM_INPUT_BITS + 1;
	localparam MAX_OUTPUT_BIT			= NUM_OUTPUT_BITS - 1;
	localparam NUM_TEST_BITS 			= (NUM_INPUT_BITS * 2) + 1;
	localparam MAX_TEST_BIT				= NUM_TEST_BITS - 1;
	localparam NUM_TEST_CASES 		= 2 ** NUM_TEST_BITS; 
	localparam MAX_TEST_VALUE 		= NUM_TEST_CASES - 1;
	localparam TEST_A_BIT					= NUM_INPUT_BITS - 1;
	localparam TEST_B_BIT					= 2 * NUM_INPUT_BITS - 1;
	localparam TEST_CARRY_IN_BIT	= MAX_TEST_BIT;
	localparam TEST_SUM_BIT				= 0;
	localparam TEST_CARRY_OUT_BIT	= MAX_OUTPUT_BIT;
	localparam TEST_DELAY					= 10;
	
	// Declare Design Under Test (DUT) portmap signals
	wire	[NUM_INPUT_BITS-1:0] tb_a;
	wire	[NUM_INPUT_BITS-1:0] tb_b;
	wire	tb_carry_in;
	wire	[NUM_INPUT_BITS-1:0] tb_sum;
	wire	tb_carry_out;
	
	// Declare test bench signals
	//integer tb_test_case;
	reg [MAX_TEST_BIT:0] tb_test_inputs;
	reg [NUM_INPUT_BITS:0] tb_expected_outputs;
	
	// identify problem signals
	reg no_match;

	// DUT port map
	adder_16bit DUT(.a(tb_a), .b(tb_b), .carry_in(tb_carry_in), .sum(tb_sum), .overflow(tb_carry_out));
	
	// Connect individual test input bits to a vector for easier testing
	assign tb_a					= tb_test_inputs[TEST_A_BIT:0];
	assign tb_b					= tb_test_inputs[TEST_B_BIT:TEST_A_BIT + 1];
	assign tb_carry_in	= tb_test_inputs[TEST_CARRY_IN_BIT];
	
	// Test bench process
	initial
	begin
		// Initialize test inputs for DUT
		tb_test_inputs = '0;
		//tb_test_case = 'd1;

		no_match = '0;
		no_match = '1;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 1); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 1); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 1); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 1); //tb_test_case);
			no_match = 1;		
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 1");

		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h00001FFFD;
		//tb_test_case = 'd2;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 2); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 2); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 2); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 2); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 2");

		//******************************************************************************
		
		// Initialize test inputs for DUT
		tb_test_inputs = 33'h1FFFF0001;
		//tb_test_case = 'd3;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 3); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 3); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 3); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 3); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 3");

		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h1EEE8DDDE;
		//tb_test_case = 'd4;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 4); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 4); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 4); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 4); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 4");

		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h000020002;
		//tb_test_case = 'd5;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 5); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 5); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 5); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 5); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 5");
		//******************************************************************************
		
		// Initialize test inputs for DUT
		tb_test_inputs = 33'h0C0C00C08;
		//tb_test_case = 'd6;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 6); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 6); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 6); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 6); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 6");
		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h030300307;
		//tb_test_case = 'd7;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 7); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 7); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 7); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 7); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 7");
		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h1;
		//tb_test_case = 'd8;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 8); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 8); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 8); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 8); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 8");
		//******************************************************************************

		// Initialize test inputs for DUT
		tb_test_inputs = 33'h1FFFFFFFF;

		//tb_test_case = 'd9;

		// Wait for a bit to allow this process to catch up with assign statements triggered
		// by test input assignment above
		#1;
			
		// Calculate the expected outputs
		tb_expected_outputs = tb_a + tb_b + tb_carry_in;
		
		// Wait for DUT to process the inputs
		#(TEST_DELAY - 1);
			
		// Check the DUT's Sum output value
		if(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0])
		begin
			$info("Correct Sum value for test case %d!", 9); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Sum value for test case %d!", 9); //tb_test_case);
			no_match = 1;
		end
		
		// Check the DUT's Carry Out output value
		if(tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out)
		begin
			$info("Correct Carry Out value for test case %d!", 9); //tb_test_case);
			no_match = '0;
		end
		else
		begin
			$error("Incorrect Carry Out value for test case %d!", 9); //tb_test_case);
			no_match = 1;
		end

		assert(tb_expected_outputs[NUM_INPUT_BITS-1:0] == tb_sum[NUM_INPUT_BITS-1:0] && (tb_expected_outputs[TEST_CARRY_OUT_BIT] == tb_carry_out))
			else $error("Incorrect sum for case 9");
		//******************************************************************************


	end
	
	// Wrap-up process
	final
	begin
		if(NUM_TEST_CASES != 8)
		begin
			// Didn't run the test bench through all test cases
			$display("This test bench was not run long enough to execute all test cases. Please run this test bench for at least a total of %d ns", (NUM_TEST_CASES * TEST_DELAY));
		end
		else
		begin
			// Test bench was run to completion
			$display("This test bench has run to completion");
		end
	end

endmodule
