
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity genImm32 is
    port (
        instr : in  std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
end genImm32;

architecture comportamento of genImm32 is
begin

    process(instr)

        variable opcode  : std_logic_vector(6 downto 0);
        variable funct3  : std_logic_vector(2 downto 0);
        variable imm_tmp : signed(31 downto 0);

    begin

        opcode := instr(6 downto 0);
        funct3 := instr(14 downto 12);

        imm_tmp := (others => '0');

        case opcode is

            -- R-type: sem imediato
            when "0110011" =>
                imm_tmp := (others => '0');

            -- I-type: LOAD, OP-IMM e JALR
            when "0000011" |
                 "0010011" |
                 "1100111" =>

                -- SLLI, SRLI e SRAI
                if opcode = "0010011" and
                   (funct3 = "001" or funct3 = "101") then

                    imm_tmp := signed(
                        resize(
                            unsigned(instr(24 downto 20)),
                            32
                        )
                    );

                else

                    -- Imediato de 12 bits com extensão de sinal
                    imm_tmp := resize(
                        signed(instr(31 downto 20)),
                        32
                    );

                end if;

            -- S-type: STORE
            when "0100011" =>

                imm_tmp := resize(
                    signed(
                        instr(31 downto 25) &
                        instr(11 downto 7)
                    ),
                    32
                );

            -- SB-type: BRANCH
            when "1100011" =>

                imm_tmp := resize(
                    signed(
                        instr(31) &
                        instr(7) &
                        instr(30 downto 25) &
                        instr(11 downto 8) &
                        '0'
                    ),
                    32
                );

            -- U-type: LUI e AUIPC
            when "0110111" |
                 "0010111" =>

                imm_tmp := signed(
                    instr(31 downto 12) &
                    "000000000000"
                );

            -- UJ-type: JAL
            when "1101111" =>

                imm_tmp := resize(
                    signed(
                        instr(31) &
                        instr(19 downto 12) &
                        instr(20) &
                        instr(30 downto 21) &
                        '0'
                    ),
                    32
                );

            when others =>
                imm_tmp := (others => '0');

        end case;

        imm32 <= imm_tmp;

    end process;

end comportamento;

