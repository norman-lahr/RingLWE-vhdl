-- TestBench Template 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
USE std.textio.ALL;
use WORK.DECLARATION_PKG.all;

  ENTITY TB_LWE_System IS
  END TB_LWE_System;

  ARCHITECTURE behavior OF TB_LWE_System IS 

-- Component Declaration
	COMPONENT LWE_Encrypt
		Port ( CLK : in  STD_LOGIC;
			   RESET : in  STD_LOGIC;
			   START : in  STD_LOGIC;
			   RDY : out  STD_LOGIC;
			   A : in  POLYNOMIAL;
			   P : in  POLYNOMIAL;
			   M : in  STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
			   C1 : out  POLYNOMIAL;
			   C2 : out  POLYNOMIAL
			   );
	END COMPONENT;

	signal CLK 			:STD_LOGIC := '0';
	signal RESET_ENC 	:STD_LOGIC := '0';
	signal START_ENC 	:STD_LOGIC := '0';
	signal RDY_ENC 		:STD_LOGIC := '0';
	signal A_ENC 		:POLYNOMIAL;
	signal P_ENC 		:POLYNOMIAL;
	signal M_ENC 		:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	signal C1_ENC 		:POLYNOMIAL;
	signal C2_ENC 		:POLYNOMIAL;


	COMPONENT LWE_Decrypt
		port( 
			CLK : in  STD_LOGIC;
			RESET : in  STD_LOGIC;
			START : in  STD_LOGIC;
			RDY : out  STD_LOGIC;
			C1 : in  POLYNOMIAL;
			C2 : in  POLYNOMIAL;
			R2 : in  POLYNOMIAL;
			M : out  STD_LOGIC_VECTOR (MSG_LEN-1 downto 0)
			);
	END COMPONENT;

	signal RESET_DEC 	:STD_LOGIC := '0';
	signal START_DEC 	:STD_LOGIC := '0';
	signal RDY_DEC 		:STD_LOGIC := '0';
	signal R2_DEC 		:POLYNOMIAL;
	signal M_DEC 		:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	signal C1_DEC 		:POLYNOMIAL;
	signal C2_DEC 		:POLYNOMIAL;
	
	-- Public Key
	constant int_A	:INTEGER_ARRAY := (1514, 1720, 985, 1410, 3147, 1882, 1858, 2441, 1195, 1656, 783, 854, 2380, 681, 2023, 2231, 2141, 247, 1422, 771, 1632, 871, 1100, 110, 978, 2892, 2900, 1360, 1156, 2964, 1610, 222, 296, 97, 3129, 1557, 2851, 2763, 2261, 2005, 2909, 2233, 1309, 1994, 1274, 3232, 2998, 1954, 2834, 1809, 2012, 2535, 139, 1425, 1285, 2000, 2787, 2946, 1003, 2992, 2547, 2494, 3140, 2624, 1254, 3292, 1976, 1338, 1461, 1488, 1905, 379, 2456, 247, 2717, 3185, 3177, 1995, 576, 473, 306, 1949, 1014, 3095, 885, 114, 2644, 2198, 3203, 2916, 2450, 207, 495, 747, 866, 446, 3010, 288, 2221, 2842, 2196, 414, 2561, 3148, 2219, 309, 2410, 2855, 663, 2511, 1106, 3138, 2928, 3058, 274, 2676, 1097, 2098, 3177, 938, 2016, 3318, 2774, 2401, 2860, 673, 2075, 510);
	constant int_P	:INTEGER_ARRAY := (928, 780, 31, 2085, 2498, 2208, 2290, 1714, 2634, 3144, 2608, 3208, 2150, 1836, 778, 2904, 192, 2164, 16, 2551, 2690, 919, 3314, 2189, 3277, 1870, 1974, 867, 743, 1273, 2958, 2216, 2992, 1031, 1672, 2331, 852, 46, 994, 693, 333, 1709, 3078, 2137, 3129, 430, 3252, 1470, 1148, 395, 2194, 1646, 3302, 120, 1675, 1785, 1299, 683, 1769, 1533, 264, 1132, 1157, 2709, 1681, 997, 2248, 2625, 1788, 2449, 3313, 2067, 358, 2503, 2179, 599, 1022, 230, 1183, 2771, 2505, 1559, 524, 2396, 3162, 1368, 453, 1730, 3190, 1688, 1075, 727, 1833, 2389, 2659, 615, 2305, 2252, 2621, 483, 355, 218, 90, 709, 1683, 1446, 1914, 1912, 2718, 199, 50, 1495, 29, 531, 2706, 2057, 217, 1726, 401, 2361, 653, 2581, 834, 150, 2040, 2489, 636, 2290);
	-- Private Key
	constant int_R2	:INTEGER_ARRAY := (3326, 6, 3, 1, 2, 2, 3328, 2, 2, 3328, 2, 3325, 2, 3326, 0, 3, 5, 0, 2, 2, 3327, 3, 2, 3324, 4, 4, 3328, 3326, 3328, 3, 4, 3328, 0, 0, 1, 0, 3327, 1, 1, 3324, 3327, 0, 1, 3327, 3327, 3325, 4, 0, 1, 3327, 3326, 1, 3, 1, 0, 0, 3327, 3328, 3327, 1, 0, 3326, 2, 3328, 4, 2, 3327, 3323, 3326, 3327, 0, 4, 3, 2, 3326, 5, 1, 2, 1, 3325, 3327, 3327, 3, 3328, 2, 1, 2, 2, 2, 3325, 3328, 3328, 3326, 3328, 2, 3326, 1, 3328, 3328, 3328, 3327, 5, 5, 0, 5, 3326, 2, 1, 3324, 3327, 3328, 1, 6, 3, 3325, 3326, 1, 0, 1, 3, 0, 3328, 5, 3328, 3, 3328, 1, 5);
  
	constant int_MSG:CHARACTER_ARRAY := ('H','E','L','L','O',' ','W','O','R','L','D','!','!','!','!','!');
	
   -- Clock period definitions
   constant PERIOD : time := 10 ns;
   
  BEGIN

  -- Component Instantiation
          uut1: LWE_Encrypt PORT MAP(
                  CLK => CLK,
				  RESET => RESET_ENC,
				  START => START_ENC,
				  RDY => RDY_ENC,
				  A => A_ENC,
				  P => P_ENC,
				  M => M_ENC,
				  C1 => C1_ENC,
				  C2 => C2_ENC
          );

          uut2: LWE_Decrypt PORT MAP(
                  CLK => CLK,
				  RESET => RESET_DEC,
				  START => START_DEC,
				  RDY => RDY_DEC,
				  C1 => C1_DEC,
				  C2 => C2_DEC,
				  R2 => R2_DEC,
				  M => M_DEC
          );
   -- Clock process definitions
	CLK <= not CLK after PERIOD/2;

   -- Stimulus process
   stim_proc: process
   
    
	VARIABLE TX_LOC : LINE;
	VARIABLE TX_STR : String(1 to 4096);
	
   begin		
		-- Init inputs
		for i in 0 to DEGREE_F-1 loop
			A_ENC(i) <= conv_std_logic_vector(int_A(i), MODULUS_Q_WIDTH);
			P_ENC(i) <= conv_std_logic_vector(int_P(i), MODULUS_Q_WIDTH);
			R2_DEC(i) <= conv_std_logic_vector(int_R2(i), MODULUS_Q_WIDTH);
		end loop;
		
		for i in 0 to MSG_LEN/8-1 loop
			M_ENC((i+1)*8-1 downto i*8) <= CONV_STD_LOGIC_VECTOR(character'pos(int_MSG(i)), 8);
		end loop;

		-- Encrypt
		wait for PERIOD;
		RESET_ENC <= '1';
		wait for PERIOD;
		RESET_ENC <= '0';
		wait for 10*PERIOD;

		START_ENC <= '1';
		wait for PERIOD;
		START_ENC <= '0';
		wait until RDY_ENC = '1';
		wait for PERIOD;
		
		write(TX_LOC,string'(LF & "C1 = ")); 
		for i in 0 to DEGREE_F-1 loop
			write(TX_LOC, conv_integer(C1_ENC(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		write(TX_LOC,string'(LF & "C2 = ")); 
		for i in 0 to DEGREE_F-1 loop
			write(TX_LOC, conv_integer(C2_ENC(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		TX_STR(TX_LOC.all'range) := TX_LOC.all;
		
		Deallocate(TX_LOC);
		ASSERT (FALSE) REPORT TX_STR SEVERITY NOTE;
		TX_STR := (others => ' ');
		
		C1_DEC <= C1_ENC;
		C2_DEC <= C2_ENC;
		
		
		-- Decrypt
		wait for 9*PERIOD;
		RESET_DEC <= '1';
		wait for PERIOD;
		RESET_DEC <= '0';
		wait for 10*PERIOD;

		START_DEC <= '1';
		wait for PERIOD;
		START_DEC <= '0';
		wait until RDY_DEC = '1';
		wait for PERIOD;
		
		write(TX_LOC,string'(LF & "M_ENC = ")); 
		for i in 0 to MSG_LEN/8-1 loop
			write(TX_LOC, character'val(conv_integer(M_ENC((i+1)*8-1 downto i*8))));
			write(TX_LOC, string'(", "));
		end loop;
		
		write(TX_LOC,string'(LF & "M_ENC(bin) = ")); 
		for i in 0 to MSG_LEN-1 loop
			write(TX_LOC, conv_integer(M_ENC(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		write(TX_LOC,string'(LF & "M_DEC = ")); 
		for i in 0 to MSG_LEN/8-1 loop
			write(TX_LOC, character'val(conv_integer(M_DEC((i+1)*8-1 downto i*8))));
			write(TX_LOC, string'(", "));
		end loop;
		
		write(TX_LOC,string'(LF & "M_DEC(bin) = ")); 
		for i in 0 to MSG_LEN-1 loop
			write(TX_LOC, conv_integer(M_DEC(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		TX_STR(TX_LOC.all'range) := TX_LOC.all;
		
		Deallocate(TX_LOC);
		ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
		TX_STR := (others => ' ');
		
		if (M_DEC /= M_ENC) then
			assert (false) report "Result of decryption is not equal to the original plaintext!" severity failure;
		else
			assert (false) report "Simulation successful (not a failure).  No problems detected." severity failure;
		end if; 
		
		
		assert (false) report
		"Simulation successful (not a failure).  No problems detected."
		severity failure;
   end process;
  END;
