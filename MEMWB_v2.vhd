LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY MEMWB IS
  PORT (
    clk       : IN  std_logic;
    freeze    : IN  std_logic;                     -- NOVO
    readIn    : IN  std_logic_vector(31 DOWNTO 0);
    aluIn     : IN  std_logic_vector(31 DOWNTO 0);
    wbAddIn   : IN  std_logic_vector(4 downto 0);
    WBin      : IN  std_logic_vector(2 downto 0);
    pcPl4In   : IN  std_logic_vector(31 downto 0);
    pcPlIIn   : IN  std_logic_vector(31 downto 0);

    readOut   : OUT std_logic_vector(31 DOWNTO 0);
    aluOut    : OUT std_logic_vector(31 DOWNTO 0);
    wbAddOut  : OUT std_logic_vector(4 downto 0);
    WBout     : OUT std_logic_vector(2 downto 0);
    pcPl4Out  : OUT std_logic_vector(31 downto 0);
    pcPlIOut  : OUT std_logic_vector(31 downto 0)
    );
END MEMWB;

ARCHITECTURE TypeArchitecture OF MEMWB IS
SIGNAL memwb_s : std_logic_vector(135 DOWNTO 0);
BEGIN

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (freeze = '0') THEN  -- NOVO
                memwb_s(31 DOWNTO 0)    <= readIn;
                memwb_s(63 DOWNTO 32)   <= aluIn;
                memwb_s(68 DOWNTO 64)   <= wbAddIn;
                memwb_s(71 DOWNTO 69)   <= WBin;
                memwb_s(103 downto 72)  <= pcPl4In;
                memwb_s(135 downto 104) <= pcPlIIn;
            END IF;
        END IF;
        IF (falling_edge(clk)) THEN
            readOut  <= memwb_s(31 DOWNTO 0);
            aluOut   <= memwb_s(63 DOWNTO 32);
            wbAddOut <= memwb_s(68 DOWNTO 64);
            WBout    <= memwb_s(71 downto 69);
            pcPl4Out <= memwb_s(103 downto 72);
            pcPlIOut <= memwb_s(135 downto 104);
        END IF;
    END PROCESS;

END TypeArchitecture;
