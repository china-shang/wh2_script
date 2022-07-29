


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
		-- Malekith has commanded all loyal subjects to deliver the Vortex to him, and I shall be the one to gift him the power he desires. I, Lokhir Fellheart, am not content with my current renown; the completion of this task will earn me the respect and admiration of all – even the Witch King himself.
		"wh2_dlc11.camp.vortex.lokhirfellheart.early_game.001",
		nil, 
		"wh2_dlc11_def_lokhir_early_game_capture_settlement",
		"FELICION",
		the_southern_sentinels_region_str,
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
		-- The Lizardmen impede my search for Scrolls, and in doing so, delay my service to the Witch King. Malekith does not tolerate failure and I shall not fail my task, if I am to claim his favour I must slay these Cold Blooded beasts.
		"wh2_dlc11.camp.vortex.lokhirfellheart.early_game.003",
		nil,
		"wh2_dlc11_def_lokhir_early_game_capture_province",
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
		"wh2_dlc11_def_lokhir_early_game_enact_commandment",
		"FELICION",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn six
	-- advice_key, infotext, region_key, mission_key, mission_rewards
	start_early_game_search_ruins_mission_listener(		
		-- The Witch King’s sorceress Felicion requires Scrolls of Hekarti for her rituals; though I find myself distrustful of this woman I shall do as Malekith has commanded and aid her in this search. These lands are sure to be filled with these artefacts, one just needs a keen eye and a taste for treasure. 
		"wh2_dlc11.camp.vortex.lokhirfellheart.early_game.002",
		nil,
		xlansec_region_str,
		6,
		"wh2_dlc11_def_lokhir_early_game_search_ruins",
		"FELICION",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_ritual_currency_payload_amount .. ";}"
		},
		{		-- factions to modify the personality of
			{
				["faction_key"] = "wh2_main_lzd_sentinels_of_xeti",
				["start_personality_easy"] = "wh2_lizardmen_early_noruins_easy",
				["start_personality_normal"] = "wh2_lizardmen_early_noruins_easy",
				["start_personality_hard"] = "wh2_lizardmen_early_noruins_hard",
				["complete_personality_easy"] = "wh2_lizardmen_early_easy",
				["complete_personality_normal"] = "wh2_lizardmen_early",
				["complete_personality_hard"] = "wh2_lizardmen_early_internally_hostile_aggressive_less_diplomatic_hard"
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
		"wh2_dlc11_def_lokhir_early_game_rogue_armies",
		"FELICION",
		"wh2_main_rogue_mangy_houndz",
		{
			{v(268, 50), xlansec_region_str},
			{v(267, 61), xlansec_region_str},
			{v(316, 73), xlansec_region_str}
		},
		"wh_main_grn_cav_goblin_wolf_chariot,wh_main_grn_cav_goblin_wolf_riders_0,wh_main_grn_cav_goblin_wolf_riders_0,wh_main_grn_inf_goblin_spearmen,wh_main_grn_inf_goblin_spearmen,wh_main_grn_inf_goblin_archers,wh_main_grn_inf_goblin_archers", 
		xlansec_region_str,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_rogue_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- The enemy retreats. How typical of the weaklings. Not that I need to tell a Druchii this, but show them no mercy – finish them!
		"wh2.camp.vortex.advice.early_game.eliminate_faction.002",
		nil,
		"wh2_dlc11_def_lokhir_early_game_eliminate_faction",
		"FELICION",
		"wh2_main_lzd_southern_sentinels",
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
		"wh2_dlc11_def_lokhir_early_game_upgrade_settlement_part_two",
		"FELICION",
		chupayotl_region_str,
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
		"wh2_dlc11_def_lokhir_early_game_hero_building_mission",
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
		"wh2_dlc11_def_lokhir_early_game_hero_recruitment_mission",
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
		"wh2_dlc11_def_lokhir_early_game_hero_action_mission",
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
		"wh2_dlc11_def_lokhir_early_game_raise_army_mission",
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
		"wh2_dlc11_def_lokhir_early_game_non_aggression_pact", 
		"FELICION",
		"wh2_dlc09_tmb_lybaras", 
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
		"wh2_dlc11_def_lokhir_early_game_trade_agreement",
		"FELICION",
		"wh2_dlc09_tmb_lybaras",
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
			-- Scrolls of great power may be found within the deepest vaults and darkest ruins, Krakenlord. The Altar of the Horned Rat is known to house such treasures...
			"wh2.camp.vortex.advice.early_game.ritual_settlements_lokhir.0110",
			-- The altar is but a verminous nest! The Skaven corrupt this place of power – rid them from these ruins and secure the scrolls for your own cause.
			"wh2.camp.vortex.advice.early_game.ritual_settlements_lokhir.0111"
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
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {206.8, 81.0, 26.9, 0.00, 16.1}) end, 0);

		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);	
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {177.2, 133.8, 19.0, 0.0, 9.74}) end, 9);
		
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
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {182.4, 129.8, 9.4, 2.27, 4.18}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene, 
			nil, 
			0.5, 
			"wh2_dlc11_def_lokhir_early_game_capture_ritual_settlement", 
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
			-- The Altar of the Horned Rat has been cleansed, Krakenlord. Construct facilities at once to enable your search for the scrolls you seek. I sense that the Vortex dims further...
			"wh2_dlc10.camp.vortex.early_game.ritual_buildings_lokhir.0110", 
			nil,
			"wh2_dlc11_def_lokhir_early_game_construct_ritual_building", 
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
		local enact_ritual_mission_key = "wh2_dlc11_def_lokhir_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "FELICION";
		local ritual_key = "wh2_main_ritual_vortex_1_def";
	
	
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- The sorceress informs me she is nearly ready to unleash her first ritual against the Vortex of the Asur; but she is not alone in trying to influence the magic maelstrom. We must hurry, I will not fall second to some foreign cretin. More Scrolls are needed to dominate the Vortex and we shall find them!
			"wh2_dlc11.camp.vortex.LokhirFellheart.early_game.004",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_005",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_dlc11_def_lokhir_early_game_earn_ritual_currency",
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
			-- We have enough Scrolls to begin the first ritual, inform Felicion to cast her spell this instant! We must also continue the hunt for more Scrolls, this is only the first step in the race and I will not claim the first hurdle only to fall short of my goal.
			"wh2_dlc11.camp.vortex.lokhirfellheart.early_game.005",
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