--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH08 : practise TIMER and FREQUENCY GENERATOR
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH08 is
     port
     (    CLK : in  STD_LOGIC;
          XA  : out STD_LOGIC_VECTOR (3 downto 0);
          XB  : out STD_LOGIC_VECTOR (7 downto 0);
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH08;

architecture CH08_ARCH of CH08 is
     signal SAMPLE    : STD_LOGIC;
     signal FOUT,DOUT : STD_LOGIC;
     signal VALUE     : STD_LOGIC_VECTOR (7 downto 0);
begin
--
--*********************************************************
--
-- 20-BIT free counter
--
FREE_COUNTER : block
     signal Q   : STD_LOGIC_VECTOR (19 downto 0);
     signal DLY : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               DLY <= Q(19);               --delay
               Q   <= Q+1;                 --UP counter
          end if;
     end process;
     SAMPLE <= Q(19) and not DLY;          --differential
end block FREE_COUNTER;
--
--*********************************************************
--
-- 8-BIT UP/DOWN parameter setting
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
     RST <= not XC(3);                       --RST signal
     DIR <= not XC(1);                       --DIR signal
     EC  <= SAMPLE and not XC(0);            --EC  signal
     XB  <= not Q;                           --output signal
     VALUE <=   Q;                           --parameter value
end block UPDOWN_COUNTER;
--
--*********************************************************
-- programmable frequency generation
--
FREQ_GENERATION : block
     signal Q      : STD_LOGIC_VECTOR (8 downto 0);
     signal DLY,EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then      --CLK rising
               DLY <= Q(8);
               if EC='1' then                --CLK enable
                    Q <= Q + ('0' & VALUE);  --integration
               end if;
          end if;
     end process;
     EC   <= SAMPLE;
     DOUT <= Q(8) xor DLY;                   --differential
     FOUT <= Q(8);
end block FREQ_GENERATION;
--
--*********************************************************
-- A/B phase generation
--
PHASE_GENERATION : block
     signal EC,DIR,A,B : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               if EC='1' then              --CLK enable
                    A <= DIR xor     B;    --A phase generation
                    B <= DIR xor not A;    --B phase generation
               end if;
          end if;
     end process;
     EC  <= DOUT;                          --base frequency
     DIR <= XC(2);                         --direction control
     XA(0) <= A;                           --A-phase output
     XA(1) <= B;                           --B-phase output
     XA(2) <= not DOUT;                    --pulse  output
     XA(3) <=     FOUT;                    --square output
end block PHASE_GENERATION;
--
--*********************************************************
-- end of architechture
--
end CH08_ARCH;

