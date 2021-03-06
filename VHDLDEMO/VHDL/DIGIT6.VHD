--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- DIGIT6 : one digit control with divide-by-6
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity DIGIT6 is
     port
     (    CLK : in    STD_LOGIC;                     --system clock
          DB  : out   STD_LOGIC_VECTOR (3 downto 0); --digit bus
          ENB : in    STD_LOGIC;                     --output enable
          CLR : in    STD_LOGIC;                     --clear signal
          EC  : in    STD_LOGIC;                     --carry in
          CY  : out   STD_LOGIC                      --carry out
     );
end DIGIT6;

architecture DIGIT6_ARCH of DIGIT6 is
     signal Q : STD_LOGIC_VECTOR (3 downto 0);
     signal RST,DLY : STD_LOGIC;
begin
--
--*********************************************************
--
-- one digit control with divide-by-10
--
     process (CLK,RST)
     begin
          if RST='1' then                   --reset control
               Q <= "0000";                 --reset to 0
          elsif CLK'event and CLK='1' then  --clock rising
               DLY <= Q(2);                 --delay
               if EC='1' then               --clock enable
                    Q <= Q+1;               --counter+1
               end if;
          end if;
     end process;
     CY  <= not Q(2) and DLY;               --carry output
     RST <= '1' when Q=6 or CLR='1' else    --reset when Q=6
            '0';
     DB  <= Q when ENB='1' else             --output control
            "ZZZZ";
--
--*********************************************************
-- end of architechture
--
end DIGIT6_ARCH;

