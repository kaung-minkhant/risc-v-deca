library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end cpu_tb;

architecture sim of cpu_tb is

    component cpu IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32
        );
        PORT (
            reset_n, clk: std_logic
        );
    END component;

    constant CLK_PERIOD : time := 50 ps;
    constant CLK_HALF_PERIOD : time :=  CLK_PERIOD / 2;

    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';

    constant DATA_WIDTH : integer := 32;

begin

    clk <= not clk after CLK_HALF_PERIOD;

    reset_n <= '1' after 5*CLK_PERIOD;

    DUT : entity work.cpu(rtl)
    generic map (
        DATA_WIDTH =>  DATA_WIDTH
    )
    port map (
        clk => clk,
        reset_n => reset_n
        
    );

end architecture;