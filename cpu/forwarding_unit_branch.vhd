library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit_branch is
  port (
    rd_ex, rd_mem, rd_wb : in std_logic_vector(4 downto 0);
    rs1_id, rs2_id : in std_logic_vector(4 downto 0);
    opcode, opcode_ex, opcode_mem : in std_logic_vector(6 downto 0);
    stall_branch : out std_logic;
    forward_branch_A, forward_branch_B : out std_logic_vector(2 downto 0)
    );
end forwarding_unit_branch;

architecture rtl of forwarding_unit_branch is
  begin
    FORWARDING_PROC : process(rd_ex, rd_mem, rd_wb, rs1_id, rs2_id, opcode, opcode_mem)
    begin
  
      --- TODO: FIX THE LOAD BUG
      if (unsigned(opcode) = "1100011") then
        if (unsigned(rs1_id) /= 0) then
          if (unsigned(rs1_id) = unsigned(rd_ex) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_A <= "001";
          elsif (unsigned(rs1_id) = unsigned(rd_ex) and unsigned(opcode_mem) = "0000011" and unsigned(rs1_id) /= unsigned(rd_mem)) then
            forward_branch_A <= "001";
          elsif (unsigned(rs1_id) = unsigned(rd_mem) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_A <= "010";
          elsif (unsigned(rs1_id) = unsigned(rd_wb) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_A <= "011";
          elsif (unsigned(opcode_mem) = "0000011" and unsigned(rs1_id) = unsigned(rd_mem)) then
            forward_branch_A <= "100";
          else
            forward_branch_A <= "000";
          end if;
        else
          forward_branch_A <= "000";
        end if;
  
        if (unsigned(rs2_id) /= 0) then
          if (unsigned(rs2_id) = unsigned(rd_ex) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_B <= "001";
          elsif (unsigned(rs2_id) = unsigned(rd_ex) and unsigned(opcode_mem) /= "0000011" and unsigned(rs2_id) /= unsigned(rd_mem)) then
            forward_branch_B <= "001";
          elsif (unsigned(rs2_id) = unsigned(rd_mem) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_B <= "010";
          elsif (unsigned(rs2_id) = unsigned(rd_wb) and unsigned(opcode_mem) /= "0000011") then
            forward_branch_B <= "011";
          elsif (unsigned(opcode_mem) = "0000011" and unsigned(rs2_id) = unsigned(rd_mem)) then
            forward_branch_B <= "100";
          else
            forward_branch_B <= "000";
          end if;
        else
          forward_branch_B <= "000";
        end if;
      end if;
    end process;
  
    STALL_PROC : process(opcode, opcode_ex, opcode_mem, rs1_id, rd_ex, rd_mem, rs2_id)
    begin
      if (unsigned(opcode_ex) = "0000011" and unsigned(opcode) = "1100011" and (unsigned(rs1_id) = unsigned(rd_ex) or unsigned(rs2_id) = unsigned(rd_ex))) then
        stall_branch <= '1';
      elsif (unsigned(opcode) = "1100011" and unsigned(opcode_mem) = "0000011" and (unsigned(rs1_id) = unsigned(rd_mem) or unsigned(rs2_id) = unsigned(rd_mem))) then
        stall_branch <= '1';
      else
        stall_branch <= '0';
      end if;
    end process;
  end architecture;
