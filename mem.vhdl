library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
    port (
        clk: in std_logic;
        mem_address: in std_logic_vector (7 downto 0);
        mem_value_write: in std_logic_vector (7 downto 0);
        mem_read_or_write: in std_logic;
        mem_req: in std_logic;
        mem_ack: out std_logic;
        mem_value_read: out std_logic_vector (7 downto 0)
    );
end;

architecture behavior of mem is
    signal mem_ack_buf: std_logic;
begin
    -- GHDL's old VHDL spec doesn't allow reading from out ports.
    mem_ack <= mem_ack_buf;

    process (clk)
        type memory_type is array (255 downto 0) of bit_vector (7 downto 0);
        variable memory: memory_type;
    begin
        if rising_edge(clk) then
            -- mem_req = '0' and mem_ack_buf = '0': idle.
            -- mem_req = '1' and mem_ack_buf = '1': waiting on mem_req = '0'.
            if mem_req = '1' and mem_ack_buf = '0' then
                case mem_read_or_write is
                when '0' =>
                    -- Read a value from memory into mem_value_read.
                    mem_value_read <= to_stdlogicvector(memory(to_integer(unsigned(mem_address))));
                when '1' =>
                    -- Write a value from mem_value_write into memory.
                    memory(to_integer(unsigned(mem_address))) := to_bitvector(mem_value_write);
                when others =>
                end case;
                -- Done.
                mem_ack_buf <= '1';
            elsif mem_req = '0' and mem_ack_buf = '1' then
                -- Complete the handshake; we're ready for another operation.
                mem_ack_buf <= '0';
            end if;
        end if;
    end process;
end;
