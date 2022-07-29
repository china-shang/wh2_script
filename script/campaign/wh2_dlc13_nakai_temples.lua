local quetzl_temple_count = 0;
local xholankha_temple_count = 0;
local itzl_temple_count = 0;

local quetzl_completed = false;
local xholankha_completed = false;
local itzl_completed = false;

local nakai_temple_ids = {
	["1132333820"] = "quetzl",
	["1485462950"] = "itzl",
	["1999603937"] = "xholankha"
};

function add_nakai_temples_listeners()
	out("#### Adding Nakai Temples Listeners ####");
	
	if cm:is_new_game() == true then
		local nakai_interface = cm:model():world():faction_by_key("wh2_dlc13_lzd_spirits_of_the_jungle"); 

		if nakai_interface:is_null_interface() == false then
			if nakai_interface:is_human() == true then
				if cm:model():is_multiplayer() == false and cm:model():campaign_name("wh2_main_great_vortex") == true then
					cm:force_declare_war("wh2_dlc13_emp_the_huntmarshals_expedition", "wh2_dlc13_lzd_spirits_of_the_jungle", false, false, false);
					cm:force_diplomacy("faction:wh2_dlc13_emp_the_huntmarshals_expedition", "faction:wh2_dlc13_lzd_spirits_of_the_jungle", "all", false, false, true);
				end
			elseif cm:model():campaign_name("main_warhammer") == true then
				local nakai_char = cm:get_closest_character_to_position_from_faction("wh2_dlc13_lzd_spirits_of_the_jungle", 336, 564, true, false);
				local priest_char = cm:get_closest_character_to_position_from_faction("wh2_dlc13_lzd_spirits_of_the_jungle", 330, 570, false, false);
				if nakai_char then
					cm:teleport_to(cm:char_lookup_str(nakai_char), 22, 174, true);
				end;
				if priest_char then
					cm:teleport_to(cm:char_lookup_str(priest_char), 27, 174, true);
				end;
				cm:force_declare_war("wh2_dlc12_skv_clan_mange", "wh2_dlc13_lzd_spirits_of_the_jungle", false, false, false);
				cm:force_alliance("wh2_main_lzd_tlaxtlan", "wh2_dlc13_lzd_spirits_of_the_jungle", false);
			end
		end
	end

	core:add_listener(
		"nakai_CharacterPerformsSettlementOccupationDecision",
		"CharacterPerformsSettlementOccupationDecision",
		function(context)
			return context:character():faction():name() == "wh2_dlc13_lzd_spirits_of_the_jungle";
		end,
		function(context)
			local character = context:character();
			
			if character:is_null_interface() == false then
				out("Nakai Temple - ");
				
				local occupation_decision = tostring(context:occupation_decision());
				
				out("\toccupation_decision - "..occupation_decision);
				
				local temple_key = nakai_temple_ids[occupation_decision];
				
				if temple_key then
					out("\ttemple_key - "..temple_key);
					
					local region = context:garrison_residence():region();

					create_region_temple(region, temple_key);

					local defenders_faction = cm:get_faction("wh2_dlc13_lzd_defenders_of_the_great_plan");

					if defenders_faction:is_vassal() == false then
						cm:force_make_vassal("wh2_dlc13_lzd_spirits_of_the_jungle", "wh2_dlc13_lzd_defenders_of_the_great_plan");
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "all", false, false, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "war", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "break vassal", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "war", false, true, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "peace", false, true, false);
					end
				end
			end
			
			count_defenders_temples();
		end,
		true
	);
	
	cm:add_faction_turn_start_listener_by_name(
		"nakai_FactionTurnStart",
		"wh2_dlc13_lzd_spirits_of_the_jungle",
		function(context)
			count_defenders_temples();
			
			cm:faction_add_pooled_resource("wh2_dlc13_lzd_spirits_of_the_jungle", "lzd_old_ones_favour", "wh2_dlc13_resource_factor_old_ones_income", (quetzl_temple_count * 2) + (xholankha_temple_count * 2) + (itzl_temple_count * 2));

			local faction = context:faction();

			if faction:has_effect_bundle("wh2_dlc13_ritual_temple_itzl_0_hunters_gaze") == true then
				local faction = cm:model():world():faction_by_key("wh2_dlc13_lzd_defenders_of_the_great_plan"); 

				if faction:is_null_interface() == false and faction:is_dead() == false then
					local region_list = faction:region_list();

					for i = 0, region_list:num_items() - 1 do
						local current_region = region_list:item_at(i);
						local region_key = current_region:name();
						cm:make_region_visible_in_shroud("wh2_dlc13_lzd_spirits_of_the_jungle", region_key);
					end
				end
			end
		end,
		true
	);
	core:add_listener(
		"nakai_RitualCompletedEvent",
		"RitualCompletedEvent",
		function(context)
			return context:performing_faction():name() == "wh2_dlc13_lzd_spirits_of_the_jungle";
		end,
		function(context)
			local ritual = context:ritual():ritual_key();
			
			if ritual == "wh2_dlc13_ritual_temple_itzl_0_hunters_gaze" then
				-- Make Vassal Regions Visible
				local faction = cm:model():world():faction_by_key("wh2_dlc13_lzd_defenders_of_the_great_plan"); 

				if faction:is_null_interface() == false and faction:is_dead() == false then
					local region_list = faction:region_list();

					for i = 0, region_list:num_items() - 1 do
						local current_region = region_list:item_at(i);
						local region_key = current_region:name();
						cm:make_region_visible_in_shroud("wh2_dlc13_lzd_spirits_of_the_jungle", region_key);
					end
				end
			elseif ritual == "wh2_dlc13_ritual_temple_quetzl_0_stalwart_defenders" then
				-- Siege holdout and stats when defending in a siege
				cm:apply_effect_bundle("wh2_dlc13_ritual_temple_quetzl_0_stalwart_defenders", "wh2_dlc13_lzd_defenders_of_the_great_plan", 5);
			elseif ritual == "wh2_dlc13_rituals_lzd_allegiance" then
				-- Apply Attrition effect
				cm:apply_effect_bundle("wh2_dlc13_bundle_lzd_defender_attrition", "wh2_dlc13_lzd_defenders_of_the_great_plan", 5);
			elseif ritual == "wh2_dlc13_rituals_lzd_rebirth" then
				-- Spawn army for Defenders
				local defender_key = "wh2_dlc13_lzd_defenders_of_the_great_plan"
				local faction = cm:model():world():faction_by_key(defender_key); 

				if faction:is_null_interface() == false and faction:is_dead() == false then
					if faction:has_home_region() == true then
						
						local home_region = faction:home_region();

						if home_region:garrison_residence():is_under_siege() == true then

							local region_list = faction:region_list();
							for i = 0, region_list:num_items() - 1 do
								local current_region = region_list:item_at(i);
								if current_region:garrison_residence():is_under_siege() == false then
									home_region = current_region;
									break;
								end

							end
							if home_region == faction:home_region() then
								script_error("ERROR: attempted to spawn army for wh2_dlc13_lzd_defenders_of_the_great_plan but no suitable regions could be found");
							end
						end
						local home_key = home_region:name();

						local pos_x, pos_y = cm:find_valid_spawn_location_for_character_from_settlement(defender_key, home_key, false, true, 3);

						if pos_x > -1 then
							local ram = random_army_manager;
							ram:remove_force("lzd_rite_spawn");
							ram:new_force("lzd_rite_spawn");
	
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_inf_saurus_spearmen_blessed_1", 4);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_inf_saurus_warriors_blessed_1", 4);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_inf_chameleon_skinks_blessed_0", 4);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_cav_horned_ones_blessed_0", 2);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_mon_carnosaur_blessed_0", 2);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_mon_stegadon_blessed_1", 2);
							ram:add_mandatory_unit("lzd_rite_spawn", "wh2_main_lzd_mon_bastiladon_blessed_2", 1);

							local unit_count = random_army_manager:mandatory_unit_count("lzd_rite_spawn");
							local spawn_units = random_army_manager:generate_force("lzd_rite_spawn", unit_count, false);

							cm:create_force(
								defender_key,
								spawn_units,
								home_key,
								pos_x,
								pos_y,
								true,
								function(cqi)
									cm:apply_effect_bundle_to_characters_force("wh2_dlc13_bundle_lzd_defender_army", cqi, 0, true);
								end
							);
						end
					end
				end
			end
		end,
		true
	);
end

function create_region_temple(region, temple_key)
	if temple_key == nil then
		local t = {"quetzl", "itzl", "xholankha"};
		local r = cm:random_number(3);
		temple_key = t[r];
	end

	local settlement = region:settlement();
	
	cm:instantly_set_settlement_primary_slot_level(settlement, 1);
	
	local function create_temple(slot, temple)
		cm:region_slot_instantly_upgrade_building(slot, temple);
		cm:callback(function() cm:heal_garrison(region:cqi()) end, 0.5);
	end
	
	if settlement:is_port() then
		create_temple(settlement:port_slot(), "wh2_dlc13_lzd_port_nakai_" .. temple_key);
	else
		create_temple(settlement:active_secondary_slots():item_at(0), "wh2_dlc13_lzd_nakai_" .. temple_key);
	end
end

function count_defenders_temples()
	local defenders_faction = cm:get_faction("wh2_dlc13_lzd_defenders_of_the_great_plan");
	
	if defenders_faction then
		local region_list = defenders_faction:region_list();
		
		quetzl_temple_count = 0;
		xholankha_temple_count = 0;
		itzl_temple_count = 0;
		
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			local current_settlement = current_region:settlement();
			local temple_bonus = 1;

			if current_region:is_province_capital() == true then
				temple_bonus = 3;
			end
			
			if current_settlement:is_port() then
				local port_slot = current_settlement:port_slot()
				
				if port_slot:has_building() then
					local port_slot_building_name = port_slot:building():name();
					
					if port_slot_building_name == "wh2_dlc13_lzd_port_nakai_quetzl" then
						quetzl_temple_count = quetzl_temple_count + temple_bonus;
					elseif port_slot_building_name == "wh2_dlc13_lzd_port_nakai_xholankha" then
						xholankha_temple_count = xholankha_temple_count + temple_bonus;
					elseif port_slot_building_name == "wh2_dlc13_lzd_port_nakai_itzl" then
						itzl_temple_count = itzl_temple_count + temple_bonus;
					end;
				end;
			else
				local active_secondary_slots = current_settlement:active_secondary_slots();
				
				for j = 0, active_secondary_slots:num_items() - 1 do
					local current_slot = active_secondary_slots:item_at(j);
					
					if not current_slot:is_null_interface() and current_slot:has_building() then
						local building_name = current_slot:building():name();
						
						if building_name == "wh2_dlc13_lzd_nakai_quetzl" then
							quetzl_temple_count = quetzl_temple_count + temple_bonus;
						elseif building_name == "wh2_dlc13_lzd_nakai_xholankha" then
							xholankha_temple_count = xholankha_temple_count + temple_bonus;
						elseif building_name == "wh2_dlc13_lzd_nakai_itzl" then
							itzl_temple_count = itzl_temple_count + temple_bonus;
						end;
					end;
				end;
			end;
		end;
		
		--Remove all Temple effect bundles
		local nakai_faction = cm:get_faction("wh2_dlc13_lzd_spirits_of_the_jungle");
		
		for i = 1, 5 do
			if nakai_faction:has_effect_bundle("wh2_dlc13_nakai_temple_quetzl_" .. i) then
				cm:remove_effect_bundle("wh2_dlc13_nakai_temple_quetzl_" .. i, "wh2_dlc13_lzd_spirits_of_the_jungle");
			end;
			
			if nakai_faction:has_effect_bundle("wh2_dlc13_nakai_temple_xholankha_" .. i) then
				cm:remove_effect_bundle("wh2_dlc13_nakai_temple_xholankha_" .. i, "wh2_dlc13_lzd_spirits_of_the_jungle");
			end;
			
			if nakai_faction:has_effect_bundle("wh2_dlc13_nakai_temple_itzl_" .. i) then
				cm:remove_effect_bundle("wh2_dlc13_nakai_temple_itzl_" .. i, "wh2_dlc13_lzd_spirits_of_the_jungle");
			end;
		end;
		
		if quetzl_temple_count >= 5 then
			cm:apply_effect_bundle("wh2_dlc13_nakai_temple_quetzl" .. get_temple_effect_bundle_suffix(quetzl_temple_count, "quetzl"), "wh2_dlc13_lzd_spirits_of_the_jungle", -1);
		end;
		
		if xholankha_temple_count >= 5 then
			cm:apply_effect_bundle("wh2_dlc13_nakai_temple_xholankha" .. get_temple_effect_bundle_suffix(xholankha_temple_count, "xholankha"), "wh2_dlc13_lzd_spirits_of_the_jungle", -1);
		end;
		
		if itzl_temple_count >= 5 then
			cm:apply_effect_bundle("wh2_dlc13_nakai_temple_itzl" .. get_temple_effect_bundle_suffix(itzl_temple_count, "itzl"), "wh2_dlc13_lzd_spirits_of_the_jungle", -1);
		end;
	end;
end;

function get_temple_effect_bundle_suffix(count, temple_key)
	if count >= 25 then
		if temple_key == "quetzl" then
			cm:set_saved_value("quetzl_completed", true);
		elseif temple_key == "xholankha" then
			cm:set_saved_value("xholankha_completed", true);
		elseif temple_key == "itzl" then
			cm:set_saved_value("itzl_completed", true);
		end
		core:trigger_event("ScriptEventDotGPGodCompleted");
		return "_5";
	elseif count >= 20 then
		return "_4";
	elseif count >= 15 then
		return "_3";
	elseif count >= 10 then
		return "_2";
	else
		core:trigger_event("ScriptEventDotGP5Temples");
		return "_1";
	end;
end;

--save/load functions
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("quetzl_completed", quetzl_completed, context);
		cm:save_named_value("xholankha_completed", xholankha_completed, context);
		cm:save_named_value("itzl_completed", itzl_completed, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			quetzl_completed = cm:load_named_value("quetzl_completed", quetzl_completed, context);
			xholankha_completed = cm:load_named_value("xholankha_completed", xholankha_completed, context);
			itzl_completed = cm:load_named_value("itzl_completed", itzl_completed, context);
		end
	end
);