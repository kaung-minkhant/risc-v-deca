LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_container IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32
    );
    PORT (
        -- inputs
        -- address_offset : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        added_address_debug : out std_logic_vector(31 downto 0);
        branch_target : in std_logic_vector(DATA_WIDTH-1 downto 0);
        stall : in std_logic;

        -- output address
        pc_address : buffer STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        pc_address_next : out std_logic_vector(DATA_WIDTH-1 downto 0);

        -- reset and clock
        reset_n, clk, clk_main : IN STD_LOGIC;

        -- controls
        -- load, branch/add (1 = branch)
        branch_condition: In std_logic;
        controls : IN STD_LOGIC_VECTOR(1 DOWNTO 0)

    );
END pc_container;

ARCHITECTURE rtl OF pc_container IS

    COMPONENT pc IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32
        );
        PORT (
    -- addresses
    input_addr : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    branch_addr : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    inst_addr  : out std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- clock and reset
    reset_n, clk, clk_main : IN STD_LOGIC;

    -- control 
    load : IN STD_LOGIC;
    branch: in std_logic
        );
    END COMPONENT;

    component adder is
        generic (
          DATA_WIDTH : integer := 8
        );
        port (
    A : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    B : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    stall : in std_logic;
    cin : in std_logic;
    result : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    cout : out std_logic
        );
      end component;
    signal load, add_n_branch, added_cout, branch_cout: std_logic := '0';
    signal address_buffer, added_address, branch_address : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
BEGIN
    added_address_debug <= added_address;
    load <= controls(1);
    add_n_branch <= controls(0);
    pc_u : pc
    GENERIC MAP(
        DATA_WIDTH => DATA_WIDTH
    ) port map (
        reset_n =>  reset_n, clk => clk, clk_main => clk_main, load =>  load, inst_addr => pc_address, 
        input_addr =>  added_address, branch => add_n_branch, branch_addr => branch_target
    );

    increment_adder : adder 
    generic map (
        DATA_WIDTH =>  DATA_WIDTH
    ) port map(
      A => pc_address, B => x"00000004", cin =>  '0', result =>  added_address, cout =>  added_cout, stall => stall
    );

    -- branch_adder : adder 
    -- generic map (
    --     DATA_WIDTH =>  DATA_WIDTH
    -- ) port map(
    --     A => pc_address, B => address_offset, cin =>  '0', result =>  branch_address, cout =>  branch_cout
    -- );

    address_buffer <= branch_target when branch_condition = '1'  else
        added_address; 
    pc_address_next <= address_buffer;
END ARCHITECTURE;
