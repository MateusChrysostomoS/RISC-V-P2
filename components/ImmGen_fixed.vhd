library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ImmGen is
    Port( 
        inst: in std_logic_vector(31 downto 0);  -- Entrada da instrução (32 bits)
        imm: out std_logic_vector(31 downto 0)   -- Saída do valor imediato gerado (32 bits)
        );
end ImmGen;

architecture Behavioral of ImmGen is
    signal opcode      : std_logic_vector(6 downto 0);
    signal imm_interno : std_logic_vector(31 downto 0);
begin

    opcode <= inst(6 downto 0);

    process(opcode, inst)
    begin
        -- Default zera tudo antes de cada caso, evita inferir latch
        imm_interno <= (others => '0');

        case opcode is
            -- I-type: addi/andi/ori/slti/etc (0010011), load (0000011), jalr (1100111)
            when "0010011" | "0000011" | "1100111" =>
                imm_interno(11 downto 0)  <= inst(31 downto 20);
                imm_interno(31 downto 12) <= (others => inst(31));

            -- U-type: lui (0110111), auipc (0010111)
            when "0110111" | "0010111" =>
                imm_interno(31 downto 12) <= inst(31 downto 12);
                imm_interno(11 downto 0)  <= (others => '0');

            -- S-type: sw (0100011)
            when "0100011" =>
                imm_interno(11 downto 5)  <= inst(31 downto 25);
                imm_interno(4 downto 0)   <= inst(11 downto 7);
                imm_interno(31 downto 12) <= (others => inst(31));

            -- SB-type: beq/bne (1100011)
            when "1100011" =>
                imm_interno(12)           <= inst(31);
                imm_interno(11)           <= inst(7);
                imm_interno(10 downto 5)  <= inst(30 downto 25);
                imm_interno(4 downto 1)   <= inst(11 downto 8);
                imm_interno(0)            <= '0';
                imm_interno(31 downto 13) <= (others => inst(31));

            -- UJ-type: jal (1101111)
            when "1101111" =>
                imm_interno(20)           <= inst(31);
                imm_interno(19 downto 12) <= inst(19 downto 12);
                imm_interno(11)           <= inst(20);
                imm_interno(10 downto 1)  <= inst(30 downto 21);
                imm_interno(0)            <= '0';
                imm_interno(31 downto 21) <= (others => inst(31));

            when others =>
                imm_interno <= (others => '0');
        end case;
    end process;

    imm <= imm_interno;

end Behavioral;
