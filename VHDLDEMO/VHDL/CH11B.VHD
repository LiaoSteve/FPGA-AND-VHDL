--The IEEE standard 1164 package, declares std_logic, rising_edge(), etc.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--
--*********************************************************
-- CH11B : digital clock with 7-segment LED control (test #B)
--                    designed by Pei-Chong Tang, Jan. 1999
--*********************************************************
--
entity CH11B is
     port
     (    CLK : in  STD_LOGIC;                      --4MHz clock
          XA  : out STD_LOGIC_VECTOR (3 downto 0);  --output port
          XB  : out STD_LOGIC_VECTOR (7 downto 0);  --input/output
          XC  : in  STD_LOGIC_VECTOR (3 downto 0)   --input  port
     );
end CH11B;

architecture CH11B_ARCH of CH11B is
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
     signal HZ,SEC,CLR      : STD_LOGIC;
     signal CY1,CY2,CY3,CY4 : STD_LOGIC;
begin
--
--*********************************************************
--
-- system connection for the experiment
--
SYSTEM_CONNECT : block
begin
     U1: DIGIT10  port map (CLK,DB,ENB(0),CLR,HZ, CY1);
     U2: DIGIT6   port map (CLK,DB,ENB(1),CLR,CY1,CY2);
     U3: DIGIT10  port map (CLK,DB,ENB(2),CLR,CY2,CY3);
     U4: DIGIT6   port map (CLK,DB,ENB(3),CLR,CY3,CY4);
     CLR <= not XC(0) or not XC(1) or not XC(2) or not XC(3);
     XA  <= not ENB;
     XB(7) <= SEC and ENB(2);
     XB(6 downto 0) <= SEG;
end block SYSTEM_CONNECT;
--
--*********************************************************
-- 24-bit free counter
--
FREE_COUNTER : block
     signal Q : STD_LOGIC_VECTOR (23 downto 0);
     signal D : STD_LOGIC_VECTOR (1  downto 0);
     signal DLY : STD_LOGIC;
begin
     process (CLK)
     begin
          if CLK'event and CLK='1' then
               DLY <= Q(23);
               Q   <= Q+1;
          end if;
     end process;
     HZ  <= Q(23) and not DLY;
     SEC <= Q(23);
     D <= Q(17 downto 16);
     ENB <= "0001" when D=0    else
            "0010" when D=1    else
            "0100" when D=2    else
            "1000" when D=3    else
            "0000";
end block FREE_COUNTER;
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
            "1110111" when DB=10 else
            "1111100" when DB=11 else
            "0111001" when DB=12 else
            "1011110" when DB=13 else
            "1111001" when DB=14 else
            "1110001" when DB=15 else
            "0000000";
end block SEVEN_SEGMENT;
--
--*********************************************************
-- end of architechture
--
end CH11B_ARCH;

