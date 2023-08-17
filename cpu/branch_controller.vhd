library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_controller is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        func3 : in std_logic_vector(2 downto 0);
        branch_condition : in std_logic;
        clk, clk_main, reset_n: in std_logic;
        rs1_data, rs2_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        opcode: in std_logic_vector(6 downto 0);
        branch : out std_logic
    );
end branch_controller;

architecture rtl of branch_controller is
    signal equal : std_logic := '0';
    signal clk_r : std_logic_vector(2 downto 0) := (others => '0');
    signal branch_pos_edge, branch_neg_edge : std_logic := '0';
begin
    equal <= '1' when (unsigned(rs1_data) = unsigned(rs2_data)) else 
        '0' when (unsigned(rs1_data) /= unsigned(rs2_data)) else
        '0';

    EDGE_PROC : process(clk_main)
    begin
        if (clk_main'event and clk_main='1') then
            clk_r <= clk_r(clk_r'left-1 downto 0) & clk;
        end if;
    end process;

    POSITIVE_EDGE_PROC : process(clk)
    begin
        if (clk'event and clk = '1') then
            branch_pos_edge <= '0';
        end if;
    end process;

    NEGATIVE_EDGE_PROC : process(clk, branch_condition, func3, equal)
    begin
        if (clk'event and clk='0') then
            if (branch_condition = '1') then
                case func3 is
                    when "000" => 
                        branch_neg_edge <= equal;
                    when "001" =>
                        branch_neg_edge <= not equal;
                    when others =>
                        branch_neg_edge <= '0';
                end case;
            end if;
        end if;
    end process;

    -- branch <= '0' when reset_n = '0' else
    --         branch_pos_edge when clk = '1' else
    --         branch_neg_edge when clk = '0' else
    --         '0';


    BRANCH_LOGIC_PROC : process(func3, branch_condition, equal, clk_r, reset_n)
    begin
        if (reset_n = '0') then
            branch <= '0';
        elsif (clk_r(clk_r'left downto clk_r'left-1) = "01") then
            branch <= '0';
        elsif (clk_r(clk_r'left downto clk_r'left-1) = "10") then
          if (branch_condition = '1') then
            case func3 is
                when "000" =>
                    branch <= equal;
                when "001" =>
                    branch <= not equal;
                when others =>
                    branch <= '0';
            end case;
          end if;
        end if;        
    end process;

end architecture;
