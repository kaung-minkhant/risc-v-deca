library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
  generic (
    DATA_WIDTH : integer := 32
  );
  port (
    A : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    result : out std_logic_vector((DATA_WIDTH * 2) - 1 downto 0)
  );
end multiplier;

architecture arch of multiplier is

  component adder is
    generic (
      DATA_WIDTH : integer := 8
    );
    port (
      A : in std_logic_vector(DATA_WIDTH - 1 downto 0);
      B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
      cin : in std_logic;
      result : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      cout : out std_logic
    );
  end component;
  type partial_array is array (0 to DATA_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  type multiplier_array is array (0 to DATA_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  type sum_array is array (0 to DATA_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  type aggregate_array is array (0 to DATA_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal partials : partial_array := ((others => (others => '0')));
  signal partial_sums : sum_array := ((others => (others => '0')));
  signal multiplier_extended : multiplier_array := ((others => (others => '0')));
  signal carry_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal aggregates : aggregate_array := ((others => (others => '0')));
  signal result_lower : std_logic_vector(DATA_WIDTH - 2 downto 0) := (others => '0');
begin

  carry_out(0) <= '0';
  partial_sums(0) <= partials(0);
  MULTIPLIER_PROC : process (B)
  begin
    for i in 0 to B'length - 1 loop
      if B(i) = '1' then
        multiplier_extended(i) <= (others => '1');
      elsif B(i) = '0' then
        multiplier_extended(i) <= (others => '0');
      end if;
    end loop;
  end process;

  PARTIAL_PROC : process (multiplier_extended, A)
  begin
    for i in 0 to A'length - 1 loop
      partials(i) <= A and multiplier_extended(i);
    end loop;
  end process;

  AGGREGATE_PROC : process (carry_out, partial_sums)
  begin
    for i in 0 to DATA_WIDTH - 2 loop
      aggregates(i) <= carry_out(i) & partial_sums(i)(DATA_WIDTH - 1 downto 1);
    end loop;
  end process;

  PARTIAL_SUM_GEN : for i in 0 to DATA_WIDTH - 2 generate
    adderx : adder
    generic map(
      DATA_WIDTH => DATA_WIDTH
    )
    port map(
      A => partials(i + 1), B => aggregates(i), cin => '0', cout => carry_out(i + 1), result => partial_sums(i + 1)
    );
  end generate;

  RESULT_LOWER_PROC : process (partial_sums)
  begin
    for i in 0 to result_lower'length - 1 loop
      result_lower(i) <= partial_sums(i)(0);
    end loop;
  end process;

  result <= carry_out(DATA_WIDTH - 1) & partial_sums(DATA_WIDTH - 1) & result_lower;

  -- result <= carry_out(DATA_WIDTH - 1) & partial_sums(DATA_WIDTH - 1) & partial_sums(DATA_WIDTH - 2)(0) & partial_sums(DATA_WIDTH - 3)(0) & partial_sums(0)(0);

  -- aggregates(0) <= carry_out(0) & partial_sums(0)(DATA_WIDTH - 1 downto 1);
  -- aggregates(1) <= carry_out(1) & partial_sums(1)(DATA_WIDTH - 1 downto 1);
  -- aggregates(2) <= carry_out(2) & partial_sums(2)(DATA_WIDTH - 1 downto 1);

  -- adder0 : adder
  -- generic map(
  --   DATA_WIDTH => DATA_WIDTH
  -- )
  -- port map(
  --   A => partials(1), B => aggregates(0), cin => '0', cout => carry_out(1), result => partial_sums(1)
  -- );

  -- adder1 : adder
  -- generic map(
  --   DATA_WIDTH => DATA_WIDTH
  -- )
  -- port map(
  --   A => partials(2), B => aggregates(1), cin => '0', cout => carry_out(2), result => partial_sums(2)
  -- );

  -- adder2 : adder
  -- generic map(
  --   DATA_WIDTH => DATA_WIDTH
  -- )
  -- port map(
  --   A => partials(3), B => aggregates(2), cin => '0', cout => carry_out(3), result => partial_sums(3)
  -- );
  -- aggregates(0) <= carry_out(0) & partials(0)(DATA_WIDTH - 1 downto 1);
  -- u0 : adder
  -- generic map(
  --   DATA_WIDTH => DATA_WIDTH
  -- )
  -- port map(
  --   A => partials(1), B => aggregates(0), cin => '0', cout => carry_out(1), result => partial_sums(0)
  -- );
end architecture;