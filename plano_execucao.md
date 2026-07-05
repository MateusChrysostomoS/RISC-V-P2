# Plano de execução — CPU RISC-V vetorial (Arquitetura de Computadores)

Este documento registra todas as decisões técnicas do projeto. Ele serve tanto de
guia de implementação quanto de rascunho para a seção "premissas adotadas" do
relatório final.

---

## 1. Ferramenta: Digital (não Logisim-evolution)

**Decisão:** o projeto será construído no simulador **Digital**, conforme exigido
no enunciado. O arquivo que vocês tinham é do Logisim-evolution — os módulos VHDL
podem ser copiados quase sem alteração (VHDL é agnóstico de simulador), mas a
**esquemática (fiação, blocos, posições) precisa ser refeita do zero no Digital**,
porque os formatos de arquivo (`.circ` vs `.dig`) não são compatíveis.

**Ação:** antes de continuar, confirmem com o professor se class Logisim-evolution
seria aceito — mas para não perder tempo, vamos seguir assumindo Digital, que é o
que está escrito no enunciado.

---

## 2. Correções no RV32I base (já feitas)

- `ImmGen`: opcodes de `lui`, `auipc` e `jalr` corrigidos (estavam com bits errados).
- `Control_Unit`: completado com todos os opcodes do subconjunto (`lw`, `jal`,
  `jalr`, `lui`, `auipc`), que estava truncado no arquivo original.

## 3. Decisão: `BranchNotEq` vem do `funct3`, não do opcode

`beq` e `bne` compartilham o mesmo opcode (`1100011`); a diferença está no
`funct3` (bits 14-12 da instrução: `000` = beq, `001` = bne).

**Decisão:** o `Control_Unit` passa a receber `funct3` como entrada adicional e
gera `BranchNotEq` a partir dele, não do opcode.

## 4. Decisão: `auipc` não será vetorizado de fato

O enunciado pede "versão vetorial" de `auipc`, mas a instrução soma um imediato
ao **PC** (não a um registrador) — particionar isso em lanes não tem muito
sentido prático (o PC não é um dado vetorial).

**Decisão estratégica:** `auipc.v` será implementado como **idêntico ao `auipc`
escalar**, apenas aceitando a codificação vetorial no opcode para fins de
conformidade com o enunciado. Isso deve ser explicitado no relatório como uma
simplificação de projeto, com a justificativa acima. Isso é uma escolha de
engenharia legítima e evita complexidade desnecessária sem violar o requisito
("suportar a versão vetorial" — ela existe, só que operacionalmente igual à
escalar, o que é uma decisão de design documentável).

## 5. Decisão: codificação das instruções vetoriais

**Opcode:** `0001011` (opcode `custom-0`, reservado pela spec RISC-V para
extensões não padronizadas — não conflita com nenhuma instrução RV32I).

Todas as instruções vetoriais usam esse mesmo opcode; o `funct3` e o `funct7`
mantêm o mesmo significado do RV32I escalar (mesma tabela), e dois bits antes
não usados do `funct7` (bits 26-25 da instrução) codificam a **largura do
elemento (VEW — Vector Element Width)**:

| VEW (bits 26-25) | Largura do elemento | Lanes na palavra de 32 bits |
|---|---|---|
| `00` | 8 bits  | 4 |
| `01` | 16 bits | 2 |
| `10` | 32 bits | 1 (equivale ao escalar) |
| `11` | reservado (não usado) |  |

Para as instruções I-type vetoriais (`addi.v`, `slli.v`, `srli.v`), os dois bits
mais altos do imediato (`imm[11:10]`) são reaproveitados como VEW, reduzindo o
imediato efetivo para 10 bits com sinal — suficiente para os fins didáticos do
trabalho.

| Instrução | Opcode | funct3 | funct7[6:5]=VEW | funct7[5] |
|---|---|---|---|---|
| `add.v`  | 0001011 | 000 | VEW | 0 |
| `sub.v`  | 0001011 | 000 | VEW | 1 |
| `sll.v`  | 0001011 | 001 | VEW | 0 |
| `srl.v`  | 0001011 | 101 | VEW | 0 |
| `addi.v` | 0001011 | 000 | imm[11:10]=VEW | — |
| `slli.v` | 0001011 | 001 | imm[11:10]=VEW | — |
| `srli.v` | 0001011 | 101 | imm[11:10]=VEW | — |
| `auipc.v`| 0001011 | (funct3 dedicado, ex: 111) | — | — |

## 6. Decisão: a ALU vira uma ALU particionável

A `ALU` ganha uma entrada nova `vec_mode : std_logic_vector(1 downto 0)` (o VEW).
Quando `vec_mode /= "10"`, o somador de 32 bits é dividido em sub-somadores de
8 ou 16 bits, cada um com seu próprio `carry_in` forçado a `'0'` (em vez de
propagar do lane anterior) — isso impede que um overflow em um lane "vaze" para
o lane vizinho, que é a essência de uma operação SIMD.

O deslocador (`shift_left`/`shift_right`) segue a mesma lógica: cada lane desloca
de forma independente, usando só os bits de quantidade de deslocamento relevantes
para o tamanho daquele lane.

## 7. Decisão: dois mecanismos de "pausa" distintos — não confundir

Isso é importante e fácil de misturar:

- **Stall de load-use** (`Harzard` unit): trava só `PC` e `IFID`, e insere uma
  bolha (NOP) no controle que vai para `IDEX` — os estágios seguem rodando,
  só que com uma instrução "vazia" no meio.
- **Freeze de carga de memória** (requisito novo do trabalho): quando a memória
  está sendo carregada externamente, **toda a CPU precisa congelar de verdade** —
  nenhum registrador de pipeline muda, nem insere bolha, só pausa tudo até a
  carga terminar.

**Decisão:** um sinal único `mem_loading` (vindo de fora, indicando carga em
andamento) vira uma entrada de **freeze** em `PC2`, `IFID`, `IDEX`, `EXMEM` e
`MEMWB` — os quatro últimos hoje não têm essa entrada e precisam ganhá-la.
Continua sendo um sinal *separado* do `stall` do hazard detection.

## 7.1 Fiação exata do freeze (não confundir com o stall)

```
PC2.writeEnableL   <= stall_hazard OR mem_loading
IFID.writeEnableL  <= stall_hazard OR mem_loading
IDEX.freeze        <= mem_loading            -- SÓ isso, nunca stall_hazard
EXMEM.freeze       <= mem_loading
MEMWB.freeze       <= mem_loading
```

Se o `IDEX` também travar durante o `stall_hazard`, a bolha (NOP) nunca entra
no pipeline e o load-use hazard não é resolvido — os dois mecanismos precisam
ficar desacoplados dessa forma.

## 9. Fiação da carga assíncrona no Digital

Isso é montagem de esquemática (não dá pra fazer por código sozinho), então
aqui vai o roteiro exato:

1. **Adicionem uma segunda memória (ROM)** só com os dados de teste que vocês
   querem pré-carregar na RAM de dados — chamem de `ROM_fonte`. Ela é
   endereçada pelo `MemLoader.loader_addr`.
2. **Coloquem o componente `MemLoader`** (biblioteca de VHDL do Digital,
   igual aos outros módulos) ligado assim:
   - `src_data` ← saída de dados da `ROM_fonte`
   - `loader_addr` → endereço da `ROM_fonte` **e** um dos lados de um mux de
     endereço que vai pra RAM de dados
   - `clk`, `reset` ← os mesmos sinais globais da CPU
3. **Multiplexador de endereço da RAM de dados**: seletor = `mem_loading`.
   - `mem_loading = '1'` → endereço vem do `MemLoader.loader_addr`
   - `mem_loading = '0'` → endereço vem do datapath normal (saída da ALU)
4. **Multiplexador de dado de entrada da RAM**: mesmo seletor `mem_loading`.
   - `'1'` → dado vem do `MemLoader.loader_data`
   - `'0'` → dado vem do `read2` normal (register file, valor de `sw`)
5. **Multiplexador do `we` (write enable) da RAM**: mesmo seletor.
   - `'1'` → `we` vem do `MemLoader.loader_we`
   - `'0'` → `we` vem do `MemWrite` normal do `Control_Unit`
6. **`mem_loading`** sai do `MemLoader` e alimenta o `Freeze_Control`
   (seção 7.1), que por sua vez trava `PC2`, `IFID`, `IDEX`, `EXMEM`, `MEMWB`.
7. Ajustem `WORD_COUNT` no `MemLoader` para o número de palavras que o teste
   de vocês realmente precisa pré-carregado.

Assim, nos primeiros `WORD_COUNT` ciclos depois do reset, a CPU fica
completamente parada enquanto a RAM é populada; depois disso, `mem_loading`
cai pra `'0'` permanentemente e a CPU roda normalmente.

## 10. Ordem de implementação

1. ✅ `ImmGen` corrigido
2. ✅ `Control_Unit` completado (v1, subconjunto RV32I)
3. ✅ `Control_Unit_v2`: entrada `funct3`, `BranchNotEq` corrigido,
   decodificação do opcode vetorial (`0001011`)
4. ✅ `ALU_v2`: `vec_mode` com somador e deslocador particionados
5. ✅ `IDEX_v2`, `EXMEM_v2`, `MEMWB_v2`: entrada de `freeze`
6. ✅ `Freeze_Control` e `MemLoader`: lógica de carga assíncrona e
   congelamento — falta só desenhar a fiação no Digital seguindo a seção 9
7. ⬜ **Próximo passo:** montar a esquemática completa no Digital com todos
   os módulos v2, ligar os multiplexadores da seção 9, e simular o reset
8. ⬜ Testes: rodar cada instrução (escalar e vetorial) isoladamente,
   depois um programa combinando várias
9. ⬜ Relatório: descrever cada decisão deste documento com a justificativa
