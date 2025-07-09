# MIPS Single-Cycle - SystemVerilog

Acest proiect implementeaza un procesor MIPS simplificat, de tip single-cycle, scris in SystemVerilog.

## Instructiuni suportate

Procesorul poate executa urmatoarele instructiuni:

- Aritmetice: `add`, `addi`, `sub`
- Logice: `and`, `or`
- Memorie: `lw`, `sw`
- Control: `j`, `beq`, `bne`

## Arhitectura

Procesorul este organizat in stilul clasic al unui MIPS single-cycle si include urmatoarele etape:

- IF (Instruction Fetch)
- ID (Instruction Decode)
- EX (Execute)
- MEM (Memory Access)
- WB (Write Back)

Fiecare instructiune este executata complet intr-un singur ciclu de ceas.

## Module componente

- `program_counter` - retine si actualizeaza adresa instructiunii curente
- `instruction_memory` - memorie ROM pentru instructiuni
- `control` - genereaza semnalele de control pe baza opcode-ului
- `reg_file` - registrii generali
- `sign_extend` - extinde constantele de 16 biti la 32 de biti
- `alu` si `alu_control` - executa operatii aritmetice si logice
- `data_memory` - memorie RAM pentru operatii de tip load/store
- `adder`, `mux2`, `shift_left_2` - componente auxiliare pentru calculul adreselor si selectii

