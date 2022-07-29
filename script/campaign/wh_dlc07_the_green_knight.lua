local green_knight_turn_available = 0;
local green_knight_show_arrival_message = false;

function add_green_knight_listeners()
	out("#### Adding Green Knight Listeners ####");
	
	local human_bretonnian_faction = false;

	local human_factions = cm:get_human_factions();

	for i = 1, #human_factions do
		local current_human_faction = cm:get_faction(human_factions[i]);
		
		if current_human_faction:culture() == "wh_main_brt_bretonnia" then
			human_bretonnian_faction = true;
		end;
	end;
	
	if not human_bretonnian_faction then

		local function spawn_green_knight_callback(context)
			local faction = context:faction();
			local faction_name = faction:name();
			
			local is_valid = false;
			
			for i = 0, faction:unique_agents():num_items() - 1 do
				local unique_agent = faction:unique_agents():item_at(i);
				
				is_valid = unique_agent:valid();
				
				out("Spawn_AI_Green_Knight check for faction: " .. faction_name .. " - Agent: " .. unique_agent:agent_key() .. " (" .. unique_agent:charges_expended() .. "/" .. unique_agent:charges() .. ") - " .. tostring(is_valid));
			end;
			
			if is_valid then
				cm:spawn_unique_agent(faction:command_queue_index(), "dlc07_brt_green_knight", false);
			end;
		end;

		-- start a FactionTurnStart listener for each Bretonnian faction
		for faction_key in pairs(BRETONNIA_FACTIONS) do
			cm:add_faction_turn_start_listener_by_name(
				"Bret_Green_Knight_FactionTurnStart",
				faction_key,
				spawn_green_knight_callback,
				true
			);
		end;
	end;
	
	core:add_listener(
		"Bret_UniqueAgentSpawned",
		"UniqueAgentSpawned",
		function(context)
			local character = context:unique_agent_details():character();
	
			return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight");
		end,
		function(context)
			out("#### Unique Agent Spawned ####");
			local character = context:unique_agent_details():character();
			
			if character:rank() < 40 then
				local char_str = "character_cqi:"..character:cqi();
				
				cm:add_agent_experience(char_str, 40, true);
				cm:replenish_action_points(char_str);
				
				for i = 1, 40 do
					cm:force_add_skill(char_str, "wh_dlc07_skill_green_knight_dummy");
				end
			end
			
			if character:faction():is_human() and not cm:is_multiplayer() then
				-- fly camera to Green Knight
				cm:scroll_camera_from_current(false, 1, {character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0});
			end
		end,
		true
	);
	
	core:add_listener(
		"Bret_UniqueAgentDespawned",
		"UniqueAgentDespawned",
		function(context)
			local character = context:unique_agent_details():character();
			
			return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight") and character:faction():is_human();
		end,
		function(context)
			local character = context:unique_agent_details():character();
			
			cm:show_message_event_located(
				character:faction():name(),
				"event_feed_strings_text_wh_event_feed_string_legendary_hero_departed_title",
				"event_feed_strings_text_wh_event_feed_string_legendary_hero_departed_primary_detail",
				"event_feed_strings_text_wh_event_feed_string_legendary_hero_departed_secondary_detail",
				character:logical_position_x(),
				character:logical_position_y(),
				false,
				702
			);
		end,
		true
	);
end;