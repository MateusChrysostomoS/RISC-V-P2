library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_Control is
    port(
        Functs    : IN std_logic_vector(3 downto 0);
        AluOp   : IN std_logic_vector(1 downto 0);
        Control : OUT std_logic_vector(3 downto 0)
        );
end ALU_Control;

architecture TypeArchitecture of ALU_Control is
begin
    control <= "0010" when AluOp = "00" else
             "0110" when AluOp = "01" else
             "0010" when Functs = "0000" else
             "0110" when Functs = "1000" else
             "0011" when Functs = "0001" else
             "0101" when Functs = "0100" else
             "0111" when Functs = "0101" else
             "0001" when Functs = "0110" else
             "0000" when Functs = "0111";

end TypeArchitecture;
