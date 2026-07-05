library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Centraliza a diferença entre os dois mecanismos de pausa do pipeline:
--   * stall_hazard  -> vem da unidade Harzard (load-use hazard)
--   * mem_loading   -> vem do MemLoader (carga assíncrona de memória em andamento)
--
-- pc_ifid_freeze : trava PC e IFID em QUALQUER um dos dois casos
-- deep_freeze    : trava IDEX/EXMEM/MEMWB SÓ durante carga de memória
--                  (durante stall_hazard, IDEX precisa continuar recebendo
--                  a bolha/NOP, então NÃO pode travar nesse caso)
entity Freeze_Control is
    port(
        stall_hazard   : in  std_logic;
        mem_loading    : in  std_logic;
        pc_ifid_freeze : out std_logic;
        deep_freeze    : out std_logic
        );
end Freeze_Control;

architecture TypeArchitecture of Freeze_Control is
begin
    pc_ifid_freeze <= stall_hazard or mem_loading;
    deep_freeze    <= mem_loading;
end TypeArchitecture;
