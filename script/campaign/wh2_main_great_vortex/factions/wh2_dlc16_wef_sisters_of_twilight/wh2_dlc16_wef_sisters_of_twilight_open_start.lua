


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
	
	-- kicks off mission proceedings
	start_early_game_missions(from_intro_first_turn);

	---sisters Vortex narrative
	cm:trigger_mission("wh2_dlc16_wef_sisters_of_twilight", "wh2_dlc16_wef_sisters_vortex_narrative_1", true)
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
	
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
		
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- [[col:green]]The very presence of these emerald horrors imperils our mission, Arahan.[[/col]]\n[[col:magic]]Don't be so coy, sister. Just come out and say "let's kill thousands of Orcs."[[/col]]\n[[col:green]]What matters is cleansing the settlement of threat, not your wearisome bloodthirst.[[/col]]
		"wh2_dlc16.camp.vortex.sisters.early_game.001",
		nil, 
		"wh2_dlc16_wef_sisters_early_game_capture_settlement",
		"PROPHETESS_NAIETH",
		"wh2_main_vor_obsidian_peaks_ice_spire",
		"wh2_dlc16_grn_naggaroth_orcs",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 5;}"
		},
		true,
		nil,
		nil,
		true
	);
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- [[col:green]]Greenskins are like fungus.  While their infection remains, their obscene growth will continue unabated.[[/col]]\n[[col:magic]]You can do it, Naestra. Say the words I long to hear.[[/col]]\n[[col:green]]…Very well. We must eradicate the Greenskins.[[/col]]\n[[col:magic]]I love you, sister.[[/col]]
		"wh2_dlc16.camp.vortex.sisters.early_game.002",
		nil,
		"wh2_dlc16_wef_sisters_early_game_eliminate_faction",
		"PROPHETESS_NAIETH",
		"wh2_dlc16_grn_naggaroth_orcs",
		1,
		25,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 15;}"
		},
		true
	);

	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		-- You now have the facilities to begin technological research, my Lord. It only remains for you to choose the direction of development.
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_research_tech",
		"PROPHETESS_NAIETH",
		{
			"money 500"
		},
		false,
		true,
		2
	);
	
	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		-- The population of your province grows, mighty Lord. See that the expansion continues, so that you may further develop your realm.
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_upgrade_settlement_part_two",
		"PROPHETESS_NAIETH",
		"wh2_main_vor_naggaroth_glade",
		{
			"wh_dlc05_wef_settlement_major_main_2"
		},
		{
			"wh_dlc05_wef_settlement_major_main_3"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 5;}"
		}
	);
	
	-- hero building mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to construct one of the target buildings
	-- optional turn delay introduces a turn countdown delay between the completion of the building and the issuing of the mission
	-- advice_key, infotext, mission_key, trigger_building_list, turn_delay, target_building_list, mission_rewards
	start_early_game_hero_building_mission_listener(
		-- The wars to come will be fought using guile as well as brawn. Consider expanding your facilities to permit the recruitment of Heroes, my Lord. Heroes can be hired to support your forces, or to strike against the enemy.
		"wh2.camp.vortex.advice.early_game.hero_buildings.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_hero_building_mission",
		"PROPHETESS_NAIETH",
		{	
			"wh_dlc05_wef_settlement_major_main_2"
		},
		1,
		{
			"wh_dlc05_wef_spellsingers_1",
			"wh_dlc05_wef_tree_spirits_2",
			"wh_dlc05_wef_melee_2"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 5;}"
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
		"wh2_dlc16_wef_sisters_early_game_hero_action_mission",
		"PROPHETESS_NAIETH",
		{
			"money 500"
		}
	);
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_raise_army_mission",
		"PROPHETESS_NAIETH",
		{
			"money 500"
		}
	);
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my lord, for there are foreign powers sympathetic to your cause. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_non_aggression_pact",
		"PROPHETESS_NAIETH",
		"wh2_main_def_clar_karond",
		5,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 10;}"
		}
	);
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		-- Relations abroad have blossomed since agreeing a pact of non-aggression, my lord. A trade agreement may now be possible. Let your merchants flourish, for industry drives war.
		"wh2.camp.vortex.advice.early_game.trade_agreements.001",
		nil,
		"wh2_dlc16_wef_sisters_early_game_trade_agreement",
		"PROPHETESS_NAIETH",
		"wh2_main_def_clar_karond",
		3,
		10,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wef_worldroots_naggarond_glade_vortex;factor wh2_dlc11_resource_factor_other;amount 10;}"
		}
	);
	
end;
