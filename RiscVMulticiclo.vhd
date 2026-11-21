
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processador is
    port (
        clk   : in std_logic;
        reset : in std_logic
    );
end Processador;

architecture Behavioral of Processador is

    -- =========================================
    -- Sinais principais
    -- =========================================

    signal pc_atual : std_logic_vector(31 downto 0);
    signal pc_novo  : std_logic_vector(31 downto 0);

    signal instrucao : std_logic_vector(31 downto 0);

    signal endereco_memoria : std_logic_vector(31 downto 0);
    signal dado_memoria     : std_logic_vector(31 downto 0);

    signal dado_mdr : std_logic_vector(31 downto 0);

    -- =========================================
    -- Registradores internos
    -- =========================================

    signal pc_instr : std_logic_vector(31 downto 0);
    signal pc_back  : std_logic_vector(31 downto 0);

    signal reg_A : std_logic_vector(31 downto 0);
    signal reg_B : std_logic_vector(31 downto 0);

    signal alu_out : std_logic_vector(31 downto 0);

    -- =========================================
    -- Banco de registradores
    -- =========================================

    signal dado_rs1 : std_logic_vector(31 downto 0);
    signal dado_rs2 : std_logic_vector(31 downto 0);

    signal dado_escrita_reg : std_logic_vector(31 downto 0);

    -- =========================================
    -- Gerador de imediato
    -- =========================================

    signal imediato_signed : signed(31 downto 0);
    signal imediato        : std_logic_vector(31 downto 0);

    -- =========================================
    -- ULA
    -- =========================================

    signal entrada_ula_A : std_logic_vector(31 downto 0);
    signal entrada_ula_B : std_logic_vector(31 downto 0);

    signal resultado_ula : std_logic_vector(31 downto 0);
    signal cond_ula      : std_logic;

    signal opcode_ula : std_logic_vector(3 downto 0);

    -- =========================================
    -- Controle
    -- =========================================

    signal MemRead, MemWrite : std_logic;
    signal IorD               : std_logic;
    signal IRWrite            : std_logic;
    signal MDRWrite           : std_logic;

    signal AWrite, BWrite     : std_logic;
    signal RegWrite           : std_logic;
    signal ALUOutWrite        : std_logic;

    signal PCInstrWrite       : std_logic;
    signal PCBackWrite        : std_logic;

    signal ALUSrcA : std_logic_vector(1 downto 0);
    signal ALUSrcB : std_logic_vector(1 downto 0);

    signal ALUOp : std_logic_vector(1 downto 0);

    signal PCWrite     : std_logic;
    signal PCWriteCond : std_logic;

    signal PCSource : std_logic_vector(1 downto 0);

    signal RegDataSel : std_logic_vector(1 downto 0);

    signal pc_enable : std_logic;

begin

    -- =========================================
    -- 1. CONTROLE
    -- =========================================

    U_CONTROLE: entity work.Controle
        port map (
            clk           => clk,
            reset         => reset,
            instrucao     => instrucao,

            MemRead       => MemRead,
            MemWrite      => MemWrite,
            IorD          => IorD,
            IRWrite       => IRWrite,
            MDRWrite      => MDRWrite,

            AWrite        => AWrite,
            BWrite        => BWrite,
            RegWrite      => RegWrite,
            ALUOutWrite   => ALUOutWrite,

            PCInstrWrite  => PCInstrWrite,
            PCBackWrite   => PCBackWrite,

            ALUSrcA       => ALUSrcA,
            ALUSrcB       => ALUSrcB,
            ALUOp         => ALUOp,

            PCWrite       => PCWrite,
            PCWriteCond   => PCWriteCond,
            PCSource      => PCSource,

            RegDataSel    => RegDataSel
        );


    -- =========================================
    -- 2. MEMÓRIA
    -- =========================================

    -- Seleciona:
    -- IorD = 0: endereço do PC
    -- IorD = 1: endereço calculado pela ULA

    endereco_memoria <=
        pc_atual when IorD = '0' else
        alu_out;

    U_MEMORIA: entity work.Memoria
        port map (
            clk          => clk,
            MemRead      => MemRead,
            MemWrite     => MemWrite,
            endereco     => endereco_memoria,
            DadoEscrita  => reg_B,
            DadoLido     => dado_memoria
        );


    -- =========================================
    -- 3. REGISTRADOR DE INSTRUÇÃO (IR)
    -- =========================================

    U_IR: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => IRWrite,
            D     => dado_memoria,
            Q     => instrucao
        );


    -- =========================================
    -- 4. REGISTRADOR MDR
    -- =========================================

    U_MDR: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => MDRWrite,
            D     => dado_memoria,
            Q     => dado_mdr
        );


    -- =========================================
    -- 5. BANCO DE REGISTRADORES XREGS
    -- =========================================

    U_XREGS: entity work.XREGS
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            wren  => RegWrite,

            rs1   => instrucao(19 downto 15),
            rs2   => instrucao(24 downto 20),
            rd    => instrucao(11 downto 7),

            data  => dado_escrita_reg,

            ro1   => dado_rs1,
            ro2   => dado_rs2
        );


    -- =========================================
    -- 6. REGISTRADORES A E B
    -- =========================================

    U_REG_A: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => AWrite,
            D     => dado_rs1,
            Q     => reg_A
        );

    U_REG_B: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => BWrite,
            D     => dado_rs2,
            Q     => reg_B
        );


    -- =========================================
    -- 7. GERADOR DE IMEDIATOS
    -- =========================================

    U_IMEDIATO: entity work.genImm32
        port map (
            instr => instrucao,
            imm32 => imediato_signed
        );

    imediato <= std_logic_vector(imediato_signed);


    -- =========================================
    -- 8. MULTIPLEXADOR DA ENTRADA A DA ULA
    -- =========================================

    with ALUSrcA select
        entrada_ula_A <=
            pc_atual  when "00",
            reg_A     when "01",
            (others => '0') when "10",
            pc_instr  when "11",
            (others => '0') when others;


    -- =========================================
    -- 9. MULTIPLEXADOR DA ENTRADA B DA ULA
    -- =========================================

    with ALUSrcB select
        entrada_ula_B <=
            reg_B     when "00",
            x"00000004" when "01",
            imediato  when "10",
            imediato  when "11",
            (others => '0') when others;


    -- =========================================
    -- 10. CONTROLE DA ULA
    -- =========================================

    U_CONTROLE_ULA: entity work.ControleULA
        port map (
            ALUOp  => ALUOp,
            funct3 => instrucao(14 downto 12),
            funct7 => instrucao(31 downto 25),
            opcode => opcode_ula
        );


    -- =========================================
    -- 11. ULA
    -- =========================================

    U_ULA: entity work.ulaRV
        generic map (
            WSIZE => 32
        )
        port map (
            opcode => opcode_ula,
            A      => entrada_ula_A,
            B      => entrada_ula_B,
            Z      => resultado_ula,
            cond   => cond_ula
        );


    -- =========================================
    -- 12. REGISTRADOR ALUOut
    -- =========================================

    U_ALUOUT: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => ALUOutWrite,
            D     => resultado_ula,
            Q     => alu_out
        );


    -- =========================================
    -- 13. REGISTRADOR PCInstr
    -- =========================================

    U_PCINSTR: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => PCInstrWrite,
            D     => pc_atual,
            Q     => pc_instr
        );


    -- =========================================
    -- 14. REGISTRADOR PCBack
    -- =========================================

    U_PCBACK: entity work.Registrador
        generic map (
            WSIZE => 32
        )
        port map (
            clk   => clk,
            reset => reset,
            en    => PCBackWrite,
            D     => resultado_ula,
            Q     => pc_back
        );


    -- =========================================
    -- 15. MULTIPLEXADOR DE ESCRITA DO BANCO
    -- =========================================

    with RegDataSel select
        dado_escrita_reg <=
            alu_out  when "00",
            dado_mdr when "01",
            pc_back  when "10",
            (others => '0') when others;


    -- =========================================
    -- 16. MULTIPLEXADOR DE ENTRADA DO PC
    -- =========================================

    with PCSource select
        pc_novo <=
            resultado_ula when "00",
            alu_out       when "01",
            (alu_out(31 downto 1) & '0') when "10",
            (others => '0') when others;


    -- =========================================
    -- 17. HABILITAÇÃO DO PC
    -- =========================================

    pc_enable <= PCWrite or (PCWriteCond and cond_ula);


    -- =========================================
    -- 18. CONTADOR DE PROGRAMA
    -- =========================================

    U_PC: entity work.PC
        port map (
            clk      => clk,
            reset    => reset,
            enable   => pc_enable,
            entrada  => pc_novo,
            saida    => pc_atual
        );

end Behavioral;

