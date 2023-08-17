library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_id_pipe_reg is
  generic (
    DATA_WIDTH : integer := 32
  );
    port (
      -- clock and reset
      clk, reset_n : in std_logic;

      -- input
      pc_next_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      instruction_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      stall : in std_logic;

      -- output
      pc_next: out std_logic_vector(DATA_WIDTH-1 downto 0);
      instruction: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end if_id_pipe_reg;

architecture rtl of if_id_pipe_reg is
  signal pc_next_buffer, instruction_buffer : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin

  IF_ID_PIPLINE_REGISTER_PROC : process(clk, reset_n, stall)
  begin
    if (reset_n = '0') then
      pc_next_buffer <= (others => '0');
      instruction_buffer <= (others => '0');
    elsif (clk'event and clk = '1' and stall = '0') then
      pc_next_buffer <= pc_next_i;
      instruction_buffer <= instruction_i;
    end if;

    end process;
    pc_next <= pc_next_buffer;
    instruction <= instruction_buffer;

end architecture;