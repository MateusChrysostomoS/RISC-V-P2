LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;

ENTITY somador IS
  PORT (
    A, B : IN  std_logic_vector(31 DOWNTO 0);
    Z    : OUT std_logic_vector(31 DOWNTO 0)
    );
END somador;

ARCHITECTURE TypeArchitecture OF somador IS
BEGIN
Z <= A + B;
END TypeArchitecture;
