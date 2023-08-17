library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_container is
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
end uart_container;

architecture arch of uart_container is
  constant TX_START_C : integer := 0;
  constant RX_MODE_32_C : integer := 1;
  constant TX_BUSY_C : integer := 0;
  constant TX_DONE_C : integer := 1;
  constant RX_BUSY_C : integer := 2;
  constant RX_DONE_C : integer := 3;
  constant FRAME_ERROR_C : integer := 4;

  component uart is
    generic (
      input_clock_frequency : natural := 10e6;
      baudrate : natural := 10e5
    );
    port (
      -- clock and resets
      clk : in std_logic;

      -- data related
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(7 downto 0);
      data_out_32 : out std_logic_vector(31 downto 0);

      -- control related
      tx_start : in std_logic;
      rx_mode_32 : in std_logic;

      -- flags
      tx_busy, rx_busy, tx_done, rx_done : out std_logic;
      frame_error : out std_logic;

      -- module interface
      uart_rx_line : in std_logic;
      uart_tx_line : out std_logic
    );
  end component;

  signal tx_buffer : std_logic := '0';
begin

  UART_MODULE : uart
  generic map (
    input_clock_frequency => input_clock_frequency,
    baudrate => baudrate
  )
  port map(
    clk => clk, data_in => data_in, data_out => data_out, data_out_32 => data_out_32,
    uart_rx_line => rx, uart_tx_line => tx,
    tx_start => control(TX_START_C), rx_mode_32 => control(RX_MODE_32_C),
    tx_busy => flags(TX_BUSY_C), tx_done => flags(TX_DONE_C),
    rx_busy => flags(RX_BUSY_C), rx_done => flags(RX_DONE_C),
    frame_error => flags(FRAME_ERROR_C)
  );
end architecture;