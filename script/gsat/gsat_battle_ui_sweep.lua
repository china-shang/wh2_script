
require "data.script.gsat.lib.all"

Lib.Helpers.Init.script_name("Battle UI Sweep")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_custom_battle()
Lib.Battle.Misc.start_battle()
Lib.Helpers.UI_Sweeps.custom_battle_clicks()
Lib.Frontend.Misc.quit_to_windows()