library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit is
    port(
        opcode                     : IN  std_logic_vector(6 downto 0);
        funct3                     : IN  std_logic_vector(2 downto 0); -- NOVO: precisa vir da instrução (bits 14-12)
        raw_vew                    : IN  std_logic_vector(1 downto 0); -- NOVO: bits 26-25 (R-vetorial) ou imm[11:10] (I-vetorial), ligados direto da instrução no datapath
        AluSrc, blockA, RegWrite   : OUT std_logic;
        MemRead, MemWrite, Branch  : OUT std_logic;
        BranchNotEq, BrIncond      : OUT std_logic;
        regToPC                    : OUT std_logic;
        AluOp, regSrc              : OUT std_logic_vector(1 downto 0);
        vec_enable                 : OUT std_logic;                    -- NOVO: '1' se é instrução vetorial
        vec_mode                   : OUT std_logic_vector(1 downto 0)  -- NOVO: largura do elemento (VEW)
        );
end Control_Unit;

architecture TypeArchitecture of Control_Unit is
begin
    process(opcode, funct3)
    begin
        -- Defaults: evita latch e cobre opcodes não usados
        AluSrc      <= '0';
        blockA      <= '0';
        RegWrite    <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        Branch      <= '0';
        AluOp       <= "00";
        regSrc      <= "00";
        BranchNotEq <= '0';
        BrIncond    <= '0';
        regToPC     <= '0';
        vec_enable  <= '0';
        vec_mode    <= "10"; -- default = 32 bits (equivale a escalar)

        case opcode is

            when "0110011" =>  -- R-Type (add, sub, and, or, xor, sll, srl)
                AluSrc      <= '0';
                RegWrite    <= '1';
                AluOp       <= "10";
                regSrc      <= "00";

            when "0010011" =>  -- I-Type aritmético (addi, andi, ori, slli, srli...)
                AluSrc      <= '1';
                RegWrite    <= '1';
                AluOp       <= "11";
                regSrc      <= "00";

            when "0000011" =>  -- I-Type load (lw)
                AluSrc      <= '1';
                RegWrite    <= '1';
                MemRead     <= '1';
                AluOp       <= "00";
                regSrc      <= "01";

            when "1100111" =>  -- I-Type jalr
                AluSrc      <= '1';
                RegWrite    <= '1';
                AluOp       <= "00";
                regToPC     <= '1';
                BrIncond    <= '1';
                regSrc      <= "10";

            when "0100011" =>  -- S-Type (sw)
                AluSrc      <= '1';
                MemWrite    <= '1';
                AluOp       <= "00";

            when "1100011" =>  -- SB-Type (beq/bne)
                Branch      <= '1';
                AluOp       <= "01";
                -- CORRIGIDO: beq/bne têm o mesmo opcode; a diferença é o funct3
                if funct3 = "001" then
                    BranchNotEq <= '1'; -- bne
                else
                    BranchNotEq <= '0'; -- beq (funct3 = "000")
                end if;

            when "1101111" =>  -- UJ-Type (jal)
                RegWrite    <= '1';
                BrIncond    <= '1';
                regToPC     <= '1';
                regSrc      <= "10";

            when "0110111" =>  -- U-Type (lui)
                RegWrite    <= '1';
                blockA      <= '1';
                AluSrc      <= '1';
                AluOp       <= "00";

            when "0010111" =>  -- U-Type (auipc)
                RegWrite    <= '1';
                AluSrc      <= '1';
                AluOp       <= "00";
                regSrc      <= "11";

            when "0001011" =>  -- CUSTOM-0: instruções vetoriais
                                -- add.v/sub.v (funct3=000), sll.v (funct3=001),
                                -- srl.v (funct3=101) tratados como R-Type vetorial;
                                -- addi.v/slli.v/srli.v tratados como I-Type vetorial
                                -- (a distinção R vs I fica a cargo do bit extra que
                                -- vocês definirem no encoding -- ver plano de execução
                                -- seção 5). Aqui assumimos um bit dedicado, ex: inst(31),
                                -- para diferenciar R-vetorial de I-vetorial:
                vec_enable <= '1';
                RegWrite   <= '1';
                if funct3 = "111" then
                    -- auipc.v: tratado como o auipc escalar (decisão do plano, item 4)
                    AluSrc   <= '1';
                    AluOp    <= "00";
                    regSrc   <= "11";
                    vec_enable <= '0'; -- comporta-se como escalar de verdade
                else
                    AluSrc   <= '0'; -- ajustar para '1' se for a variante imediata (addi.v/slli.v/srli.v)
                    AluOp    <= "10";
                    regSrc   <= "00";
                    vec_mode <= raw_vew; -- largura do elemento vem direto da instrução
                end if;

            when others =>
                null;

        end case;
    end process;
end TypeArchitecture;
