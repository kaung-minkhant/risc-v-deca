library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microcontroller is
    port (
        clk, reset_n : in std_logic;

        general_io : inout std_logic_vector(15 downto 0);
        special_io : inout std_logic_vector(15 downto 0)
    );
end microcontroller;

architecture rtl of microcontroller is

    constant DATA_WIDTH: integer := 32;

    component cpu_pipelined IS
    GENERIC (
      DATA_WIDTH : INTEGER := 32;
      OPERATION_WIDTH : integer := 3
    );
    PORT (
        -- data memory exports
        general_pin_dir: out std_logic_vector(15 downto 0);
        general_pin_write: out std_logic_vector(15 downto 0);
        general_pin_read: in std_logic_vector(15 downto 0);

        -- uart1
        uart1_flags: in std_logic_vector(7 downto 0);
        uart1_controls: out std_logic_vector(7 downto 0);
        uart1_data_write : out std_logic_vector(31 downto 0); 
        uart1_data_read : in std_logic_vector(7 downto 0);
        uart1_data_32_read : in std_logic_vector(31 downto 0);

        -- spi1
        spi1_flags: in std_logic_vector(7 downto 0);
        spi1_controls: out std_logic_vector(7 downto 0);
        spi1_data_write: out std_logic_vector(7 downto 0);
        spi1_data_read: in std_logic_vector(7 downto 0);

        -- i2c1
        i2c1_flags : in std_logic_vector(7 downto 0);
        i2c1_controls: out std_logic_vector(7 downto 0);
        i2c1_data_read : in std_logic_vector(7 downto 0);
        i2c1_data_write : out std_logic_vector(7 downto 0);
        i2c1_addr_write: out std_logic_vector(6 downto 0);

        reset_n, clk: std_logic
    );
END component;
signal general_pin_dir, general_pin_write, general_pin_read: std_logic_vector(15 downto 0) := (others => '0');

signal uart1_controls, uart1_flags, uart1_data_read : std_logic_vector(7 downto 0) := (others => '0');
signal uart1_data_write, uart1_data_32_read : std_logic_vector(31 downto 0) := (others => '0');

signal spi1_controls, spi1_flags, spi1_data_write, spi1_data_read : std_logic_vector(7 downto 0) := (others => '0');

signal i2c1_controls, i2c1_flags, i2c1_data_write, i2c1_data_read : std_logic_vector(7 downto 0) := (others => '0');
signal i2c1_addr_write : std_logic_vector(6 downto 0) := (others => '0');

component io is
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
      clk : in std_logic;
      reset_n : in std_logic
    );
  end component;
begin

    cpu: cpu_pipelined
    generic map (
        DATA_WIDTH => DATA_WIDTH, OPERATION_WIDTH => 3
    ) port map (
        reset_n => reset_n, clk => clk,
        general_pin_dir => general_pin_dir, general_pin_read => general_pin_read, general_pin_write => general_pin_write,
        uart1_controls => uart1_controls, uart1_flags => uart1_flags,
        uart1_data_write => uart1_data_write, uart1_data_read => uart1_data_read, uart1_data_32_read => uart1_data_32_read,
        spi1_controls => spi1_controls, spi1_flags => spi1_flags,
        spi1_data_write => spi1_data_write, spi1_data_read => spi1_data_read,
        i2c1_controls => i2c1_controls, i2c1_flags => i2c1_flags,
        i2c1_data_write => i2c1_data_write, i2c1_data_read => i2c1_data_read, i2c1_addr_write => i2c1_addr_write
    );

    io_u: io
    port map(
        clk => clk, reset_n => reset_n,
        general_io => general_io, special_io => special_io,
        general_io_dir => general_pin_dir, general_io_data_in => general_pin_write, general_io_data_out => general_pin_read,
        uart1_controls => uart1_controls, uart1_flags => uart1_flags,
        uart1_data_in => uart1_data_write, uart1_data_out => uart1_data_read, uart1_data_out_32 => uart1_data_32_read,
        spi1_controls => spi1_controls, spi1_flags => spi1_flags,
        spi1_data_in => spi1_data_write, spi1_data_out => spi1_data_read,
        i2c1_controls => i2c1_controls, i2c1_flags => i2c1_flags,
        i2c1_data_in => i2c1_data_write, i2c1_data_out => i2c1_data_read, i2c1_addr => i2c1_addr_write
    );

end architecture;