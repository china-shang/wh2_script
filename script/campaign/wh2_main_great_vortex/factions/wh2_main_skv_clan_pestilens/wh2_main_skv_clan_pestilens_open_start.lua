


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
			personality_key = "wh2_lizardmen_early_internally_hostile_aggressive";								-- normal/hard
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
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- Reptile-things should not be here! Why have they resettled old-festering ruins? What are they up to, mmm? Attack soon - claim this place for Clan Pestilens!
		"wh2.camp.vortex.skrolk.early_game.001",
		nil, 
		"wh2_main_skv_skrolk_early_game_capture_settlement",
		"SNEEK_SCRATCHETT",
		subatuun_region_str,
		southern_sentinels_faction_str,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_enemy_settlement_mission_ritual_currency_payload_amount .. ";}"
		},
		true
	);
	
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		-- Reptile prisoners say the Lizards retake old jungles, on the lookout for ancient artefacts, yes-yes. Plan a ritual they do, same as Skaven, ha-ha! Sotek’s things must not succeed, a plague be upon them!
		"wh2.camp.vortex.skrolk.early_game.003",
		nil,
		"wh2_main_skv_skrolk_early_game_capture_province",
		"SNEEK_SCRATCHETT",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_province_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- enact commandment listener - triggers when the player captures a province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_enact_commandment_mission_listener(
		-- Your armed forces have secured the province, my Lord. Any contesting claim to this territory has been eliminated. Now that your rule is unquestioned, you may consider issuing a commandment to rouse the populace, so that they may better serve your ends.
		"wh2.camp.vortex.advice.early_game.commandments.001",
		nil,
		"wh2_main_skv_skrolk_early_game_enact_commandment",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- Warpstone found in old ruins, reptiles not get there yet-yet! Search ancient places, my brood - find Warpstone, claim it for Pestilens!
		"wh2.camp.vortex.skrolk.early_game.002",
		nil,
		the_sentinel_of_time_region_str,
		6,
		"wh2_main_skv_skrolk_early_game_search_ruins",
		"SNEEK_SCRATCHETT",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_ritual_currency_payload_amount .. ";}"
		},
		{		-- factions to modify the personality of
			{
				["faction_key"] = southern_sentinels_faction_str,
				["start_personality_easy"] = "wh2_lizardmen_early_noruins_easy",
				["start_personality_normal"] = "wh2_lizardmen_noruins_early",
				["start_personality_hard"] = "wh2_lizardmen_early_noruins_hard",
				["complete_personality_easy"] = "wh2_lizardmen_early_easy",
				["complete_personality_normal"] = "wh2_lizardmen_early",
				["complete_personality_hard"] = "wh2_lizardmen_early_hard"
			},
			{
				["faction_key"] = "wh2_main_skv_clan_spittel",
				["start_personality_easy"] = "wh2_passive_noruins_cowardly_easy",
				["start_personality_normal"] = "wh2_passive_noruins_cowardly",
				["start_personality_hard"] = "wh2_passive_noruins_cowardly_hard",
				["complete_personality_easy"] = "wh2_passive_cowardly_easy",
				["complete_personality_normal"] = "wh2_passive_cowardly",
				["complete_personality_hard"] = "wh2_passive_cowardly_hard"
			}
		}
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil,
		"wh2_main_skv_skrolk_early_game_rogue_armies",
		"SNEEK_SCRATCHETT",
		"wh2_main_rogue_worldroot_rangers",
		{
			{v(241, 129), marks_of_the_old_ones_region_str},
			{v(223, 87), oyxl_region_str},
			{v(209, 93), oyxl_region_str},
			{v(248, 120), oyxl_region_str}
		},
		"wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_glade_guard_1,wh_dlc05_wef_inf_glade_guard_0,wh_dlc05_wef_cav_glade_riders_0",
		the_sentinel_of_time_region_str,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_rogue_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- tech building mission
	-- triggers after the player upgrades their settlement
	-- advice_key, infotext, mission_key, building_key, table of tech building keys, mission_rewards
	start_early_game_tech_building_mission_listener(
		-- There is no end to the diabolical invention of your kind, my Lord. Build your most devious minds a place of work, and they may put their terrible creativity to work.
		"wh2.camp.vortex.advice.early_game.tech_buildings.020",
		nil,
		"wh2_main_skv_skrolk_early_game_construct_tech_building",
		"GREY_SEER_VULSCREEK",
		{
			"wh2_main_skv_assassins_2",
			"wh2_main_skv_order_2"
		},
		{
			"money 500"
		},
		false,
		{
			"wh2_main_skv_settlement_major_3",
			"wh2_main_skv_settlement_major_3_coast",
			"wh2_main_skv_settlement_minor_3",
			"wh2_main_skv_settlement_minor_3_coast"
		}
	);
	
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		-- You now have the facilities to begin technological research, my Lord. It only remains for you to choose the direction of development.
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_main_skv_skrolk_early_game_research_tech",
		"SNEEK_SCRATCHETT",
		{
			"money 500"
		}
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- See how the enemy scurries away from your might! Show them no mercy, prince of rats - finish them!
		"wh2.camp.vortex.advice.early_game.eliminate_faction.004",
		nil,
		"wh2_main_skv_skrolk_early_game_eliminate_faction",
		"GREY_SEER_VULSCREEK",
		southern_sentinels_faction_str,
		1,
		25,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_eliminate_faction_mission_ritual_currency_payload_amount .. ";}"
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
		"wh2_main_skv_skrolk_early_game_upgrade_settlement_part_two",
		"SNEEK_SCRATCHETT",
		oyxl_region_str,
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
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_growth_point_mission_ritual_currency_payload_amount .. ";}"
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
		"wh2_main_skv_skrolk_early_game_hero_building_mission",
		"SNEEK_SCRATCHETT",
		{		
			"wh2_main_skv_settlement_major_3",
			"wh2_main_skv_settlement_major_3_coast",
			"wh2_main_skv_settlement_minor_3",
			"wh2_main_skv_settlement_minor_3_coast"
		},
		1,
		{
			"wh2_main_skv_plagues_1",
			"wh2_main_skv_assassins_2",
			"wh2_main_skv_engineers_1"
		},
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_building_mission_ritual_currency_payload_amount .. ";}"
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
		"wh2_main_skv_skrolk_early_game_hero_recruitment_mission",
		"SNEEK_SCRATCHETT",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_recruitment_mission_ritual_currency_payload_amount .. ";}"
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
		"wh2_main_skv_skrolk_early_game_hero_action_mission",
		"SNEEK_SCRATCHETT",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_hero_action_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_main_skv_skrolk_early_game_raise_army_mission",
		"GREY_SEER_VULSCREEK",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- Your kind are known for its backstabbing ways, mighty Lord. Yet there remain some hapless fools abroad that will be lured by your honeyed chitterings. Agree a pact of non-aggression, and begin sharpening your knife for when the time comes to break it!
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.003",
		nil,
		"wh2_main_skv_skrolk_early_game_non_aggression_pact",
		"GREY_SEER_VULSCREEK",
		"wh2_dlc11_cst_vampire_coast", 
		7,
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_non_aggression_pact_mission_ritual_currency_payload_amount .. ";}"
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
		"wh2_main_skv_skrolk_early_game_trade_agreement",
		"SNEEK_SCRATCHETT",
		"wh2_dlc11_cst_vampire_coast",
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_trade_agreement_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- ritual settlement capture missions
	do
		local ritual_region_key = "wh2_main_vor_headhunters_jungle_altar_of_the_horned_rat";
		
		local advice_to_show = {
			-- The Altar of the Horned Rat conceals many dark secrets, dark Lord. Yet its latent power is exploited by a rival clan for their own ends. Much warpstone they are said to have found there.
			"wh2.camp.vortex.advice.early_game.ritual_settlements.070",
			-- Seizing the Altar would no doubt lead to war amongst your own kind, yet the warpstone must be yours. Prepare for an attack!
			"wh2.camp.vortex.advice.early_game.ritual_settlements.071"
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {179.7, 132.2, 8.6, -0.56, 5.0}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {179.5, 131.7, 8.6, -1.07, 5.0}) end, 9);
		
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {157.9, 92.1, 24.3, 0.04, 20.0}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene, 
			nil, 
			0.5, 
			"wh2_main_skv_skrolk_early_game_capture_ritual_settlement",
			"GREY_SEER_VULSCREEK",
			ritual_region_key, 
			12,
			{
				"money 2000",
				"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_ritual_settlement_capture_mission_ritual_currency_payload_amount .. ";}"
			}
		);
		
		
		-- ritual settlement building mission
		-- issues a mission to build a ritual building once the ritual settlement is captured
		-- advice_key, infotext, mission_key, region_key, building_key, mission_rewards
		start_early_game_ritual_building_mission_listener(
			-- The Altar has fallen to you, Lord Skrolk. Those of your kin that stood against you have fled into their burrows. Move at once to put facilities in place to begin warpstone collection, for the Vortex is weakening all the time.
			"wh2.camp.vortex.advice.early_game.ritual_buildings.070", 
			nil,
			"wh2_main_skv_skrolk_early_game_construct_ritual_building",
			"SNEEK_SCRATCHETT",
			ritual_region_key, 
			"wh2_main_ritual_skv_1",
			{
				"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_ritual_building_mission_ritual_currency_payload_amount .. ";}"
			}
		);
		
		
		-- ritual building limiter
		-- prevents other factions from constructing a ritual settlement building until the player captures the target ritual settlement
		start_early_game_ritual_building_limiter_listener(
			nil, 		-- all non-primary factions
			{
				"wh2_main_ritual_hef_1",
				"wh2_main_ritual_def_1",
				"wh2_main_ritual_lzd_1",
				"wh2_main_ritual_skv_1"
			}
		)
	end;
	
	
	
	
	do
		local ritual_trigger_currency_threshold = 350;
		local enact_ritual_mission_key = "wh2_main_skv_skrolk_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "GREY_SEER_VULSCREEK";
		local ritual_key = "wh2_main_ritual_vortex_1_skv";
		
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- Much Warpstone found, but more is-is needed. Lizards race towards ritual of their own, Skrolk must get there first!
			"wh2.camp.vortex.skrolk.early_game.004",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_007",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_main_skv_skrolk_early_game_earn_ritual_currency",
			"GREY_SEER_VULSCREEK",
			ritual_trigger_currency_threshold,
			enact_ritual_mission_key,
			enact_ritual_mission_issuer,
			ritual_key,
			{
				"money 2000"
			}
		);
		
		
		
		-- ritual mission
		-- mission given to the player to enact their first major ritual
		-- triggers when the player starts a turn with the supplied amount of ritual currency, or if the currency mission is completed
		-- if the currency mission is completed, the supplied mission (to actually enact the ritual) is issued, otherwise just the advice is given (for flavour)
		-- advice_key, infotext, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_mission_listener(
			-- Skrolk has succeeded, my brood, the Warpstone is secure! Now-now, the ritual may begin!
			"wh2.camp.vortex.skrolk.early_game.005",
			nil,
			ritual_trigger_currency_threshold,
			enact_ritual_mission_key,
			enact_ritual_mission_issuer,
			ritual_key,
			{
				"money 2000"
			}
		);
	end;
end;
