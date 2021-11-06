module FSMswap (input logic CLK, input logic [7:0] i, input logic [7:0] j, input logic [7:0] q, input logic start, 
					output logic write_enable, output logic [7:0] address, output logic [7:0] write_data, output logic done);
parameter [9:0] start_state=    10'b0000_000000;
parameter [9:0] regSIJ     =    10'b0001_000001;
parameter [9:0] regSI      =    10'b0010_000010;
parameter [9:0] regSJ      =    10'b0011_000100;
parameter [9:0] SIeqSJ     =    10'b0100_001000;
parameter [9:0] SJmulSI    =    10'b0101_011000;
parameter [9:0] done_state =    10'b0110_100000;

reg [9:0]STATE;
reg [7:0] temp_i;
reg [7:0] temp_j;
reg [7:0] temp_A;
reg [7:0] temp_B;

assign done = STATE[5];


always_ff @ (posedge CLK)
	begin
		case(STATE)
			start : begin
					  if(start_state) STATE <= regSIJ;
					  else STATE <= start_state;
					  end
			regSIJ : STATE <= regSI;
			regSI  : STATE <= regSJ;
			regSJ  : STATE <= SIeqSJ;
			SIeqSJ : STATE <= SJmulSI;
			SJmulSI: STATE <= done_state;
			done_state :   STATE <= start_state;
			
			
			default: STATE <= start_state;
		endcase
	end
	
always_ff @ (posedge CLK)
	begin
		if(STATE[0]) begin
			temp_i <= i;
			temp_j <= j;
						 end
						 
		if(STATE[1]) begin
			address <= temp_i; // We are reading at same time we send address?
			temp_A <= q;       //Registering data
						end
						
		if(STATE[2])begin
			address <= temp_j; 
			temp_B <= q;       //Registering data
						end
						
		if(STATE[3])begin
			address <= temp_i;
			write_enable <= 1;
			write_data <= temp_B;
						end
					
		if(STATE[4])begin
			address <= temp_j;
			write_enable <= 1;
			write_data <= temp_A;
						end
		
		if(STATE[5])begin
			write_enable <= 0;
						end
			
	end


endmodule
