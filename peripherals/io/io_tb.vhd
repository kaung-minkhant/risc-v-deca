library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity io_tb is
end io_tb;

architecture arch of io_tb is
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
      uart1_controls : inout std_logic_vector(7 downto 0);
      spi1_controls : inout std_logic_vector(7 downto 0);
      -- special io data
      uart1_data_in : in std_logic_vector(31 downto 0);
      uart1_data_out : out std_logic_vector(7 downto 0);
      uart1_data_out_32 : out std_logic_vector(31 downto 0);

      spi1_data_in : in std_logic_vector(7 downto 0);
      spi1_data_out : out std_logic_vector(7 downto 0);
      -- clock and reset
      clk : in std_logic;
      reset_n : in std_logic
    );
  end component;
  signal general_io, special_io, general_io_data_in, general_io_data_out, general_io_dir : std_logic_vector(15 downto 0) := (others => '0');
  signal uart1_controls, spi1_controls, uart1_data_out, spi1_data_in, spi1_data_out : std_logic_vector(7 downto 0) := (others => '0');
  signal uart1_data_in, uart1_data_out_32 : std_logic_vector(31 downto 0) := (others => '0');
  signal clk, reset_n : std_logic := '0';
begin

  io_module : io port map(
    general_io,
    special_io,
    -- general io controls
    general_io_dir,
    -- generation io data
    general_io_data_in,
    general_io_data_out,
    -- special io controls
    uart1_controls,
    spi1_controls,
    -- special io data
    uart1_data_in,
    uart1_data_out,
    uart1_data_out_32,
    spi1_data_in,
    spi1_data_out,
    -- clock and reset
    clk,
    reset_n
  );

  special_io(0) <= special_io(1);

end architecture;