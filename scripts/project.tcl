create_project ludi-v /ludi-v -part xc7a35ticsg324-1L
set_property simulator_language Verilog [current_project]
add_files -norecurse {/rtl/top.sv /rtl/core/stage_decode.sv /rtl/core/stage_execute.sv /rtl/core/stage_fetch.sv /rtl/core/stage_memory.sv /rtl/core/instr_mem.sv /rtl/core/stage_writeback.sv}
add_files -fileset constrs_1 -norecurse /constraints/Arty-A7-35-Master.xdc
update_compile_order -fileset sources_1
