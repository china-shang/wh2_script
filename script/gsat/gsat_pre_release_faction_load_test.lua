require "data.script.gsat.lib.all"

-- variables_file: faction_load_variables.txt

local campaign_type = cv_campaign_type or "Mortal Empire"
local take_turn_screenshots = cv_turn_screenshots or false
g_campaign_ended_early = false

local faction
if(campaign_type == "Mortal Empire") then
    faction = cv_mortal_empire_faction
elseif(campaign_type == "Vortex") then
    faction = cv_vortex_faction
end

if(faction == nil or faction == "Random") then
    faction = Lib.Frontend.Campaign.select_random_faction(campaign_type)
end

Lib.Helpers.Init.script_name("PRE RELEASE FACTION TEST")
Lib.Frontend.Misc.verify()
Lib.Frontend.Loaders.load_campaign(faction, campaign_type)

if(take_turn_screenshots == true) then
    Common_Actions.take_screenshot("campaign", faction.."_"..campaign_type.."_Turn_1")
end

Lib.Campaign.Misc.end_turn_without_fail()
Lib.Campaign.Misc.clear_end_turn_blockers()

if(take_turn_screenshots == true) then
    Common_Actions.take_screenshot("campaign", faction.."_"..campaign_type.."_Turn_2")
end

Lib.Campaign.Misc.end_turn_without_fail()
Lib.Campaign.Misc.clear_end_turn_blockers()

if(take_turn_screenshots == true) then
    Common_Actions.take_screenshot("campaign", faction.."_"..campaign_type.."_Turn_3")
end

Lib.Menu.Misc.save_game()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.load_most_recent_save()
Lib.Campaign.Misc.clear_end_turn_blockers()
Lib.Menu.Misc.quit_to_frontend()
Lib.Frontend.Misc.quit_to_windows()