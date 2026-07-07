library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

entity ALU is
    port(
    A, B      : in  std_logic_vector(31 downto 0);
    control   : in  std_logic_vector(3 downto 0);
    vec_mode  : in  std_logic_vector(1 downto 0); -- "00"=4x8bit, "01"=2x16bit, "10"=1x32bit (escalar)
    result    : out std_logic_vector(31 downto 0);
    zero      : out std_logic);
end ALU;

architecture TypeArchitecture of ALU is

    signal zero_out    : std_logic_vector(32 downto 0);
    signal result_out  : std_logic_vector(31 downto 0);
    signal sum_result  : std_logic_vector(31 downto 0);
    signal sub_result  : std_logic_vector(31 downto 0);
    signal shl_result  : std_logic_vector(31 downto 0);
    signal shr_result  : std_logic_vector(31 downto 0);

begin

    -- =====================================================================
    -- Somador/subtrator particionável: em modo vetorial, cada lane calcula
    -- de forma independente (carry_in de cada lane travado em '0', nunca
    -- propaga do lane vizinho). Em modo escalar (vec_mode="10"), funciona
    -- como um somador de 32 bits normal.
    -- =====================================================================
    process(A, B, vec_mode, control)
        variable carry_add : std_logic_vector(32 downto 0);
        variable carry_sub : std_logic_vector(32 downto 0);
        variable a_bit, b_bit, b_bit_sub : std_logic;
    begin
        carry_add(0) := '0';
        carry_sub(0) := '1'; -- subtração = soma com complemento de 2

        for i in 0 to 31 loop
            -- Se este bit é fronteira de lane (início de um lane novo em modo
            -- vetorial), força o carry_in daquele lane a partir do zero em
            -- vez de propagar o carry do lane anterior.
            if (vec_mode = "00" and (i = 8 or i = 16 or i = 24)) then
                carry_add(i) := '0';
                carry_sub(i) := '1';
            elsif (vec_mode = "01" and i = 16) then
                carry_add(i) := '0';
                carry_sub(i) := '1';
            end if;

            a_bit     := A(i);
            b_bit     := B(i);
            b_bit_sub := not B(i);

            sum_result(i) <= a_bit xor b_bit xor carry_add(i);
            carry_add(i+1) := (a_bit and b_bit) or (carry_add(i) and (a_bit xor b_bit));

            sub_result(i) <= a_bit xor b_bit_sub xor carry_sub(i);
            carry_sub(i+1) := (a_bit and b_bit_sub) or (carry_sub(i) and (a_bit xor b_bit_sub));
        end loop;
    end process;

    -- =====================================================================
    -- Deslocador particionável: cada lane desloca de forma independente,
    -- usando só os bits de quantidade relevantes para o tamanho do lane
    -- (ex: lane de 8 bits só usa B(2 downto 0) como quantidade de shift).
    -- =====================================================================
    process(A, B, vec_mode)
        variable shamt : integer;
    begin
        case vec_mode is
            when "00" => -- 4 lanes de 8 bits
                for lane in 0 to 3 loop
                    shamt := to_integer(unsigned(B(lane*8+2 downto lane*8)));
                    shl_result(lane*8+7 downto lane*8) <=
                        std_logic_vector(shift_left(unsigned(A(lane*8+7 downto lane*8)), shamt));
                    shr_result(lane*8+7 downto lane*8) <=
                        std_logic_vector(shift_right(unsigned(A(lane*8+7 downto lane*8)), shamt));
                end loop;

            when "01" => -- 2 lanes de 16 bits
                for lane in 0 to 1 loop
                    shamt := to_integer(unsigned(B(lane*16+3 downto lane*16)));
                    shl_result(lane*16+15 downto lane*16) <=
                        std_logic_vector(shift_left(unsigned(A(lane*16+15 downto lane*16)), shamt));
                    shr_result(lane*16+15 downto lane*16) <=
                        std_logic_vector(shift_right(unsigned(A(lane*16+15 downto lane*16)), shamt));
                end loop;

            when others => -- escalar, 32 bits, 1 lane
                shamt := to_integer(unsigned(B(4 downto 0))); -- RV32I: só 5 bits de shamt
                shl_result <= std_logic_vector(shift_left(unsigned(A), shamt));
                shr_result <= std_logic_vector(shift_right(unsigned(A), shamt));
        end case;
    end process;

    -- =====================================================================
    -- Seleção final pela mesma tabela de control que já existia
    -- =====================================================================
    result_out <= sum_result                when control = "0010" else  -- add / add.v
                  sub_result                when control = "0110" else  -- sub / sub.v
                  (A xor B)                 when control = "0101" else  -- xor
                  (A or B)                  when control = "0001" else  -- or
                  (A and B)                 when control = "0000" else  -- and
                  shl_result                when control = "0011" else  -- sll / sll.v
                  shr_result                when control = "0111" else  -- srl / srl.v
                  (others => '0');

    result <= result_out;

    zero_out(0) <= '0';
    G2: for I in 1 to 32 generate
        zero_out(I) <= zero_out(I - 1) or result_out(I - 1);
    end generate;
    zero <= not zero_out(32);

end TypeArchitecture;
