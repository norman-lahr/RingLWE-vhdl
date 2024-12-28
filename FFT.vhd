----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:04:22 11/17/2011 
-- Design Name: 
-- Module Name:    FFT - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;	-- Conversation to STD_LOGIC_VECTOR
use WORK.DECLARATION_PKG.all;

entity FFT is
    port(
		A 		:in POLYNOMIAL_2K;
		Z 		:out POLYNOMIAL_2K;
		CLK		:in STD_LOGIC;
		START	:in STD_LOGIC;
		RESET	:in STD_LOGIC;
		LOAD	:in STD_LOGIC;
		IFFT	:in STD_LOGIC;
		RDY		:out STD_LOGIC
		);
end FFT;

architecture Behavioral of FFT is
	----------------
	-- Components --
	----------------
	
	component FFT_Butterfly is
		port(
			A		:in N_BIT_INT;
			B		:in N_BIT_INT;
			W		:in N_BIT_INT;
			C		:out N_BIT_INT;
			D		:out N_BIT_INT;
			CLK		:in STD_LOGIC;
			START	:in STD_LOGIC;
			RESET	:in STD_LOGIC;
			EN		:in STD_LOGIC;
			BYPASS	:in STD_LOGIC;
			RDY		:out STD_LOGIC
			);
	end component FFT_Butterfly;
		
	component MUX_N is
		generic(
				N	:INTEGER
				);
		port(
			A	:in N_BIT_INT_ARRAY(N-1 downto 0);
			SEL	:in INTEGER range 0 to N-1;
			Z	:OUT	N_BIT_INT
			);
	end component MUX_N;
	
	component And_N is
		generic(
				N: INTEGER
				);
		port(
			A	:in STD_LOGIC_VECTOR (N-1 downto 0);
			Z	:out  STD_LOGIC);
	end component And_N;
	
	-------------
	-- Signals --
	-------------
	
	-- Log2(N), N = 2 * Degree of F
	constant LOG2_N: integer := log2(2*DEGREE_F);
	-- The number of inputs of the FFT is the doubled maximum degree
	-- Signals for input of the FFT Butterly elements
	signal in_fft_butterfly: N_BIT_INT_ARRAY(2*DEGREE_F-1 downto 0);
	-- Signals for output of the FFT Butterly elements
	signal out_fft_butterfly: N_BIT_INT_ARRAY(2*DEGREE_F-1 downto 0);
	-- Signals for w of the FFT Butterly elements
	signal w_fft_butterfly: N_BIT_INT_ARRAY(DEGREE_F-1 downto 0);
	-- Stages s
	signal s: INTEGER range 0 to LOG2_N-1;
	
	-- Internal start and ready signal for the Butterflies
	signal int_start, int_rdy: STD_LOGIC;
	signal global_rdy: STD_LOGIC_VECTOR(DEGREE_F-1 downto 0);

	
	type STATE_T is(IDLE, RUN, WAIT_RDY, INC_S, DONE);
	signal state: STATE_T;
	-- Counter enable, Counter reset, Butterfly enable for storing input values
	signal ce, reset_ctr, buttterfly_en: STD_LOGIC;
	
	signal int_a, rev_a: N_BIT_INT_ARRAY((2*DEGREE_F) -1 downto 0);
	-- Roots of unity
	signal in_mux_w: N_BIT_INT_ARRAY(LOG2_N * DEGREE_F - 1 downto 0);
	constant W_ARRAY_ROM: N_BIT_INT_ARRAY(LOG2_N * DEGREE_F - 1 downto 0) := getWArray(W, DEGREE_F, false);
	constant INV_W_ARRAY_ROM: N_BIT_INT_ARRAY(LOG2_N * DEGREE_F - 1 downto 0) := getWArray(INV_W, DEGREE_F, true);
	
	signal int_bypass	:STD_LOGIC;
	
begin
	-----------------------------------------------
	-- Connect Input vector inbit-reversed order --
	-----------------------------------------------
	Rev_Input: for i in 0 to 2*DEGREE_F-1 generate
		rev_a(rev(i,LOG2_N)) <= A(i);
	end generate;
	-- Store Input values
	In_FF: process (CLK, RESET)
	begin
		if CLK'event and CLK = '1' then
			if LOAD = '1' then
				int_a <= rev_a;
			end if;
		end if;
	end process;
	
	---------------------------------------------
	-- Build a parallel and flat FFT structure --
	---------------------------------------------
	
	-- Generate FFT Butterly Modules and connect their signals
	FFT_Butterflies: for i in 0 to DEGREE_F-1 generate
		-- Intermediate input signals for the multiplexers
		signal in_mux_a, in_mux_b: N_BIT_INT_ARRAY(LOG2_N-2 downto 0);
		
		-- Feedback Addresses
		constant outAddr: INTEGER_ARRAY((log2(2*DEGREE_F)-1)*2*DEGREE_F -1 downto 0) := getAddr(DEGREE_F);
		
	begin
		-- Generate one FFT Butterfly
		FFT_Butterfly1: FFT_Butterfly port map(
												A => in_fft_butterfly(2*i),
												B => in_fft_butterfly(2*i+1),
												W => w_fft_butterfly(i),
												C => out_fft_butterfly(2*i),
												D => out_fft_butterfly(2*i+1),
												CLK => CLK,
												START => int_start,
												RESET => RESET,
												EN => buttterfly_en,
												BYPASS => int_bypass,
												RDY => global_rdy(i)
												);
											   
			-- Connect global output
			Z(i) <= out_fft_butterfly(2*i);				-- Connect first output
			Z(i+DEGREE_F) <= out_fft_butterfly(2*i+1);	-- Connect second output
			
			-- Generate one MUX per Butterfly input
			MUX_A: MUX_N generic map(
									N => LOG2_N
									)
							port map(
									A(0) => int_a(2*i), 
									A(LOG2_N - 1 downto 1) => in_mux_a, 
									SEL => s, 
									Z => in_fft_butterfly(2*i)
									);
													
			MUX_B: MUX_N generic map(
									N => LOG2_N
									)
							port map(
									A(0) => int_a(2*i+1), 
									A(LOG2_N - 1 downto 1) => in_mux_b, 
									SEL => s, Z => in_fft_butterfly(2*i+1)
									);
													
			MUX_W: MUX_N generic map(
									N => LOG2_N
									)
							port map(
									A => in_mux_w(i*LOG2_N + LOG2_N-1 downto i*LOG2_N), 
									SEL => s, 
									Z =>w_fft_butterfly(i)
									);
			
			-- Flatten	the parallel FFT structure to only one reused stage									
			Connect_Feedback: for j in 0 to LOG2_N-2 generate
				in_mux_a(j) <= out_fft_butterfly(outAddr(2*(LOG2_N-1) * i + j));
				in_mux_b(j) <= out_fft_butterfly(outAddr(2*(LOG2_N-1) * i + j + (LOG2_N-1)));
			end generate;
						
	end generate FFT_Butterflies;
						
	-- Global Ready signal of all butterflies
	AND_RDY: And_N generic map(
								N => DEGREE_F
								)
						port map(
								A => global_rdy, 
								Z => int_rdy
								);
								
	-- Determine the correct W
	with IFFT select in_mux_w <= W_ARRAY_ROM when '0', 
								INV_W_ARRAY_ROM when '1', 
								(others => (others =>'0')) when others;

	
	------------------
	-- Control unit --
	------------------
	-- Counting the stages
	counter: process(CLK, RESET, reset_ctr)
	begin
		if RESET = '1' or reset_ctr = '1' then
			s <= 0;
		elsif CLK'event and CLK = '1' then
			-- Increment, if counter is enabled and
			-- s has not reached its limit
			if ce = '1' and s < LOG2_N -1 then
				s <= s + 1;
			end if;
		end if;
	end process;
	
	control_unit: process(CLK, RESET, state, IFFT, s)
	begin
		RDY <= '0';
		int_start <= '0';
		ce <= '0';
		buttterfly_en <= '0';
		int_bypass <= '0';
		reset_ctr <= '0';
		
		-- Outputs
		case state is
			when IDLE		=>	RDY <= '0';
								int_start <='0';
								buttterfly_en <= '0';
								reset_ctr <= '1';
									
			when RUN 		=>	int_start <= '1';
								ce <= '0';
								buttterfly_en <= '1';
								reset_ctr <= '0';
			
			when WAIT_RDY	=>	int_start <= '0';
								buttterfly_en <= '0';
								if(IFFT = '1' and s = LOG2_N -1) then
									int_bypass <= '1';
								end if;
									
			when INC_S 		=>	int_start <= '0';
								ce <= '1';
										
			when DONE 		=>	RDY <= '1';
								ce <= '0';
								if(IFFT = '1' and s = LOG2_N -1) then -- TODO Ueberfluessig?
									int_bypass <= '1';
								end if;
									
			when others 	=> 	NULL;
			
		end case;

		-- Inputs, clocked
		if RESET = '1' then
			state <= IDLE;
			
		elsif CLK'event and CLK = '1' then
			case state is
				when IDLE		=>	if START = '1' then 
										state <= RUN; 
									end if;
				-- Start FSM, if start is called					
				when RUN 		=>	state <= WAIT_RDY;
				-- Wait for the internal ready signal
				when WAIT_RDY 	=>	if int_rdy = '1' then 
										state <= INC_S; 
									end if;
				-- Go to the next stage
				when INC_S 		=> 	if (s < LOG2_N - 1) then 
										state <= RUN; else state <= DONE; 
									end if;
				-- FFT is ready					
				when DONE 		=> 	state <= IDLE;
				
				when others 	=> 	NULL;
			end case;
		end if;
	end process;
	
end Behavioral;

