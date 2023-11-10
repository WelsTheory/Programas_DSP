
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir_tb is
end fir_tb;

architecture arch of fir_tb is

constant CORDIC_CLK_PERIOD: time := 2 ns;
constant FIR_CLK_PERIOD: time := 10 ns;
constant PI_POS: signed(15 downto 0) := X"6488";
constant PI_NEG: signed(15 downto 0) := X"9B78";
constant PHASE_INC_2MHZ: integer :=  200;
constant PHASE_INC_30MHZ: integer :=  3000;

signal cordic_clk: std_logic := '0';
signal clk_fir: std_logic := '0';
signal phase_tvalid: std_logic := '0';
signal phase_2MHZ: signed(15 downto 0) := (others => '0');
signal phase_30MHZ: signed(15 downto 0) := (others => '0');
signal sincos_2MHZ_tvalid: std_logic;
signal sin_2MHZ,cos_2MHZ: std_logic_vector(15 downto 0);
signal sincos_30MHZ_tvalid: std_logic;
signal sin_30MHZ, cos_30MHZ: std_logic_vector(15 downto 0);
signal noisy_signal: signed(15 downto 0);
signal filtered_signal: signed(15 downto 0);

begin

cordic_inst_0: entity work.cordic_0
port map(
    aclk => cordic_clk,
    s_axis_phase_tvalid => phase_tvalid,
    s_axis_phase_tdata => std_logic_vector(phase_2MHZ),
    m_axis_dout_tvalid => sincos_2MHZ_tvalid,
    m_axis_dout_tdata(31 downto 16) => sin_2MHZ,
    m_axis_dout_tdata(15 downto 0) => cos_2MHZ
);

cordic_inst_1: entity work.cordic_0
port map(
    aclk => cordic_clk,
    s_axis_phase_tvalid => phase_tvalid,
    s_axis_phase_tdata => std_logic_vector(phase_30MHZ),
    m_axis_dout_tvalid => sincos_30MHZ_tvalid,
    m_axis_dout_tdata(31 downto 16) => sin_30MHZ,
    m_axis_dout_tdata(15 downto 0) => cos_30MHZ
);

process(cordic_clk)
begin
    if rising_edge(cordic_clk) then
        phase_tvalid <= '1';

        if (phase_2MHZ + PHASE_INC_2MHZ < PI_POS) then
            phase_2MHz <= phase_2MHZ + PHASE_INC_2MHZ;
        else
            phase_2MHZ <= PI_NEG + (phase_2MHZ+ PHASE_INC_2MHZ - PI_POS);
        end if;

        if (phase_30MHZ + PHASE_INC_30MHZ < PI_POS) then
            phase_30MHZ <= phase_30MHZ + PHASE_INC_30MHZ;
        else
            phase_30MHZ <= PI_NEG + (phase_30MHZ+ PHASE_INC_30MHZ - PI_POS);
        end if;
    end if;
end process;

process
begin
    cordic_clk <= '0';
    wait for CORDIC_CLK_PERIOD/2;
    cordic_clk <= '1';
    wait for CORDIC_CLK_PERIOD/2;
end process;

process
begin
    clk_fir <= '0';
    wait for FIR_CLK_PERIOD/2;
    clk_fir <= '1';
    wait for FIR_CLK_PERIOD/2;
end process;

process(clk_fir)
begin
    if rising_edge(clk_fir) then
        noisy_signal <= (signed(sin_2MHZ) + signed(sin_30MHZ))/2;    
    end if;
end process;

fir_inst: entity work.fir
port map(
    clk_fir => clk_fir,
    noisy_signal => noisy_signal,
    filtered_signal => filtered_signal
);


end arch;