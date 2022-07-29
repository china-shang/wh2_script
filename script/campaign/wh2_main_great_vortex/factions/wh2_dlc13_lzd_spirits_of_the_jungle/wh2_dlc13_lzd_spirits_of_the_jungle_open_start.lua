


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
		local personality_key = "wh2_skaven_early_internally_hostile_aggressive_easy";
		
		if difficulty_level == 0 or difficulty_level == -1 then
			personality_key = "wh2_skaven_early_internally_hostile_aggressive";								-- normal/hard
		elseif difficulty_level == -2 or difficulty_level == -3 then
			personality_key = "wh2_skaven_early_internally_hostile_aggressive_less_diplomatic_hard";		-- v.hard/legendary
		end;
		
		-- prevents the supplied principal enemy faction from being able to request peace, sets them into the supplied personality, and prevents anyone from arranging a NAP or a trade agreement with the player until a message is received
		-- also prevents anyone declaring war with the player for the specified number of turns from the start of the game
		-- enemy_faction_key, enemy_personality_key, num_turns_before_war
		start_early_game_diplomacy_setup_listener(
			"wh2_dlc12_skv_clan_mange",
			personality_key,
			9
		);
	end;
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- get/cache the cqi of the initial enemy lord that we pan the camera to
	enemy_initial_lord_char_cqi = cm:get_cached_value(
		"enemy_initial_lord_char_cqi",
		function()
			local character = cm:get_closest_general_to_position_from_faction(cm:get_faction("wh2_dlc12_skv_clan_mange"), 234, 52, false);
			if character then
				return character:cqi();
			end;
		end
	);
	
	
	-- prevent specific nearby enemy character from moving too far at start of game, so the player can chase them down
	-- lord_cqi, [list of effect bundles to be applied per-turn]
	start_early_game_character_lockdown_listener(
		enemy_initial_lord_char_cqi, 
		"wh_main_reduced_movement_range_90",
		"wh_main_reduced_movement_range_60",
		"wh_main_reduced_movement_range_30"
	);
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- Find forgotten relics.
		"wh2_dlc13.camp.vortex.nakai.early_game.001",
		nil,
		"wh2_main_vor_northern_great_jungle_quittax",
		6,
		"wh2_dlc13_lzd_nakai_early_game_search_ruins",
		"YUKANNADOOZAT",
		{
			"money 1000"
		},
		{},		-- factions to modify the personality of
		true
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil,
		"wh2_dlc13_lzd_nakai_early_game_rogue_armies",
		"YUKANNADOOZAT",
		"wh2_main_rogue_worldroot_rangers",
		{
			{v(121, 201), "wh2_main_vor_northern_great_jungle_quittax"},
			{v(145, 192), "wh2_main_vor_northern_great_jungle_quittax"},
			{v(136, 232), "wh2_main_vor_northern_great_jungle_quittax"}
		},
		"wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_glade_guard_1,wh_dlc05_wef_inf_glade_guard_0,wh_dlc05_wef_cav_glade_riders_0",
		"wh2_main_vor_northern_great_jungle_quittax",
		{
			"money 1000"
		}
	);
		
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_issuer, mission_rewards, trigger_on_capture_settlement_mission_issued, should_delay_initial_firing, fire_on_turn
	start_early_game_research_tech_mission_listener(
		-- You now have the facilities to begin technological research, my Lord. It only remains for you to choose the direction of development.
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_research_tech",
		"YUKANNADOOZAT",
		{
			"money 1000"
		},
		false,
		true,
		3
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		--The trespassers flee. They are warmbloods - it is to be expected. Finish them!
		"wh2.camp.vortex.advice.early_game.eliminate_faction.003",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_eliminate_faction",
		"YUKANNADOOZAT",
		"wh2_dlc12_skv_clan_mange",
		1,
		25,
		{
			"money 1000"
		}
	);
	
	
	-- growth point horde mission
	-- this is a mission for the player to upgrade their LL's main ship building chain 
	-- this triggers once the player receives their first growth point for their LLs army
	-- advice_key, infotext, mission_key, mission_issuer, faction_key, upgrade_building_keys, mission_rewards
	start_early_game_cst_growth_point_ship_mission_listener(
		-- Your following grows, mighty Lord. Put the new recruits to good use and repair the Old Ones Ziggurrat you control.
		"wh2.camp.vortex.advice.early_game.horde_growth.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_upgrade_settlement_part_two",
		"YUKANNADOOZAT",
		"wh2_dlc13_lzd_spirits_of_the_jungle",
		{
			"wh2_dlc13_horde_lizardmen_ziggurat_3"
		},
		{
			"money 1000"
		}
	);
	
	
	-- hero building mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to construct one of the target buildings
	-- optional turn delay introduces a turn countdown delay between the completion of the building and the issuing of the mission
	-- advice_key, infotext, mission_key, mission_issuer, trigger_building_list, turn_delay, target_building_list, mission_rewards
	start_early_game_hero_building_mission_listener(
		-- The wars to come will be fought using guile as well as brawn. Consider expanding your facilities to permit the recruitment of Heroes, my Lord. Heroes can be hired to support your forces, or to strike against the enemy.
		"wh2.camp.vortex.advice.early_game.hero_buildings.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_hero_building_mission",
		"YUKANNADOOZAT",
		{		
			"wh2_dlc13_horde_lizardmen_ziggurat_3",
			"wh2_dlc13_horde_lizardmen_ziggurat_minor_3"
		},
		1,
		{
			"wh2_dlc13_horde_lizardmen_saurus_veteran_1",
			"wh2_dlc13_horde_lizardmen_skink_chief_1",
			"wh2_dlc13_horde_lizardmen_skink_priest_1",
			"wh2_dlc13_horde_lizardmen_skinks_2",
			"wh2_dlc13_horde_lizardmen_saurus_3",
			"wh2_dlc13_horde_lizardmen_slann_1"
		},
		{
			"money 1000"
		},
		true
	);
	
	
	-- hero recruitment mission
	-- triggers if the player completes one of the supplied trigger buildings
	-- issues the supplied advice, and a mission to recruit a hero
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_recruitment_mission_listener(
		-- Facilities are now in place to recruit a Hero, my Lord. Such operatives may move behind enemy lines and strike independently of your armies.
		"wh2.camp.vortex.advice.early_game.recruit_hero.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_hero_recruitment_mission",
		"YUKANNADOOZAT",
		{
			"money 1000"
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
		"wh2_dlc13_lzd_nakai_early_game_hero_action_mission",
		"YUKANNADOOZAT",
		{
			"money 1000"
		}
	);
	
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_raise_army_mission",
		"YUKANNADOOZAT",
		{
			"money 1000"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my Lord, for there are foreign powers sympathetic to your cause. Relations may be built with them through diplomacy. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc13_lzd_nakai_early_game_non_aggression_pact",
		"YUKANNADOOZAT",
		southern_sentinels_faction_str,
		7,
		{
			"money 1000"
		}
	);

	
	--Nakai Gift Region mission
	--triggered after How-They-Pley dismissed
	--advice_key, infotext, region_key, mission_key, mission_issuer, mission_rewards
	start_early_game_nakai_gift_region_mission_listener(
		-- The Great Plan is under threat, the world has fallen into disarray and it is your duty to fulfill the Old Ones designs. Take regions and gift them to The Defenders of the Great Plan, they will help you restore balance to the world.
		"wh2.camp.vortex.advice.early_game.gift_region.001",
		nil,
		"wh2_main_vor_northern_spine_of_sotek_monument_of_izzatal",
		"wh2_dlc13_lzd_nakai_early_game_gift_region",
		"YUKANNADOOZAT",
		{
			"money 1000"
		}
	);
	
	
end;