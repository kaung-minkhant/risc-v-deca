LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY i2c_test IS
END ENTITY i2c_test;

ARCHITECTURE tb OF i2c_test IS
    CONSTANT CLOCK_FREQ : INTEGER := 50e6;
    CONSTANT BUS_CLK : INTEGER := 5e6;
    CONSTANT CLOCK_PERIOD : TIME := 2 ps;
    CONSTANT CLOCK_HALF_PERIOD : TIME := CLOCK_PERIOD/2;

    COMPONENT i2c_master IS
        GENERIC (
            input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
            bus_clk : INTEGER := 400_000); --speed the i2c bus (scl) will run at in Hz
        PORT (
            clk : IN STD_LOGIC; --system clock
            reset_n : IN STD_LOGIC; --active low reset
            ena : IN STD_LOGIC; --latch in command
            addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
            rw : IN STD_LOGIC; --'0' is write, '1' is read
            data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
            busy : OUT STD_LOGIC; --indicates transaction in progress
            data_rd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
            ack_error : BUFFER STD_LOGIC; --flag if improper acknowledge from slave
            sda : INOUT STD_LOGIC; --serial data output of i2c bus
            scl : INOUT STD_LOGIC;
            clk_data : OUT STD_LOGIC); --serial clock output of i2c bus
    END COMPONENT;

    SIGNAL scl_tb, sda_tb : STD_LOGIC := 'Z';
    SIGNAL clk_tb, reset_n_tb, ena_tb, rw_tb, busy_tb, ack_error_tb, data_valid_tb, data_valid_tb2, read_req_tb, read_req_tb2, data_clk_tb : STD_LOGIC := '0';
    SIGNAL addr_tb : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
    SIGNAL data_wr_tb, data_rd_tb, data_to_master_tb, data_to_master_tb2, data_from_master_tb, data_from_master_tb2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";

    COMPONENT I2C_minion IS
        GENERIC (
            MINION_ADDR : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011"
        );
        PORT (
            scl : INOUT STD_LOGIC;
            sda : INOUT STD_LOGIC;
            clk : IN STD_LOGIC;
            reset_n : IN STD_LOGIC;
            -- User interface
            read_req : OUT STD_LOGIC;
            data_to_master : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            data_valid : OUT STD_LOGIC;
            data_from_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;

    PROCEDURE transmit_once(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC
    ) IS
    BEGIN
        data_wr <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '0';
        data_wr <= "01100110";
        ena <= '1';
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE read_once(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC;
        SIGNAL data_to_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    ) IS
    BEGIN
        data_to_master <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '1';
        ena <= '1';
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE transmit_three_same(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC
    ) IS
    BEGIN
        data_wr <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '0';
        data_wr <= "01100110";
        ena <= '1';
        WAIT UNTIL rising_edge(busy);
        data_wr <= "00110111";
        WAIT UNTIL rising_edge(busy);
        data_wr <= "01001110";
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE read_twice_same(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC;
        SIGNAL data_to_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL read_req : IN STD_LOGIC
    ) IS
    BEGIN
        data_to_master <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '1';
        ena <= '1';
        WAIT UNTIL rising_edge(read_req);
        data_to_master <= "00100111";
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE transmit_two_different(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC
    ) IS
    BEGIN
        data_wr <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '0';
        data_wr <= "01100110";
        ena <= '1';
        WAIT UNTIL rising_edge(busy);
        addr <= "0000111";
        data_wr <= "00110111";
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE read_two_different(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC;
        SIGNAL data_to_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL data_to_master2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL read_req : IN STD_LOGIC
    ) IS
    BEGIN
        data_to_master <= "01100110";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '1';
        ena <= '1';
        WAIT UNTIL rising_edge(read_req);
        data_to_master2 <= "11001011";
        addr <= "0000111";
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;

    PROCEDURE write_then_read(
        SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL rw : OUT STD_LOGIC;
        SIGNAL ena : OUT STD_LOGIC;
        SIGNAL busy : IN STD_LOGIC;
        SIGNAL data_to_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL data_to_master2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL read_req : IN STD_LOGIC
    ) IS
    BEGIN
        data_wr <= "01100110";
        data_to_master <= "11001011";
        WAIT FOR 5 * CLOCK_PERIOD;
        addr <= "0000011";
        rw <= '0';
        ena <= '1';
        WAIT UNTIL rising_edge(busy);
        rw <= '1';
        WAIT UNTIL rising_edge(busy);
        ena <= '0';
    END PROCEDURE;
BEGIN

    master : i2c_master
    GENERIC MAP(
        input_clk => CLOCK_FREQ,
        bus_clk => BUS_CLK
    )
    PORT MAP(
        clk => clk_tb,
        reset_n => reset_n_tb,
        ena => ena_tb,
        addr => addr_tb,
        rw => rw_tb,
        data_wr => data_wr_tb,
        busy => busy_tb,
        data_rd => data_rd_tb,
        ack_error => ack_error_tb,
        sda => sda_tb,
        scl => scl_tb,
        clk_data => data_clk_tb
    );

    slave : I2C_minion
    GENERIC MAP(
        MINION_ADDR => "0000011"
    )
    PORT MAP(
        scl => scl_tb,
        sda => sda_tb,
        clk => clk_tb,
        reset_n => reset_n_tb,
        -- User interface
        read_req => read_req_tb,
        data_to_master => data_to_master_tb,
        data_valid => data_valid_tb,
        data_from_master => data_from_master_tb
    );

    slave2 : I2C_minion
    GENERIC MAP(
        MINION_ADDR => "0000111"
    )
    PORT MAP(
        scl => scl_tb,
        sda => sda_tb,
        clk => clk_tb,
        reset_n => reset_n_tb,
        -- User interface
        read_req => read_req_tb2,
        data_to_master => data_to_master_tb2,
        data_valid => data_valid_tb2,
        data_from_master => data_from_master_tb2
    );
    clock_generation : PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR CLOCK_HALF_PERIOD;
        clk_tb <= '1';
        WAIT FOR CLOCK_HALF_PERIOD;
    END PROCESS;

    -- reset generation
    reset_n_tb <= '0', '1' AFTER 2 * CLOCK_PERIOD;

    TESTS : PROCESS
    BEGIN
        -- write once to slave with correct address 0000011
        WAIT UNTIL falling_edge(busy_tb);
        transmit_once(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb);
        -- transmit_three_same(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb);
        -- transmit_two_different(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb);
        -- read_once(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb, data_to_master_tb);
        -- read_twice_same(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb, data_to_master_tb, read_req_tb);
        -- read_two_different(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb, data_to_master_tb, data_to_master_tb2, read_req_tb);
        -- write_then_read(data_wr_tb, addr_tb, rw_tb, ena_tb, busy_tb, data_to_master_tb, data_to_master_tb2, read_req_tb);
        WAIT;

    END PROCESS;
END ARCHITECTURE tb;