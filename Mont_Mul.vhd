----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:57:44 11/14/2011 
-- Design Name: 
-- Module Name:    Mul_Mod - RTL 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Montgomery Multiplier
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;				-- Signal Types
use IEEE.STD_LOGIC_ARITH.ALL;			-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.ALL;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use WORK.Declaration_PKG.ALL;

entity mont_mul is
port (
  x, y: in std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
  clk, reset, start: in std_logic;
  z: out std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
  done: out std_logic
);
end mont_mul;

architecture rtl of mont_mul is
  signal p, pc, ps, y_by_xi, next_pc, next_ps, 
         half_ac, half_as, half_bc, half_bs, p_minus_m: std_logic_vector(MODULUS_Q_WIDTH downto 0);
  signal ac, as, bc, bs, long_m: std_logic_vector(MODULUS_Q_WIDTH+1 downto 0);
  signal int_x: std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
  signal xi, load, ce_p, equal_zero: std_logic;
  type states is range 0 to 3;
  signal current_state: states;
  signal count: std_logic_vector(LOG_MODULUS_Q_WIDTH-1 downto 0);
begin
  and_gates: for i in 0 to MODULUS_Q_WIDTH-1 generate y_by_xi(i) <= y(i) and xi; end generate;
  y_by_xi(MODULUS_Q_WIDTH) <= '0';

  first_csa: for i in 0 to MODULUS_Q_WIDTH generate
    as(i) <= pc(i) xor ps(i) xor y_by_xi(i);
    ac(i+1) <= (pc(i) and ps(i)) or (pc(i) and y_by_xi(i)) or (ps(i) and y_by_xi(i));
  end generate;
  ac(0) <= '0'; as(MODULUS_Q_WIDTH+1) <= '0';
  long_m <= "00"&m;
  second_csa: for i in 0 to MODULUS_Q_WIDTH generate
    bs(i) <= ac(i) xor as(i) xor long_m(i);
    bc(i+1) <= (ac(i) and as(i)) or (ac(i) and long_m(i)) or (as(i) and long_m(i));
  end generate;
  bc(0) <= '0'; bs(MODULUS_Q_WIDTH+1) <= ac(MODULUS_Q_WIDTH+1);
  half_as <= as(MODULUS_Q_WIDTH+1 downto 1); half_ac <= ac(MODULUS_Q_WIDTH+1 downto 1);
  half_bs <= bs(MODULUS_Q_WIDTH+1 downto 1); half_bc <= bc(MODULUS_Q_WIDTH+1 downto 1);

  with as(0) select next_pc <= half_ac when '0', half_bc when others;
  with as(0) select next_ps <= half_as when '0', half_bs when others;

  parallel_register: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then 
      pc <= (others => '0'); ps <= (others => '0');
    elsif ce_p = '1' then 
      pc <= next_pc; ps <= next_ps; 
    end if;
  end if;
  end process parallel_register;

  equal_zero <= '1' when count = zero else '0';

  p <= ps + pc;
  p_minus_m <= p + MINUS_M;
	with p_minus_m(MODULUS_Q_WIDTH) select z <= p(MODULUS_Q_WIDTH-1 downto 0) when '0', p_minus_m(MODULUS_Q_WIDTH-1 downto 0) when others;
	--z <= p(MODULUS_Q_WIDTH-1 downto 0);
  shift_register: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then 
      int_x <= x;
    elsif ce_p = '1' then
      --for i in 0 to MODULUS_Q_WIDTH-2 loop int_x(i) <= int_x(i+1); end loop;
      --int_x(MODULUS_Q_WIDTH-1) <= '0';
	  int_x <= '0' & int_x(MODULUS_Q_WIDTH-1 downto 1);
    end if;
  end if;
  end process shift_register;

  xi <= int_x(0);

  counter: process(clk)
  begin
  if clk'event and clk = '1' then
    if load = '1' then 
      count <= conv_std_logic_vector(MODULUS_Q_WIDTH-1, LOG_MODULUS_Q_WIDTH);
    elsif ce_p= '1' then 
      count <= count - 1;
    end if;
  end if;
  end process;

  control_unit: process(clk, reset, current_state)
  begin
  case current_state is
    when 0 to 1 => ce_p <= '0'; load <= '0'; done <= '1';
    when 2 => ce_p <= '0'; load <= '1'; done <= '0';
    when 3 => ce_p <= '1'; load <= '0'; done <= '0';
  end case;

  if reset = '1' then
    current_state <= 0;
  elsif clk'event and clk = '1' then
    case current_state is
      when 0 => if start = '0' then current_state <= 1; end if;
      when 1 => if start = '1' then current_state <= 2; end if;
      when 2 => current_state <= 3;
      when 3 => if equal_zero = '1' then current_state <= 0; end if;
    end case;
  end if;
  end process;

end rtl;