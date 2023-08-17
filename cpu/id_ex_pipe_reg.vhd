library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_ex_pipe_reg is
  generic (
    DATA_WIDTH : integer := 32
  );
    port (
      -- clock and reset
      clk, reset_n : in std_logic;

      -- input
      pc_next_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      rs1_i, rs2_i, immediate_i: in std_logic_vector(DATA_WIDTH-1 downto 0);
      rd_i : in std_logic_vector(4 downto 0); 
      func3_i : in std_logic_vector(2 downto 0);
      func7_i : in std_logic_vector(6 downto 0);
      ex_control_i : in std_logic_vector(2 downto 0);
      mem_control_i : in std_logic_vector(2 downto 0);
      wb_control_i : in std_logic_vector(1 downto 0);
      rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
      opcode_i : in std_logic_vector(6 downto 0);

      -- output
      pc_next: out std_logic_vector(DATA_WIDTH-1 downto 0);
      rs1_o, rs2_o, immediate_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
      rd_o : out std_logic_vector(4 downto 0);
      func3_o : out std_logic_vector(2 downto 0);
      func7_o : out std_logic_vector(6 downto 0);
      ex_control_o : out std_logic_vector(2 downto 0);
      mem_control_o : out std_logic_vector(2 downto 0);
      wb_control_o : out std_logic_vector(1 downto 0);
      rs1_addr_o, rs2_addr_o : out std_logic_vector(4 downto 0);
      opcode_o : out std_logic_vector(6 downto 0)
    );
end id_ex_pipe_reg;

architecture rtl of id_ex_pipe_reg is
  signal pc_next_buffer, rs1_buffer, rs2_buffer, immediate_buffer: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal func3_buffer : std_logic_vector(2 downto 0) := (others => '0');
  signal func7_buffer : std_logic_vector(6  downto 0) := (others => '0');
  signal rd_buffer: std_logic_vector(4 downto 0):= (others => '0'); 
  signal opcode_buffer : std_logic_vector(6 downto 0) := (others => '0');

  signal ex_control_buffer :  std_logic_vector(2 downto 0) :=(others => '0');
  signal mem_control_buffer :  std_logic_vector(2 downto 0):=(others => '0');
  signal wb_control_buffer :  std_logic_vector(1 downto 0):=(others => '0');
  signal rs1_addr_buffer, rs2_addr_buffer : std_logic_vector(4 downto 0) := (others => '0');
begin

  IF_ID_PIPLINE_REGISTER_PROC : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      pc_next_buffer <= (others => '0');
      rs1_buffer <= (others => '0');
      rs2_buffer <= (others => '0');
      immediate_buffer <= (others => '0');
      rd_buffer <= (others => '0');
      func3_buffer <= (others => '0');
      func7_buffer <= (others => '0');
      ex_control_buffer <= (others => '0');
      mem_control_buffer <= (others => '0');
      wb_control_buffer <= (others => '0');
      rs1_addr_buffer <= (others => '0');
      rs2_addr_buffer <= (others => '0');
      opcode_buffer <= (others => '0');
    elsif (clk'event and clk = '1') then
      pc_next_buffer <= pc_next_i;
      rs1_buffer <= rs1_i;
      rs2_buffer <= rs2_i;
      immediate_buffer <= immediate_i;
      rd_buffer <= rd_i;
      func3_buffer <= func3_i;
      func7_buffer <= func7_i;
      ex_control_buffer <= ex_control_i;
      mem_control_buffer <= mem_control_i;
      wb_control_buffer <= wb_control_i;
      rs2_addr_buffer <= rs2_addr_i;
      rs1_addr_buffer <= rs1_addr_i;
      opcode_buffer <= opcode_i;
    end if;

    end process;
    pc_next <= pc_next_buffer;
    rs1_o <= rs1_buffer;
    rs2_o <= rs2_buffer;
    immediate_o <= immediate_buffer;
    rd_o <= rd_buffer;
    func3_o <= func3_buffer;
    func7_o <= func7_buffer;
    ex_control_o <= ex_control_buffer;
    mem_control_o <= mem_control_buffer;
    wb_control_o <= wb_control_buffer;
    rs1_addr_o <= rs1_addr_buffer;
    rs2_addr_o <= rs2_addr_buffer;
    opcode_o <= opcode_buffer;
end architecture;