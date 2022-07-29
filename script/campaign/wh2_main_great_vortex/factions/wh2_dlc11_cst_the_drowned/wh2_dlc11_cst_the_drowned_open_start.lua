


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
	

	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	

	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- The brutes to the south are not worthy of a performance but they will join my crew, first I’ll take their lives, then their settlement and finally I’ll take their bodies for my growing army. All will join in adoration of my voice, willingly or not they will join.
		"wh2_dlc11.camp.vortex.CylostaDirefin.early_game.001",
		nil, 
		"wh2_dlc11_cst_cylostra_early_game_capture_settlement",
		"SYMBOLS",
		ziggurat_of_dawn_region_str,
		skeggi_faction_str,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_enemy_settlement_mission_infamy_payload_amount .. ";}"
		},
		true
	);

	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		-- The Northmen have fallen but there is still work to do. I cannot perform for the Phoenix King if he will not grant me an audience; if I foster an empire of loving fans he will have no choice but to recognise me and invite me to his court. Yes, I must grow my empire further.
		"wh2_dlc11.camp.vortex.CylostaDirefin.early_game.003",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_capture_province",
		"SYMBOLS",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_province_mission_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		-- Your armed forces have secured the province, my Lord. Any contesting claim to this territory has been eliminated. Now that your rule is unquestioned, you may consider issuing a commandment to rouse the populace, so that they may better serve your ends.
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_enact_commandment",
		"SYMBOLS",
		{
			"money 500"
		}
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		nil,
		nil,
		"wh2_dlc11_cst_cylostra_early_game_eliminate_faction",
		"SYMBOLS",
		skeggi_faction_str,
		1,
		25,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_eliminate_faction_mission_infamy_payload_amount .. ";}"
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
		"wh2_dlc11_cst_cylostra_early_game_upgrade_settlement_part_two",
		"SYMBOLS",
		grey_rock_point_region_str,
		{
			"wh2_dlc11_vampirecoast_settlement_minor_coast_2"
		},
		{
			"wh2_dlc11_vampirecoast_settlement_minor_coast_3"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_growth_point_mission_infamy_payload_amount .. ";}"
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
		"wh2_dlc11_cst_cylostra_early_game_hero_building_mission",
		"SYMBOLS",
		{	
--may need to add more for other special settlements			
			"wh2_dlc11_special_settlement_galleons_graveyard_3",
			"wh2_main_special_settlement_sartosa_cst_3",
			"wh2_main_special_settlement_the_awakening_cst_3",
			"wh2_dlc11_vampirecoast_settlement_major_coast_3",
			"wh2_dlc11_vampirecoast_settlement_major_3",
			"wh2_dlc11_vampirecoast_settlement_minor_coast_3",
			"wh2_dlc11_vampirecoast_settlement_minor_3",
			"wh2_dlc11_vampirecoast_ship_captains_cabin_3"
		},
		1,
		{
--temp buildings until agent recruitment has been tied to a particular chain
			"wh2_dlc11_vampirecoast_support_monsters_2",
			"wh2_dlc11_vampirecoast_port_2",
			"wh2_dlc11_vampirecoast_military_ranged_3"
		},
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_building_mission_infamy_payload_amount .. ";}"
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
		"wh2_dlc11_cst_cylostra_early_game_hero_recruitment_mission",
		"SYMBOLS",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_recruitment_mission_infamy_payload_amount .. ";}"
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
		"wh2_dlc11_cst_cylostra_early_game_hero_action_mission",
		"SYMBOLS",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_action_mission_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_raise_army_mission",
		"SYMBOLS",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my lord, for there are foreign powers sympathetic to your cause. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_non_aggression_pact", 
		"SYMBOLS",
		"wh2_main_emp_new_world_colonies", 
		7,
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_non_aggression_pact_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- trade-agreement mission
	-- triggers after the non-aggression pact mission is completed, when the standing between the player and the target faction has risen sufficiently to make a trade agreement plausible
	-- supplied min_turn_threshold specifies the minimum number of turns after the non-aggression pact is agreed before this can trigger. max_turn_threshold is the maximum number of turns after the nap is agreed
	-- advice_key, infotext, mission_key, target_faction_key, min_turn_threshold, max_turn_threshold, mission_rewards
	start_early_game_trade_agreement_mission_listener(
		-- The clamour of sycophants has increased since agreeing a pact of non-aggression, my Lord. A trade agreement with your new 'friends' may now be possible. Let your merchants flourish, for industry drives war.
		"wh2.camp.vortex.advice.early_game.trade_agreements.002",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_trade_agreement",
		"SYMBOLS",
		"wh2_main_emp_new_world_colonies",
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_trade_agreement_mission_infamy_payload_amount .. ";}"
		}
	);
	
	-- pirate cove mission
	-- triggers if the player completes capture province mission
	-- issues the supplied advice, and a mission to establish a pirate cove
	-- advice_key, infotext, mission_key, mission_issuer, buildings, mission_rewards 
	start_early_game_cst_pirate_cove_mission_listener(
		-- Not all loot need be fought and died for, there is plenty of treasure to be had with a little cunning and some corrupt connections. Building a pirate cove can allow you to construct buildings under your enemy's watch generating loot based of the relative wealth of the target region; the larger the target the more a pirate can smuggle without the host noticing anything is awry. 
		"wh2_dlc11.camp.vortex.advice.early_game.pirate_cove.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_pirate_cove_mission",
		"SYMBOLS",
		{		
			"wh2_dlc11_foreign_corruption_1",
			"wh2_dlc11_foreign_income_1",
			"wh2_dlc11_foreign_infamy_1",
			"wh2_dlc11_foreign_trade_1"
		},
		{
			"money 500",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_cst_pirate_cove_mission_infamy_payload_amount .. ";}"
		}
	);
		
	-- growth point ship mission
	-- this is a mission for the player to upgrade their LL's main ship building chain 
	-- this triggers once the player receives their first growth point for their LLs army
	-- advice_key, infotext, mission_key, mission_issuer, faction_key, upgrade_building_keys, mission_rewards
	start_early_game_cst_growth_point_ship_mission_listener(
		-- Your Lord's ships will grow as more wrecks are collected and used to upgrade their own ship. This salvaging of wrecks will allow your Lord's to build their ship into a true force to be reckoned with.
		"wh2_dlc11.camp.vortex.advice.early_game.ship_growth.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_ship_building",
		"SYMBOLS",
		the_drowned_faction_str,
		{
			"wh2_dlc11_vampirecoast_ship_captains_cabin_3"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_cst_growth_point_ship_mission_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- Loyalty mission
	-- this is a mission for the player to raise a Lord's army to 8 
	-- issued after the raise army mission is completed
	-- advice_key, info_text, mission_key, mission_issuer, faction_key, mission_rewards
	start_early_game_cst_loyalty_mission_listener(
		-- The loyalty of your suborrdinates is a valuable commodity, many pirates have been felled by mutnious curs. Keeping your forces loyal also comes with benefits, as the more loyal one of your Lords is the better they will perform on your behalf my Lord.
		"wh2_dlc11.camp.vortex.advice.early_game.loyalty.001",
		nil,
		"wh2_dlc11_cst_cylostra_early_game_loyalty_mission",
		"SYMBOLS",
		the_drowned_faction_str,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount " .. early_game_cst_loyalty_mission_infamy_payload_amount .. ";}"
		}
	);
	
	
	-- Treasure Hunting mission
	-- issued after the how-they-play event is dismissed
	-- advice_key, info_text, mission_key
	start_early_game_cst_treasure_hunting_mission_listener(
		-- Admiral, treasure can be found throughout the world. Solve the map's riddle to lead you to untold riches and wealth.
		"wh2_dlc11.camp.advice.cst.treasure_hunts.001",
		nil,
		"wh2_dlc11_cst_treasure_map_starting_treasure_cylostra"
	);
	

	-- Search for the Vengeance mission
	-- issued after the how-they-play event is dismissed
	-- advice_key, info_text, mission_key, target_faction_key
	start_early_game_cst_search_for_the_vengeance_mission_listener(
		-- The wreck of the Vengeance has been found, Admiral, yet not by us it would seem. A corsair fleet has been sighted where the vessel went down. They must not be allowed to salvage her!
		"wh2_dlc11.camp.advice.cst.search_for_the_vengeance.001",
		nil,
		"wh2_dlc11_mission_harpoon",
		"wh2_dlc11_cst_harpoon_the_sunken_land_corsairs",
		"wh2_main_vor_sea_sea_of_serpents"
	);
end;