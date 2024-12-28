--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:51:34 11/09/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE-ENCRYPT/TB_Add_Sub_Poly.vhd
-- Project Name:  LWE-ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: add_sub_poly
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
use IEEE.STD_LOGIC_1164.ALL;				-- Signal Types
use IEEE.STD_LOGIC_ARITH.ALL;			-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.ALL;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.NUMERIC_STD.ALL;				-- Numerical Computation
use IEEE.STD_LOGIC_TEXTIO.ALL;			-- User input/output
use IEEE.MATH_REAL.ALL;					-- Numerical computation on type REAL

use WORK.Declaration_PKG.ALL;
use STD.TEXTIO.ALL;

entity tb_add_sub_poly is
end tb_add_sub_poly;

architecture BEHAVIOUR of tb_add_sub_poly is

  -- Component Declaration for the Unit Under Test (UUT1)
  component add_sub_poly is
    port(
      a, b		: in POLYNOMIAL;
      add_sub	: in STD_LOGIC;  
      z			: out POLYNOMIAL);
  end component add_sub_poly;
  
    -- Internal signals
  constant DELAY : TIME := 100 ns;
  constant NUMBER_TESTS: NATURAL := 100;
  signal x, y, x_minus_y, x_plus_y, xx, yy: polynomial := (others => ZERO_COEF);

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut1: add_sub_poly PORT MAP(a => x, b => y, add_sub => '1', z => x_minus_y);
  uut2: add_sub_poly PORT MAP(a => x_minus_y, b => y, add_sub => '0', z => xx);
  uut3: add_sub_poly PORT MAP(a => x, b => y, add_sub => '0', z => x_plus_y);
  uut4: add_sub_poly PORT MAP(a => x_plus_y, b => x, add_sub => '1', z => yy);

  tb_proc : process --generate values
    procedure gen_polynom(X : out polynomial; w: natural; s1, s2: inout Natural) is
      variable i_x, i_p: INTEGER;
      variable rand: REAL;
    begin      
        i_p := conv_integer(('0' & Q));
        for i in 0 to DEGREE_F-1 loop
          UNIFORM(s1, s2, rand);
          i_x := INTEGER(TRUNC(rand * real(i_p)));
          X(i) := CONV_STD_LOGIC_VECTOR (i_x, MODULUS_Q_WIDTH);
        end loop;
    end procedure;

    variable seed1, seed2: POSITIVE; 
    variable aPol: POLYNOMIAL;
    variable i_x: NATURAL;
    variable rand: REAL;

  begin

    wait for DELAY;
    for I in 1 to NUMBER_TESTS loop
      gen_polynom(aPol, DEGREE_F, seed1, seed2);
      x <= aPol;
      gen_polynom(aPol, DEGREE_F, seed1, seed2);
      y <= aPol;
      wait for DELAY;
      if ( (x /= xx) or (y /= yy) ) then
        assert (false) report "ERROR!!! X-Y+Y /= X  or  X+Y-X /= Y" severity ERROR;
      end if;  
 
    end loop;
    wait for DELAY;
    assert (false) report "Simulation successful!.  Not error detected"
    severity FAILURE;
  end process;

end;