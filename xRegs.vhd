library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity XREGS is
    generic (
        WSIZE : natural := 32
    );
    port (
        clk, wren : in std_logic;
        rs1, rs2, rd : in std_logic_vector(4 downto 0);
        data : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
end XREGS;

architecture Behavioral of XREGS is

    type reg_array is array (0 to 31) of
        std_logic_vector(WSIZE-1 downto 0);

    signal regs : reg_array := (others => (others => '0'));

begin

    -- Escrita sincronizada pela borda de subida do clock
    process(clk)
    begin
        if rising_edge(clk) then
            if wren = '1' then
                -- O registrador x0 não pode ser alterado
                if unsigned(rd) /= 0 then
                    regs(to_integer(unsigned(rd))) <= data;
                end if;
            end if;
        end if;
    end process;

    -- Primeira porta de leitura
    ro1 <= (others => '0') when unsigned(rs1) = 0
           else regs(to_integer(unsigned(rs1)));

    -- Segunda porta de leitura
    ro2 <= (others => '0') when unsigned(rs2) = 0
           else regs(to_integer(unsigned(rs2)));

end Behavioral;

