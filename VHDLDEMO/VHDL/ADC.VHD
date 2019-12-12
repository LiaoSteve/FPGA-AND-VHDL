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
-- ADC : 8-BIT ADC input
--                    designed by Pei-Chong Tang, Feb. 1999
--*********************************************************
--
entity ADC is
     port
     (    AOP  : out STD_LOGIC_VECTOR (7 downto 0); --ADC data
          AIN  : in  STD_LOGIC_VECTOR (7 downto 0); --ADC input
          STC  : out STD_LOGIC;                     --start of conv.
          ENB  : out STD_LOGIC;                     --read enable
          FREQ : in  STD_LOGIC;                     --sample point
          CLK  : in  STD_LOGIC                      --system clock
     );
end ADC;

architecture ADC_ARCH of ADC is
     signal D0,D1,D2,D3 : STD_LOGIC;
begin
--
--*********************************************************
--
-- time sequence generator
--
TIME_SEQUENCE : block
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               D3<=D2; D2<=D1; D1<=D0; D0<=FREQ;
          end if;
     end process;
     ENB <= not (FREQ or D0 or D1);
     STC <= not  D3;
end block TIME_SEQUENCE;
--
--*********************************************************
--
-- 8-bit analog-to-digital input
--
ADC_FETCH : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               if EC='1' then
                    AOP <= AIN;
               end if;
          end if;
     end process;
     EC <= D1;
end block ADC_FETCH;
--
--*********************************************************
-- end of architechture
--
end ADC_ARCH;

