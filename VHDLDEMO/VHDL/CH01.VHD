--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH01 : check compiling process
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH01 is
     port
     (    XC0 : in  STD_LOGIC;
          XA0 : out STD_LOGIC
     );
end CH01;

architecture CH01_ARCH of CH01 is
begin
--
--*********************************************************
-- simple I/O test
--
     XA0 <= XC0;
--
--*********************************************************
-- end of architechture
--
end CH01_ARCH;
