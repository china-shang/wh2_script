require "data.script.gsat.lib.all"
local file = [[\\ca-data\tw\Automation\WH2\Silence\?.lua]]
package.path = package.path .. ";" ..file
require "ME_campaignregion_luatable"

-- variables_file: silent_sanctum_build_variables.txt
local campaign_type = cv_campaign_type or "Mortal Empire"

local faction = "Oxyotl"

g_successful_regions = {}
g_unsuccessful_regions = {}

Lib.Helpers.Init.script_name("SILENT SANCTUM REGION BUILD TEST")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_campaign(faction, campaign_type)

-- It takes 8 sanctum stones to be granted 1 sanctum point. You start the campaign with 3 so we are adding 805 to be taken to 101 Sanctum Points.
Lib.Campaign.Silence.Misc.add_sanctum_stones(805)
Common_Actions.trigger_console_command("campaign_debug_tree_auto_end_turn_all")
Utilities.print("-----Total number of regions to build on = "..#g_me_regiontable.."-----")
for _,region_key in pairs(g_me_regiontable) do
	Lib.Campaign.Silence.Misc.create_silent_sanctum_at_region(region_key)
	Lib.Campaign.Misc.end_turn_without_fail()
	Lib.Campaign.Misc.clear_end_turn_blockers()
end

Lib.Campaign.Silence.Misc.confirm_sanctum_build_results()
Lib.Menu.Misc.save_game()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.load_most_recent_save()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.quit_to_frontend()
Lib.Frontend.Misc.quit_to_windows()