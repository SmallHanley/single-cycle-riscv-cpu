// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output reg        instr_read,
    output reg        data_read,
    output reg [31:0] instr_addr,
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);
/* Add your design */
reg [31:0] register [31:0];
reg [31:0] pc;
reg [31:0] count;
reg [2:0] state;
integer i;

always@(posedge clk)
begin
	if(rst)
	begin
		register[0] = 32'd0;
		pc = 32'd0;
		state = 3'd0;
		count = 32'd0;
	end
	else
	begin
		case(state)
			3'd0:
			begin
				register[0] = 0;
				state <= 3'd1;
				instr_addr <= pc;
				instr_read <= 1;
				data_read <= 0;
				data_write <= 4'b0000;
				/*if(count >=0)
				begin
				$display("%d pc : %h, %b, %h", count, pc, instr_out, instr_out);
				for(i = 0; i < 32; i = i + 4)
				begin
					$display("%h, %h, %h, %h", register[i], register[i+1], register[i+2], register[i+3]);
				end
				$display("\n");
				end*/
				count = count + 1;
			end
			3'd1: state <= 3'd2;
			3'd2:
			begin	
				case(instr_out[6:0])
					7'b0110011:
					begin
						case({instr_out[31:25], instr_out[14:12]})
							10'b0000000000:	register[instr_out[11:7]] <= register[instr_out[19:15]] + register[instr_out[24:20]];
							10'b0100000000: register[instr_out[11:7]] <= register[instr_out[19:15]] - register[instr_out[24:20]];
							10'b0000000001: register[instr_out[11:7]] <= register[instr_out[19:15]] << register[instr_out[24:20]][4:0] ;
							10'b0000000010:	register[instr_out[11:7]] <= ($signed(register[instr_out[19:15]]) < $signed(register[instr_out[24:20]])) ? 1 : 0;
							10'b0000000011:	register[instr_out[11:7]] <= (register[instr_out[19:15]] < register[instr_out[24:20]]) ? 1 : 0;
							10'b0000000100:	register[instr_out[11:7]] <= register[instr_out[19:15]] ^ register[instr_out[24:20]];
							10'b0000000101: register[instr_out[11:7]] <= register[instr_out[19:15]] >> register[instr_out[24:20]][4:0] ;
							10'b0100000101: register[instr_out[11:7]] <= $signed(register[instr_out[19:15]]) >> register[instr_out[24:20]][4:0] ;
							10'b0000000110:	register[instr_out[11:7]] <= register[instr_out[19:15]] | register[instr_out[24:20]];
							10'b0000000111: register[instr_out[11:7]] <= register[instr_out[19:15]] & register[instr_out[24:20]];
							default: ;
						endcase
						state <= 3'd0;
						pc = pc + 32'd4;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
					end
					7'b0000011:
					begin
						data_addr <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]};
						state <= 3'd3;
						instr_addr <= pc;
						instr_read <= 1;
						data_read <= 1;
						data_write <= 4'b0000;
					end 
					7'b0010011:
					begin
						case(instr_out[14:12])
							3'b000: register[instr_out[11:7]] <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]};
							3'b010: register[instr_out[11:7]] <= ($signed(register[instr_out[19:15]]) < $signed({{20{instr_out[31]}}, instr_out[31:20]})) ? 1 : 0;
							3'b011: register[instr_out[11:7]] <= ($unsigned(register[instr_out[19:15]]) < $unsigned({{20{instr_out[31]}}, instr_out[31:20]})) ? 1 : 0;
							3'b100: register[instr_out[11:7]] <= register[instr_out[19:15]] ^ {{20{instr_out[31]}}, instr_out[31:20]};
							3'b110: register[instr_out[11:7]] <= register[instr_out[19:15]] | {{20{instr_out[31]}}, instr_out[31:20]};
							3'b111: register[instr_out[11:7]] <= register[instr_out[19:15]] & {{20{instr_out[31]}}, instr_out[31:20]};
							3'b001: register[instr_out[11:7]] <= register[instr_out[19:15]] << instr_out[24:20];
							3'b101: 
							begin
								case(instr_out[31:25])
									7'b0000000: register[instr_out[11:7]] <= register[instr_out[19:15]] >> instr_out[24:20];
									7'b0100000: register[instr_out[11:7]] <= $signed(register[instr_out[19:15]]) >>> instr_out[24:20];
									default: ;
								endcase
							end
							default: ;
						endcase
						state <= 3'd0;
						pc = pc + 32'd4;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
					end
					7'b1100111: 
					begin
						register[instr_out[11:7]] <= pc + 32'd4;
						pc <= {{20{instr_out[31]}}, instr_out[31:20]} + register[instr_out[19:15]];
						state <= 3'd0;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
						//$display("JALR");
					end
					7'b0100011:
					begin
						data_addr = register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
						state <= 3'd0;
						pc = pc + 32'd4;
						instr_read <= 1;
						data_read <= 0;
						case(instr_out[14:12])
							3'b010:
							begin
								data_in <= register[instr_out[24:20]];
								data_write <= 4'b1111;
							end
							3'b000:
							begin
								data_in <= {register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0], register[instr_out[24:20]][7:0]};
								case(data_addr[1:0])
									2'b00: data_write <= 4'b0001;
									2'b01: data_write <= 4'b0010;
									2'b10: data_write <= 4'b0100;
									2'b11: data_write <= 4'b1000;
									default: ;
								endcase
							end
							3'b001:
							begin
								data_in <= {register[instr_out[24:20]][15:0], register[instr_out[24:20]][15:0]};
								case(data_addr[1:0])
									2'b00: data_write <= 4'b0011;
									2'b10: data_write <= 4'b1100;
									default: ;
								endcase
							end
							default: ;
						endcase
					end
					7'b1100011:
					begin
						case(instr_out[14:12])
							3'b000: pc = (register[instr_out[19:15]] == register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							3'b001: pc = (register[instr_out[19:15]] != register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							3'b100: pc = ($signed(register[instr_out[19:15]]) < $signed(register[instr_out[24:20]])) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							3'b101: pc = ($signed(register[instr_out[19:15]]) >= $signed(register[instr_out[24:20]])) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							3'b110: pc = (register[instr_out[19:15]] < register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							3'b111: pc = (register[instr_out[19:15]] >= register[instr_out[24:20]]) ? pc + {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0} : pc + 4;
							default: ;
						endcase
						state <= 3'd0;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
					end
					7'b0010111:
					begin
						register[instr_out[11:7]] <= pc + {instr_out[31:12], 12'd0};
						state <= 3'd0;
						pc = pc + 32'd4;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
					end
					7'b0110111:
					begin
						register[instr_out[11:7]] <= {instr_out[31:12], 12'd0};
						state <= 3'd0;
						pc = pc + 32'd4;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
					end
					7'b1101111:
					begin
						register[instr_out[11:7]] <= pc + 32'd4;			
						pc = pc + {{11{instr_out[31]}}, instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};
						state <= 3'd0;
						instr_read <= 0;
						data_read <= 0;
						data_write <= 4'b0000;
						//$display("JAL");
					end
					default: ;
				endcase
			end
			3'd3:
			begin
				state <= 3'd4;
				data_addr <= register[instr_out[19:15]] + {{20{instr_out[31]}}, instr_out[31:20]};
				instr_read <= 1;
				data_read <= 1;
				data_write <= 4'b0000;
			end
			3'd4:
			begin
				case(instr_out[14:12])
					3'b010: register[instr_out[11:7]] <= data_out;
					3'b000: register[instr_out[11:7]] <= {{24{data_out[7]}}, data_out[7:0]};
					3'b001: register[instr_out[11:7]] <= {{16{data_out[15]}}, data_out[15:0]};
					3'b100: register[instr_out[11:7]] <= {24'd0, data_out[7:0]};
					3'b101: register[instr_out[11:7]] <= {16'd0, data_out[15:0]};
					default: ;
				endcase
				state <= 3'd0;
				pc = pc + 32'd4;
				instr_read <= 0;
				data_read <= 0;
				data_write <= 4'b0000;
			end
		endcase
	end
end

endmodule
