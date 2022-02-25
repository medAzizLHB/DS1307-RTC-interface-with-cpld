--interface DS1307 with cpld
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity write is
port ( 	clk : in std_logic;   ---system clock
       reset : in std_logic;  ---switching process
 	sda   : inout std_logic;  ----i2c data line
		scl   : out std_logic := '1'; ---i2c clock line
		l1    : out std_logic := '1');
end write;

architecture Behavioral of write is

type state is (start,state1,state2,state3,stop,finish); ---fsm
signal ps : state := start;

signal control : std_logic_vector(7 downto 0) := x"0b"; --command data for write
signal add     : std_logic_vector(7 downto 0) := x"00"; --address
signal datas    : std_logic_vector(7 downto 0) := x"00"; --initial value for second	
signal datam    : std_logic_vector(7 downto 0) := x"9a";--initial value for minutes
signal datah    : std_logic_vector(7 downto 0) := x"c4";	--initial value for hours
signal datada    : std_logic_vector(7 downto 0) := x"80"; --initial value for day
signal datadate    : std_logic_vector(7 downto 0) := x"8c";	--initial value for date
signal datamon    : std_logic_vector(7 downto 0) := x"48";	--initial value for month
signal dataye    : std_logic_vector(7 downto 0) := x"10";	--initial value for year			 
signal ack : std_logic := '1';								 
begin
process(reset,clk)------------------
variable i,j : integer := 0;
begin
if reset = '1' then
if clk'event and clk = '1' then
if ps = start then    ---i2c start condition
if i <= 250 then
i := i + 1;
sda <= '1';
scl <= '1';
elsif i > 250 and i <= 500 then
i := i + 1;
sda <= '0';
scl <= '1';
elsif i > 500 and i < 750 then
i := i + 1;
sda <= '0';
scl <= '0';
elsif i = 750 then
i := 0;
sda <= '0';
scl <= '0';
ps <= state1 ;
end if;
end if;
---------------------------------------------------------------------
if ps = state1 then   -----control word for write
if i <= 250 then
i := i + 1;
scl <= '0';
if j < 8 then
sda <= control(j);
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 250 and i <= 500 then
i := i + 1;
scl <= '1';
if j < 8 then
sda <= control(j);
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 500 and i < 750 then
i := i + 1;
scl <= '0';
if j < 8 then
sda <= control(j);
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i = 750 then
scl <= '0';
i := 0;
if j < 8 then
j := j + 1;
elsif j = 8 then
j := 0;
ps <= state2;
end if;
end if;
end if;
--------------------------------------------------------
if ps = state2 then   ----address send state
if i <= 250 then
i := i + 1;
scl <= '0';
if j < 8 then
sda <= add(j);  ---sending each bit of address
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 250 and i <= 500 then
i := i + 1;
scl <= '1';
if j < 8 then
sda <= add(j);
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 500 and i < 750 then
i := i + 1;
scl <= '0';
if j < 8 then
sda <= add(j);
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i = 750 then
scl <= '0';
i := 0;
if j < 8 then
j := j + 1;
elsif j = 8 then
j := 0;
case add  is    -----assigning address for each register
when x"00" =>
add <= x"80" ;
when x"80" =>
add <= x"40" ;
------------------------------------------------
when x"40" =>
add <= x"c0" ;
when x"c0" =>
add <= x"20" ;
when x"20" =>
add <= x"a0" ;
when x"a0" =>
add <= x"60" ;
when x"60" =>
add <= x"70" ;
when others =>
null;
------------------------------------------------
end case;
ps <= state3;
end if;
end if;
end if;
if ps = state3 then
if i <= 250 then
i := i + 1;
scl <= '0';
if j < 8 then
case add  is    ---assigning initial data for each register
when x"80"  =>
sda <= datas(j);
------------------------------------------------
when x"40" =>
sda <= datam(j);
when x"c0" =>
sda <= datah(j);
when x"20" =>
sda <= datada(j);
when x"a0" =>
sda <= datadate(j);
when x"60" =>
sda <= datamon(j);
when x"70" =>
sda <= dataye(j);
when others =>
null;
--------------------------------------------------
end case;
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 250 and i <= 500 then
i := i + 1;
scl <= '1';
if j < 8 then
case add is 
when x"80"  =>
sda <= datas(j);
------------------------------------------------
when x"40" =>
sda <= datam(j);
when x"c0" =>
sda <= datah(j);
when x"20" =>
sda <= datada(j);
when x"a0" =>
sda <= datadate(j);
when x"60" =>
sda <= datamon(j);
l1 <= '0';
when x"70" =>
sda <= dataye(j);
when others =>
null;
--------------------------------------------------
end case;
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i > 500 and i < 750 then
i := i + 1;
scl <= '0';
if j < 8 then
case add is
when x"80"  =>
sda <= datas(j);
------------------------------------------------
when x"40" =>
sda <= datam(j);
when x"c0" =>
sda <= datah(j);
when x"20" =>
sda <= datada(j);
when x"a0" =>
sda <= datadate(j);
when x"60" =>
sda <= datamon(j);
when x"70" =>
sda <= dataye(j);
when others =>
null;
--------------------------------------------------
end case;
elsif j = 8 then
sda <= 'Z';
ack <= sda;
end if;
elsif i = 750 then
scl <= '0';
i := 0;
if j < 8 then
j := j + 1;
elsif j = 8 then
j := 0;
ps <= stop;
end if;
end if;
end if;
--------------------------------------------------------
if ps = stop then    ----i2c stop condition 
if i <= 250 then
i := i + 1;
sda <= '0';
scl <= '1';
elsif i > 250 and i <= 500 then
i := i + 1;
sda <= '1';
scl <= '1';
elsif i > 500 and i < 750 then
i := i + 1;
sda <= '1';
scl <= '1';
elsif i = 750 then
i := 0;
sda <= '1';
scl <= '1';
case add  is
when x"70" =>
ps <= finish ;
when x"80" =>
ps <= start ;
------------------------------------------------
when x"40" =>
ps <= start ;
when x"c0" =>
ps <= start ;
when x"20" =>
ps <= start ;
when x"a0" =>
ps <= start ;
when x"60" =>
ps <= start ;
when others =>
null;
------------------------------------------------
end case; 
end if;
-----------------------------------------
end if;
end if;
end if;
end process;
end Behavioral;