library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hazard_Detection is
    port (
        -- Sinal de controle vindo do registrador ID/EX
        IDEX_MemRead     : in  std_logic; 
        
        -- Endereço do registrador de destino no estágio EX
        IDEX_RegisterRd  : in  std_logic_vector(4 downto 0);
        
        -- Endereços dos registradores fonte na instrução atual (estágio ID)
        IFID_RegisterRs1 : in  std_logic_vector(4 downto 0);
        IFID_RegisterRs2 : in  std_logic_vector(4 downto 0);
        
        -- Saída de controle de Hazard para o seu Freeze_Control
        stall_hazard     : out std_logic
    );
end Hazard_Detection;

architecture Behavioral of Hazard_Detection is
begin
    -- O Hazard de load-use é detectado de forma puramente combinacional
    process(IDEX_MemRead, IDEX_RegisterRd, IFID_RegisterRs1, IFID_RegisterRs2)
    begin
        -- Verifica se a instrução anterior é um Load (MemRead = '1')
        -- E se o registrador destino do Load é igual a um dos operandos requeridos agora
        -- Ignora o registrador zero ("00000"), pois ele não gera hazard real
        if (IDEX_MemRead = '1' and 
           ((IDEX_RegisterRd = IFID_RegisterRs1) or (IDEX_RegisterRd = IFID_RegisterRs2)) and 
           (IDEX_RegisterRd /= "00000")) then
           
            stall_hazard <= '1'; -- Aciona a bolha (NOP)
        else
            stall_hazard <= '0'; -- Fluxo normal do pipeline
        end if;
    end process;

end Behavioral;