library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
  port (
    rs1_addr_ex, rs2_addr_ex,rd_addr_mem, rd_addr_wb, rs2_addr_mem: in  std_logic_vector(4 downto 0);
    reg_write_mem, reg_write_wb,data_memory_write: in std_logic;
    opcode_i, opcode_mem : in std_logic_vector(6 downto 0);
    forwardA, forwardB: buffer std_logic_vector(1 downto 0)
  );
end forwarding_unit;

architecture rtl of forwarding_unit is
  begin
    HAZARD_PROC : process(reg_write_mem, reg_write_wb, opcode_mem, rs1_addr_ex, rs2_addr_ex, rd_addr_mem, rd_addr_wb)
    begin
      
      if (reg_write_mem = '1' or reg_write_wb = '1') then
        if (unsigned(rs1_addr_ex) = unsigned(rd_addr_wb) and reg_write_wb = '1' and unsigned(rd_addr_wb) /= unsigned(rd_addr_mem)) then
          forwardA <= "01";
        elsif (unsigned(rs1_addr_ex) = unsigned(rd_addr_mem) and  (opcode_mem /= "0000011" or unsigned(rd_addr_wb) = unsigned(rd_addr_mem)) and reg_write_mem = '1') then 
          forwardA <= "10";
        elsif (unsigned(rs1_addr_ex) = unsigned(rd_addr_mem) and opcode_mem = "0000011" and reg_write_mem = '1') then
          forwardA <= "11";
        else
          forwardA <= "00";
        end if;
      else
        forwardA <= "00";
      end if;
  
      if (reg_write_mem = '1' or reg_write_wb = '1') then
        if (unsigned(rs2_addr_ex) = unsigned(rd_addr_wb) and reg_write_wb = '1' and unsigned(rd_addr_wb) /= unsigned(rd_addr_mem)) then
          forwardB <= "01";
        elsif (unsigned(rs2_addr_ex) = unsigned(rd_addr_mem) and  (opcode_mem /= "0000011" or unsigned(rd_addr_wb) = unsigned(rd_addr_mem)) and reg_write_mem = '1') then 
          forwardB <= "10";
        elsif (unsigned(rs2_addr_ex) = unsigned(rd_addr_mem) and opcode_mem = "0000011" and reg_write_mem = '1') then
          forwardB <= "11";
        else
          forwardB <= "00";
        end if;
      else
        forwardB <= "00";
      end if;
    
    end process;
  
  
  end architecture;
