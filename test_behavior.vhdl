library ieee;
use ieee.std_logic_1164.all;

entity test_behavior is
end test_behavior;

architecture behavior of test_behavior is
    signal clk: std_logic;
    signal ticks: integer;
    signal rst: std_logic;
    signal mem_address: std_logic_vector (7 downto 0);
    signal mem_value_write: std_logic_vector (7 downto 0);
    signal mem_read_or_write: std_logic;
    signal mem_req: std_logic;
    signal mem_ack: std_logic;
    signal mem_value_read: std_logic_vector (7 downto 0);
begin
    clock_component: entity work.clock_of_n_ticks port map (
        clock => clk,
        ticks => ticks
    );
    mem_component: entity work.mem port map (
        clk => clk,
        mem_address => mem_address,
        mem_value_write => mem_value_write,
        mem_read_or_write => mem_read_or_write,
        mem_req => mem_req,
        mem_ack => mem_ack,
        mem_value_read => mem_value_read
    );
    jpac_component: entity work.jpac port map (
        clk => clk,
        rst => rst,
        mem_address => mem_address,
        mem_value_write => mem_value_write,
        mem_read_or_write => mem_read_or_write,
        mem_req => mem_req,
        mem_ack => mem_ack,
        mem_value_read => mem_value_read
    );

    process (clk)
    begin
        if ticks < 10 then
            rst <= '1';
        else
            rst <= '0';
        end if;
    end process;
end;
