--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- DISPLAY : 4-digit LED display control
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity DISPLAY is
     port
     (    CLK : in  STD_LOGIC;                      --system clock
          REG : in  STD_LOGIC_VECTOR (15 downto 0); --digit data
          SEG : out STD_LOGIC_VECTOR (6  downto 0); --segment output
          SEQ : out STD_LOGIC_VECTOR (1  downto 0); --segment output
          SAMPLE,BLINK : out STD_LOGIC              --sample and blink
     );
end DISPLAY;

architecture DISPLAY_ARCH of DISPLAY is
     signal SCAN : STD_LOGIC_VECTOR (1 downto 0);
     signal DB   : STD_LOGIC_VECTOR (3 downto 0);
begin
--
--*********************************************************
-- 22-bit free counter
--
FREE_COUNTER : block
     signal Q : STD_LOGIC_VECTOR (21 downto 0);
     signal D : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               D <= Q(15);
               Q <= Q+1;
          end if;
     end process;
     BLINK  <= Q(21);
     SAMPLE <= not Q(15) and D;
     SCAN   <= Q(17 downto 16);
     SEQ    <= SCAN;
end block FREE_COUNTER;
--
--*********************************************************
-- scanning sequence and bus multiplexer
--
MULTIPLEXER : block
begin
     DB <= REG(15 downto 12) when SCAN=3 else "ZZZZ";
     DB <= REG(11 downto  8) when SCAN=2 else "ZZZZ";
     DB <= REG(7  downto  4) when SCAN=1 else "ZZZZ";
     DB <= REG(3  downto  0) when SCAN=0 else "ZZZZ";
end block MULTIPLEXER;
--
--*********************************************************
-- seven-segment LED transformation
--
SEVEN_SEGMENT : block
begin
           --GFEDCBA
     SEG <= "0111111" when DB=0  else
            "0000110" when DB=1  else
            "1011011" when DB=2  else
            "1001111" when DB=3  else
            "1100110" when DB=4  else
            "1101101" when DB=5  else
            "1111101" when DB=6  else
            "0000111" when DB=7  else
            "1111111" when DB=8  else
            "1101111" when DB=9  else
            "1110111" when DB=10 else
            "1111100" when DB=11 else
            "0111001" when DB=12 else
            "1011110" when DB=13 else
            "1111001" when DB=14 else
            "1110001" when DB=15 else
            "0000000";
end block SEVEN_SEGMENT;
--
--*********************************************************
-- end of architechture
--
end DISPLAY_ARCH;


