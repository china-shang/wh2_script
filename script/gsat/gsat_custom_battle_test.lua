-- How to run GSAT Scripts - http://totalwar-confluence:8090/pages/viewpage.action?pageId=16123828
-- How to create GSAT Scripts -  http://totalwar-confluence:8090/pages/viewpage.action?pageId=27541925

-- variables_file: custom_battle_variables.txt

require "data.script.gsat.lib.all"


local battle_count = cv_battle_count or 1
local battle_length = cv_battle_length or 20
local team_1_size = cv_team_1_size or math.random(1,4)
local team_2_size = cv_team_2_size or math.random(1,4)
local battle_type = cv_battle_type or "Random"
local map_preset = cv_map_preset or "Random"
local difficulty = cv_difficulty or "Random"
local time = cv_time or "Random"
local funds = cv_funds or "Random"
local realism = cv_realism or "Random"
local large_armies = cv_large_armies or "Random"
local tower_level = cv_tower_level or "Random"
local unit_caps = cv_unit_caps or false

g_army_faction = {
    [1] = {},
    [2] = {}
}

g_army_faction[1][1] = cv_army_faction_1_1 or nil
g_army_faction[1][2] = cv_army_faction_1_2 or nil
g_army_faction[1][3] = cv_army_faction_1_3 or nil
g_army_faction[1][4] = cv_army_faction_1_4 or nil
g_army_faction[2][1] = cv_army_faction_2_1 or nil
g_army_faction[2][2] = cv_army_faction_2_2 or nil
g_army_faction[2][3] = cv_army_faction_2_3 or nil
g_army_faction[2][4] = cv_army_faction_2_4 or nil

Lib.Helpers.Init.script_name("Custom Battle Sweep")
Lib.Frontend.Misc.verify()
Lib.Helpers.Loops.custom_battle_loop(battle_count, battle_length, team_1_size, team_2_size, battle_type, map_preset, difficulty, time, funds, realism, large_armies, tower_level, unit_caps)
Lib.Frontend.Misc.quit_to_windows()