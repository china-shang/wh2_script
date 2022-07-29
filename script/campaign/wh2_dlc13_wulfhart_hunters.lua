local wulfhart_faction = "wh2_dlc13_emp_the_huntmarshals_expedition";

local hunter_kalara_unlocked = false;
local hunter_kalara_complete = false;
local hunter_kalara_spawned = false;

local hunter_jorek_unlocked = false;
local hunter_jorek_complete = false;
local hunter_jorek_spawned = false;

local hunter_rodrik_unlocked = false;
local hunter_rodrik_complete = false;
local hunter_rodrik_spawned = false;

local hunter_hertwig_unlocked = false;
local hunter_hertwig_complete = false;		
local hunter_hertwig_spawned = false;

function add_wulfhart_hunters_listeners()
	out("#### Adding Wulfhart Hunters Listeners ####");
	
	if cm:is_new_game() == true then
		local wulfhart_interface = cm:model():world():faction_by_key(wulfhart_faction); 
		local nakai_interface = cm:model():world():faction_by_key("wh2_dlc13_lzd_spirits_of_the_jungle");

		if wulfhart_interface:is_null_interface() == false then
			if wulfhart_interface:is_human() == true then
				cm:callback(function()
					wulfhart_generate_hunter_missions();
				end, 0.5);
				
				if cm:model():is_multiplayer() == false and cm:model():campaign_name("wh2_main_great_vortex") == true then
					local gor_rok_interface = cm:model():world():faction_by_key("wh2_main_lzd_itza");

					if nakai_interface:is_null_interface() == false then
						-- Hide Nakai for Markus in SP
						cm:kill_character(nakai_interface:faction_leader():command_queue_index(), false, false);
						cm:lock_starting_general_recruitment("1651687924", "wh2_dlc13_lzd_spirits_of_the_jungle");
					end
					
					if gor_rok_interface:is_null_interface() == false then
						-- Hide Gor rok for Markus in SP
						cm:kill_character(gor_rok_interface:faction_leader():command_queue_index(), false, false);
						cm:lock_starting_general_recruitment("2140785316", "wh2_main_lzd_itza");
					end
					
					cm:force_declare_war("wh2_dlc13_lzd_spirits_of_the_jungle", "wh2_dlc13_emp_the_huntmarshals_expedition", false, false, false);
					cm:force_diplomacy("faction:wh2_dlc13_emp_the_huntmarshals_expedition", "faction:wh2_dlc13_lzd_spirits_of_the_jungle", "all", false, false, true);
				end

			elseif cm:get_campaign_name() == "main_warhammer" or (nakai_interface:is_null_interface() == false and nakai_interface:is_human() == false) then
				local wulfhart_cqi = wulfhart_interface:command_queue_index()
				local wulfhart_capital_cqi = wulfhart_interface:home_region():cqi()
				cm:spawn_unique_agent_at_region(wulfhart_cqi, "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal",wulfhart_capital_cqi, false);
				cm:spawn_unique_agent_at_region(wulfhart_cqi, "wh2_dlc13_emp_hunter_jorek_grimm",wulfhart_capital_cqi, false);
				cm:spawn_unique_agent_at_region(wulfhart_cqi, "wh2_dlc13_emp_hunter_kalara_of_wydrioth",wulfhart_capital_cqi, false);
				cm:spawn_unique_agent_at_region(wulfhart_cqi, "wh2_dlc13_emp_hunter_rodrik_l_anguille",wulfhart_capital_cqi, false);
			end
		end
	end
	
	if cm:model():is_multiplayer() == false then
		cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "all", false, false, true);
		cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "payments", true, true, true);
		cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "war", true, true, true);
		cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "peace", true, true, true);
	end
	
	core:add_listener(
		"HunterSpawned",
		"UniqueAgentSpawned",
		function(context)
			local unique_agent_subtype = context:unique_agent_details():character():character_subtype_key();
			return unique_agent_subtype == "wh2_dlc13_emp_hunter_kalara_of_wydrioth" or unique_agent_subtype == "wh2_dlc13_emp_hunter_jorek_grimm" 
				or unique_agent_subtype == "wh2_dlc13_emp_hunter_rodrik_l_anguille" or unique_agent_subtype == "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal";
		end,
		function(context)
			local unique_agent = context:unique_agent_details():character();
			local unique_agent_subtype = unique_agent:character_subtype_key();
			out.design("\n\t\t The subtype is: \t"..unique_agent_subtype);
			if unique_agent_subtype == "wh2_dlc13_emp_hunter_kalara_of_wydrioth" then
				out("KALARA SPAWNED!");
				hunter_kalara_spawned = true;
			end
			if unique_agent_subtype == "wh2_dlc13_emp_hunter_jorek_grimm" then
				out("JOREK SPAWNED!");
				hunter_jorek_spawned = true;
			end
			if unique_agent_subtype == "wh2_dlc13_emp_hunter_rodrik_l_anguille" then
				out("RODRIK SPAWNED!");
				hunter_rodrik_spawned = true;
			end
			if unique_agent_subtype == "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal" then
				out("HERTWIG SPAWNED!");
				hunter_hertwig_spawned = true;
			end
			cm:replenish_action_points("character_cqi:"..unique_agent:command_queue_index());
		end,
		true
	);

	cm:add_faction_turn_start_listener_by_name(
		"HunterFailedToSpawn",
		wulfhart_faction,
		function(context)
			local wulfhart_interface = cm:model():world():faction_by_key(wulfhart_faction); 
			local wulfhart_cqi = wulfhart_interface:command_queue_index();
			
			if hunter_kalara_unlocked == true and hunter_kalara_spawned == false then
				cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_kalara_of_wydrioth", false);
			end
			if hunter_jorek_unlocked == true and hunter_jorek_spawned == false then
				cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_jorek_grimm", false);
			end
			if hunter_rodrik_unlocked == true and hunter_rodrik_spawned == false then
				cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_rodrik_l_anguille", false);
			end
			if hunter_hertwig_unlocked == true and hunter_hertwig_spawned == false then
				cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal", false);
			end

			if cm:model():is_multiplayer() == false then
				cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "all", false, false, true);
				cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "payments", true, true, true);
				cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "war", true, true, true);
				cm:force_diplomacy("faction:"..wulfhart_faction, "subculture:wh2_main_sc_lzd_lizardmen", "peace", true, true, true);
			end
		end,
		true
	);

	core:add_listener(
		"HunterIncidentsSucceeded",
		"MissionSucceeded",
		function(context)
			return context:faction():name() == wulfhart_faction;
		end,
		function(context)
			wulfhart_missions_updated(context);
		end,
		true
	);

	core:add_listener(
		"HunterIncidentsCancelled",
		"MissionCancelled",
		function(context)
			return context:faction():name() == wulfhart_faction;
		end,
		function(context)
			wulfhart_missions_updated(context);
		end,
		true
	);

	core:add_listener(
		"HunterIncidentsGenerationFailed",
		"MissionGenerationFailed",
		true,
		function(context)
			local mission = context:mission();
			out.design("\n\n\t\t print the mission id here: "..mission.."\n");
			if mission:find("rodrik_languille_stage_2") then
				cm:trigger_dilemma(wulfhart_faction, "wh2_dlc13_wulfhart_rodrik_languille_stage_2_dilemma");
			elseif mission:find("hertwig_van_hal_stage_4") then
				cm:trigger_dilemma(wulfhart_faction, "wh2_dlc13_wulfhart_hertwig_van_hal_stage_4_dilemma");
			elseif mission:find("_kalara_stage_2") then
				if cm:get_campaign_name() == "main_warhammer" then
					cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_kalara_stage_3", true);
				else
					cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_kalara_stage_3", true);
				end
			elseif mission:find("_rodrik_languille_stage_3") then
				if cm:get_campaign_name() == "main_warhammer" then
					cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_rodrik_languille_stage_4", true);
				else
					cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_rodrik_languille_stage_4", true);
				end
			end

		end,
		true
	);
	
	core:add_listener(
		"KalaraStage2",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key():find("_kalara_stage_1");
		end,
		function(context)
			if cm:get_campaign_name() == "main_warhammer" then
				cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_kalara_stage_2", true);
			else
				cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_kalara_stage_2", true);
			end
		end,	
		true
	);

	-- Not head to head
	if cm:model():campaign_type() ~= 2 then
		-- Apply army abilities in the Amber Bow Quest Battle
		core:add_listener(
			"AmberBow_ArmyAbilities",
			"PendingBattle",
			function()
				local pb = cm:model():pending_battle();
				return pb:set_piece_battle_key():find("wh2_dlc13_vortex_emp_wulfhart_amber_bow_stage_4");
			end,
			function()
				local pb = cm:model():pending_battle();
				
				local defender = pb:defender();
				local defender_cqi = defender:military_force():command_queue_index();
					
				out.design("Granting army abilities to defender belonging to " .. defender:faction():name());
					
				cm:apply_effect_bundle_to_force("wh2_dlc13_bundle_amber_bow_army_abilities", defender_cqi, 0);
				
			end,
			true
		);
	end;
	
	-- player completes the quest battle
	core:add_listener(
		"AmberBow_BattleCompleted",
		"BattleCompleted",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key():find("wh2_dlc13_vortex_emp_wulfhart_amber_bow_stage_4");
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local defender = pb:defender();
			local char_cqi = false;
			local mf_cqi = false;
			local faction_name = false;
			local has_been_fought = pb:has_been_fought();
			
			if has_been_fought then
				-- if the battle was fought, the defender may have died, so get them from the pending battle cache
				char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_defender(1);
			else
				-- if the player retreated, the pending battle cache won't have stored the defender, so get it from the defender character (who should still be alive as they retreated!)
				faction_name = defender:faction():name();
			end;

			-- player has completed Amber Bow QB
			if defender then
				-- remove army ability effect bundle
				cm:remove_effect_bundle_from_force("wh2_dlc13_bundle_amber_bow_army_abilities", defender:military_force():command_queue_index());
			end;
		end,
		true
	);


	-- Not head to head
	if cm:model():campaign_type() ~= 2 then
		-- Apply army abilities in the Final Battle
		core:add_listener(
			"FinalBattle_Abilities",
			"PendingBattle",
			function()
				local pb = cm:model():pending_battle();
				return pb:set_piece_battle_key():find("wh2_dlc13_qb_emp_final_battle_wulfhart");
			end,
			function()
				local pb = cm:model():pending_battle();
				
				local attacker = pb:attacker();
                local attacker_mf = attacker:military_force();
                local attacker_cqi = attacker_mf:command_queue_index();

                local attacker_char_list = attacker_mf:character_list();

                for i = 0, attacker_char_list:num_items() - 1 do
                    local char_subtype = attacker_char_list:item_at(i):character_subtype_key();
                    if char_subtype == "wh2_dlc13_emp_hunter_rodrik_l_anguille" then
                        cm:apply_effect_bundle_to_force("wh2_dlc13_hunter_final_battle_effect_rodrik_dummy", attacker_cqi, 0);
                    end
					if char_subtype == "wh2_dlc13_emp_hunter_jorek_grimm" then
                        cm:apply_effect_bundle_to_force("wh2_dlc13_hunter_final_battle_effect_jorek_dummy", attacker_cqi, 0);
                    end
				end
			end,
			true
		);
	end;
	
	-- player completes the quest battle
	core:add_listener(
		"FinalBattle_BattleCompleted",
		"BattleCompleted",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key():find("wh2_dlc13_qb_emp_final_battle_wulfhart");
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local attacker = pb:attacker();
			local char_cqi = false;
			local mf_cqi = false;
			local faction_name = false;
			local has_been_fought = pb:has_been_fought();
			
			if has_been_fought then
				-- if the battle was fought, the attacker may have died, so get them from the pending battle cache
				char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_attacker(1);
			else
				-- if the player retreated, the pending battle cache won't have stored the attacker, so get it from the attacker character (who should still be alive as they retreated!)
				faction_name = attacker:faction():name();
			end;

			-- player has completed Final Battle
			if attacker then
				-- remove army ability effect bundle
				cm:remove_effect_bundle_from_force("wh2_dlc13_hunter_final_battle_effect_rodrik_dummy", attacker:military_force():command_queue_index());
				cm:remove_effect_bundle_from_force("wh2_dlc13_hunter_final_battle_effect_jorek_dummy", attacker:military_force():command_queue_index());
			end;
		end,
		true
	);

	local wulfhart_interface = cm:model():world():faction_by_key(wulfhart_faction); 

	if wulfhart_interface:is_null_interface() == false then
		if wulfhart_interface:is_human() == true then

			if cm:get_campaign_name() == "main_warhammer" then
				memm = mission_manager:new(wulfhart_faction, "wh2_dlc13_wulfhart_kalara_stage_1");
				memm:add_new_scripted_objective(
					"mission_text_text_mis_raise_wanted_level_objective", 
					"PooledResourceEffectChangedEvent",
					function(context)
						local faction = context:faction();
						local resource = context:resource();
						return resource:key() == "emp_wanted" and faction:name() == wulfhart_faction and resource:value() >= 20;
					end
				);

				memm:set_mission_issuer("CLAN_ELDERS")
				memm:add_payload("effect_bundle{bundle_key wh2_dlc13_payload_hunter_join;turns 0;}");
				out.design("wh2_dlc13_wulfhart_kalara_stage_1");
			else
				vormm = mission_manager:new(wulfhart_faction, "wh2_dlc13_vor_wulfhart_kalara_stage_1");
				vormm:add_new_scripted_objective(
					"mission_text_text_mis_raise_wanted_level_objective", 
					"PooledResourceEffectChangedEvent",
					function(context)
						local faction = context:faction();
						local resource = context:resource();
						return resource:key() == "emp_wanted" and faction:name() == wulfhart_faction and resource:value() >= 20;
					end
				);

				vormm:set_mission_issuer("CLAN_ELDERS")
				vormm:add_payload("effect_bundle{bundle_key wh2_dlc13_payload_hunter_join;turns 0;}");
				out.design("wh2_dlc13_vor_wulfhart_kalara_stage_1");
			end
		end
	end
end

function wulfhart_generate_hunter_missions()
	
	--checks which campaign it is, then triggers stage 1 of all hunter missions for correct campaign
	if cm:get_campaign_name() == "main_warhammer" then
		memm:trigger();
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_jorek_grimm_stage_1", true);
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_hertwig_van_hal_stage_1", true);
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_wulfhart_rodrik_languille_stage_1", true);
	else
		vormm:trigger();
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_jorek_grimm_stage_1", true);
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_hertwig_van_hal_stage_1", true);
		cm:trigger_mission(wulfhart_faction, "wh2_dlc13_vor_wulfhart_rodrik_languille_stage_1", true);
	end;
		
end

function wulfhart_missions_updated(context)
	local wulfhart_interface = cm:model():world():faction_by_key(wulfhart_faction); 
	local mission_key = context:mission():mission_record_key();
	local incident_key = "";
	local is_hunter_mission = false;

	local wulfhart_cqi = wulfhart_interface:command_queue_index();
	
	--check if the succeeded mission belongs to a hunter mission
	if mission_key:find("_wulfhart_kalara_stage_") then
		
		if mission_key:find("stage_1") then
			
			cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
			cm:disable_event_feed_events(true, "wh_event_category_agent", "", "");
			cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_kalara_of_wydrioth", false);
			
			cm:callback(
				function()
					cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
					cm:disable_event_feed_events(false, "wh_event_category_agent", "", "");
				end,
				0.2
			);
			
			cm:set_saved_value("hunter_kalara_unlocked", true);
			hunter_kalara_unlocked = true;
			core:trigger_event("HunterUnlocked");

			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_join", wulfhart_faction);
				end,
				0.5
			);
			
			incident_key = "wh2_dlc13_wulfhart_kalara_stage_1_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_2") then
			incident_key = "wh2_dlc13_wulfhart_kalara_stage_2_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_3") then

			cm:callback(
				function()
					local wulfhart_char_list = wulfhart_interface:character_list();
					for i = 0, wulfhart_char_list:num_items() - 1 do
						local wulfhart_char = wulfhart_char_list:item_at(i);
						if wulfhart_char:character_subtype_key() == "wh2_dlc13_emp_hunter_kalara_of_wydrioth" then
							cm:force_add_trait(cm:char_lookup_str(wulfhart_char), "wh2_dlc13_trait_kalara_pursuer");
							break;
						end						
					end					
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_kalara_dummy", wulfhart_faction);
				end,
				0.5
			);


			incident_key = "wh2_dlc13_wulfhart_kalara_stage_3_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_4") then
			incident_key = "wh2_dlc13_wulfhart_kalara_stage_4_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_5") then
			incident_key = "wh2_dlc13_wulfhart_kalara_stage_5_incident";
			is_hunter_mission = true;
			cm:set_saved_value("hunter_kalara_complete", true);
			core:trigger_event("ScriptEventHunterStoryCompleted");
		end;
	
	elseif mission_key:find("_wulfhart_jorek_grimm_stage_") then
		
		if mission_key:find("stage_1") then
			
			cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
			cm:disable_event_feed_events(true, "wh_event_category_agent", "", "");
			
			cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_jorek_grimm", false);
			
			cm:callback(
				function()
					cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
					cm:disable_event_feed_events(false, "wh_event_category_agent", "", "");
				end,
				0.2
			);
			
			cm:set_saved_value("hunter_jorek_unlocked", true);
			hunter_jorek_unlocked = true;
			core:trigger_event("HunterUnlocked");
			
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_join", wulfhart_faction);
				end,
				0.5
			);

			incident_key = "wh2_dlc13_wulfhart_jorek_grimm_stage_1_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_2") then
			incident_key = "wh2_dlc13_wulfhart_jorek_grimm_stage_2_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_3") then
			incident_key = "wh2_dlc13_wulfhart_jorek_grimm_stage_3_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_4") then
			cm:add_unit_to_faction_mercenary_pool(wulfhart_interface, "wh2_dlc13_huntmarshall_veh_obsinite_gyrocopter_0", 1, 100, 1, 0.1, 0, "", "", "", true);
			incident_key = "wh2_dlc13_wulfhart_jorek_grimm_stage_4_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_5") then
			cm:set_saved_value("hunter_jorek_complete", true);
			core:trigger_event("ScriptEventHunterStoryCompleted");
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_dilemma", wulfhart_faction);
				end,
				0.5
			);
		end;
		
	elseif mission_key:find("_wulfhart_hertwig_van_hal_stage_") then
		
		if mission_key:find("stage_1") then
			cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
			cm:disable_event_feed_events(true, "wh_event_category_agent", "", "");
			
			cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_doctor_hertwig_van_hal", false);
			
			cm:callback(
				function()
					cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
					cm:disable_event_feed_events(false, "wh_event_category_agent", "", "");
				end,
				0.2
			);
			
			cm:set_saved_value("hunter_hertwig_unlocked", true);
			hunter_hertwig_unlocked = true;
			core:trigger_event("HunterUnlocked");
			
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_join", wulfhart_faction);
				end,
				0.5
			);

			incident_key = "wh2_dlc13_wulfhart_hertwig_van_hal_stage_1_incident";
			is_hunter_mission = true;			
		elseif mission_key:find("stage_2") then
			incident_key = "wh2_dlc13_wulfhart_hertwig_van_hal_stage_2_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_3") then
			incident_key = "wh2_dlc13_wulfhart_hertwig_van_hal_stage_3_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_4") then
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_dilemma", wulfhart_faction);
				end,
				0.5
			);
		elseif mission_key:find("stage_5a") then
			incident_key = "wh2_dlc13_wulfhart_hertwig_van_hal_stage_5a_incident";
			is_hunter_mission = true;
			cm:set_saved_value("hunter_hertwig_complete", true);
			core:trigger_event("ScriptEventHunterStoryCompleted");
		elseif mission_key:find("stage_5b") then
			incident_key = "wh2_dlc13_wulfhart_hertwig_van_hal_stage_5b_incident";
			is_hunter_mission = true;
			cm:set_saved_value("hunter_hertwig_complete", true);
			core:trigger_event("ScriptEventHunterStoryCompleted");
		end;
		
	elseif mission_key:find("_wulfhart_rodrik_languille_stage_") then
		
		if mission_key:find("stage_1") then
			
			cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
			cm:disable_event_feed_events(true, "wh_event_category_agent", "", "");
			
			cm:spawn_unique_agent(wulfhart_cqi, "wh2_dlc13_emp_hunter_rodrik_l_anguille", false);
			
			cm:callback(
				function()
					cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
					cm:disable_event_feed_events(false, "wh_event_category_agent", "", "");
				end,
				0.2
			);
			
			cm:set_saved_value("hunter_rodrik_unlocked", true);
			hunter_rodrik_unlocked = true;
			core:trigger_event("HunterUnlocked");			
				
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_join", wulfhart_faction);
				end,
				0.5
			);

			incident_key = "wh2_dlc13_wulfhart_rodrik_languille_stage_1_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_2") then
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_dilemma", wulfhart_faction);
				end,
				0.5
			);
		elseif mission_key:find("stage_3") then
			incident_key = "wh2_dlc13_wulfhart_rodrik_languille_3_incident";
			is_hunter_mission = true;
		elseif mission_key:find("stage_4") then
			cm:callback(
				function()
					cm:remove_effect_bundle("wh2_dlc13_payload_hunter_dilemma", wulfhart_faction);
				end,
				0.5
			);
		elseif mission_key:find("stage_5") then
			incident_key = "wh2_dlc13_wulfhart_rodrik_languille_5_incident";
			is_hunter_mission = true;
			cm:set_saved_value("hunter_rodrik_complete", true);
			core:trigger_event("ScriptEventHunterStoryCompleted");
		end;
		
	end
	
	--check if the incident key is an incdient or dilemma then trigger it
	if is_hunter_mission == true then
		cm:trigger_incident(wulfhart_faction, incident_key, true);
	end
end

--save/load functions
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("hunter_kalara_unlocked", hunter_kalara_unlocked, context);
		cm:save_named_value("hunter_kalara_complete", hunter_kalara_complete, context);
		cm:save_named_value("hunter_kalara_spawned", hunter_kalara_spawned, context);
		cm:save_named_value("hunter_jorek_unlocked", hunter_jorek_unlocked, context);
		cm:save_named_value("hunter_jorek_complete", hunter_jorek_complete, context);
		cm:save_named_value("hunter_jorek_spawned", hunter_jorek_spawned, context);
		cm:save_named_value("hunter_rodrik_unlocked", hunter_rodrik_unlocked, context);
		cm:save_named_value("hunter_rodrik_complete", hunter_rodrik_complete, context);
		cm:save_named_value("hunter_rodrik_spawned", hunter_rodrik_spawned, context);
		cm:save_named_value("hunter_hertwig_unlocked", hunter_hertwig_unlocked, context);
		cm:save_named_value("hunter_hertwig_complete", hunter_hertwig_complete, context);
		cm:save_named_value("hunter_hertwig_spawned", hunter_hertwig_spawned, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			hunter_kalara_unlocked = cm:load_named_value("hunter_kalara_unlocked", hunter_kalara_unlocked, context);
			hunter_kalara_complete = cm:load_named_value("hunter_kalara_complete", hunter_kalara_complete, context);
			hunter_kalara_spawned = cm:load_named_value("hunter_kalara_spawned", hunter_kalara_spawned, context);
			hunter_jorek_unlocked = cm:load_named_value("hunter_jorek_unlocked", hunter_jorek_unlocked, context);
			hunter_jorek_complete = cm:load_named_value("hunter_jorek_complete", hunter_jorek_complete, context);
			hunter_jorek_spawned = cm:load_named_value("hunter_jorek_spawned", hunter_jorek_spawned, context);
			hunter_rodrik_unlocked = cm:load_named_value("hunter_rodrik_unlocked", hunter_rodrik_unlocked, context);
			hunter_rodrik_complete = cm:load_named_value("hunter_rodrik_complete", hunter_rodrik_complete, context);
			hunter_rodrik_spawned = cm:load_named_value("hunter_rodrik_spawned", hunter_rodrik_spawned, context);
			hunter_hertwig_unlocked = cm:load_named_value("hunter_hertwig_unlocked", hunter_hertwig_unlocked, context);
			hunter_hertwig_complete = cm:load_named_value("hunter_hertwig_complete", hunter_hertwig_complete, context);
			hunter_hertwig_spawned = cm:load_named_value("hunter_hertwig_spawned", hunter_hertwig_spawned, context);
		end
	end
);