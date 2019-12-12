--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH03 : practise BIT operators
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH03 is
     port
     (    XB : out STD_LOGIC_VECTOR (7 downto 0);
          XC : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH03;

architecture CH03_ARCH of CH03 is
begin
--
--*********************************************************
-- 3-to-8 address decoding
--
     XB(0) <= not(XC(3) and not XC(2) and not XC(1) and not XC(0)); --1000
     XB(1) <= not(XC(3) and not XC(2) and not XC(1) and     XC(0)); --1001
     XB(2) <= not(XC(3) and not XC(2) and     XC(1) and not XC(0)); --1010
     XB(3) <= not(XC(3) and not XC(2) and     XC(1) and     XC(0)); --1011
     XB(4) <= not(XC(3) and     XC(2) and not XC(1) and not XC(0)); --1100
     XB(5) <= not(XC(3) and     XC(2) and not XC(1) and     XC(0)); --1101
     XB(6) <= not(XC(3) and     XC(2) and     XC(1) and not XC(0)); --1110
     XB(7) <= not(XC(3) and     XC(2) and     XC(1) and     XC(0)); --1111
--
--*********************************************************
-- end of architechture
--
end CH03_ARCH;

