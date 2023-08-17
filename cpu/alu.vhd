LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_misc.ALL;

ENTITY alu IS
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
END alu;

ARCHITECTURE arch OF alu IS
  COMPONENT one_bit_alu IS
    GENERIC (
      OPERATION_WIDTH : INTEGER := 3
    );
    PORT (
      -- inputs
      a, b, cin : IN STD_LOGIC;
      less : IN STD_LOGIC;

      -- outputs
      result : OUT STD_LOGIC;
      cout : OUT STD_LOGIC;
      set : OUT STD_LOGIC;

      -- controls
      operation : IN STD_LOGIC_VECTOR(OPERATION_WIDTH - 1 DOWNTO 0);
      binvert : IN STD_LOGIC;
      ainvert : IN STD_LOGIC
    );
  END COMPONENT;

  CONSTANT BNEGATE_i : INTEGER := OPERATION_WIDTH - 1 + 1;
  CONSTANT AINVERT_i : INTEGER := OPERATION_WIDTH - 1 + 2;
  SIGNAL carry_buffer : STD_LOGIC_VECTOR(DATA_WIDTH DOWNTO 0) := (OTHERS => '0');
  SIGNAL bnegate, ainvert : STD_LOGIC := '0';
  SIGNAL op_code : STD_LOGIC_VECTOR(OPERATION_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL set_buff : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL result_buffer, zero_vector : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN

  ainvert <= operation(AINVERT_i);
  bnegate <= operation(BNEGATE_i);
  op_code <= operation(OPERATION_WIDTH - 1 DOWNTO 0);

  one_bit_alu_least : one_bit_alu GENERIC MAP(
    OPERATION_WIDTH => OPERATION_WIDTH
  )
  PORT MAP(
    a => A(0), b => B(0), cin => bnegate, result => result_buffer(0), cout => carry_buffer(1),
    operation => op_code, binvert => bnegate, ainvert => ainvert, less => set_buff(DATA_WIDTH - 1), set => set_buff(0)
  );

  one_bit_alu_most : one_bit_alu GENERIC MAP(
    OPERATION_WIDTH => OPERATION_WIDTH
  )
  PORT MAP(
    a => A(DATA_WIDTH - 1), b => B(DATA_WIDTH - 1), cin => carry_buffer(DATA_WIDTH - 1), result => result_buffer(DATA_WIDTH - 1), cout => carry_buffer(DATA_WIDTH),
    operation => op_code, binvert => bnegate, ainvert => ainvert, less => '0', set => set_buff(DATA_WIDTH - 1)
  );
  ONE_BIT_ALU_GEN : FOR i IN 1 TO DATA_WIDTH - 2 GENERATE
    one_bit_aluX : one_bit_alu GENERIC MAP(
      OPERATION_WIDTH => OPERATION_WIDTH
    )
    PORT MAP(
      a => A(i), b => B(i), cin => carry_buffer(i), result => result_buffer(i), cout => carry_buffer(i + 1),
      operation => op_code, binvert => bnegate, ainvert => ainvert, less => '0', set => set_buff(i)
    );
  END GENERATE;

  cout <= carry_buffer(DATA_WIDTH);
  zero <= '1' when unsigned(result_buffer) = unsigned(zero_vector) else
  '0';
  result <= result_buffer;
END ARCHITECTURE;