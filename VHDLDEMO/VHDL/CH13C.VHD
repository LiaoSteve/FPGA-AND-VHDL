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
-- CH13C : stepping motor control (test #C)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH13C is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --LED scanning
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --LED segment
          XC  : in  STD_LOGIC_VECTOR (3 downto 0);  --keyboard input
          YA  : out STD_LOGIC_VECTOR (3 downto 0)   --stepping output
     );
end CH13C;
architecture CH13C_ARCH of CH13C is
     component MONITOR
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
     end component;

     signal DB     : STD_LOGIC_VECTOR (7 downto 0);
     signal A      : STD_LOGIC_VECTOR (3 downto 0);
     signal RD,SWR : STD_LOGIC;

     signal STS    : STD_LOGIC_VECTOR (1 downto 0);
     signal SEQ    : STD_LOGIC_VECTOR (2 downto 0);
     signal STEP   : STD_LOGIC_VECTOR (3 downto 0);
     signal SPD    : STD_LOGIC_VECTOR (7 downto 0);
     signal LMT    : STD_LOGIC_VECTOR (7 downto 0);
     signal LENGTH : STD_LOGIC_VECTOR (7 downto 0);
     signal ACCLNG : STD_LOGIC_VECTOR (7 downto 0);
     signal DIR,PLS,FREQ: STD_LOGIC;
     signal CS0  : STD_LOGIC;
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
begin
U1:  MONITOR  port map (CLK, DB, A, RD, SWR, XA, XB, XC, FREQ);
     YA <= STEP;     
end block SYSTEM_CONNECT;
--
--*********************************************************
--
--  command register
--
COMMAND_REGISTER : block
     signal CS,CS1,CS2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if CS1='1' then
                    DIR <= not DIR;   --DIR: register #1
               end if;
               if CS2='1' then
                    LMT <= DB;        --LMT: register #2
               end if;
          end if;
     end process;
     CS <= SWR and not A(3) and not A(2);
     CS0 <= CS and not A(1) and not A(0);
     CS1 <= CS and not A(1) and     A(0);
     CS2 <= CS and     A(1) and not A(0);
end block COMMAND_REGISTER;
--
--*********************************************************
--
--  position control
--
POSITION_CONTROL : block
     signal EC,TRG0,TRG1,TRG2,TRG3 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if EC='1' then
                    STS <= STS + 1;
               end if;
          end if;
     end process;
     EC  <= TRG0 or TRG1 or TRG2 or TRG3;
     TRG0 <= '1' when STS=0 and  CS0='1'                     else '0';
     TRG1 <= '1' when STS=1 and (LENGTH<=ACCLNG or SPD>=LMT) else '0';
     TRG2 <= '1' when STS=2 and  LENGTH<=ACCLNG              else '0';
     TRG3 <= '1' when STS=3 and  LENGTH=0                    else '0';
end block POSITION_CONTROL;
--
--*********************************************************
--
--  position counting
--
POSITION_COUNTING : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if EC='1' then
                    if CS0='1' then
                         LENGTH <= DB;
                    else
                         LENGTH <= LENGTH - 1;
                    end if;
               end if;
          end if;
     end process;
     EC <= CS0 or PLS;
end block POSITION_COUNTING;
--
--*********************************************************
--
--  accelerate counting
--
ACC_COUNTING : block
     signal EC,RST : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then
               ACCLNG <= "00000000";
          elsif CLK'event and CLK='1' then
               if EC='1' then
                    ACCLNG <= ACCLNG + 1;
               end if;
          end if;
     end process;
     RST <= '1' when STS=0             else '0';
     EC  <= '1' when STS=1 and PLS='1' else '0';
end block ACC_COUNTING;
--
--*********************************************************
--
--  accelerate control
--
ACC_CONTROL : block
     signal EC,DIR,SET : STD_LOGIC;
begin
     process (CLK)
     begin
          if SET='1' then
               SPD <= "00000001";
          elsif CLK'event and CLK='1' then
               if EC='1' then
                    if DIR='1' then
                        SPD <= SPD - 1;
				    --SPD <= SPD;
                    else
                       SPD <= SPD + 1;
				   --SPD <= SPD;
                    end if;
               end if;
          end if;
     end process;
     SET <= '1' when STS=0 or SPD=0 else '0';
     EC  <= FREQ and STS(0);
     DIR <= '0' when STS=1          else '1';
end block ACC_CONTROL;
--
--*********************************************************
--
--  speed control
--
SPEED_CONTROL : block
     signal BUF : STD_LOGIC_VECTOR (8 downto 0);
     signal EC,DLY : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               DLY <= BUF(8);
               if EC='1' then
                    BUF <= BUF + ('0' & SPD);
               end if;
          end if;
     end process;
     EC  <= FREQ;
     PLS <= BUF(8) xor DLY when STS/=0 else '0';
end block SPEED_CONTROL;
--
--*********************************************************
--
--  test step-table for stepping motor control
--
STEP_MOVING : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if EC='1' then
                    if DIR='1' then
                         SEQ <= SEQ - 1;
                    else
                         SEQ <= SEQ + 1;
                    end if;
               end if;
          end if;
     end process;
     EC  <= PLS;
end block STEP_MOVING;
--
--*********************************************************
--
--  table mapping for stepping motor
--
TABLE_MAPPING : block
begin
     STEP <= "0001" when SEQ=0 else
             "0011" when SEQ=1 else
             "0010" when SEQ=2 else
             "0110" when SEQ=3 else
             "0100" when SEQ=4 else
             "1100" when SEQ=5 else
             "1000" when SEQ=6 else
             "1001";
end block TABLE_MAPPING;
--
--*********************************************************
-- end of architechture
--
end CH13C_ARCH;

