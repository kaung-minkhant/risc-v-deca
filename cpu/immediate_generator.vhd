LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY immediate_generator IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        instruction : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        immediate : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END immediate_generator;

ARCHITECTURE rtl OF immediate_generator IS
    SIGNAL opcode : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate_buffer_I : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate_buffer_S : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate_buffer_SB : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate_extended : signed(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    opcode <= instruction(6 DOWNTO 0);

    -- s type 00001110100101010011100000100011
    -- i type 00001111000001010011010010000011
    -- sb type 00001110000000000000100001100011

    IMMEDIATE_DECODING_PROC : PROCESS (opcode, instruction)
    BEGIN
        CASE opcode IS

            WHEN "0110011" => -- R type
                immediate_buffer_I <= (OTHERS => '0');
            WHEN "0010011" | "0000011" => -- I type
                immediate_buffer_I <= instruction(31 DOWNTO 20);
            WHEN "0100011" => -- S type
                immediate_buffer_S <= instruction(31 DOWNTO 25) & instruction(11 DOWNTO 7);
            when "1100011" => -- SB type
                immediate_buffer_SB <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);
            WHEN OTHERS =>
                immediate_buffer_I <= (OTHERS => '0');

        END CASE;
    END PROCESS;

    WITH opcode SELECT
        immediate_extended <= resize(signed(immediate_buffer_I), immediate_extended'length) WHEN "0010011" | "0000011",
        resize(signed(immediate_buffer_S), immediate_extended'length) WHEN "0100011",
        resize(signed(immediate_buffer_SB), immediate_extended'length) WHEN "1100011",
        (OTHERS => '0') WHEN OTHERS;

    immediate <= STD_LOGIC_VECTOR(immediate_extended);
END ARCHITECTURE;