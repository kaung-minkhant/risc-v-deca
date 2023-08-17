library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity io is
  generic (
    FREQ: integer:= 50_000_000
  );
  port (
    -- external
    general_io : inout std_logic_vector(15 downto 0);
    special_io : inout std_logic_vector(15 downto 0);

    -- general io controls
    general_io_dir : in std_logic_vector(15 downto 0);

    -- generation io data
    general_io_data_in : in std_logic_vector(15 downto 0);
    general_io_data_out : out std_logic_vector(15 downto 0);

    -- special io controls
    uart1_controls : in std_logic_vector(7 downto 0);
    uart1_flags : out std_logic_vector(7 downto 0);
    spi1_controls : in std_logic_vector(7 downto 0);
    spi1_flags : out std_logic_vector(7 downto 0);
    i2c1_controls : in std_logic_vector(7 downto 0);
    i2c1_flags : out std_logic_vector(7 downto 0);

    -- special io data
    uart1_data_in : in std_logic_vector(31 downto 0);
    uart1_data_out : out std_logic_vector(7 downto 0);
    uart1_data_out_32 : out std_logic_vector(31 downto 0);

    spi1_data_in : in std_logic_vector(7 downto 0);
    spi1_data_out : out std_logic_vector(7 downto 0);

    i2c1_data_in : in std_logic_vector(7 downto 0);
    i2c1_data_out : out std_logic_vector(7 downto 0);
    i2c1_addr : in std_logic_vector(6 downto 0);

    -- clock and reset
    clk, clk_main : in std_logic;
    reset_n : in std_logic
  );
end io;
-- special pin mapping
--  0 : uart1 rx 
--  1 : uart1 tx
--  2 : spi1 clk
--  3 : spi1 miso
--  4 : spi1 mosi
architecture arch of io is

  constant UART1_RX : integer := 0;
  constant UART1_TX : integer := 1;
  constant SPI1_CLK : integer := 2;
  constant SPI1_MISO : integer := 3;
  constant SPI1_MOSI : integer := 4;
  constant I2C1_SDA : integer := 5;
  constant I2C1_SCL : integer := 6;

  component iopin is
    port (
      -- external
      pin : inout std_logic;

      -- data transfer
      data_in : in std_logic;
      data_out : out std_logic;

      -- controls, clock and reset
      dir_control : in std_logic;
      clk : in std_logic;
      reset_n : in std_logic
    );
  end component;

  component uart_container is
    generic (
      input_clock_frequency : natural := 10e6;
      baudrate : natural := 10e5
    );
    port (
      -- line interface
      rx : in std_logic;
      tx : out std_logic;

      -- control and flag interface
      -- 7  6           5       4       3       2       1           0
      -- x  frame_error rx_done rx_busy tx_done tx_busy rx_mode_32  tx_start
      control : in std_logic_vector(7 downto 0);
      flags : buffer std_logic_vector(7 downto 0);

      -- clock
      clk : in std_logic;

      -- data
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(7 downto 0);
      data_out_32 : out std_logic_vector(31 downto 0)
    );
  end component;

  component spi_master_container is
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
      data_out : buffer std_logic_vector(7 downto 0);

      -- control and flags
      -- 0 : tx_dv
      -- 0 : tx_ready
      -- 1 : rx_dv
      controls : in std_logic_vector(7 downto 0);
      flags : out std_logic_vector(7 downto 0);

      -- spi interface
      spi_clk : out std_logic;
      spi_miso : in std_logic;
      spi_mosi : out std_logic
    );
  end component;

  component i2c_master_container is
    generic (
      input_clk : integer := 50e6; --input clock speed from user logic in Hz
      bus_clk : integer := 10e6); --speed the i2c bus (scl) will run at in Hz
    port (
      -- clock and resets
      clk : in std_logic;
      reset_n : in std_logic;

      -- data and address
      addr : in std_logic_vector(6 downto 0); --address of target slave
      data_in : in std_logic_vector(7 downto 0); --data to write to slave
      data_out : out std_logic_vector(7 downto 0); --data read from slave

      -- control
      --  0 : ena
      --  1 : rw ('0' is write, '1' is read)
      --  0 : busy
      --  1 : ack_error
      controls : in std_logic_vector(7 downto 0);
      flags : buffer std_logic_vector(7 downto 0);

      -- i2c interface
      sda : inout std_logic; --serial data output of i2c bus
      scl : inout std_logic; --serial clock output of i2c bus

      -- debugging
      clk_data : out std_logic
    );
  end component;
begin
  IOPIN_GEN : for i in 0 to general_io'length - 1 generate
    iopinx : iopin port map(
      pin => general_io(i), data_in => general_io_data_in(i), data_out => general_io_data_out(i),
      dir_control => general_io_dir(i), clk => clk, reset_n => reset_n
    );
  end generate;

  UART1 : uart_container
  generic map(
    input_clock_frequency => FREQ,
    baudrate => 1_000
  )
  port map(
    rx => special_io(UART1_RX), tx => special_io(UART1_TX), control => uart1_controls, flags => uart1_flags,
    clk => clk_main, data_in => uart1_data_in, data_out => uart1_data_out, data_out_32 => uart1_data_out_32
  );

  SPI1 : spi_master_container
  generic map(
    SPI_MODE => 0,
    INPUT_CLK => FREQ,
    BUS_CLK => 25e6
  )
  port map(
    clk => clk, reset_n => reset_n,
    data_in => spi1_data_in, data_out => spi1_data_out,
    controls => spi1_controls, flags => spi1_flags,
    spi_clk => special_io(SPI1_CLK), spi_miso => special_io(SPI1_MISO), spi_mosi => special_io(SPI1_MOSI)
  );

  I2C1 : i2c_master_container
  generic map(
    input_clk => FREQ,
    bus_clk => 10e6
  )
  port map(
    clk => clk, reset_n => reset_n,
    addr => i2c1_addr, data_in => i2c1_data_in, data_out => i2c1_data_out,
    controls => i2c1_controls, flags => i2c1_flags,
    sda => special_io(I2C1_SDA), scl => special_io(I2C1_SCL)
  );

end architecture;