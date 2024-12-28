--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:33:53 11/14/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE-Encrypt/TB_Mul_Mod.vhd
-- Project Name:  LWE-ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: add_sub_mod
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
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_signed.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
use WORK.Declaration_PKG.ALL;
 
ENTITY TB_Mul_Mod IS
END TB_Mul_Mod;
 
ARCHITECTURE behavior OF TB_Mul_Mod IS 
	COMPONENT mul_mod is
	PORT (
		x, y: in std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
		clk, reset, start: in std_logic; 
		z: out std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
		done: out std_logic
	);
	END COMPONENT;
	--Inputs
	SIGNAL x, y:  std_logic_vector(MODULUS_Q_WIDTH-1 downto 0) := (others=>'0');
	SIGNAL clk: STD_LOGIC := '0'; 
	SIGNAL reset, start, done: std_logic;
	--Outputs
	SIGNAL z :  std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);

	constant DELAY : time := 100 ns;
	constant PERIOD : time := 200 ns;
	constant DUTY_CYCLE : real := 0.5;
	constant OFFSET : time := 0 ns;

BEGIN

	clk <= not clk after PERIOD/2;
	
	-- Instantiate the Unit Under Test (UUT)
	UUT: mul_mod PORT MAP(x => x, y => y, 
						  clk => clk, reset => reset, start => start,
						  z => z, done => done);
						  
	TB_Proc: PROCESS
	
    VARIABLE TX_LOC : LINE;
    VARIABLE TX_STR : String(1 to 4096);
	
    BEGIN
      start <= '0'; reset <= '1';
      WAIT FOR PERIOD;
      reset <= '0';
      WAIT FOR PERIOD;
	  
      for J in 0 to MODULUS_Q-1 loop
        for I in 0 to MODULUS_Q-1 loop
          x <= CONV_STD_LOGIC_VECTOR (I, MODULUS_Q_WIDTH);
          y <= CONV_STD_LOGIC_VECTOR (J, MODULUS_Q_WIDTH);
          start <= '1';
          WAIT FOR PERIOD;
          start <= '0';
          wait until done = '1';
          WAIT FOR PERIOD;
          IF ( ((I*J) mod MODULUS_Q) /= ieee.std_logic_unsigned.CONV_INTEGER(z) ) THEN 
            write(TX_LOC,string'("ERROR!!! X=")); write(TX_LOC, x);
            write(TX_LOC,string'("* Y=")); write(TX_LOC, y);
            write(TX_LOC,string'(" mod Q=")); write(TX_LOC, Q);
            write(TX_LOC,string'(" is Z=")); write(TX_LOC, z);
            write(TX_LOC,string'(" instead of:")); write(TX_LOC, (I*J) mod MODULUS_Q);
            write(TX_LOC, string'(" "));
            write(TX_LOC,string'(" (i=")); write(TX_LOC, i);
            write(TX_LOC,string'(" j=")); write(TX_LOC, j); 
            write(TX_LOC, string'(")"));
            TX_STR(TX_LOC.all'range) := TX_LOC.all;
            Deallocate(TX_LOC);
            ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
          END IF;  
          end loop;
      end loop;
    WAIT FOR DELAY;
    ASSERT (FALSE) REPORT
    "Simulation successful (not a failure).  No problems detected. "
    SEVERITY FAILURE;
	END PROCESS;
END;
