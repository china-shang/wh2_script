


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
	local enemy_faction_str = "wh2_main_def_the_forgebound";

	-- how they play event message that appears at the start of the open campaign
	start_early_game_how_they_play_listener();
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
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
			enemy_faction_str,
			personality_key,
			3
		);
	end;

	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name, enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- The Elf-things not suspect of-of rats on Naggaroth, ha-ha! No-furs build their things where warpstone lies buried! Take-take no-fur cities! Smash them down! Claim warpstone for me!
		"dlc09.camp.vortex.tretch.early_game.001",
		nil, 
		"wh2_dlc09_skv_tretch_early_game_capture_settlement",
		"GREY_SEER_VULSCREEK",
		"wh2_main_vor_the_clawed_coast_the_monoliths",
		enemy_faction_str,
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
		-- Pointy-eared no-furs will plan attack now Skaven presence is-is revealed. Must not let them regroup! Keep attacking, nyaargh!
		"dlc09.camp.vortex.tretch.early_game.003",
		nil,
		"wh2_dlc09_skv_tretch_early_game_capture_province",
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
		"wh2_dlc09_skv_tretch_early_game_enact_commandment",
		"GREY_SEER_VULSCREEK",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of the supplied turn
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- The remnants of long-abandoned cities may yet yield uncovered treasure. Send armed forces to search such ruins, my Lord, and great riches may be yours.
		"wh2.camp.vortex.advice.early_game.treasure_hunting.001",
		nil,
		"wh2_main_vor_shadow_wood_daldrachs_lair",
		6,
		"wh2_dlc09_skv_tretch_early_game_search_ruins",
		"SNEEK_SCRATCHETT",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_ritual_currency_payload_amount .. ";}"
		},
		{		-- factions to modify the personality of
			{
				["faction_key"] = "wh2_main_def_hag_graef",
				["start_personality_easy"] = "wh2_darkelf_early_noruins_easy",
				["start_personality_normal"] = "wh2_darkelf_early_noruins",
				["start_personality_hard"] = "wh2_darkelf_early_noruins_internally_hostile_aggressive_less_diplomatic_hard",
				["complete_personality_easy"] = "wh2_darkelf_early_easy",
				["complete_personality_normal"] = "wh2_darkelf_early",
				["complete_personality_hard"] = "wh2_darkelf_early_internally_hostile_aggressive_less_diplomatic_hard"
			},
			{
				["faction_key"] = "wh2_main_def_clar_karond",
				["start_personality_easy"] = "wh2_darkelf_early_noruins_easy",
				["start_personality_normal"] = "wh2_darkelf_early_noruins",
				["start_personality_hard"] = "wh2_darkelf_early_noruins_internally_hostile_aggressive_less_diplomatic_hard",
				["complete_personality_easy"] = "wh2_darkelf_early_easy",
				["complete_personality_normal"] = "wh2_darkelf_early",
				["complete_personality_hard"] = "wh2_darkelf_early_internally_hostile_aggressive_less_diplomatic_hard"
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
		"wh2_dlc09_skv_tretch_early_game_rogue_armies",
		"GREY_SEER_VULSCREEK",
		"wh2_main_rogue_worldroot_rangers",
		{
			{v(265, 602), "wh2_main_vor_shadow_wood_circle_of_destruction"},
			{v(300, 577), "wh2_main_vor_the_clawed_coast_the_twisted_glade"},
			{v(220, 568), "wh2_main_vor_shadow_wood_venom_glade"}
		},
		"wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_eternal_guard_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_dryads_0,wh_dlc05_wef_inf_glade_guard_1,wh_dlc05_wef_inf_glade_guard_0,wh_dlc05_wef_cav_glade_riders_0",
		the_great_arena_region_str,
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
		"wh2_dlc09_skv_tretch_early_game_construct_tech_building",
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
		"wh2_dlc09_skv_tretch_early_game_research_tech",
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
		"wh2_dlc09_skv_tretch_early_game_eliminate_faction",
		"SNEEK_SCRATCHETT",
		enemy_faction_str,
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
		"wh2_dlc09_skv_tretch_early_game_upgrade_settlement_part_two",
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
		"wh2_dlc09_skv_tretch_early_game_hero_building_mission",
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
		"wh2_dlc09_skv_tretch_early_game_hero_recruitment_mission",
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
		"wh2_dlc09_skv_tretch_early_game_hero_action_mission",
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
		"wh2_dlc09_skv_tretch_early_game_raise_army_mission",
		"SNEEK_SCRATCHETT",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- ritual settlement capture missions
	do
		local ritual_region_key = "wh2_main_vor_the_black_coast_vauls_anvil";
		
		local advice_to_show = {
			-- Much warpstone may be found at Vaul's Anvil, my Lord, a site of great reverence to the elves. The surface-dwellers yoke the energies of this place to forge weapons of great and terrible power.
			"dlc09.camp.vortex.advice.early_game.ritual_settlements.080",
			-- The time is right to move on the forge, yet be sure to prepare your invasion forces thoroughly - the Elves will fiercely resist a strike against so sacred a site.
			"dlc09.camp.vortex.advice.early_game.ritual_settlements.081"
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {165.3, 418.6, 9.4, 0.0, 4.0}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {166.7, 418.5, 9.6, 0.5, 4.0}) end, 9);
		
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {165.7, 422.3, 27.0, 0.0, 17.0}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene, 
			nil, 
			0.5, 
			"wh2_dlc09_skv_tretch_early_game_capture_ritual_settlement",
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
			-- The Anvil has fallen to you, Lord Tretch. Move at once to secure the warpstone abundant in the local area. Facilities must be constructed to begin extraction.
			"dlc09.camp.vortex.advice.early_game.ritual_buildings.080",
			nil,
			"wh2_dlc09_skv_tretch_early_game_construct_ritual_building",
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
		local enact_ritual_mission_key = "wh2_dlc09_skv_tretch_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "SNEEK_SCRATCHETT";
		local ritual_key = "wh2_main_ritual_vortex_1_skv";
		
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- Elf-things sat on much warpstone, it seems! Get more! Council want warpstone, council get warpstone! Then glory for Tretch!
			"dlc09.camp.vortex.tretch.early_game.004",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_007",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_dlc09_skv_tretch_early_game_earn_ritual_currency",
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
			-- Clan Rictus find warpstone best of all! Ritual is ready now, ha-ha! Go-go!
			"dlc09.camp.vortex.tretch.early_game.005",
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