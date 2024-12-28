--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:15:00 12/01/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_ENC_DEC.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Encode
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;
 
ENTITY TB_ENC_DEC IS
END TB_ENC_DEC;
 
ARCHITECTURE behavior OF TB_ENC_DEC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Encode
    PORT(
         M : IN  STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
         Z : OUT  POLYNOMIAL
        );
    END COMPONENT;
	
    component Decode is
    port( 
		M :in POLYNOMIAL;
		Z :out STD_LOGIC_VECTOR (MSG_LEN-1 downto 0)
		);
	end component;

   --Inputs
   signal M_enc : STD_LOGIC_VECTOR (MSG_LEN-1 downto 0) := (others => '0');
   signal M_dec : POLYNOMIAL := (others =>(others => '0'));

 	--Outputs
   signal Z_enc : POLYNOMIAL;
   signal Z_dec : STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);

	signal CLK	:STD_LOGIC := '0';
 
   constant PERIOD : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Encode PORT MAP (
          M => M_enc,
          Z => Z_enc
        );
	uut_dec: Decode PORT MAP (
          M => M_dec,
          Z => Z_dec
        );

	CLK <= not CLK after PERIOD/2;
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for PERIOD;	
	
	for i in 0 to MSG_LEN/8 -1 loop
		M_enc(((i+1) * 8)-1 downto i * 8) <= CONV_STD_LOGIC_VECTOR(character'pos('A')+i, 8);
	end loop;
	
	wait for PERIOD;
	
	M_dec <= Z_enc;
	
	wait for PERIOD;
	if (M_enc /= Z_dec) then
		assert (false) report "Output of Decoder is not equal to the input of Encoder!" severity ERROR;
	end if; 
	if (M_enc = Z_dec) then
		assert (false) report "Success!" severity ERROR;
	end if; 
      wait;
   end process;

END;
