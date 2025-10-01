`timescale 1ns / 1ps

package mips_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "mips_defines.svh"

  `include "mips_instruction_transaction.svh"
  `include "mips_program_transaction.svh"
  `include "mips_memory_transaction.svh"


  `include "mips_parser.svh"
  `include "mips_golden_model.svh"
  `include "mips_instruction_generator.svh"
  `include "mips_coverage.svh"

  `include "mips_sequence_random.svh"
  `include "mips_sequence_undefined.svh"
  `include "mips_sequence_overflow.svh"
  `include "mips_sequencer.svh"


  `include "mips_driver.svh"
  `include "mips_monitor.svh"

  `include "mips_scoreboard.svh"

  `include "mips_agent.svh"

  `include "mips_env.svh"

  `include "mips_test_random.svh"
  `include "mips_test_undefined.svh"
  `include "mips_test_overflow.svh"

endpackage