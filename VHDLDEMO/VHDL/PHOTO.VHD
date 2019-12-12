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
-- PHOTO : photo-encoder decoding circuit
--         (CLK, PHTA,PHTB,PHTZ, MODE, ZCLR, RD)
--     ==> (DBUS, ZERO)
--
--                    designed by Pei-Chong Tang, Dec. 1998
--*********************************************************
--
entity PHOTO is
     port
     (    DB    : inout STD_LOGIC_VECTOR (7 downto 0); --data bus
          PA,PB : in    STD_LOGIC;                     --photo input
          CS    : in    STD_LOGIC;                     --chip select
          RD    : in    STD_LOGIC;                     --read signal
          CLK   : in    STD_LOGIC                      --system clock
     );
end PHOTO;

architecture PHOTO_ARCH of PHOTO is
     signal CNT     : STD_LOGIC_VECTOR (7 downto 0);
     signal PHA,PHB : STD_LOGIC;
     signal DIR,PLS : STD_LOGIC;
begin
--
--*********************************************************
-- low-pass digital filter
--      (PA,  PB)
--  ==> (PHA, PHB)
--
FILTER_A : block                   -- digital filter for #A
     signal D0,D1,D2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then  --CLK rising
               D2<=D1; D1<=D0; D0<=PA;   --delay 3 clocks
               PHA <= (D0 and D1 and D2) or ((D0 or D1 or D2) and PHA);
          end if;
     end process;
end block FILTER_A;

FILTER_B : block                   -- digital filter for #B
     signal D0,D1,D2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then  --CLK rising edge
               D2<=D1; D1<=D0; D0<=PB;    --delay 3 clocks
               PHB <= (D0 and D1 and D2) or ((D0 or D1 or D2) and PHB);
          end if;
     end process;
end block FILTER_B;
--
--*********************************************************
-- up/down decoding
--        (PHA, PHB)
--    ==> (DIR, PLS)
--
DECODER : block
     signal DLA,DLB : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then  -- clock rising edge
               DLA<=PHA; DLB<=PHB;       -- delay 1-clock
          end if;
     end process;
     DIR <= (not PHA and     DLA and not PHB)
         or (    PHA and not DLA and     PHB)
         or (not PHB and     DLB and     PHA)
         or (    PHB and not DLB and not PHA);
     PLS <= (not PHA and DLA) or (PHA and not DLA)
         or (not PHB and DLB) or (PHB and not DLB);
end block DECODER;

--
--*********************************************************
-- up/down counter
--        (CLK, MODE, PLS, DIR)
--    ==> (CNT)
--
COUNTER : block
     signal EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then   --clock rising
               if EC='1' then             --clock enable
                    if DIR='1' then       --up/down control
                         CNT <= CNT - 1;  --down counter
                    else
                         CNT <= CNT + 1;  --up   counter
                    end if;
               end if;
          end if;
     end process;
     EC <= PLS;
end block COUNTER;
--
--*********************************************************
-- bus interface
--      (CNT, RD)
--  ==> (DBUS)
--
BUS_INTERFACE : block
     signal T : STD_LOGIC;
begin
     DB <= CNT when T='1' else "ZZZZZZZZ";
     T  <= not RD and CS;
end block BUS_INTERFACE;
--
--*********************************************************
-- end of architecture
--
end PHOTO_ARCH;






