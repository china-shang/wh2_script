


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	OPEN CAMPAIGN INTRO SCRIPT
--
--	Script for the intro to the main open campaign - loaded if the player hasn't
--	selected to play the intro first turn on the frontend, or if they have and
--	they've completed it
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

---------------------------------------------------------------
--	Start the open campaign from the intro cutscene (first-turn skipped)
---------------------------------------------------------------

function start_open_campaign_from_intro_cutscene()

	-- show advisor dismiss button
	cm:modify_advice(true);

	start_open_campaign(false);
end;










---------------------------------------------------------------
--	Start the open campaign (shared)
---------------------------------------------------------------

function start_open_campaign(from_intro_first_turn)
	out("start_open_campaign() called, from intro first turn: " .. tostring(from_intro_first_turn));
	
	-- start interventions
	start_interventions();
	
	-- kicks off mission proceedings
	start_early_game_missions(from_intro_first_turn, true);
end;








---------------------------------------------------------------
--	Start all faction-specific interventions
---------------------------------------------------------------

function start_interventions()

	out.interventions("* start_interventions() called");
	out("* start_interventions() called");
	
	--[[
	in_empire_technology_requirements:start();
	in_empire_technologies:start();
	in_empire_racial_advice:start();
	in_offices_advice:start();
	]]
			
	-- global
	start_global_interventions(true);
end;

















---------------------------------------------------------------
--	Early-game missions
--	Start the listeners that trigger the early-game missions.
--	the underlying functions are found in wh2_early_game.lua
---------------------------------------------------------------

-- do this immediately upon load of this file
do
	-- how they play event message that appears at the start of the open campaign
	start_early_game_how_they_play_listener();
	

	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name (OR char cqi), enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		
		"wh2.dlc17.camp.vortex.oxyotl.early.game.001.threat_map",
		nil, 
		"wh2_dlc17_lzd_oxyotl_early_game_capture_settlement",
		"YUKANNADOOZAT",
		"wh2_main_vor_deadwood_shagrath",
		"wh2_dlc17_nor_deadwood_ravagers",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource lzd_sanctum_gems;factor wh2_dlc17_resource_factor_sanctum_gems_retrieved;amount 2}"
		},
		true
	);
	

	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc17_lzd_oxyotl_early_game_raise_new_army",
		"YUKANNADOOZAT",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource lzd_sanctum_gems;factor wh2_dlc17_resource_factor_sanctum_gems_retrieved;amount 4}"
	
		}
	);

	start_early_game_ritual_category_mission_listener(
		"wh2.dlc17.camp.vortex.oxyotl.early.game.003.sanctum_buildings", 
		nil, 
		"wh2_dlc17_lzd_oxyotl_early_game_construct_building_in_silent_sanctum", 
		"OXYOTL_TELEPORTATION",
		"lzd_sanctum_points", 
		1, 
		"YUKANNADOOZAT",
		{
			"money 1000"
		},
		"mission_text_text_wh2_dlc17_threat_map_mis_override_build_sanctum_1"
	)

	start_generic_scripted_mission_listener(
	"wh2_dlc17_lzd_oxyotl_early_game_complete_threat_mission",
	"YUKANNADOOZAT",
	{
		"money 1000",
		"faction_pooled_resource_transaction{resource lzd_sanctum_gems;factor wh2_dlc17_resource_factor_sanctum_gems_retrieved;amount 4}"
	}, 
	"mission_text_text_mis_objective_oxyotl_resolve_threat", 
	"ScriptEventOxyThreatMapCreated", 
	"ScriptEventOxyThreatMapSuccess")

end;