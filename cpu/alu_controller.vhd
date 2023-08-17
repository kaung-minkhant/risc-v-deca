library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_controller is
    port (
      alu_op : in std_logic_vector(1 downto 0);
      func3: in std_logic_vector(2 downto 0);
      func7: in std_logic_vector(6 downto 0);

      alu_controls: out std_logic_vector(4 downto 0)
    );
end alu_controller;

architecture rtl of alu_controller is
  signal func : std_logic_vector(func7'length + func3'length - 1 downto 0):= (others => '0');
begin
  func <= func7 & func3;
  CONTROL_PROC : process(alu_op, func3, func7)
  begin
    if (alu_op = "00") then
      case func is
        when "0000000000" => -- add
          alu_controls <= "00010";
        when "0100000000" => -- sub
          alu_controls <= "01010";
        when "0000000111" => -- and
          alu_controls <= "00000";
        when "0000000110" => -- or
          alu_controls <= "00001";
        when others =>
          alu_controls <= "00010";
      end case;
    elsif (alu_op = "01") then -- add overide
      alu_controls <= "00010";
    elsif (alu_op = "11") then -- sub overide
      alu_controls <= "01010";
    end if;
  end process;

end architecture;