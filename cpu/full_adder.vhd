library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
  port (
    A : in std_logic;
    B : in std_logic;
    result : out std_logic;
    cout : out std_logic;
    cin : in std_logic
  );
end full_adder;

architecture arch of full_adder is
  component half_adder is
    port (
      A : in std_logic;
      B : in std_logic;
      result : out std_logic;
      cout : out std_logic
    );
  end component;
  signal partial_1, partial1_cout, partial2_cout : std_logic := '0';
begin
  adder1 : half_adder port map(
    A => A, B => B, result => partial_1, cout => partial1_cout
  );

  adder2 : half_adder port map(
    A => partial_1, B => cin, result => result, cout => partial2_cout
  );

  cout <= partial1_cout or partial2_cout;
end architecture;