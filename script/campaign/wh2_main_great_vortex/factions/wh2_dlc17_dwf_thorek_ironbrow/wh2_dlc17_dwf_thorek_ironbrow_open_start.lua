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
--	Start the open campaign from the intro first-turn
---------------------------------------------------------------

function start_open_campaign_from_intro_first_turn()
	
	cm:disable_end_turn(false);
	
	-- reset first-turn ui status, including diplomacy
	cm:get_campaign_ui_manager():display_first_turn_ui(true);
	
	-- start listeners for post-battle victory and defeat
	in_post_normal_battle_victory_options:start();
	in_post_battle_defeat_options:start();
	
	core:add_listener(
		"start_open_campaign_from_intro_first_turn",
		"ScriptEventPlayerFactionTurnStart",
		true,
		function()
			-- allow characters to take experience again
			cm:set_character_experience_disabled(false);
		
			-- remove second battle override, so that it doesn't trigger again
			cm:remove_custom_battlefield("intro_battle_2");
		
			start_open_campaign(true);
		end,
		false
	);
end;

---------------------------------------------------------------
--	Start the open campaign (shared)
---------------------------------------------------------------

function start_open_campaign(from_intro_first_turn)
	out("start_open_campaign() called, from intro first turn: " .. tostring(from_intro_first_turn));
	
	-- start interventions
	start_interventions();
	
	-- show advisor progress button
	cm:modify_advice(true);
	
	-- kicks off mission proceedings
	start_early_game_missions(from_intro_first_turn);
end;

---------------------------------------------------------------
--	Start all faction-specific interventions
---------------------------------------------------------------

function start_interventions()

	out.interventions("* start_interventions() called");
	out("* start_interventions() called");
	
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
	
	
	local difficulty_level = cm:model():difficulty_level();
	
	do
		local personality_key = "wh2_skaven_early_internally_hostile_aggressive_easy";
		
		if difficulty_level == 0 or difficulty_level == -1 then
			personality_key = "wh2_skaven_early_internally_hostile_aggressive";							-- normal/hard
		elseif difficulty_level == -2 or difficulty_level == -3 then
			personality_key = "wh2_skaven_early_internally_hostile_aggressive_less_diplomatic_hard";		-- v.hard/legendary
		end;
		
		-- prevents the supplied principal enemy faction from being able to request peace, sets them into the supplied personality, and prevents anyone from arranging a NAP or a trade agreement with the player until a message is received
		-- also prevents anyone declaring war with the player for the specified number of turns from the start of the game
		-- enemy_faction_key, enemy_personality_key, num_turns_before_war
		start_early_game_diplomacy_setup_listener(
			"wh2_dlc12_skv_clan_mange",
			personality_key,
			3
		);
	end;
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		"wh2_dlc17.camp.advice.dwf.thorek_story.001",
		nil, 
		"wh2_dlc17_dwf_thorek_early_game_capture_settlement",
		"KING_KAZADOR",
		"wh2_main_vor_southern_spine_of_sotek_mine_of_the_bearded_skulls",
		"wh2_dlc12_skv_clan_mange",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 5;}"
		},
		true
	);
	
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province		-- (set to 2 provinces)
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		"wh2.camp.vortex.advice.early_game.provinces.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_capture_province",
		"KING_KAZADOR",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 20;}"
		},
		"2"
	);
	
	-- search ruins listener
	-- triggers at the start of turn six
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		"wh2.camp.vortex.advice.early_game.treasure_hunting.001",
		nil,
		"wh2_main_vor_the_lost_valleys_subatuun",
		6,
		"wh2_dlc17_dwf_thorek_early_game_search_ruins",
		"KING_KAZADOR",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 10;}"
		},
		{},
		false
	);
	
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		"wh2.dlc17.camp.vortex.thorek.ironbrow.early.game.002.technology",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_research_tech",
		"KING_KAZADOR",
		{
			"money 500"
		},
		false,
		true,
		2,
		3
	);
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		"wh2.camp.vortex.advice.early_game.eliminate_faction.010",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_eliminate_faction",
		"KING_KAZADOR",
		"wh2_dlc12_skv_clan_mange",
		1,
		25,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 20;}"
		}
	);


	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		-- The population of your province grows, mighty Lord. See that the expansion continues, so that you may further develop your realm.
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_upgrade_settlement_part_two",
		"KING_KAZADOR",
		"wh2_main_vor_southern_spine_of_sotek_mine_of_the_bearded_skulls",
		{
			"wh_main_dwf_settlement_major_2"	-- only using major and not including minor, so this doesn't trigger on camapign start
		},
		{
			"wh_main_dwf_settlement_major_3",
			"wh_main_dwf_settlement_minor_3"
		},
		{
			"money 500",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 10;}"
		}
	);
	
	-- hero building mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to construct one of the target buildings
	-- optional turn delay introduces a turn countdown delay between the completion of the building and the issuing of the mission
	-- advice_key, infotext, mission_key, trigger_building_list, turn_delay, target_building_list, mission_rewards
	start_early_game_hero_building_mission_listener(
		"wh2.dlc17.camp.vortex.thorek.ironbrow.early.game.003.recruitment",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_construct_hero_building",
		"KING_KAZADOR",
		{
			"wh_main_dwf_settlement_major_3",
			"wh_main_dwf_settlement_minor_3"
		},
		1,
		{
			"wh_main_dwf_smith_1"
		},
		{
			"money 500",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 15;}"
		}
	);
	
	
	-- hero action mission
	-- triggers when the player gains their first hero
	-- issues the supplied advice, and a mission to use a hero action
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_action_mission_listener(
		-- A hero has enrolled in your service, my Lord. Be sure to put them to work - their unique skills may solve problems that no amount of money or effort would otherwise be able to crack.
		"wh2.camp.vortex.advice.early_game.hero_actions.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_hero_action_mission",
		"KING_KAZADOR",
		{
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 20;}"
		}
	);
	
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_raise_army_mission",
		"KING_KAZADOR",
		{
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 20;}"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_non_aggression_pact", 
		"KING_KAZADOR",
		"wh2_main_lzd_southern_sentinels", 
		7,
		{
			"money 500"
		}
	);
	
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		"wh2.camp.vortex.advice.early_game.trade_agreements.001",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_trade_agreement",
		"KING_KAZADOR",
		"wh2_main_lzd_southern_sentinels",
		3,
		12,
		{
			"money 1000"
		}
	);


	-- resources mission
	-- Triggers after a supplied number of turns, or if the player goes within a turn's march of the supplied settlement with any military force. It won't trigger if the
	-- player somehow gets the resource beforehand (unless they lose it again).	
	-- advice_key, infotext, region_key, turn_threshold, mission_key, resource_key, mission_issuer, mission_rewards
	start_early_game_resources_mission_listener(
		"war.camp.advice.resources.001", 
		nil, 
		"wh2_main_vor_central_spine_of_sotek_chiquibol",
		3, 
		"wh2_dlc17_dwf_thorek_early_game_resources", 
		"res_gems", 
		"KING_KAZADOR", 
		{
			"money 500",
			"faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 20;}"
		}
	);


	-- pooled resources mission
	-- Triggers once the player has accumulated the supplied minimum amount of the supplied pooled resource. Issues a mission
	-- to earn the higher threshold of the same resource
	-- advice_key, infotext, mission_key, resource_name, resource_min_threshold, resource_mission_threshold, mission_issuer, mission_rewards
	start_early_game_pooled_resource_mission_listener(
		"",
		nil,
		"wh2_dlc17_dwf_thorek_early_game_oathgold",
		"dwf_oathgold",
		1,
		15,
		"KING_KAZADOR",
		{
			"money 1000"
		}
	);
	

	start_generic_scripted_mission_listener(
		"wh2_dlc17_dwf_thorek_early_game_forge_artifact",
		"KING_KAZADOR",
		{
			"money 1000"
		},
		"mission_text_text_mis_objective_thorek_forge_artefact",
		"ScriptEvent_StartForgeArtefactMission",
		"ScriptEvent_CompleteForgeArtefactMission"
	);

	core:add_listener(
		"ThorekEG_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return context:faction():name() == "wh2_dlc17_dwf_thorek_ironbrow" and cm:turn_number() >= 3;				
		end,
		function(context)
			core:trigger_event("ScriptEvent_StartForgeArtefactMission");
		end,
		true
	);

	core:add_listener(
		"ThorekEG_RitualCompletedEvent",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_key():find("wh2_dlc17_dwf_ritual_thorek_artifact_");
		end,
		function(context)
			core:trigger_event("ScriptEvent_CompleteForgeArtefactMission");
		end,
		true
	);
	

end;

