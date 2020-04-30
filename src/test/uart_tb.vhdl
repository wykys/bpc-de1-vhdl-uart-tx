library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.uart_types.all;

entity uart_tb is
end entity uart_tb;

architecture behavioral of uart_tb is

    constant FREQ        : positive := 1E6; -- Hz
    constant PER_DIV_TWO : time     := 1 sec / (FREQ * 2);
    signal clk           : std_logic;
    signal tx            : std_logic;

    signal speed_config : speed_config_t := SPEED_SLOW;


begin

    dut : entity work.uart
        generic map(
            FREQ => FREQ
        )
        port map(
            clk_i          => clk,
            stop_config_i  => STOP_BIT_ONE,
            speed_config_i => speed_config,
            tx_o           => tx
        );

    clock: process begin
        clk <= '0';
        wait for PER_DIV_TWO;
        clk <= '1';
        wait for PER_DIV_TWO;
    end process clock;

    stim : process begin
        wait for 2 ms;
        speed_config <= SPEED_FAST;
        wait;
    end process stim;

end architecture behavioral;