--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- KEYBOARD : one-bit keyboard debouncing
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity KEYBOARD is
     port
     (    CLK    : in  STD_LOGIC;                    --system clock
          SAMPLE : in  STD_LOGIC;                    --sample point
          SEQ    : in  STD_LOGIC_VECTOR(1 downto 0); --scanning sequence
          INP    : in  STD_LOGIC_VECTOR(3 downto 0); --keyboard input
          CODE   : out STD_LOGIC_VECTOR(3 downto 0); --keyboard output
          KIN    : out STD_LOGIC                     --keyboard strike
     );
end KEYBOARD;

architecture KEYBOARD_ARCH of KEYBOARD is
     signal KBUF : STD_LOGIC_VECTOR (4 downto 0);
     signal PLS1,PLS2,PLS3 : STD_LOGIC;
     signal KEY,FLT        : STD_LOGIC;
begin
--
--*********************************************************
--
-- keyboard sequence control
--
KEYBOARD_SEQUENCE : block
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                 --CLK rising
               PLS3<=PLS2; PLS2<=PLS1; PLS1<=SAMPLE;    --delay
          end if;
     end process;
end block KEYBOARD_SEQUENCE;
--
--*********************************************************
--
-- keyboard decoding
--
KEYBOARD_DECODING : block
     signal D      : STD_LOGIC_VECTOR (2 downto 0);
     signal EC,RST : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then
               KBUF <= "00000";
          elsif CLK'event and CLK='1' then
               if EC='1' then
                    KBUF <= D & (not SEQ);
               end if;
          end if;
     end process;
     D(2 downto 0) <= "100" when INP="0001" else
                      "101" when INP="0010" else
                      "110" when INP="0100" else
                      "111" when INP="1000" else
                      "000";
     EC  <= PLS1 and D(2);
     RST <= PLS3 and not SEQ(1) and not SEQ(0);
end block KEYBOARD_DECODING;
--
--*********************************************************
--
-- keyboard latch
--
KEYBOARD_LATCH : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then        --CLK rising
               if EC='1' then                  --CLK enable
                    CODE <= KBUF(3 downto 0);  --latch code
                    KEY  <= KBUF(4);
               end if;
          end if;
     end process;
     EC <= PLS2 and not SEQ(1) and not SEQ(0);
end block KEYBOARD_LATCH;
--
--*********************************************************
--
-- keyboard debouncing
--
KEYBOARD_DEBOUNCING : block
     signal D0,D1,EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               if EC='1' then              --CLK enable
                    D1<=D0; D0<=KEY;       --delay
                    FLT <= ((D0 and D1) or FLT) and (D0 or D1); --RS-F/F
               end if;
          end if;
     end process;
     EC <= PLS3 and not SEQ(1) and not SEQ(0);
end block KEYBOARD_DEBOUNCING;
--
--*********************************************************
--
-- differential signal
--
KEYBOARD_DIFF : block
     signal D0,D1 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               D1<=D0; D0<=FLT;            --delay
          end if;
     end process;
     KIN <= D0 and not D1;                 --differential
end block KEYBOARD_DIFF;
--
--*********************************************************
-- end of architechture
--
end KEYBOARD_ARCH;

