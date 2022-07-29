


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
		-- Me want see-see how nasty Elf-things work. Cut open, take best bit-bits, make many-many new beasts! Take-hold city-place, have big supply of nasty Elf-thing parts, yes?
		"wh2_dlc16.camp.vortex.throt.early_game.001",
		nil, 
		"wh2_dlc16_skv_throt_early_game_capture_settlement",
		"SNEEK_SCRATCHETT",
		"wh2_main_vor_the_chill_road_ashrak",
		"wh2_main_def_ghrond",
		{
			"money 2000"
		},
		true,
		nil,
		nil,
		true
	);
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		-- Must be ready-ready to take-steal Elf queen-thing. Not enough Clanrats! Not enough Rat-Ogres! Moulder must rule whole cold place, quick-fast, make big clan-pack here!
		"wh2_dlc16.camp.vortex.throt.early_game.002",
		nil,
		"wh2_dlc16_skv_throt_early_game_capture_province",
		"SNEEK_SCRATCHETT",
		{
			"money 1000"
		},
		nil,
		true
	);
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		-- Your armed forces have secured the province, my Lord. Any contesting claim to this territory has been eliminated. Now that your rule is unquestioned, you may consider issuing a commandment to rouse the populace, so that they may better serve your ends.
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_dlc16_skv_throt_early_game_enact_commandment",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
	
	-- tech building mission
	-- triggers after the player upgrades their settlement
	-- advice_key, infotext, mission_key, building_key, table of tech building keys, mission_rewards
	start_early_game_tech_building_mission_listener(
		-- There is no end to the diabolical invention of your kind, my Lord. Build your most devious minds a place of work, and they may put their terrible creativity to work.
		"wh2.camp.vortex.advice.early_game.tech_buildings.020",
		nil,
		"wh2_dlc16_skv_throt_early_game_construct_tech_building",
		"SNEEK_SCRATCHETT",
		{
			"wh2_main_skv_salvage_1",
			"wh2_main_skv_farm_1",
			"wh2_main_skv_order_1"
		},
		{
			"money 500"
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
		"wh2_dlc16_skv_throt_early_game_research_tech",
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
		"wh2.camp.vortex.advice.early_game.eliminate_faction.004",
		nil,
		"wh2_dlc16_skv_throt_early_game_eliminate_faction",
		"SNEEK_SCRATCHETT",
		"wh2_main_def_ghrond",
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
		-- The population of your province grows, mighty Lord. See that the expansion continues, so that you may further develop your realm.
		"wh2.camp.vortex.advice.early_game.growth.001",
		nil,
		"wh2_dlc16_skv_throt_early_game_upgrade_settlement_part_two",
		"SNEEK_SCRATCHETT",
		"wh2_main_vor_the_chill_road_atorak",
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
		"wh2_dlc16_skv_throt_early_game_hero_action_mission",
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
		"wh2_dlc16_skv_throt_early_game_raise_army_mission",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- Your kind are known for its backstabbing ways, mighty Lord. Yet there remain some hapless fools abroad that will be lured by your honeyed chitterings. Agree a pact of non-aggression, and begin sharpening your knife for when the time comes to break it!
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.003",
		nil,
		"wh2_dlc16_skv_throt_early_game_non_aggression_pact",
		"SNEEK_SCRATCHETT",
		"wh2_main_def_har_ganeth",
		5,
		{
			"money 1000"
		}
	);
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		-- The pretence of amity is working, verminous Lord. Your new 'friends' may be willing to open trade negotiations. Consider making an agreement, and allowing your merchants to flourish before your sudden but inevitable betrayal.
		"wh2.camp.vortex.advice.early_game.trade_agreements.003",
		nil,
		"wh2_dlc16_skv_throt_early_game_trade_agreement",
		"SNEEK_SCRATCHETT",
		"wh2_main_def_har_ganeth",
		3,
		10,
		{
			"money 2000"
		}
	);
	
end;
