LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY control_unit IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
      opcode: in std_logic_vector(6 downto 0);
      stall : in std_logic;
      control_string: out std_logic_vector(8 downto 0)
    );
END control_unit;

ARCHITECTURE rtl OF control_unit IS
  
BEGIN
  CONTROL_PROC : process(opcode, stall)
    begin
      if (stall = '1') then
        control_string <= "000000000";
      else
      case opcode is
        when "0110011" => -- R type
          control_string <= "110000000";
        when "0000011" => -- I load type
          control_string <= "111011010";
        when "0010011" => -- I arith type
          control_string <= "111010000";
        when "0100011" => -- S type
          control_string <= "101010100";
        when "1100011" => -- SB type
          control_string <= "100110001";
        when others =>
          control_string <= "000000000";
      end case;
      end if;
    
    end process;

END ARCHITECTURE;