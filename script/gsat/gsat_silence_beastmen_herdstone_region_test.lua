require "data.script.gsat.lib.all"
local file = [[\\ca-data\tw\Automation\WH2\Silence\?.lua]]
package.path = package.path .. ";" ..file
require "ME_campaignregion_luatable"

-- variables_file: bloodgrounds_build_herdstone_variables.txt
local campaign_type = cv_campaign_type or "Mortal Empire"

local faction = "Taurox the Brass Bull"

g_successful_regions = {}
g_unsuccessful_regions = {}
g_watchers_set = false

Lib.Helpers.Init.script_name("HERDSTONE REGION BUILD TEST")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_campaign(faction, campaign_type)

Common_Actions.trigger_console_command("campaign_debug_tree_auto_end_turn_all")
Utilities.print("-----Total number of regions to build on = "..#g_me_regiontable.."-----")
Lib.Campaign.Misc.make_faction_leader_immortal()
for _,region_key in pairs(g_me_regiontable) do
	Lib.Campaign.Silence.Misc.build_herdstone_on_region(region_key)
	Lib.Campaign.Silence.Misc.confrim_bloodgrounds_before_abandon(region_key)
	Lib.Campaign.Misc.end_turn_without_fail()
	Lib.Campaign.Misc.clear_end_turn_blockers()
end

Lib.Menu.Misc.save_game()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.load_most_recent_save()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.quit_to_frontend()
Lib.Frontend.Misc.quit_to_windows()