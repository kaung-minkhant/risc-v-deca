LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY spi_slave IS
  PORT (
    clk : IN STD_LOGIC; --spi clk from master
    data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rx_dv : IN STD_LOGIC;
    reset_n : IN STD_LOGIC; --active low reset
    ss_n : IN STD_LOGIC; --active low slave select
    mosi : IN STD_LOGIC; --master out, slave in
    miso : OUT STD_LOGIC;
    rx_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  ); --master in, slave out
END spi_slave;

ARCHITECTURE rtl OF spi_slave IS

  SIGNAL rx_buf : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --receiver buffer
  SIGNAL tx_buf : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --transmit buffer
  SIGNAL miso_count : INTEGER RANGE 0 TO 7 := 7;
BEGIN

  UPDATE_PROC : PROCESS (rx_dv, reset_n, data_wr)
  BEGIN
    IF (reset_n = '0') THEN
      tx_buf <= (OTHERS => '0');
    ELSE
      IF ((rx_dv'event AND rx_dv = '1') OR (data_wr'event AND miso_count = 7)) THEN
        tx_buf <= data_wr;
      END IF;
    END IF;
  END PROCESS;
  -----------------------------------------------------------------
  --Sampling MISO on Falling rising_edge
  ------------------------------------------------------------------
  PROCESS (clk, reset_n)
  BEGIN

    IF (reset_n = '0') THEN
      miso_count <= 7;
    ELSIF falling_edge(clk) THEN
      IF (ss_n = '0') THEN
        IF (miso_count = 0) THEN
          miso_count <= 7;
        ELSE
          miso_count <= miso_count - 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  miso <= 'Z' WHEN ss_n = '1' ELSE
    tx_buf(miso_count);

  --------------------------------------------------------------------
  --Sampling MOSI Data on rising_edge
  --------------------------------------------------------------------
  PROCESS (clk, reset_n)
    VARIABLE bitCount : INTEGER RANGE -1 TO 7;
  BEGIN

    IF (reset_n = '0') THEN
      bitCount := 7;
      rx_buf <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      IF (ss_n = '0') THEN
        rx_buf(bitCount) <= mosi; -- MSB bit is received first
        bitCount := bitCount - 1;

        IF (bitCount =- 1) THEN
          bitCount := 7;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  rx_data <= rx_buf;
END ARCHITECTURE;