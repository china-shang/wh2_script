local skaven_under_empire_initial_amount = 3;
local skaven_under_empire_cooldown = 10;
local skaven_under_empire_ruins = {};
local skaven_under_empire_doomspheres = {};
local skaven_under_empire_spawn_weights = {
	subcultures = {
		["wh_main_sc_dwf_dwarfs"] = 5,
		["wh_main_sc_grn_greenskins"] = 4,
		["wh_main_sc_grn_savage_orcs"] = 3,
		["wh_main_sc_emp_empire"] = 2,
		["wh_main_sc_ksl_kislev"] = 1,
		["wh_main_sc_teb_teb"] = 1,
		["wh_main_sc_brt_bretonnia"] = 1,
		["wh2_main_sc_lzd_lizardmen"] = 1,
		["wh2_main_sc_def_dark_elves"] = 1
	},
	climates = {
		["climate_mountain"] = 3,
		["climate_jungle"] = 2,
		["climate_wasteland"] = 1,
		["climate_savannah"] = 1,
		["climate_chaotic"] = 1,
		["climate_desert"] = 1,
		["climate_temperate"] = 1,
		["climate_frozen"] = 1,
		["climate_ocean"] = 0,
		["climate_island"] = 0,
		["climate_magicforest"] = 0
	}
};

function add_under_empire_listeners()
	out("#### Adding Under-Empire Listeners ####");
	core:add_listener(
		"underempire_CharacterGarrisonTargetAction",
		"CharacterGarrisonTargetAction",
		true,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				if context:agent_action_key():find("settlement_expand_underempire") then
					local agent_faction = context:character():faction();
					local faction_key = agent_faction:name();
					
					local actual_cooldown = skaven_under_empire_cooldown;
					
					if cm:model():campaign_name("main_warhammer") then
						local skavenblight = cm:model():world():region_manager():region_by_key("wh2_main_skavenblight_skavenblight");
						
						if skavenblight:is_null_interface() == false then
							local owner = skavenblight:owning_faction();
							
							if owner:is_null_interface() == false then
								if owner:name() == faction_key then
									if skavenblight:building_exists("wh2_main_special_skavenblight_shattered_tower") then
										actual_cooldown = actual_cooldown - 5;
									end
								end
							end
						end
					end
					
					cm:remove_effect_bundle("wh2_dlc12_bundle_underempire_cooldown", faction_key);
					cm:apply_effect_bundle("wh2_dlc12_bundle_underempire_cooldown", faction_key, actual_cooldown);
					core:trigger_event("ScriptEventPlayerUnderEmpireEstablished");
				end
			end
		end,
		true
	);
	core:add_listener(
		"underempire_FactionBeginTurnPhaseNormal",
		"FactionBeginTurnPhaseNormal",
		function(context)
			return context:faction():culture() == "wh2_main_skv_skaven";
		end,
		function(context)
			local faction = context:faction();
			local faction_key = faction:name();
			
			local skaven_under_empire_turn_cutscene = true;
			local skaven_under_empire_turn_count = 0;
			local skaven_under_empire_advice = false;
			
			local first_nuke = true;
			local first_nuke_pos_x = 0;
			local first_nuke_pos_y = 0;
			
			local under_empires = faction:foreign_slot_managers();
			
			for i = 0, under_empires:num_items() - 1 do
				local under_empire = under_empires:item_at(i);
			
				local region = under_empire:region();
				local region_key = region:name();
				local region_owner = region:owning_faction();
				local region_owner_key = region_owner:name();
				local is_under_empire_human = faction:is_human();
				local is_region_owner_human = region_owner:is_human();
				local settlement = region:settlement();
				local settlement_x = settlement:logical_position_x();
				local settlement_y = settlement:logical_position_y();
				
				for j = 0, under_empire:num_slots() - 1 do
					local slot = under_empire:slots():item_at(j);
					
					if slot:is_null_interface() == false and slot:has_building() == true then
						local building_key = slot:building();

						if building_key == "wh2_dlc12_under_empire_annexation_doomsday_2" then
							-- Limit Doomsphere VFX to distance from cutscene
							local show_vfx = false;
							
							if first_nuke == true then
								first_nuke = false;
								show_vfx = true;
								first_nuke_pos_x = settlement_x;
								first_nuke_pos_y = settlement_y;
							else
								local distance_to_first_nuke = distance_squared(settlement_x, settlement_y, first_nuke_pos_x, first_nuke_pos_y);
								
								if distance_to_first_nuke <= 8000 then
									show_vfx = true;
								end
							end
						
							-- Detonate Doomsphere
							under_empire_detonate_nuke(region, skaven_under_empire_turn_cutscene, show_vfx, skaven_under_empire_turn_count, faction_key, region_owner_key);
							skaven_under_empire_turn_cutscene = false;
							skaven_under_empire_turn_count = skaven_under_empire_turn_count + 1;
							
							-- Doomsphere detonated advice
							if skaven_under_empire_advice == false then
								if is_under_empire_human == true then
									skaven_under_empire_advice = true;
									core:trigger_event("ScriptEventUnderEmpireDoomsphereCompleted", region);
								elseif is_region_owner_human == true then
									skaven_under_empire_advice = true;
									core:trigger_event("ScriptEventUnderEmpireAIDoomsphereCompleted", region);
								end
							end
							break;
						elseif building_key == "wh2_dlc12_under_empire_annexation_doomsday_1" then
							-- Doomsphere build advice
							if skaven_under_empire_advice == false then
								if is_under_empire_human == true then
									skaven_under_empire_advice = true;
									core:trigger_event("ScriptEventUnderEmpireDoomsphereStarted", region);
								end
							end
						elseif building_key == "wh2_dlc12_under_empire_annexation_war_camp_2" then
							-- Spawn Warcamp army
							under_empire_war_camp_created(region_key, faction);
							
							-- Warcamp Advice
							if skaven_under_empire_advice == false then
								if is_under_empire_human == true then
									skaven_under_empire_advice = true;
									core:trigger_event("ScriptEventUnderEmpirePlayerWarCamp", region);
								elseif is_region_owner_human == true then
									skaven_under_empire_advice = true;
									core:trigger_event("ScriptEventUnderEmpireAIWarCamp", region);
								end
							end
							break;
						elseif building_key == "wh2_dlc14_under_empire_annexation_plague_cauldron_2" then
							-- Spawn Plague Priest
							under_empire_plague_cauldron_created(faction, region);
						end
					end
				end
			end
		end,
		true
	);
	core:add_listener(
		"underempire_GarrisonOccupiedEvent",
		"GarrisonOccupiedEvent",
		true,
		function(context)
			local region_key = context:garrison_residence():region():name();
			
			if skaven_under_empire_ruins[region_key] ~= nil then
				if context:character():faction():culture() ~= "wh2_main_skv_skaven" then
					cm:override_building_chain_display(skaven_under_empire_ruins[region_key][1], skaven_under_empire_ruins[region_key][1], region_key);
					cm:override_building_chain_display(skaven_under_empire_ruins[region_key][2], skaven_under_empire_ruins[region_key][2], region_key);
					skaven_under_empire_ruins[region_key] = nil;
				end
			end
		end,
		true
	);
	core:add_listener(
		"underempire_ForeignSlotManagerDiscoveredEvent",
		"ForeignSlotManagerDiscoveredEvent",
		true,
		function(context)
			under_empire_discovered(context);
		end,
		true
	);
	core:add_listener(
		"underempire_ForeignSlotManagerRemovedEvent",
		"ForeignSlotManagerRemovedEvent",
		true,
		function(context)
			under_empire_destroyed(context);
		end,
		false
	);
	core:add_listener(
		"underempire_CharacterTurnStart",
		"CharacterTurnStart",
		function(context)
			local character = context:character();
			
			-- Are they an agent in a region and not in an army?
			if character:has_military_force() == false and character:character_type("general") == false and character:character_type("colonel") and character:is_politician() == false and character:has_region() == true then
				local region = character:region();
				
				-- Is this region occupied and owned by the agents faction?
				if region:is_null_interface() == false and region:is_abandoned() == false and region:owning_faction():name() == character:faction():name() then
					local foreign_slots = region:foreign_slot_managers();
					
					-- Does it have any foreign slots in it?
					for i = 0, foreign_slots:num_items() - 1 do
						local foreign_slot = foreign_slots:item_at(i);
						
						-- Is this foreign slot still hidden?
						if foreign_slot:is_null_interface() == false and region:owning_faction():is_null_interface() == false and foreign_slot:has_been_discovered(region:owning_faction():command_queue_index()) == false then
							-- Does it belong to a human Skaven?
							if foreign_slot:faction():is_human() == true and foreign_slot:faction():culture() == "wh2_main_skv_skaven" then
								-- Is this agents faction different to the foreign slots faction?
								if foreign_slot:faction():name() ~= character:faction():name() then
									return true;
								end
							end
						end
					end
				end
			end
			return false;
		end,
		function(context)
			local character = context:character();
			core:trigger_event("ScriptEventUnderEmpireAgentInRegion", character);
		end,
		false
	);
	core:add_listener(
		"underempire_RegionPlagueStateChanged",
		"RegionPlagueStateChanged",
		true,
		function(context)
			underempire_RegionPlagueStateChanged(context);
		end,
		true
	);

	if cm:is_new_game() == true then
		if cm:model():campaign_name("main_warhammer") == true then
			-- Under-City - Karak Eight Peaks - Clan Mors
			local clan_mors = cm:model():world():faction_by_key("wh2_main_skv_clan_mors");
			local clan_mors_cqi = clan_mors:command_queue_index();
			local eight_peaks = cm:model():world():region_manager():region_by_key("wh_main_eastern_badlands_karak_eight_peaks");
			local eight_peaks_cqi = eight_peaks:cqi();
			cm:add_foreign_slot_set_to_region_for_faction(clan_mors_cqi, eight_peaks_cqi, "wh2_dlc12_slot_set_underempire");
			cm:make_region_visible_in_shroud("wh2_main_skv_clan_mors", "wh_main_eastern_badlands_karak_eight_peaks");
			
			local fsm_clan_mors = clan_mors:foreign_slot_managers();

			if fsm_clan_mors:num_items() > 0 then
				local first_fsm_slots = clan_mors:foreign_slot_managers():item_at(0):slots();

				if first_fsm_slots:num_items() > 0 then
					local fslot = first_fsm_slots:item_at(0);

					if clan_mors:is_human() == true then
						cm:foreign_slot_instantly_upgrade_building(fslot, "wh2_dlc12_under_empire_settlement_warren_5");
					else
						cm:foreign_slot_instantly_upgrade_building(fslot, "wh2_dlc12_under_empire_discovery_deeper_tunnels_1");
					end;
				else
					script_error("WARNING: attempting to adjust Clan Mors foreign slots at the start of a new game but first foreign slot manager has no slots");
				end;
			else
				script_error("WARNING: attempting to adjust Clan Mors foreign slots at the start of a new game but no foreign slot managers were found");
			end;

			-- Under-City - Crookback Mountain - Clan Rictus
			local faction_clan_rictus = cm:model():world():faction_by_key("wh2_dlc09_skv_clan_rictus");
			local faction_clan_rictus_cqi = faction_clan_rictus:command_queue_index();
			local region_crookback_mountain = cm:model():world():region_manager():region_by_key("wh2_main_the_wolf_lands_crookback_mountain");
			local region_crookback_mountain_cqi = region_crookback_mountain:cqi();
			cm:add_foreign_slot_set_to_region_for_faction(faction_clan_rictus_cqi, region_crookback_mountain_cqi, "wh2_dlc12_slot_set_underempire");
			cm:make_region_visible_in_shroud("wh2_dlc09_skv_clan_rictus", "wh2_main_the_wolf_lands_crookback_mountain");
			
			local fsm_clan_rictus = faction_clan_rictus:foreign_slot_managers();

			if fsm_clan_rictus:num_items() > 0 then
				local first_fsm_slots = faction_clan_rictus:foreign_slot_managers():item_at(0):slots();

				if first_fsm_slots:num_items() > 0 then
					local fslot = first_fsm_slots:item_at(0);
						cm:foreign_slot_instantly_upgrade_building(fslot, "wh2_dlc12_under_empire_discovery_deeper_tunnels_1");
				else
					script_error("WARNING: attempting to adjust Clan Rictus foreign slots at the start of a new game but first foreign slot manager has no slots");
				end;
			else
				script_error("WARNING: attempting to adjust Clan Rictus foreign slots at the start of a new game but no foreign slot managers were found");
			end;
			
			if cm:model():random_percent(35) then
				-- Under-City - Altdorf - Clan Moulder
				local altdorf = cm:model():world():region_manager():region_by_key("wh_main_reikland_altdorf");
				
				if altdorf:owning_faction():is_human() == true then
					local clan_moulder = cm:model():world():faction_by_key("wh2_main_skv_clan_moulder");

					if clan_moulder:is_human() == false then
						local clan_moulder_cqi = clan_moulder:command_queue_index();
						local altdorf_cqi = altdorf:cqi();
						cm:add_foreign_slot_set_to_region_for_faction(clan_moulder_cqi, altdorf_cqi, "wh2_dlc12_slot_set_underempire");
						cm:make_region_visible_in_shroud("wh2_main_skv_clan_moulder", "wh_main_reikland_altdorf");
						
						local fslots = clan_moulder:foreign_slot_managers():item_at(0):slots();
						local fslot_1 = fslots:item_at(0);
						cm:foreign_slot_instantly_upgrade_building(fslot_1, "wh2_dlc12_under_empire_discovery_deeper_tunnels_1");
					end
				end
			else
				if cm:model():random_percent(20) then
					-- Under-City - Ubersreik - Clan Skyre
					local clan_skyre = cm:model():world():faction_by_key("wh2_main_skv_clan_skyre");
					
					if clan_skyre:is_human() == false then
						local clan_skyre_cqi = clan_skyre:command_queue_index();
						local ubersreik = cm:model():world():region_manager():region_by_key("wh_main_reikland_helmgart");
						local ubersreik_cqi = ubersreik:cqi();
						cm:add_foreign_slot_set_to_region_for_faction(clan_skyre_cqi, ubersreik_cqi, "wh2_dlc12_slot_set_underempire");
						cm:make_region_visible_in_shroud("wh2_main_skv_clan_skyre", "wh_main_reikland_helmgart");
						
						local fslots = clan_skyre:foreign_slot_managers():item_at(0):slots();
						local fslot_1 = fslots:item_at(0);
						cm:foreign_slot_instantly_upgrade_building(fslot_1, "wh2_dlc12_under_empire_discovery_deeper_tunnels_1");
					end
				end
			end
			
			-- Overwrite Mordheim ruin in ME
			local region_key = "wh_main_ostermark_mordheim";
			local region = cm:model():world():region_manager():region_by_key(region_key);
			local display_chain = region:settlement():display_primary_building_chain();
			local building_chain = region:settlement():primary_building_chain();
			cm:override_building_chain_display(display_chain, "wh2_dlc12_dummy_nuclear_ruins", region_key);
			cm:override_building_chain_display(building_chain, "wh2_dlc12_dummy_nuclear_ruins", region_key);
			skaven_under_empire_ruins[region_key] = {display_chain, building_chain};
		end
		
		if skaven_under_empire_initial_amount > 0 then
			spawn_random_under_empire(skaven_under_empire_initial_amount);
		end
	else
		local region_list = cm:model():world():region_manager():region_list();

		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			local region_key = current_region:name();
			cm:remove_scripted_composite_scene("doomsphere_"..region_key);
		end
	end
end

function spawn_random_under_empire(spawn_amount)
	local possible_regions = weighted_list:new();
	local region_list = cm:model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		
		if current_region:foreign_slot_managers():is_empty() == true then
			local subculture_bonus = skaven_under_empire_spawn_weights.subcultures[current_region:owning_faction():subculture()] or 0;
			local climate_bonus = skaven_under_empire_spawn_weights.climates[current_region:settlement():get_climate()] or 0;
			
			-- Not owned by Skaven subculture
			if subculture_bonus > 0 then
				local weight = subculture_bonus + climate_bonus;
				possible_regions:add_item(current_region, weight);
			end
		end
	end
	
	local faction_list = cm:model():world():faction_list();
	local skaven_ai_factions = {};
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:is_human() == false and faction:subculture() == "wh2_main_sc_skv_skaven" then
			table.insert(skaven_ai_factions, faction);
		end
	end
	
	if #skaven_ai_factions > 0 then
		for i = 1, spawn_amount do
			local region, index = possible_regions:weighted_select();
			local pos_x = region:settlement():logical_position_x();
			local pos_y = region:settlement():logical_position_y();
			local closest_skaven = skaven_ai_factions[1];
			local closest_region = 9999999;
			
			for j = 1, #skaven_ai_factions do
				local faction = skaven_ai_factions[j];
				local region_list = faction:region_list();
				
				for k = 0, region_list:num_items() - 1 do
					local current_region = region_list:item_at(k);
					local reg_pos_x = current_region:settlement():logical_position_x();
					local reg_pos_y = current_region:settlement():logical_position_y();
					
					local distance = distance_squared(pos_x, pos_y, reg_pos_x, reg_pos_y);
					
					if distance < closest_region then
						closest_skaven = skaven_ai_factions[j];
						closest_region = distance;
					end
				end
			end
			
			local skv_cqi = closest_skaven:command_queue_index();
			local reg_cqi = region:cqi();
			out("spawn_random_under_empire - "..region:name().." for "..closest_skaven:name());
			cm:add_foreign_slot_set_to_region_for_faction(skv_cqi, reg_cqi, "wh2_dlc12_slot_set_underempire");
			cm:make_region_visible_in_shroud(closest_skaven:name(), region:name());
			possible_regions:remove_item(index);
		end
	end
end

function under_empire_war_camp_created(region_key, faction)
	local faction_key = faction:name();
	out("under_empire_war_camp_created("..region_key..", "..faction_key..")");
	local ram = random_army_manager;
	ram:remove_force("skaven_warcamp");
	ram:new_force("skaven_warcamp");
	
	local melee_unit_key = "wh2_main_skv_inf_clanrats_1";
	local spear_unit_key = "wh2_main_skv_inf_clanrat_spearmen_1";
	
	if faction:has_technology("tech_skv_9_2") == true then
		melee_unit_key = "wh2_main_skv_inf_stormvermin_1";
		spear_unit_key = "wh2_main_skv_inf_stormvermin_0";
	end
	
	-- Standard Army
	ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 3);
	ram:add_mandatory_unit("skaven_warcamp", spear_unit_key, 2);
	ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_inf_plague_monks", 2);
	ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_mon_rat_ogres", 1);
	ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_art_plagueclaw_catapult", 1);
	
	-- Extra Clanrat Units
	if faction:has_technology("tech_skv_4_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	if faction:has_technology("tech_skv_5_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	if faction:has_technology("tech_skv_6_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	if faction:has_technology("tech_skv_7_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	if faction:has_technology("tech_skv_8_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	if faction:has_technology("tech_skv_9_0") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	-- Extra Plague Monk
	if faction:has_technology("tech_skv_5_2") == true then
		ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_inf_plague_monks", 1);
	end
	-- Extra Hell Pit Abomination
	if faction:has_technology("tech_skv_4_3") == true then
		ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_mon_hell_pit_abomination", 1);
	end
	-- Extra Plagueclaw Catapult
	if faction:has_technology("tech_skv_6_1") == true then
		ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_art_plagueclaw_catapult", 1);
	end
	-- Extra Doomwheel
	if faction:has_technology("tech_skv_8_3") == true then
		ram:add_mandatory_unit("skaven_warcamp", "wh2_main_skv_veh_doomwheel", 1);
	end
	-- DLC14 check for clan Eshin specific tech variant
	if faction:has_technology("tech_skv_8_0_eshin") == true then
		ram:add_mandatory_unit("skaven_warcamp", melee_unit_key, 1);
	end
	
	local unit_count = random_army_manager:mandatory_unit_count("skaven_warcamp");
	local spawn_units = random_army_manager:generate_force("skaven_warcamp", unit_count, false);
	local pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_settlement(faction_key, region_key, false, true, 9);
	
	local faction = cm:model():world():faction_by_key(faction_key);
	local region = cm:model():world():region_manager():region_by_key(region_key);
	local faction_cqi = faction:command_queue_index();
	local region_cqi = region:cqi();
	
	local faction_key = faction:name();
	local region_owner = region:owning_faction();
	local region_owner_key = region_owner:name();
	
	local settlement_x = region:settlement():logical_position_x();
	local settlement_y = region:settlement():logical_position_y();
	
	if pos_x > -1 then
		cm:create_force(
			faction_key,
			spawn_units,
			region_key,
			pos_x,
			pos_y,
			true,
			function(cqi)
				cm:apply_effect_bundle_to_characters_force("wh2_dlc12_bundle_underempire_army_spawn", cqi, 5, true);
				cm:add_character_vfx(cqi, "scripted_effect20", false);
			end
		);
		
		-- Declare War
		if cm:model():is_multiplayer() == false or (cm:model():is_multiplayer() == true and faction:allied_with(region_owner) == false) then
			cm:force_declare_war(faction_key, region_owner_key, false, false);
		end
		-- Destroy Under-City
		cm:remove_faction_foreign_slots_from_region(faction_cqi, region_cqi);
		
		-- Tell the army owner
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_warcamp_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_warcamp_description",
			settlement_x, settlement_y,
			true,
			121
		);
		-- Tell the region owner
		cm:show_message_event_located(
			region_owner_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_warcamp_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_warcamp_description_target",
			settlement_x, settlement_y,
			true,
			121
		);
	end
end

function underempire_RegionPlagueStateChanged(context)
	local region = context:region();
	local region_key = region:name();

	if context:is_infected() == true then
		under_empire_plagues[region_key] = true;
	else
		under_empire_plagues[region_key] = nil;
	end
end

function under_empire_plague_cauldron_created(faction, region)
	local region_key = region:name();

	if under_empire_plagues[region_key] == nil then
		local faction_key = faction:name();
		local settlement = region:settlement();
		local settlement_x = settlement:logical_position_x();
		local settlement_y = settlement:logical_position_y();
		local region_owner = region:owning_faction();
		local region_owner_key = region_owner:name();

		cm:spawn_plague_at_settlement(settlement, "wh2_main_plague_skaven");
		
		-- Tell the plague owner
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_plague_cauldron_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_plague_cauldron_description",
			settlement_x, settlement_y,
			true,
			125
		);
		-- Tell the region owner
		cm:show_message_event_located(
			region_owner_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_plague_cauldron_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_plague_cauldron_description_target",
			settlement_x, settlement_y,
			true,
			125
		);
	end
end

function under_empire_discovered(context)
	local faction = context:owner();

	if faction:culture() == "wh2_main_skv_skaven" then
		local region = context:slot_manager():region();
		local region_key = region:name();
		local settlement_x = region:settlement():logical_position_x();
		local settlement_y = region:settlement():logical_position_y();
		
		local faction_key = faction:name();
		local region_owner = context:discoveree();
		local region_owner_key = region_owner:name();
		
		-- Tell the Under-City owner
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_discovered_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_discovered_description",
			settlement_x, settlement_y,
			false,
			122
		);
		-- Tell the region owner
		cm:show_message_event_located(
			region_owner_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_discovered_title",
			"regions_onscreen_"..region_key,
			"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_discovered_description_target",
			settlement_x, settlement_y,
			false,
			122
		);
		
		if faction:is_human() == true then
			core:trigger_event("ScriptEventUnderEmpirePlayerDiscovered", region);
		end
		if region_owner:is_human() == true then
			core:trigger_event("ScriptEventUnderEmpireAIDiscovered", region);
		end
	end
end

function under_empire_destroyed(context)
	local owner = context:owner();

	if owner:culture() == "wh2_main_skv_skaven" then
		local owner_key = owner:name();
		local remover = context:remover():name();
		local region = context:region();
		local region_key = region:name();
		local settlement_x = region:settlement():logical_position_x();
		local settlement_y = region:settlement():logical_position_y();
		
		if context:cause_was_razing() == true then
			-- Tell the Under-City owner their region was razed
			cm:show_message_event_located(
				owner_key,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_title",
				"regions_onscreen_"..region_key,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_razing_description",
				settlement_x, settlement_y,
				false,
				124
			);
		else
			-- Tell the Under-City owner they were removed
			cm:show_message_event_located(
				owner_key,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_title",
				"regions_onscreen_"..region_key,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_description",
				settlement_x, settlement_y,
				false,
				124
			);
			-- Tell the region owner they removed an Under-City
			cm:show_message_event_located(
				remover,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_title",
				"regions_onscreen_"..region_key,
				"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_destroyed_remover_description",
				settlement_x, settlement_y,
				false,
				124
			);
		end
		
		if context:remover():is_human() == true and context:cause_was_razing() == false then
			core:trigger_event("ScriptEventUnderEmpireRemovedByPlayer", region);
		end
	end
end

function under_empire_detonate_nuke(region, show_cutscene, show_vfx, timeout, nuke_owner, region_owner)
	local show_cutscene_local = cm:get_local_faction_name(true) == nuke_owner;
	
	if cm:model():is_multiplayer() == false then
		local fade_in_time = 1;
		local pause_after_fade_before_vfx = 0.5;
		local vfx_play_time = 4;
		local fade_out_time = 3;
		
		if show_cutscene == false then
			-- Pause all non-focused nukes so they don't happen before the cutscene one
			cm:callback(function()
				under_empire_nuke_region(region, nuke_owner, region_owner, show_vfx);
			end, fade_in_time + fade_in_time + pause_after_fade_before_vfx + 0.5 + timeout);
		else
			local x, y, d, b, h = cm:get_camera_position();
			local pos_x = region:settlement():display_position_x();
			local pos_y = region:settlement():display_position_y();
			cm:make_region_visible_in_shroud(nuke_owner, region:name());
			
			if show_cutscene_local == true then
				cm:steal_user_input(true);
				cm:fade_scene(0, fade_in_time);
			end
			
			cm:callback(function() -- 1.0s
				if show_cutscene_local == true then
					cm:scroll_camera_with_direction(true, vfx_play_time * 2, {pos_x, pos_y, 24.23, 0.0, 21.1}, {pos_x, pos_y + 4, 31.78, 0.0, 41.04});
					CampaignUI.ToggleCinematicBorders(true);
					cm:fade_scene(1, fade_in_time);
				end
				
				cm:callback(function() -- 1.5s
					under_empire_nuke_region(region, nuke_owner, region_owner, show_vfx);
					
					if show_cutscene_local == true then
						cm:callback(function() -- 4.0s
							cm:fade_scene(0, fade_out_time);
							
							cm:callback(function() -- 3.0s
								cm:steal_user_input(false);
								cm:set_camera_position(x, y, d, b, h);
								CampaignUI.ToggleCinematicBorders(false);
								cm:fade_scene(1, fade_in_time);
							end, fade_out_time);
						end, vfx_play_time);
					end
				end, fade_in_time + pause_after_fade_before_vfx);
			end, fade_in_time);
		end
	else
		if show_cutscene == true and show_cutscene_local == true then
			local pos_x = region:settlement():display_position_x();
			local pos_y = region:settlement():display_position_y();
			cm:set_camera_position(pos_x, pos_y, 24.23, 0.0, 21.1);
		end
		under_empire_nuke_region(region, nuke_owner, region_owner, show_vfx);
	end
end

function under_empire_nuke_region(region, nuke_owner, region_owner, show_vfx)
	local region_key = region:name();
	local region_cqi = region:cqi();
	local settlement_x = region:settlement():logical_position_x();
	local settlement_y = region:settlement():logical_position_y();
	local faction = cm:model():world():faction_by_key(nuke_owner);
	local faction_cqi = faction:command_queue_index();
	
	-- Find and kill any army in the settlement
	local garrison_residence = region:garrison_residence();
	
	if garrison_residence:is_null_interface() == false and garrison_residence:is_settlement() == true then
		if garrison_residence:has_army() == true then
			local force = garrison_residence:army();
			
			if force:is_armed_citizenry() == false and force:has_general() == true then
				cm:kill_character(force:general_character():command_queue_index(), true, true);
			end
		end
	end
	
	
	if show_vfx == true then
		-- Add nuclear composite scene
		cm:add_scripted_composite_scene_to_settlement("doomsphere_"..tostring(region_key), "under_empire_doomsphere", "settlement:"..tostring(region_key), 0, 0, true, true, false);
	end
	-- Destroy Under-City
	cm:remove_faction_foreign_slots_from_region(faction_cqi, region_cqi);
	-- Destroy City
	cm:set_region_abandoned(region_key);
	
	cm:callback(function()
		cm:apply_effect_bundle_to_region("wh2_dlc12_skaven_doomsphere", region_key, 0);
	end, 0.5);
	
	local ruin_display = "wh2_dlc12_dummy_nuclear_ruins";
	local display_chain = region:settlement():display_primary_building_chain();
	local building_chain = region:settlement():primary_building_chain();
	
	if display_chain:starts_with("wh2_dlc09_special_settlement_pyramid_of_nagash") then
		ruin_display = "wh2_dlc12_dummy_nuclear_ruins_tmb_nagash";
	elseif display_chain:starts_with("wh2_dlc09_special_settlement_khemri") then
		ruin_display = "wh2_dlc12_dummy_nuclear_ruins_tmb_settra";
	elseif string.find(display_chain, "_lzd") then
		ruin_display = "wh2_dlc12_dummy_nuclear_ruins_lzd";
	elseif string.find(display_chain, "_tmb") then
		ruin_display = "wh2_dlc12_dummy_nuclear_ruins_tmb";
	elseif region_key == "wh_main_yn_edri_eternos_the_oak_of_ages" then
		ruin_display = "wh2_dlc12_dummy_nuclear_ruins_oak";
	end
	
	out("Overwriting building display - "..display_chain.." - "..building_chain);
	cm:override_building_chain_display(display_chain, ruin_display, region_key);
	cm:override_building_chain_display(building_chain, ruin_display, region_key);
	skaven_under_empire_ruins[region_key] = {display_chain, building_chain};
	
	if show_vfx == true then
		-- Doomsphere composite scene is one shot but this is just for edge cases where it remains
		cm:callback(function()
			cm:remove_scripted_composite_scene("doomsphere_"..tostring(region_key));
		end, 10);
	end
	
	-- Tell the nuke owner
	cm:show_message_event_located(
		nuke_owner,
		"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_doomsphere_title",
		"regions_onscreen_"..region_key,
		"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_doomsphere_description",
		settlement_x, settlement_y,
		true,
		120
	);
	-- Tell the region owner
	cm:show_message_event_located(
		region_owner,
		"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_doomsphere_title",
		"regions_onscreen_"..region_key,
		"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_doomsphere_description_target",
		settlement_x, settlement_y,
		true,
		120
	);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("skaven_under_empire_ruins", skaven_under_empire_ruins, context);
		cm:save_named_value("under_empire_plagues", under_empire_plagues, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		skaven_under_empire_ruins = cm:load_named_value("skaven_under_empire_ruins", {}, context);
		under_empire_plagues = cm:load_named_value("under_empire_plagues", {}, context);
	end
);