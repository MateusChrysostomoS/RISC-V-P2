LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY EXMEM IS
  PORT (
    clk       : IN  std_logic;
    freeze    : IN  std_logic;                     -- NOVO
    sumIn     : IN  std_logic_vector(31 DOWNTO 0);
    zeroIn    : IN  std_logic;
    aluIn     : IN  std_logic_vector(31 DOWNTO 0);
    read2In   : IN  std_logic_vector(31 DOWNTO 0);
    wbAddIn   : IN  std_logic_vector(4 downto 0);
    WBin      : IN  std_logic_vector(2 downto 0);
    Min       : IN  std_logic_vector(5 downto 0);
    pcPl4In   : IN  std_logic_vector(31 downto 0);

    pcOut     : OUT std_logic_vector(31 DOWNTO 0);
    zeroOut   : OUT std_logic;
    aluOut    : OUT std_logic_vector(31 DOWNTO 0);
    read2Out  : OUT std_logic_vector(31 DOWNTO 0);
    wbAddOut  : OUT std_logic_vector(4 downto 0);
    WBout     : OUT std_logic_vector(2 downto 0);
    Mout      : OUT std_logic_vector(5 downto 0);
    pcPl4Out  : OUT std_logic_vector(31 downto 0)
    );
END EXMEM;

ARCHITECTURE TypeArchitecture OF EXMEM IS
SIGNAL exmem_s : std_logic_vector(142 DOWNTO 0);
BEGIN

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (freeze = '0') THEN  -- NOVO
                exmem_s(31 DOWNTO 0)     <= sumIn;
                exmem_s(32)              <= zeroIn;
                exmem_s(64 DOWNTO 33)    <= aluIn;
                exmem_s(96 DOWNTO 65)    <= read2In;
                exmem_s(101 DOWNTO 97)   <= wbAddIn;
                exmem_s(104 DOWNTO 102)  <= WBin;
                exmem_s(110 DOWNTO 105)  <= Min;
                exmem_s(142 downto 111)  <= pcPl4In;
            END IF;
        END IF;
        IF (falling_edge(clk)) THEN
            pcOut    <= exmem_s(31 DOWNTO 0);
            zeroOut  <= exmem_s(32);
            aluOut   <= exmem_s(64 DOWNTO 33);
            read2Out <= exmem_s(96 DOWNTO 65);
            wbAddOut <= exmem_s(101 DOWNTO 97);
            WBout    <= exmem_s(104 DOWNTO 102);
            Mout     <= exmem_s(110 DOWNTO 105);
            pcPl4Out <= exmem_s(142 downto 111);
        END IF;
    END PROCESS;

END TypeArchitecture;
