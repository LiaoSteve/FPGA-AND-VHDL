--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--This package is a version of the Synopsys package and has been 
-- optimized for use with the Express compiler.
--library SYNOPSYS;
--use SYNOPSYS.attributes.all;

--
--*********************************************************
-- MONITOR : system monitor with LED and keyboard
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity MONITOR is
     port
     (    CLK : in    STD_LOGIC;                     --system clock
          DB  : inout STD_LOGIC_VECTOR (7 downto 0); --data bus
          A   : out   STD_LOGIC_VECTOR (3 downto 0); --address bus
          RD  : out   STD_LOGIC;                     --read  control
          SWR : out   STD_LOGIC;                     --write control
          XA  : out   STD_LOGIC_VECTOR (3 downto 0); --LED scanning
          XB  : out   STD_LOGIC_VECTOR (7 downto 0); --LED segment
          XC  : in    STD_LOGIC_VECTOR (3 downto 0); --keyboard input
          FREQ: out   STD_LOGIC                      --test frequency
     );
end MONITOR;

architecture MONITOR_ARCH of MONITOR is
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
     signal REG  : STD_LOGIC_VECTOR (12 downto 0);
     signal CODE : STD_LOGIC_VECTOR (3  downto 0);
     signal SEQ  : STD_LOGIC_VECTOR (1  downto 0);
     signal SEG  : STD_LOGIC_VECTOR (6  downto 0);
     signal KIN,SAMPLE,BLINK : STD_LOGIC;
begin
--
--*********************************************************
-- system connection for LED & keyboard interface
--
SYSTEM_CONNECT : block
     signal INP  : STD_LOGIC_VECTOR (3 downto 0);
     signal ENB  : STD_LOGIC_VECTOR (3  downto 0);
begin
U1:  KEYBOARD port map (CLK, SAMPLE, SEQ, INP, CODE, KIN);
     DB  <= REG(7 downto 0) when REG(12)='1' else
           "ZZZZZZZZ";
     INP <= not XC;
     XA  <= not ENB;
     XB(7)          <= (SEQ(1) and     SEQ(0) and not REG(12) and BLINK) or
                       (SEQ(1) and not SEQ(0));
     XB(6 downto 0) <= SEG when SEQ(1 downto 0)/=3 else "0000000";
     ENB <= "0001" when SEQ=0 else
            "0010" when SEQ=1 else
            "0100" when SEQ=2 else
            "1000" when SEQ=3 else
            "0000";
     RD  <= REG(12);
     SWR <= REG(12) and KIN and
            not CODE(3) and CODE(2) and not CODE(1) and not CODE(0);
     A  <= REG(11 downto 8);
end block SYSTEM_CONNECT;
--
--*********************************************************
-- 22-bit free counter
--
FREE_COUNTER : block
     signal Q : STD_LOGIC_VECTOR (21 downto 0);
     signal DLY1,DLY2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               DLY1 <= Q(15);
               DLY2 <= Q(13);
               Q <= Q+1;
          end if;
     end process;
     BLINK  <= Q(21);
     SAMPLE <= not Q(15) and DLY1;
     FREQ   <= not Q(13) and DLY2;
     SEQ    <= Q(17 downto 16);
end block FREE_COUNTER;
--
--*********************************************************
--
--
DIGIT0_MONITOR : block               --***** digit #0 *****
     signal EC,LD,DIR : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                          --CLK rising
               if EC='1' then                                    --CLK enable
                    if    LD='1'  then
                         REG(3 downto 0) <= DB (3 downto 0);     --load register
                    elsif DIR='0' then
                         REG(3 downto 0) <= REG(3 downto 0) + 1; --up   counter
                    else
                         REG(3 downto 0) <= REG(3 downto 0) - 1; --down counter
                    end if;
               end if;
          end if;
     end process;
     EC  <= (SAMPLE and not REG(12)) or
            (KIN    and not CODE(3) and CODE(1) and CODE(0));
     LD  <=  SAMPLE and not REG(12);
     DIR <= CODE(2);
end block DIGIT0_MONITOR;

DIGIT1_MONITOR : block               --***** digit #1 *****
     signal EC,LD,DIR : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                          --CLK rising
               if EC='1' then                                    --CLK enable
                    if    LD='1'  then
                         REG(7 downto 4) <= DB (7 downto 4);     --load register
                    elsif DIR='0' then
                         REG(7 downto 4) <= REG(7 downto 4) + 1; --up   counter
                    else
                         REG(7 downto 4) <= REG(7 downto 4) - 1; --down counter
                    end if;
               end if;
          end if;
     end process;
     EC  <= (SAMPLE and not REG(12)) or
            (KIN    and not CODE(3) and CODE(1) and not CODE(0));
     LD  <=  SAMPLE and not REG(12);
     DIR <= CODE(2);
end block DIGIT1_MONITOR;

DIGIT2_MONITOR : block               --***** digit #2 *****
     signal EC,DIR : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                            --CLK rising
               if EC='1' then                                      --CLK enable
                    if DIR='0' then
                         REG(11 downto 8) <= REG(11 downto 8) + 1; --up   counter
                    else
                         REG(11 downto 8) <= REG(11 downto 8) - 1; --down counter
                    end if;
               end if;
          end if;
     end process;
     EC  <= KIN and not CODE(3) and not CODE(1) and CODE(0);
     DIR <= CODE(2);
end block DIGIT2_MONITOR;

DIGIT3_MONITOR : block               --***** digit #3 *****
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then                  --CLK rising
               if EC='1' then                            --CLK enable
                    REG(12) <= not REG(12);              --T-type F/F
               end if;
          end if;
     end process;
     EC  <= KIN and not CODE(3) and not CODE(2) and not CODE(1) and not CODE(0);
end block DIGIT3_MONITOR;
--
--*********************************************************
-- seven-segment LED transformation
--
SEVEN_SEGMENT : block
     signal D : STD_LOGIC_VECTOR (3 downto 0);
begin
     D <= REG(11 downto  8) when SEQ=2 else "ZZZZ";
     D <= REG(7  downto  4) when SEQ=1 else "ZZZZ";
     D <= REG(3  downto  0) when SEQ=0 else "ZZZZ";
           --GFEDCBA
     SEG <= "0111111" when D=0  else
            "0000110" when D=1  else
            "1011011" when D=2  else
            "1001111" when D=3  else
            "1100110" when D=4  else
            "1101101" when D=5  else
            "1111101" when D=6  else
            "0000111" when D=7  else
            "1111111" when D=8  else
            "1101111" when D=9  else
            "1110111" when D=10 else
            "1111100" when D=11 else
            "0111001" when D=12 else
            "1011110" when D=13 else
            "1111001" when D=14 else
            "1110001" when D=15 else
            "0000000";
end block SEVEN_SEGMENT;
--
--*********************************************************
-- end of architechture
--
end MONITOR_ARCH;


