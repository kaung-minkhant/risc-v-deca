library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_pipe_reg is
  generic (
    DATA_WIDTH : integer := 32
  );
  port (
    -- clock and reset
    clk, reset_n : in std_logic;

    -- input
    mem_data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
    alu_result_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_i : in std_logic_vector(4 downto 0);
    wb_control_i : in std_logic_vector(1 downto 0);
    opcode_i : in std_logic_vector(6 downto 0);

    -- output
    mem_data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    alu_result_o: out std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_o : out std_logic_vector(4 downto 0);
    wb_control_o : out std_logic_vector(1 downto 0);
    opcode_o : out std_logic_vector(6 downto 0)
  );
end mem_wb_pipe_reg;

architecture rtl of mem_wb_pipe_reg is
  signal mem_data_buffer, alu_result_buffer: std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rd_buffer : std_logic_vector(4 downto 0) := (others => '0');
  signal wb_control_buffer : std_logic_vector(1 downto 0) := (others => '0');
  signal opcode_buffer : std_logic_vector(6 downto 0) := (others => '0');
begin
  MEM_WB_PIPE_REG_PROC : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      mem_data_buffer <= (others => '0');
      alu_result_buffer <= (others => '0');
      rd_buffer <= (others => '0');
      wb_control_buffer <= (others => '0');
      opcode_buffer <= (others => '0');
    elsif (clk'event and clk='1') then
      mem_data_buffer <= mem_data_i;
      alu_result_buffer <= alu_result_i;
      rd_buffer <= rd_i;
      wb_control_buffer <= wb_control_i;
      opcode_buffer <= opcode_i;
    end if;
  end process;
  mem_data_o <= mem_data_buffer;
  alu_result_o <= alu_result_buffer;
  rd_o <= rd_buffer;
  wb_control_o <= wb_control_buffer;
  opcode_o <= opcode_buffer;
end architecture;