library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;

  ENTITY TB_LWE_KeyGen IS
  END TB_LWE_KeyGen;

  ARCHITECTURE behavior OF TB_LWE_KeyGen IS 

  -- Component Declaration
	component LWE_KeyGen is
		Port ( CLK : in  STD_LOGIC;
			   RESET : in  STD_LOGIC;
			   START : in  STD_LOGIC;
			   RDY : out  STD_LOGIC;
			   A : out  POLYNOMIAL;
			   P : out  POLYNOMIAL;
			   R2 : out  POLYNOMIAL
			   );
	end component LWE_KeyGen;
          
   --Inputs
   signal CLK : std_logic := '1';
   signal RESET : std_logic := '0';
   signal START : std_logic := '0';

 	--Outputs
   signal RDY	: std_logic;
   signal A 	: POLYNOMIAL;
   signal P 	: POLYNOMIAL;
   signal R2	: POLYNOMIAL;

   -- Clock period definitions
   constant PERIOD : time := 10 ns;
   
  BEGIN

  -- Component Instantiation
          uut: LWE_KeyGen 
					PORT MAP(
						  CLK => CLK,
						  RESET => RESET,
						  START => START,
						  RDY => RDY,
						  A => A,
						  P => P,
						  R2 => R2
							);


   -- Clock process definitions
	CLK <= not CLK after PERIOD/2;
 

   -- Stimulus process
   stim_proc: process
   begin		
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
		assert (false) report
		"Simulation successful (not a failure).  No problems detected."
		severity failure;
   end process;

  END;
