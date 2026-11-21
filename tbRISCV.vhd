
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Processador is
end tb_Processador;

architecture sim of tb_Processador is

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

begin

    -- Clock de 10 ns
    clk <= not clk after 5 ns;

    -- Processador em teste
    DUT: entity work.Processador
        port map (
            clk   => clk,
            reset => reset
        );

    -- Sequência de teste
    processo_teste: process
    begin

        report "INICIO DO TESTE DO PROCESSADOR";

        -- Mantém o processador em reset
        reset <= '1';
        wait for 20 ns;

        -- Libera o processador
        reset <= '0';

        -- Aguarda a execução do programa
        wait for 3000 ns;

        report "FIM DA EXECUCAO DO PROGRAMA";
        report "Confira os registradores e a memoria na waveform.";

        wait;
    end process;

end sim;

