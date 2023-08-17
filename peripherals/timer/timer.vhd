library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic (
        FREQ: integer := 50_000_000
    );
    port (
        clk_main : in std_logic;
        milli : in std_logic_vector(31 downto 0);

        on_timing : out std_logic
    );
end timer;

architecture rtl of timer is
    constant ONE_MILLI_COUNT : integer := 50_000;
    signal count := integer := 0;
    signal count_milli := integer := 0;
begin
    COUNT_PROC : process(clk_main)
    begin
        if (clk_main'event and clk_main = '1') then
            count <= count + 1;
            if (count >= ONE_MILLI_COUNT) then
                -- one milli done
                count_milli <= count_milli + 1;
                count <= 0;
            end if;
        end if;
    end process;

end architecture;