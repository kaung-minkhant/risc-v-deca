library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart is
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
end entity uart;

architecture rtl of uart is
  constant count_per_bit : natural := input_clock_frequency/baudrate;
  component uart_tx is
    generic (
      count_per_bit : natural := 20 -- clock per bit
    );
    port (
      clk, send : in std_logic;
      data_in : in std_logic_vector(31 downto 0);
      tx_busy, tx, tx_done : out std_logic
    );
  end component;

  component uart_rx is
    generic (
      count_per_bit : natural := 20 -- clock per bit
    );
    port (
      rx, clk : in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      data_out_32 : out std_logic_vector(31 downto 0);
      rx_busy, rx_done : out std_logic;
      mode32 : in std_logic;
      frame_error : out std_logic
    );
  end component;
begin

  tx_u : uart_tx
  generic map(
    count_per_bit => count_per_bit
  )
  port map(
    clk => clk, send => tx_start, data_in => data_in,
    tx_busy => tx_busy, tx => uart_tx_line, tx_done => tx_done
  );

  rx_u : uart_rx
  generic map(
    count_per_bit => count_per_bit
  )
  port map(
    rx => uart_rx_line, clk => clk, data_out => data_out,
    rx_busy => rx_busy, rx_done => rx_done, data_out_32 => data_out_32, mode32 => rx_mode_32, frame_error => frame_error
  );

end architecture rtl;