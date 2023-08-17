library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master_container is
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
    --  2 : busy
    --  3 : ack_error
    controls : in std_logic_vector(7 downto 0);
    flags : buffer std_logic_vector(7 downto 0);

    -- i2c interface
    sda : inout std_logic; --serial data output of i2c bus
    scl : inout std_logic; --serial clock output of i2c bus

    -- debugging
    clk_data : out std_logic
  );
end i2c_master_container;

architecture arch of i2c_master_container is
  constant ENA_C : integer := 0;
  constant RW_C : integer := 1;
  constant BUSY_C : integer := 0;
  constant ACK_ERROR_C : integer := 1;

  component i2c_master is
    generic (
      input_clk : integer := 50e6; --input clock speed from user logic in Hz
      bus_clk : integer := 10e6); --speed the i2c bus (scl) will run at in Hz
    port (
      clk : in std_logic; --system clock
      reset_n : in std_logic; --active low reset
      ena : in std_logic; --latch in command
      addr : in std_logic_vector(6 downto 0); --address of target slave
      rw : in std_logic; --'0' is write, '1' is read
      data_wr : in std_logic_vector(7 downto 0); --data to write to slave
      busy : out std_logic; --indicates transaction in progress
      data_rd : out std_logic_vector(7 downto 0); --data read from slave
      ack_error : buffer std_logic; --flag if improper acknowledge from slave
      sda : inout std_logic; --serial data output of i2c bus
      scl : inout std_logic; --serial clock output of i2c bus
      clk_data : out std_logic);
  end component;
begin
  i2c_master_module : i2c_master
  generic map(
    input_clk => input_clk, bus_clk => bus_clk
  )
  port map(
    clk => clk, reset_n => reset_n,
    addr => addr, data_rd => data_out, data_wr => data_in,
    ena => controls(ENA_C), rw => controls(RW_C), busy => flags(BUSY_C), ack_error => flags(ACK_ERROR_C),
    sda => sda, scl => scl,
    clk_data => clk_data
  );

end architecture;