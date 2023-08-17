library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_deca is
    generic (
        FREQ : integer := 50_000_000
    );
    port (
        ADC_CLK_10, MAX10_CLK1_50, MAX10_CLK2_50: in std_logic;
        general_io : inout std_logic_vector(15 downto 0);
        special_io : inout std_logic_vector(15 downto 0);
        LED: out std_logic_vector(7 downto 0);
        SW: in std_logic_vector(1 downto 0)
    );
end cpu_deca;

architecture rtl of cpu_deca is
    component clk_divider is
        generic (
            FREQ: integer := 50_000_000;
            O_FREQ: integer := 1
        );
        port (
            clk : in std_logic;
            reset_n : in std_logic;
            clk_o: out std_logic
        );
    end component;

    component cpu_pipelined IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            OPERATION_WIDTH : integer := 3
        );
        PORT (
            rs_debug : out std_logic_vector(31 downto 0);
            branch_debug, branch_condition_debug: out std_logic;
            pc_addr_debug, rs1_branch_debug, rs2_branch_debug : out std_logic_vector(31 downto 0);
            forward_branch_debug : out std_logic_vector(2 downto 0);
            added_address_debug, rd_ex_debug : out std_logic_vector(31 downto 0);
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

            reset_n, clk, clk_main: std_logic
        );
    END component;

    component io is
        generic(
            FREQ: integer := 50_000_000
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
      end component;
    signal reset_n, clk, clk_main : std_logic := '0';
    signal general_pin_dir, general_pin_write, general_pin_read: std_logic_vector(15 downto 0) := (others => '0');
    -- signal special_io : std_logic_vector(15 downto 0) := (others => '0');

    -- uart1
    signal uart1_flags, uart1_controls, uart1_data_read: std_logic_vector(7 downto 0) := (others => '0');
    signal uart1_data_write, uart1_data_32_read : std_logic_vector(31 downto 0) := (others => '0');

    -- spi1
    signal spi1_flags, spi1_controls, spi1_data_write, spi1_data_read: std_logic_vector(7 downto 0) := (others => '0');

    -- i2c1
    signal i2c1_flags, i2c1_controls, i2c1_data_read, i2c1_data_write : std_logic_vector(7 downto 0) := (others => '0');
    signal i2c1_addr_write: std_logic_vector(6 downto 0) := (others => '0');

    signal branch_debug, branch_condition_debug : std_logic := '0';
    signal pc_addr_debug : std_logic_vector(31 downto 0) := (others => '0');
    signal added_address_debug, rs_debug,  rs1_branch_debug, rs2_branch_debug , rd_ex_debug: std_logic_vector(31 downto 0) := (others => '0');
    signal forward_branch_debug : std_logic_vector(2 downto 0) := (others => '0');
begin
    reset_n <= SW(0);
    clk_main <= MAX10_CLK1_50;
    LED(0) <= not special_io(1);
    LED(1) <= not general_io(1);
    LED(2) <= not general_io(2);
    LED(3) <= not general_io(3);
    LED(4) <= not general_io(4);
    LED(5) <= not general_io(5);
    LED(7) <= not branch_debug;
    LED(6) <= not clk;

    clk_divider_u: clk_divider 
    generic map(
        FREQ => FREQ,
        O_FREQ => 1
    ) port map (
        clk => clk_main, reset_n => reset_n, clk_o => clk
    );

    cpu_pipelined_u: cpu_pipelined
    port map(
        rs_debug => rs_debug,
        branch_debug => branch_debug,
        pc_addr_debug => pc_addr_debug,
        added_address_debug => added_address_debug,
        branch_condition_debug => branch_condition_debug,
        rd_ex_debug => rd_ex_debug,
		  rs1_branch_debug => rs1_branch_debug,
		  rs2_branch_debug => rs2_branch_debug,
          forward_branch_debug => forward_branch_debug,
        -- data memory exports
        general_pin_dir => general_pin_dir,
        general_pin_write => general_pin_write,
        general_pin_read => general_pin_read,

        -- uart1
        uart1_flags => uart1_flags,
        uart1_controls => uart1_controls,
        uart1_data_write => uart1_data_write,
        uart1_data_read => uart1_data_read,
        uart1_data_32_read => uart1_data_32_read,

        -- spi1
        spi1_flags => spi1_flags,
        spi1_controls => spi1_controls,
        spi1_data_write => spi1_data_write,
        spi1_data_read => spi1_data_read,

        -- i2c1
        i2c1_flags => i2c1_flags,
        i2c1_controls => i2c1_controls,
        i2c1_data_read => i2c1_data_read,
        i2c1_data_write => i2c1_data_write,
        i2c1_addr_write => i2c1_addr_write,

        reset_n => reset_n, clk => clk, clk_main => clk_main
    );

    io_u: io
    generic map(
        FREQ => FREQ
    )
    port map(
        general_io => general_io,
        special_io => special_io,
        -- general io controls
        general_io_dir => general_pin_dir,
      
        -- generation io data
        general_io_data_in => general_pin_write,
        general_io_data_out => general_pin_read,
    
        -- special io controls
          uart1_controls => uart1_controls,
          uart1_flags => uart1_flags,
          spi1_controls => spi1_controls,
          spi1_flags => spi1_flags,
          i2c1_controls => i2c1_controls,
          i2c1_flags => i2c1_flags,
    
        -- special io data
        uart1_data_in => uart1_data_write,
        uart1_data_out => uart1_data_read,
        uart1_data_out_32 => uart1_data_32_read,
    
        spi1_data_in => spi1_data_write,
        spi1_data_out => spi1_data_read,
    
        i2c1_data_in => i2c1_data_write,
        i2c1_data_out => i2c1_data_read,
        i2c1_addr => i2c1_addr_write,
    
        -- clock and reset
        clk => clk,
        clk_main => clk_main,
        reset_n => reset_n
    );

end architecture;