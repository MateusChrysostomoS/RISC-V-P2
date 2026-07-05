library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Carrega WORD_COUNT palavras de 32 bits de uma memória fonte (ex: uma ROM
-- separada com os dados de teste) para a RAM de dados da CPU, de forma
-- sequencial, ANTES da CPU começar a executar. Enquanto mem_loading = '1',
-- a CPU inteira deve ficar congelada (ver Freeze_Control).
--
-- Este módulo só GERA o endereço/dado/we da carga. A troca de qual sinal
-- realmente chega na RAM (o da carga ou o da CPU) é feita por multiplexadores
-- fora deste módulo, no datapath principal -- ver instruções de fiação no
-- plano de execução, seção 9.

entity MemLoader is
    generic(
        WORD_COUNT : integer := 16;  -- quantas palavras carregar; ajustem ao tamanho do teste
        ADDR_WIDTH : integer := 24
        );
    port(
        clk          : in  std_logic;
        reset        : in  std_logic;
        src_data     : in  std_logic_vector(31 downto 0); -- dado vindo da ROM/fonte, endereçado por loader_addr
        loader_addr  : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        loader_data  : out std_logic_vector(31 downto 0);
        loader_we    : out std_logic;
        mem_loading  : out std_logic
        );
end MemLoader;

architecture TypeArchitecture of MemLoader is
    signal counter : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal loading : std_logic := '1';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            loading <= '1';
        elsif rising_edge(clk) then
            if loading = '1' then
                if to_integer(counter) = WORD_COUNT - 1 then
                    loading <= '0';  -- terminou de carregar, nunca mais entra aqui até outro reset
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    loader_addr <= std_logic_vector(counter);
    loader_data <= src_data;
    loader_we   <= loading;
    mem_loading <= loading;

end TypeArchitecture;
