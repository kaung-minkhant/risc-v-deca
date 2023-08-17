library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tb is
end entity uart_tb;

architecture tb of uart_tb is
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

  signal data_in_tb : std_logic_vector(31 downto 0) := x"00000000";
  signal clk_tb : std_logic := '0';
  signal tx_start_tb : std_logic := '0';
  signal uart_rx_line_tb : std_logic := '1';
  signal uart_tx_line_tb : std_logic := '1';
  signal tx_busy_tb, rx_busy_tb, tx_done_tb, rx_done_tb : std_logic := '1';
  signal data_out_tb : std_logic_vector(7 downto 0) := x"00";
  signal rx_mode_32_tb : std_logic := '0';
  signal frame_error_tb : std_logic := '0';
  signal data_out_32_tb : std_logic_vector(31 downto 0) := x"00000000";
  signal signal_source_tb : std_logic := '0';

  signal loop_signal_tb : std_logic;
  procedure transmit(
    variable tx_value : in std_logic_vector(31 downto 0);
    signal tx_done : in std_logic;
    signal data_in : out std_logic_vector(31 downto 0);
    signal rx_mode_32 : out std_logic;
    signal tx_start : out std_logic;
    variable mode_32_on : in std_logic) is
  begin
    wait for 100 ps;
    data_in <= tx_value;
    if (mode_32_on = '0') then
      rx_mode_32 <= '0';
    elsif (mode_32_on = '1') then
      rx_mode_32 <= '1';
    end if;

    tx_start <= '0';
    wait for 100 ps;
    tx_start <= '1';
    wait for 50 ps;
    tx_start <= '0';
    wait until rising_edge(tx_done);
  end procedure;

  procedure transmit_same_twice(
    signal tx_done : in std_logic;
    signal data_in : out std_logic_vector(31 downto 0);
    signal rx_mode_32 : out std_logic;
    signal tx_start : out std_logic;
    variable mode_32 : in std_logic
  ) is
    variable value : std_logic_vector(31 downto 0);
  begin
    value := x"ff11ff35";
    transmit(value, tx_done, data_in, rx_mode_32, tx_start, mode_32);
    value := x"ff11ff35";
    transmit(value, tx_done, data_in, rx_mode_32, tx_start, mode_32);
  end procedure;

  procedure transmit_different(
    signal tx_done : in std_logic;
    signal data_in : out std_logic_vector(31 downto 0);
    signal rx_mode_32 : out std_logic;
    signal tx_start : out std_logic;
    variable mode_32 : in std_logic
  ) is
    variable value : std_logic_vector(31 downto 0);
  begin
    value := x"ff11ff35";
    transmit(value, tx_done, data_in, rx_mode_32, tx_start, mode_32);
    value := x"01824f35";
    transmit(value, tx_done, data_in, rx_mode_32, tx_start, mode_32);
  end procedure;

  procedure transmit_series(
    variable data : in std_logic_vector(7 downto 0);
    signal tx : out std_logic
  ) is
    constant one_cycle : time := 40 ps;
  begin
    for index in 0 to 7 loop
      tx <= data(index);
      wait for one_cycle;
    end loop;

  end procedure;

  procedure framerate_testing(
    signal tx_signal : out std_logic
  ) is
    constant one_cycle : time := 40 ps;
    variable data_to_transmit : std_logic_vector(7 downto 0);
  begin
    -- no frame error
    -- idle
    tx_signal <= '1';
    wait for 100 ps;
    -- start bit
    tx_signal <= '0';
    wait for one_cycle;
    -- data
    data_to_transmit := "01010101";
    transmit_series(data_to_transmit, tx_signal);
    -- stop bit and idle
    tx_signal <= '1';
    wait for 300 ps;

    -- start bit frame error
    -- data
    data_to_transmit := "01011101";
    transmit_series(data_to_transmit, tx_signal);
    -- stop bit and idle
    tx_signal <= '1';
    wait for 300 ps;

    --stop bit frame error
    -- start bit
    tx_signal <= '0';
    wait for one_cycle;
    -- data
    data_to_transmit := "01010101";
    transmit_series(data_to_transmit, tx_signal);
    wait for 300 ps;
  end procedure;

begin
  -- set 'uart_tx_line_tb' for normal testing
  -- set 'signal_source_tb' for frame error testing
  loop_signal_tb <= signal_source_tb;

  DUT : uart
  generic map(
    input_clock_frequency => 10e6,
    baudrate => 5e6
  )
  port map(
    data_in => data_in_tb, tx_start => tx_start_tb, clk => clk_tb,
    uart_rx_line => loop_signal_tb, uart_tx_line => uart_tx_line_tb,
    tx_busy => tx_busy_tb, rx_busy => rx_busy_tb, tx_done => tx_done_tb,
    rx_done => rx_done_tb, data_out => data_out_tb,
    data_out_32 => data_out_32_tb, rx_mode_32 => rx_mode_32_tb, frame_error => frame_error_tb
  );

  clock_gen : process is
  begin
    wait for 10 ps;
    clk_tb <= not clk_tb;
  end process;

  input_gen : process is
    variable value : std_logic_vector(31 downto 0);
    variable mode_32 : std_logic;
  begin
    mode_32 := '0';
    -- transmit_same_twice(tx_done_tb, data_in_tb, rx_mode_32_tb, tx_start_tb, mode_32);
    framerate_testing(signal_source_tb);
    wait for 500 ps;
    assert (FALSE) report "Simulation end." severity failure;
  end process;

end architecture tb;