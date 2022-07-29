require "data.script.gsat.lib.all"

-- variables_file: benchmark_variables.txt

local benchmark_choice = cv_benchmark or "campaign benchmark"
local gfx_choice = cv_gfx_preset or "Default"

Utilities.print(benchmark_choice)
Utilities.print(gfx_choice)

Lib.Helpers.Init.script_name("Benchmark Test")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_benchmark(benchmark_choice, gfx_choice)
Lib.Helpers.Misc.exit_benchmark_when_finished()
Lib.Frontend.Misc.quit_to_windows()