-- How to run GSAT Scripts - http://totalwar-confluence:8090/pages/viewpage.action?pageId=16123828
-- How to create GSAT Scripts -  http://totalwar-confluence:8090/pages/viewpage.action?pageId=27541925


require "data.script.gsat.lib.all"

local faction = Lib.Frontend.Campaign.select_random_faction("Mortal Empire")

Lib.Helpers.Init.script_name("Campaign UI Sweep")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_campaign(faction, "Mortal Empire")
Lib.Helpers.UI_Sweeps.campaign_clicks()
Lib.Frontend.Misc.quit_to_windows()
