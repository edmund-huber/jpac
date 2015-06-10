library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jpac is
    port (
        clk: in std_logic;
        rst: in std_logic;
        mem_address: out std_logic_vector (7 downto 0);
        mem_value_write: out std_logic_vector (7 downto 0);
        mem_read_or_write: out std_logic;
        mem_req: out std_logic;
        mem_ack: in std_logic;
        mem_value_read: in std_logic_vector (7 downto 0)
    );
end;

architecture behavior of jpac is
begin
    process (clk)
        type jpac_states is (
            fresh,
            fetch_ip,
            wait_fetch_ip_plus_1,
            fetch_ip_plus_1,

            wait_fetch_value_for_add,
            fetch_value_for_add,
            wait_fetch_dp_for_add,
            fetch_dp_for_add,

            wait_fetch_value_for_copy,
            fetch_value_for_copy,

            wait_write,
            write
        );
        variable state: jpac_states;

        variable ip: std_logic_vector (7 downto 0);
        variable dp: std_logic_vector (7 downto 0);
        variable value: std_logic_vector (7 downto 0);
    begin
        if rising_edge(clk) then
            -- Reset
            if rst = '1' then
                state := fresh;
                ip := "00000000";
                dp := "00000000";

            -- Fetch an instruction+data and decide what to do next based on
            -- the instruction.
            elsif state = fresh and mem_ack = '0' then
                -- Fetch an instruction at the address IP.
                state := fetch_ip;
                mem_address <= ip;
                mem_read_or_write <= '0';
                mem_req <= '1';
            elsif state = fetch_ip and mem_ack = '1' then
                -- Wait for the memory controller to be free again.
                state := wait_fetch_ip_plus_1;
                value := mem_value_read;
                mem_req <= '0';
            elsif state = wait_fetch_ip_plus_1 and mem_ack = '0' then
                -- Fetch the instruction data at IP+1.
                state := fetch_ip_plus_1;
                mem_address <= std_logic_vector(unsigned(ip) + 1);
                mem_read_or_write <= '0';
                mem_req <= '1';
            elsif state = fetch_ip_plus_1 and mem_ack = '1' then
                mem_req <= '0';
                if value = "00" then
                    -- Jump
                    state := fresh;
                    ip := mem_value_read;
                elsif value = "01" then
                    -- Point
                    state := fresh;
                    dp := mem_value_read;
                elsif value = "10" then
                    -- Add
                    state := wait_fetch_value_for_add;
                    value := mem_value_read;
                elsif value = "11" then
                    -- Copy
                    state := wait_fetch_value_for_copy;
                    value := mem_value_read;
                end if;

            -- Add
            elsif state = wait_fetch_value_for_add and mem_ack = '0' then
                state := fetch_value_for_add;
                mem_address <= value;
                mem_read_or_write <= '0';
                mem_req <= '1';
            elsif state = fetch_value_for_add and mem_ack = '1' then
                state := wait_fetch_dp_for_add;
                value := mem_value_read;
                mem_req <= '0';
            elsif state = wait_fetch_dp_for_add and mem_ack = '0' then
                state := fetch_dp_for_add;
                mem_address <= dp;
                mem_read_or_write <= '0';
                mem_req <= '1';
            elsif state = fetch_dp_for_add and mem_ack = '1' then
                state := wait_write;
                value := std_logic_vector(unsigned(value) + unsigned(mem_value_read));
                mem_req <= '0';

            -- Copy
            elsif state = wait_fetch_value_for_copy and mem_ack = '0' then
                state := fetch_value_for_copy;
                mem_address <= value;
                mem_read_or_write <= '0';
                mem_req <= '1';
            elsif state = fetch_value_for_copy and mem_ack = '1' then
                state := wait_write;
                value := mem_value_read;
                mem_req <= '0';

            -- Add or Copy
            elsif state = wait_write and mem_ack = '0' then
                state := write;
                mem_address <= dp;
                mem_read_or_write <= '1';
                mem_value_write <= value;
                mem_req <= '1';
            elsif state = write and mem_ack = '1' then
                state := fresh;
                mem_req <= '0';
            end if;
        end if;
    end process;
end;
