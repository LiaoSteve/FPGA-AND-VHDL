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
-- CH15A : temperature control (test #A)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH15A is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --LED scanning
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --LED segment
          XC  : in  STD_LOGIC_VECTOR (3 downto 0);  --keyboard input
          YA  : out STD_LOGIC_VECTOR (3 downto 0);  --PWM  output
          YB  : in  STD_LOGIC_VECTOR (7 downto 0)   --photo input
     );
end CH15A;
architecture CH15A_ARCH of CH15A is
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
     component ADC
     port
     (    AOP  : out STD_LOGIC_VECTOR (7 downto 0); --ADC data
          AIN  : in  STD_LOGIC_VECTOR (7 downto 0); --ADC input
          STC  : out STD_LOGIC;                     --start of conv.
          ENB  : out STD_LOGIC;                     --read enable
          FREQ : in  STD_LOGIC;                     --sample point
          CLK  : in  STD_LOGIC                      --system clock
     );
     end component;
     signal DB   : STD_LOGIC_VECTOR (7 downto 0);
     signal A    : STD_LOGIC_VECTOR (3 downto 0);
     signal RD, SWR : STD_LOGIC;
     signal AOP,AIN : STD_LOGIC_VECTOR (7 downto 0);
     signal CS0,PWR : STD_LOGIC;
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
     signal DIN : STD_LOGIC_VECTOR (7 downto 0);
     signal FREQ,STC,ENB : STD_LOGIC;
begin
U1:  MONITOR port map (CLK, DB, A, RD, SWR, XA, XB, XC, FREQ);
U2:  ADC     port map (AOP, AIN, STC, ENB, FREQ, CLK);

     YA(0) <= PWR;
     YA(1) <= '1';
     YA(2) <= ENB;
     YA(3) <= STC;
     AIN   <= YB;

     CS0  <= not A(3) and not A(2) and not A(1) and not A(0);
end block SYSTEM_CONNECT;
--
--*********************************************************
-- command register
--
COMMAND_REGISTER : block
     signal T,EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if EC='1' then
                    PWR <= DB(0);
               end if;
          end if;
     end process;
     DB <= AOP when T='1' else "ZZZZZZZZ";
     EC <= SWR and CS0;
     T  <= not RD and CS0;
end block COMMAND_REGISTER;
--
--*********************************************************
-- end of architechture
--
end CH15A_ARCH;

