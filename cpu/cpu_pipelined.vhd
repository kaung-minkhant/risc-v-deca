LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cpu_pipelined IS
    GENERIC (
      DATA_WIDTH : INTEGER := 32;
      OPERATION_WIDTH : integer := 3
    );
    PORT (
      rs_debug : out std_logic_vector(31 downto 0);
       branch_debug, branch_condition_debug: out std_logic;
       pc_addr_debug, rs1_branch_debug, rs2_branch_debug : out std_logic_vector(31 downto 0);
       added_address_debug, rd_ex_debug : out std_logic_vector(31 downto 0);
       forward_branch_debug : out std_logic_vector(2 downto 0);
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
END cpu_pipelined;

ARCHITECTURE rtl OF cpu_pipelined IS

    component pc_container IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        added_address_debug : out std_logic_vector(31 downto 0);
        -- inputs
        -- address_offset : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        branch_target : in std_logic_vector(DATA_WIDTH-1 downto 0);
        stall : in std_logic;

        -- output address
        pc_address : buffer STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        pc_address_next : out std_logic_vector(DATA_WIDTH-1 downto 0);

        -- reset and clock
        reset_n, clk, clk_main : IN STD_LOGIC;

        -- controls
        -- load, branch/add (1 = branch)
        branch_condition: In std_logic;
        controls : IN STD_LOGIC_VECTOR(1 DOWNTO 0)

    );
    END component;

    component instruction_memory IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        -- double word address
        instruction_address : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        -- instruction
        instruction : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

        -- clock and resets
        clk : IN STD_LOGIC;
        reset_n : IN STD_LOGIC
    );
END component;

component register_file is
    generic (
      DATA_WIDTH : integer := 32
    );
    port (
      rs_debug : out std_logic_vector(31 downto 0);
      -- rs1 
      rs1 : in std_logic_vector(4 downto 0);
      rs1_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  
      -- rs2
      rs2 : in std_logic_vector(4 downto 0);
      rs2_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  
      -- rd
      rd : in std_logic_vector(4 downto 0);
      rd_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  
      -- controls
      rw : in std_logic;
  
      -- clock and resets
      clk : in std_logic;
      reset_n : in std_logic
    );
  end component;

  component alu IS
  GENERIC (
    DATA_WIDTH : INTEGER := 4;
    OPERATION_WIDTH : INTEGER := 3
  );
  PORT (
    -- input data
    A : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- output data
    result : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    cout, zero : OUT STD_LOGIC;

    -- controls
    -- ainvert, bnegate, operations(3)
    operation : IN STD_LOGIC_VECTOR(OPERATION_WIDTH - 1 + 2 DOWNTO 0)
  );
END component;

component immediate_generator IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        immediate : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END component;

component data_memory is
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
  end component;

  component alu_controller is
    port (
      alu_op : in std_logic_vector(1 downto 0);
      func3: in std_logic_vector(2 downto 0);
      func7: in std_logic_vector(6 downto 0);

      alu_controls: out std_logic_vector(4 downto 0)
    );
end component;

component control_unit IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
      opcode: in std_logic_vector(6 downto 0);
      stall : in std_logic;
      control_string: out std_logic_vector(8 downto 0)
    );
END component;

component branch_controller is
    generic (
        DATA_WIDTH : integer := 32
    );
  port (
    func3 : in std_logic_vector(2 downto 0);
    branch_condition : in std_logic;
    clk, clk_main, reset_n : in std_logic;
    rs1_data, rs2_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    branch : out std_logic
  );
end component;

component branch_calculator is
  generic (
    DATA_WIDTH : integer := 32
  );
    port (
      pc: in std_logic_vector(DATA_WIDTH-1 downto 0);
      offset: in std_logic_vector(DATA_WIDTH-1 downto 0);
      stall : in std_logic;

      branch_target: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end component;

-------------------------------- pipeline register components
component if_id_pipe_reg is
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
end component;

component id_ex_pipe_reg is
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
end component;

component ex_mem_pipe_reg is
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
end component;

component mem_wb_pipe_reg is
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
end component;


component forwarding_unit is
  port (
    rs1_addr_ex, rs2_addr_ex,rd_addr_mem, rd_addr_wb, rs2_addr_mem: in  std_logic_vector(4 downto 0);
    reg_write_mem, reg_write_wb,data_memory_write: in std_logic;
    opcode_i, opcode_mem : in std_logic_vector(6 downto 0);
    forwardA, forwardB: out std_logic_vector(1 downto 0)
  );
end component;



component forwarding_unit_branch is
  port (
    rd_ex, rd_mem, rd_wb : in std_logic_vector(4 downto 0);
    rs1_id, rs2_id : in std_logic_vector(4 downto 0);
    opcode, opcode_ex, opcode_mem : in std_logic_vector(6 downto 0);
    stall_branch: out std_logic;
    forward_branch_A, forward_branch_B : out std_logic_vector(2 downto 0)
  );
  end component;

  signal pc_address, instruction, rd_data, rs1_data, rs2_data,  b_data, immediate, data_memory_read: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal alu_result, branch_target : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal pc_controls : std_logic_vector(1 downto 0) := (others =>  '0');
signal register_file_rw, alu_src, memtoreg, alu_zero, alu_cout, branch_condition, branch, load : std_logic := '0';
  signal alu_op : std_logic_vector(1 downto 0):= (others => '0');
signal alu_controls : std_logic_vector(4 downto 0):= (others => '0');
  signal data_memory_controls : std_logic_vector(1 downto 0) := (others => '0');
signal controls : std_logic_vector(8 downto 0) := (others => '0');
signal opcode : std_logic_vector(6 downto 0) := (others => '0');

----- pipeline signals
signal pc_address_piped_if, pc_address_piped_id, pc_address_piped_ex : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal instruction_piped_id, rs1_piped_ex, rs2_piped_ex, immediate_piped_ex : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal rs2_data_piped_mem, branch_target_piped_mem, alu_result_piped_mem , memory_write_data: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal zero_piped_mem, stall, stall_branch, stall_forward : std_logic := '0';
signal mem_data_piped_wb, alu_result_piped_wb : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal rd_ex, rd_mem, rd_wb : std_logic_vector(4 downto 0) := (others => '0');
signal func3_piped_ex, func3_piped_mem : std_logic_vector(2 downto 0) := (others => '0');
signal func7_piped_ex : std_logic_vector(6 downto 0) := (others => '0');
signal controls_id : std_logic_vector(8 downto 0) := (others => '0');
signal wb_id, wb_ex, wb_mem, wb_wb: std_logic_vector(1 downto 0) := (others => '0');
signal ex_ex: std_logic_vector(2 downto 0) := (others => '0');
signal mem_ex, mem_mem: std_logic_vector(2 downto 0) := (others => '0');
signal rs1_addr_ex, rs2_addr_ex, rs2_addr_mem : std_logic_vector(4 downto 0) := (others => '0');
signal forwardA, forwardB : std_logic_vector(1 downto 0) := (others => '0');
signal forward_branch_A, forward_branch_B : std_logic_vector(2 downto 0) := (others => '0');
signal alu_a_piped, alu_b_piped : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal opcode_ex, opcode_mem, opcode_wb : std_logic_vector(6 downto 0) := (others => '0');
signal rs1_branch_data, rs2_branch_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
BEGIN
branch_debug <= branch;
pc_addr_debug <= pc_address;
branch_condition_debug <= branch_condition;
rs1_branch_debug <= rs1_branch_data;
rs2_branch_debug <= rs2_branch_data;
forward_branch_debug <= forward_branch_B;
rd_ex_debug(4 downto 0) <= rd_ex;

  opcode <= instruction_piped_id(6 downto 0);
  controls_id <= controls;
  wb_id <= controls_id(7) & controls_id(3);
  pc_controls <= load & branch;
  branch_condition <= controls_id(0);
  data_memory_controls <= mem_mem(2 downto 1);
  memtoreg <= wb_wb(0);
  alu_op <= ex_ex(1 downto 0);
  alu_src <= ex_ex(2);
  register_file_rw <= wb_wb(1);
  load <= '1';

    pc_u : pc_container 
    generic map(
        DATA_WIDTH =>  DATA_WIDTH
    ) port map (
      branch_target =>  branch_target, pc_address =>  pc_address, reset_n =>  reset_n, clk =>  clk, clk_main => clk_main,
      controls =>  pc_controls, pc_address_next => pc_address_piped_if, stall => stall, branch_condition => branch_condition, 
      added_address_debug => added_address_debug
    );

    rs1_branch_data <= rs1_data when forward_branch_A = "000" else
      alu_result when forward_branch_A = "001" else
      alu_result_piped_mem when forward_branch_A = "010" else
      rd_data when forward_branch_A = "011" else
      data_memory_read when forward_branch_A = "100" else
      rs1_data;
    rs2_branch_data <= rs2_data when forward_branch_B = "000" else
      alu_result when forward_branch_B = "001" else
      alu_result_piped_mem when forward_branch_B = "010" else
      rd_data when forward_branch_B = "011" else
      data_memory_read when forward_branch_B = "100" else
      rs2_data;
    branch_controller_u : branch_controller 
    generic map (
        DATA_WIDTH => DATA_WIDTH
    )
    port map(
      func3 => instruction_piped_id(14 downto 12), branch_condition => branch_condition, branch => branch, reset_n => reset_n,
      rs1_data => rs1_branch_data, rs2_data => rs2_branch_data, clk => clk, clk_main => clk_main, opcode => opcode
    );

    branch_calculator_u: branch_calculator
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        pc => pc_address_piped_id, offset => immediate, branch_target => branch_target, stall => stall
      );

    instruction_memory_u : instruction_memory
    generic map (
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        clk =>  clk, reset_n =>  reset_n, instruction_address =>  pc_address, instruction =>  instruction
    );

    register_file_u : register_file
      generic map (
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        rs_debug => rs_debug,
        rs1 => instruction_piped_id(19 downto 15), rs2 => instruction_piped_id(24 downto 20), rd => rd_wb,
        rd_data => rd_data, rs1_data => rs1_data, rs2_data => rs2_data, clk => clk, reset_n => reset_n,
        rw => register_file_rw
      );
    alu_a_piped <= rs1_piped_ex when forwardA = "00" else
      rd_data when forwardA = "01" else
      alu_result_piped_mem when forwardA = "10" else
      data_memory_read when forwardA = "11" else
      rs1_piped_ex;

    alu_b_piped <= rs2_piped_ex when forwardB = "00" else
      rd_data when forwardB = "01" else
      alu_result_piped_mem when forwardB = "10" else
      data_memory_read when forwardB = "11" else
      rs2_piped_ex;

    b_data <= alu_b_piped when alu_src = '0' else
      immediate_piped_ex when alu_src = '1' else
      rs2_piped_ex;
    alu_u : alu 
      generic map (
        DATA_WIDTH => DATA_WIDTH,
        OPERATION_WIDTH => OPERATION_WIDTH
      ) port map (
        A => alu_a_piped, B => b_data, result => alu_result, cout => alu_cout, zero => alu_zero,
        operation => alu_controls
      );

    alu_controller_u : alu_controller
      port map(
        alu_op => alu_op, func3 => func3_piped_ex,
        func7 => func7_piped_ex, alu_controls => alu_controls 
      );

    immediate_generator_u : immediate_generator
      generic map (
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        instruction => instruction_piped_id, immediate => immediate
      );

    rd_data <= alu_result_piped_wb when memtoreg = '0' else
      mem_data_piped_wb when memtoreg = '1' else
      alu_result_piped_wb;

    data_memory_u : data_memory 
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        clk => clk, clk_main => clk_main, reset_n => reset_n, address => alu_result_piped_mem, write_data => rs2_data_piped_mem,
        read => data_memory_controls(0), write => data_memory_controls(1), read_data => data_memory_read,
        general_pin_write => general_pin_write, general_pin_read => general_pin_read, general_pin_dir => general_pin_dir,
        uart1_flags => uart1_flags, uart1_controls => uart1_controls,
        uart1_data_write => uart1_data_write, uart1_data_read => uart1_data_read, uart1_data_32_read => uart1_data_32_read,
        spi1_flags => spi1_flags, spi1_controls => spi1_controls,
        spi1_data_write => spi1_data_write, spi1_data_read => spi1_data_read,
        i2c1_flags => i2c1_flags, i2c1_controls => i2c1_controls,
        i2c1_data_read => i2c1_data_read, i2c1_data_write => i2c1_data_write, i2c1_addr_write => i2c1_addr_write
      );

    control_unit_u : control_unit
      generic map (
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        opcode => opcode,
        control_string => controls,
        stall => stall
      );


    ------------------ pipeline

    if_id_pipe_reg_u: if_id_pipe_reg 
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        clk => clk, reset_n => reset_n,
        pc_next_i => pc_address, pc_next => pc_address_piped_id,
        instruction_i => instruction, instruction => instruction_piped_id,
        stall => stall
      );

    id_ex_pipe_reg_u : id_ex_pipe_reg
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        clk => clk, reset_n => reset_n,
        pc_next_i => pc_address_piped_id,
        rs1_i => rs1_data, rs2_i => rs2_data, immediate_i => immediate,
        pc_next => pc_address_piped_ex, rs1_o => rs1_piped_ex,
        rs2_o => rs2_piped_ex, immediate_o => immediate_piped_ex,
        rd_i => instruction_piped_id(11 downto 7), rd_o => rd_ex,
        func3_o => func3_piped_ex, func7_o => func7_piped_ex,
        func3_i => instruction_piped_id(14 downto 12), func7_i => instruction_piped_id(31 downto 25),
        ex_control_i => controls_id(6 downto 4), mem_control_i => controls_id(2 downto 0),
        wb_control_i => wb_id, ex_control_o => ex_ex, mem_control_o => mem_ex, wb_control_o => wb_ex,
        rs1_addr_i => instruction_piped_id(19 downto 15), rs2_addr_i =>  instruction_piped_id(24 downto 20),
        rs1_addr_o => rs1_addr_ex, rs2_addr_o => rs2_addr_ex,
        opcode_i => instruction_piped_id(6 downto 0), opcode_o => opcode_ex
      );

    ex_mem_pipe_reg_u: ex_mem_pipe_reg
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        clk => clk, reset_n => reset_n,
        branch_address_i => branch_target,
        alu_result_i => alu_result,
        rs2_data_i => alu_b_piped,
        zero_i => alu_zero,
        branch_target_o => branch_target_piped_mem,
        alu_result_o => alu_result_piped_mem,
        rs2_data_o => rs2_data_piped_mem,
        zero_o => zero_piped_mem,
        rd_i => rd_ex, rd_o => rd_mem,
        func3_o => func3_piped_mem, func3_i => func3_piped_ex,
        mem_control_i => mem_ex, wb_control_i => wb_ex,
        mem_control_o => mem_mem, wb_control_o => wb_mem,
        rs2_i => rs2_addr_ex, rs2_o => rs2_addr_mem,
        opcode_i => opcode_ex, opcode_o => opcode_mem
      );

    mem_wb_pipe_reg_u: mem_wb_pipe_reg
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        mem_data_i => data_memory_read,
        alu_result_i => alu_result_piped_mem,
        mem_data_o => mem_data_piped_wb,
        alu_result_o => alu_result_piped_wb, 
        clk => clk, reset_n => reset_n,
        rd_i => rd_mem, rd_o => rd_wb,
        wb_control_i => wb_mem, wb_control_o => wb_wb, 
        opcode_i => opcode_mem, opcode_o => opcode_wb
      );
    forwarding_unit_u : forwarding_unit
  port map(
    rs1_addr_ex => rs1_addr_ex, rs2_addr_ex => rs2_addr_ex, rd_addr_mem => rd_mem, rd_addr_wb => rd_wb,
    reg_write_mem => wb_mem(1), reg_write_wb => register_file_rw ,
    forwardA => forwardA, forwardB => forwardB,
    data_memory_write => mem_mem(2), rs2_addr_mem => rs2_addr_mem,
    opcode_i => opcode_wb, opcode_mem => opcode_mem
  );
   stall <=  stall_branch;
  forwarding_unit_branch_u : forwarding_unit_branch
  port map(
    rd_ex => rd_ex, rd_mem => rd_mem, rd_wb => rd_wb, rs1_id => instruction_piped_id(19 downto 15), rs2_id => instruction_piped_id(24 downto 20),
    opcode => instruction_piped_id(6 downto 0), opcode_ex => opcode_ex, stall_branch => stall_branch, 
    forward_branch_A => forward_branch_A, forward_branch_B => forward_branch_B, opcode_mem => opcode_mem
  );
END ARCHITECTURE;
