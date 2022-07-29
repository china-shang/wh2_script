function Start_CharacterTurnStart_Building_Effect_Listener()
	core:add_listener(
		"UnderEmpireCharacterTurnStart",
		"CharacterTurnStart",
		true,
		function(context) UnderEmpireBuildingLaboratory(context:character()) end,
		true
	);
end;


function Add_Building_Effect_Listeners()
	core:add_listener(
		"RangerBuildingEffects",
		"ScriptEventHumanFactionFactionTurnStart",
		true,
		function(context) RangerBuildingEffects(context) end,
		true
	);

	-- don't start CharacterTurnStart listener until turn two
	if cm:model():turn_number() > 1 then
		Start_CharacterTurnStart_Building_Effect_Listener();
	else
		core:add_listener(
			"PreUnderEmpireCharacterTurnStart",
			"FactionTurnStart",
			function() return cm:model():turn_number() > 1 end,
			Start_CharacterTurnStart_Building_Effect_Listener,
			false
		);
	end;	
	
	cm:add_faction_turn_start_listener_by_culture(
		"UnderEmpireBuildingExpansion",
		"wh2_main_skv_skaven",
		function(context)
			UnderEmpireBuildingExpansion(context:faction())
		end,
		true
	);
end

function RangerBuildingEffects(context)
	local faction = context:faction();
	local scouted_regions = {};
	
	if faction:subculture() == "wh_main_sc_dwf_dwarfs" then
		local region_list = faction:region_list();
		
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);
			
			if region:building_exists("wh_dlc06_dwf_ranger_hub_1") or region:building_exists("wh_dlc06_dwf_ranger_hub_1_all") or region:building_exists("wh_dlc06_dwf_ranger_hub_2") then
				table.insert(scouted_regions, region:name());
				local adjacent_region_list = region:adjacent_region_list();
				
				for j = 0, adjacent_region_list:num_items() - 1 do
					table.insert(scouted_regions, adjacent_region_list:item_at(j):name());
				end
			end
		end
		
		local army_list = faction:military_force_list();
		
		for i = 0, army_list:num_items() - 1 do
			local army = army_list:item_at(i);
			
			if army:has_general() then
				local general = army:general_character();
				
				if army:has_effect_bundle("wh_dlc06_ranger_scouting") then
					cm:remove_effect_bundle_from_characters_force("wh_dlc06_ranger_scouting", general:command_queue_index());
				end
				
				if general:has_region() and Character_In_Scouted_Region(scouted_regions, general:region():name()) then
					cm:apply_effect_bundle_to_characters_force("wh_dlc06_ranger_scouting", general:command_queue_index(), 0, true);
				end
			end
		end
	end
end

function Character_In_Scouted_Region(scouted_regions, character_region)
	for i = 1, #scouted_regions do
		if scouted_regions[i] == character_region then
			return true;
		end
	end
	return false;
end

function UnderEmpireBuildingLaboratory(character)
	if character:faction():culture() == "wh2_main_skv_skaven" and character:character_type("engineer") == true then
		local under_empires = character:faction():foreign_slot_managers();
		
		for i = 0, under_empires:num_items() - 1 do
			local under_empire = under_empires:item_at(i);
			
			for j = 0, under_empire:num_slots() - 1 do
				local slot = under_empire:slots():item_at(j);
				
				if slot:has_building() == true then
					if slot:building() == "wh2_dlc12_special_warlock_lab_1" then
						cm:add_agent_experience(cm:char_lookup_str(character), 50);
						break;
					end
				end
			end
		end
	end
end

function UnderEmpireBuildingExpansion(faction)
	local faction_key = faction:name();
	local under_empires = faction:foreign_slot_managers();
	
	for i = 0, under_empires:num_items() - 1 do
		local expand_chance = 0;
		local under_empire = under_empires:item_at(i);
		local region = under_empire:region();
		out("UnderEmpireBuildingExpansion - "..region:name());
		
		for j = 0, under_empire:num_slots() - 1 do
			local slot = under_empire:slots():item_at(j);
			
			if slot:has_building() == true then
				if slot:building() == "wh2_dlc12_under_empire_warpstone_mine_2" then
					expand_chance = 10;
					break;
				elseif slot:building() == "wh2_dlc12_under_empire_warpstone_mine_1" then
					expand_chance = 5;
					break;
				end
			end
		end
			
		if expand_chance > 0 then
			out("\tChance - "..tostring(expand_chance).."%");
			if cm:model():random_percent(expand_chance) then
				out("\t\tSuccess!");
				local adjacent_region_list = region:adjacent_region_list();
				
				for j = 0, adjacent_region_list:num_items() - 1 do
					local possible_region = adjacent_region_list:item_at(j);
					local region_key = possible_region:name();
					out("\t\tAdjacent Region: "..region_key);
					
					if possible_region:is_abandoned() == false and possible_region:owning_faction():is_null_interface() == false and possible_region:owning_faction():name() ~= faction_key then
						local slot_manager = possible_region:foreign_slot_manager_for_faction(faction_key);
						
						if slot_manager:is_null_interface() == true then
							out("\t\t\tAccepting Region: "..region_key);
							cm:add_foreign_slot_set_to_region_for_faction(faction:command_queue_index(), possible_region:cqi(), "wh2_dlc12_slot_set_underempire");
							cm:make_region_visible_in_shroud(faction_key, region_key);
							
							local settlement_x = possible_region:settlement():logical_position_x();
							local settlement_y = possible_region:settlement():logical_position_y();
							
							cm:show_message_event_located(
								faction_key,
								"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_expanded_title",
								"regions_onscreen_"..region_key,
								"event_feed_strings_text_wh2_dlc12_event_feed_string_scripted_event_under_empire_expanded_description",
								settlement_x, settlement_y,
								false,
								123
							);
							
							expand_chance = -1;
							return true;
						end
					end
				end
			end
		end
	end
end