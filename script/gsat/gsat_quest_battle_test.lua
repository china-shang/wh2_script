require "data.script.gsat.lib.all"

-- variables_file: quest_battle_variables.txt
 
if(cv_faction_leader == nil or cv_faction_leader == "Random") then
    cv_faction_leader = g_quest_factions[math.random(1, #g_quest_factions)]
end
local faction_leader = cv_faction_leader
local difficulty = cv_difficulty or "Random"
local battle_length = cv_battle_length or 10

-- Loads all of a single factions quest battles then quits out.
Lib.Helpers.Init.script_name("QUEST BATTLE TEST")
Lib.Frontend.Misc.verify()
Lib.Helpers.Loops.load_all_faction_quest_battles(faction_leader, difficulty, battle_length)
Lib.Frontend.Misc.quit_to_windows()