


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
	
	local local_faction = cm:get_local_faction_name();
	-- prevent all factions from being able to declare war on the player
	cm:force_diplomacy("all", "faction:" .. local_faction, "war", false, true, false);
	
	-- establish a countdown to when other factions can declare war
	cm:add_turn_countdown_event(
		local_faction, 
		6, 
		"ScriptEventEGAllowAIToDeclareWar"
	);
	
	-- set the first turn count modifier - this tells early-game scripts that the first-turn turn should not be counted towards missions that trigger on certain turns
	if not cm:get_saved_value("first_turn_count_modifier") then
		cm:set_saved_value("first_turn_count_modifier", 0);
	end;
	
	
	-- get/cache the cqi of the initial enemy lord that we pan the camera to
	enemy_initial_lord_char_cqi = cm:get_cached_value(
		"enemy_initial_lord_char_cqi",
		function()
			local character = cm:get_closest_general_to_position_from_faction(cm:get_faction("wh2_main_emp_sudenburg"), 511, 199, false);
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
	
	
	-- capture enemy settlement mission that triggers on the first turn of the open campaign
	-- advice_key, infotext (nil for default), mission_key, enemy_region_name (OR char cqi), enemy_faction_name, mission_rewards
	start_early_game_capture_enemy_settlement_mission_listener(
		-- The Great Plan is clear, yet the Untamed Ones seek to go against its wisdom. As Master of Skies it is my honour and duty to rectify this mistake and remove these warmbloods.
		"wh2_dlc12.camp.vortex.tiktaqto.early_game.001",
		nil, 
		"wh2_dlc12_lzd_tiktaqto_early_game_capture_settlement",
		"YUKANNADOOZAT",
		enemy_initial_lord_char_cqi,
		"wh2_main_emp_sudenburg",
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
		-- A base of operations is required if our mission to save the Vortex is to succeed.
		"wh2_dlc12.camp.vortex.tiktaqto.early_game.003",
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_capture_province",
		"YUKANNADOOZAT",
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
		"wh2_dlc12_lzd_tiktaqto_early_game_enact_commandment",
		"YUKANNADOOZAT",
		{
			"money 500"
		}
	);
	
	
	-- search ruins listener
	-- triggers at the start of turn two
	-- advice_key, infotext, region_key, trigger_turn, mission_key, mission_issuer, mission_rewards, factions_personalities_mapping
	start_early_game_search_ruins_mission_listener(		
		-- Plaques long forgotten lie hidden here in the Southlands. Our task is to recover them before any warmbloods reach them. A task fit for the preeminent servant of Master Mazdamundi.
		"wh2_dlc12.camp.vortex.tiktaqto.early_game.002",
		nil,
		"wh2_main_vor_western_jungles_statues_of_the_gods",
		3,
		"wh2_dlc12_lzd_tiktaqto_early_game_search_ruins",
		"YUKANNADOOZAT",
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_search_ruins_mission_ritual_currency_payload_amount .. ";}"
		},
		{	-- factions to modify the personality of	
		}		
	);
	
	
	-- rogue armies listener
	-- spawns a rogue army the turn after the player searches ruins
	-- advice_key, infotext, mission_key, rogue_army_faction_name, rogue_army_position_list, rogue_army_unit_list, rogue_army_home_region, mission_rewards
	start_early_game_rogue_army_mission_listener(
		-- A wandering host approaches! Beware of such 'rogue armies', my Lord - they must not be allowed to threaten your realm. Do not tolerate their incursions on your soil!
		"wh2.camp.vortex.advice.early_game.rogue_armies.001", 
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_rogue_armies",
		"YUKANNADOOZAT",
		"wh2_main_rogue_vauls_expedition",
		{
			{v(567, 163), "wh2_main_vor_the_red_rivers_sun-tree_glades"},
			{v(591, 182), "wh2_main_vor_the_red_rivers_sun-tree_glades"},
			{v(547, 188), "wh2_main_vor_the_red_rivers_sun-tree_glades"},
			{v(546, 161), "wh2_main_vor_the_red_rivers_sun-tree_glades"}
		},
		
		"wh2_main_hef_inf_archers_1,wh2_main_hef_inf_archers_1,wh2_main_hef_inf_swordmasters_of_hoeth_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_cha_mage_life_0",
		"wh2_main_vor_the_red_rivers_sun-tree_glades",
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_rogue_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- tech building mission
	-- triggers after the player upgrades their settlement
	-- advice_key, infotext, mission_key, building_key, table of tech building keys, mission_rewards
	start_early_game_tech_building_mission_listener(
		-- Put your Skinks to work on improving your methods of warfare, my Lord. For this task they will need even grander edifices - construct these, and unleash their creativity.
		"wh2.camp.vortex.advice.early_game.tech_buildings.010",
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_construct_tech_building",
		"YUKANNADOOZAT",
		{
			"wh2_main_lzd_saurus_2",
			"wh2_main_lzd_skinks_2",
			"wh2_main_lzd_beasts_1",
			"wh2_main_lzd_scrying_1",
			"wh2_main_lzd_farm_1",
			"wh2_main_lzd_industry_2",
			"wh2_main_lzd_order_2",
			"wh2_main_lzd_energy_1"
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
		"wh2_dlc12_lzd_tiktaqto_early_game_research_tech",
		"YUKANNADOOZAT",
		{
			"money 500"
		}
	);
	
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- The trespassers flee. They are warmbloods - it is to be expected. Finish them!
		"wh2.camp.vortex.advice.early_game.eliminate_faction.003",
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_eliminate_faction",
		"YUKANNADOOZAT",
		"wh2_main_emp_sudenburg",
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
		"wh2_dlc12_lzd_tiktaqto_early_game_upgrade_settlement_part_two",
		"YUKANNADOOZAT",
		"wh2_main_vor_western_jungles_tlaqua",
		{
			"wh2_main_lzd_settlement_major_2"
		},
		{
			"wh2_main_lzd_settlement_major_3"
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
		"wh2_dlc12_lzd_tiktaqto_early_game_hero_building_mission",
		"YUKANNADOOZAT",
		{		
			"wh2_main_lzd_outpostnorsca_major_3",
			"wh2_main_lzd_outpostnorsca_major_3_coast",
			"wh2_main_lzd_outpostnorsca_minor_3",
			"wh2_main_lzd_outpostnorsca_minor_3_coast",
			"wh2_main_lzd_settlement_major_3",
			"wh2_main_lzd_settlement_major_3_coast",
			"wh2_main_lzd_settlement_minor_3",
			"wh2_main_lzd_settlement_minor_3_coast",
			"wh2_main_special_settlement_hexoatl_hexoatl_3",
			"wh2_main_special_settlement_altdorf_lzd_3",
			"wh2_main_special_settlement_athel_loren_lzd_3",
			"wh2_main_special_settlement_black_crag_lzd_3",
			"wh2_main_special_settlement_castle_drakenhof_lzd_3",
			"wh2_main_special_settlement_couronne_lzd_3",
			"wh2_main_special_settlement_eight_peaks_lzd_3",
			"wh2_main_special_settlement_itza_other_lzd_3",
			"wh2_main_special_settlement_karaz_a_karak_lzd_3",
			"wh2_main_special_settlement_khemri_lzd_3",
			"wh2_main_special_settlement_kislev_lzd_3",
			"wh2_main_special_settlement_lahmia_lzd_3",
			"wh2_main_special_settlement_lothern_lzd_3",
			"wh2_main_special_settlement_miragliano_lzd_3",
			"wh2_main_special_settlement_naggarond_lzd_3"
		},
		1,
		{
			"wh2_main_lzd_skinks_2",
			"wh2_main_lzd_saurus_3",
			"wh2_main_lzd_worship_sotek_1",
			"wh2_main_lzd_worship_oldones_1"
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
		"wh2_dlc12_lzd_tiktaqto_early_game_hero_recruitment_mission",
		"YUKANNADOOZAT",
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
		"wh2_dlc12_lzd_tiktaqto_early_game_hero_action_mission",
		"YUKANNADOOZAT",
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
		"wh2_dlc12_lzd_tiktaqto_early_game_raise_army_mission",
		"YUKANNADOOZAT",
		{
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_raise_army_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, my Lord, for there are foreign powers sympathetic to your cause. Relations may be built with them through diplomacy. Agreeing a pact of non-aggression with a foreign leader will do much to build trust between you. Trade relations or a military alliance may follow.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.001",
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_non_aggression_pact",
		"YUKANNADOOZAT",
		"wh2_main_lzd_zlatan",
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
		-- Relations with the rulers of this place have blossomed since agreeing a pact of non-aggression, my Lord. A trade agreement may now be possible. Let your merchants flourish, for industry creates war.
		"wh2.camp.vortex.advice.early_game.trade_agreements.001",
		nil,
		"wh2_dlc12_lzd_tiktaqto_early_game_trade_agreement",
		"YUKANNADOOZAT",
		"wh2_main_lzd_zlatan",
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_trade_agreement_mission_ritual_currency_payload_amount .. ";}"
		}
	);
	
	
	-- ritual settlement capture missions
	do
		local ritual_region_key = "wh2_main_vor_the_red_rivers_golden_tower_of_the_gods";
		
		local advice_to_show = {
			-- In the jungle interior stands a Golden Tower of great power. Many of the plaques that you seek may surely be found there, mighty Lord.
			"wh2.camp.vortex.advice.early_game.ritual_settlements.050"
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {419.2, 97.6, 8.6, -0.95, 5.0}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {418.6, 100.7, 11.7, -0.39, 6.0}) end, 9);
		
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
		
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {438.3, 104.0, 23.6, 0.0, 19.0}) end, 16);
		
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			advice_to_show[1],
			cutscene,
			nil,
			0.5,
			"wh2_dlc12_lzd_tiktaqto_early_game_capture_ritual_settlement",
			"YUKANNADOOZAT",
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
			-- The Golden Tower is secure, mighty Lord. Its misbegotten defenders have fled into the continent's interior. The search for plaques may begin once suitable facilities are constructed. Make haste, for the Vortex diminishes with the passing of time.
			"wh2.camp.vortex.advice.early_game.ritual_buildings.050", 
			nil,
			"wh2_dlc12_lzd_tiktaqto_early_game_construct_ritual_building",
			"YUKANNADOOZAT",
			ritual_region_key,
			"wh2_main_ritual_lzd_1",
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
		local enact_ritual_mission_key = "wh2_dlc12_lzd_tiktaqto_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "YUKANNADOOZAT";
		local ritual_key = "wh2_main_ritual_vortex_1_lzd";
	
	
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- Master Mazdamundi requires plaques to complete his ritual; as Master of Skies it shall be my honour to provide our most wise leader with these artefacts. 
			"wh2_dlc12.camp.vortex.tiktaqto.early_game.004",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_006",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_dlc12_lzd_tiktaqto_early_game_earn_ritual_currency",
			"YUKANNADOOZAT",
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
			-- The ritual is prepared, our revered master commands us to participate.
			"wh2_dlc12.camp.vortex.tiktaqto.early_game.005",
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