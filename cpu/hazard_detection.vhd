library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detection is
  port (
    mem_read_i : std_logic;
    opcode_i : std_logic_vector(6 downto 0);
    rd_ex, rs1_id, rs2_id: in std_logic_vector(4 downto 0);

    stall : out std_logic
  );
end hazard_detection;

architecture rtl of hazard_detection is

begin
HARARD_STALL_PROC : process(mem_read_i, opcode_i, rd_ex, rs1_id, rs2_id)
  begin
  if (mem_read_i = '1' and opcode_i /= "0100011" and ((unsigned(rd_ex) = unsigned(rs1_id)) or (unsigned(rd_ex) = unsigned(rs2_id)))) then
    stall <= '1';
  else
    stall <= '0';
  end if;
  end process;
end architecture;