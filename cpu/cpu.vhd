LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cpu IS
    GENERIC (
      DATA_WIDTH : INTEGER := 32;
        OPERATION_WIDTH : integer := 3
    );
    PORT (
        reset_n, clk: std_logic
    );
END cpu;

ARCHITECTURE rtl OF cpu IS

    component pc_container IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        -- inputs
        branch_target : in std_logic_vector(DATA_WIDTH-1 downto 0);

        -- output address
        pc_address : buffer STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        pc_address_next : out std_logic_vector(DATA_WIDTH-1 downto 0);

        -- reset and clock
        reset_n, clk : IN STD_LOGIC;

        -- controls
        -- load, branch/add (1 = branch)
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
        clk, reset_n : in std_logic;
  
        -- input data and address
        address : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
  
        --output data
        read_data : buffer std_logic_vector(DATA_WIDTH-1 downto 0);
  
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
      control_string: out std_logic_vector(8 downto 0)
    );
END component;

component branch_controller is
  port (
      func3 : in std_logic_vector(2 downto 0);
      branch_condition, zero : in std_logic;
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

      branch_target: out std_logic_vector(DATA_WIDTH-1 downto 0)
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
signal pc_address_piped : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
BEGIN
    pc_controls <= load & branch;
    opcode <= instruction(6 downto 0);
  branch_condition <= controls(0);
  data_memory_controls <= controls(2 downto 1);
  memtoreg <= controls(3);
  alu_op <= controls(5 downto 4);
  alu_src <= controls(6);
  register_file_rw <= controls(7);
  load <= controls(8);

    pc_u : pc_container 
    generic map(
        DATA_WIDTH =>  DATA_WIDTH
    ) port map (
      branch_target =>  branch_target, pc_address =>  pc_address, reset_n =>  reset_n, clk =>  clk,
      controls =>  pc_controls, pc_address_next => pc_address_piped
    );

    branch_controller_u : branch_controller 
    port map(
      func3 => instruction(14 downto 12), branch_condition => branch_condition, zero => alu_zero, branch => branch
    );

    branch_calculator_u: branch_calculator
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        pc => pc_address, offset => immediate, branch_target => branch_target
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
        rs1 => instruction(19 downto 15), rs2 => instruction(24 downto 20), rd => instruction(11 downto 7),
        rd_data => rd_data, rs1_data => rs1_data, rs2_data => rs2_data, clk => clk, reset_n => reset_n,
        rw => register_file_rw
      );

    b_data <= rs2_data when alu_src = '0' else
      immediate when alu_src = '1' else
      rs2_data;
    alu_u : alu 
      generic map (
        DATA_WIDTH => DATA_WIDTH,
        OPERATION_WIDTH => OPERATION_WIDTH
      ) port map (
        A => rs1_data, B => b_data, result => alu_result, cout => alu_cout, zero => alu_zero,
        operation => alu_controls
      );

    alu_controller_u : alu_controller
      port map(
        alu_op => alu_op, func3 => instruction(14 downto 12),
        func7 => instruction(31 downto 25), alu_controls => alu_controls 
      );

    immediate_generator_u : immediate_generator
      generic map (
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        instruction => instruction, immediate => immediate
      );

    rd_data <= alu_result when memtoreg = '0' else
      data_memory_read when memtoreg = '1' else
      alu_result;
    data_memory_u : data_memory 
      generic map(
        DATA_WIDTH => DATA_WIDTH
      ) port map(
        clk => clk, reset_n => reset_n, address => alu_result, write_data => rs2_data,
        read => data_memory_controls(0), write => data_memory_controls(1), read_data => data_memory_read
      );

    control_unit_u : control_unit
      generic map (
        DATA_WIDTH => DATA_WIDTH
      ) port map (
        opcode => opcode,
        control_string => controls
      );

END ARCHITECTURE;