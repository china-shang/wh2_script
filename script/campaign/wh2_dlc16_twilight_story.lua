local throt_faction_key = "wh2_main_skv_clan_moulder";
local sisters_faction_key = "wh2_dlc16_wef_sisters_of_twilight";
local throt_waystone_targets = {
		{region = "wh2_main_vor_iron_peaks_the_moon_shard", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_1", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_1", mission_complete = false}, 
		{region = "wh2_main_vor_the_black_coast_vauls_anvil", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_2", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_2", mission_complete = false}, 
		{region = "wh2_main_vor_the_black_flood_temple_of_khaine", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_3", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_3", mission_complete = false}, 
		{region = "wh2_main_vor_plain_of_spiders_clarak_spire", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_4", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_4", mission_complete = false}, 
		{region = "wh2_main_vor_shadow_wood_clar_karond", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_5", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_5", mission_complete = false}, 
		{region = "wh2_main_vor_the_chill_road_the_great_arena", mission_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_mission_reward_6", final_battle_effect_bundle = "wh2_dlc16_skv_throt_vortex_narrative_final_battle_bundle_6", mission_complete = false}
	};
local throt_remaining_waystones = 6;
local throt_ritual_base = 50;
local throt_ritual_timer = 50;
local throt_added_waystone_time = 10;

active_skaven_invasions = false;
skaven_invasions_turn_start = 0;

local throt_final_battle_mission_key = "wh2_dlc16_qb_skv_final_battle_throt";
local sisters_final_battle_mission_key = "wh2_dlc16_qb_wef_final_battle_sisters";

function add_twilight_story_listeners()
	out("#### Adding Throt Story Listeners ####");
	local throt_interface = cm:model():world():faction_by_key(throt_faction_key);
	local sisters_interface = cm:model():world():faction_by_key(sisters_faction_key);

	--check campaign is Vortex
	if cm:model():campaign_name("wh2_main_great_vortex") == true then
		if cm:is_new_game() then
			cm:add_scripted_composite_scene_to_logical_position("campaign_daemon_portal","campaign_daemon_portal",134,569,1,1,false,true,false)
		end
		--check if Throt exists and if he is human
		if throt_interface:is_null_interface() == false and throt_interface:is_human() == true  then
		
			core:add_listener(
				"Throt_FactionTurnStart",
				"ScriptEventHumanFactionTurnStart",
				true,
				function(context)
					Throt_FactionTurnStart(context);
				end,
				true
			);
			core:add_listener(
				"Throt_MissionSucceeded",
				"MissionSucceeded",
				true,
				function(context)
					Throt_MissionSucceeded(context);
				end,
				true
			);
			-- Apply correct effect bundles to Throts enemy faction depending on remaining missions
			core:add_listener(
				"Throt_PendingFinalBattle",
				"PendingBattle",
				function()
					local pb = cm:model():pending_battle();
					return pb:set_piece_battle_key() == "wh2_dlc16_qb_skv_final_battle_throt";
				end,
				function()
					local pb = cm:model():pending_battle();
					
					local defender = pb:defender();
					local defender_cqi = defender:military_force():command_queue_index();
					
					for i = 1, #throt_waystone_targets do
						if throt_waystone_targets[i].mission_complete == false then
							out.design("Applying effect bundles to defender belonging to " .. defender:faction():name());
							cm:apply_effect_bundle_to_force(throt_waystone_targets[i].final_battle_effect_bundle, defender_cqi, 0);
						end
					end
				end,
				true
			);
			core:add_listener(
				"Throt_FinalBattleCompleted",
				"BattleCompleted",
				function(context)
					local pb = cm:model():pending_battle();
					return pb:has_been_fought() and pb:set_piece_battle_key() == "wh2_dlc16_qb_skv_final_battle_throt";
				end,
				function(context)
					local won = false;

					if cm:pending_battle_cache_attacker_victory() then
						won = true;
					end;
					Throt_CompleteCampaign(won);
				end,
				true
			);
			core:add_listener(
				"Throt_FinalBattleMissionFailed",
				"MissionFailed",
				function(context)
					return context:mission():mission_record_key() == throt_final_battle_mission_key;
				end,
				function(context)
					--Campaign Loss
					Throt_CompleteCampaign(false);
				end,
				true
			);
			if cm:is_new_game() and not cm:is_multiplayer() then
				for i = 1, #throt_waystone_targets do
					local mm = mission_manager:new(throt_faction_key, "wh2_dlc16_skv_throt_vortex_narrative_"..i);
					local region_key = throt_waystone_targets[i].region
					mm:set_mission_issuer("CLAN_ELDERS");
					mm:add_new_objective("RAZE_OR_OWN_SETTLEMENTS");
					mm:add_condition("region "..region_key);
					mm:set_turn_limit(0);
					mm:set_should_whitelist(false);
					mm:add_payload("money 5000");
					mm:add_payload("effect_bundle{bundle_key " .. throt_waystone_targets[i].mission_effect_bundle .. ";turns 0;}");
					mm:trigger();

					
					local comp_scene_id = "healing_ritual_"..region_key
					cm:add_scripted_composite_scene_to_settlement(comp_scene_id,"wh2_dlc16_wef_healing_ritual","settlement:"..region_key,0,0,false,true,true)
				end

			end
			
			Throt_UpdateRitualTimer();
			Throt_ButtonControl();
			Throt_CinematicTriggers();
			Throt_FinalBattleSetupDilemma();

		--check if the Sisters exists and if they are human
		elseif sisters_interface:is_null_interface() == false and sisters_interface:is_human() == true  then

			core:add_listener(
				"Sisters_MissionSucceeded",
				"MissionSucceeded",
				true,
				function(context)
					Sisters_MissionSucceeded(context);
				end,
				true
			);
			core:add_listener(
				"Sisters_FinalBattleCompleted",
				"BattleCompleted",
				function(context)
					local pb = cm:model():pending_battle();
					return pb:has_been_fought() and pb:set_piece_battle_key() == "wh2_dlc16_qb_wef_final_battle_sisters";
				end,
				function(context)
					local won = false;

					if cm:pending_battle_cache_defender_victory() then
						won = true;
						cm:remove_scripted_composite_scene("campaign_daemon_portal")
					end;
				end,
				true
			);
	

			Sisters_CinematicTriggers();

		end
	end
	welves_retlation_army_setup();
end

function Throt_FactionTurnStart(context)
	local faction = context:faction();

	if faction:name() == throt_faction_key and cm:is_multiplayer() == false then
		local turn_number = cm:model():turn_number();
		Throt_UpdateRitualTimer();
		if throt_ritual_timer <= 0 then
			cm:trigger_mission(throt_faction_key, throt_final_battle_mission_key, true)
		end
	end
end

function Throt_MissionSucceeded(context)
	local faction = context:faction();

	if faction:is_human() == true and faction:name() == throt_faction_key then
		local mission = context:mission();
		local mission_key = mission:mission_record_key();

		if mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_") then
			throt_remaining_waystones = throt_remaining_waystones - 1;
			core:trigger_event("ScriptEvent_WaystoneMissionCompleted");
			if throt_remaining_waystones == 3 then
				core:trigger_event("ScriptEvent_UnlockThrotFinalBattle");
			end
			Throt_UpdateRitualTimer();
			local region_key = false
			if mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_1") then
				throt_waystone_targets[1].mission_complete = true;
				region_key = throt_waystone_targets[1].region
				spawn_retaliation_army(region_key);
				
			elseif mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_2") then
				throt_waystone_targets[2].mission_complete = true;
				region_key = throt_waystone_targets[2].region
				spawn_retaliation_army(region_key);
				
			elseif mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_3") then
				throt_waystone_targets[3].mission_complete = true;
				region_key = throt_waystone_targets[3].region
				spawn_retaliation_army(region_key);
				
			elseif mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_4") then
				throt_waystone_targets[4].mission_complete = true;
				region_key = throt_waystone_targets[4].region
				spawn_retaliation_army(region_key);
			
			elseif mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_5") then
				throt_waystone_targets[5].mission_complete = true;
				region_key = throt_waystone_targets[5].region
				spawn_retaliation_army(region_key);
				
			elseif mission_key:find("wh2_dlc16_skv_throt_vortex_narrative_6") then
				throt_waystone_targets[6].mission_complete = true;
				region_key = throt_waystone_targets[6].region
				spawn_retaliation_army(region_key);
				
			end
			if region_key ~= false then
				local comp_scene_id = "healing_ritual_"..region_key
				cm:remove_scripted_composite_scene(comp_scene_id)
				
				---BLOW UP THE WAYSTONE!!!!
				cm:add_scripted_composite_scene_to_settlement("ritual_finished","wh2_dlc16_ariel_agent_action","settlement:"..region_key,0,0, true, true, true)
			end
		end
		
	end
end

function spawn_retaliation_army(region_key)
	
	local retaliation_faction_key = "wh_dlc05_wef_wood_elves_qb1";	
	--local spawn_pos = {x = 139, y = 566};
	--commented out old spawn pos method to instead use a safer method whichchecks ifthe position is free first
	local spawn_x, spawn_y = cm:find_valid_spawn_location_for_character_from_position("wh_dlc05_wef_wood_elves_qb1", 139, 566, true, 8);
	local spawn_pos = {x = spawn_x, y = spawn_y};
	local welve_retaliation = nil;
	local player_cqi = cm:get_faction(throt_faction_key):command_queue_index();
	local sisters_region_cqi = cm:get_region("wh2_main_vor_naggaroth_glade"):cqi();

	--get total destroyed waystones, this will be used to scale number of units based on how many waystones destroyed
	--additionally we use it to make sure we can get multiple invasions as they will have unique invasion keys
	local total_waystones_destroyed = (6 - throt_remaining_waystones); 
	local num_units = 5; 
	local force_key = "welves_retaliation_";
	local invasion_key = "welves_retaliation_invasion_";

	--check for difficulty if easy or normal less units of lower quality, hard or above more units higher quality
	if cm:get_difficulty() <= 2 then		
		num_units = num_units + total_waystones_destroyed*2;
		invasion_key = invasion_key .. tostring(total_waystones_destroyed);
		force_key = force_key .. "easy";
	elseif cm:get_difficulty() >= 3 then
		num_units = num_units + total_waystones_destroyed*3;
		invasion_key = invasion_key .. tostring(total_waystones_destroyed);
		force_key = force_key .. "hard";
	end

	if num_units > 19 then
		num_units = 19;
	end

	--create random force with the force key and number of units
	local unit_list = random_army_manager:generate_force(force_key, num_units);

	welve_retaliation = invasion_manager:new_invasion(invasion_key, retaliation_faction_key, unit_list, spawn_pos);

	--set region target to be the recently occupied waystone settlement, if the settlement was razed then set throts capital
	local region = cm:get_region(region_key);
	local target_region = "";

	if region:is_abandoned() == false then
		target_region = region_key;
	else
		target_region = cm:get_faction(throt_faction_key):home_region():name();
	end

	welve_retaliation:set_target("REGION", target_region, throt_faction_key);
	welve_retaliation:apply_effect("wh_main_bundle_military_upkeep_free_force_siege_attacker", 0);
	welve_retaliation:add_aggro_radius(300, {throt_faction_key}, 5);
	welve_retaliation:abort_on_target_owner_change(true);
	welve_retaliation:start_invasion(true,true,false,false);
	cm:trigger_incident_with_targets(player_cqi,"wh2_dlc16_incident_skv_retaliation_army_spawned", 0,0,0,0,sisters_region_cqi,0)

end

function Throt_UpdateRitualTimer()
	local turn_number = cm:model():turn_number();
--  #turns left			= 	(starting timer)		-	(current turn)		+	((total waystones - remaining)		*	(time gained from destroying waystone))
	throt_ritual_timer	= 	(throt_ritual_base) 	- 	(turn_number - 1) 	+ 	((6 - throt_remaining_waystones) 	* 	throt_added_waystone_time);
	out.design("\n\t\tThrot campaign timer is :\t" .. tostring(throt_ritual_timer))
	if throt_ritual_timer < 0 then
		throt_ritual_timer = 0;
	end
	effect.set_context_value("throt_vortex_battle_timer", throt_ritual_timer);

end

function Throt_ButtonControl()
	
	local throt_button = find_uicomponent(core:get_ui_root(), "layout", "throt_vortex_holder", "throt_vortex", "final_battle_button_holder", "final_battle_button");

	if throt_button and (throt_remaining_waystones >= 4) then
		throt_button:SetDisabled(true);
	end

	core:add_listener(
		"Throt_FinalBattleButtonUnlocker",
		"ScriptEvent_UnlockThrotFinalBattle",
		true,
		function()
			if throt_button then
				throt_button:SetDisabled(false);
			end
		end,
		false
	);

	core:add_listener(
		"ThrotFinalBattle_ComponentLClickUp",
		"ComponentLClickUp",
		function(context)
			return UIComponent(context.component) == throt_button;
		end,
		function(context)
					
			if cm:is_multiplayer() == false then
				cm:trigger_dilemma(throt_faction_key, "wh2_dlc16_skv_throt_final_battle_dilemma");
			else
				CampaignUI.TriggerCampaignScriptEvent(0, "throt_final_battle_event");
			end
		end,
		true
	);

	core:add_listener(
		"Throt_UITrigger",
		"UITrigger",
		function(context)
			return context:trigger() == "throt_final_battle_event";
		end,
		function(context)
			cm:trigger_dilemma(throt_faction_key, "wh2_dlc16_skv_throt_final_battle_dilemma");
		end,
		true
	);

end

function Throt_CinematicTriggers()
	
	core:add_listener(
		"Throt_COA_cine",
		"ScriptEvent_UnlockThrotFinalBattle",
		true,
		function()
			core:svr_save_registry_bool("twilight_throt_call_to_arms", true);
			cm:register_instant_movie("warhammer2/twilight/twilight_throt_call_to_arms");
		end,
		false
	);
	
	core:add_listener(
		"Throt_WIN_cine",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key() == throt_final_battle_mission_key;
		end,
		function()
			cm:complete_scripted_mission_objective("wh_main_long_victory", "complete_throt_final_battle", true);
			core:svr_save_registry_bool("twilight_throt_win", true);
			cm:register_instant_movie("warhammer2/twilight/twilight_throt_win");
		end,
		false
	);
end

function Throt_FinalBattleSetupDilemma()
	core:add_listener(
		"Throt_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		function(context)
			return context:dilemma() == "wh2_dlc16_skv_throt_final_battle_dilemma";
		end,
		function(context)
			local choice = context:choice();
			if choice == 0 then
				cm:trigger_mission(throt_faction_key, throt_final_battle_mission_key, true)
			end
		end,
		true
	);
end

function Throt_CompleteCampaign(value)
	if value then		
		cm:disable_event_feed_events(true, "", "", "faction_campaign_victory_objective_complete");
	else
		cm:disable_event_feed_events(true, "", "", "faction_event_mission_aborted");
	end;
	
	local campaign_type = cm:model():campaign_type();
	
	if campaign_type == 0 then
		out("If this is false then throt should lose campaign: "..tostring(value))
		cm:complete_scripted_mission_objective("wh_main_long_victory", "complete_throt_final_battle", value);
		cm:complete_scripted_mission_objective("wh2_main_vor_domination_victory", "domination", value);
	elseif campaign_type == 4 then
		cm:complete_scripted_mission_objective("wh_main_mp_coop_victory", "final_battle_condition", value);
	else
		cm:complete_scripted_mission_objective("wh_main_mp_versus_victory", "final_battle_condition", value);
	end;
end;

function Sisters_MissionSucceeded(context)
	local faction = context:faction();

	if faction:is_human() == true and faction:name() == sisters_faction_key then
		local mission = context:mission();
		local mission_key = mission:mission_record_key();

		if mission_key:find("wh2_dlc16_wef_sisters_vortex_narrative_1") then
			
			Worldroots:spawn_ariel(sisters_faction_key)

		elseif mission_key:find("wh2_dlc16_wef_sisters_vortex_narrative_2") then
	
			--remove previous narrative mission reward effect bundle
			cm:remove_effect_bundle("wh2_dlc16_wef_sisters_vortex_narrative_reward_1", sisters_faction_key);
				
		elseif mission_key:find("wh2_dlc16_wef_sisters_vortex_narrative_3") then
		
			-- Skaven invasions of increasing difficulty will spawn after final battle is unlocked
			-- setting bool to true for the turn_start listeners above and saving the current turn for the invasion start number
			-- triggering incident to explain to player
			active_skaven_invasions = true;
			skaven_invasions_turn_start = cm:turn_number();
			cm:trigger_incident(sisters_faction_key, "wh2_dlc16_incident_sisters_skaven_invasion_warning");

			--remove previous narrative mission reward effect bundle
			cm:remove_effect_bundle("wh2_dlc16_wef_sisters_vortex_narrative_reward_2", sisters_faction_key);

		elseif mission_key:find(sisters_final_battle_mission_key) then
			--fire incident to state invasions are over
			cm:trigger_incident(sisters_faction_key, "wh2_dlc16_incident_sisters_skaven_invasion_ends");
			--end of of the invasions if they have already started once final battle is completed
			invasion_manager:kill_invasion_by_key("witchwood_invasion_137535");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_101581");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_102575");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_101535");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_129586");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_149539");
			invasion_manager:kill_invasion_by_key("witchwood_invasion_79555");

			active_skaven_invasions = false;

			--remove previous narrative mission reward effect bundle
			cm:remove_effect_bundle("wh2_dlc16_wef_sisters_vortex_narrative_reward_3", sisters_faction_key);

		end
		
	end
end

function Sisters_CinematicTriggers()
	
	core:add_listener(
		"Sisters_COA_cine",
		"RitualStartedEvent",
		function(context)
			return context:ritual():ritual_key() == "wh2_dlc16_ritual_rebirth_naggarond_glade_vortex";
		end,
		function()
			core:svr_save_registry_bool("twilight_sisters_call_to_arms", true);
			cm:register_instant_movie("warhammer2/twilight/twilight_sisters_call_to_arms");
		end,
		false
	);
	
	core:add_listener(
		"Sisters_WIN_cine",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key() == sisters_final_battle_mission_key;
		end,
		function()
			cm:complete_scripted_mission_objective("wh_main_long_victory", "complete_sisters_final_battle", true);
			core:svr_save_registry_bool("twilight_sisters_win", true);
			cm:register_instant_movie("warhammer2/twilight/twilight_sisters_win");
		end,
		false
	);
	
end

function welves_retlation_army_setup()
	
	-- Easy/Normal Army
	random_army_manager:new_force("welves_retaliation_easy");
	
	random_army_manager:add_mandatory_unit("welves_retaliation_easy", "wh_dlc05_wef_inf_eternal_guard_0", 3);	
	random_army_manager:add_mandatory_unit("welves_retaliation_easy", "wh_dlc05_wef_inf_glade_guard_0", 2);
	
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_inf_dryads_0", 10);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_inf_eternal_guard_1", 10);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_inf_deepwood_scouts_0", 8);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_forest_dragon_0", 1);
	random_army_manager:add_unit("welves_retaliation_easy", "wh2_dlc16_wef_mon_zoats", 1);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_cav_wild_riders_0", 1);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_mon_treeman_0", 1);
	random_army_manager:add_unit("welves_retaliation_easy", "wh_dlc05_wef_cav_sisters_thorn_0", 1);
	
	-- Hard or Above Army
	random_army_manager:new_force("welves_retaliation_hard");
	
	random_army_manager:add_mandatory_unit("welves_retaliation_hard", "wh_dlc05_wef_inf_eternal_guard_1", 3);
	random_army_manager:add_mandatory_unit("welves_retaliation_hard", "wh_dlc05_wef_inf_deepwood_scouts_1", 2);
	
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_inf_wildwood_rangers_0", 10);
	random_army_manager:add_unit("welves_retaliation_hard", "wh2_dlc16_wef_inf_bladesingers_0", 10);
	random_army_manager:add_unit("welves_retaliation_hard", "wh2_dlc16_wef_cav_great_stag_knights_0", 2);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_cav_sisters_thorn_0", 2);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_cav_glade_riders_1", 8);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_cav_wild_riders_1", 2);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_inf_waywatchers_0", 8);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_forest_dragon_0", 1);
	random_army_manager:add_unit("welves_retaliation_hard", "wh2_dlc16_wef_mon_zoats", 2);
	random_army_manager:add_unit("welves_retaliation_hard", "wh_dlc05_wef_mon_treeman_0", 1);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("throt_ritual_timer", throt_ritual_timer, context);
		cm:save_named_value("throt_remaining_waystones", throt_remaining_waystones, context);
		cm:save_named_value("throt_waystone_targets", throt_waystone_targets, context);
		cm:save_named_value("active_skaven_invasions", active_skaven_invasions, context);
		cm:save_named_value("skaven_invasions_turn_start", skaven_invasions_turn_start, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			throt_ritual_timer = cm:load_named_value("throt_ritual_timer", throt_ritual_timer, context);
			throt_remaining_waystones = cm:load_named_value("throt_remaining_waystones", throt_remaining_waystones, context);
			throt_waystone_targets = cm:load_named_value("throt_waystone_targets", throt_waystone_targets, context);
			active_skaven_invasions = cm:load_named_value("active_skaven_invasions", active_skaven_invasions, context);
			skaven_invasions_turn_start = cm:load_named_value("skaven_invasions_turn_start", skaven_invasions_turn_start, context);
		end
	end
);
