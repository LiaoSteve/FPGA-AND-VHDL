--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH05 : check 2-BIT MATH operator
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH05 is
     port
     (    XA : out UNSIGNED (3 downto 0);
          XB : out UNSIGNED (7 downto 0);
          XC : in  UNSIGNED (3 downto 0)
     );
end CH05;

architecture CH05_ARCH of CH05 is
     signal A,B : UNSIGNED (1 downto 0);  --internal signals
begin
--
--*********************************************************
-- 2-BIT MATH operator
--
     A <= XC(3 downto 2);
     B <= XC(1 downto 0);
     XB(1 downto 0) <= A + B;             --test (A+B)
     XB(3 downto 2) <= A - B;             --test (A-B)
     XB(7 downto 4) <= A * B;             --test (A*B)
     XA(0) <= '1' when A>=B else          --test (A>=B)
              '0';
     XA(1) <= '1' when A>B  else          --test (A>B)
              '0';
     XA(2) <= '1' when A<B  else          --test (A<B)
              '0';
     XA(3) <= '1' when A=B  else          --test (A=B)
              '0';
--
--*********************************************************
-- end of architechture
--
end CH05_ARCH;




