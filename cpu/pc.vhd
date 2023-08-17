library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
  generic (
    DATA_WIDTH : integer := 32
    );
  port (
    -- addresses
    input_addr : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    branch_addr : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    inst_addr  : out std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- clock and reset
    reset_n, clk, clk_main : in std_logic;

    -- control 
    load   : in std_logic;
    branch : in std_logic
    );
end pc;

architecture arch of pc is
  signal address_buffer : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal branch_r : std_logic_vector(2 downto 0) := (others => '0');
  signal clk_r : std_logic_vector(2 downto 0) := (others => '0');

  signal branch_data : std_logic_vector(31 downto 0) := (others => '0');
  signal normal_data : std_logic_vector(31 downto 0) := (others => '0');
begin

  PREV_BRANCH_PROC : process(clk_main)
  begin
    if (clk_main'event and clk_main='1') then
      branch_r <= branch_r(branch_r'left-1 downto 0) & branch;
    end if;
  end process;

  -- address_buffer(0) <= clk_edge;

  BRANCH_PROC : process(branch)
  begin
    if (branch'event and branch='0') then
      branch_data <= input_addr;
    end if;
  end process;

  CLK_PROC : process(clk)
  begin
    if (clk'event and clk='1') then
      if (load = '1') then
        normal_data <= input_addr;
      end if;
    end if;
  end process;

  -- LOAD_PROC : process (reset_n, clk, branch_r, branch)
  -- begin
  --   if (reset_n = '0') then
  --     address_buffer <= (others => '0');
  --   -- elsif (branch_r(branch_r'left downto branch_r'left-1) = "10") then
  --   --   address_buffer <= input_addr;
  --   -- elsif (branch = '1') then
  --   --   address_buffer <= branch_addr;
  --   elsif (clk_r(clk_r'left downto clk_r'left-1) = "01") then
  --     if (load = '1') then
  --       address_buffer <= input_addr;
  --     else
  --       address_buffer <= address_buffer;
  --     end if;
  --   end if;
  -- end process;


  inst_addr <= (others => '0') when reset_n = '0' else
                branch_data when branch_r(branch_r'left downto branch_r'left-1) = "10" else
                branch_addr when branch='1' and clk='0' else
                normal_data when clk = '1';
end architecture;
