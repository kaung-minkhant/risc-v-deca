library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
  generic (
    DATA_WIDTH : integer := 32
  );
    port (
      -- clock and reset
      clk, clk_main, reset_n : in std_logic;

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

      --i2c1
      i2c1_flags : in std_logic_vector(7 downto 0);
      i2c1_controls: out std_logic_vector(7 downto 0);
      i2c1_data_read : in std_logic_vector(7 downto 0);
      i2c1_data_write : out std_logic_vector(7 downto 0);
      i2c1_addr_write: out std_logic_vector(6 downto 0);


      -- input data and address
      address : in std_logic_vector(DATA_WIDTH-1 downto 0);
      write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

      --output data
      read_data : out std_logic_vector(DATA_WIDTH-1 downto 0);

      -- controls
      write, read : in std_logic
    );
end data_memory;

architecture rtl of data_memory is
  constant GENERAL_PIN_DIR_ADDR : INTEGER := 1;
  constant GENERAL_PIN_OUT_ADDR : INTEGER := 2;
  constant GENERAL_PIN_IN_ADDR : INTEGER := 3;

  constant UART1_CONTROL_ADDR: INTEGER := 4;
  constant UART1_FLAGS_ADDR: INTEGER := 35;
  constant UART1_WRITE_ADDR: INTEGER := 11;
  constant UART1_READ_ADDR: INTEGER := 12;
  constant UART1_READ_32_ADDR: INTEGER := 13;
  
  constant SPI1_CONTROL_ADDR: INTEGER := 5;
  constant SPI1_FLAGS_ADDR: integer := 36;
  constant SPI1_WRITE_ADDR: integer := 20;
  constant SPI1_READ_ADDR: integer := 21;
  
  constant I2C1_CONTROL_ADDR: INTEGER := 6;
  constant I2C1_FLAGS_ADDR: integer := 37;
  constant I2C1_WRITE_ADDR: integer := 26;
  constant I2C1_READ_ADDR: integer := 27;
  constant I2C1_ADDR_ADDR: integer := 28;
  


  type DATA_MEMORY_t is array (0 to 2**8 -1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal data_memory_array : DATA_MEMORY_t := (others => (others => '0'));
  
  signal write_buffer, read_buffer : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal clk_r : std_logic_vector(2 downto 0) := (others => '0');
  begin
    write_buffer <= write_data;
    read_data <= read_buffer;

    EDGE_PROC : process(clk_main, clk)
    begin
      if (clk_main'event and clk_main = '1') then
        clk_r <= clk_r(clk_r'left-1 downto 0) & clk;
      end if;
    end process;

    MEMORY_PROC : process(clk_r, reset_n, general_pin_read, uart1_flags, uart1_data_read, uart1_data_32_read, spi1_flags, spi1_data_read,
      i2c1_flags, i2c1_data_read
    )begin
      data_memory_array(GENERAL_PIN_IN_ADDR)(15 downto 0) <= general_pin_read;
      data_memory_array(UART1_FLAGS_ADDR)(7 downto 0) <= uart1_flags;
      data_memory_array(UART1_READ_ADDR)(7 downto 0) <= uart1_data_read;
      data_memory_array(UART1_READ_32_ADDR) <= uart1_data_32_read;
      data_memory_array(SPI1_FLAGS_ADDR)(7 downto 0) <= spi1_flags;
      data_memory_array(SPI1_READ_ADDR)(7 downto 0) <= spi1_data_read;
      data_memory_array(I2C1_FLAGS_ADDR)(7 downto 0) <= i2c1_flags;
      data_memory_array(I2C1_READ_ADDR)(7 downto 0) <= i2c1_data_read;
      if (reset_n = '0') then
        data_memory_array <= (others => (others => '0'));
      elsif (clk_r(clk_r'left downto clk_r'left-1) = "01") then
        if (write = '1'
          and to_integer(unsigned(address)) /= GENERAL_PIN_IN_ADDR
          and to_integer(unsigned(address)) /= UART1_FLAGS_ADDR
          and to_integer(unsigned(address)) /= SPI1_FLAGS_ADDR
          and to_integer(unsigned(address)) /= UART1_READ_ADDR
          and to_integer(unsigned(address)) /= UART1_READ_32_ADDR
          and to_integer(unsigned(address)) /= SPI1_READ_ADDR
          and to_integer(unsigned(address)) /= I2C1_READ_ADDR
          ) then
          data_memory_array(to_integer(unsigned(address))) <= write_buffer;
        end if;
      end if;
    end process;
            
    READING_PROC : process(clk_r)
    begin
      if (clk_r(clk_r'left downto clk_r'left-1) = "10" and read='1') then
        read_buffer <= data_memory_array(to_integer(unsigned(address)));
      else
        read_buffer <= read_buffer;
      end if;
    end process;

    general_pin_dir <= data_memory_array(GENERAL_PIN_DIR_ADDR)(15 downto 0);
    general_pin_write <= data_memory_array(GENERAL_PIN_OUT_ADDR)(15 downto 0);


    uart1_controls <= data_memory_array(UART1_CONTROL_ADDR)(7 downto 0);
    uart1_data_write <= data_memory_array(UART1_WRITE_ADDR);

    spi1_controls <= data_memory_array(SPI1_CONTROL_ADDR)(7 downto 0);
    spi1_data_write <= data_memory_array(SPI1_WRITE_ADDR)(7 downto 0);

    i2c1_controls <= data_memory_array(I2C1_CONTROL_ADDR)(7 downto 0);
    i2c1_data_write <= data_memory_array(I2C1_WRITE_ADDR)(7 downto 0);
    i2c1_addr_write <= data_memory_array(I2C1_ADDR_ADDR)(6 downto 0);
    
end architecture;
