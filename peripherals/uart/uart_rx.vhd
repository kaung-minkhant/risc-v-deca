LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY uart_rx IS
    GENERIC (
        count_per_bit : NATURAL := 20 -- clock per bit
    );
    PORT (
        rx, clk : IN STD_LOGIC;
        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out_32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rx_busy, rx_done : OUT STD_LOGIC;
        mode32 : IN STD_LOGIC;
        frame_error : OUT STD_LOGIC
    );
END ENTITY uart_rx;

ARCHITECTURE rtl OF uart_rx IS
    SIGNAL rx_flag : STD_LOGIC := '0';

    SIGNAL index : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL word : INTEGER RANGE 0 TO 3 := 0;

    SIGNAL count : INTEGER := 0;
    CONSTANT HALF_BIT_COUNT : NATURAL := (count_per_bit - 1)/2;
    CONSTANT FULL_BIT_COUNT : NATURAL := count_per_bit - 1;
BEGIN

    PROCESS (clk) IS
        VARIABLE data_full : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        VARIABLE data_out_var : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        IF (clk'event AND clk = '1') THEN
            IF (rx_flag = '0') THEN
                rx_done <= '0';
                frame_error <= '0';
            END IF;

            IF (rx = '0') THEN
                rx_flag <= '1';
            END IF;

            IF (rx_flag = '1') THEN
                rx_busy <= '1';
                IF (count < FULL_BIT_COUNT) THEN
                    count <= count + 1;
                ELSE
                    count <= 0;
                END IF;

                IF (count = HALF_BIT_COUNT) THEN
                    data_full(index) := rx;
                    IF (index < 9) THEN
                        index <= index + 1;
                    ELSE
                        index <= 0;
                        rx_flag <= '0';
                        rx_busy <= '0';
                        IF (data_full(0) = '0' AND data_full(9) = '1') THEN
                            data_out_var := data_full(8 DOWNTO 1);
                            data_out <= data_out_var;
                            IF (mode32 = '1') THEN
                                data_out_32(8 * word + 7 DOWNTO 8 * word + 0) <= data_out_var;
                                IF (word /= 3) THEN
                                    word <= word + 1;
                                ELSE
                                    word <= 0;
                                END IF;
                            END IF;
                            IF (mode32 = '1') THEN
                                IF (word = 3) THEN
                                    rx_done <= '1';
                                END IF;
                            ELSE
                                rx_done <= '1';
                            END IF;
                            count <= 0;
                            frame_error <= '0';
                        ELSE
                            data_out <= x"00";
                            frame_error <= '1';
                        END IF;
                    END IF;
                END IF;
            ELSE
                rx_busy <= '0';
            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE rtl;