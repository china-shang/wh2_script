
require "data.script.gsat.lib.all"

Lib.Helpers.Init.script_name("Frontend UI Sweep")
Lib.Frontend.Misc.verify()
Lib.Helpers.UI_Sweeps.custom_battle_lobby_ui()
Lib.Helpers.UI_Sweeps.multiplayer_config_clicks()
Lib.Helpers.UI_Sweeps.replays_clicks()
Lib.Helpers.UI_Sweeps.the_laboratory_clicks()
Lib.Helpers.UI_Sweeps.options_clicks()
Lib.Frontend.Misc.quit_to_windows()