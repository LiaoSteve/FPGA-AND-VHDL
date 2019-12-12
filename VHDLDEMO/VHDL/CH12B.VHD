--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH12B : electronic code lock (test #B)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH12B is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --output port
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --output port
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)   --input  port
     );
end CH12B;
architecture CH12B_ARCH of CH12B is
     component KEYBOARD
     port
     (    CLK    : in  STD_LOGIC;                    --system clock
          SAMPLE : in  STD_LOGIC;                    --sample point
          SEQ    : in  STD_LOGIC_VECTOR(1 downto 0); --scanning sequence
          INP    : in  STD_LOGIC_VECTOR(3 downto 0); --keyboard input
          CODE   : out STD_LOGIC_VECTOR(3 downto 0); --keyboard output
          KIN    : out STD_LOGIC                     --keyboard strike
     );
     end component;
     component DISPLAY
     port
     (    CLK : in  STD_LOGIC;                      --system clock
          REG : in  STD_LOGIC_VECTOR (15 downto 0); --digit data
          SEG : out STD_LOGIC_VECTOR (6  downto 0); --segment output
          SEQ : out STD_LOGIC_VECTOR (1  downto 0); --segment output
          SAMPLE,BLINK : out STD_LOGIC              --sample and blink
     );
     end component;
     signal ACC  : STD_LOGIC_VECTOR (15 downto 0);
     signal REG  : STD_LOGIC_VECTOR (15 downto 0);
     signal SEG  : STD_LOGIC_VECTOR (6  downto 0);
     signal ENB  : STD_LOGIC_VECTOR (3  downto 0);
     signal SEQ  : STD_LOGIC_VECTOR (1  downto 0);
     signal CODE : STD_LOGIC_VECTOR (3  downto 0);
     signal FUN  : STD_LOGIC_VECTOR (6  downto 0);
     signal KIN,SAMPLE,UNLOCK,BLINK : STD_LOGIC;
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
     signal INP : STD_LOGIC_VECTOR (3  downto 0);
begin
U1:  KEYBOARD port map (CLK, SAMPLE, SEQ, INP, CODE, KIN);
U2:  DISPLAY  port map (CLK, ACC, SEG, SEQ, SAMPLE, BLINK);
     INP   <= not XC;
     XA    <= not ENB;
     XB(7) <= UNLOCK and BLINK;
     XB(6 downto 0) <= SEG;
     ENB <= "0001" when SEQ=0 else
            "0010" when SEQ=1 else
            "0100" when SEQ=2 else
            "1000" when SEQ=3 else
            "0000";
     FUN <= "0000010" when CODE=10 else
            "0000100" when CODE=11 else
            "0001000" when CODE=12 else
            "0010000" when CODE=13 else
            "0100000" when CODE=14 else
            "1000000" when CODE=15 else
            "0000001";
end block SYSTEM_CONNECT;
--
--*********************************************************
-- keyin process
--
KEYIN_PROCESS : block
     signal RST,EC,DIR : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then                                  --CLK reset
               ACC <= "0000000000000000";
          elsif CLK'event and CLK='1' then                 --CLK rising
               if EC='1' then                              --CLK enable
                    if DIR='1' then
                         ACC <= ACC(11 downto 0) & CODE;   --shift left
                    else
                         ACC <= "0000" & ACC(15 downto 4); --shift right
                    end if;
               end if;
          end if;
     end process;
     RST <= KIN and FUN(2);             --RESET
     EC  <= KIN and (FUN(0) or FUN(1)); --NUMBER or BACK
     DIR <= FUN(0);                     --NUMBER
end block KEYIN_PROCESS;
--
--*********************************************************
-- setting process
--
SETTING_PROCESS : block
     signal RST,EC : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then                    --data reset
               REG <= "0000000000000000";
          elsif CLK'event and CLK='1' then   --CLK rising
               if EC='1' then                --CLK enable
                    REG <= ACC;              --data latch
               end if;
          end if;
     end process;
     RST <= KIN and FUN(3);                  --RESET CODE
     EC  <= KIN and FUN(4) and UNLOCK;       --SET   CODE
end block SETTING_PROCESS;
--
--*********************************************************
-- compare process
--
COMPARE_PROCESS : block
     signal RST,EC,Q : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then                    --data reset
               Q <= '0';                     --data reset
          elsif CLK'event and CLK='1' then   --CLK rising
               if EC='1' then                --CLK enable
                    Q <= '1';                --RS Flip/Flop
               end if;
          end if;
     end process;
     RST <= KIN and FUN(5);                  --RESET LOCK
     EC  <= '1' when KIN='1' and FUN(6)='1' and REG=ACC else
            '0';
     UNLOCK <= Q;
end block COMPARE_PROCESS;
--
--*********************************************************
-- end of architechture
--
end CH12B_ARCH;

