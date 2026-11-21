
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registrador is
    generic (
        WSIZE : natural := 32
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        en    : in std_logic;

        D : in std_logic_vector(WSIZE-1 downto 0);
        Q : out std_logic_vector(WSIZE-1 downto 0)
    );
end Registrador;

architecture Behavioral of Registrador is

    signal reg : std_logic_vector(WSIZE-1 downto 0)
                 := (others => '0');

begin

    process(clk, reset)
    begin

        if reset = '1' then
            reg <= (others => '0');

        elsif rising_edge(clk) then

            if en = '1' then
                reg <= D;
            end if;

        end if;

    end process;

    Q <= reg;

end Behavioral;

