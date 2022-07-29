local resource_list = {"res_gold", "res_gems", "res_rom_marble"};
local resource_faction = "";

local resource_locations = {
	["main_warhammer"] = {
		["res_gold"] = {},
		["res_gems"] = {},
		["res_rom_marble"] = {}
	},
	["wh2_main_great_vortex"] = {
		["res_gold"] = {},
		["res_gems"] = {},
		["res_rom_marble"] = {}
	}
};

function add_nagash_books_effects_listeners()
	local campaign_key = "";
	
	if cm:model():campaign_name("main_warhammer") then
		campaign_key = "main_warhammer";
	else
		campaign_key = "wh2_main_great_vortex";
	end
	
	local all_regions = cm:model():world():region_manager():region_list();
	
	for i = 0, all_regions:num_items() - 1 do
		local current_region = all_regions:item_at(i);
		local resource_key = "";
		
		for k = 0, current_region:slot_list():num_items() - 1 do
			local current_slot = current_region:slot_list():item_at(k);
		
			if current_slot:resource_key() ~= "" then
				resource_key = current_slot:resource_key();
				break;
			end
		end
		
		if resource_key ~= "" then
			for j = 1, #resource_list do
				if resource_list[j] == resource_key then
					table.insert(resource_locations[campaign_key][resource_list[j]], current_region:name());
				end
			end
		end
	end
end


core:add_listener(
	"faction_turn_start_tmb_lift_shroud_resource_locations",
	"ScriptEventHumanFactionTurnStart",
	true,
	function(context)
		local faction = context:faction();
		
		if faction:culture() == "wh2_dlc09_tmb_tomb_kings" then
			local turn_number = cm:model():turn_number();
			local campaign_key = "";
			
			if cm:model():campaign_name("main_warhammer") then
				campaign_key = "main_warhammer";
			else
				campaign_key = "wh2_main_great_vortex";
			end
			
			if faction:has_effect_bundle("wh2_dlc09_books_of_nagash_reward_2") then
				for i = 1, #resource_list do 
					for j = 1, #resource_locations[campaign_key][resource_list[i]] do
						cm:make_region_visible_in_shroud(resource_faction, resource_locations[campaign_key][resource_list[i]][j]);
					end
				end
			end
		end
	end,
	true
);


core:add_listener(
	"character_sacked_settlement_tmb_create_storm_for_region",
	"CharacterSackedSettlement",
	true,
	function(context)
		local faction = context:character():faction();
		
		if faction:culture() == "wh2_dlc09_tmb_tomb_kings" and faction:has_effect_bundle("wh2_dlc09_books_of_nagash_reward_3") then
			local char_cqi = context:character():command_queue_index();
			local army_bundle = "wh2_dlc09_books_of_nagash_reward_3_army";
			local duration = 10;
			
			cm:remove_effect_bundle_from_characters_force(army_bundle, char_cqi);
			cm:apply_effect_bundle_to_characters_force(army_bundle, char_cqi, duration, true);
			cm:trigger_incident(faction:name(),"wh2_dlc09_incident_tmb_sand_storm_spawned", true);
			cm:create_storm_for_region(context:character():region():name(), 1, duration, "land_storm");
		end
	end,
	true
);


core:add_listener(
	"garrison_occupied_event_tmb_create_storm_for_region",
	"GarrisonOccupiedEvent",
	true,
	function(context)
		local faction = context:character():faction();
		
		if faction:culture() == "wh2_dlc09_tmb_tomb_kings" and faction:has_effect_bundle("wh2_dlc09_books_of_nagash_reward_3") then
			local char_cqi = context:character():command_queue_index();
			local army_bundle = "wh2_dlc09_books_of_nagash_reward_3_army";
			local duration = 10;
			
			cm:remove_effect_bundle_from_characters_force(army_bundle, char_cqi);
			cm:apply_effect_bundle_to_characters_force(army_bundle, char_cqi, duration, true);
			cm:trigger_incident(faction:name(), "wh2_dlc09_incident_tmb_sand_storm_spawned", true);
			cm:create_storm_for_region(context:character():region():name(), 1, duration, "land_storm");
		end
	end,
	true
);


core:add_listener(
	"mission_succeeded_tmb_lift_shroud",
	"MissionSucceeded",
	true,
	function(context)
		local faction = context:faction();
		
		if faction:culture() == "wh2_dlc09_tmb_tomb_kings" then
			local mission_key = context:mission():mission_record_key();
			local faction_name = context:faction():name();
			local campaign_key = "";
			
			if cm:model():campaign_name("main_warhammer") then
				campaign_key = "main_warhammer";
			elseif cm:model():campaign_name("wh2_main_great_vortex") then
				campaign_key = "wh2_main_great_vortex";
			end
			
			if mission_key == "wh2_dlc09_books_of_nagash_2" then
				resource_faction = faction_name;
				
				for i = 1, #resource_list do
					for j = 1, #resource_locations[campaign_key][resource_list[i]] do
						cm:make_region_visible_in_shroud(faction_name, resource_locations[campaign_key][resource_list[i]][j]);
					end
				end
			end
			
			if mission_key == "wh2_dlc09_books_of_nagash_4" then
				cm:pooled_resource_mod(faction:command_queue_index(), "tmb_canopic_jars", "wh2_main_resource_factor_other", 400);
				cm:remove_event_restricted_unit_record_for_faction("wh2_dlc09_tmb_mon_necrosphinx_ror", faction_name);
			end
		end
	end,
	true
);

--[[
local tmb_army_lost = {
	["cqi"] = {},
	["faction"] = {}
};


core:add_listener(
	"pending_battle_tmb_watch_list",
	"PendingBattle",
	true,
	function(context)
		local pb = cm:model():pending_battle();
		
		for i = 1, cm:pending_battle_cache_num_attackers() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
			out("preparing the watch list");
			if cm:model():military_force_for_command_queue_index(this_mf_cqi):faction():subculture() == "wh2_dlc09_sc_tmb_tomb_kings" then
				table.insert(tmb_army_lost["cqi"],this_mf_cqi);
				table.insert(tmb_army_lost["faction"],current_faction_name);
				out("putting "..current_faction_name.." to watch list");
			end
		end
		for i = 1, cm:pending_battle_cache_num_defenders() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
			if cm:model():military_force_for_command_queue_index(this_mf_cqi):faction():subculture() == "wh2_dlc09_sc_tmb_tomb_kings" then
				table.insert(tmb_army_lost["cqi"],this_mf_cqi);
				table.insert(tmb_army_lost["faction"],current_faction_name);
				out("putting "..current_faction_name.." to watch list");
			end
		end
	end,
	true
);


core:add_listener(
	"battle_completed_tmb_watch_list",
	"BattleCompleted",
	true,
	function(context)
		out("checking the list now");
		for i = 1, #tmb_army_lost["cqi"] do 
			out("checking suvivability of "..tmb_army_lost["faction"][i]);
			out(cm:model():military_force_for_command_queue_index(tmb_army_lost["cqi"][i]):is_null_interface());
			if cm:model():military_force_for_command_queue_index(tmb_army_lost["cqi"][i]):is_null_interface() == true then
				out("this faction is to be debuffed"..tmb_army_lost["faction"][i]);
			end
		end
	end,
	true
);
]]--

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("resource_faction", resource_faction, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		resource_faction = cm:load_named_value("resource_faction", "", context);
	end
);