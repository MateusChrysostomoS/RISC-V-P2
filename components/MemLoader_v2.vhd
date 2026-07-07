library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Carrega WORD_COUNT palavras de 32 bits de uma memória fonte para a RAM de dados.
-- Código adaptado sem 'generic' na entity para compatibilidade total com o
-- gerador automático de pinos do Simulador Digital.

entity MemLoader is
    port(
        clk          : in  std_logic;
        reset        : in  std_logic;
        src_data     : in  std_logic_vector(31 downto 0);
        loader_addr  : out std_logic_vector(23 downto 0); -- Tamanho fixado em 24 bits
        loader_data  : out std_logic_vector(31 downto 0);
        loader_we    : out std_logic;
        mem_loading  : out std_logic
    );
end MemLoader;

architecture TypeArchitecture of MemLoader is
    -- Constantes movidas para dentro da arquitetura para não quebrar o parser do Digital
    constant WORD_COUNT : integer := 16; 
    
    signal counter : unsigned(23 downto 0) := (others => '0');
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
                    loading <= '0';  -- terminou de carregar
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