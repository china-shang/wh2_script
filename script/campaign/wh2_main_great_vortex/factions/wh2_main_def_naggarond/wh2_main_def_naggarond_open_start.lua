


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
			clan_septik_faction_str,
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
	start_early_game_character_lockdown_listener(
		enemy_secondary_lord_char_cqi, 
		"wh_main_reduced_movement_range_90",
		"wh_main_reduced_movement_range_60",
		"wh_main_reduced_movement_range_30"
	);
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name (OR char cqi), enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- The under-vermin concentrate their movements around sites of magic, looting artefacts of great power. Skaven are pitiful cowards; they would not seek war with me without good reason. We must counterattack, and discern their motives!
		"wh2.camp.vortex.malekith.early_game.001",
		{
			1,
			"wh2.camp.advice.skaven_underworld.info_001",
			"wh2.camp.advice.skaven_underworld.info_002",
			"wh2.camp.advice.skaven_underworld.info_003"
		}, 
		"wh2_main_def_malekith_early_game_capture_settlement",
		"FELICION",
		enemy_secondary_lord_char_cqi,
		clan_septik_faction_str,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_capture_enemy_settlement_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- gift units listener - gifts units to player that's played through the intro first turn, as they come into the open campaign
	-- this only needs to be set up for lords that have a first-turn intro!
	-- char_cqi, message_title, message_primary_detail, message_secondary_detail, message_picture, <list of units>
	start_early_game_gifted_units_listener(
		player_legendary_lord_char_cqi, 
		"event_feed_strings_text_wh2_scripted_event_gifted_units_naggarond_title", 
		"", 
		"event_feed_strings_text_wh2_scripted_event_gifted_units_naggarond_secondary_detail", 
		871, 
		"wh2_main_def_inf_black_guard_0",
		"wh2_main_def_art_reaper_bolt_thrower"
	);
	
	
	-- capture province listener - triggers on completion of the capture enemy settlement mission (see above), or when the player 
	-- captures a settlement not in their starting province
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_capture_province_mission_listener(
		-- The Druchii seek to hold our cities while they pick them clean of arcane relics and scrolls. The puppets of the Witch King must be driven out, and the treasures they have taken reclaimed before they are put to evil use.
		"wh2.camp.vortex.malekith.early_game.003",
		nil,
		"wh2_main_def_malekith_early_game_capture_province",
		"FELICION",
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
		"wh2_main_def_malekith_early_game_enact_commandment",
		"FELICION",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- Felicion arranges a ritual, yet the power of many scrolls are required to undertake it. My scryers tell me that many such artefacts remain hidden within sites of great antiquity. We must reach them before the Skaven!
		"wh2.camp.vortex.malekith.early_game.002",
		nil,
		the_great_arena_region_str,
		6,
		"wh2_main_def_malekith_early_game_search_ruins",
		"FELICION",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_ritual_currency_payload_amount .. ";}"
		},
		{		-- factions to modify the personality of
			{
				["faction_key"] = "wh2_main_def_ghrond",
				["start_personality_easy"] = "wh2_passive_noruins_easy",
				["start_personality_normal"] = "wh2_passive_noruins",
				["start_personality_hard"] = "wh2_passive_noruins_hard",
				["complete_personality_easy"] = "wh2_passive_easy",
				["complete_personality_normal"] = "wh2_passive",
				["complete_personality_hard"] = "wh2_passive_hard"
			},
			{
				["faction_key"] = "wh2_main_def_har_ganeth",
				["start_personality_easy"] = "wh2_darkelf_early_noruins_easy",
				["start_personality_normal"] = "wh2_darkelf_early_noruins",
				["start_personality_hard"] = "wh2_darkelf_early_noruins_internally_hostile_aggressive_less_diplomatic_hard",
				["complete_personality_easy"] = "wh2_darkelf_early_easy",
				["complete_personality_normal"] = "wh2_darkelf_early",
				["complete_personality_hard"] = "wh2_darkelf_early_internally_hostile_aggressive_less_diplomatic_hard"
			},
			{
				["faction_key"] = "wh2_main_def_hag_graef",
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
		"wh2_main_def_malekith_early_game_rogue_armies",
		"FELICION",
		"wh2_main_rogue_mangy_houndz",
		{
			{v(194, 622), naggarond_region_str},
			{v(207, 632), naggarond_region_str},
			{v(208, 654), naggarond_region_str}
		},
		"wh_main_grn_cav_goblin_wolf_chariot,wh_main_grn_cav_goblin_wolf_riders_0,wh_main_grn_cav_goblin_wolf_riders_0,wh_main_grn_inf_goblin_spearmen,wh_main_grn_inf_goblin_spearmen,wh_main_grn_inf_goblin_archers,wh_main_grn_inf_goblin_archers",
		altar_of_ultimate_darkness_region_str,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_rogue_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- upgrade settlement mission
	-- triggers after the first attack
	-- mission_key, building_key, province_key, mission_rewards
	start_early_game_upgrade_settlement_mission_listener(
		"wh2_main_def_malekith_early_game_upgrade_settlement",
		"FELICION",
		"wh2_main_special_settlement_naggarond_2",
		naggarond_region_str,
		{
			"money 500"
		}
	);
	
	
	-- public order mission
	-- triggers if the player is suffering public order problems in their principal settlement (primary lords only)
	-- advice_key, infotext, mission_key, region_key, mission_rewards
	start_early_game_public_order_mission_listener(
		-- Traitors within the Black Court make trouble in your absence, my King. Take steps to re-assert absolute control over your city. Any dissent must be crushed!
		"wh2.camp.vortex.advice.early_game.public_order.010",
		nil,
		"wh2_main_def_malekith_early_game_public_order",
		"FELICION",
		naggarond_region_str,
		{
			"money 1000"
		}
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- The enemy retreats. How typical of the weaklings. Not that I need to tell a Druchii this, but show them no mercy – finish them!
		"wh2.camp.vortex.advice.early_game.eliminate_faction.002",
		nil,
		"wh2_main_def_malekith_early_game_eliminate_faction",
		"FELICION",
		clan_septik_faction_str,
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
		"wh2_main_def_malekith_early_game_upgrade_settlement_part_two",
		"FELICION",
		naggarond_region_str,
		"wh2_main_special_settlement_naggarond_2",
		"wh2_main_special_settlement_naggarond_3",
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
		"wh2_main_def_malekith_early_game_hero_building_mission",
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
		"wh2_main_def_malekith_early_game_hero_recruitment_mission",
		"FELICION",
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
		"wh2_main_def_malekith_early_game_hero_action_mission",
		"FELICION",
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
		"wh2_main_def_malekith_early_game_raise_army_mission",
		"FELICION",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, for there are foreign powers who may wish to curry favour with the Black Court. Agreeing a pact of non-aggression will leave you free to focus your furious wrath upon those who dare cross the Witch King.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.002",
		nil,
		"wh2_main_def_malekith_early_game_non_aggression_pact",
		"FELICION",
		"wh2_main_def_hag_graef",
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
		-- The clamour of sycophants has increased since agreeing a pact of non-aggression, my Lord. A trade agreement with your new 'friends' may now be possible. Let your merchants flourish, for industry drives war.
		"wh2.camp.vortex.advice.early_game.trade_agreements.002",
		nil,
		"wh2_main_def_malekith_early_game_trade_agreement",
		"FELICION",
		"wh2_main_def_hag_graef",
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_trade_agreement_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- ritual settlement capture missions
	do
		local ritual_region_key = "wh2_main_vor_the_chill_road_ghrond";
		
		local advice_to_show = {
			-- Atop the Tower of Prophecy in Ghrond, the Sorceresses of the Dark Convent commune with the malign powers of Chaos. Such energies could be directed towards control of the Vortex, dark Lord.
			"wh2.camp.vortex.advice.early_game.ritual_settlements.020",
			-- An attack on Ghrond should not be undertaken lightly, but is surely necessary to secure its power for your cause.
			"wh2.camp.vortex.advice.early_game.ritual_settlements.021"
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {163.0, 517.2, 8.6, -0.07, 5.0}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {164.2, 516.9, 8.6, 0.28, 5.0}) end, 9);
		
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {154.7, 503.3, 22.1, 0.11, 17.0}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene,
			nil,
			0.5, 
			"wh2_main_def_malekith_early_game_capture_ritual_settlement",
			"FELICION",
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
			-- Ghrond has fallen, my Lord - the depraved followers of the Hag Sorceress now bend their knee to you. Nevertheless, be wary of a counter-attack. Be sure to erect a shrine as soon as can be, in order to gain the scrolls you seek.
			"wh2.camp.vortex.advice.early_game.ritual_buildings.020", 
			nil,
			"wh2_main_def_malekith_early_game_construct_ritual_building",
			"FELICION",
			ritual_region_key, 
			"wh2_main_ritual_def_1",
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
		local enact_ritual_mission_key = "wh2_main_def_malekith_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "FELICION";
		local ritual_key = "wh2_main_ritual_vortex_1_def";
	
	
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- It is clear that the Skaven intend some twisted sorcery to exploit the weakened Vortex. They must not interrupt my plans: the scrolls we have found so far are not yet sufficient for Felicion to begin the ritual. More must be found.
			"wh2.camp.vortex.malekith.early_game.004",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_005",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_main_def_malekith_early_game_earn_ritual_currency",
			"FELICION",
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
			-- We have all the scrolls we need to commence the ritual. Let us not delay, for Felicion stands ready...
			"wh2.camp.vortex.malekith.early_game.005",
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
