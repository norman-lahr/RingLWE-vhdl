----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:16:24 11/29/2011 
-- Design Name: 
-- Module Name:    Mul_Mod_Poly - Behavioral 
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


entity Mul_Mod_Poly is
    port( 
		A		:in POLYNOMIAL;
        B		:in POLYNOMIAL;
		Z		:out POLYNOMIAL;
        CLK		:in STD_LOGIC;
		RESET	:in  STD_LOGIC;
        START	:in STD_LOGIC;
        RDY		:out STD_LOGIC
		);
end Mul_Mod_Poly;

architecture Behavioral of Mul_Mod_Poly is

	component FFT is
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
	end component FFT;
	
	component Mul_Mod_Vec is
		port( 
			A		:in POLYNOMIAL;
			B		:in POLYNOMIAL;
			Z		:out POLYNOMIAL;
			CLK		:in STD_LOGIC;
			RESET	:in  STD_LOGIC;
			START	:in STD_LOGIC;
			LOAD_A	:in STD_LOGIC;
			LOAD_B	:in STD_LOGIC;
			RDY		:out STD_LOGIC
			);
	end component Mul_Mod_Vec;

	signal start_fft, load_fft, rdy_fft, ifft_fft	:STD_LOGIC;
	signal start_mul, rdy_mul, load_a, load_b		:STD_LOGIC;
	
	signal A_fft, Z_fft						:POLYNOMIAL_2K;
	signal int_a, int_b, int_z				:POLYNOMIAL_2K;
	
	signal A_mul_vec, B_mul_vec, Z_mul_vec	:POLYNOMIAL;
	signal select_in						:INTEGER range 0 to 2;

	type STATE_T is(IDLE, FFT_LOAD_A, FFT_START_A, WAIT_FOR_RDY_A, 
					FFT_LOAD_B, FFT_START_B, WAIT_FOR_RDY_B, MULT_LOAD_B, 
					MULT_VEC_START, WAIT_FOR_RDY_MULT_VEC, IFFT_LOAD_Z, 
					IFFT_START, WAIT_FOR_RDY_Z, DONE);
	signal state: STATE_T;
begin

   FFT1: FFT port map (
						A => A_fft,
						Z => Z_fft,
						CLK => CLK,
						START => start_fft,
						RESET => RESET,
						LOAD => load_fft,
						IFFT => ifft_fft,
						RDY => rdy_fft
						);
	Mul_Mod_Vec1: Mul_Mod_Vec port map (
										A => A_mul_vec,
										B => B_mul_vec,
										Z => Z_mul_vec,
										CLK => CLK,
										RESET => RESET,
										START => start_mul,
										LOAD_A => load_a,
										LOAD_B => load_b,
										RDY => rdy_mul
										);
										
	with select_in select A_fft <= int_a when 0, 
									int_b when 1, 
									int_z when 2, 
									(others => (others => '0')) when others;
	
	-- Set the second half of the FFT input to zero
	Gen_int_a: for i in A'range generate
		int_a(i) <= A(i);
	end generate;
	
	int_a(int_a'high downto A'high+1) <= (others => (others => '0'));
	
	Gen_int_b: for i in B'range generate
		int_b(i) <= B(i);
	end generate;
	
	int_b(int_b'high downto B'high+1) <= (others => (others => '0'));
	
	-- Map elements of multiplication to every second
	-- element of the last FFT input
	Gen_int_z: for i in Z_mul_vec'low to Z_mul_vec'high generate
		int_z(2*i) <= (others => '0');
		int_z(2*i+1) <= Z_mul_vec(i);
	end generate;
	
	-- Map every second element of FFT output to 
	-- elements of multiplication input and global output
	Gen_fft_out: for i in A_mul_vec'low to A_mul_vec'high generate
		A_mul_vec(i) <= Z_fft(2*i+1);
		B_mul_vec(i) <= Z_fft(2*i+1);
		Z(i) <= Z_fft(i);
	end generate;
	
	
	-- Control unit --
	control_unit: process(CLK, RESET, state)
	begin
		-- These assignments are avoiding latches
		select_in <= 0;
		load_fft <= '0';
		RDY <= '0';	
		start_fft <= '0';											
		load_a <= '0';
		load_b <= '0';
		start_mul <= '0';
		ifft_fft <= '0';
		
		-- Outputs
		case state is
			when IDLE					=>	select_in <= 0;
											load_fft <= '0';
											RDY <= '0';	
											start_fft <= '0';											
											load_a <= '0';
											load_b <= '0';
											start_mul <= '0';
											ifft_fft <= '0';
			
			when FFT_LOAD_A 			=> 	load_fft <= '1';
											select_in <= 0;
			
			when FFT_START_A			=>	load_fft <= '0';
											start_fft <= '1';
											select_in <= 0;
			
			when WAIT_FOR_RDY_A			=>	start_fft <= '0';
											select_in <= 1;
			
			when FFT_LOAD_B				=>	load_fft <= '1';
											load_a <= '1';
											select_in <= 1;
			
			when FFT_START_B			=>	load_fft <= '0';
											load_a <= '0';
											start_fft <= '1';
											select_in <= 1;
			
			when WAIT_FOR_RDY_B			=>	start_fft <= '0';
											select_in <= 2;
			
			when MULT_LOAD_B			=>	load_b <= '1';
											select_in <= 2;
			
			when MULT_VEC_START			=>	load_b <= '0';
											start_mul <= '1';
											select_in <= 2;
			
			when WAIT_FOR_RDY_MULT_VEC	=>	start_mul <= '0';
											select_in <= 2;
			
			when IFFT_LOAD_Z			=>	load_fft <= '1';
											ifft_fft <= '1';
											select_in <= 2;
			
			when IFFT_START				=>	load_fft <= '0';
											start_fft <= '1';
											ifft_fft <= '1';
											select_in <= 2;
			
			when WAIT_FOR_RDY_Z			=>	start_fft <= '0';
											ifft_fft <= '1';
											select_in <= 2;
			
			when DONE					=>	RDY <= '1';
											select_in <= 2;
			
			when others 	=> 	NULL;
			
		end case;

		-- Inputs, clocked
		if RESET = '1' then
			state <= IDLE;
			
		elsif CLK'event and CLK = '1' then
			case state is
				when IDLE					=>	if(START = '1') then
													state <= FFT_LOAD_A;
												end if;
				
				when FFT_LOAD_A 			=>	state <= FFT_START_A;
				
				when FFT_START_A			=>	state <= WAIT_FOR_RDY_A;
				
				when WAIT_FOR_RDY_A			=>	if(rdy_fft = '1') then
													state <= FFT_LOAD_B;
												end if;
				
				when FFT_LOAD_B				=>	state <= FFT_START_B;
				
				when FFT_START_B			=>	state <= WAIT_FOR_RDY_B;
				
				when WAIT_FOR_RDY_B			=>	if(rdy_fft = '1') then
													state <= MULT_LOAD_B;
												end if;
				
				when MULT_LOAD_B			=>	state <= MULT_VEC_START;
				
				when MULT_VEC_START			=>	state <= WAIT_FOR_RDY_MULT_VEC;
				
				when WAIT_FOR_RDY_MULT_VEC	=>	if(rdy_mul = '1') then
													state <= IFFT_LOAD_Z;
												end if;
				
				when IFFT_LOAD_Z			=>	state <= IFFT_START;
				
				when IFFT_START				=>	state <= WAIT_FOR_RDY_Z;
				
				when WAIT_FOR_RDY_Z			=>	if(rdy_FFT = '1') then
													state <= DONE;
												end if;
				
				when DONE					=>	state <= IDLE;
				
				when others 	=> 	NULL;
			end case;
		end if;
	end process;
	
	
end Behavioral;

