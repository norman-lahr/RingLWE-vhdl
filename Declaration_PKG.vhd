----------------------------------------------------------
--	Package for often reused declarations and functions --
----------------------------------------------------------

--------------------------------
-- Text Editor Settings:      --
-- Font: "Monospace", Size: 8 --
-- Tab width: 4               --
--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;		-- Signal Types
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;

package DECLARATION_PKG is
	-------------
	-- General --
	-------------
	-- Integer array
	type INTEGER_ARRAY is array(NATURAL range <>) of INTEGER;
	
	-- Two-dimensional integer array
	type INTEGER_2DARRAY is array(NATURAL range <>, NATURAL range <>) of INTEGER;
	
	-- Character array
	type CHARACTER_ARRAY is array(NATURAL range <>) of CHARACTER;
	
	-- Calculates Logarithmus Dualis, rounded down
	function log2(val : INTEGER) return INTEGER;
	
	-- Calculates the inverted element of a in m;
	function invMod(a, m: INTEGER) return INTEGER;
	
	----------------------
	-- System Parameter --
	----------------------
	-- Prime modulus q
	constant MODULUS_Q: NATURAL := 3329;--17;--2053;
	
	-- Bit width of modulus q
	constant MODULUS_Q_WIDTH: NATURAL := log2(MODULUS_Q)+1;--5;--12;
	
	-- Length of MODULUS_Q_WIDTH
	constant LOG_MODULUS_Q_WIDTH: NATURAL := log2(MODULUS_Q_WIDTH)+1;--3;--4;
	
	-- Modulus as STD_LOGIC_VECTOR
	constant Q: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0) := conv_std_logic_vector(MODULUS_Q, MODULUS_Q_WIDTH);
	
	-- Adjusted Integer, with n-bit width
	subtype N_BIT_INT is STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
	
	-- Array of adjusted integers
	type N_BIT_INT_ARRAY is array(NATURAL range <>) of N_BIT_INT;
	
	-- Message length in bit
	constant MSG_LEN: NATURAL := 128;--4;--128;
	
	constant ENC_VAL: N_BIT_INT := conv_std_logic_vector(MODULUS_Q/2, MODULUS_Q_WIDTH);

	-----------------
	-- Polynomials --
	-----------------
	-- Degree of polynomial modulus f(x)
	constant DEGREE_F: NATURAL := 128;--4;--128;
	
	-- Type for polynomial modulus f(x)
	type MOD_POLYNOMIAL is array(DEGREE_F downto 0) of STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
	
	-- Type for general polynomial
	type POLYNOMIAL is array(DEGREE_F-1 downto 0) of STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
	
	-- Multiplication with FFT needs polynomials with the doubled degree of the original polynomial
	type POLYNOMIAL_2K is array((2*DEGREE_F) -1 downto 0) of N_BIT_INT;
	
	-- Zero, initial coefficient
	constant ZERO_COEF: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0) := (others => '0');
	
	-- Zero, initial polynomial
	constant ZERO_POLY: POLYNOMIAL := (others => ZERO_COEF);

	-------------
	-- Decoder --
	-------------
	constant THRESHOLD	:N_BIT_INT := conv_std_logic_vector(MODULUS_Q/4, MODULUS_Q_WIDTH);
	constant NEG_THRESHOLD	:N_BIT_INT := conv_std_logic_vector((-MODULUS_Q/4) mod MODULUS_Q, MODULUS_Q_WIDTH);
	---------------------------
	-- Montgomery Multiplier --
	---------------------------
	-- (-Q^-1) mod 2^MODULUS_Q_WIDTH, Calc the inverse and then note the negative.
	constant INV_MODULUS_Q: NATURAL := (- invMod(MODULUS_Q, 2**MODULUS_Q_WIDTH)) mod 2**MODULUS_Q_WIDTH;--15;--2867;
	
	-- R2 = R^2 mod Q, R = (2^MODULUS_Q_WIDTH)
	constant R2: NATURAL := ((2**MODULUS_Q_WIDTH)**2) mod MODULUS_Q;--4;--100;
	
	-- Modulus for Montgomery Multiplier
	constant M: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0) := conv_std_logic_vector(MODULUS_Q, MODULUS_Q_WIDTH);
	
	-- negative and inverted Modulus for Montgomery Multiplier
	constant INV_M: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0) := conv_std_logic_vector(INV_MODULUS_Q, MODULUS_Q_WIDTH);
	
	-- R^2 mod Q
	constant R2_PRE: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0) := conv_std_logic_vector(R2, MODULUS_Q_WIDTH);
	
	-- Constant zero vector for Montgomery Multiplier
	constant ZERO: STD_LOGIC_VECTOR(LOG_MODULUS_Q_WIDTH-1 downto 0) := (others => '0');
	
	-- -M mod Q
	constant MINUS_M: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH downto 0) := conv_std_logic_vector(2**MODULUS_Q_WIDTH- MODULUS_Q, MODULUS_Q_WIDTH+1);
		
	-----------------------------------------
	-- Fast Fourier Transformation (FFT) / --
	-- Number Theory Transformation (NTT)  --
	-----------------------------------------
	-- Root of unity
	-- W^n = -1 mod Q, with n is the degree of the modulus polynomial f(x)
	-- W^2n = 1 mod Q
	constant W		:INTEGER := 17;--2;
	constant INV_W	:INTEGER := invMod(W, MODULUS_Q);
	
	-- Calculates the feedback addresses.
	-- They are determined by the parallel FFT structure
	-- e.g. in "Introduction to Algorithms", 3rd edition, 
	-- by Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest
	-- and Clifford Stein. Figure 30.5.
	--
	-- Based on the iterative radix-2 FFT algorithm of Cooley and Tukey.
	-- The function builds an array of output indices, which
	-- can iteratively be assigned to the inputs of the
	-- multiplexers in front of every butterfly-module.
	--
	-- Example for the first butterfly-module of an FFT-8
	--
	--                    +-----------+
	--         A(0)--|\   |           |
	-- Out(0) --> 0--| |--| Butterfly |--Out(0)
	-- Out(0) --> 1--|/   | Module 0  |
	--                    |           |
	--         A(4)--|\   |           |
	-- Out(2) --> 2--| |--|           |--Out(1)
	-- Out(4) --> 3--|/   |           |
	--                    +-----------+
	--                          .
	--                          .
	--                          .
	--
	function getAddr(deg: INTEGER) return INTEGER_ARRAY;
	
	-- Calculates the array of roots of unity. 
	-- The entries are assigned iteratively to
	-- the inputs of the W-multiplexers.
	function getWArray(w, deg: INTEGER; inverse :BOOLEAN) return N_BIT_INT_ARRAY;
	
	-- Calculates the reversed bit order
	function rev(k, len: INTEGER) return INTEGER;
	
	-- FFT for Testbench
	function int_fft(A: POLYNOMIAL_2k; inverse: BOOLEAN) return POLYNOMIAL_2K;
	
	----------------------
	-- Gaussian Sampler --
	----------------------
	constant GAUSSIAN_RESOLUTION	:INTEGER := 1023; -- The 10-bit LFSR count only mod 1023 -> See Xilinx Doc
	constant CONST_S	:REAL := 6.67;
	constant LFSR_LENGTH	:INTEGER := 10;
	function feedbackArray(val : INTEGER) return INTEGER_ARRAY;
	
	function gaussianArray(resolution: INTEGER; s: REAL) return INTEGER_ARRAY;
	function g(x: INTEGER; s: REAL) return REAL;
	function getConentLength(resolution :INTEGER; s: REAL) return INTEGER;
	function getContent(resolution :INTEGER; s: REAL) return N_BIT_INT_ARRAY;
	function getLimits(resolution :INTEGER; s: REAL) return INTEGER_ARRAY;
	
	-- There is no function like the rand() function of C.
	-- For every LFSR in the system, an own seed will be
	-- calculated.
	-- Every polynomial random generator needs DEGREE_F LFSRs.
	-- There are maximal 3 Gaussian sampler in LWE_Encrypt and 1
	-- uniform sampler in LWE_KeyGen
	function genRandomArray(seed, seed_range, array_size :INTEGER; no_zero :BOOLEAN) return INTEGER_ARRAY;
	
	constant NUMBER_OF_GAUSS				:INTEGER := 3;
	constant GAUSS_RANDOM_SEED_ARRAY_SIZE	:INTEGER := NUMBER_OF_GAUSS * DEGREE_F;
	constant GAUSS_RANDOM_SEED_RANGE		:INTEGER := 2**LFSR_LENGTH -2;			-- LFSR must not be 0 or 2**LFSR_LENGTH-1, because of XNOR function
	constant GAUSS_RANDOM_SEED_ARRAY		:INTEGER_ARRAY(GAUSS_RANDOM_SEED_ARRAY_SIZE-1 downto 0) := genRandomArray(0, GAUSS_RANDOM_SEED_RANGE, GAUSS_RANDOM_SEED_ARRAY_SIZE, false);
	
	constant NUMBER_OF_UNI				:INTEGER := 1;
	constant UNI_RANDOM_SEED_ARRAY_SIZE	:INTEGER := DEGREE_F;
	constant UNI_RANDOM_SEED_RANGE		:INTEGER := 2**MODULUS_Q_WIDTH -2;			-- LFSR must not be 0 or 2**MODULUS_Q_WIDTH-1, because of XNOR function
	constant UNI_RANDOM_SEED_ARRAY		:INTEGER_ARRAY(UNI_RANDOM_SEED_ARRAY_SIZE-1 downto 0) := genRandomArray(1, UNI_RANDOM_SEED_RANGE, UNI_RANDOM_SEED_ARRAY_SIZE, true);
	
	
	
end DECLARATION_PKG;

package body DECLARATION_PKG is
 
	function log2(val : INTEGER)
		return INTEGER is

		variable return_val : INTEGER;

		begin
			if (val = 1) then return 0;
			elsif (val >= 2 and val <= 3) 			then return 1;
			elsif (val >= 4 and val <= 7) 			then return 2;
			elsif (val >= 8 and val <= 15) 			then return 3;
			elsif (val >= 16 and val <= 31) 		then return 4;
			elsif (val >= 32 and val <= 63) 		then return 5;
			elsif (val >= 64 and val <= 127)		then return 6;
			elsif (val >= 128 and val <= 255)		then return 7;
			elsif (val >= 256 and val <= 511) 		then return 8;
			elsif (val >= 512 and val <= 1023) 		then return 9;
			elsif (val >= 1024 and val <= 2047) 	then return 10;
			elsif (val >= 2048 and val <= 4095) 	then return 11;
			elsif (val >= 4096 and val <= 8191) 	then return 12;
			elsif (val >= 8192 and val <= 16383)	then return 13;
			else return 0;
			end if;
		end;
	
	function getAddr(deg: INTEGER)
		return INTEGER_ARRAY is

		variable res	:INTEGER_ARRAY((log2(2*deg)-1)*2*deg -1 downto 0);
		variable last_x	:INTEGER_ARRAY(2*deg -1 downto 0);
		variable m		:INTEGER;
		variable x		:INTEGER;
		variable a		:INTEGER;
		variable k		:INTEGER;

		constant n		:INTEGER := 2*deg;
		constant log2n	:INTEGER := log2(n);

		begin
		
		for s in 1 TO log2(n) loop
			x := 0;
			m := 2**s;
			k := 0;
			while (k < n)  loop
				for j in 0 TO m/2-1 loop
					a := k+j;
					if (s > 1) then
						res(s-2 + (log2n-1) * x) := last_x(a);
					end if;
					last_x(a) := x; -- Save x for the next round
					x := x+1;
					a := a+m/2;

					if (s > 1) then
						res(s-2 + (log2n-1) * x) := last_x(a);
					end if;
					last_x(a) := x;	-- Save x for the next round
					x := x+1;
					
				end loop;
				k := k+m;
			end loop;
		 end loop;
		 return res;
	end;
	
	function getWArray(w, deg: INTEGER; inverse :BOOLEAN)
		return N_BIT_INT_ARRAY is
		
		constant LOG2_N		:INTEGER := log2(2*deg);
		constant n			:INTEGER := 2*deg;
		
		variable return_w	:N_BIT_INT_ARRAY(LOG2_N * deg - 1 downto 0);
		variable w_Array	:INTEGER_ARRAY(deg - 1 downto 0);
		variable k			:INTEGER;
		variable i, x, y	:INTEGER;
		variable m			:INTEGER;
		-- Optimization factor for inverse FFT
		variable inv_fac	:INTEGER;
		
		begin
		
			w_Array(0) := 1;
			for i in 1 to n/2-1 loop
				w_Array(i) := w_Array(i-1) * w mod MODULUS_Q;
			end loop;
			
			for s in 1 to LOG2_N loop	
				m := 2**s;
				y := 0;
				k := 0;
				while (k < n)  loop
					x := 0;
					for j in 0 to m/2 - 1 loop
						-- Modification for inverse FFT
						if (inverse = true and s = LOG2_N) then
							inv_fac := (2 * invMod(n, MODULUS_Q)) mod MODULUS_Q;
						else
							inv_fac := 1;
						end if;
						return_w((s-1) + LOG2_N * y) := conv_std_logic_vector((inv_fac * w_Array(x * 2**(LOG2_N-s))) mod MODULUS_Q, MODULUS_Q_WIDTH);
						x := x + 1;
						y := y + 1;
					end loop;
					k := k+m;
				end loop;
			end loop;
			
			return return_w;
	end;
	
	function rev(k, len: INTEGER)
		return INTEGER is
		
		variable int_k	:STD_LOGIC_VECTOR(len-1 downto 0);
		variable rev_k	:STD_LOGIC_VECTOR(int_k'reverse_range);
		
		begin
			int_k := conv_std_logic_vector(k,len);
			for i in int_k'range loop
				rev_k(i) := int_k(i);
			end loop;

			return CONV_INTEGER(rev_k);
	end;
	
	
	function invMod(a, m: INTEGER) 
		return INTEGER is
		
		variable q,r, x, y, xx, yy, sign, int_a, int_m	:INTEGER;
		variable xs, ys									:INTEGER_ARRAY(1 downto 0);
		
		begin
	
		xs(0) := 1; xs(1) := 0;
		ys(0) := 0; ys(1) := 1;
		sign := 1;
		int_a := a;
		int_m := m;
		
		while(int_m /= 0) loop
			r := int_a mod int_m;
			q := int_a / int_m;
			int_a := int_m;
			int_m := r;
			xx := xs(1);
			yy := ys(1);
			xs(1) := q*xs(1) + xs(0);
			ys(1) := q*ys(1) + ys(0);
			xs(0) := xx;
			ys(0) := yy;
			sign := -sign;
		end loop;
		
		x := sign*xs(0);
		y := -sign*ys(0);
		
		assert(int_a = 1) report "a and m are not coprime!" severity error;
		if(x < 0) then
			x := x + m;
		end if;
		return x;
	end;

	function int_fft(A: POLYNOMIAL_2k; inverse: BOOLEAN) 
		return POLYNOMIAL_2K is 
		
		constant deg		:INTEGER := A'length/2;
		constant LOG2_N		:INTEGER := log2(2*deg);
		constant n			:INTEGER := 2*deg;
		
		variable revA		:POLYNOMIAL_2K;
		variable w_Array	:INTEGER_ARRAY(deg - 1 downto 0);
		variable k			:INTEGER;
		variable x, t, u	:INTEGER;
		variable m			:INTEGER;
		variable int_w		:INTEGER;
		
		begin
		
			if (inverse = true) then
				int_w := INV_W;
			else
				int_w := W;
			end if;
			w_Array(0) := 1;
			for i in 1 to n/2-1 loop
				w_Array(i) := (w_Array(i-1) * int_w) mod MODULUS_Q;
			end loop;
			
			for i in 0 to A'length-1 loop
				revA(rev(i, LOG2_N)) := A(i);
			end loop;
			
			for s in 1 to LOG2_N loop	
				m := 2**s;
				k := 0;
				while (k < n)  loop
					x := 0;
					for j in 0 to m/2 - 1 loop
						t := (w_Array(x * 2**(LOG2_N-s)) * conv_integer(revA(k + j +m/2))) mod MODULUS_Q;
						u := conv_integer(revA(k + j));
						
						revA(k + j) := conv_std_logic_vector((u + t) mod MODULUS_Q, MODULUS_Q_WIDTH);
						revA(k + j + m/2) := conv_std_logic_vector((u - t) mod MODULUS_Q, MODULUS_Q_WIDTH);
						
						x := x + 1;
					end loop;
					k := k+m;
				end loop;
			end loop;
			
			if (inverse = true) then
				for i in 0 to A'length-1 loop
					revA(i) := conv_std_logic_vector((conv_integer(revA(i)) * invMod(n,MODULUS_Q)) mod MODULUS_Q, MODULUS_Q_WIDTH); --todo
				end loop;
			end if;
			
			return revA;
	end;
	
	function gaussianArray(resolution: INTEGER; s: REAL) 
		return INTEGER_ARRAY is
			constant GAUSS_ARRAY_SIZE:	INTEGER := integer(2.0*ceil(2.0*s)+1.0);
			variable res	:INTEGER_ARRAY(GAUSS_ARRAY_SIZE-1 downto 0);
			variable diff, sum, j, k, addr	:INTEGER := 0;
			variable hit, count, count1, count2	:BOOLEAN;
		begin
		for i in 0 to GAUSS_ARRAY_SIZE-1 loop
			res(i) := integer(round(g(i-GAUSS_ARRAY_SIZE/2, s) * real(resolution)));
			sum := sum + res(i);
		end loop;
		
		-- Correct the array, if there are too few or too much elements
		diff := sum - resolution;
		hit := false;
		j := 0;
		k := GAUSS_ARRAY_SIZE-1;
		
		if (diff /= 0) then
			if (diff > 0) then	-- Cut the outer regions (low probability)
				while (diff /= 0) loop
					hit := false;
					if (diff mod 2 = 0) then	-- Cut from the front
						while (hit = false) loop
							if(res(j) > 0) then
								res(j) := res(j) -1;
								diff := diff -1;
								hit := true;
							end if;
							j := j +1;
						end loop;
					else						-- Cut from the back
						while (hit = false) loop
							if(res(k) > 0) then
								res(k) := res(k) -1;
								diff := diff -1;
								hit := true;
							end if;
							k:= k -1;
						end loop;
					end if;
				end loop;
			else				-- Fill up from the middle (high probability)
				j := 0;
				count := abs(diff) mod 2 /= 0;
				
				while (diff /= 0) loop
					if (diff mod 2 = 0) then
						addr := GAUSS_ARRAY_SIZE/2 - (j mod (GAUSS_ARRAY_SIZE/2));
						if(res(addr) /= 0) then
							if(count1 = true) then
								j := j +1;
							end if;
							res(addr) := res(addr) +1;
							diff := diff +1;
						end if;
						if (count1 = false and count2 = false) then
							count1 := true;	-- Enable first part to increase j
						end if;
					else
						addr := GAUSS_ARRAY_SIZE/2 + (j mod (GAUSS_ARRAY_SIZE/2));
						if (res(addr) /= 0) then
							if (count = false and count2 = true) then
								j := j +1;
							end if;
							res(addr) := res(addr) +1;
							diff := diff +1;
							if (count = true and count2 = true) then
								j := j +1;
							end if;
						end if;
						if(count1 = false and count2 = false) then
							j := j +1;
							count2 := true;
						end if;
					end if;
				end loop;
			end if;
		end if;
		
		return res;
	end;
	
	
	function g(x: INTEGER; s: REAL) 
		return REAL is
			constant PI: 	REAL := 3.14159265;
			variable res:	REAL;
			
		begin
		return (1.0/s) * exp((-PI * real(x*x))/(s*s));
	end;
	
	function getConentLength(resolution :INTEGER; s: REAL)
		return INTEGER is
		constant GAUSS_ARRAY_SIZE	:INTEGER := integer(2.0*ceil(2.0*s)+1.0);
		variable tmpGaussianArray	:INTEGER_ARRAY(GAUSS_ARRAY_SIZE-1 downto 0);
		variable res	:INTEGER;
		
		begin
		
		res := 0;
		tmpGaussianArray := gaussianArray(resolution, s);
		
		for i in 0 to GAUSS_ARRAY_SIZE-1 loop		-- Count how many elements are not equal zero
			if(tmpGaussianArray(i) /= 0) then
				res := res +1;
			end if;
		end loop;
		
		return res;
	end;

	function getContent(resolution :INTEGER; s: REAL)
		return N_BIT_INT_ARRAY is
		
		constant GAUSS_ARRAY_SIZE	:INTEGER := integer(2.0*ceil(2.0*s)+1.0);
		variable tmpGaussianArray	:INTEGER_ARRAY(GAUSS_ARRAY_SIZE-1 downto 0);
		constant resLength	:INTEGER := getConentLength(resolution, s);
		variable res	:N_BIT_INT_ARRAY(resLength-1 downto 0);
		variable j	:INTEGER;
		
		begin
		
		j := 0;
		tmpGaussianArray := gaussianArray(resolution, s);
		
		for i in 0 to GAUSS_ARRAY_SIZE-1 loop		-- Count how many elements are not equal zero
			if(tmpGaussianArray(i) /= 0) then
				res(j) := conv_std_logic_vector((i-GAUSS_ARRAY_SIZE/2) mod MODULUS_Q, MODULUS_Q_WIDTH);
				j := j +1;
			end if;
		end loop;
		
		return res;
	end;
	
	function getLimits(resolution :INTEGER; s: REAL)
		return INTEGER_ARRAY is
		
		constant GAUSS_ARRAY_SIZE	:INTEGER := integer(2.0*ceil(2.0*s)+1.0);
		variable tmpGaussianArray	:INTEGER_ARRAY(GAUSS_ARRAY_SIZE-1 downto 0);
		constant resLength	:INTEGER := 2*getConentLength(resolution, s);	-- Every content element has two limits
		variable res	:INTEGER_ARRAY(resLength-1 downto 0);
		variable j, limit	:INTEGER;
		
		begin
		j := 0;
		limit := 0;
		tmpGaussianArray := gaussianArray(resolution, s);
		
		for i in 0 to GAUSS_ARRAY_SIZE-1 loop		-- Count how many elements are not equal zero
			if(tmpGaussianArray(i) /= 0) then
				
				res(2*j) := limit;
				limit := limit + tmpGaussianArray(i);
				res(2*j+1) := limit -1;
				j := j +1;
			end if;
		end loop;
		
		return res;
	end;
	
	function feedbackArray(val : INTEGER)
		return INTEGER_ARRAY is

		variable return_val : INTEGER_ARRAY(3 downto 0);

		begin
			case val is
			
				when 3	=>	return_val := (-1,-1,2,1);
				when 4	=>	return_val := (-1,-1,3,2);
				when 5	=>	return_val := (-1,-1,4,2);
				when 6	=>	return_val := (-1,-1,5,4);
				when 7	=>	return_val := (-1,-1,6,5);
				when 8	=>	return_val := (7,5,4,3);
				when 9	=>	return_val := (-1,-1,8,4);
				when 10	=>	return_val := (-1,-1,9,6);
				when 11	=>	return_val := (-1,-1,10,8);
				when 12	=>	return_val := (11,5,3,0);
				when 13	=>	return_val := (12,3,2,0);
				when 14	=>	return_val := (13,4,2,0);

				when others 		=> return_val := (-1,-1,-1,-1);
				
			end case;
			
			return return_val;
		end;
		
	function genRandomArray(seed, seed_range, array_size :INTEGER; no_zero :BOOLEAN)
		return INTEGER_ARRAY is
					
		variable res			:INTEGER_ARRAY(array_size-1 downto 0);
		variable rand			:REAL;
		variable seed1, seed2	:POSITIVE;
		variable temp			:INTEGER;
		
		begin      
			for i in 0 to array_size-1 loop
				loop
					uniform(seed1, seed2, rand);
					temp := INTEGER(trunc(rand * REAL(seed_range)));
					
					exit when (not(no_zero and temp = 0));
				end loop;
				
				res(i) := temp;
			end loop;	
			
			return res;
				
	end;
	
end DECLARATION_PKG;
