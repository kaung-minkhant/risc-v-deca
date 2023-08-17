library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    generic (
        FREQ: integer := 50_000_000;
        O_FREQ: integer := 1
    );
    port (
        clk : in std_logic;
        reset_n : in std_logic;
        clk_o: out std_logic
    );
end clk_divider;

architecture rtl of clk_divider is
    constant half_count: integer := (FREQ/O_FREQ)/2;
    signal count: integer := 0;
    signal clk_buf: std_logic := '0';
begin
    OUT_PROC : process(clk, reset_n)
    begin
        if (reset_n = '0') then
            clk_buf <= '0';
        elsif (clk'event and clk='1') then
            count <= count + 1;
            if (count >= half_count) then
                clk_buf <= not clk_buf;
                count <= 0;
            end if;
        end if;
    end process;
    clk_o <= clk_buf;
end architecture;