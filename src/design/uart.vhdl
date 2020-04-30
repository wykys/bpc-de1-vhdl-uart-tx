library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.uart_types.all;

entity uart is
    generic (
        constant FREQ : natural
    );
    port (
        clk_i          : in std_logic;
        stop_config_i  : in stop_config_t;
        speed_config_i : in speed_config_t;
        tx_o           : out std_logic
    );
end uart;

architecture rtl of uart is
    constant BAUD_SLOW         : natural := 9600;   -- db
    constant BAUD_FAST         : natural := 115200; -- bd
    constant BAUD_COUNTER_SLOW : natural := (FREQ / BAUD_SLOW) - 1;
    constant BAUD_COUNTER_FAST : natural := (FREQ / BAUD_FAST) - 1;

    signal clk : std_logic;
    signal tx  : std_logic := '1';

    signal clk_cnt   : natural range 0 to BAUD_COUNTER_SLOW;
    signal buffer_tx : std_logic_vector(7 downto 0) := x"A5";
    signal index     : natural range 0 to 7         := 0;

    signal stop_config  : stop_config_t;
    signal speed_config : speed_config_t;

    type opcode_t is (IDLE, START_BIT, DATA, STOP_BIT);
    signal opcode : opcode_t := IDLE;

begin
    clk <= clk_i;

    process (clk) begin
        if rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
            if (speed_config = SPEED_SLOW and clk_cnt = BAUD_COUNTER_SLOW) or
                (speed_config = SPEED_FAST and clk_cnt = BAUD_COUNTER_FAST) then

                clk_cnt     <= 0;
                stop_config <= stop_config_i;

                case opcode is
                    when START_BIT =>
                        tx     <= '0';
                        opcode <= DATA;
                        index  <= 0;

                    when DATA =>
                        tx    <= buffer_tx(index);
                        index <= index + 1;
                        if index = 7 then
                            index  <= 0;
                            opcode <= STOP_BIT;
                        end if;
                    when STOP_BIT =>
                        tx <= '1';
                        if stop_config = STOP_BIT_ONE then
                            opcode <= IDLE;
                            index  <= 0;
                        else
                            if index = 0 then
                                index <= 1;
                            else
                                index  <= 0;
                                opcode <= IDLE;
                            end if;
                        end if;

                    when others =>
                        index <= index + 1;
                        if index = 7 then
                            index        <= 0;
                            opcode       <= START_BIT;
                            speed_config <= speed_config_i;
                        end if;
                end case;
            end if;
        end if;
    end process;

    tx_o <= tx;

end architecture rtl;