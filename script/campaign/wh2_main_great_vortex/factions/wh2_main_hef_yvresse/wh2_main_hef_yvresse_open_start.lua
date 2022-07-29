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
		local personality_key = "wh2_darkelf_early_internally_hostile_aggressive_easy";
		
		if difficulty_level == 0 or difficulty_level == -1 then
			personality_key = "wh2_darkelf_early_internally_hostile_aggressive";							-- normal/hard
		elseif difficulty_level == -2 or difficulty_level == -3 then
			personality_key = "wh2_darkelf_early_internally_hostile_aggressive_less_diplomatic_hard";		-- v.hard/legendary
		end;
		
		-- prevents the supplied principal enemy faction from being able to request peace, sets them into the supplied personality, and prevents anyone from arranging a NAP or a trade agreement with the player until a message is received
		-- also prevents anyone declaring war with the player for the specified number of turns from the start of the game
		-- enemy_faction_key, enemy_personality_key, num_turns_before_war
		start_early_game_diplomacy_setup_listener(
			"wh2_main_grn_arachnos",
			personality_key,
			3
		);
	end;
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- prevent specific nearby enemy character from moving too far at start of game, so the player can chase them down
	-- lord_cqi, [list of effect bundles to be applied per-turn]
	do
		local char_cqi = cm:get_cached_value(
			"enemy_lockdown_char_cqi",
			function()
				local character = cm:get_faction("wh2_main_grn_arachnos"):faction_leader();
				if character then
					return character:cqi();
				end;
			end
		);
		
		start_early_game_character_lockdown_listener(
			char_cqi, 
			"wh_main_reduced_movement_range_90",
			"wh_main_reduced_movement_range_60",
			"wh_main_reduced_movement_range_30"
		);
	end;
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		"wh2_dlc15.camp.vortex.eltharion.early_game.001",
		nil, 
		"wh2_dlc15_hef_eltharion_early_game_capture_settlement",
		"LOREMASTER_TALARIAN",
		"wh2_main_vor_northern_yvresse_tralinia",
		"wh2_main_grn_arachnos",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		},
		true
	);
	
	--[[
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		"wh2_dlc15.camp.vortex.eltharion.early_game.003",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_capture_province",
		"LOREMASTER_TALARIAN",
		{
			"money 2000",
			"influence 5"
		}
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_enact_commandment",
		"LOREMASTER_TALARIAN",
		{
			"money 500",
			"influence 2"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		"wh2_dlc15.camp.vortex.eltharion.early_game.002",
		nil,
		"wh2_main_vor_northern_yvresse_sardenath",
		3,
		"wh2_dlc15_hef_eltharion_early_game_search_ruins",
		"LOREMASTER_TALARIAN",
		{
			"money 500",
			"influence 1"
		},
		{}
		--{		-- factions to modify the personality of
		--	{
		--		["faction_key"] = "wh2_main_hef_caledor",
		--		["start_personality_easy"] = "wh2_highelf_early_noruins_internally_hostile_aggressive_easy",
		--		["start_personality_normal"] = "wh2_highelf_early_noruins_internally_hostile_aggressive",
		--		["start_personality_hard"] = "wh2_highelf_early_noruins_internally_hostile_aggressive_less_diplomatic_hard",
		--		["complete_personality_easy"] = "wh2_highelf_early_internally_hostile_aggressive_easy",
		--		["complete_personality_normal"] = "wh2_highelf_early_internally_hostile_aggressive",
		--		["complete_personality_hard"] = "wh2_highelf_early_internally_hostile_aggressive_less_diplomatic_hard"
		--	}
		--}
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil, 
		"wh2_dlc15_hef_eltharion_early_game_rogue_armies",
		"LOREMASTER_TALARIAN",
		"wh2_main_rogue_teef_snatchaz", 
		{
			{v(670, 528), "wh2_main_vor_northern_yvresse_tralinia"},
			{v(638, 518), "wh2_main_vor_northern_yvresse_tralinia"},
			{v(627, 539), "wh2_main_vor_northern_yvresse_tralinia"},
			{v(616, 576), "wh2_main_vor_northern_yvresse_tralinia"}
		},
		"wh_main_grn_cav_goblin_wolf_chariot,wh_main_grn_cha_goblin_big_boss_0,wh_main_grn_inf_night_goblin_archers,wh_main_grn_inf_night_goblin_archers,wh_main_grn_inf_night_goblins,wh_main_grn_inf_night_goblins,wh_main_grn_art_goblin_rock_lobber", 
		"wh2_main_vor_northern_yvresse_tralinia",
		{
			"money 2000",
			"influence 5"
		}
	);
	]]--
	
	-- upgrade settlement mission
	-- triggers after the first attack
	-- mission_key, building_key, region_key, mission_rewards
	start_early_game_upgrade_settlement_mission_listener(
		"wh2_dlc15_hef_eltharion_early_game_upgrade_settlement",
		"LOREMASTER_TALARIAN",
		"wh2_main_hef_resource_marble_1",
		"wh2_main_vor_northern_yvresse_tor_yvresse",
		{
			"money 500",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- tech building mission
	-- triggers after the player upgrades their settlement
	-- advice_key, infotext, mission_key, building_key, table of tech building keys, mission_rewards
	start_early_game_tech_building_mission_listener(
		"wh2.camp.vortex.advice.early_game.tech_buildings.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_construct_tech_building",
		"LOREMASTER_TALARIAN",
		{
			"wh2_main_hef_barracks_2"
		},
		{
			"money 500",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_research_tech",
		"LOREMASTER_TALARIAN",
		{
			"money 500",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- public order mission
	-- triggers if the player is suffering public order problems in their principal settlement (primary lords only)
	-- advice_key, infotext, mission_key, region_key, mission_rewards
	start_early_game_public_order_mission_listener(
		"wh2.camp.vortex.advice.early_game.public_order.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_public_order",
		"LOREMASTER_TALARIAN",
		"wh2_main_vor_northern_yvresse_tor_yvresse",
		{
			"money 1000",
			"influence 2",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		},
		true
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		"wh2.camp.vortex.advice.early_game.eliminate_faction.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_eliminate_faction",
		"LOREMASTER_TALARIAN",
		"wh2_main_grn_arachnos",
		1,
		25,
		{
			"money 2000",
			"influence 3",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_upgrade_settlement_part_two",
		"LOREMASTER_TALARIAN",
		"wh2_main_vor_northern_yvresse_tor_yvresse",
		"wh2_dlc15_special_settlement_tor_yvresse_eltharion_2",
		"wh2_dlc15_special_settlement_tor_yvresse_eltharion_3",
		{
			"money 1000",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- hero building mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to construct one of the target buildings
	-- optional turn delay introduces a turn countdown delay between the completion of the building and the issuing of the mission
	-- advice_key, infotext, mission_key, trigger_building_list, turn_delay, target_building_list, mission_rewards
	start_early_game_hero_building_mission_listener(
		"wh2.camp.vortex.advice.early_game.hero_buildings.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_hero_building_mission",
		"LOREMASTER_TALARIAN",
		{
			"wh2_main_hef_outpostnorsca_major_2",
			"wh2_main_hef_outpostnorsca_major_2_coast",
			"wh2_main_hef_outpostnorsca_minor_2",
			"wh2_main_hef_outpostnorsca_minor_2_coast",
			"wh2_main_hef_settlement_major_2",
			"wh2_main_hef_settlement_major_2_coast",
			"wh2_main_hef_settlement_minor_2",
			"wh2_main_hef_settlement_minor_2_coast",
			"wh2_main_special_settlement_lothern_2",
			"wh2_main_special_settlement_altdorf_hef_2",
			"wh2_main_special_settlement_athel_loren_hef_2",
			"wh2_main_special_settlement_black_crag_hef_2",
			"wh2_main_special_settlement_castle_drakenhof_hef_2",
			"wh2_main_special_settlement_colony_major_hef_2",
			"wh2_main_special_settlement_colony_minor_hef_2",
			"wh2_main_special_settlement_couronne_hef_2",
			"wh2_main_special_settlement_eight_peaks_hef_2",
			"wh2_main_special_settlement_hexoatl_hef_2",
			"wh2_main_special_settlement_itza_hef_2",
			"wh2_main_special_settlement_karaz_a_karak_hef_2",
			"wh2_main_special_settlement_khemri_hef_2",
			"wh2_main_special_settlement_kislev_hef_2",
			"wh2_main_special_settlement_lahmia_hef_2",
			"wh2_main_special_settlement_miragliano_hef_2",
			"wh2_main_special_settlement_naggarond_hef_2"
		},
		1,
		{
			"wh2_main_hef_mages_1",
			"wh2_main_hef_court_1"
		},
		{
			"money 500",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- hero recruitment mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to recruit a hero
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_recruitment_mission_listener(
		"wh2.camp.vortex.advice.early_game.recruit_hero.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_hero_recruitment_mission",
		"LOREMASTER_TALARIAN",
		{
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- hero action mission
	-- triggers when the player gains their first hero
	-- issues the supplied advice, and a mission to use a hero action
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_action_mission_listener(
		"wh2.camp.vortex.advice.early_game.hero_actions.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_hero_action_mission",
		"LOREMASTER_TALARIAN",
		{
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
		
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my Lord, for there are foreign powers sympathetic to your cause. Relations may be built with them through diplomacy. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc15_hef_eltharion_early_game_non_aggression_pact", 
		"LOREMASTER_TALARIAN",
		"wh2_main_hef_cothique", 
		7,
		{
			"money 500",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
	
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		"wh2.camp.vortex.advice.early_game.trade_agreements.004",
		{
			"wh2.camp.advice.espionage.info_001",
			"wh2.camp.advice.espionage.info_002",
			"wh2.camp.advice.espionage.info_003",
			"wh2.camp.advice.espionage.info_004"
		},
		"wh2_dlc15_hef_eltharion_early_game_trade_agreement",
		"LOREMASTER_TALARIAN",
		"wh2_main_hef_chrace",
		3,
		12,
		{
			"money 1000",
			"influence 1",
			"faction_pooled_resource_transaction{resource wardens_supply;factor wh2_dlc15_resource_factor_wardens_supply_missions;amount " .. early_game_hef_eltharion_warden_supplies .. ";}"
		}
	);
end;




