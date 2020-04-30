library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.uart_types.all;

entity uart_tb is
end entity uart_tb;

architecture behavioral of uart_tb is

    constant FREQ        : positive := 1E6; -- Hz
    constant PER_DIV_TWO : time     := 1 sec / (FREQ * 2);
    signal clk           : std_logic;
    signal tx            : std_logic;
    signal set_stop_bit : std_logic := '1';
begin

    dut : entity work.uart
        generic map(
            FREQ => FREQ
        )
        port map(
            clk_i => clk,
            set_stop_bit_i => set_stop_bit,
            tx_o  => tx
        );

    stim : process begin



        while true loop

            clk <= '0';
            wait for PER_DIV_TWO;

            clk <= '1';
            wait for PER_DIV_TWO;

        end loop;
    end process stim;

end architecture behavioral;