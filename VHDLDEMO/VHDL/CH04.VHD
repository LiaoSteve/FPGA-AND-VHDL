--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH04 : practise VECTOR operators
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH04 is
     port
     (    XB : out STD_LOGIC_VECTOR (7 downto 0);
          XC : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH04;

architecture CH04_ARCH of CH04 is
begin
--
--*********************************************************
-- 3-to-8 address decoding
--
     XB <= "11111110" when XC="1000" else
           "11111101" when XC="1001" else
           "11111011" when XC="1010" else
           "11110111" when XC="1011" else
           "11101111" when XC="1100" else
           "11011111" when XC="1101" else
           "10111111" when XC="1110" else
           "01111111" when XC="1111" else
           "11111111";
--
--*********************************************************
-- end of architechture
--
end CH04_ARCH;

