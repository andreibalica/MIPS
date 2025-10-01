# Proiect MIPS - Procesoare Single-Cycle și Pipeline

## Descriere Generală

Acest proiect implementează două variante ale procesorului MIPS-32 în SystemVerilog, bazate pe arhitectura clasică prezentată în **"Computer Organization and Design: The Hardware/Software Interface"** de David A. Patterson și John L. Hennessy:
- **Single-Cycle MIPS**: Implementare simplă unde fiecare instrucțiune se execută într-un singur ciclu de ceas
- **Pipelined MIPS**: Implementare cu pipeline pe 5 etape pentru performanță îmbunătățită

Proiectul include și un mediu complet de verificare folosind UVM (Universal Verification Methodology), conform metodologiei din **"The UVM Primer: An Introduction to the Universal Verification Methodology"** de Ray Salemi, pentru testarea funcționalității procesoarelor.


## Structura Proiectului

```
MIPS/
├── design/
│   ├── mips_single_cycle/     # Implementarea MIPS single-cycle
│   └── mips_pipeline/         # Implementarea MIPS cu pipeline
└── verification/              # Mediul de testare UVM
```

## Arhitectura MIPS Single-Cycle

### Modulul Principal: `mips_single_cycle.sv`

Implementează arhitectura MIPS clasică cu următoarele componente:

#### Componente Principale:
- **Program Counter (PC)**: Gestionează adresa instrucțiunii curente
- **Instruction Memory**: Stochează instrucțiunile programului
- **Register File**: 32 de registre generale de 32-bit
- **ALU**: Unitatea aritmetico-logică pentru operații de calcul
- **Data Memory**: Memoria pentru date (load/store)
- **Control Unit**: Generează semnalele de control pentru datapath

#### Instrucțiuni Suportate:

##### R-Type (Registru-Registru):
- `ADD rd, rs, rt`: Adunare cu detectare overflow
- `SUB rd, rs, rt`: Scădere cu detectare overflow  
- `AND rd, rs, rt`: Operația AND pe biți
- `OR rd, rs, rt`: Operația OR pe biți

##### I-Type (Immediate):
- `ADDI rt, rs, immediate`: Adunare cu valoare imediată
- `LW rt, offset(rs)`: Încărcare cuvânt din memorie
- `SW rt, offset(rs)`: Salvare cuvânt în memorie
- `BEQ rs, rt, offset`: Salt condiționat (egal)
- `BNE rs, rt, offset`: Salt condiționat (diferit)

##### J-Type (Jump):
- `J target`: Salt necondiționat

#### Gestionarea Excepțiilor:
- **Instrucțiuni nedefinite**: Detectare și tratare prin vectori de întrerupere
- **Overflow aritmetic**: Detectare la operații ADD/SUB cu salt la handler
- **Exception Program Counter (EPC)**: Salvează adresa instrucțiunii care a cauzat excepția

## Arhitectura MIPS Pipeline

### Modulul Principal: `mips_pipeline.sv`

Implementează pipeline pe 5 etape conform arhitecturii MIPS clasice:

#### Etapele Pipeline-ului:

1. **IF (Instruction Fetch)**:
   - Citirea instrucțiunii din memorie
   - Incrementarea PC cu 4
   - Predicția salturilor pentru performanță

2. **ID (Instruction Decode)**:
   - Decodarea instrucțiunii
   - Citirea registrelor
   - Generarea semnalelor de control
   - Extinderea semnului pentru immediate

3. **EX (Execute)**:
   - Execuția operației în ALU
   - Calcularea adresei pentru branch
   - Rezolvarea hazard-urilor prin forwarding

4. **MEM (Memory Access)**:
   - Accesul la memoria de date (load/store)
   - Rezolvarea branch-urilor (actualizarea PC)

5. **WB (Write Back)**:
   - Scrierea rezultatului înapoi în registre

### Gestionarea Hazard-urilor:

#### 1. Data Hazards (Dependențe de Date):
- **Forwarding Unit** (`pl_forwarding_control.sv`): 
  - Detectează dependențele RAW (Read After Write)
  - Redirecționează datele de la EX/MEM sau MEM/WB direct la intrările ALU
  - Evită stall-urile pentru majoritatea cazurilor

#### 2. Control Hazards (Salturile):
- **Branch Prediction** (`pl_branch_prediction.sv`):
  - Predictor FSM cu 4 stări care, bazat pe branch-urile anterioare, decide dacă branch-ul actual va fi "not taken" sau "taken"
  - Stări: SNT (Strongly Not Taken), WNT (Weakly Not Taken), WT (Weakly Taken), ST (Strongly Taken)
  - Detectarea misprediction și flush pipeline
  - Penalizare de 3 cicluri la predicție incorectă
- **Hazard Detection** (`pl_hazard_detection.sv`):
  - Detectează hazard-urile load-use
  - Inserează bubble-uri (NOP) când este necesar

### Optimizări de Performanță:
- **Branch Prediction**: Reduce penalizarea pentru branch-uri
- **Forwarding**: Elimină majoritatea stall-urilor de date
- **Pipeline Flush**: Curăță pipeline-ul la branch misprediction

## Mediul de Verificare UVM

### Structura Testbench-ului:

#### Componente UVM:
- **`mips_agent.svh`**: Agent UVM pentru controlul testului
- **`mips_driver.svh`**: Driver pentru stimulii procesorului
- **`mips_monitor.svh`**: Monitor pentru colectarea răspunsurilor
- **`mips_scoreboard.svh`**: Verificarea corectitudinii funcționale
- **`mips_coverage.svh`**: Colectarea acoperirii funcționale

#### Modele de Referință:
- **`mips_golden_model.svh`**: Model software de referință pentru MIPS
- **`mips_instruction_generator.svh`**: Generator de instrucțiuni aleatorii

#### Tipuri de Teste:

##### 1. Test Random (`mips_test_random.sv`):
- Generează secvențe aleatorii de instrucțiuni
- Verifică funcționalitatea generală
- Testează corner cases prin randomizare

##### 2. Test Overflow (`mips_test_overflow.sv`):
- Testează specific detectarea și gestionarea overflow-ului
- Verifică vectorii de excepții

##### 3. Test Undefined Instructions (`mips_test_undefined.sv`):
- Testează instrucțiuni invalide/nedefinite
- Verifică mecanismul de gestionare a erorilor
