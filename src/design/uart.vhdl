library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.uart_types.all;

entity uart is
    generic (
        constant FREQ : natural
    );
    port (
        clk_i          : in std_logic;
        set_stop_bit_i : in std_logic; -- 0=1b, 1=2b
        tx_o           : out std_logic
    );
end uart;

architecture rtl of uart is
    constant BAUD1         : natural := 9600;   -- db
    constant BAUD2         : natural := 115200; -- bd
    constant BAUD_COUNTER1 : natural := (FREQ / BAUD1) - 1;
    constant BAUD_COUNTER2 : natural := (FREQ / BAUD2) - 1;

    signal clk : std_logic;
    signal tx  : std_logic := '1';

    signal clk_cnt   : natural range 0 to BAUD_COUNTER2;
    signal buffer_tx : std_logic_vector(7 downto 0) := x"00";
    signal index     : natural range 0 to 7         := 0;

    signal stop_config : stop_bit_t := STOP_BIT_ONE;

    type opcode_t is (IDLE, START_BIT, DATA, STOP_BIT);
    signal opcode : opcode_t := IDLE;

begin
    clk <= clk_i;

    process (clk) begin
        if rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
            if clk_cnt = BAUD_COUNTER2 then
                clk_cnt <= 0;
                if set_stop_bit_i = '0' then
                    stop_config <= STOP_BIT_ONE;
                else
                    stop_config <= STOP_BIT_TWO;
                end if;

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
                            index  <= 0;
                            opcode <= START_BIT;
                        end if;
                end case;
            end if;
        end if;
    end process;

    tx_o <= tx;

end architecture rtl;