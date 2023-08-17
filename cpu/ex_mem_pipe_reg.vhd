library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_mem_pipe_reg is
    generic (
        DATA_WIDTH: integer := 32
    );
    port (
        -- clock and reset
       clk, reset_n : in std_logic;

       -- input
       branch_address_i, alu_result_i, rs2_data_i: in std_logic_vector(DATA_WIDTH-1 downto 0);
       zero_i : in std_logic;
       rd_i : in std_logic_vector(4 downto 0);
       func3_i : in std_logic_vector(2 downto 0);
       rs2_i : in std_logic_vector(4 downto 0);
       mem_control_i : in std_logic_vector(2 downto 0);
       wb_control_i : in std_logic_vector(1 downto 0);
       opcode_i : in std_logic_vector(6 downto 0);
       -- output
       branch_target_o, alu_result_o, rs2_data_o: out std_logic_vector(DATA_WIDTH-1 downto 0);
       zero_o : out std_logic;
       rd_o : out std_logic_vector(4 downto 0);
       func3_o : out std_logic_vector(2 downto 0);
       rs2_o : out std_logic_vector(4 downto 0);
       mem_control_o : out std_logic_vector(2 downto 0);
       wb_control_o : out std_logic_vector(1 downto 0);
       opcode_o : out std_logic_vector(6 downto 0)
    );
end ex_mem_pipe_reg;

architecture rtl of ex_mem_pipe_reg is
  signal branch_target_buffer, alu_result_buffer, rs2_data_buffer: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
  signal zero_buffer : std_logic := '0';
  signal rd_buffer: std_logic_vector(4 downto 0):= (others => '0');
  signal func3_buffer : std_logic_vector(2 downto 0) := (others => '0');
  signal rs2_buffer : std_logic_vector(4 downto 0) := (others => '0');
  signal mem_control_buffer : std_logic_vector(2 downto 0) := (others => '0');
  signal wb_control_buffer : std_logic_vector(1 downto 0) := (others => '0');
  signal opcode_buffer : std_logic_vector(6 downto 0) := (others => '0');
begin
  EX_MEM_PIPE_REG_PROC : process(clk, reset_n)
   begin
   if (reset_n = '0') then
      branch_target_buffer <= (others => '0');
     alu_result_buffer <= (others => '0');
     rs2_data_buffer <= (others => '0');
     zero_buffer <= '0';
     rd_buffer <= (others => '0');
     func3_buffer <= (others => '0');
     mem_control_buffer <= (others => '0');
     wb_control_buffer <= (others => '0');
     rs2_buffer <= (others => '0'); 
     opcode_buffer <= (others => '0');
   elsif (clk'event and clk='1') then
     branch_target_buffer <= branch_address_i;
     alu_result_buffer <= alu_result_i;
     rs2_data_buffer <= rs2_data_i;
     zero_buffer <= zero_i;
     rd_buffer <= rd_i;
     func3_buffer <= func3_i;
     mem_control_buffer <= mem_control_i;
     wb_control_buffer <= wb_control_i;
     rs2_buffer <= rs2_i;
     opcode_buffer <= opcode_i;
   end if;
   end process; 
   branch_target_o <= branch_target_buffer;
   alu_result_o <= alu_result_buffer;
   rs2_data_o <= rs2_data_buffer;
   zero_o <= zero_buffer;
   rd_o <= rd_buffer;
   func3_o <= func3_buffer;
   mem_control_o <= mem_control_buffer;
   wb_control_o <= wb_control_buffer;
   rs2_o <= rs2_buffer;
   opcode_o <= opcode_buffer;
end architecture;