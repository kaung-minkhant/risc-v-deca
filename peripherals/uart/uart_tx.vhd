LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY uart_tx IS
    GENERIC (
        count_per_bit : NATURAL := 4 -- clock per bit
    );
    PORT (
        clk, send : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        tx_busy, tx, tx_done : OUT STD_LOGIC
    );
END ENTITY uart_tx;

ARCHITECTURE rtl OF uart_tx IS
    SIGNAL tx_flag : STD_LOGIC := '0';

    SIGNAL index : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL word : INTEGER RANGE 0 TO 4 := 0;

    SIGNAL data_seg_1, data_seg_2, data_seg_3, data_seg_4 : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL count : INTEGER := 0;
    CONSTANT HALF_BIT_COUNT : NATURAL := (count_per_bit - 1)/2;
    CONSTANT FULL_BIT_COUNT : NATURAL := count_per_bit - 1;

    signal send_state: std_logic := '0';
    signal send_r : std_logic_vector(2 downto 0) := (others => '0');
BEGIN

    data_seg_1 <= data_in(7 DOWNTO 0);
    data_seg_2 <= data_in(15 DOWNTO 8);
    data_seg_3 <= data_in(23 DOWNTO 16);
    data_seg_4 <= data_in(31 DOWNTO 24);

    SEND_PROC : process(clk)
    begin
        if (clk'event and clk = '1') then
            send_r <= send_r(send_r'left-1 downto 0) & send;
        end if;
    end process;

    PROCESS (clk) IS
        VARIABLE data_full : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
    BEGIN
        
        IF (clk'event AND clk = '1') THEN
            IF (tx_flag = '0') THEN
                tx_done <= '0';
            END IF;
            IF (tx_flag = '0' and send_r(send_r'left downto send_r'left-1)="01") THEN
                tx_flag <= '1';
                word <= 0;
            END IF;

            IF (tx_flag = '1') THEN
                tx_busy <= '1';
                tx_done <= '0';

                IF (word = 0) THEN
                    data_full := '1' & data_seg_1 & '0';
                ELSIF (word = 1) THEN
                    data_full := '1' & data_seg_2 & '0';
                ELSIF (word = 2) THEN
                    data_full := '1' & data_seg_3 & '0';
                ELSIF (word = 3) THEN
                    data_full := '1' & data_seg_4 & '0';
                END IF;

                IF (count < FULL_BIT_COUNT) THEN
                    count <= count + 1;
                ELSE
                    count <= 0;
                END IF;

                IF (count = HALF_BIT_COUNT) THEN
                    tx <= data_full(index);
                    IF (index < 9) THEN
                        index <= index + 1;
                    ELSE
                        index <= 0;
                        IF (word /= 3) THEN
                            word <= word + 1;
                        ELSE
                            word <= 0;
                            tx_flag <= '0';
                            tx_busy <= '0';
                            tx_done <= '1';
                        END IF;
                    END IF;
                END IF;
            ELSE
                tx_busy <= '0';
                tx <= '1';
            END IF;

        END IF;
    END PROCESS;

END ARCHITECTURE rtl;