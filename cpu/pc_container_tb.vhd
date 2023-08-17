library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pc_container_tb is
end pc_container_tb;

architecture sim of pc_container_tb is

    component pc_container IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        -- inputs
        address_offset : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        -- output address
        pc_address : buffer STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        -- reset and clock
        reset_n, clk : IN STD_LOGIC;

        -- controls
        -- load, branch/add (1 = branch)
        controls : IN STD_LOGIC_VECTOR(1 DOWNTO 0)

    );
END component;

    constant CLK_PERIOD : time := 10 ps;
    constant CLK_HALF_PERIOD : time :=  CLK_PERIOD / 2;

    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';

    constant DATA_WIDTH : integer := 32;

    signal controls : std_logic_vector(1 downto 0) := (others => '0');
    signal pc_address, address_offset : std_logic_vector(DATA_WIDTH-1 downto 0) :=  (others => '0');

begin

    clk <= not clk after CLK_HALF_PERIOD;
    reset_n <=  '1' after 3 * CLK_PERIOD;

    DUT : entity work.pc_container(rtl)
    generic map (
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset_n => reset_n,
        address_offset => address_offset, pc_address =>  pc_address, controls => controls
    );

    TEST_PROC : process
    begin
        for i in 0 to 4 loop
            wait for CLK_PERIOD * 3;
            controls <= "10";
            wait for CLK_PERIOD;
            controls <= "00";
        end loop;
        for j in 0 to 5 loop
            wait for CLK_PERIOD*3;
            address_offset <= std_logic_vector(to_unsigned(j, address_offset'length));
            controls <= "11";
            wait for CLK_PERIOD;
            controls <= "01";
        end loop;
        wait;
    end process;



   
end architecture;