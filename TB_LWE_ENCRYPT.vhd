library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
USE std.textio.ALL;
use WORK.DECLARATION_PKG.all;

  ENTITY TB_LWE_Encrypt IS
  END TB_LWE_Encrypt;

  ARCHITECTURE behavior OF TB_LWE_Encrypt IS 

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

	signal CLK 		:STD_LOGIC := '0';
	signal RESET 	:STD_LOGIC := '0';
	signal START 	:STD_LOGIC := '0';
	signal RDY 		:STD_LOGIC := '0';
	signal A 		:POLYNOMIAL;
	signal P 		:POLYNOMIAL;
	signal M 		:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	signal C1 		:POLYNOMIAL;
	signal C2 		:POLYNOMIAL;

	-- Public Key
	constant int_A	:INTEGER_ARRAY := (1538, 1694, 678, 205, 1977, 1981, 804, 1035, 952, 559, 1438, 1417, 2017, 174, 809, 194, 1074, 2039, 364, 677, 78, 1760, 1018, 1411, 107, 1058, 198, 1981, 597, 902, 2015, 705, 1638, 727, 256, 594, 900, 396, 457, 1130, 1651, 688, 1450, 1974, 272, 1097, 1185, 58, 688, 1270, 1678, 1471, 2020, 1517, 1774, 447, 1061, 1458, 812, 1854, 1491, 978, 1544, 822, 1013, 970, 633, 184, 123, 1707, 1823, 1170, 1861, 367, 1016, 1710, 60, 331, 1992, 23, 1813, 574, 594, 1949, 1203, 1426, 947, 445, 1513, 1836, 1912, 1787, 1894, 570, 1876, 44, 484, 223, 1421, 864, 1347, 1977, 394, 1592, 785, 893, 177, 1427, 1533, 1723, 508, 415, 1979, 1410, 1765, 1740, 261, 387, 1311, 118, 749, 90, 504, 730, 99, 1894, 343, 943);
	constant int_P	:INTEGER_ARRAY := (355, 1233, 1168, 388, 1933, 618, 1655, 1946, 1253, 153, 453, 187, 1161, 1522, 1082, 814, 1015, 654, 276, 75, 1601, 1955, 1422, 799, 8, 832, 295, 1599, 804, 252, 414, 2004, 958, 397, 750, 1057, 298, 1862, 891, 757, 295, 604, 329, 1878, 123, 1953, 1818, 321, 1723, 11, 219, 419, 1379, 845, 1528, 197, 1746, 487, 585, 1503, 107, 51, 878, 885, 174, 497, 1445, 633, 925, 868, 434, 1771, 311, 1529, 993, 1827, 710, 659, 1193, 147, 1784, 829, 1586, 1813, 641, 1005, 771, 213, 948, 656, 998, 1551, 460, 2049, 1536, 1875, 1867, 1281, 222, 1977, 728, 556, 1479, 261, 1946, 1502, 474, 1651, 635, 1567, 549, 1702, 428, 1384, 1188, 1495, 2011, 261, 157, 1144, 1075, 593, 15, 1949, 45, 235, 160, 284);
	-- Private Key
	--constant int_R2	:INTEGER_ARRAY := (2052, 2051, 2050, 2, 2052, 2051, 2049, 2050, 2049, 1, 2, 2051, 0, 0, 0, 2051, 2052, 2048, 2050, 2051, 2051, 2049, 2052, 1, 2049, 2052, 2048, 5, 2051, 5, 2048, 2051, 2, 2, 0, 2048, 2051, 2050, 2048, 2, 5, 1, 4, 0, 2052, 2, 1, 1, 0, 2051, 0, 2050, 2049, 3, 1, 2, 0, 1, 2052, 2052, 1, 2048, 2, 4, 2052, 0, 0, 0, 2051, 2, 3, 5, 2050, 2052, 1, 2052, 2, 3, 2051, 2, 2051, 2, 0, 2049, 2051, 2050, 2, 2052, 4, 2052, 4, 2, 2, 2049, 2048, 1, 5, 2052, 2049, 3, 2051, 2, 4, 2052, 1, 1, 2049, 4, 1, 2049, 0, 5, 2051, 2050, 3, 4, 5, 1, 1, 0, 2051, 2052, 5, 1, 1, 1, 1, 2050);
  
	constant int_MSG:CHARACTER_ARRAY := ('H','E','L','L','O',' ','W','O','R','L','D','!','!','!','!','!');
	
	
   -- Clock period definitions
   constant PERIOD : time := 10 ns;
   
  BEGIN

  -- Component Instantiation
          uut: LWE_Encrypt PORT MAP(
                  CLK => CLK,
				  RESET => RESET,
				  START => START,
				  RDY => RDY,
				  A => A,
				  P => P,
				  M => M,
				  C1 => C1,
				  C2 => C2
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
			A(DEGREE_F-1 - i) <= conv_std_logic_vector(int_A(i), MODULUS_Q_WIDTH);
			P(DEGREE_F-1 - i) <= conv_std_logic_vector(int_P(i), MODULUS_Q_WIDTH);
			--R2(i) <= conv_std_logic_vector(int_R2(i), MODULUS_Q_WIDTH);
		end loop;
		
		for i in 0 to MSG_LEN/8-1 loop
			M((i+1)*8-1 downto i*8) <= CONV_STD_LOGIC_VECTOR(character'pos(int_MSG(i)), 8);
		end loop;
		
		
		wait for PERIOD;
		RESET <= '1';
		wait for PERIOD;
		RESET <= '0';
		wait for 10*PERIOD;

		START <= '1';
		wait for PERIOD;
		START <= '0';
		wait until RDY = '1';
		wait for PERIOD;
		
		write(TX_LOC,string'("C1 = ")); 
		for i in 0 to DEGREE_F-1 loop
			write(TX_LOC, conv_integer(C1(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		write(TX_LOC,string'("C2 = ")); 
		for i in 0 to DEGREE_F-1 loop
			write(TX_LOC, conv_integer(C2(i)));
			write(TX_LOC, string'(", "));
		end loop;
		
		TX_STR(TX_LOC.all'range) := TX_LOC.all;
		
		Deallocate(TX_LOC);
		ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
		
		write(TX_LOC,string'("M = ")); 
		for i in 0 to MSG_LEN/8-1 loop
			write(TX_LOC, character'val(conv_integer(M_DEC((i+1)*8-1 downto i*8))));
			write(TX_LOC, string'(", "));
		end loop;
		
		TX_STR(TX_LOC.all'range) := TX_LOC.all;
		
		Deallocate(TX_LOC);
		ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
		
		if (M /= cmp_M) then
			assert (false) report "Result of decryption is not equal to the original plaintext!" severity failure;
		else
			assert (false) report "Simulation successful (not a failure).  No problems detected." severity failure;
		end if; 
		
		assert (false) report
		"Simulation successful (not a failure).  No problems detected."
		severity failure;
   end process;

  END;
