library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_calculator is
  generic (
    DATA_WIDTH : integer := 32
  );
    port (
      pc: in std_logic_vector(DATA_WIDTH-1 downto 0);
      offset: in std_logic_vector(DATA_WIDTH-1 downto 0);
      stall : in std_logic;

      branch_target: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end branch_calculator;

architecture rtl of branch_calculator is
  component adder is
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
      end component;
      signal offset_shifted : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      signal cout : std_logic := '0';
begin
  
  offset_shifted <= offset(DATA_WIDTH-2 downto 0) & '0';
  branch_calculate_u: adder
    generic map(
      DATA_WIDTH => DATA_WIDTH
    ) port map(
      A => pc, B => offset_shifted, cin => '0', result => branch_target,  cout => cout, stall => stall
    );
  

end architecture;