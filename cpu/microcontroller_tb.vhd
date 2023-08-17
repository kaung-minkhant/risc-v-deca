library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microcontroller_tb is
end microcontroller_tb;

architecture sim of microcontroller_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 10 ps; --1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal reset_n : std_logic := '0';

    component microcontroller is
        port (
            clk, reset_n : in std_logic;
    
            general_io : inout std_logic_vector(15 downto 0);
            special_io : inout std_logic_vector(15 downto 0)
        );
    end component;
    
    signal general_io, special_io : std_logic_vector(15 downto 0) := (others => '0');

begin

    clk <= not clk after clk_period / 2;
    reset_n <= '1' after 5*clk_period;

    DUT: microcontroller
    port map(
        clk => clk, reset_n => reset_n,
        general_io => general_io, special_io => special_io
    );


end architecture;