library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
use STD.ENV.ALL;

architecture Teste of Memoria is

    type memoria_array is array (0 to 4095) of std_logic_vector(31 downto 0);
    signal palavras : memoria_array := (others => (others => '0'));

    type resultados_array is array (0 to 23) of std_logic_vector(31 downto 0);
    constant esperado : resultados_array := (
         0 => x"0000000E", -- ORI 12
         1 => x"0000000A", -- ORI 0
         2 => x"FFFFFFFF", -- ORI -1
         3 => x"FFFFF80A", -- ORI -2048
         4 => x"000007FF", -- ORI 2047
         5 => x"00000008", -- ANDI 12
         6 => x"00000000", -- ANDI 0
         7 => x"0000000A", -- ANDI -1
         8 => x"00000000", -- ANDI -2048
         9 => x"0000000A", -- ANDI 2047
        10 => x"00000006", -- XORI 12
        11 => x"0000000A", -- XORI 0
        12 => x"FFFFFFF5", -- XORI -1
        13 => x"FFFFF80A", -- XORI -2048
        14 => x"000007F5", -- XORI 2047
        15 => x"0000000F", -- ADDI 5
        16 => x"00000005", -- ADDI -5
        17 => x"0000040A", -- ADDI 1024
        18 => x"FFFFF80A", -- ADDI -2048
        19 => x"00000809", -- ADDI 2047
        20 => x"00000000", -- escrita em x0
        21 => x"00000008", -- AND tipo R
        22 => x"0000000E", -- OR tipo R
        23 => x"00000006"  -- XOR tipo R
    );

begin

    -- Mesmo acesso por palavra da memoria original.
    process(endereco, MemRead, palavras)
    begin
        if MemRead = '1' and unsigned(endereco(31 downto 14)) = 0 then
            DadoLido <= palavras(to_integer(unsigned(endereco(13 downto 2))));
        else
            DadoLido <= (others => '0');
        end if;
    end process;

    process
        file programa : text open read_mode is "tests/programa_imm.hex";
        variable linha : line;
        variable palavra : std_logic_vector(31 downto 0);
        variable carregadas : integer := 0;
        variable aprovados : integer := 0;
    begin
        while not endfile(programa) loop
            assert carregadas < palavras'length
                report "Programa maior que a memoria" severity failure;
            readline(programa, linha);
            hread(linha, palavra);
            palavras(carregadas) <= palavra;
            carregadas := carregadas + 1;
        end loop;

        report "Instrucoes carregadas: " & integer'image(carregadas);

        loop
            wait until rising_edge(clk);
            if MemWrite = '1' then
                assert aprovados < esperado'length
                    report "Escrita extra na memoria" severity failure;
                assert unsigned(endereco) = to_unsigned(512 + 4 * aprovados, 32)
                    report "Endereco inesperado no teste " & integer'image(aprovados + 1)
                    severity failure;
                assert DadoEscrita = esperado(aprovados)
                    report "Teste " & integer'image(aprovados + 1) &
                           ": esperado " & to_hstring(esperado(aprovados)) &
                           ", obtido " & to_hstring(DadoEscrita)
                    severity failure;

                palavras(to_integer(unsigned(endereco(13 downto 2)))) <= DadoEscrita;
                report "APROVADO " & integer'image(aprovados + 1) &
                       ": " & to_hstring(DadoEscrita);
                aprovados := aprovados + 1;

                if aprovados = esperado'length then
                    report "24 testes aprovados, 0 reprovados";
                    finish;
                end if;
            end if;
        end loop;
    end process;

    process
    begin
        wait for 3000 ns;
        assert false report "Tempo esgotado antes dos 24 testes" severity failure;
    end process;

end Teste;
