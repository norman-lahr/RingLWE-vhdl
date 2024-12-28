--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:09:30 12/07/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_Gauss_Sampler.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Gauss_Sampler
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
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;
use STD.TEXTIO.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_Gauss_Sampler IS
END TB_Gauss_Sampler;
 
ARCHITECTURE behavior OF TB_Gauss_Sampler IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Gauss_Sampler
    PORT(
         CLK : IN  std_logic;
         INIT : IN  std_logic;
         Z : OUT  N_BIT_INT
        );
    END COMPONENT;
    

	--Inputs
	signal CLK : std_logic := '0';
	signal INIT : std_logic := '0';

	--Outputs
	signal Z : N_BIT_INT := (others => '0');

	-- Clock period definitions
	constant PERIOD : time := 10 ns;

	constant SAMPLES	:INTEGER := 100000;
	constant HIST_LENGTH	:INTEGER := getConentLength(GAUSSIAN_RESOLUTION, CONST_S);
	signal hist				:INTEGER_ARRAY(HIST_LENGTH-1 downto 0);
	signal addr_int			:INTEGER := 0;
	signal z_int			:INTEGER := 0;

	constant GAUSS_ARRAY_SIZE	:INTEGER := integer(2.0*ceil(2.0*CONST_S)+1.0);
	constant tmpGaussianArray	:INTEGER_ARRAY(GAUSS_ARRAY_SIZE-1 downto 0) := gaussianArray(GAUSSIAN_RESOLUTION, CONST_S);

	signal sum	:INTEGER:=0;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: Gauss_Sampler PORT MAP (
		  CLK => CLK,
		  INIT => INIT,
		  Z => Z
		);

	clk <= not clk after PERIOD/2;


	-- Stimulus process
	stim_proc: process

		begin		
			-- hold reset state for 100 ns.
			for i in 0 to HIST_LENGTH-1 loop
				hist(i) <= 0;
			end loop;
			sum <= 0;
			for i in 0 to GAUSS_ARRAY_SIZE-1 loop
				sum <= sum + tmpGaussianArray(i);
			end loop;
			
			wait for PERIOD;
			INIT <= '1';
			wait for PERIOD;
			INIT <= '0';
			wait for PERIOD;
			
			for i in 0 to SAMPLES-1 loop
				z_int <= conv_integer(Z);
				if (z_int > HIST_LENGTH/2) then
					addr_int <= z_int - MODULUS_Q;
				else 
					addr_int <= z_int;
				end if;
				
				hist(addr_int + HIST_LENGTH/2) <= hist(addr_int + HIST_LENGTH/2) +1;
				wait for 10*PERIOD;
			end loop;
			
			wait for PERIOD;
			assert (false) report
			"Simulation successful (not a failure).  No problems detected. Look at hist() for evaluation."
			severity failure;

		end process;

END;
