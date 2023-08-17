library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_container_tb is
end uart_container_tb;

architecture arch of uart_container_tb is
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
      control : inout std_logic_vector(7 downto 0);

      -- clock
      clk : in std_logic;

      -- data
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(7 downto 0);
      data_out_32 : out std_logic_vector(31 downto 0)
    );
  end component;
  signal rx, tx, clk : std_logic;
  signal control, data_out : std_logic_vector(7 downto 0) := (others => '0');
  signal data_in, data_out_32 : std_logic_vector(31 downto 0) := (others => '0');
begin

  container : uart_container port map(
    rx, tx, control, clk, data_in, data_out, data_out_32
  );

  rx <= tx;

end architecture;