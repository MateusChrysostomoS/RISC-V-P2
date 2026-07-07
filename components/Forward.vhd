library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Forward is
	port(
	     clk					: IN std_logic;
	     regWriteWB, regWriteMEM 	: IN std_logic;
	     RSrc1, RSrc2			: IN std_logic_vector(4 downto 0);
	     RDWB, RDMEM			: IN std_logic_vector(4 downto 0);
	     forwardA, forwardB		: OUT std_logic_vector(1 downto 0)
     );
end Forward;

architecture TypeArchitecture of Forward is
	signal forwardA_interno, forwardB_interno : std_logic_vector(1 downto 0) := "00";

begin
	process(clk)
    begin
        if ((regWriteMEM = '1') and (not(RDMEM = "00000")) and (RDMEM = RSrc1)) then
        	forwardA_interno <= "10";
        end if;

        if ((regWriteMEM = '1') and (not(RDMEM = "00000")) and (RDMEM = RSrc2)) then
        	forwardB_interno <= "10";
        end if;

        if ((regWriteWB = '1') and (not(RDWB = "00000")) and (RDWB = RSrc1)) then
        	forwardA_interno <= "01";
        end if;

        if ((regWriteWB = '1') and (not(RDWB = "00000")) and (RDWB = RSrc2)) then
        	forwardB_interno <= "01";
        end if;

    end process;

    forwardA <= forwardA_interno;
    forwardB <= forwardB_interno;
end TypeArchitecture;
