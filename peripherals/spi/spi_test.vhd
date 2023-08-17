------------------------------------------------------------------------------/
-- Description:       Simple test bench for SPI Master module
------------------------------------------------------------------------------/
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spi_test IS
END ENTITY spi_test;

ARCHITECTURE TB OF spi_test IS
  COMPONENT spi_master IS
    GENERIC (
      SPI_MODE : INTEGER := 0;
      INPUT_CLK : INTEGER := 50e6;
      BUS_CLK : INTEGER := 25e6
    );
    PORT (
      -- Control/Data Signals,
      reset_n : IN STD_LOGIC; -- FPGA Reset
      clk : IN STD_LOGIC; -- FPGA Clock

      -- TX (MOSI) Signals
      i_TX_Byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Byte to transmit on MOSI
      i_TX_DV : IN STD_LOGIC; -- Data Valid Pulse with i_TX_Byte
      o_TX_Ready : BUFFER STD_LOGIC; -- Transmit Ready for next byte

      -- RX (MISO) Signals
      o_RX_DV : OUT STD_LOGIC; -- Data Valid pulse (1 clock cycle)
      o_RX_Byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Byte received on MISO

      -- SPI Interface
      o_SPI_Clk : OUT STD_LOGIC;
      i_SPI_MISO : IN STD_LOGIC;
      o_SPI_MOSI : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT spi_slave IS
    PORT (
      clk : IN STD_LOGIC; --spi clk from master
      data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      rx_dv : IN STD_LOGIC;
      reset_n : IN STD_LOGIC; --active low reset
      ss_n : IN STD_LOGIC; --active low slave select
      mosi : IN STD_LOGIC; --master out, slave in
      miso : OUT STD_LOGIC;
      rx_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    ); --master in, slave out 
  END COMPONENT;

  SIGNAL reset_n_tb : STD_LOGIC := '0'; -- FPGA Reset
  SIGNAL clk_tb : STD_LOGIC := '0'; -- FPGA Clock

  -- TX (MOSI) Signals
  SIGNAL i_TX_Byte_tb : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Byte to transmit on MOSI
  SIGNAL i_TX_DV_tb : STD_LOGIC := '0'; -- Data Valid Pulse with i_TX_Byte
  SIGNAL o_TX_Ready_tb : STD_LOGIC := '0'; -- Transmit Ready for next byte

  -- RX (MISO) Signals
  SIGNAL o_RX_DV_tb : STD_LOGIC := '0'; -- Data Valid pulse (1 clock cycle)
  SIGNAL o_RX_Byte_tb : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Byte received on MISO

  -- SPI Interface
  SIGNAL o_SPI_Clk_tb : STD_LOGIC := '0';
  SIGNAL i_SPI_MISO_tb : STD_LOGIC := '0';
  SIGNAL o_SPI_MOSI_tb : STD_LOGIC := '0';

  SIGNAL data_wr_tb : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ss_n_tb : STD_LOGIC := '1'; --active low slave select
  SIGNAL rx_data_tb : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

  CONSTANT INPUT_CLK : INTEGER := 50e6;
  CONSTANT BUS_CLK : INTEGER := 25e6;
  CONSTANT SPI_MODE : INTEGER := 0;

  CONSTANT CLOCK_HALF_PERIOD : TIME := 10 ps;
  CONSTANT CLOCK_PERIOD : TIME := 2 * CLOCK_HALF_PERIOD;

  PROCEDURE transmit_once(
    SIGNAL tx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_dv : OUT STD_LOGIC;
    SIGNAL tx_ready : IN STD_LOGIC;
    SIGNAL ss_n : OUT STD_LOGIC
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(tx_ready);
    WAIT FOR 2 * CLOCK_PERIOD;
    tx_byte <= x"56";
    WAIT FOR 3 * CLOCK_HALF_PERIOD;
    ss_n <= '0';
    tx_dv <= '1';
    WAIT UNTIL falling_edge(tx_ready);
    tx_dv <= '0';
    WAIT UNTIL rising_edge(tx_ready);
    ss_n <= '1';
  END PROCEDURE;

  PROCEDURE read_once(
    SIGNAL tx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_dv : OUT STD_LOGIC;
    SIGNAL tx_ready : IN STD_LOGIC;
    SIGNAL ss_n : OUT STD_LOGIC;
    SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(tx_ready);
    WAIT FOR 2 * CLOCK_PERIOD;
    tx_byte <= x"55";
    data_wr <= x"98";
    WAIT FOR 3 * CLOCK_HALF_PERIOD;
    ss_n <= '0';
    tx_dv <= '1';
    WAIT UNTIL falling_edge(tx_ready);
    tx_dv <= '0';
    WAIT UNTIL rising_edge(tx_ready);
    ss_n <= '1';
  END PROCEDURE;

  PROCEDURE transmit_twice(
    SIGNAL tx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_dv : OUT STD_LOGIC;
    SIGNAL tx_ready : IN STD_LOGIC;
    SIGNAL ss_n : OUT STD_LOGIC
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(tx_ready);
    WAIT FOR 2 * CLOCK_PERIOD;
    tx_byte <= x"56";
    WAIT FOR 3 * CLOCK_HALF_PERIOD;
    ss_n <= '0';
    tx_dv <= '1';
    WAIT UNTIL falling_edge(tx_ready);
    tx_dv <= '0';
    tx_byte <= x"65";
    WAIT UNTIL rising_edge(tx_ready);
    tx_dv <= '1';
    WAIT UNTIL falling_edge(tx_ready);
    -- WAIT FOR CLOCK_PERIOD;
    tx_dv <= '0';

    -- ss_n <= '1';
  END PROCEDURE;

  PROCEDURE read_twice(
    SIGNAL tx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_dv : OUT STD_LOGIC;
    SIGNAL tx_ready : IN STD_LOGIC;
    SIGNAL ss_n : OUT STD_LOGIC;
    SIGNAL data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(tx_ready);
    WAIT FOR 2 * CLOCK_PERIOD;
    tx_byte <= x"55";
    data_wr <= x"98";
    WAIT FOR 3 * CLOCK_HALF_PERIOD;
    ss_n <= '0';
    tx_dv <= '1';
    WAIT UNTIL falling_edge(tx_ready);
    tx_dv <= '0';
    tx_byte <= x"55";
    data_wr <= x"AB";
    WAIT UNTIL rising_edge(tx_ready);
    ss_n <= '1';
  END PROCEDURE;
BEGIN -- architecture TB

  controller : spi_master
  GENERIC MAP(
    SPI_MODE => SPI_MODE,
    INPUT_CLK => INPUT_CLK,
    BUS_CLK => BUS_CLK
  )
  PORT MAP(
    reset_n_tb, clk_tb,
    i_TX_Byte_tb, i_TX_DV_tb,
    o_TX_Ready_tb, o_RX_DV_tb,
    o_RX_Byte_tb,
    o_SPI_Clk_tb, i_SPI_MISO_tb, o_SPI_MOSI_tb
  );

  peripheral : spi_slave
  PORT MAP(
    o_SPI_Clk_tb, data_wr_tb,
    o_RX_DV_tb, reset_n_tb, ss_n_tb,
    o_SPI_MOSI_tb, i_SPI_MISO_tb,
    rx_data_tb
  );

  CLOCK_GEN_PROC : PROCESS IS
  BEGIN
    WAIT FOR CLOCK_HALF_PERIOD;
    clk_tb <= NOT clk_tb;
  END PROCESS;

  reset_n_tb <= '0', '1' AFTER 4 * CLOCK_PERIOD;

  TESTINGS_PROC : PROCESS IS
  BEGIN
    -- transmit_once(i_TX_Byte_tb, i_TX_DV_tb, o_TX_Ready_tb, ss_n_tb);
    -- transmit_twice(i_TX_Byte_tb, i_TX_DV_tb, o_TX_Ready_tb, ss_n_tb);
    read_once(i_TX_Byte_tb, i_TX_DV_tb, o_TX_Ready_tb, ss_n_tb, data_wr_tb);
    WAIT;
  END PROCESS;

END ARCHITECTURE TB;