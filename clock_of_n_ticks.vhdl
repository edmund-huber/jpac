library ieee;
use ieee.std_logic_1164.all;

entity clock_of_n_ticks is
    port (
        clock: out std_logic;
        ticks: out integer
    );
end;

architecture behavior of clock_of_n_ticks is
    signal ticks_buf: integer := 0;
begin
    process (ticks_buf)
    begin
        ticks <= ticks_buf;
        if ticks_buf mod 2 = 0 then
            clock <= '0';
        else
            clock <= '1';
        end if;
        if ticks_buf < 100 then
            ticks_buf <= ticks_buf + 1 after 10 ns;
        end if;
    end process;
end;
