


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
				local character = cm:get_closest_general_to_position_from_faction("wh_main_nor_skaeling", 697, 637, false);
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
		--Malekith has ordered the acquisition of the Scrolls of Hekarti. If I am to further ascend the ranks of Naggaroth, I must deliver on his request. The local belligerents will have to be dealt with first, whether by death or enslavement. Time to feed.
		"wh2_twa03.camp.vortex.Rakarth.early_game.001",
		nil, 
		"wh2_twa03_def_rakarth_early_game_capture_settlement",
		"FELICION",
		"wh2_main_vor_albion_troll_fjord",
		"wh_main_nor_skaeling",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. 15 .. ";}"
		},
		true,
		false,
		false,
		true
	);

		
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- How dare the Skaeling continue to oppose me? Their love for war is admirable, but whenever I face them in battle I am reminded of the superiority of beasts over Men. It matters little – they shall all be trampled into carrion under hoof, paw and claw, or ground into feed for my monstrous host.
		"wh2_twa03.camp.vortex.Rakarth.early_game.002",
		nil,
		"wh2_twa03_def_rakarth_early_game_eliminate_faction",
		"FELICION",
		"wh_main_nor_skaeling",
		1,
		25,
		{
			"money 2000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. 20 .. ";}"
		},
		true
	);
	
	
	-- non-aggression pact mission
	-- triggers on the supplied turn, if the player does not already have a nap with the specified faction (and they aren't at war with them)
	-- advice_key, infotext, mission_key, target_faction_key, turn_threshold, mission_rewards
	start_early_game_non_aggression_pact_mission_listener(
		-- You need not fight your enemies alone, for there are foreign powers who may wish to curry favour with the Black Court. Agreeing a pact of non-aggression will leave you free to focus your furious wrath upon those who dare cross the Witch King.
		"wh2.camp.vortex.advice.early_game.non_aggression_pacts.002",
		nil,
		"wh2_twa03_def_rakarth_early_game_non_aggression_pact", 
		"FELICION",
		"wh2_main_nor_aghol", 
		3,
		{
			"money 500",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. 8 .. ";}"
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
		"wh2_twa03_def_rakarth_early_game_trade_agreement",
		"FELICION",
		"wh2_main_nor_aghol",
		3,
		12,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " ..15 .. ";}"
		}
	);

	do
		local ritual_region_key = "wh2_main_vor_nagarythe_shrine_of_khaine";

		local advice_to_show = {
			"wh2_twa03.camp.vortex.Rakarth.early_game.003"
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
		-- Go to ritual site
		cutscene:action(function() cm:scroll_camera_from_current(false, 9, {357.8, 491.5, 13.2, 0.0, 7.4}) end, 0);
		
		cutscene:action(
			function() 
				cm:show_advice(advice_to_show[1]);
				table.remove(advice_to_show, 1);
			end, 
			0.5
		);
		-- Pan around ritual site
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {357.9, 492.1, 13.2, 0.55, 6.3}) end, 9);
		
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
		-- Pull up from from ritual site
		cutscene:action(function() cm:scroll_camera_from_current(false, 8, {357.6, 495.8, 28.2, 0.0, 17.0}) end, 16);	
		
		-- ritual settlement capture mission
		-- issues a mission for the player to capture the nearby ritual settlement
		-- supply a cutscene loaded with camera movements and advice triggers. Infotext delay is the time after the cutscene is triggered that the infotext should be shown (to coincide with first advice)
		-- advice_key, cutscene, infotext, infotext_delay, mission_key, region_key, turn_threshold, mission_rewards
		start_early_game_ritual_settlement_capture_mission_listener(
			"wh2_twa03.camp.vortex.Rakarth.early_game.003",
			cutscene, 
			nil, 
			0.5, 
			"wh2_twa03_def_rakarth_early_game_capture_ritual_settlement", 
			"FELICION",
			ritual_region_key, 
			7,
			{
				"money 2000",
				"faction_pooled_resource_transaction{resource wh2_main_ritual_currency;factor wh2_main_resource_factor_missions;amount " .. early_game_ritual_settlement_capture_mission_ritual_currency_payload_amount .. ";}"
			}
		);
		
		
		-- ritual settlement building mission
		-- issues a mission to build a ritual building once the ritual settlement is captured
		-- advice_key, infotext, mission_key, region_key, building_key, mission_rewards
		start_early_game_ritual_building_mission_listener(
			"", 
			nil,
			"wh2_twa03_def_rakarth_early_game_construct_ritual_building", 
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
		local enact_ritual_mission_key = "wh2_twa03_def_rakarth_early_game_enact_ritual";
		local enact_ritual_mission_issuer = "FELICION";
		local ritual_key = "wh2_main_ritual_vortex_1_def";
	
	
		-- ritual currency mission
		-- mission given to the player to enact their first major ritual
		-- triggers once the player has earned the supplied mission trigger currency threshold
		-- if the player has never done this before, they are given a mission to earn the currency. If they have, they are just given a mission to enact the ritual.
		-- advice_key, infotext, mission_trigger_currency_threshold, earn_currency_mission_key, ritual_trigger_currency_threshold, enact_ritual_mission_key, ritual_key, mission_rewards
		start_early_game_ritual_currency_mission_listener(
			-- The sorceress informs me she is nearly ready to unleash her first ritual against the Vortex of the Asur; but she is not alone in trying to influence the magic maelstrom. We must hurry, I will not fall second to some foreign cretin. More Scrolls are needed to dominate the Vortex and we shall find them!
			"",
			{
				1,
				"wh2.camp.advice.ritual_currency.info_001",
				"wh2.camp.advice.ritual_currency.info_002",
				"wh2.camp.advice.ritual_currency.info_005",		-- customise this value per-race!
				"wh2.camp.advice.ritual_currency.info_003"
			},
			30,
			"wh2_twa03_def_rakarth_early_game_earn_ritual_currency",
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
			"",
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
