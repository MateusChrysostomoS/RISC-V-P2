LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IDEX IS
  PORT (
    clk            : IN  std_logic;
    freeze         : IN  std_logic;                     -- NOVO: '1' = memória carregando, congela tudo
    pcIn           : IN  std_logic_vector(31 DOWNTO 0);
    read1In        : IN  std_logic_vector(31 DOWNTO 0);
    read2In        : IN  std_logic_vector(31 DOWNTO 0);
    immGenIn       : in  std_logic_vector(31 DOWNTO 0);
    aluControlin   : IN  std_logic_vector(3 downto 0);
    wbAddIn        : IN  std_logic_vector(4 downto 0);
    WBin           : IN  std_logic_vector(2 downto 0);
    Min            : IN  std_logic_vector(5 downto 0);
    EXin           : IN  std_logic_vector(3 downto 0);
    pcPl4In        : IN  std_logic_vector(31 downto 0);
    rs1In          : IN  std_logic_vector(4 downto 0);
    rs2In          : IN  std_logic_vector(4 downto 0);

    pcOut          : OUT std_logic_vector(31 DOWNTO 0);
    read1Out       : OUT std_logic_vector(31 DOWNTO 0);
    read2Out       : OUT std_logic_vector(31 DOWNTO 0);
    immGenOut      : OUT std_logic_vector(31 DOWNTO 0);
    aluControlout  : OUT std_logic_vector(3 downto 0);
    wbAddOut       : OUT std_logic_vector(4 downto 0);
    WBout          : OUT std_logic_vector(2 downto 0);
    Mout           : OUT std_logic_vector(5 downto 0);
    EXout          : OUT std_logic_vector(3 downto 0);
    pcPl4Out       : OUT std_logic_vector(31 downto 0);
    rs1Out         : OUT std_logic_vector(4 downto 0);
    rs2Out         : OUT std_logic_vector(4 downto 0)
    );
END IDEX;

ARCHITECTURE TypeArchitecture OF IDEX IS
SIGNAL idex_s : std_logic_vector(191 DOWNTO 0);
BEGIN

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (freeze = '0') THEN  -- NOVO: só escreve se não estiver congelado
                idex_s(31 DOWNTO 0)     <= pcIn;
                idex_s(63 DOWNTO 32)    <= read1In;
                idex_s(95 DOWNTO 64)    <= read2In;
                idex_s(127 DOWNTO 96)   <= immGenIn;
                idex_s(131 DOWNTO 128)  <= aluControlin;
                idex_s(136 DOWNTO 132)  <= wbAddIn;
                idex_s(139 downto 137)  <= WBin;
                idex_s(145 downto 140)  <= Min;
                idex_s(149 downto 146)  <= EXin;
                idex_s(181 downto 150)  <= pcPl4In;
                idex_s(186 downto 182)  <= rs1In;
                idex_s(191 downto 187)  <= rs2In;
            END IF;
        END IF;
        IF (falling_edge(clk)) THEN
            pcOut         <= idex_s(31 DOWNTO 0);
            read1Out      <= idex_s(63 DOWNTO 32);
            read2Out      <= idex_s(95 DOWNTO 64);
            immGenOut     <= idex_s(127 DOWNTO 96);
            aluControlout <= idex_s(131 DOWNTO 128);
            wbAddOut      <= idex_s(136 DOWNTO 132);
            WBout         <= idex_s(139 downto 137);
            Mout          <= idex_s(145 downto 140);
            EXout         <= idex_s(149 downto 146);
            pcPl4Out      <= idex_s(181 downto 150);
            rs1Out        <= idex_s(186 downto 182);
            rs2Out        <= idex_s(191 downto 187);
        END IF;
    END PROCESS;

END TypeArchitecture;
