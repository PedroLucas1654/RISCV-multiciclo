library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ulaRV is
    generic (WSIZE : natural := 32);
    port (
        opcode : in std_logic_vector(3 downto 0);
        A, B   : in std_logic_vector(WSIZE-1 downto 0);
        Z      : out std_logic_vector(WSIZE-1 downto 0);
        cond   : out std_logic
    );
end ulaRV;

architecture behavioral of ulaRV is
begin
    proc_ula: process(A, B, opcode)
        variable resultado : std_logic_vector(WSIZE-1 downto 0);
        variable c : std_logic;
        variable deslocamento : natural;
    begin
        resultado := (others => '0');
        c := '0';
        deslocamento := to_integer(unsigned(B(4 downto 0)));

        case opcode is
            when "0000" => -- ADD
                resultado := std_logic_vector(unsigned(A) + unsigned(B));

            when "0001" => -- SUB
                resultado := std_logic_vector(unsigned(A) - unsigned(B));

            when "0010" => -- AND
                resultado := A and B;

            when "0011" => -- OR
                resultado := A or B;

            when "0100" => -- XOR
                resultado := A xor B;

            when "0101" => -- SLL
                resultado := std_logic_vector(shift_left(unsigned(A), deslocamento));

            when "0110" => -- SRL
                resultado := std_logic_vector(shift_right(unsigned(A), deslocamento));

            when "0111" => -- SRA
                resultado := std_logic_vector(shift_right(signed(A), deslocamento));

            when "1000" => -- SLT: A < B com sinal
                if signed(A) < signed(B) then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when "1001" => -- SLTU: A < B sem sinal
                if unsigned(A) < unsigned(B) then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when "1010" => -- SGE: A >= B com sinal
                if signed(A) >= signed(B) then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when "1011" => -- SGEU: A >= B sem sinal
                if unsigned(A) >= unsigned(B) then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when "1100" => -- SEQ
                if A = B then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when "1101" => -- SNE
                if A /= B then
                    resultado(0) := '1';
                    c := '1';
                end if;

            when others =>
                resultado := (others => '0');
                c := '0';
        end case;

        Z <= resultado;
        cond <= c;
    end process;
end behavioral;

