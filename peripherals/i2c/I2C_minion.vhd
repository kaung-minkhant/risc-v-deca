------------------------------------------------------------
-- File      : I2C_minion.vhd
------------------------------------------------------------
-- Author    : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
-- Copyright (c) 2019 Peter Samarin
------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
------------------------------------------------------------
ENTITY I2C_minion IS
  GENERIC (
    MINION_ADDR : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011"
  );
  PORT (
    scl : INOUT STD_LOGIC;
    sda : INOUT STD_LOGIC;
    clk : IN STD_LOGIC;
    reset_n : IN STD_LOGIC;
    -- User interface
    read_req : OUT STD_LOGIC;
    data_to_master : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_valid : OUT STD_LOGIC;
    data_from_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END ENTITY I2C_minion;
------------------------------------------------------------
ARCHITECTURE arch OF I2C_minion IS
  TYPE state_t IS (idle, get_address_and_cmd,
    answer_ack_start, write,
    read, read_ack_start,
    read_ack_got_rising, read_stop);
  -- I2C state management
  SIGNAL state_reg : state_t := idle;
  SIGNAL cmd_reg : STD_LOGIC := '0';
  SIGNAL bits_processed_reg : INTEGER RANGE 0 TO 8 := 0;
  SIGNAL continue_reg : STD_LOGIC := '0';

  SIGNAL scl_reg : STD_LOGIC := 'Z';
  SIGNAL sda_reg : STD_LOGIC := 'Z';
  SIGNAL scl_debounced : STD_LOGIC := 'Z';
  SIGNAL sda_debounced : STD_LOGIC := 'Z';

  SIGNAL scl_pre_internal : STD_LOGIC := 'Z';
  SIGNAL scl_internal : STD_LOGIC := '1';
  SIGNAL sda_pre_internal : STD_LOGIC := 'Z';
  SIGNAL sda_internal : STD_LOGIC := '1';

  -- Helpers to figure out next state
  SIGNAL start_reg : STD_LOGIC := '0';
  SIGNAL stop_reg : STD_LOGIC := '0';
  SIGNAL scl_rising_reg : STD_LOGIC := '0';
  SIGNAL scl_falling_reg : STD_LOGIC := '0';

  -- Address and data received from master
  SIGNAL addr_reg : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
  SIGNAL data_reg : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
  SIGNAL data_from_master_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

  SIGNAL scl_prev_reg : STD_LOGIC := 'Z';
  -- Minion writes on scl
  SIGNAL scl_wen_reg : STD_LOGIC := '0';
  SIGNAL scl_o_reg : STD_LOGIC := '0'; -- unused for now
  SIGNAL sda_prev_reg : STD_LOGIC := 'Z';
  -- Minion writes on sda
  SIGNAL sda_wen_reg : STD_LOGIC := '0';
  SIGNAL sda_o_reg : STD_LOGIC := '0';

  -- User interface
  SIGNAL data_valid_reg : STD_LOGIC := '0';
  SIGNAL read_req_reg : STD_LOGIC := '0';
  SIGNAL data_to_master_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN

  PROCESS (clk) IS
  BEGIN
    IF rising_edge(clk) THEN
      scl_pre_internal <= scl;
      sda_pre_internal <= sda;
    END IF;
  END PROCESS;
  scl_internal <= '0' WHEN scl_pre_internal = '0' ELSE
    '1';
  sda_internal <= '0' WHEN sda_pre_internal = '0' ELSE
    '1';
  PROCESS (clk) IS
  BEGIN
    IF rising_edge(clk) THEN
      -- Delay SCL and SDA by 1 clock cycle
      scl_prev_reg <= scl_internal;
      sda_prev_reg <= sda_internal;
      -- Detect rising and falling SCL
      scl_rising_reg <= '0';
      IF scl_prev_reg = '0' AND scl_internal = '1' THEN
        scl_rising_reg <= '1';
      END IF;
      scl_falling_reg <= '0';
      IF scl_prev_reg = '1' AND scl_internal = '0' THEN
        scl_falling_reg <= '1';
      END IF;

      -- Detect I2C START condition
      start_reg <= '0';
      stop_reg <= '0';
      IF scl_internal = '1' AND scl_prev_reg = '1' AND
        sda_prev_reg = '1' AND sda_internal = '0' THEN
        start_reg <= '1';
        stop_reg <= '0';
      END IF;

      -- Detect I2C STOP condition
      IF scl_prev_reg = '1' AND scl_internal = '1' AND
        sda_prev_reg = '0' AND sda_internal = '1' THEN
        start_reg <= '0';
        stop_reg <= '1';
      END IF;

    END IF;
  END PROCESS;

  ----------------------------------------------------------
  -- I2C state machine
  ----------------------------------------------------------
  PROCESS (clk) IS
  BEGIN
    IF rising_edge(clk) THEN
      -- Default assignments
      sda_o_reg <= '0';
      sda_wen_reg <= '0';
      -- User interface
      data_valid_reg <= '0';
      read_req_reg <= '0';

      CASE state_reg IS

        WHEN idle =>
          IF start_reg = '1' THEN
            state_reg <= get_address_and_cmd;
            bits_processed_reg <= 0;
          END IF;

        WHEN get_address_and_cmd =>
          IF scl_rising_reg = '1' THEN
            IF bits_processed_reg < 7 THEN
              bits_processed_reg <= bits_processed_reg + 1;
              addr_reg(6 - bits_processed_reg) <= sda_internal;
            ELSIF bits_processed_reg = 7 THEN
              bits_processed_reg <= bits_processed_reg + 1;
              cmd_reg <= sda_internal;
            END IF;
          END IF;

          IF bits_processed_reg = 8 AND scl_falling_reg = '1' THEN
            bits_processed_reg <= 0;
            IF addr_reg = MINION_ADDR THEN -- check req address
              state_reg <= answer_ack_start;
              IF cmd_reg = '1' THEN -- issue read request 
                read_req_reg <= '1';
                data_to_master_reg <= data_to_master;
              END IF;
            ELSE
              ASSERT false
              REPORT ("I2C: target/minion address mismatch (data is being sent to another minion).")
                SEVERITY note;
              state_reg <= idle;
            END IF;
          END IF;

          ----------------------------------------------------
          -- I2C acknowledge to master
          ----------------------------------------------------
        WHEN answer_ack_start =>
          -- sda_wen_reg <= '1';
          -- sda_o_reg <= '0';
          IF scl_falling_reg = '1' THEN
            IF cmd_reg = '0' THEN
              state_reg <= write;
            ELSE
              state_reg <= read;
            END IF;
          END IF;

          ----------------------------------------------------
          -- WRITE
          ----------------------------------------------------
        WHEN write =>
          IF scl_rising_reg = '1' THEN
            bits_processed_reg <= bits_processed_reg + 1;
            IF bits_processed_reg < 7 THEN
              data_reg(6 - bits_processed_reg) <= sda_internal;
            ELSE
              data_from_master_reg <= data_reg & sda_internal;
              data_valid_reg <= '1';
            END IF;
          END IF;

          IF scl_falling_reg = '1' AND bits_processed_reg = 8 THEN
            state_reg <= answer_ack_start;
            bits_processed_reg <= 0;
          END IF;

          ----------------------------------------------------
          -- READ: send data to master
          ----------------------------------------------------
        WHEN read =>
          sda_wen_reg <= '1';
          IF data_to_master_reg(7 - bits_processed_reg) = '0' THEN
            sda_o_reg <= '0';
          ELSE
            sda_o_reg <= 'Z';
          END IF;

          IF scl_falling_reg = '1' THEN
            IF bits_processed_reg < 7 THEN
              bits_processed_reg <= bits_processed_reg + 1;
            ELSIF bits_processed_reg = 7 THEN
              state_reg <= read_ack_start;
              bits_processed_reg <= 0;
            END IF;
          END IF;

          ----------------------------------------------------
          -- I2C read master acknowledge
          ----------------------------------------------------
        WHEN read_ack_start =>
          IF scl_rising_reg = '1' THEN
            state_reg <= read_ack_got_rising;
            IF sda_internal = '1' THEN -- nack = stop read
              continue_reg <= '0';
            ELSE -- ack = continue read
              continue_reg <= '1';
              read_req_reg <= '1'; -- request reg byte
              data_to_master_reg <= data_to_master;
            END IF;
          END IF;

        WHEN read_ack_got_rising =>
          IF scl_falling_reg = '1' THEN
            IF continue_reg = '1' THEN
              IF cmd_reg = '0' THEN
                state_reg <= write;
              ELSE
                state_reg <= read;
              END IF;
            ELSE
              state_reg <= read_stop;
            END IF;
          END IF;

          -- Wait for START or STOP to get out of this state
        WHEN read_stop =>
          NULL;

          -- Wait for START or STOP to get out of this state
        WHEN OTHERS =>
          ASSERT false
          REPORT ("I2C: error: ended in an impossible state.")
            SEVERITY error;
          state_reg <= idle;
      END CASE;

      --------------------------------------------------------
      -- Reset counter and state on start/stop
      --------------------------------------------------------
      IF start_reg = '1' THEN
        state_reg <= get_address_and_cmd;
        bits_processed_reg <= 0;
      END IF;

      IF stop_reg = '1' THEN
        state_reg <= idle;
        bits_processed_reg <= 0;
      END IF;

      IF reset_n = '0' THEN
        state_reg <= idle;
      END IF;
    END IF;
  END PROCESS;

  ----------------------------------------------------------
  -- I2C interface
  ----------------------------------------------------------
  sda <= sda_o_reg WHEN sda_wen_reg = '1' ELSE
    'Z';
  scl <= scl_o_reg WHEN scl_wen_reg = '1' ELSE
    'Z';
  ----------------------------------------------------------
  -- User interface
  ----------------------------------------------------------
  -- Master writes
  data_valid <= data_valid_reg;
  data_from_master <= data_from_master_reg;
  -- Master reads
  read_req <= read_req_reg;
END ARCHITECTURE arch;