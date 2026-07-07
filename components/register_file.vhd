library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
  port(
    outA        : out std_logic_vector(31 downto 0);
    outB        : out std_logic_vector(31 downto 0);
    input       : in  std_logic_vector(31 downto 0);
    regSelManual: in  std_logic_vector(4 downto 0);
    outRegManual: out std_logic_vector(31 downto 0);
    writeEnable : in  std_logic;
    regASel     : in  std_logic_vector(4 downto 0);
    regBSel     : in  std_logic_vector(4 downto 0);
    writeRegSel : in  std_logic_vector(4 downto 0);
    clk         : in  std_logic
    );
end register_file;

architecture TypeArchitecture of register_file is
  type registerFile is array(0 to 31) of std_logic_vector(31 downto 0);
  signal registers : registerFile :=
   ("00000000000000000000000000010000","00000000000000000000000000000001","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
    "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000");

begin
  regFile : process (clk) is
  begin
    if rising_edge(clk) then
      if (registers(to_integer(unsigned(regASel))) = "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") THEN
        outA <= (others => '0');
      ELSE
        outA <= registers(to_integer(unsigned(regASel)));
      END IF;
      IF (registers(to_integer(unsigned(regBSel))) = "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") THEN
        outB <= (others => '0');
      ELSE
        outB <= registers(to_integer(unsigned(regBSel)));
      END IF;
      if writeEnable = '1' then
        registers(to_integer(unsigned(writeRegSel))) <= input;
        if regASel = writeRegSel then
          outA <= input;
        end if;
        if regBSel = writeRegSel then
          outB <= input;
        end if;
      end if;
    end if;
  end process;

  outRegManual <= registers(to_integer(unsigned(regSelManual)));

end TypeArchitecture;
