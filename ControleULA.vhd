
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControleULA is
    port (
        ALUOp  : in  std_logic_vector(1 downto 0);
        funct3 : in  std_logic_vector(2 downto 0);
        funct7 : in  std_logic_vector(6 downto 0);

        opcode : out std_logic_vector(3 downto 0)
    );
end ControleULA;

architecture Behavioral of ControleULA is
begin

    process(ALUOp, funct3, funct7)
    begin

        -- Operacao padrao: ADD
        opcode <= "0000";

        case ALUOp is

            -- LOAD, STORE e calculo de endereco
            when "00" =>
                opcode <= "0000"; -- ADD

            -- Comparacoes: BEQ e BNE
            when "01" =>
                case funct3 is

                    when "000" =>
                        opcode <= "1100"; -- SEQ (BEQ)

                    when "001" =>
                        opcode <= "1101"; -- SNE (BNE)

                    when others =>
                        opcode <= "0000";

                end case;

            -- Instrucoes tipo R
            when "10" =>
                case funct3 is

                    when "000" =>
                        if funct7 = "0100000" then
                            opcode <= "0001"; -- SUB
                        else
                            opcode <= "0000"; -- ADD
                        end if;

                    when "001" =>
                        opcode <= "0101"; -- SLL

                    when "010" =>
                        opcode <= "1000"; -- SLT

                    when "011" =>
                        opcode <= "1001"; -- SLTU

                    when "100" =>
                        opcode <= "0100"; -- XOR

                    when "101" =>
                        if funct7 = "0100000" then
                            opcode <= "0111"; -- SRA
                        else
                            opcode <= "0110"; -- SRL
                        end if;

                    when "110" =>
                        opcode <= "0011"; -- OR

                    when "111" =>
                        opcode <= "0010"; -- AND

                    when others =>
                        opcode <= "0000";

                end case;

            when others =>
                opcode <= "0000";

        end case;

    end process;

end Behavioral;

