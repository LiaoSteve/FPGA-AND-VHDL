--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH09 : practise STATE MACHINE and SHIFT REGISTER
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH09 is
     port
     (    CLK : in  STD_LOGIC;
          XA  : out STD_LOGIC_VECTOR (3 downto 0);
          XB  : out STD_LOGIC_VECTOR (7 downto 0);
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)
     );
end CH09;

architecture CH09_ARCH of CH09 is
     signal SAMPLE,DISPLAY   : STD_LOGIC;
     signal KEY,FLT,DIF,DOUT : STD_LOGIC;
     signal DIN : STD_LOGIC_VECTOR (1 downto 0);
begin
--
--*********************************************************
--
-- 20-BIT free counter
--
FREE_COUNTER : block
     signal Q     : STD_LOGIC_VECTOR (19 downto 0);
     signal D1,D2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then    --CLK rising
               D1 <= Q(16);                --delay
               D2 <= Q(19);                --delay
               Q   <= Q+1;                 --UP counter
          end if;
     end process;
     SAMPLE  <= Q(16) and not D1;          --differential (125Hz)
     DISPLAY <= Q(19) and not D2;          --differential ( 16Hz)
end block FREE_COUNTER;
--
--*********************************************************
--
-- keyboard decoding
--
KEYBOARD_DECODING : block
begin
     KEY <= not(XC(0) and XC(1) and XC(2) and XC(3));  --any keyin 
     DIN <= "00" when XC="1110" else                   --<0> for XC(0)
            "01" when XC="1101" else                   --<1> for XC(1)
            "10" when XC="1011" else                   --<2> for XC(2)
            "11";                                      --<3> for XC(3)
end block KEYBOARD_DECODING;
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
                    D1<=D0; D0<=KEY;       --delay
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
-- state machine
--
STATE_MACHINE : block
     type STATE is (S0,S1,S2,S3,S4,S5,S6,S7); --STATE definition
--     attribute enum_encoding of
--     STATE : type is "000 001 010 011 100 101 110 111";
     signal EC      : STD_LOGIC;
     signal NOW,NXT : STATE;
begin
     process (CLK)                            --sequential logic
     begin
          if CLK'event and CLK='1' then       --CLK rising
               if EC='1' then                 --CLK enable
                    NOW <= NXT;               --state to next
               end if;
          end if;
     end process;
     process (NOW,DIN)                        --combinational logic
     begin
          case NOW is
          when S0 =>                          --in state S0
               DOUT <= '0';
               if DIN="01" then               --check <1>
                    NXT <= S1;
               else
                    NXT <= S0;
               end if;
          when S1 =>                          --in state S1
               DOUT <= '0';
               if DIN="10" then               --check <2>
                    NXT <= S2;
               else
                    NXT <= S0;
               end if;
          when S2 =>                          --in state S2
               DOUT <= '0';
               if DIN="11" then               --check <3>
                    NXT <= S3;
               else
                    NXT <= S0;
               end if;
          when S3 =>                          --in state S3
               DOUT <= '0';
               if DIN="11" then               --check <3>
                    NXT <= S4;
               else
                    NXT <= S0;
               end if;
          when S4 =>                          --in state S4
               DOUT <= '0';
               if DIN="00" then               --check <0>
                    NXT <= S5;
               else
                    NXT <= S0;
               end if;
          when S5 =>                          --in state S5
               DOUT <= '0';
               if DIN="01" then               --check <1>
                    NXT <= S6;
               else
                    NXT <= S0;
               end if;
          when S6 =>                          --in state S6
               DOUT <= '1';                   --signal OK
               NXT  <= S0;
          when others =>                      --in others
               DOUT <= '0';
               NXT  <= S0;
          end case;
     end process;
     EC <= DIF;                               --sample signal
     XA <= "1111" when NOW=S0 else            --state monitor
           "1110" when NOW=S1 else
           "1101" when NOW=S2 else
           "1100" when NOW=S3 else
           "1011" when NOW=S4 else
           "1010" when NOW=S5 else
           "1001" when NOW=S6 else
           "1111";
end block STATE_MACHINE;
--
--*********************************************************
--
-- waveform-generation by shift-register
--
SHIFT_REGISTER : block
     signal STS    : STD_LOGIC_VECTOR (7 downto 0);
     signal RST,EC : STD_LOGIC;
begin
     process (CLK,RST)
     begin
          if RST='1' then                   --reset status
               STS <= "00000001";           --to S0
          elsif CLK'event and CLK='1' then  --CLK rising
               if EC='1' then
                    STS <= STS(6 downto 0) & STS(7); --rotate left
               end if;
          end if;
     end process;
     RST <= not DOUT;                       --RST signal
     EC  <= DOUT and DISPLAY;               --EC  signal
     XB(0) <= not(DOUT and (STS(0) or STS(7))); --LED output
     XB(1) <= not(DOUT and (STS(1) or STS(6)));
     XB(2) <= not(DOUT and (STS(2) or STS(5)));
     XB(3) <= not(DOUT and (STS(3) or STS(4)));
     XB(4) <= not(DOUT and (STS(4) or STS(3)));
     XB(5) <= not(DOUT and (STS(5) or STS(2)));
     XB(6) <= not(DOUT and (STS(6) or STS(1)));
     XB(7) <= not(DOUT and (STS(7) or STS(0)));
end block SHIFT_REGISTER;
--
--*********************************************************
-- end of architechture
--
end CH09_ARCH;

