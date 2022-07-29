


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
	-- advice_key, infotext, mission_key, mission_issuer, target_id, enemy_faction_name, mission_rewards, start_from_how_they_play_event_dismissed, start_from_books_of_nagash_mission_issued, start_from_turn_two, force_advice
	-- this mission set up uses the books of nagash trigger despite not being tomb kings, this is because Eshin use that trigger too for their Shadowy Dealings mission
	start_early_game_capture_enemy_settlement_mission_listener(
		"wh2_dlc14.camp.vortex.deathmaster_snikch.early_game.001",
		nil, 
		"wh2_dlc14_skv_snikch_early_game_capture_settlement",
		"SNEEK_SCRATCHETT",
		"wh2_main_vor_land_of_the_dervishes_elven_ruins",
		"wh2_main_emp_sudenburg",
		{
			"money 500"
		},
		false,
		true,
		false,
		true
	);
	
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		"wh2.camp.vortex.advice.early_game.provinces.001",
		--"wh2_dlc14.camp.vortex.deathmaster_snikch.early_game.002",
		nil,
		"wh2_dlc14_skv_snikch_early_game_capture_province",
		"SNEEK_SCRATCHETT",
		{
			"money 1000"
		},
		"1"
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		-- Your armed forces have secured the province, my Lord. Any contesting claim to this territory has been eliminated. Now that your rule is unquestioned, you may consider issuing a commandment to rouse the populace, so that they may better serve your ends.
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_dlc14_skv_snikch_early_game_enact_commandment",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- Hmm yes… Warpstone is there - my armour can detect it yes-yes! A great vein of Warpstone waiting to be mined! Must hurry-snatch before other lesser clans stumble on Warpstone and take what is mine-mine!
		"wh2.camp.vortex.advice.early_game.treasure_hunting.001",
		nil,
		"wh2_main_vor_the_great_desert_bel_aliad",
		6,
		"wh2_dlc14_skv_snikch_early_game_search_ruins",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		},
		{}		-- factions to modify the personality of
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army four turns after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil,
		"wh2_dlc14_skv_snikch_early_game_rogue_armies",
		"SNEEK_SCRATCHETT",
		"wh2_main_rogue_vauls_expedition",
		{
			{v(585, 275), "wh2_main_vor_the_great_desert_black_tower_of_arkhan"},
			{v(527, 289), "wh2_main_vor_the_great_desert_bel_aliad"},			
			{v(550, 261), "wh2_main_vor_land_of_the_dervishes_sudenburg"}
		},
		"wh2_main_hef_inf_archers_1,wh2_main_hef_inf_archers_1,wh2_main_hef_inf_swordmasters_of_hoeth_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_cha_mage_life_0",
		"wh2_main_vor_the_great_desert_black_tower_of_arkhan",
		{
			"money 2000"
		}
	);	
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_issuer, mission_rewards, trigger_on_capture_settlement_mission_issued, should_delay_initial_firing, fire_on_turn
	start_early_game_research_tech_mission_listener(
		-- You now have the facilities to begin technological research, my Lord. It only remains for you to choose the direction of development.
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_dlc14_skv_snikch_early_game_research_tech",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		},
		false,
		true,
		2
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- See how the enemy scurries away from your might! Show them no mercy, prince of rats - finish them!
		"wh2_dlc14.camp.vortex.deathmaster_snikch.early_game.002",
		nil,
		"wh2_dlc14_skv_snikch_early_game_eliminate_faction",
		"SNEEK_SCRATCHETT",
		"wh2_main_emp_sudenburg",
		1,
		25,
		{
			"money 2000"
		},
		true
	);
	
	
	-- growth point mission
	-- this is a mission for the player to upgrade their settlement (again)
	-- this triggers once the player receives their first growth point in a region with the supplied building, informs the player about growth points, and tasks them to upgrade their settlement further
	-- advice_key, infotext, mission_key, region_key, required_building_key, upgrade_building_key, mission_rewards
	start_early_game_growth_point_mission_listener(
		-- The population of your province grows, mighty Lord. See that the expansion continues, so that you may further develop your realm.
		"wh2_dlc14.camp.vortex.deathmaster_snikch.early_game.003",
		nil,
		"wh2_dlc14_skv_snikch_early_game_upgrade_settlement_part_two",
		"SNEEK_SCRATCHETT",
		"wh2_main_vor_land_of_the_dervishes_el-kalabad",
		{
			"wh2_main_skv_settlement_major_2",
			"wh2_main_skv_settlement_major_2_coast",
			"wh2_main_skv_settlement_minor_2",
			"wh2_main_skv_settlement_minor_2_coast"
		},
		{
			"wh2_main_skv_settlement_major_3",
			"wh2_main_skv_settlement_major_3_coast",
			"wh2_main_skv_settlement_minor_3",
			"wh2_main_skv_settlement_minor_3_coast"
		},
		{
			"money 1000"
		},
		true
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
		"wh2_dlc14_skv_snikch_early_game_hero_building_mission",
		"SNEEK_SCRATCHETT",
		{		
			"wh2_main_skv_settlement_major_3",
			"wh2_main_skv_settlement_major_3_coast",
			"wh2_main_skv_settlement_minor_3",
			"wh2_main_skv_settlement_minor_3_coast",
			"wh2_main_special_settlement_colony_major_other_3"
		},
		1,
		{
			"wh2_main_skv_plagues_1",
			"wh2_main_skv_assassins_2",
			"wh2_main_skv_engineers_1"
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
		-- Facilities are now in place to recruit a Hero, my Lord. Such operatives may move behind enemy lines and strike independently of your armies.
		"wh2.camp.vortex.advice.early_game.recruit_hero.001",
		nil,
		"wh2_dlc14_skv_snikch_early_game_hero_recruitment_mission",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
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
		"wh2_dlc14_skv_snikch_early_game_hero_action_mission",
		"SNEEK_SCRATCHETT",
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
		"wh2_dlc14_skv_snikch_early_game_raise_army_mission",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);

	-- Shadowy Dealings mission
	-- triggers after How They Play dismissed
	-- mission key, mission issuer, mission rewards
	start_early_game_shadowy_dealings_mission_listener(
		"wh2_dlc14_skv_snikch_early_game_shadowy_dealings",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
end;
