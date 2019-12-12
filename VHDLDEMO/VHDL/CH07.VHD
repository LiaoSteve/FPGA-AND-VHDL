--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH07 : practise synchronize UP/DOWN counter
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH07 is
     port
     (    CLK : in  STD_LOGIC;
          XB  : out STD_LOGIC_VECTOR (7 downto 0);
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH07;

architecture CH07_ARCH of CH07 is
     signal SAMPLE,FLT,DIF : STD_LOGIC;
begin
--
--*********************************************************
--
-- 17-BIT free counter
--
FREE_COUNTER : block
     signal Q   : STD_LOGIC_VECTOR (16 downto 0);
     signal DLY : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               DLY <= Q(16);               --delay
               Q   <= Q+1;                 --UP counter
          end if;
     end process;
     SAMPLE <= Q(16) and not DLY;          --differential
end block FREE_COUNTER;
--
--*********************************************************
--
-- keyboard debouncing
--
DEBOUNCING : block
     signal D0,D1 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               if SAMPLE='1' then          --sampling control
                    D1<=D0; D0<=not XC(0); --delay
                    FLT <= ((D0 and D1) or FLT) and (D0 or D1); --RS-F/F
               end if;
          end if;
     end process;
end block DEBOUNCING;
--
--*********************************************************
--
-- differential signal
--
DIFFERENTIAL : block
     signal D0,D1 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               D1<=D0; D0<=FLT;            --delay
          end if;
     end process;
     DIF <= D0 and not D1;                 --differential
end block DIFFERENTIAL;
--
--*********************************************************
--
-- 8-BIT synchronize up/down counter
--
UPDOWN_COUNTER : block
     signal Q : STD_LOGIC_VECTOR (7 downto 0);
     signal RST,EC,DIR : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then                  --counter reset
               Q <= "00000000";            --Q=0
          elsif CLK'event and CLK='1' then --CLK rising
               if EC='1' then              --CLK enable
                    if DIR='0' then        --UP/DOWN direction
                         Q <= Q+1;         --UP   counter
                    else
                         Q <= Q-1;         --DOWN counter
                    end if;
               end if;
          end if;
     end process;
     RST <= not XC(3);                     --RST signal
     EC  <= DIF and XC(2);                 --EC  signal
     DIR <= not XC(1);                     --DIR signal
     XB  <= not Q;                         --output signal
end block UPDOWN_COUNTER;
--
--*********************************************************
-- end of architechture
--
end CH07_ARCH;

