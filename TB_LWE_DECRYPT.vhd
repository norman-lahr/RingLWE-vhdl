library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
USE std.textio.ALL;
use WORK.DECLARATION_PKG.all;

  ENTITY TB_LWE_Decrypt IS
  END TB_LWE_Decrypt;

  ARCHITECTURE behavior OF TB_LWE_Decrypt IS 

  -- Component Declaration
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

	signal CLK 		:STD_LOGIC := '0';
	signal RESET 	:STD_LOGIC := '0';
	signal START 	:STD_LOGIC := '0';
	signal RDY 		:STD_LOGIC := '0';
	signal R2 		:POLYNOMIAL;
	signal M 		:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	signal C1 		:POLYNOMIAL;
	signal C2 		:POLYNOMIAL;

	-- Public Key
	--constant int_A	:INTEGER_ARRAY := (1538, 1694, 678, 205, 1977, 1981, 804, 1035, 952, 559, 1438, 1417, 2017, 174, 809, 194, 1074, 2039, 364, 677, 78, 1760, 1018, 1411, 107, 1058, 198, 1981, 597, 902, 2015, 705, 1638, 727, 256, 594, 900, 396, 457, 1130, 1651, 688, 1450, 1974, 272, 1097, 1185, 58, 688, 1270, 1678, 1471, 2020, 1517, 1774, 447, 1061, 1458, 812, 1854, 1491, 978, 1544, 822, 1013, 970, 633, 184, 123, 1707, 1823, 1170, 1861, 367, 1016, 1710, 60, 331, 1992, 23, 1813, 574, 594, 1949, 1203, 1426, 947, 445, 1513, 1836, 1912, 1787, 1894, 570, 1876, 44, 484, 223, 1421, 864, 1347, 1977, 394, 1592, 785, 893, 177, 1427, 1533, 1723, 508, 415, 1979, 1410, 1765, 1740, 261, 387, 1311, 118, 749, 90, 504, 730, 99, 1894, 343, 943);
	--constant int_P	:INTEGER_ARRAY := (355, 1233, 1168, 388, 1933, 618, 1655, 1946, 1253, 153, 453, 187, 1161, 1522, 1082, 814, 1015, 654, 276, 75, 1601, 1955, 1422, 799, 8, 832, 295, 1599, 804, 252, 414, 2004, 958, 397, 750, 1057, 298, 1862, 891, 757, 295, 604, 329, 1878, 123, 1953, 1818, 321, 1723, 11, 219, 419, 1379, 845, 1528, 197, 1746, 487, 585, 1503, 107, 51, 878, 885, 174, 497, 1445, 633, 925, 868, 434, 1771, 311, 1529, 993, 1827, 710, 659, 1193, 147, 1784, 829, 1586, 1813, 641, 1005, 771, 213, 948, 656, 998, 1551, 460, 2049, 1536, 1875, 1867, 1281, 222, 1977, 728, 556, 1479, 261, 1946, 1502, 474, 1651, 635, 1567, 549, 1702, 428, 1384, 1188, 1495, 2011, 261, 157, 1144, 1075, 593, 15, 1949, 45, 235, 160, 284);
	-- Private Key
	constant int_R2	:INTEGER_ARRAY := (2052, 2051, 2050, 2, 2052, 2051, 2049, 2050, 2049, 1, 2, 2051, 0, 0, 0, 2051, 2052, 2048, 2050, 2051, 2051, 2049, 2052, 1, 2049, 2052, 2048, 5, 2051, 5, 2048, 2051, 2, 2, 0, 2048, 2051, 2050, 2048, 2, 5, 1, 4, 0, 2052, 2, 1, 1, 0, 2051, 0, 2050, 2049, 3, 1, 2, 0, 1, 2052, 2052, 1, 2048, 2, 4, 2052, 0, 0, 0, 2051, 2, 3, 5, 2050, 2052, 1, 2052, 2, 3, 2051, 2, 2051, 2, 0, 2049, 2051, 2050, 2, 2052, 4, 2052, 4, 2, 2, 2049, 2048, 1, 5, 2052, 2049, 3, 2051, 2, 4, 2052, 1, 1, 2049, 4, 1, 2049, 0, 5, 2051, 2050, 3, 4, 5, 1, 1, 0, 2051, 2052, 5, 1, 1, 1, 1, 2050);
  
	constant int_MSG:CHARACTER_ARRAY := ('H','E','L','L','O',' ','W','O','R','L','D','!','!','!','!','!');
	signal cmp_M 	:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	
	--constant int_C1	:INTEGER_ARRAY := (1106, 1486, 3061, 2620, 2553, 1296, 217, 1581, 216, 1987, 2931, 3072, 3206, 1700, 3175, 2482, 1738, 3198, 1871, 3141, 3113, 2296, 485, 2610, 2989, 554, 1107, 871, 921, 2846, 509, 2233, 2820, 1668, 3255, 1623, 2484, 2094, 2069, 2025, 361, 1005, 3129, 928, 638, 1403, 2520, 866, 123, 3251, 3301, 858, 1568, 1121, 171, 1647, 1324, 1804, 1032, 942, 2419, 662, 2442, 1307, 1000, 2378, 812, 589, 3324, 836, 1215, 3032, 59, 1371, 2265, 2859, 481, 241, 1897, 251, 121, 2796, 2952, 2784, 1027, 1452, 651, 2447, 2242, 621, 71, 253, 3154, 2806, 784, 3052, 1800, 2041, 1963, 2401, 528, 956, 891, 774, 1796, 2587, 188, 2146, 2018, 74, 2462, 1636, 480, 1194, 3152, 3137, 1588, 19, 2969, 1431, 858, 1650, 1947, 2922, 2391, 512, 2649, 290);
	constant int_C1	:INTEGER_ARRAY := (1106, 2791, 998, 2516, 2206, 1915, 2521, 2442, 61, 389, 2309, 2957, 933, 262, 1166, 2989, 837, 3212, 3260, 1401, 1857, 1813, 1155, 74, 1215, 1844, 2711, 1444, 3222, 2475, 1189, 1870, 1681, 3082, 3176, 1742, 1035, 3194, 1342, 3121, 2586, 2828, 2084, 2323, 2490, 848, 370, 1915, 1301, 75, 1380, 2015, 2130, 1217, 2775, 3158, 1433, 1271, 2621, 2574, 460, 1338, 3227, 908, 3218, 566, 350, 1955, 525, 793, 356, 1311, 267, 2900, 977, 2108, 499, 2557, 1489, 2445, 19, 1621, 1699, 472, 717, 2784, 1578, 778, 79, 1017, 493, 2488, 2810, 1041, 852, 2853, 940, 1759, 854, 2130, 79, 1745, 1783, 895, 2490, 1466, 831, 2742, 3158, 2603, 552, 3308, 2923, 261, 2774, 1306, 3246, 136, 1062, 238, 1996, 1280, 227, 2779, 1722, 929, 317, 1720);
	--constant int_C2	:INTEGER_ARRAY := (588, 3012, 3199, 2754, 853, 1224, 158, 1851, 2022, 857, 2271, 1748, 1916, 854, 2141, 2459, 1220, 80, 90, 1706, 2954, 2264, 813, 2414, 833, 241, 363, 1129, 2786, 2370, 775, 1631, 984, 1869, 848, 283, 1157, 1033, 2371, 1510, 2300, 254, 1980, 1768, 2310, 3049, 2742, 1896, 394, 2302, 2395, 2949, 584, 204, 1375, 1731, 558, 3015, 2011, 3095, 1092, 953, 2514, 1561, 645, 846, 159, 1378, 3088, 300, 1258, 2974, 308, 2302, 1367, 2422, 1582, 2745, 393, 856, 2922, 2929, 477, 3130, 2037, 242, 2212, 2071, 3325, 253, 293, 2738, 3242, 2561, 135, 1901, 160, 1453, 1442, 2630, 2906, 2785, 531, 2673, 1520, 242, 820, 1110, 1811, 1543, 1811, 2024, 516, 2710, 1993, 1107, 862, 1082, 3217, 1865, 575, 2331, 254, 1750, 373, 1412, 2650, 2502);
	constant int_C2	:INTEGER_ARRAY := ( 588, 1494, 1773, 2095, 307, 442, 1044, 1493, 2888, 1538, 287, 2711, 1865, 219, 2673, 1290, 427, 207, 21, 699, 2363, 999, 2380, 3228, 986, 2897, 1802, 3133, 427, 3056, 2568, 679, 1972, 1639, 1701, 2288, 2836, 1040, 773, 284, 1691, 2554, 694, 2998, 1355, 239, 2862, 2225, 1361, 1279, 2568, 1854, 182, 726, 3175, 2571, 3152, 2532, 180, 659, 690, 1880, 386, 3014, 2467, 2811, 2124, 3200, 2752, 1744, 1151, 2793, 1236, 2714, 1349, 449, 290, 115, 1997, 2490, 1645, 319, 2309, 1278, 2003, 1003, 2673, 654, 2264, 2030, 658, 3087, 2393, 1092, 700, 2244, 1168, 930, 1348, 1396, 3046, 2258, 935, 1246, 2822, 2886, 788, 1827, 1036, 90, 2905, 816, 1341, 865, 2278, 1558, 625, 2701, 1719, 3014, 1872, 1541, 1779, 697, 1094, 3285, 556, 929);
   -- Clock period definitions
   constant PERIOD : time := 10 ns;
   
  BEGIN

  -- Component Instantiation
          uut: LWE_Decrypt PORT MAP(
                  CLK => CLK,
				  RESET => RESET,
				  START => START,
				  RDY => RDY,
				  C1 => C1,
				  C2 => C2,
				  R2 => R2,
				  M => M
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
			--A(i) <= conv_std_logic_vector(int_A(i), MODULUS_Q_WIDTH);
			--P(i) <= conv_std_logic_vector(int_P(i), MODULUS_Q_WIDTH);
			R2(DEGREE_F-1 - i) <= conv_std_logic_vector(int_R2(i), MODULUS_Q_WIDTH);
			C1(i) <= conv_std_logic_vector(int_C1(i), MODULUS_Q_WIDTH);
			C2(i) <= conv_std_logic_vector(int_C2(i), MODULUS_Q_WIDTH);
		end loop;
		
		for i in 0 to MSG_LEN/8-1 loop
			cmp_M((i+1)*8-1 downto i*8) <= CONV_STD_LOGIC_VECTOR(character'pos(int_MSG(i)), 8);
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
		
		write(TX_LOC,string'("M = ")); 
		for i in 0 to MSG_LEN/8-1 loop
			write(TX_LOC, character'val(conv_integer(M((i+1)*8-1 downto i*8))));
			write(TX_LOC, string'(", "));
		end loop;
		
		TX_STR(TX_LOC.all'range) := TX_LOC.all;
		
		Deallocate(TX_LOC);
		ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
		
		if (M /= cmp_M) then
			assert (false) report "Result of decryption is not equal to the original plaintext!" severity ERROR;
		else
			assert (false) report "Simulation successful (not a failure).  No problems detected." severity ERROR;
		end if; 
		
		assert (false) report
			"Simulation successful (not a failure).  No problems detected."
		severity failure;
		
   end process;

  END;
