--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH02 : practise VECTOR signals
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH02 is
     port
     (    XA : out STD_LOGIC_VECTOR (0     to 3);
          XB : out UNSIGNED         (7 downto 0);
          XC : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH02;

architecture CH02_ARCH of CH02 is
begin
--
--*********************************************************
-- VECTOR process
--
     XA <= XC;                           -- XA(0-3)=XC(3-0)
     XB(3 downto 0) <= UNSIGNED(XC);     -- XB(3-0)=XC(3-0)
     XB(4) <= XC(3);                     -- XB(4-7)=XC(3-0)
     XB(5) <= XC(2);
     XB(6) <= XC(1);
     XB(7) <= XC(0);
--
--*********************************************************
-- end of architechture
--
end CH02_ARCH;

