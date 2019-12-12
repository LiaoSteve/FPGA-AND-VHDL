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
-- CH13A : stepping motor control (test #A)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH13A is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --LED scanning
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --LED segment
          XC  : in  STD_LOGIC_VECTOR (3 downto 0);  --keyboard input
          YA  : out STD_LOGIC_VECTOR (3 downto 0)   --stepping output
     );
end CH13A;
architecture CH13A_ARCH of CH13A is
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
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
begin
U1:  MONITOR  port map (CLK, DB, A, RD, SWR, XA, XB, XC);
     YA <= STEP;     
end block SYSTEM_CONNECT;
--
--*********************************************************
--
--  command register
--
COMMAND_REGISTER : block
     signal CS0 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if CS0='1' then
                    SEQ <= DB(2 downto 0); --SEQ: register #0
               end if;
          end if;
     end process;
     CS0 <= SWR and not A(3) and not A(2) and not A(1) and not A(0);
end block COMMAND_REGISTER;
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
end CH13A_ARCH;

