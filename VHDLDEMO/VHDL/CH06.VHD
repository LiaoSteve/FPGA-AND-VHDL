--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH06 : practise FREQUENCY-DIVIDER (FREE-COUNTER)
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH06 is
     port
     (    CLK : in  STD_LOGIC;
          XA  : out STD_LOGIC_VECTOR (3 downto 0);
          XB  : out STD_LOGIC_VECTOR (7 downto 0)
     );
end CH06;

architecture CH06_ARCH of CH06 is
     signal Q   : STD_LOGIC_VECTOR (23 downto 0);
     signal CNT : STD_LOGIC_VECTOR (3  downto 0);
begin
--
--*********************************************************
--
-- 24-BIT free counter
--
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               Q <= Q + 1;
          end if;
     end process;
     CNT <= Q(23 downto 20);
--
--*********************************************************
-- Look-Up-Table (LUT) control
--
     XA <= not CNT;
     XB <= "11111110" when CNT="0000" else
           "11111100" when CNT="0001" else
           "11111000" when CNT="0010" else
           "11110000" when CNT="0011" else
           "11100000" when CNT="0100" else
           "11000000" when CNT="0101" else
           "10000000" when CNT="0110" else
           "00000000" when CNT="0111" else
           "00000001" when CNT="1000" else
           "00000011" when CNT="1001" else
           "00000111" when CNT="1010" else
           "00001111" when CNT="1011" else
           "00011111" when CNT="1100" else
           "00111111" when CNT="1101" else
           "01111111" when CNT="1110" else
           "11111111";
--
--*********************************************************
-- end of architechture
--
end CH06_ARCH;

