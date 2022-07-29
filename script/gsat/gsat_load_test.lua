require "data.script.gsat.lib.all"


Lib.Helpers.Init.script_name("LOAD TEST")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_campaign(faction, 1)
Lib.Campaign.Misc.skip_cutscene()
Lib.Menu.Misc.quit_to_frontend()
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_custom_battle(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, false)
Lib.Battle.Misc.start_battle()
Lib.Menu.Misc.quit_to_frontend()
Lib.Battle.Misc.return_to_frontend()
Lib.Frontend.Misc.verify()
Lib.Frontend.Misc.quit_to_windows()
