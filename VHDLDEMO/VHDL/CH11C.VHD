--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH11C : digital clock with 7-segment LED control (test #C)
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH11C is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --output port
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --input/output
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)   --input  port
     );
end CH11C;

architecture CH11C_ARCH of CH11C is
     component DIGIT10    --***** one digit with divide-by-10 *****
     port
     (    CLK : in    STD_LOGIC;                     --system clock
          DB  : out   STD_LOGIC_VECTOR (3 downto 0); --digit bus
          ENB : in    STD_LOGIC;                     --output enable
          CLR : in    STD_LOGIC;                     --clear signal
          EC  : in    STD_LOGIC;                     --carry in
          CY  : out   STD_LOGIC                      --carry out
     );
     end component;
     component DIGIT6     --***** one digit with divide-by-6  *****
     port
     (    CLK : in    STD_LOGIC;                     --system clock
          DB  : out   STD_LOGIC_VECTOR (3 downto 0); --digit bus
          ENB : in    STD_LOGIC;                     --output enable
          CLR : in    STD_LOGIC;                     --clear signal
          EC  : in    STD_LOGIC;                     --carry in
          CY  : out   STD_LOGIC                      --carry out
     );
     end component;
                         --***** global signals *****
     signal DB  : STD_LOGIC_VECTOR (3 downto 0);
     signal SEG : STD_LOGIC_VECTOR (6 downto 0);
     signal ENB : STD_LOGIC_VECTOR (3 downto 0);
     signal HZ,SEC,CLR,HOLD : STD_LOGIC;
     signal SAMPLE,MATCH    : STD_LOGIC;
     signal KEY,FLT,DIF     : STD_LOGIC;
     signal SEL : STD_LOGIC_VECTOR (2 downto 0);
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
     signal EC, EC1,EC2,EC3,EC4 : STD_LOGIC;
     signal CY0,CY1,CY2,CY3,CY4 : STD_LOGIC;
begin
     U1: DIGIT10  port map (CLK,DB,ENB(0),CLR,EC1,CY1);
     U2: DIGIT6   port map (CLK,DB,ENB(1),CLR,EC2,CY2);
     U3: DIGIT10  port map (CLK,DB,ENB(2),CLR,EC3,CY3);
     U4: DIGIT6   port map (CLK,DB,ENB(3),CLR,EC4,CY4);
     CLR <= not XC(3);
     EC  <=  HZ and not SEL(2) and not XC(0);
     CY0 <=  HZ and not HOLD;
     EC1 <= (CY0 and SEL(2)) or (EC and not SEL(1) and not SEL(0));
     EC2 <= (CY1 and SEL(2)) or (EC and not SEL(1) and     SEL(0));
     EC3 <= (CY2 and SEL(2)) or (EC and     SEL(1) and not SEL(0));
     EC4 <= (CY3 and SEL(2)) or (EC and     SEL(1) and     SEL(0));
     KEY <= not XC(0) or not XC(1) or not XC(2) or not XC(3);
     XA  <= not ENB;
     XB(7) <= SEC and ENB(2) and SEL(2) and not HOLD;
GEN: for I in 0 to 6 generate
     XB(I) <= SEG(I) and (SEC or not MATCH or SEL(2));  
     end generate;
end block SYSTEM_CONNECT;
--
--*********************************************************
-- 24-bit free counter
--
FREE_COUNTER : block
     signal Q : STD_LOGIC_VECTOR (23 downto 0);
     signal D : STD_LOGIC_VECTOR (1  downto 0);
     signal DLY1,DLY2 : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               DLY1 <= Q(23);
               DLY2 <= Q(15);
               Q  <= Q+1;
          end if;
     end process;
     SEC    <= Q(23);
     HZ     <= Q(23) and not DLY1;
     SAMPLE <= Q(15) and not DLY2;
     D <= Q(17 downto 16);
     ENB <= "0001" when D=0 else
            "0010" when D=1 else
            "0100" when D=2 else
            "1000" when D=3 else
            "0000";
     MATCH <= '1' when D=SEL(1 downto 0) else '0';
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
               if SAMPLE='1' then          --CLK enable
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
-- timer control
--
TIMER_CONTROL : block
     signal SET,EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if SET='1' then
               HOLD <= '1';
          elsif CLK'event and CLK='1' then
               if EC='1' then
                    HOLD <= not HOLD;
               end if;
          end if;
     end process;
     SET <= not XC(3);
     EC  <= not XC(2) and DIF;
end block TIMER_CONTROL;
--
--*********************************************************
-- digit select
--
DIGIT_SELECT : block
     signal Q : STD_LOGIC_VECTOR (2 downto 0);
     signal SET,EC : STD_LOGIC;
begin
     process (CLK)
     begin
          if SET='1' then
               Q <= "100";
          elsif CLK'event and CLK='1' then
               if EC='1' then
                    Q <= Q-1;
               end if;
          end if;
     end process;
     SET <= '1' when Q=7 else '0';
     EC  <= DIF and not XC(1);
     SEL <= Q;
end block DIGIT_SELECT;
--
--*********************************************************
-- seven-segment LED transformation
--
SEVEN_SEGMENT : block
begin
           --GFEDCBA
     SEG <= "0111111" when DB=0  else
            "0000110" when DB=1  else
            "1011011" when DB=2  else
            "1001111" when DB=3  else
            "1100110" when DB=4  else
            "1101101" when DB=5  else
            "1111101" when DB=6  else
            "0000111" when DB=7  else
            "1111111" when DB=8  else
            "1101111" when DB=9  else
            "0000000";
end block SEVEN_SEGMENT;
--
--*********************************************************
-- end of architechture
--
end CH11C_ARCH;

