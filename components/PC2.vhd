LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC2 IS
  PORT (
    clk      : IN  std_logic;
    reset    : IN  std_logic;
    pc_in    : IN  std_logic_vector(31 DOWNTO 0);
    writeEnableL   : IN std_logic;
    pc_out   : OUT std_logic_vector(31 DOWNTO 0)
    );
END PC2;

ARCHITECTURE TypeArchitecture OF PC2 IS
BEGIN
    PROCESS (clk, reset, writeEnableL)
    BEGIN
        IF (rising_edge(clk)) THEN
            if (pc_in = "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") then
                pc_out <= (others => '0');
            elsif (writeEnableL = '0') then
                pc_out <= pc_in;
            end if;
        END IF;
        IF (reset = '1') THEN
            pc_out <= (others => '0');
        END IF;
    END PROCESS;
END TypeArchitecture;
