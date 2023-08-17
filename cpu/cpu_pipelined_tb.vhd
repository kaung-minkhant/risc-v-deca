library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_pipelined_tb is
end cpu_pipelined_tb;

architecture sim of cpu_pipelined_tb is

    component cpu_pipelined IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32
        );
        PORT (
          -- data memory exports
           general_pin_dir: inout std_logic_vector(15 downto 0);
           general_pin_out: inout std_logic_vector(15 downto 0);
           general_pin_in: inout std_logic_vector(15 downto 0);

            reset_n, clk: std_logic
        );
    END component;

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
        i2c1_controls : inout std_logic_vector(7 downto 0);

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
    constant CLK_PERIOD : time := 100 ps;
    constant CLK_HALF_PERIOD : time :=  CLK_PERIOD / 2;

    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';

    signal general_pin_dir, general_pin_out, general_pin_in : std_logic_vector(15 downto 0) := (others => '0');
    signal uart1_controls, spi1_controls, i2c1_controls, uart1_data_out, spi1_data_in, spi1_data_out, i2c1_data_in, i2c1_data_out : std_logic_vector(7 downto 0) := (others => '0');
    signal uart1_data_in, uart1_data_out_32 : std_logic_vector(31 downto 0) := (others => '0');
    signal i2c1_addr : std_logic_vector(6 downto 0) := (others => '0');

    constant DATA_WIDTH : integer := 32;

begin

    clk <= not clk after CLK_HALF_PERIOD;

    reset_n <= '1' after 5*CLK_PERIOD;

    DUT : entity work.cpu_pipelined(rtl)
    generic map (
        DATA_WIDTH =>  DATA_WIDTH
    )
    port map (
        clk => clk,
        reset_n => reset_n,
        general_pin_in => general_pin_in, general_pin_out => general_pin_out, general_pin_dir => general_pin_dir
    );



    IO_u : io 
    port map(
      clk => clk, reset_n => reset_n,
      general_io_dir => general_pin_dir, general_io_data_out => general_pin_out, general_io_data_in => general_pin_in,
      uart1_controls => uart1_controls, uart1_data_in => uart1_data_in, uart1_data_out => uart1_data_out, uart1_data_out_32 => uart1_data_out_32,
      spi1_controls => spi1_controls, spi1_data_in => spi1_data_in, spi1_data_out => spi1_data_out,
      i2c1_controls => i2c1_controls, i2c1_addr => i2c1_addr, i2c1_data_in => i2c1_data_in, i2c1_data_out => i2c1_data_out
    );

end architecture;
