--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH12A : electronic code lock (test #A)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH12A is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --output port
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --output port
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)   --input  port
     );
end CH12A;
architecture CH12A_ARCH of CH12A is
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
     signal SEG  : STD_LOGIC_VECTOR (6  downto 0);
     signal ENB  : STD_LOGIC_VECTOR (3  downto 0);
     signal SEQ  : STD_LOGIC_VECTOR (1  downto 0);
     signal CODE : STD_LOGIC_VECTOR (3  downto 0);
     signal KIN,SAMPLE,BLINK : STD_LOGIC;
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
     XB(7) <= BLINK;
     XB(6 downto 0) <= SEG;
     ENB <= "0001" when SEQ=0 else
            "0010" when SEQ=1 else
            "0100" when SEQ=2 else
            "1000" when SEQ=3 else
            "0000";
end block SYSTEM_CONNECT;
--
--*********************************************************
-- accumulator process
--
ACCUMULATOR : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                    --CLK rising
               if EC='1' then                              --CLK enable
                    ACC <= ACC(11 downto 0) & CODE;        --shift left
               end if;
          end if;
     end process;
     EC  <= KIN;
end block ACCUMULATOR;
--
--*********************************************************
-- end of architechture
--
end CH12A_ARCH;

