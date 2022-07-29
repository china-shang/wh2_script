


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
	start_early_game_missions(from_intro_first_turn, true);

	-- Taurox Vortex narrative
	cm:trigger_mission("wh2_dlc17_bst_taurox", "wh2_dlc17_bst_taurox_vortex_narrative_1", true)
end;


---------------------------------------------------------------
--	Start all faction-specific interventions
---------------------------------------------------------------

function start_interventions()

	out.interventions("* start_interventions() called");
	out("* start_interventions() called");
			
	-- global
	start_global_interventions(true);
	core:trigger_event("ScriptEventBeastmenCampaignStart")
end;

---------------------------------------------------------------
--	Early-game missions
--	Start the listeners that trigger the early-game missions.
--	the underlying functions are found in wh2_early_game.lua
---------------------------------------------------------------
local early_game_dread_amount = "100"
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
		--Destroy the enemy! Raze their hovels! Build Herdstone for glory of Dark Masters!
		"wh2.dlc17.camp.vortex.taurox.early.game.001.herdstone",
		nil, 
		"wh2_dlc17_bst_taurox_early_game_capture_herdstone",
		"HARBINGER",
		"wh2_main_vor_shadow_wood_venom_glade",
		"wh2_main_def_clar_karond",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
		},
		true,
		nil,
		nil,
		true
	);
	
	-- eliminate faction mission
	-- triggers once the principal enemy faction is down to a small number of settlements
	-- advice_key, infotext, mission_key, faction_key, number_settlements_threshold, max_turn_threshold, mission_rewards
	start_early_game_eliminate_faction_mission_listener(
		-- The weak cannot survive the Bloodgrounds. I smell their fear… Smell their blood. Find them! Destroy them! Smash walls and burn their homes to the ground!
		"wh2.dlc17.camp.vortex.taurox.early.game.002.bloodgrounds",
		nil,
		"wh2_dlc17_bst_taurox_early_game_destroy_faction",
		"HARBINGER",
		"wh2_main_def_clar_karond",
		4,
		40,
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
		},
		true
	);

	start_early_game_cst_growth_point_ship_mission_listener(
		"wh2.dlc17.camp.vortex.taurox.early.game.002.bloodgrounds",
		nil,
		"wh2_dlc17_bst_taurox_early_game_construct_building_in_horde",
		"HARBINGER",
		"wh2_dlc17_bst_taurox",
		{
			"wh_dlc03_horde_beastmen_herd_2"
		},
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
		}
	);
	
	start_early_game_tech_building_mission_listener(
	"wh2.camp.vortex.advice.early_game.hero_buildings.001", 
	nil, 
	"wh2_dlc17_bst_taurox_early_game_construct_special_herdstone_building",
	"HARBINGER",
	{
		"wh2_dlc17_bst_special_secondary_attributes",
		"wh2_dlc17_bst_special_secondary_attrition",
		"wh2_dlc17_bst_special_secondary_climates",
		"wh2_dlc17_bst_special_secondary_resistances",
		"wh2_dlc17_bst_special_secondary_spell"
	},
	{
		"money 1000",
		"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
	}, 
	false,
	{	
		"wh2_dlc17_bst_settlement_major_1",
		"wh2_dlc17_bst_settlement_minor_1",
		"wh2_dlc17_bst_settlement_major_1_coast",
		"wh2_dlc17_bst_settlement_minor_1_coast",

	});

	
	
	start_early_game_pooled_resource_mission_listener(
		"wh2_dlc17.camp.advice.bst.panel.001.open",
		{
			"war.camp.hp.dread_panel.001",
			"war.camp.hp.dread_panel.002",
			"war.camp.hp.dread_panel.003"
		},
		"wh2_dlc17_bst_taurox_early_game_sack_raze_bloodground",
		"bst_dread",
		10,
		200,
		"HARBINGER",
		{
			"money 1000"
		}
	);

	start_early_game_ritual_category_mission_listener(
		"wh2_dlc17.camp.advice.bst.panel.001.open", 
		{
			"war.camp.hp.dread_panel.001",
			"war.camp.hp.dread_panel.002",
			"war.camp.hp.dread_panel.003"
		}, 
		"wh2_dlc17_bst_taurox_early_game_spend_dread_on_panel", 
		"BEASTMEN_RITUAL_UNITS",
		"bst_dread", 
		200, 
		"HARBINGER",
		{
			"money 1000"
		},
		"mission_text_text_wh2_dlc17_beastmen_panel_mis_override_unit_cap_1"
	)
		
			
	-- hero action mission
	-- triggers when the player gains their first hero
	-- issues the supplied advice, and a mission to use a hero action
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_hero_action_mission_listener(
		-- A hero has enrolled in your service, my Lord. Be sure to put them to work - their unique skills may solve problems that no amount of money or effort would otherwise be able to crack.
		"wh2.camp.vortex.advice.early_game.hero_actions.001",
		nil,
		"wh2_dlc17_bst_taurox_early_game_hero_action",
		"HARBINGER",
		{
			"money 500"
		}
	);
	
	-- research tech mission
	-- triggers once the player has built a tech-capable building
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_research_tech_mission_listener(
		-- You now have the facilities to begin technological research, my Lord. It only remains for you to choose the direction of development.
		"wh2.camp.vortex.advice.early_game.tech_research.001",
		nil,
		"wh2_dlc17_bst_taurox_early_game_unlock_technology",
		"HARBINGER",
		{
			"money 1000",
			"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
		},
		false,
		true,
		4
	);

	-- raise army mission
	-- triggers when the player is at war with two armies, is outnumbered and can afford a second army
	-- advice_key, infotext, mission_key, mission_rewards
	start_early_game_raise_army_mission_listener(
		-- Your war efforts would be strengthened by the raising of a new army. Appoint another command, and you can open a second front against your foes.
		"war.camp.advice.raise_forces.001",
		nil,
		"wh2_dlc17_bst_taurox_early_game_raise_new_army",
		"HARBINGER",
		{
			"money 500"
		}
	);
	
	start_generic_scripted_mission_listener(
	"wh2_dlc17_bst_taurox_early_game_cast_herdstone_ritual",
	"HARBINGER",
	{
		"money 1000",
		"faction_pooled_resource_transaction{resource bst_dread;factor wh2_dlc17_bst_dread_gain_missions_events;amount "..early_game_dread_amount..";}"
	}, 
	"mission_text_text_mis_objective_taurox_perform_ritual_of_ruin", 
	"ScriptEventBloodgroundCreated", 
	"ScriptEventRitualofRuinPerformed")
	
end;
