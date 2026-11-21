
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        entrada: in  std_logic_vector(31 downto 0);
        saida  : out std_logic_vector(31 downto 0)
    );
end PC;

architecture Behavioral of PC is

    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');

begin

    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= (others => '0');

        elsif rising_edge(clk) then
            if enable = '1' then
                pc_reg <= entrada;
            end if;
        end if;
    end process;

    saida <= pc_reg;

end Behavioral;

