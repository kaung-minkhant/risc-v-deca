library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master_container is
  generic (
    SPI_MODE : integer := 0;
    INPUT_CLK : integer := 100e6;
    BUS_CLK : integer := 25e6
    -- CLKS_PER_HALF_BIT : INTEGER := 2
  );
  port (
    -- clock and resets
    clk : in std_logic;
    reset_n : in std_logic;

    -- data
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);

    -- control and flags
    -- 0 : tx_dv
    -- 1 : tx_ready
    -- 2 : rx_dv
    controls : in std_logic_vector(7 downto 0);
    flags : buffer std_logic_vector(7 downto 0);

    -- spi interface
    spi_clk : out std_logic;
    spi_miso : in std_logic;
    spi_mosi : out std_logic
  );
end spi_master_container;

architecture arch of spi_master_container is

  constant TX_DV_C : integer := 0;
  constant TX_READY_C : integer := 0;
  constant RX_DV_C : integer := 1;

  component spi_master is
    generic (
      SPI_MODE : integer := 0;
      INPUT_CLK : integer := 50e6;
      BUS_CLK : integer := 25e6
      -- CLKS_PER_HALF_BIT : INTEGER := 2
    );
    port (
      -- Control/Data Signals,
      reset_n : in std_logic; -- FPGA Reset
      clk : in std_logic; -- FPGA Clock

      -- TX (MOSI) Signals
      i_TX_Byte : in std_logic_vector(7 downto 0); -- Byte to transmit on MOSI
      i_TX_DV : in std_logic; -- Data Valid Pulse with i_TX_Byte
      o_TX_Ready : buffer std_logic; -- Transmit Ready for next byte

      -- RX (MISO) Signals
      o_RX_DV : out std_logic; -- Data Valid pulse (1 clock cycle)
      o_RX_Byte : out std_logic_vector(7 downto 0); -- Byte received on MISO

      -- SPI Interface
      o_SPI_Clk : out std_logic;
      i_SPI_MISO : in std_logic;
      o_SPI_MOSI : out std_logic
    );
  end component;

begin

  SPI_MASTER_MODULE : spi_master
  generic map(
    SPI_MODE => SPI_MODE,
    INPUT_CLK => INPUT_CLK,
    BUS_CLK => BUS_CLK
  )
  port map(
    clk => clk, reset_n => reset_n,
    i_TX_Byte => data_in, o_RX_Byte => data_out,
    i_TX_DV => controls(TX_DV_C), o_TX_Ready => flags(TX_READY_C), o_RX_DV => flags(RX_DV_C),
    o_SPI_Clk => spi_clk, i_SPI_MISO => spi_miso, o_SPI_MOSI => spi_mosi
  );

end architecture;