LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY address_decoder IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
      byte_address : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
      double_word_address : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END address_decoder;

ARCHITECTURE rtl OF address_decoder IS

BEGIN

  double_word_address <= "00" & byte_address(DATA_WIDTH-1 downto 2);

END ARCHITECTURE;