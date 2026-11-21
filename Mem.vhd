
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memoria is
    port (
        clk          : in  std_logic;
        MemRead      : in  std_logic;
        MemWrite     : in  std_logic;

        endereco     : in  std_logic_vector(31 downto 0);
        DadoEscrita  : in  std_logic_vector(31 downto 0);
        DadoLido     : out std_logic_vector(31 downto 0)
    );
end Memoria;

architecture Behavioral of Memoria is

    type memoria_array is array (0 to 4095)
        of std_logic_vector(31 downto 0);


signal memoria : memoria_array := (
 others => (others => '0')
);

    signal indice : integer range 0 to 4095;

begin

    -- Converte o endereco de byte em indice de palavra.
    indice <= to_integer(unsigned(endereco(13 downto 2)));

    -- Leitura assincrona
    process(endereco, MemRead, memoria)
    begin
        if MemRead = '1' then

            if unsigned(endereco(31 downto 14)) = 0 then
                DadoLido <= memoria(
                    to_integer(unsigned(endereco(13 downto 2)))
                );
            else
                DadoLido <= (others => '0');
            end if;

        else
            DadoLido <= (others => '0');
        end if;
    end process;

    -- Escrita sincronizada
    process(clk)
    begin
        if rising_edge(clk) then

            if MemWrite = '1' then

                if unsigned(endereco(31 downto 14)) = 0 then
                    memoria(indice) <= DadoEscrita;
                end if;

            end if;

        end if;
    end process;

end Behavioral;

