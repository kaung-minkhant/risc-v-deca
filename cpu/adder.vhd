library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic (
    DATA_WIDTH : integer := 32
  );
  port (
    A : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    stall : in std_logic;
    cin : in std_logic;
    result : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    cout : out std_logic
  );
end adder;

architecture arch of adder is
  component full_adder is
    port (
      A : in std_logic;
      B : in std_logic;
      result : out std_logic;
      cout : out std_logic;
      cin : in std_logic
    );
  end component;
  signal carry_buffer : std_logic_vector(DATA_WIDTH downto 0) := (others => '0');
  signal result_buffer : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal b_buffer : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin
  carry_buffer(0) <= cin;
  b_buffer <= B when stall = '0' else
  (others => '0') when stall = '1' else
  B;
  adder_GEN : for i in 0 to A'length - 1 generate
    adderX : full_adder port map(
      A => A(i), B => b_buffer(i), cin => carry_buffer(i), cout => carry_buffer(i + 1), result => result_buffer(i)
    );
  end generate;
  cout <= carry_buffer(DATA_WIDTH);
  result <= result_buffer(DATA_WIDTH - 1 downto 0);

end architecture;