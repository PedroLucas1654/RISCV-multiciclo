
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controle is
    port (
        clk, reset : in std_logic;
        instrucao  : in std_logic_vector(31 downto 0);

        MemRead, MemWrite : out std_logic;
        IorD              : out std_logic;
        IRWrite           : out std_logic;
        MDRWrite          : out std_logic;

        AWrite, BWrite    : out std_logic;
        RegWrite          : out std_logic;
        ALUOutWrite       : out std_logic;

        PCInstrWrite      : out std_logic;
        PCBackWrite       : out std_logic;

        ALUSrcA           : out std_logic_vector(1 downto 0);
        ALUSrcB           : out std_logic_vector(1 downto 0);
        ALUOp             : out std_logic_vector(1 downto 0);

        PCWrite            : out std_logic;
        PCWriteCond        : out std_logic;
        PCSource           : out std_logic_vector(1 downto 0);

        RegDataSel         : out std_logic_vector(1 downto 0)
    );
end Controle;

architecture Behavioral of Controle is

    type estado_type is (
        FETCH,
        DECODE,

        MEM_ADDR,
        MEM_READ_STATE,
        MEM_WB,
        MEM_WRITE_STATE,

        R_EXEC,
        R_WB,

        ADDI_EXEC,
        ADDI_WB,

        BRANCH_STATE,

        JAL_WB,

        JALR_EXEC,
        JALR_WB,

        AUIPC_EXEC,
        AUIPC_WB,

        LUI_EXEC,
        LUI_WB
    );

    signal estado, proximo_estado : estado_type;

begin

    -- Registrador de estado
    process(clk, reset)
    begin
        if reset = '1' then
            estado <= FETCH;
        elsif rising_edge(clk) then
            estado <= proximo_estado;
        end if;
    end process;


    -- Lógica de controle
    process(estado, instrucao)
    begin

        -- Valores padrão
        MemRead       <= '0';
        MemWrite      <= '0';
        IorD           <= '0';
        IRWrite        <= '0';
        MDRWrite       <= '0';

        AWrite         <= '0';
        BWrite         <= '0';
        RegWrite       <= '0';
        ALUOutWrite    <= '0';

        PCInstrWrite   <= '0';
        PCBackWrite    <= '0';

        ALUSrcA        <= "00";
        ALUSrcB        <= "00";
        ALUOp          <= "00";

        PCWrite        <= '0';
        PCWriteCond    <= '0';
        PCSource       <= "00";

        RegDataSel     <= "00";

        proximo_estado <= FETCH;


        case estado is

            ------------------------------------------------
            -- FETCH
            ------------------------------------------------
            when FETCH =>

                MemRead       <= '1';
                IRWrite       <= '1';

                -- Guarda o endereço da instrução atual
                PCInstrWrite  <= '1';

                -- Calcula PC + 4
                ALUSrcA       <= "00";
                ALUSrcB       <= "01";
                ALUOp         <= "00";

                -- Atualiza PC e guarda PC + 4
                PCWrite       <= '1';
                PCBackWrite  <= '1';
                PCSource      <= "00";

                proximo_estado <= DECODE;


            ------------------------------------------------
            -- DECODE
            ------------------------------------------------
            when DECODE =>

                AWrite <= '1';
                BWrite <= '1';

                case instrucao(6 downto 0) is

                    -- LW
                    when "0000011" =>
                        proximo_estado <= MEM_ADDR;

                    -- SW
                    when "0100011" =>
                        proximo_estado <= MEM_ADDR;

                    -- Instruções tipo R
                    when "0110011" =>
                        proximo_estado <= R_EXEC;

                    -- ADDI
                    when "0010011" =>
                        proximo_estado <= ADDI_EXEC;

                    -- BEQ e BNE
                    when "1100011" =>

                        -- Calcula endereço do desvio:
                        -- PC da instrução + imediato
                        ALUSrcA     <= "11";
                        ALUSrcB     <= "11";
                        ALUOp       <= "00";
                        ALUOutWrite <= '1';

                        proximo_estado <= BRANCH_STATE;

                    -- JAL
                    when "1101111" =>

                        -- Calcula destino do salto
                        ALUSrcA     <= "11";
                        ALUSrcB     <= "11";
                        ALUOp       <= "00";
                        ALUOutWrite <= '1';

                        proximo_estado <= JAL_WB;

                    -- JALR
                    when "1100111" =>
                        proximo_estado <= JALR_EXEC;

                    -- AUIPC
                    when "0010111" =>
                        proximo_estado <= AUIPC_EXEC;

                    -- LUI
                    when "0110111" =>
                        proximo_estado <= LUI_EXEC;

                    when others =>
                        proximo_estado <= FETCH;

                end case;


            ------------------------------------------------
            -- ENDEREÇO DA MEMÓRIA
            ------------------------------------------------
            when MEM_ADDR =>

                -- A + imediato
                ALUSrcA <= "01";
                ALUSrcB <= "10";
                ALUOp   <= "00";

                ALUOutWrite <= '1';

                if instrucao(6 downto 0) = "0000011" then
                    proximo_estado <= MEM_READ_STATE;
                else
                    proximo_estado <= MEM_WRITE_STATE;
                end if;


            ------------------------------------------------
            -- LEITURA DA MEMÓRIA
            ------------------------------------------------
            when MEM_READ_STATE =>

                IorD     <= '1';
                MemRead  <= '1';
                MDRWrite <= '1';

                proximo_estado <= MEM_WB;


            ------------------------------------------------
            -- WRITE BACK DO LOAD
            ------------------------------------------------
            when MEM_WB =>

                RegWrite   <= '1';
                RegDataSel <= "01";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- ESCRITA NA MEMÓRIA
            ------------------------------------------------
            when MEM_WRITE_STATE =>

                IorD     <= '1';
                MemWrite <= '1';

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- EXECUÇÃO TIPO R
            ------------------------------------------------
            when R_EXEC =>

                ALUSrcA <= "01";
                ALUSrcB <= "00";
                ALUOp   <= "10";

                ALUOutWrite <= '1';

                proximo_estado <= R_WB;


            ------------------------------------------------
            -- WRITE BACK TIPO R
            ------------------------------------------------
            when R_WB =>

                RegWrite   <= '1';
                RegDataSel <= "00";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- EXECUÇÃO ADDI
            ------------------------------------------------
            when ADDI_EXEC =>

                ALUSrcA <= "01";
                ALUSrcB <= "10";
                ALUOp   <= "00";

                ALUOutWrite <= '1';

                proximo_estado <= ADDI_WB;


            ------------------------------------------------
            -- WRITE BACK ADDI
            ------------------------------------------------
            when ADDI_WB =>

                RegWrite   <= '1';
                RegDataSel <= "00";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- BRANCH: BEQ / BNE
            ------------------------------------------------
            when BRANCH_STATE =>

                ALUSrcA <= "01";
                ALUSrcB <= "00";
                ALUOp   <= "01";

                PCWriteCond <= '1';
                PCSource    <= "01";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- JAL
            ------------------------------------------------
            when JAL_WB =>

                -- Atualiza PC com o endereço calculado
                PCWrite   <= '1';
                PCSource  <= "01";

                -- Salva PC + 4 em rd
                RegWrite   <= '1';
                RegDataSel <= "10";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- EXECUÇÃO JALR
            ------------------------------------------------
            when JALR_EXEC =>

                -- rs1 + imediato
                ALUSrcA <= "01";
                ALUSrcB <= "10";
                ALUOp   <= "00";

                ALUOutWrite <= '1';

                proximo_estado <= JALR_WB;


            ------------------------------------------------
            -- JALR
            ------------------------------------------------
            when JALR_WB =>

                -- O datapath deve zerar o bit 0 do endereço
                -- antes de atualizar o PC.
                PCWrite  <= '1';
                PCSource <= "10";

                -- Salva PC + 4 em rd
                RegWrite   <= '1';
                RegDataSel <= "10";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- EXECUÇÃO AUIPC
            ------------------------------------------------
            when AUIPC_EXEC =>

                -- PC da instrução + imediato U
                ALUSrcA <= "11";
                ALUSrcB <= "10";
                ALUOp   <= "00";

                ALUOutWrite <= '1';

                proximo_estado <= AUIPC_WB;


            ------------------------------------------------
            -- WRITE BACK AUIPC
            ------------------------------------------------
            when AUIPC_WB =>

                RegWrite   <= '1';
                RegDataSel <= "00";

                proximo_estado <= FETCH;


            ------------------------------------------------
            -- EXECUÇÃO LUI
            ------------------------------------------------
            when LUI_EXEC =>

                -- Zero + imediato U
                ALUSrcA <= "10";
                ALUSrcB <= "10";
                ALUOp   <= "00";

                ALUOutWrite <= '1';

                proximo_estado <= LUI_WB;


            ------------------------------------------------
            -- WRITE BACK LUI
            ------------------------------------------------
            when LUI_WB =>

                RegWrite   <= '1';
                RegDataSel <= "00";

                proximo_estado <= FETCH;


            when others =>
                proximo_estado <= FETCH;

        end case;

    end process;

end Behavioral;

