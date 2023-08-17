library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_bit_alu is
  generic (
    OPERATION_WIDTH : integer := 3
  );
  port (
    -- inputs
    a, b, cin : in std_logic;
    less : in std_logic;

    -- outputs
    result : out std_logic;
    cout : out std_logic;
    set : out std_logic;

    -- controls
    operation : in std_logic_vector(OPERATION_WIDTH - 1 downto 0);
    binvert : in std_logic;
    ainvert : in std_logic
  );
end one_bit_alu;

architecture arch of one_bit_alu is
  component full_adder is
    port (
      A : in std_logic;
      B : in std_logic;
      result : out std_logic;
      cout : out std_logic;
      cin : in std_logic
    );
  end component;
  signal adder_result : std_logic := '0';
  signal a_buf, b_buf : std_logic := '0';
  signal op_code : integer := 0;
begin

  a_buf <= a when ainvert = '0' else
    not a when ainvert = '1' else
    a;
  b_buf <= b when binvert = '0' else
    not b when binvert = '1' else
    b;

  op_code <= to_integer(unsigned(operation));

  full_adder_1 : full_adder port map(
    cin => cin, cout => cout, result => adder_result, A => a_buf, B => b_buf
  );

  set <= adder_result;

  with op_code select result <=
    a_buf and b_buf when 0,
    a_buf or b_buf when 1,
    adder_result when 2,
    less when 3,
    '0' when others;

end architecture;