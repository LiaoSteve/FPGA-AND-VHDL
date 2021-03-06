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
-- CH14C : motion control (test #C)
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity CH14C is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz  clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --LED scanning
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --LED segment
          XC  : in  STD_LOGIC_VECTOR (3 downto 0);  --keyboard input
          YA  : out STD_LOGIC_VECTOR (1 downto 0);  --PWM  output
          YC  : in  STD_LOGIC_VECTOR (1 downto 0)   --photo input
     );
end CH14C;
architecture CH14C_ARCH of CH14C is
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
     component PWM
     port
     (    DB  : inout STD_LOGIC_VECTOR (7 downto 0);  --data bus
          OP  : out   STD_LOGIC;                      --PWM output
          CS  : in    STD_LOGIC;                      --chip select
          SWR : in    STD_LOGIC;                      --sync write
          CLK : in    STD_LOGIC                       --system clock
     );
     end component;
     component SPEED
     port
     (    DB    : inout STD_LOGIC_VECTOR (7 downto 0); --data bus
          PA,PB : in    STD_LOGIC;                     --photo input
          CS    : in    STD_LOGIC_VECTOR (1 downto 0); --chip select
          RD    : in    STD_LOGIC;                     --read signal
          CLK   : in    STD_LOGIC;                     --system clock
          FREQ  : in    STD_LOGIC                      --sample point
     );
     end component;
     signal DB   : STD_LOGIC_VECTOR (7 downto 0);
     signal A    : STD_LOGIC_VECTOR (3 downto 0);
     signal RD,SWR : STD_LOGIC;
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
     signal CS : STD_LOGIC_VECTOR (1 downto 0);
     signal OP,PA,PB,FREQ : STD_LOGIC;
begin
U1:  MONITOR port map (CLK, DB, A, RD, SWR, XA, XB, XC, FREQ);
U2:  PWM     port map (DB, OP,  CS(0), SWR, CLK);
U3:  SPEED   port map (DB, PA, PB, CS,  RD, CLK, FREQ);

     YA(0) <= OP;
     YA(1) <= '1';
     PA    <= YC(0);
     PB    <= YC(1);

     CS(0) <= not A(3) and not A(2) and not A(1) and not A(0);
     CS(1) <= not A(3) and not A(2) and not A(1) and     A(0);
end block SYSTEM_CONNECT;
--
--*********************************************************
-- end of architechture
--
end CH14C_ARCH;

