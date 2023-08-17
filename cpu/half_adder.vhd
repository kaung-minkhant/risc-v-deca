library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_adder is
  port (
    A : in std_logic;
    B : in std_logic;
    result : out std_logic;
    cout : out std_logic
  );
end half_adder;

architecture arch of half_adder is

begin
  result <= A xor B;
  cout <= A and B;
end architecture;