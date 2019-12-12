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
-- PWM : Pulse-Width-Modulation (PWM) genetation
--         (CLK, DB, SWR, CS)
--     ==> (OP)
--
--                    designed by Pei-Chong Tang, Dec. 1998
--*********************************************************
--
entity PWM is
     port
     (    DB  : inout STD_LOGIC_VECTOR (7 downto 0);  --data bus
          OP  : out   STD_LOGIC;                      --PWM output
          CS  : in    STD_LOGIC;                      --chip select
          SWR : in    STD_LOGIC;                      --sync write
          CLK : in    STD_LOGIC                       --system clock
     );
end PWM;

architecture PWM_ARCH of PWM is
     signal  CNT : STD_LOGIC_VECTOR (7 downto 0);
begin
--
--*********************************************************
-- down counter
--      (CLK)
--  ==> (CNT)
--
COUNTER : block
     signal Q : STD_LOGIC_VECTOR (9 downto 0);
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then  --CLK rising
               Q <= Q-1;                 --down counter
          end if;
     end process;
     CNT <= Q(9 downto 2);
end block COUNTER;

--
--*********************************************************
-- data-latch and comparator
--        (DB, SWR, CNT)
--    ==> (OP)
--
PWM_COMPARATOR : block
     signal Q  : STD_LOGIC_VECTOR (7 downto 0);
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then  --CLK rising
               if EC='1' then            --CLK enable
                    Q <= DB;             --D-type register
               end if;
          end if;
     end process;
     EC <= SWR and CS;                   --CLK enable
     OP <= '1' when Q>CNT else '0';      --PWM output
end block PWM_COMPARATOR;
--
--*********************************************************
-- end of architecture
--
end PWM_ARCH;


