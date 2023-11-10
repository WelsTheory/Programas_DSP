
library IEEE;
use IEEE.std_logic_1164.all;

entity sincos is
    port(
        clk: in std_logic;
        phase: in std_logic_vector(15 downto 0);
        phase_tvalid: in std_logic;
        cos: out std_logic_vector(15 downto 0);
        sin: out std_logic_vector(15 downto 0);
        sincos_tvalid: out std_logic
    );
end sincos;

architecture arch of sincos is

begin

cordic_inst: entity work.cordic_0
    port map(
        aclk => clk,
        s_axis_phase_tvalid => phase_tvalid,
        s_axis_phase_tdata => phase,
        m_axis_dout_tvalid => sincos_tvalid,
        m_axis_dout_tdata(15 downto 0) => cos,
        m_axis_dout_tdata(31 downto 16) => sin
    );

end arch;