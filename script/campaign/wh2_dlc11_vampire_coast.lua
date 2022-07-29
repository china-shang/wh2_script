local harkon_faction = "wh2_dlc11_cst_vampire_coast"; 			--this variable is harkons faction name
local noctilus_faction = "wh2_dlc11_cst_noctilus";				--this variable is noctilus' faction name	
local noctilus_war_counter = 5;									--this variable counts how many turns until noctilus' next war declaration mission
local aranessa_faction = "wh2_dlc11_cst_pirates_of_sartosa";	--this variable is aranessas faction name

local vampire_coast_dilemma_faction_keys = {
	"wh2_dlc11_brt_bretonnia_dil",
	"wh2_dlc11_def_dark_elves_dil",
	"wh2_dlc11_emp_empire_dil",
	"wh2_dlc11_nor_norsca_dil"
};

local harkon_personality = {};
harkon_personality.turns_until_swap = 5;		--this variable will determine when harkons personality will swap
harkon_personality.current = "";				--harkons current personality
harkon_personality.new = "";					--harkons new personality
harkon_personality.restored = false;			--bool for if harkons mind is restored
harkon_personality.building_complete = false;	--bool for if harkons special building completed
harkon_personality.quest_complete = false;		--bool for if harkons quest chain completed

harkon_personality_index = {"mad", "hateful", "prideful", "coward", "restored", "lucid"};
harkon_personality_eventfeed_title = {	["mad"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_primery_detail",
										["hateful"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_primery_detail",
										["prideful"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_primery_detail",
										["coward"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_primery_detail", 
										["restored"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_primery_detail"
										};
harkon_personality_eventfeed_message = {	["mad"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_mad_secondary_detail",
										["hateful"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_hatred_secondary_detail",
										["prideful"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_prideful_secondary_detail",
										["coward"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_cowerd_secondary_detail",
										["restored"] = "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_lucid_secondary_detail"
										};
harkon_personality_events = {["mad"] = "wh2_dlc11_cst_harkon_mind_change_mad",
							["hateful"] = "wh2_dlc11_cst_harkon_mind_change_hateful",
							["prideful"] = "wh2_dlc11_cst_harkon_mind_change_prideful",
							["coward"] = "wh2_dlc11_cst_harkon_mind_change_coward",
							["restored"] = "wh2_dlc11_cst_harkon_mind_change_restored",
							["lucid"] = "wh2_dlc11_cst_harkon_mind_change_lucid"
							};
harkon_personality_dummies = {"wh2_dlc11_harkon_mind_dummy_coward",
							"wh2_dlc11_harkon_mind_dummy_hateful",
							"wh2_dlc11_harkon_mind_dummy_mad",
							"wh2_dlc11_harkon_mind_dummy_prideful",
							"wh2_dlc11_harkon_mind_dummy_lucid",
							"wh2_dlc11_harkon_mind_dummy_restored"
							};

local harpoon_location = {x = 1, y = 2};
local harpoon_faction = "";

function add_vampire_coast_listeners()
	out("#### Adding Vampire Coast Listeners ####");
	local harkon = cm:get_faction(harkon_faction);
	local noctilus = cm:get_faction(noctilus_faction);
	local aranessa = cm:get_faction(aranessa_faction);
	
	if cm:is_new_game() == true then
		--[[Harkon Personality Setup]]--
		harkon_personality.current = "mad";
		if harkon and harkon:is_human() == false then
			harkon_personality.new = "restored";
			harkon_personality_trait_replace();
			harkon_personality.restored = true;
		end
		
		if noctilus and noctilus:is_human() == true then
			local spawn_pos = {x = 0, y = 0};
			local unit_list = "wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_archers_0,wh2_main_hef_cav_ellyrian_reavers_0";
			
			if (cm:get_campaign_name() == "main_warhammer") then
				--spawn position for High Elf army Mortal Empires
				spawn_pos = {x = 272, y = 198};
			else
				--spawn position for High Elf army Vortex
				spawn_pos = {x = 337, y = 383};
			end;
			
			local noct_inv = invasion_manager:new_invasion("noct_inv", "wh2_main_hef_caledor", unit_list, spawn_pos);
			noct_inv:create_general(false,"wh2_main_hef_prince","names_name_2147360210","","","");
			noct_inv:start_invasion(
				function(self)
				--this needs to check for the campaign again because this mission is called from early_game for Vortex
					if (cm:get_campaign_name() == "main_warhammer") then
						cm:trigger_mission(noctilus_faction, "wh2_dlc11_noctilus_first_turn_mission", true);
					end;
				end,
				false, false, false);	
			
		elseif 	noctilus and noctilus:is_human() == false then
			if (cm:get_campaign_name() == "main_warhammer") then
				local noctilus_char = cm:get_closest_general_to_position_from_faction(noctilus_faction, 280, 190, true);
			
				if noctilus_char then
					cm:teleport_to(cm:char_lookup_str(noctilus_char), 151, 282, true);
				end;
				
				local units = {
					"wh2_dlc11_cst_inf_zombie_deckhands_mob_0",
					"wh2_dlc11_cst_inf_zombie_deckhands_mob_0",
					"wh2_dlc11_cst_inf_zombie_deckhands_mob_1",
					"wh2_dlc11_cst_inf_zombie_gunnery_mob_1",
					"wh2_dlc11_cst_inf_zombie_gunnery_mob_1"
				};
				
				for i = 1, #units do
					cm:grant_unit_to_character(cm:char_lookup_str(noctilus_char), units[i]);
				end;
				
			end;
		end
		
	end
	
	if harkon and harkon:is_human() == true then
		local mm_fractured_mind = mission_manager:new(harkon_faction, "wh2_dlc11_harkon_factured_mind_mission");
		mm_fractured_mind:set_mission_issuer("CLAN_ELDERS");
		mm_fractured_mind:add_new_scripted_objective(
			"mission_text_text_wh2_dlc11_harkon_fractured_mind_quest",
			"ScriptEventHarkonRestored",
			true
		);
		mm_fractured_mind:add_payload("effect_bundle{bundle_key wh2_dlc11_harkon_mind_dummy_restored;turns 0;}");
		
		core:add_listener(
			"harkon_personality_swap",
			"CharacterTurnStart",
			not harkon_personality.restored,
			function(context) harkon_personality_swap(context) end,
			true
		);

		cm:add_faction_turn_start_listener_by_name(
			"harkon_mission_add",
			harkon_faction,
			function(context)
				if cm:turn_number() == 5 then
					mm_fractured_mind:trigger();
					cm:remove_faction_turn_start_listener_by_name("harkon_mission_add");
				end;
			end,
			true
		);
		
		core:add_listener(
			"harkon_building_check",
			"BuildingCompleted",
			true,
			function(context) harkon_building_check(context) end,
			true
		);
		core:add_listener(
			"harkon_quest_check",
			"MissionSucceeded",
			true,
			function(context) harkon_quest_check(context) end,
			true
		);
		
		core:add_listener(
			"harkon_dummy_removal",
			"IncidentOccuredEvent",
			true,
			function(context)
				local incident = context:dilemma();
				cm:callback(function()
					for i = 1, #harkon_personality_index do
						if incident == harkon_personality_events[harkon_personality_index[i]] then
							for j = 1, #harkon_personality_dummies do
								cm:remove_effect_bundle(harkon_personality_dummies[j], harkon_faction);
							end;
						end;
					end;	
				end, 0.5);
			end,
			true
		);
	end
	
	if noctilus and noctilus:is_human() == true then
		cm:add_faction_turn_start_listener_by_name(
			"noctilus_war_mission",
			noctilus_faction,
			function(context)
				noctilus_war_mission(context)
			end,
			true
		);
	end
	
	if aranessa and aranessa:is_human() == true then
		core:add_listener(
			"aranessa_quest_spawn_army",
			"MissionIssued",
			true,
			function(context) aranessa_quest_spawn_army(context) end,
			true
		);
		core:add_listener(
			"aranessa_quest_stage_2",
			"MissionSucceeded",
			true,
			function(context) aranessa_quest_stage_2(context) end,
			true
		);
	end
	
	core:add_listener(
		"vampire_coast_dilemma_mission",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) vampire_coast_dilemma_mission(context) end,
		true
	);
	core:add_listener(
		"vampire_coast_dilemma_mission_over",
		"MissionSucceeded",
		true,
		function(context) vampire_coast_dilemma_mission_over(context) end,
		true
	);
	
	-- start a FactionTurnStart listener for each VC dilemma faction
	for i = 1, #vampire_coast_dilemma_faction_keys do
		cm:add_faction_turn_start_listener_by_name(
			"dilemma_end_point",
			vampire_coast_dilemma_faction_keys[i],
			function(context)
				dilemma_end_point(context)
			end,
			true
		);
	end;
	core:add_listener(
		"vampire_coast_CharacterGarrisonTargetAction",
		"CharacterGarrisonTargetAction",
		true,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				if context:agent_action_key() == "wh2_dlc11_agent_action_dignitary_hinder_settlement_establish_pirate_cove" then
					local agent_faction = context:character():faction():name();
					cm:remove_effect_bundle("wh2_dlc11_bundle_pirate_cove_created", agent_faction);
					cm:apply_effect_bundle("wh2_dlc11_bundle_pirate_cove_created", agent_faction, 15);
				end
			end
		end,
		true
	);
	
	-- clear action points and force-deselect when the search-for-treasure stance is adopted
	core:add_listener(
		"ForceAdoptsStance_Dig_For_Treasure",
		"ForceAdoptsStance",
		function(context) 
			return context:stance_adopted() == 11 and context:military_force():faction():culture() == "wh2_dlc11_cst_vampire_coast" and context:military_force():faction():is_human() == true;
		end,
		function(context) 
			local current_character = context:military_force():general_character():cqi();
			cm:zero_action_points(cm:char_lookup_str(current_character));
			
			-- clear the selection if it's the local player that has changed stance
			if context:military_force():faction():name() == cm:get_local_faction_name(true) then
				CampaignUI.ClearSelection();
			end;
		end,
		true
	);
	
	-- if the player is a Vampire Coast faction, then hide the ap bar when the cursor is placed over the search-for-treasure stance button 
	-- to give the impression that it will remove AP (which the script above actually does)
	local lf = cm:get_local_faction_name(true);
	if lf and cm:get_faction(lf):culture() == "wh2_dlc11_cst_vampire_coast" then
	
		local player_has_mouse_cursor_on_treasure_hunting_stance_button = false;
		local ap_component_names = {
			{
				name = "ap_bar",
				was_visible = false
			},
			{
				name = "ap_bar_cost",
				was_visible = false
			},
			{
				name = "ap_bar_insufficient",
				was_visible = false
			}
		};
		
		core:add_listener(
			"treasure_hunting_ap_zero_on_mouseover",
			"ComponentMouseOn",
			function(context)
				return not player_has_mouse_cursor_on_treasure_hunting_stance_button and context.string == "button_MILITARY_FORCE_ACTIVE_STANCE_TYPE_CHANNELING";
			end,
			function(context)
				-- player has place the mouse cursor over the Dig for Treasure stance		
				local uic_ap_parent = find_uicomponent(core:get_ui_root(), "primary_info_panel_holder", "info_panel_background", "CharacterInfoPopup", "action_points_parent");
				if uic_ap_parent then
					player_has_mouse_cursor_on_treasure_hunting_stance_button = true;
					
					for i = 1, #ap_component_names do
						local uic = find_uicomponent(uic_ap_parent, ap_component_names[i].name);
						if uic:Opacity() > 0 then
							uic:SetOpacity(0, false);
							ap_component_names[i].was_visible = true;
						else
							ap_component_names[i].was_visible = false;
						end;
					end;
					
					-- listen for the player moving the mouse cursor
					core:add_listener(
						"treasure_hunting_ap_zero_on_mouseover",
						"ComponentMouseOn",
						function(context)
							return context.string ~= "button_MILITARY_FORCE_ACTIVE_STANCE_TYPE_CHANNELING";
						end,
						function(context)
							player_has_mouse_cursor_on_treasure_hunting_stance_button = false;
							
							local uic_ap_parent = find_uicomponent(core:get_ui_root(), "primary_info_panel_holder", "info_panel_background", "CharacterInfoPopup", "action_points_parent");
							if uic_ap_parent then								
								for i = 1, #ap_component_names do
									local uic = find_uicomponent(uic_ap_parent, ap_component_names[i].name);
									if ap_component_names[i].was_visible then
										uic:SetOpacity(255, false);
									end;
								end;
							end;
						end,
						false
					);
				end;
			end,
			true
		);
	end;	
	
	-- not head to head
	if cm:model():campaign_type() ~= 2 then
		-- apply army abilities in the final battle
		core:add_listener(
			"final_battle_army_abilities",
			"PendingBattle",
			function()
				return harkon_qb_pending_battle_is_final_battle(cm:model():pending_battle());
			end,
			function()
				local pb = cm:model():pending_battle();
				
				local attacker = pb:attacker();
				local attacker_cqi = attacker:military_force():command_queue_index();
					
				out.design("Granting army abilities to attacker belonging to " .. attacker:faction():name());
					
				cm:apply_effect_bundle_to_force("wh2_dlc11_bundle_harkon_battle_army_abilities", attacker_cqi, 0);
				
			end,
			true
		);
	end;
	
	-- player completes the final battle
	core:add_listener(
		"final_battle_clean_up",
		"BattleCompleted",
		function()
			return harkon_qb_pending_battle_is_final_battle(cm:model():pending_battle());
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

			-- player has completed Harkons QB
			if attacker then
				-- remove army ability effect bundle
				cm:remove_effect_bundle_from_force("wh2_dlc11_bundle_harkon_battle_army_abilities", attacker:military_force():command_queue_index());
			end;
		end,
		true
	);
end

-- check if the pending battle is Harkons QB
function harkon_qb_pending_battle_is_final_battle(pb)	
	return pb:set_piece_battle_key():find("wh2_dlc11_qb_cst_harkon");
end;

function harkon_personality_swap(context) --function for checking if personality needs to be swapped for Harkon
	
	local character = context:character();
	
	if not character:character_subtype("wh2_dlc11_cst_harkon") then -- if factionturnstart is not for harkon skip
		return;
	end;
	
	if not character:is_null_interface() then --check harkon is alive, if he is not alive then do not change his personality
		
		harkon_personality.turns_until_swap =  harkon_personality.turns_until_swap - 1;
		
		if harkon_personality.turns_until_swap == 0 then
			
			local rand = cm:random_number(5); --random number between 0 and 5
			
			harkon_personality.turns_until_swap = 5 + rand; --next swap between 5 and 10 turns
			
			rand = cm:random_number(3); --random number for choosing personality 3 max as 4 possible pesonalities minus the current (so we dont get same personality twice)
			
			if harkon_personality.current == "coward" then
			
				if rand == 1 then
					harkon_personality.new = "mad";
				elseif rand == 2 then
					harkon_personality.new = "prideful";
				else 
					harkon_personality.new = "hateful";
				end;
				
			elseif harkon_personality.current == "mad" then 
				
				if rand == 1 then
					harkon_personality.new = "coward";
				elseif rand == 2 then
					harkon_personality.new = "prideful";
				else 
					harkon_personality.new = "hateful";
				end;
				
			elseif harkon_personality.current == "prideful" then 
				
				if rand == 1 then
					harkon_personality.new = "coward";
				elseif rand == 2 then
					harkon_personality.new = "mad";
				else 
					harkon_personality.new = "hateful";
				end;
				
			elseif harkon_personality.current == "hateful" then 
				
				if rand == 1 then
					harkon_personality.new = "coward";
				elseif rand == 2 then
					harkon_personality.new = "mad";
				else 
					harkon_personality.new = "prideful";
				end;
				
			end;

			harkon_personality_trait_replace();
		
		end;
		
	end;
	
end

function harkon_building_check(context) --function for checking if player has completed Harkons special building (requirement to restore his mind)
	if (harkon_faction == context:building():faction():name()) then --checks that completed building was for harkons faction
	
		if (context:building():name() == "wh2_dlc11_special_ancient_vault_2") then --checks the name of the completed building matches the required building key
			harkon_personality.building_complete = true;
			harkon_personality_restored();
		end;
		
	end;
	
end

function harkon_quest_check(context) --function for checking if player has completed Harkons quest chain (requirement to restore his mind)
	if (context:mission():mission_record_key() == "wh2_dlc11_cst_harkon_quest_for_slann_gold_stage_4") or 			--checking for ME mission key
	   (context:mission():mission_record_key() == "wh2_dlc11_cst_vortex_harkon_quest_for_slann_gold_stage_4")then 	--checking for Vortex mission key
		harkon_personality.quest_complete = true;
		harkon_personality_restored();
	end;
	
end

function harkon_personality_trait_replace() --function for replacing personality trait
	
	out.design("=====Personality Change=====");
	local faction = cm:get_faction(harkon_faction);
	local character = faction:faction_leader():command_queue_index();
	character = "character_cqi:"..tostring(character);
	
	local remove_trait = "wh2_dlc11_trait_harkon_personality_" .. harkon_personality.current;
	local remove_effect_bundle = "wh2_dlc11_harkon_mind_dummy_" .. harkon_personality.current;
		

	cm:disable_event_feed_events(true, "","wh_event_subcategory_character_traits","");
	cm:force_remove_trait(character, remove_trait);
	
	local add_trait = "wh2_dlc11_trait_harkon_personality_" .. harkon_personality.new;
	local add_effect_bundle = "wh2_dlc11_harkon_mind_dummy_" .. harkon_personality.new;

	cm:force_add_trait(character, add_trait, true, 1);
	cm:callback(function() cm:disable_event_feed_events(false, "","wh_event_subcategory_character_traits","") end, 1);
	--option 1 eventfeed
	-- cm:show_message_event_located(
						-- harkon_faction,
						-- "event_feed_strings_text_wh2_dlc11_event_feed_string_scripted_event_cst_harkon_mind_change_title",
						-- harkon_personality_eventfeed_title[harkon_personality.new],
						-- harkon_personality_eventfeed_message[harkon_personality.new],
						-- cm:get_faction(harkon_faction):faction_leader():logical_position_x(),
						-- cm:get_faction(harkon_faction):faction_leader():logical_position_y(),
						-- false,
						-- 1119
						-- );	
	--option 2 incidents
	if faction:is_human() then
		cm:trigger_incident(harkon_faction, harkon_personality_events[harkon_personality.new], true);
	end;
	
	harkon_personality.current = harkon_personality.new;
	
end

function harkon_personality_restored() --function for checking if all conditions met for harkons mind to be restored (if they are it will set his mind to restored)

	if ((harkon_personality.building_complete) and (harkon_personality.quest_complete)) then	--check if conditions met for personality restored
		harkon_personality.restored = true;			
		harkon_personality.new = "restored";
		harkon_personality_trait_replace();
		
		if (cm:get_campaign_name() == "main_warhammer") then
			cm:complete_scripted_mission_objective("wh_main_short_victory", "restore_harkon_mind", true);
			cm:complete_scripted_mission_objective("wh_main_long_victory", "restore_harkon_mind", true);
		end;
		out.design("ScriptEventHarkonRestored");
		core:trigger_event("ScriptEventHarkonRestored");
	end;

end

function noctilus_war_mission(context)
	
	noctilus_war_counter = noctilus_war_counter - 1;
	
	if (noctilus_war_counter <= 0) then
	
		local mission_payloads = {
			"wh2_dlc11_award_treasure_map",
			"wh2_dlc11_noctilus_war_armour_depth_guard",
			"wh2_dlc11_noctilus_war_leadership_infantry",
			"wh2_dlc11_noctilus_war_melee_attack_large",
			"wh2_dlc11_noctilus_war_melee_defence_zombies",
			"wh2_dlc11_noctilus_war_missile_damage_infantry",
			"wh2_dlc11_noctilus_war_physical_resist_zombies",
			"wh2_dlc11_noctilus_war_raiding",
			"wh2_dlc11_noctilus_war_replenishment",
			"wh2_dlc11_noctilus_war_sacking",
			"wh2_dlc11_noctilus_war_siege",
			"wh2_dlc11_noctilus_war_weapon_strength_depth_guard",
			"wh2_dlc11_noctilus_war_weapon_strength_large",
			"wh2_dlc11_noctilus_war_winds_of_magic"
		};
		
		local payload_effect = mission_payloads[cm:random_number(#mission_payloads)]; 
		
		local factions_list = context:faction():factions_met();
		local target_faction = "target";
		local target_list = {};
		
		for i=0, factions_list:num_items() - 1 do
			local target = factions_list:item_at(i);
			
			
			-- Exclude Noctilus' faction, factions Noctilus is already at war, Noctilus' allies and factions with no forces
			if (target:name() ~= noctilus_faction) 
				and (not target:at_war_with(cm:model():world():faction_by_key(noctilus_faction))) 
					and (not target:allied_with(cm:model():world():faction_by_key(noctilus_faction))) 
						and	(not target:military_force_list():is_empty())then
				
							target_faction = target:name();
							table.insert(target_list, target_faction);
			end
		end;
		
		if (target_faction ~= "target") then
			
			target_faction = target_list[cm:random_number(#target_list)];
			
			local mm = mission_manager:new(noctilus_faction, "wh2_dlc11_noctilus_declare_war");
			mm:set_mission_issuer("CLAN_ELDERS");
			mm:add_new_objective("DECLARE_WAR");
			mm:add_condition("faction " .. target_faction);
			mm:set_turn_limit(10);
			mm:add_payload("money 1500");
			if (payload_effect == "wh2_dlc11_award_treasure_map") then
				mm:add_payload("effect_bundle{bundle_key "..payload_effect..";turns 0;}");
			else
				mm:add_payload("effect_bundle{bundle_key "..payload_effect..";turns 10;}");
			end;
			
			mm:trigger();
			
			noctilus_war_counter = 10 + cm:random_number(10);
		end;
	end;
end

function aranessa_quest_spawn_army(context) --function to spawn Aranessa's stage 2 quest army
	
	local mission_key = context:mission():mission_record_key();
	
	--declaring following 4 variables for use if the correct mission is found
	local quest_faction = "wh2_dlc11_nor_norsca_qb4";
	local quest_unit_list = "wh_dlc08_nor_inf_marauder_berserkers_0,wh_dlc08_nor_inf_marauder_berserkers_0,wh_dlc08_nor_inf_marauder_berserkers_0,wh_dlc08_nor_inf_marauder_berserkers_0,wh_dlc08_nor_inf_marauder_champions_0,wh_dlc08_nor_inf_marauder_champions_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_dlc08_nor_inf_marauder_spearman_0,wh_dlc08_nor_inf_marauder_spearman_0";
	local quest_spawn_pos = {x = 0, y = 0};
	local quest_patrol = {{x = 1, y = 1}, {x = 0, y = 0}};
	local mission_check_bool = false;
	
	if (mission_key == "wh2_dlc11_cst_aranessa_krakens_bane_stage_1") then --checks the turn number then spawn army 		
		quest_spawn_pos = {x = 310, y = 555};
		quest_patrol = {{x = 363, y = 556}, {x = 310, y = 555}};
		mission_check_bool = true;
	elseif (mission_key == "wh2_dlc11_great_vortex_cst_aranessa_krakens_bane_stage_1") then
		quest_spawn_pos = {x = 716, y = 555};
		quest_patrol = {{x = 681, y = 535}, {x = 716, y = 555}};
		mission_check_bool = true;
	end;
	
	if (mission_check_bool) then
		out.design("Inside Invasion Spawner");
		--create new army for targeting before creating mission
		local quest_inv = invasion_manager:new_invasion("aranessa_quest_inv", quest_faction, quest_unit_list, quest_spawn_pos);
		quest_inv:set_target("PATROL", quest_patrol);
		quest_inv:add_aggro_radius(300, {aranessa_faction}, 5, 3);
		quest_inv:create_general(false, "nor_marauder_chieftain", "names_name_1010314968", "", "names_name_1341883665", "");
		quest_inv:start_invasion(nil,false,false,false);
		
		cm:force_diplomacy("all", "faction:"..quest_faction, "all", false, false, true);						--set all factions to not do diplomacy with inv faction
		cm:force_diplomacy("faction:"..quest_faction, "all", "all", false, false, true);						--set inv faction to not do diplomacy with all factions 
	end;	
	
end

function aranessa_quest_stage_2(context) --function for checking if Aranessa completed her first quest mission
	
	local faction = context:faction():name();
	local mission_key = context:mission():mission_record_key();
	local quest_stage_1 = false; --bool variable to check if the mission was the previous mission in quest chain
	
	local quest_faction = "wh2_dlc11_nor_norsca_qb4";

	if (mission_key == "wh2_dlc11_cst_aranessa_krakens_bane_stage_1") then --checks the name of the completed quest mission (Mortal Empires)
		mission_key = "wh2_dlc11_cst_aranessa_krakens_bane_stage_2";
		quest_stage_1 = true;
	elseif (mission_key == "wh2_dlc11_great_vortex_cst_aranessa_krakens_bane_stage_1") then --checks the name of the completed quest mission (Vortex)
		mission_key = "wh2_dlc11_great_vortex_cst_aranessa_krakens_bane_stage_2";
		quest_stage_1 = true;
	end;
	
	if (quest_stage_1 == true) then --check to see if one of the missions was completed
		
		cm:force_declare_war(aranessa_faction, quest_faction, true, true);										--force player to declare war on faction
		cm:trigger_mission(faction, mission_key, false);
		
	end;

end

function vampire_coast_dilemma_mission(context) --function for checking if scripted missions are being triggered
	local dilemma = context:dilemma(); 		--get the dilemma key from the context
	local choice = context:choice();		--get the choice integer from the context
	
	local faction = ""; 								--declaring variable that will be used inside and after following if-statement
	local unit_list = ""; 								--declaring variable used to list the army roster of spawned army
	local spawn_pos = {x = 0, y = 0}; 					--declaring variable for spawned army's origin point
	local patrol = {{x = 0, y = 0}, {x = 1, y = 1}};	--declaring array of 2 points for army to travel between
	local agent_subtype = "";
	local fore_name = "";
	local family_name = "";
	local inv_exp = 0;
	if dilemma:find("wh2_dlc11_cst_dilemma_ocean_of_opportunities") then	--check if the dilemma has attached scripted missions MORTAL EMPIRES CAMPAIGN
		if choice == (0) then --check to see if the first option has been selected
			faction = "wh2_dlc11_brt_bretonnia_dil";
			unit_list = "wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_men_at_arms_2,wh_dlc07_brt_inf_men_at_arms_2,wh_dlc07_brt_inf_peasant_bowmen_1,wh_dlc07_brt_inf_peasant_bowmen_1,wh_dlc07_brt_inf_peasant_bowmen_1,wh_main_brt_cav_grail_knights,wh_main_brt_cav_grail_knights,wh_main_brt_cav_grail_knights,wh_main_brt_cav_mounted_yeomen_1,wh_main_brt_cav_mounted_yeomen_1,wh_dlc07_brt_art_blessed_field_trebuchet_0";
			spawn_pos = {x = 352, y = 487};
			patrol = {{x = 398, y = 123}, {x = 352, y = 487}};
			
			agent_subtype = "brt_lord";
			fore_name = "names_name_1237536125"; --Fransiscus
			family_name = "names_name_2147345570"; --Mercier
			
			inv_exp = 5;
		elseif choice == (1) then --check to see if the second option has been selected
			faction = "wh2_dlc11_emp_empire_dil";
			unit_list = "wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_art_great_cannon,wh_main_emp_art_great_cannon,wh_main_emp_art_great_cannon,wh_main_emp_cav_reiksguard,wh_main_emp_cav_reiksguard,wh_main_emp_cav_reiksguard,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners";
			spawn_pos = {x = 80, y = 286};
			patrol = {{x = 458, y = 199}, {x = 80, y = 286}};
			
			agent_subtype = "emp_lord";
			fore_name = "names_name_2147355219"; --Lennard
			family_name = "names_name_2147351126"; --the Coin-Finger
			
			inv_exp = 7;
		elseif choice == (2) then --check to see if the third option has been selected
			faction = "wh2_dlc11_def_dark_elves_dil";
			unit_list = "wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_shades_0,wh2_main_def_inf_shades_0,wh2_main_def_inf_shades_0,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_mon_kharibdyss_0,wh2_dlc10_def_mon_kharibdyss_0,wh2_main_def_inf_harpies,wh2_main_def_inf_harpies,wh2_main_def_art_reaper_bolt_thrower";
			spawn_pos = {x = 272, y = 286};
			patrol = {{x = 214, y = 561}, {x = 272, y = 286}};	
			
			agent_subtype = "wh2_main_def_dreadlord";
			fore_name = "names_name_1225535785"; --Ramon
			family_name = "names_name_1231094167"; --Dreadtongue
			
			inv_exp = 7;
		elseif choice == (3) then --check to see if the fourth option has been selected
			faction = "wh2_dlc11_nor_norsca_dil";
			unit_list = "wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_1,wh_main_nor_inf_chaos_marauders_1,wh_dlc08_nor_inf_marauder_hunters_1,wh_dlc08_nor_inf_marauder_hunters_1,wh_dlc08_nor_inf_marauder_champions_0,wh_dlc08_nor_inf_marauder_champions_1";
			spawn_pos = {x = 550, y = 579};
			patrol = {{x = 354, y = 679}, {x = 550, y = 579}};	

			agent_subtype = "nor_marauder_chieftain";
			fore_name = "names_name_1060172250"; --Tarr
			family_name = "names_name_1414761431"; --Bonespear
			
			inv_exp = 3;
		end;
	elseif dilemma:find("wh2_dlc11_vor_cst_dilemma_ocean_of_opportunities") then --check if the dilemma has attached scripted missions VORTEX CAMPAIGN
		if choice == (0) then --check to see if the first option has been selected
			faction = "wh2_dlc11_brt_bretonnia_dil";
			unit_list = "wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_foot_squires_0,wh_dlc07_brt_inf_men_at_arms_2,wh_dlc07_brt_inf_men_at_arms_2,wh_dlc07_brt_inf_peasant_bowmen_1,wh_dlc07_brt_inf_peasant_bowmen_1,wh_dlc07_brt_inf_peasant_bowmen_1,wh_main_brt_cav_grail_knights,wh_main_brt_cav_grail_knights,wh_main_brt_cav_grail_knights,wh_main_brt_cav_mounted_yeomen_1,wh_main_brt_cav_mounted_yeomen_1,wh_dlc07_brt_art_blessed_field_trebuchet_0";
			spawn_pos = {x = 716, y = 541};
			patrol = {{x = 561, y = 341}, {x = 480, y = 427}};

			agent_subtype = "brt_lord";
			fore_name = "names_name_1237536125"; --Fransiscus
			family_name = "names_name_2147345570"; --Mercier

			inv_exp = 5;
		elseif choice == (1) then --check to see if the second option has been selected
			faction = "wh2_dlc11_emp_empire_dil";
			unit_list = "wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_greatswords,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_inf_halberdiers,wh_main_emp_art_great_cannon,wh_main_emp_art_great_cannon,wh_main_emp_art_great_cannon,wh_main_emp_cav_reiksguard,wh_main_emp_cav_reiksguard,wh_main_emp_cav_reiksguard,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners,wh_main_emp_inf_handgunners";
			spawn_pos = {x = 110, y = 342};
			patrol = {{x = 694, y = 398}, {x = 110, y = 342}};
			
			agent_subtype = "emp_lord";
			fore_name = "names_name_2147355219"; --Lennard
			family_name = "names_name_2147351126"; --the Coin-Finger	
			
			inv_exp = 7;
		elseif choice == (2) then --check to see if the third option has been selected
			faction = "wh2_dlc11_def_dark_elves_dil";
			unit_list = "wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_0,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_black_ark_corsairs_1,wh2_main_def_inf_shades_0,wh2_main_def_inf_shades_0,wh2_main_def_inf_shades_0,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_inf_sisters_of_slaughter,wh2_dlc10_def_mon_kharibdyss_0,wh2_dlc10_def_mon_kharibdyss_0,wh2_main_def_inf_harpies,wh2_main_def_inf_harpies,wh2_main_def_art_reaper_bolt_thrower";
			spawn_pos = {x = 465, y = 405};
			patrol = {{x = 331, y = 593}, {x = 465, y = 405}};			

			agent_subtype = "wh2_main_def_dreadlord";
			fore_name = "names_name_1225535785"; --Ramon
			family_name = "names_name_1231094167"; --Dreadtongue
			
			inv_exp = 7;
		elseif choice == (3) then --check to see if the fourth option has been selected
			faction = "wh2_dlc11_nor_norsca_dil";
			unit_list = "wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_1,wh_main_nor_inf_chaos_marauders_1,wh_dlc08_nor_inf_marauder_hunters_1,wh_dlc08_nor_inf_marauder_hunters_1,wh_dlc08_nor_inf_marauder_champions_0,wh_dlc08_nor_inf_marauder_champions_1";
			spawn_pos = {x = 649, y = 501};
			patrol = {{x = 414, y = 700}, {x = 649, y = 501}};	

			agent_subtype = "nor_marauder_chieftain";
			fore_name = "names_name_1060172250"; --Tarr
			family_name = "names_name_1414761431"; --Bonespear	
			
			inv_exp = 3;
		end;
	else --if neither of the wanted dilemmas then return before getting to rest of the function
		return;
	end;	
	
	local mission_key = dilemma .. "_" .. choice;
	local players_faction = context:faction():name();
	
	
	local invasion = invasion_manager:get_invasion("dil_inv");
	
	if (invasion ~=nil) then
		invasion_manager:kill_invasion_by_key("dil_inv");
	end;
	local dil_inv = invasion_manager:new_invasion("dil_inv", faction, unit_list, spawn_pos);
	dil_inv:set_target("PATROL", patrol);
	dil_inv:apply_effect("wh_main_reduced_movement_range_50",-1);
	dil_inv:create_general(false, agent_subtype, fore_name, "", family_name, "");
	dil_inv:add_unit_experience(inv_exp);
	dil_inv:start_invasion(
		function(self)
			cm:trigger_mission(players_faction, mission_key, true);
		end,
		false,false,false
	);
	
	cm:force_declare_war(context:faction():name(), faction, true, true);										--force player to declare war on faction
	cm:force_diplomacy("all", "faction:"..faction, "all", false, false, true); 									--set all factions to not do diplomacy with inv faction
	cm:force_diplomacy("faction:"..faction, "all", "all", false, false, true); 									--set inv faction to not do diplomacy with all factions 
	
end


function vampire_coast_dilemma_mission_over(context) --function is to make sure faction is destroyed after completing the mission
	
	local mission_key = context:mission():mission_record_key();
	
	if mission_key:find("cst_dilemma_ocean_of_opportunities") then --check completed mission has the right key
		local faction_key = ""; --variable for faction name
		
		--assign appropriate faction name based on mission_key
		if mission_key:find("cst_dilemma_ocean_of_opportunities_0") then 
			faction_key = "wh2_dlc11_brt_bretonnia_dil";
		elseif ("cst_dilemma_ocean_of_opportunities_1") then
			faction_key = "wh2_dlc11_emp_empire_dil";
		elseif ("cst_dilemma_ocean_of_opportunities_2") then
			faction_key = "wh2_dlc11_def_dark_elves_dil";
		elseif ("cst_dilemma_ocean_of_opportunities_3") then
			faction_key = "wh2_dlc11_nor_norsca_dil";
		end;
		cm:kill_all_armies_for_faction(cm:get_faction(faction_key)); --kill army for faction after mission completed
	elseif mission_key:find("aranessa_krakens_bane_stage_2") then --check completed mission has Aranessas mission key
		cm:kill_all_armies_for_faction(cm:get_faction("wh2_dlc11_nor_norsca_qb4")); --kill army for faction after mission completed
	end;

end

function dilemma_end_point(context) --function to check that the dilemma army has arrive at their destination, if they have kill htme and abort mission
	
	local faction = context:faction():name();
	
	local army = context:faction():military_force_list():item_at(0);				--get the army (there is only 1 so it is always at position 0 in list)
	local army_position_x = army:general_character():logical_position_x();			--get army's x coordinate
	local army_position_y = army:general_character():logical_position_y();			--get army's y coordinate

	local target_x = 0;
	local target_y = 0;
	
	--assigns the target x and y coordinate based on campaign and faction
	if (cm:get_campaign_name() == "main_warhammer") then
	
		if faction == "wh2_dlc11_brt_bretonnia_dil" then
			target_x = 398;
			target_y = 123;
		elseif faction == "wh2_dlc11_emp_empire_dil" then
			target_x = 458;
			target_y = 199;	
		elseif faction == "wh2_dlc11_def_dark_elves_dil" then
			target_x = 214;
			target_y = 561;	
		elseif faction == "wh2_dlc11_nor_norsca_dil" then
			target_x = 354;
			target_y = 679;	
		end;
	
	else
	
		if faction == "wh2_dlc11_brt_bretonnia_dil" then
			target_x = 561;
			target_y = 341;
		elseif faction == "wh2_dlc11_emp_empire_dil" then
			target_x = 694;
			target_y = 398;
		elseif faction == "wh2_dlc11_def_dark_elves_dil" then
			target_x = 331;
			target_y = 593;	
		elseif faction == "wh2_dlc11_nor_norsca_dil" then
			target_x = 414;
			target_y = 700;	
		end;
		
	end;
	
	--distance from army to target = sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
	local distance_x = math.pow(army_position_x - target_x, 2);
	local distance_y = math.pow(army_position_y - target_y, 2);
		
	local distance_to_target = math.sqrt(distance_x + distance_y);
	
	if (distance_to_target <= 1) then --less than 1 as that mean its at the location
		
		cm:kill_all_armies_for_faction(cm:get_faction(faction));
		
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("harkon_personality", harkon_personality, context);
		cm:save_named_value("noctilus_war_counter", noctilus_war_counter, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		harkon_personality = cm:load_named_value("harkon_personality", harkon_personality, context);
		noctilus_war_counter = cm:load_named_value("noctilus_war_counter", noctilus_war_counter, context);
	end
);