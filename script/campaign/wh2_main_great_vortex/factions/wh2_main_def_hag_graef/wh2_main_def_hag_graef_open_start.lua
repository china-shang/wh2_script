


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
	
	
	local difficulty_level = cm:model():difficulty_level();
	
	do
		local personality_key = "wh2_lizardmen_early_internally_hostile_aggressive_easy";
		
		if difficulty_level == 0 or difficulty_level == -1 then
			personality_key = "wh2_lizardmen_early_internally_hostile_aggressive";							-- normal/hard
		elseif difficulty_level == -2 or difficulty_level == -3 then
			personality_key = "wh2_lizardmen_early_internally_hostile_aggressive_less_diplomatic_hard";		-- v.hard/legendary
		end;
		
		-- prevents the supplied principal enemy faction from being able to request peace, sets them into the supplied personality, and prevents anyone from arranging a NAP or a trade agreement with the player until a message is received
		-- also prevents anyone declaring war with the player for the specified number of turns from the start of the game
		-- enemy_faction_key, enemy_personality_key, num_turns_before_war
		start_early_game_diplomacy_setup_listener(
			southern_sentinels_faction_str,
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
				local character = cm:get_closest_general_to_position_from_faction(southern_sentinels_faction_str, 276, 80, false);
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
		"wh2_dlc14.camp.vortex.malus_darkblade.early_game.001",
		nil, 
		"wh2_dlc14_def_malus_early_game_capture_settlement",
		"FELICION",
		"wh2_main_vor_sea_of_dread_tower_of_the_sun",
		"wh2_main_hef_tor_elasor",
		{
			"money 500"
		},
		true
	);
		
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		"wh2.camp.vortex.advice.early_game.provinces.001",
		nil,
		"wh2_dlc14_def_malus_early_game_capture_province",
		"FELICION",
		{
			"money 2000"
		}
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_dlc14_def_malus_early_game_enact_commandment",
		"FELICION",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn six
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping, force_advice
	start_early_game_search_ruins_mission_listener(		
		"wh2.camp.vortex.advice.early_game.treasure_hunting.001",
		nil,
		"wh2_main_vor_shifting_mangrove_coastline_temple_avenue_of_gold",
		6,
		"wh2_dlc14_def_malus_early_game_search_ruins",
		"FELICION",
		{
			"money 500"
		}
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	--start_early_game_rogue_army_mission_listener(
	--	"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
	--	nil,
	--	"wh2_dlc14_def_malus_early_game_rogue_armies",
	--	"FELICION",
	--	"wh2_main_rogue_the_wandering_dead",
	--	{
	--		{v(691, 157), temple_of_skulls_region_str},
	--		{v(672, 139), temple_of_skulls_region_str},
	--		{v(632, 110), "wh2_main_vor_kingdom_of_beasts_serpent_coast"},
	--		{v(651, 96), "wh2_main_vor_shifting_mangrove_coastline_teotiqua"}
	--	},
	--	"wh_main_vmp_cha_banshee,wh_main_vmp_inf_cairn_wraiths,wh_main_vmp_inf_crypt_ghouls,wh_main_vmp_inf_skeleton_warriors_0,wh_main_vmp_inf_skeleton_warriors_1,wh_main_vmp_inf_zombie,wh_main_vmp_inf_zombie,wh_main_vmp_inf_zombie,wh_main_vmp_inf_zombie",
	--	cursed_jungle_region_str,
	--	{
	--		"money 2000"
	--	}
	--);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		"wh2_dlc14.camp.vortex.malus_darkblade.early_game.003",
		nil,
		"wh2_dlc14_def_malus_early_game_eliminate_faction",
		"FELICION",
		"wh2_main_hef_tor_elasor",
		1,
		25,
		{
			"money 2000"
		}
	);
	
	
	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"wh2_dlc14_def_malus_early_game_upgrade_settlement_part_two",
		"FELICION",
		"wh2_main_vor_the_black_flood_hag_graef",
		{
			"wh2_main_def_settlement_major_2",
			"wh2_main_def_settlement_major_2_coast",
			"wh2_main_def_settlement_minor_2",
			"wh2_main_def_settlement_minor_2_coast"
		},
		{
			"wh2_main_def_settlement_major_3",
			"wh2_main_def_settlement_major_3_coast",
			"wh2_main_def_settlement_minor_3",
			"wh2_main_def_settlement_minor_3_coast"
		},
		{
			"money 1000"
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
		"wh2_dlc14_def_malus_early_game_hero_building_mission",
		"FELICION",
		{		
			"wh2_main_def_outpostnorsca_major_2",
			"wh2_main_def_outpostnorsca_major_2_coast",
			"wh2_main_def_outpostnorsca_minor_2",
			"wh2_main_def_outpostnorsca_minor_2_coast",
			"wh2_main_def_settlement_major_2",
			"wh2_main_def_settlement_major_2_coast",
			"wh2_main_def_settlement_minor_2",
			"wh2_main_def_settlement_minor_2_coast",
			"wh2_main_horde_def_settlement_2",
			"wh2_main_special_settlement_naggarond_2",
			"wh2_main_special_settlement_altdorf_def_2",
			"wh2_main_special_settlement_athel_loren_def_2",
			"wh2_main_special_settlement_black_crag_def_2",
			"wh2_main_special_settlement_castle_drakenhof_def_2",
			"wh2_main_special_settlement_couronne_def_2",
			"wh2_main_special_settlement_eight_peaks_def_2",
			"wh2_main_special_settlement_hexoatl_def_2",
			"wh2_main_special_settlement_itza_def_2",
			"wh2_main_special_settlement_karaz_a_karak_def_2",
			"wh2_main_special_settlement_khemri_def_2",
			"wh2_main_special_settlement_kislev_def_2",
			"wh2_main_special_settlement_lahmia_def_2",
			"wh2_main_special_settlement_lothern_def_2",
			"wh2_main_special_settlement_miragliano_def_2"
		},
		1,
		{
			"wh2_main_def_worship_1",
			"wh2_main_def_sorcery_1"
		},
		{
			"money 500"
		}
	);
	
	
	-- hero recruitment mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to recruit a hero
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_recruitment_mission_listener(
		"wh2.camp.vortex.advice.early_game.recruit_hero.001",
		nil,
		"wh2_dlc14_def_malus_early_game_hero_recruitment_mission",
		"FELICION",
		{
			"money 500"
		}
	);
	
	
	-- hero action mission
	-- triggers when the player gains their first hero
	-- issues the supplied advice, and a mission to use a hero action
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_action_mission_listener(
		"wh2.camp.vortex.advice.early_game.hero_actions.001",
		nil,
		"wh2_dlc14_def_malus_early_game_hero_action_mission",
		"FELICION",
		{
			"money 500"
		}
	);
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		"wh2_dlc14.camp.vortex.malus_darkblade.early_game.002",
		nil,
		"wh2_dlc14_def_malus_early_game_research_tech",
		"FELICION",
		{
			"money 500"
		},
		false,
		true,
		2
	);
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc14_def_malus_early_game_raise_army_mission",
		"FELICION",
		{
			"money 500"
		}
	);
	
	-- Possession mission
	-- triggers after How They Play dismissed
	-- mission key, mission issuer, mission rewards
	start_early_game_possession_mission_listener(
		"wh2_dlc14_def_malus_early_game_possession",
		"FELICION",
		{
			"money 500"
		}
	);
	
	-- ritual settlement capture missions
	do
		local ritual_region_key = "wh2_main_vor_the_jungles_of_the_gods_caverns_of_sotek";
		
		local advice_to_show = {
			"wh2.dlc14.camp.vortex.advice.early_game.ritual_settlements.malus.001"
		};
	
		-- build a cutscene
		local cutscene = campaign_cutscene:new(
			"ritual_settlement_capture",
			24
		);
			
		cutscene:set_skippable(
			true,
			function()
				-- show any advice that has yet to be shown
				for i = 1, #advice_to_show do
					cm:show_advice(advice_to_show[i]);
				end;
				advice_to_show = {};
			end
		);
		
		cutscene:action(function() cm:make_region_visible_in_shroud(cm:get_local_faction_name(), ritual_region_key) end, 0);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {395.8, 45.5, 8.6, 0.0, 5.0}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {395.2, 45.7, 8.6, -0.51, 5.0}) end, 9);
		
		cutscene:action(
			function()
				cutscene:wait_for_advisor();
			end, 
			10.5
		);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1); 
			end, 
			11
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {457.1, 21.4, 23.3, 0.0, 19.0}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene, 
			nil, 
			0.5, 
			"wh2_dlc14_def_malus_early_game_capture_ritual_settlement",
			"FELICION",
			ritual_region_key, 
			10,
			{
				"money 2000",
				"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_ritual_settlement_capture_mission_ritual_currency_payload_amount .. ";}"
			}
		);
	end;	
end;