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
-- CH13A : stepping motor control (test #B)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH13B is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --LED scanning
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --LED segment
          XC  : in  STD_LOGIC_VECTOR (3 downto 0);  --keyboard input
          YA  : out STD_LOGIC_VECTOR (3 downto 0)   --stepping output
     );
end CH13B;
architecture CH13B_ARCH of CH13B is
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

     signal DB   : STD_LOGIC_VECTOR (7 downto 0);
     signal A    : STD_LOGIC_VECTOR (3 downto 0);
     signal RD,SWR : STD_LOGIC;

     signal SEQ  : STD_LOGIC_VECTOR (2 downto 0);
     signal STEP : STD_LOGIC_VECTOR (3 downto 0);
     signal SPD  : STD_LOGIC_VECTOR (7 downto 0);
     signal DIR,PLS,FREQ: STD_LOGIC;
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
     signal CS,CS0,CS1 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if CS0='1' then
                    SPD <= DB;           --SPD: register #0
               end if;
               if CS1='1' then
                    DIR <= not DIR;      --DIR: register #1
               end if;
          end if;
     end process;
     CS <= SWR and not A(3) and not A(2) and not A(1);
     CS0 <= CS and not A(0);
     CS1 <= CS and     A(0);
end block COMMAND_REGISTER;
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
     PLS <= BUF(8) xor DLY;
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
     EC <= PLS;
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
end CH13B_ARCH;

