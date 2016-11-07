LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

ENTITY dram_controller_tb IS
	PORT(
		CLK         : in    std_logic;
		SDRAM_CKE   : out   std_logic;
		SDRAM_CLK   : out   std_logic;
		SDRAM_CS_N  : out   std_logic;
		SDRAM_WE_N  : out   std_logic;
		SDRAM_CAS_N : out   std_logic;
		SDRAM_RAS_N : out   std_logic;
		SDRAM_A0    : out   std_logic;
		SDRAM_A1    : out   std_logic;
		SDRAM_A2    : out   std_logic;
		SDRAM_A3    : out   std_logic;
		SDRAM_A4    : out   std_logic;
		SDRAM_A5    : out   std_logic;
		SDRAM_A6    : out   std_logic;
		SDRAM_A7    : out   std_logic;
		SDRAM_A8    : out   std_logic;
		SDRAM_A9    : out   std_logic;
		SDRAM_A10   : out   std_logic;
		SDRAM_A11   : out   std_logic;
		SDRAM_A12   : out   std_logic;
		SDRAM_BA0   : out   std_logic;
		SDRAM_BA1   : out   std_logic;
		SDRAM_DQML  : out   std_logic;
		SDRAM_DQMH  : out   std_logic;
		SDRAM_DQ0   : inout std_logic;
	   SDRAM_DQ1   : inout std_logic;
	   SDRAM_DQ2   : inout std_logic;
		SDRAM_DQ3   : inout std_logic;
		SDRAM_DQ4   : inout std_logic;
		SDRAM_DQ5   : inout std_logic;
		SDRAM_DQ6   : inout std_logic;
		SDRAM_DQ7   : inout std_logic;
		SDRAM_DQ8   : inout std_logic;
		SDRAM_DQ9   : inout std_logic;
		SDRAM_DQ10  : inout std_logic;
		SDRAM_DQ11  : inout std_logic;
		SDRAM_DQ12  : inout std_logic;
		SDRAM_DQ13  : inout std_logic;
		SDRAM_DQ14  : inout std_logic;
		SDRAM_DQ15  : inout std_logic;
		DS_DP       : out   std_logic;
		DS_G        : out   std_logic;
		DS_C        : out   std_logic;
		DS_D        : out   std_logic
	);
END dram_controller_tb;

ARCHITECTURE RTL OF dram_controller_tb IS
	-- SDRAM Controller Wires:
	signal restart_system    : std_logic := '0'; -- Drive
	signal sdram_cmd_ready   : std_logic := '0'; -- Read
	signal sdram_cmd_en      : std_logic := '0'; -- Drive
	signal sdram_cmd_wr      : std_logic := '0'; -- Drive
	signal sdram_cmd_address : std_logic_vector(22 downto 0) := (others => '0'); -- Drive
	signal sdram_cmd_byte_en : std_logic_vector(3  downto 0) := (others => '0'); -- Drive
	signal sdram_cmd_data_in : std_logic_vector(31 downto 0) := (others => '0'); -- Drive
	signal sdram_data_out    : std_logic_vector(31 downto 0) := (others => '0'); -- Read
	signal sdram_data_ready  : std_logic := '0'; -- Read
	
	-- Physical SDRAM Wires:
	signal sdram_an    : std_logic_vector(12 downto 0);
	signal sdram_ban   : std_logic_vector(1  downto 0);
	signal sdram_dqmhl : std_logic_vector(1  downto 0);
	signal sdram_dqn   : std_logic_vector(15 downto 0);
	
	type fsm_t is (s_init_pll,s_init,s_init_wait,s_write,s_write_wait,s_write_wait2,s_read,s_read_wait,s_idle);
	signal state : fsm_t := s_init_pll;
	attribute FSM_ENCODING of state : signal is "ONE-HOT";
	
	signal master_clk  : std_logic := '0';
	signal pll_running : std_logic := '0';
	signal leds        : std_logic_vector(3 downto 0) := (others => '0');
	signal new_clk     : std_logic := '0';
	signal pll_reset   : std_logic := '0';
BEGIN
	master_clk <= CLK when pll_running = '0' ELSE new_clk;
	
	DS_DP <= not leds(0);
	DS_G  <= not leds(1);
	DS_C  <= not leds(2);
	DS_D  <= not leds(3);
	
	pll_inst : ENTITY work.pll PORT MAP (
		areset => pll_reset,
		inclk0 => CLK,
		c0	    => new_clk
	);

	DRAM_Controller1 : ENTITY work.DRAM_Controller 
		PORT MAP(
			new_clk, restart_system, sdram_cmd_ready, sdram_cmd_en, 
			sdram_cmd_wr, sdram_cmd_address, sdram_cmd_byte_en, 
			sdram_cmd_data_in, sdram_data_out, sdram_data_ready, 
			sdram_cke, sdram_clk, sdram_cs_n, sdram_we_n, sdram_cas_n,
			sdram_ras_n, sdram_an, sdram_ban, sdram_dqmhl, sdram_dqn
		);
		
	sdram_a0   <= sdram_an(0);
	sdram_a1   <= sdram_an(1);
	sdram_a2   <= sdram_an(2);
	sdram_a3   <= sdram_an(3);
	sdram_a4   <= sdram_an(4);
	sdram_a5   <= sdram_an(5);
	sdram_a6   <= sdram_an(6);
	sdram_a7   <= sdram_an(7);
	sdram_a8   <= sdram_an(8);
	sdram_a9   <= sdram_an(9);
	sdram_a10  <= sdram_an(10);
	sdram_a11  <= sdram_an(11);
	sdram_a12  <= sdram_an(12);
	
	SDRAM_DQMH <= sdram_dqmhl(0);
	SDRAM_DQML <= sdram_dqmhl(1);
	
	SDRAM_BA0  <= sdram_ban(0);
	SDRAM_BA1  <= sdram_ban(1);
	
	sdram_dq0  <= sdram_dqn(0);
	sdram_dq1  <= sdram_dqn(1);
	sdram_dq2  <= sdram_dqn(2);
	sdram_dq3  <= sdram_dqn(3);
	sdram_dq4  <= sdram_dqn(4);
	sdram_dq5  <= sdram_dqn(5);
	sdram_dq6  <= sdram_dqn(6);
	sdram_dq7  <= sdram_dqn(7);
	sdram_dq8  <= sdram_dqn(8);
	sdram_dq9  <= sdram_dqn(9);
	sdram_dq10 <= sdram_dqn(10);
	sdram_dq11 <= sdram_dqn(11);
	sdram_dq12 <= sdram_dqn(12);
	sdram_dq13 <= sdram_dqn(13);
	sdram_dq14 <= sdram_dqn(14);
	sdram_dq15 <= sdram_dqn(15);
	
	----------------
	-- Testbench: --
	----------------
	process(master_clk) begin
		if master_clk'event and master_clk = '1' then
	
			if new_clk = '1' then
				pll_running <= '1';
			end if;
			
			case state is
				when s_init_pll => -- Initialize PLL
					pll_reset <= '1';
					state     <= s_init;
					
				when s_init => -- Trigger startup cycle
					restart_system <= '1';
					sdram_cmd_byte_en <= (others => '1');
					state <= s_init_wait;
					pll_reset <= '0';
					
				when s_init_wait => -- Wait for startup to finish
					restart_system <= '0';
					if sdram_cmd_ready = '1' then sdram_cmd_en <= '0'; state <= s_write; end if; -- Next FSM state
					
				when s_write => -- Write data
					-- Address:
					sdram_cmd_address <= std_logic_vector(to_unsigned(0, sdram_cmd_address'length));
					-- Data:
					sdram_cmd_data_in <= std_logic_vector(to_unsigned(12, sdram_cmd_data_in'length));
					
					sdram_cmd_wr <= '1';
					sdram_cmd_en <= '1'; -- Request transaction
					state <= s_write_wait; -- Next FSM state
				
				when s_write_wait => -- Wait for data to finish writing
					sdram_cmd_en <= '0';
					sdram_cmd_wr <= '0';
					if sdram_cmd_ready = '1' then state <= s_write_wait2; end if; -- Next FSM state
				
				when s_write_wait2 =>
					if sdram_cmd_ready = '1' then state <= s_read; end if; -- Next FSM state
			
				when s_read => -- Read data
					-- Address:
					sdram_cmd_address <= std_logic_vector(to_unsigned(0, sdram_cmd_address'length));
					
					sdram_cmd_data_in <= (others => '0');
					sdram_cmd_wr <= '0';
					sdram_cmd_en <= '1';
					state <= s_read_wait; -- Next FSM state
					
				when s_read_wait => -- Wait for data to finish reading. Then grab the output and output the data into the LEDs
					sdram_cmd_en <= '0';
					if sdram_data_ready = '1' then 
						leds  <= sdram_data_out(3 downto 0);
						state <= s_idle; 
					end if; -- Next FSM state
					
				when s_idle => state <= s_idle; -- Idle
				when others => state <= s_idle; -- Idle
			end case;
		end if;
	end process;
END ARCHITECTURE;