LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IFID IS
  PORT (
    clk         : IN  std_logic;
    pcIn        : IN  std_logic_vector(31 DOWNTO 0);
    pcPl4In	 : IN  std_logic_vector(31 downto 0);
    writeEnableL   : IN std_logic;
    instIn      : IN  std_logic_vector(31 DOWNTO 0);
    pcOut       : OUT std_logic_vector(31 DOWNTO 0);
    pcPl4Out	 : OUT std_logic_vector(31 downto 0);
    instOut     : OUT std_logic_vector(31 DOWNTO 0)
    );
END IFID;

ARCHITECTURE TypeArchitecture OF IFID IS
SIGNAL IDIF : std_logic_vector(95 DOWNTO 0);
BEGIN
	PROCESS (clk, writeEnableL)
	BEGIN
		IF (rising_edge(clk)) THEN
			if (writeEnableL = '0') then
				IDIF(31 DOWNTO 0) <= instIn;
				IDIF(63 DOWNTO 32) <= pcIn;
				IDIF(95 downto 64) <= pcPl4In;
			end if;
		END IF;
		IF (falling_edge(clk)) THEN
			pcOut <= IDIF(63 DOWNTO 32);
			instOut <= IDIF(31 DOWNTO 0);
			pcPl4Out <= IDIF(95 downto 64);
		END IF;
	END PROCESS;
END TypeArchitecture;
