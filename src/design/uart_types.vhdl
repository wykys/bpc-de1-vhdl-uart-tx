
package uart_types is

    -- počet stop bitů jeden nebo dva
    type stop_config_t is (STOP_BIT_ONE, STOP_BIT_TWO);
    -- přenosová rychlost pomalá a rychlá
    type speed_config_t is (SPEED_SLOW, SPEED_FAST);
    -- parita sudá a lichá
    type parity_config_t is (PARITY_EVEN, PARITY_ODD);

end package;