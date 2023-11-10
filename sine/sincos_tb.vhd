library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sincos_tb is
end sincos_tb;

architecture arch of sincos_tb is

constant CLOCK_PERIOD: time := 10ns;
constant PI_POS: signed(15 downto 0) := "0110010010001000";
constant PI_NEG: signed(15 downto 0) := "1001101101111000";
constant PHASE_INC: integer := 256;

signal clk: std_logic := '0';
signal rst: std_logic := '1';

signal phase: signed(15 downto 0);
signal phase_tvalid: std_logic;
signal cos, sin: std_logic_vector(15 downto 0);
signal sincos_tvalid: std_logic;

begin 

sincos_inst: entity work.sincos
    port map(
        clk             => clk,
        phase           => std_logic_vector(phase),
        phase_tvalid    => phase_tvalid,
        cos             => cos,
        sin             => sin,
        sincos_tvalid   => sincos_tvalid
    );
   
process
begin 
    clk <= '0';
    wait for CLOCK_PERIOD/2;
    clk <= '1';
    wait for CLOCK_PERIOD/2;
end process;

process
begin
    rst <= '1';
    wait for CLOCK_PERIOD*10;
    rst <= '0';
    wait;
end process;

process (clk)
begin
    if rst = '1' then
        phase <= (others => '0');
        phase_tvalid <= '0';
    else
        phase_tvalid <= '1';
        if(phase + PHASE_INC < PI_POS) then
            phase <= phase + PHASE_INC;
        else 
            phase <= PI_NEG;
        end if;
    end if;
end process;

end arch;



    
    