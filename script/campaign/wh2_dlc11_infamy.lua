local infamy_core_pirates = {"wh2_dlc11_cst_the_drowned", "wh2_dlc11_cst_pirates_of_sartosa", "wh2_dlc11_cst_vampire_coast", "wh2_dlc11_cst_noctilus"};
local infamy_faction_list = {};
local infamy_shanty_level = 1;
local infamy_shanty_level_complete = 0;
local infamy_ai_cheating = false;
local harpoon_has_launcher = false;
local harpoon_has_harpoon = false;
local final_battle_key = {
	["wh2_dlc11_cst_the_drowned"] = {"wh2_dlc11_cst_final_battle_cylostra", "wh2_dlc11_cst_final_battle_grand_campaign_cylostra"},
	["wh2_dlc11_cst_pirates_of_sartosa"] = {"wh2_dlc11_cst_final_battle_aranessa", "wh2_dlc11_cst_final_battle_grand_campaign_aranessa"},
	["wh2_dlc11_cst_vampire_coast"] = {"wh2_dlc11_cst_final_battle", "wh2_dlc11_cst_final_battle_grand_campaign"},
	["wh2_dlc11_cst_noctilus"] = {"wh2_dlc11_cst_final_battle_noctilus", "wh2_dlc11_cst_final_battle_grand_campaign_noctilus"}
};
local infamy_pirate_starting_amounts = {
	["wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast"] = 1000,
	["wh2_dlc11_cst_rogue_freebooters_of_port_royale"] = 2000,
	["wh2_dlc11_cst_rogue_the_churning_gulf_raiders"] = 3000,
	["wh2_dlc11_cst_shanty_middle_sea_brigands"] = 4000,
	["wh2_dlc11_cst_rogue_bleak_coast_buccaneers"] = 5000,
	["wh2_dlc11_cst_rogue_grey_point_scuttlers"] = 6000,
	["wh2_dlc11_cst_shanty_dragon_spine_privateers"] = 7000,
	["wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean"] = 8000,
	["wh2_dlc11_cst_rogue_terrors_of_the_dark_straights"] = 9000,
	["wh2_dlc11_cst_shanty_shark_straight_seadogs"] = 12000
};
local infamy_kill_income_mod = 0.3;
local infamy_kill_income_cap = 500;
local infamy_pirate_starting_amounts_mod = 2;

function add_infamy_listeners()
	out("#### Adding Infamy Listeners ####");

	-- Add a FactionTurnStart listener for each pirate faction
	for i = 1, #infamy_core_pirates do
		cm:add_faction_turn_start_listener_by_name(
			"InfamyFactionTurnStart",
			infamy_core_pirates[i],
			function(context) InfamyFactionTurnStart(context) end, 
			true
		);
	end;

	core:add_listener(
		"InfamyBattleCompleted",
		"BattleCompleted",
		function() return cm:model():pending_battle():has_been_fought() end,
		function(context) InfamyBattleCompleted(context) end,
		true
	);
	core:add_listener(
		"InfamyCharacterRazedSettlement",
		"CharacterRazedSettlement",
		true,
		function(context) InfamyCharacterRazedSettlement(context) end,
		true
	);
	core:add_listener(
		"ShantyMissionSucceeded",
		"MissionSucceeded",
		true,
		function(context) ShantyMissionSucceeded(context) end,
		true
	);
	core:add_listener(
		"InfamyAssassination",
		"CharacterCharacterTargetAction",
		function(context) return context:mission_result_critial_success() or context:mission_result_success() end,
		function(context) InfamyAssassination(context) end,
		true
	);
	core:add_listener(
		"HarpoonMilitaryForceBuildingCompleteEvent",
		"MilitaryForceBuildingCompleteEvent",
		function(context)
			return context:building() == "wh2_dlc11_special_ship_harpoon_5" and context:character():faction():is_human() == true;
		end,
		function(context)
			harpoon_has_launcher = true;
			cm:complete_scripted_mission_objective("wh_main_long_victory", "build_harpoon_launcher", true);
		end,
		true
	);
	
	if cm:is_new_game() == true then
		local human_vampire_coast = false;
		local start_infamy = 200;
		local campaign_name = "main_warhammer";
		
		if cm:model():campaign_name("wh2_main_great_vortex") then
			campaign_name = "wh2_main_great_vortex";
		end
		
		for i = 1, #infamy_core_pirates do
			local faction = cm:model():world():faction_by_key(infamy_core_pirates[i]);
			
			if faction:is_null_interface() == false then
				if faction:is_human() == true then
					Infamy_AddInfamy(faction:name(), "wh2_dlc11_resource_factor_other", 200);
					human_vampire_coast = true;
				else
					start_infamy = start_infamy + 200;
					Infamy_AddInfamy(faction:name(), "wh2_dlc11_resource_factor_other", start_infamy);
				end
			end
		end
		
		-- Set start Infamy of all roving pirates
		local roving_pirates = roving_pirates_accessor();
		
		for i = 1, #roving_pirates do
			local pirate = roving_pirates[i];
			start_infamy = infamy_pirate_starting_amounts[pirate.faction_key] * infamy_pirate_starting_amounts_mod;
			pirate.infamy = start_infamy;
			Infamy_AddInfamy(pirate.faction_key, "wh2_dlc11_resource_factor_other", start_infamy);
		end
		
		if human_vampire_coast == true then
			local blessed_dread = cm:model():world():faction_by_key("wh2_dlc11_def_the_blessed_dread");
			
			if cm:is_multiplayer() == false and blessed_dread:is_human() == false then
				-- Kill and then lock Lokhir
				cm:kill_character(blessed_dread:faction_leader():command_queue_index(), false, false);
				
				if cm:model():campaign_name("wh2_main_great_vortex") then
					cm:lock_starting_general_recruitment("1995155769", "wh2_dlc11_def_the_blessed_dread");
				else
					cm:lock_starting_general_recruitment("1813433830", "wh2_dlc11_def_the_blessed_dread");
				end
			end
		end
	end
	InfamyPopulateList();
	
	-- Final Battle Listeners
	core:add_listener(
		"VCoast_PendingBattle",
		"PendingBattle",
		true,
		function(context)
			local pb = cm:model():pending_battle();
			local battle_key = pb:set_piece_battle_key();
			
			if battle_key == "wh2_dlc11_qb_cst_final_battle" or battle_key == "wh2_dlc11_qb_cst_final_battle_aranessa" or battle_key == "wh2_dlc11_qb_cst_final_battle_cylostra" or battle_key == "wh2_dlc11_qb_cst_final_battle_noctilus" then
				local attacker = pb:attacker();
				local attacker_cqi = attacker:military_force():command_queue_index();
				cm:apply_effect_bundle_to_force("wh2_dlc11_bundle_tmb_final_battle_army_abilities_battle_supply", attacker_cqi, 0);
			end
		end,
		true
	);
	core:add_listener(
		"VCoast_BattleCompleted",
		"BattleCompleted",
		true,
		function(context)
			local pb = cm:model():pending_battle();
			local battle_key = pb:set_piece_battle_key();
			
			if battle_key == "wh2_dlc11_qb_cst_final_battle" or battle_key == "wh2_dlc11_qb_cst_final_battle_aranessa" or battle_key == "wh2_dlc11_qb_cst_final_battle_cylostra" or battle_key == "wh2_dlc11_qb_cst_final_battle_noctilus" then
				local char_key = "harkon";
				
				if battle_key == "wh2_dlc11_qb_cst_final_battle_aranessa" then
					char_key = "aranessa";
				elseif battle_key == "wh2_dlc11_qb_cst_final_battle_cylostra" then
					char_key = "cylostra";
				elseif battle_key == "wh2_dlc11_qb_cst_final_battle_noctilus" then
					char_key = "noctilus";
				end
				
				-- save the battle movie now as it triggers during the battle itself
				core:svr_save_registry_bool("cst_battle_"..char_key, true);
				
				local this_char_cqi, this_mf_cqi, faction_key = cm:pending_battle_cache_get_attacker(1);
				cm:remove_effect_bundle_from_force("wh2_dlc11_bundle_tmb_final_battle_army_abilities_battle_supply", this_mf_cqi);
				
				-- Final battle is won in singleplayer
				if cm:is_multiplayer() == false then
					if cm:pending_battle_cache_attacker_victory() == true then
						-- Play win movie
						core:svr_save_registry_bool("cst_win_"..char_key, true);
						cm:register_instant_movie("warhammer2/cst/cst_win_"..char_key);
						
						-- Epilogue
						cm:add_turn_countdown_event(faction_key, 1, "ScriptEventShowEpilogueEvent_CST", char_key);
					end
				end
			end
		end,
		true
	);
	if cm:is_multiplayer() == false then
		core:add_listener(
			"epilogue_cst",
			"ScriptEventShowEpilogueEvent_CST",
			true,
			function(context)
				local char_key = context.string;
				local human_factions = cm:get_human_factions();
				
				cm:trigger_incident(human_factions[1], "wh2_dlc11_incident_epilogue_cst_"..char_key, true);
			end,
			false
		);
	end
end

function InfamyFactionTurnStart(context)
	local faction = context:faction();
	
	if faction:is_human() == true and cm:is_new_game() == false then
		local faction_key = context:faction():name();
		
		-- Update secret pirate
		local player_infamy = faction:pooled_resource("cst_infamy");
		
		if player_infamy:is_null_interface() == false then
			-- Check Player Infamy to see if the Sea Shanty pirates should attack
			local infamy_value = player_infamy:value();
			local roving_pirates = roving_pirates_accessor();
			local shanty_list_count = 0;
			
			for i = 1, #roving_pirates do
				local pirate = roving_pirates[i];
				
				if pirate.item_owned == "sea_shanty" or pirate.item_owned == "sea_shanty_lost" then
					shanty_list_count = shanty_list_count + 1;
					
					-- Wait until we reach the Shanty owner that matches the current number triggered
					if infamy_shanty_level == shanty_list_count then
						if infamy_value > pirate.infamy then
							-- Player has surpassed this pirates infamy
							if (infamy_shanty_level - 1) == infamy_shanty_level_complete then
								-- Player is at the Shanty level relevant to this Pirate
								InfamyShantyOwnerSurpassed(pirate, faction_key);
							end
						end
					end
				end
			end
			
			-- Single player only mystery pirate
			if cm:is_multiplayer() == false then
				local turn_number = cm:model():turn_number();
				
				if turn_number == 10 then
					local secret_pirate = {};
					secret_pirate.faction_key = "wh2_dlc11_def_the_blessed_dread";
					secret_pirate.should_fake = true;
					secret_pirate.infamy = 100;
					secret_pirate.behaviour = "secret_pirate";
					secret_pirate.has_sea_shanty = false;
					table.insert(infamy_faction_list, secret_pirate);
					cm:trigger_incident(faction_key, "wh2_dlc11_incident_cst_mystery_pirate", true);
				end
					
				if turn_number >= 10 then
					for i = 1, #infamy_faction_list do
						if infamy_faction_list[i].should_fake == true then
							if infamy_faction_list[i].behaviour == "secret_pirate" then
								out("Secret Pirate Infamy - Player: "..tostring(infamy_value).." / Pirate: "..tostring(infamy_faction_list[i].infamy));
								if infamy_faction_list[i].infamy < (infamy_value - 100) then
									local difference = math.abs(infamy_value - infamy_faction_list[i].infamy);
									if difference > 100 then
										local half_difference = difference / 2;
										half_difference = tonumber(string.format("%.0f", half_difference));
										difference = half_difference + cm:random_number(half_difference);
										difference = math.floor(difference);
										out("\tAdding "..tostring(difference).." fake Infamy points to Mystery Pirate ("..tostring(infamy_faction_list[i].infamy)..")");
										difference = infamy_faction_list[i].infamy + difference;
										infamy_faction_list[i].infamy = difference;
									end
								else
									out("\tSecret pirate is above player, not giving them Infamy");
								end
							end
						end
					end
				end
				AttemptTriggerFinalBattle(faction_key);
			end
		end
		-- Update UI
		InfamyPopulateList();
	elseif infamy_ai_cheating == true and faction:is_human() == false then
		local faction_key = context:faction():name();
		
		local infamy_boost = 10 + cm:random_number(90);
		Infamy_AddInfamy(faction_key, "wh2_dlc11_resource_factor_other", infamy_boost);
	end
end

function InfamyShantyOwnerSurpassed(pirate, player)
	cm:spawn_rogue_army(pirate.faction_key, pirate.spawn_pos.x, pirate.spawn_pos.y);
	
	local rogue_force = cm:get_faction(pirate.faction_key):faction_leader():military_force();
	local rogue_pirate = invasion_manager:new_invasion_from_existing_force(pirate.faction_key.."_PIRATE", rogue_force);
	
	if pirate.effect ~= nil and pirate.effect ~= "" then
		rogue_pirate:apply_effect(pirate.effect, -1);
	end
	if pirate.xp ~= nil and pirate.xp > 0 then
		rogue_pirate:add_unit_experience(pirate.xp);
	end
	if pirate.level ~= nil and pirate.level > 0 then
		rogue_pirate:add_character_experience(pirate.level, true);
	end
	
	rogue_pirate:set_target("NONE", nil, player);
	rogue_pirate:start_invasion(
	function()
		cm:force_diplomacy("all", "faction:"..pirate.faction_key, "all", false, false, true);
	end, true, false, false);
	pirate.item_num = infamy_shanty_level;
	
	-- notify advice scripts
	if infamy_shanty_level == 1 then
		core:trigger_event("ScriptEventFirstShantyPirateAttacks");
	elseif infamy_shanty_level == 2 then
		core:trigger_event("ScriptEventSecondShantyPirateAttacks");
	elseif infamy_shanty_level == 3 then
		core:trigger_event("ScriptEventThirdShantyPirateAttacks");
	end
	
	-- Trigger the mission
	local mm = mission_manager:new(player, "wh2_dlc11_mission_sea_shanty_"..infamy_shanty_level);
	mm:set_mission_issuer("CLAN_ELDERS");
	
	mm:add_new_objective("ENGAGE_FORCE");
	mm:add_condition("cqi "..rogue_force:command_queue_index());
	mm:add_condition("requires_victory");
	
	mm:add_payload("effect_bundle{bundle_key wh2_dlc11_bundle_sea_shanty_verse_"..infamy_shanty_level..";turns 0;}");
	mm:trigger();
	
	-- Trigger event
	local p_num = 1;
	
	if player == "wh2_dlc11_cst_noctilus" then
		p_num = 2;
	elseif player == "wh2_dlc11_cst_pirates_of_sartosa" then
		p_num = 3;
	elseif player == "wh2_dlc11_cst_the_drowned" then
		p_num = 4;
	end
	
	cm:show_message_event_located(
		player,
		"event_feed_strings_text_".."wh2_dlc11_event_feed_string_scripted_pirate_ship_title",
		"event_feed_strings_text_".."wh2_dlc11_event_feed_string_scripted_pirate_ship_primary_detail_"..infamy_shanty_level,
		"event_feed_strings_text_".."wh2_dlc11_event_feed_string_scripted_pirate_ship_secondary_detail_"..infamy_shanty_level,
		pirate.spawn_pos.x, pirate.spawn_pos.y,
		true,
		p_num + 1110
	);
	infamy_shanty_level = infamy_shanty_level + 1;
end

function ShantyMissionSucceeded(context)
	local mission_key = context:mission():mission_record_key();
	local faction = context:faction();
	
	if mission_key == "wh2_dlc11_mission_sea_shanty_1" then
		core:trigger_event("ScriptEventFirstShantyPirateDefeated");
		ShantyReward(faction, 1);
	elseif mission_key == "wh2_dlc11_mission_sea_shanty_2" then
		core:trigger_event("ScriptEventSecondShantyPirateDefeated");
		ShantyReward(faction, 2);
	elseif mission_key == "wh2_dlc11_mission_sea_shanty_3" then
		core:trigger_event("ScriptEventThirdShantyPirateDefeated");
		ShantyReward(faction, 3);
		cm:complete_scripted_mission_objective("wh_main_long_victory", "gain_all_shanties", true);
	elseif mission_key == "wh2_dlc11_mission_harpoon" then
		harpoon_has_harpoon = true;
	end
end

function ShantyReward(faction, level)
	local faction_key = faction:name();
	
	-- Remove all Shanty Effects
	for i = 1, 3 do
		cm:remove_effect_bundle("wh2_dlc11_bundle_sea_shanty_verse_"..i, faction_key);
	end
	-- Add current level Shanty
	cm:trigger_incident(faction_key, "wh2_dlc11_incident_cst_sea_shanty_gained_"..level, true);
	infamy_shanty_level_complete = infamy_shanty_level_complete + 1;
	
	-- Try to trigger the final battle
	AttemptTriggerFinalBattle(faction_key);
	
	-- Remove the first listed pirate with a Shanty
	local roving_pirates = roving_pirates_accessor();
	
	for i = 1, #roving_pirates do
		local pirate = roving_pirates[i];
		if pirate.item_owned == "sea_shanty" then
			pirate.item_owned = "sea_shanty_lost";
			-- Kill all of the factions armies
			local shanty_faction = cm:model():world():faction_by_key(pirate.faction_key);
			cm:kill_all_armies_for_faction(shanty_faction);
			break;
		end
	end
	InfamyPopulateList();
end

function AttemptTriggerFinalBattle(faction_key)
	if infamy_shanty_level_complete == 3 then
		if harpoon_has_harpoon == true and harpoon_has_launcher == true then
			local mission_key = "";
			
			if cm:model():campaign_name("wh2_main_great_vortex") then
				mission_key = final_battle_key[faction_key][1];
			elseif cm:model():campaign_name("main_warhammer") then
				mission_key = final_battle_key[faction_key][2];
			end
			
			cm:trigger_mission(faction_key, mission_key, true);
			infamy_shanty_level_complete = infamy_shanty_level_complete + 1;
			
			-- wait for battle completed otherwise it will play before selecting a post battle option etc.
			core:svr_save_registry_bool("cst_items", true);
			
			if cm:model():pending_battle():is_active() then
				core:add_listener(
					"items_movie",
					"BattleCompleted",
					true,
					function()
						cm:register_instant_movie("warhammer2/cst/cst_items");
					end,
					false
				)
			else
				cm:register_instant_movie("warhammer2/cst/cst_items");
			end;
		end
	end
end

function InfamyPopulateList()
	local infamy_holder = find_uicomponent(core:get_ui_root(), "infamy_holder");
	
	if infamy_holder and infamy_holder:Visible() == true then
	
		local is_multiplayer = cm:is_multiplayer();
		
		-- make a local copy of the infamy list (non-player factions at least) so we can work out the player's position within it
		local local_non_player_infamy_list = {};
		
		local function add_to_infamy_list(leader_name, faction_name, icon_folder, infamy_value, has_sea_shanty)
			infamy_holder:InterfaceFunction(
				"AddFakeEntry",
				leader_name,
				faction_name,
				icon_folder,
				infamy_value,
				has_sea_shanty
			);
			
			-- assemble a local infamy list in singleplayer mode (this is done for advice)
			if not is_multiplayer then
				-- insert a record in the correct position in the local infamy list
				for i = 1, #local_non_player_infamy_list do
					if local_non_player_infamy_list[i] < infamy_value then
						table.insert(local_non_player_infamy_list, i, infamy_value);
						return;
					end;
				end;
				
				-- if we're here then we need to insert our infamy value at the end of the table
				table.insert(local_non_player_infamy_list, infamy_value);
			end;
		end;
		
		-- Add the pirates in the fake list
		for i = 1, #infamy_faction_list do
			add_to_infamy_list(
				infamy_faction_list[i].faction_key.."_leader",	-- Leaders Name
				infamy_faction_list[i].faction_key,				-- Faction Name
				infamy_faction_list[i].faction_key,				-- Icon Folder
				infamy_faction_list[i].infamy,					-- Infamy Amount
				infamy_faction_list[i].has_sea_shanty			-- Has Sea Shanty
			);
		end;
		
		-- Add the real faction pirates who have infamy
		local roving_pirates = roving_pirates_accessor();
		local faction_list = cm:model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local faction_key = faction:name();
			
			if faction:has_pooled_resource("cst_infamy") then
				local faction_infamy = faction:pooled_resource("cst_infamy");
				
				if faction_infamy:is_null_interface() == false then
					local infamy_value = faction_infamy:value();
					
					if faction:is_human() == false then
						-- Roving Pirates
						for i = 1, #roving_pirates do
							local pirate = roving_pirates[i];
							local show_pirate = true;
							
							if pirate.item_owned == "sea_shanty_lost" then
								local pirate_obj = cm:get_faction(pirate.faction_key);
								if pirate_obj:is_dead() == true then
									show_pirate = false;
								end
							end
							
							if show_pirate == true and pirate.faction_key == faction_key then
								if infamy_value > 0 then
									add_to_infamy_list(
										faction_key.."_leader",				-- Leaders Name
										faction_key,						-- Faction Name
										faction_key,						-- Icon Folder
										infamy_value,						-- Infamy Amount
										pirate.item_owned == "sea_shanty"	-- Has Sea Shanty
									);
								end
								break;
							end
						end
						-- Major Factions
						for i = 1, #infamy_core_pirates do
							if infamy_core_pirates[i] == faction_key then
								add_to_infamy_list(
									faction_key.."_leader",				-- Leaders Name
									faction_key,						-- Faction Name
									faction_key,						-- Icon Folder
									infamy_value,						-- Infamy Amount
									false								-- Has Sea Shanty
								);
							end
						end
					end
				end
			end
		end

		-- work out the position of the player in the local infamy list in singleplayer mode (for advice)
		if not is_multiplayer then
			-- get the infamy value of the local player
			local local_player_infamy = cm:get_faction(cm:get_local_faction_name(true)):pooled_resource("cst_infamy"):value();
			local position_of_local_player_in_infamy_list = false;
			
			for i = 1, #local_non_player_infamy_list do
				if local_non_player_infamy_list[i] < local_player_infamy then
					-- local player is at position i in the infamy list
					position_of_local_player_in_infamy_list = i;
					break;
				end;
			end;
			
			if not position_of_local_player_in_infamy_list then
				-- no-one on the infamy list had less infamy than the player - the player is bottom of the list
				position_of_local_player_in_infamy_list = #local_non_player_infamy_list;
			end;
			
			-- if they've gained in position compared to the position previously cached, then attempt to trigger advice
			local cached_player_infamy_list_position = cm:get_saved_value("cached_player_infamy_list_position");
			if cached_player_infamy_list_position and cached_player_infamy_list_position > position_of_local_player_in_infamy_list then
				if cached_player_infamy_list_position == 1 then
					core:trigger_event("ScriptEventPlayerTopsInfamyList");
				else
					core:trigger_event("ScriptEventPlayerClimbsInfamyList");
				end
			end
			
			-- cache their current position in the infamy list
			cm:set_saved_value("cached_player_infamy_list_position", position_of_local_player_in_infamy_list);
		end;
	end
end

function InfamyBattleCompleted(context)
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();
	local attacker_won = (attacker_result == "heroic_victory") or (attacker_result == "decisive_victory") or (attacker_result == "close_victory") or (attacker_result == "pyrrhic_victory");
	local defender_won = (defender_result == "heroic_victory") or (defender_result == "decisive_victory") or (defender_result == "close_victory") or (defender_result == "pyrrhic_victory");
	local attacker_value = cm:pending_battle_cache_attacker_value();
	local defender_value = cm:pending_battle_cache_defender_value();
	local already_awarded = {};
	
	-- Give any attackers who won their Infamy
	if attacker_won == true then
		local attacker_multiplier = defender_value / attacker_value;
		attacker_multiplier = math.clamp(attacker_multiplier, 0.5, 1.5);
		local attacker_infamy = (defender_value / 10) * attacker_multiplier;
		local kill_ratio = cm:model():pending_battle():percentage_of_defender_killed();
		attacker_infamy = attacker_infamy * kill_ratio;
		
		for i = 1, cm:pending_battle_cache_num_attackers() do
			local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);
			
			if already_awarded[attacker_name] == nil then
				if attacker_name == "wh2_dlc11_cst_noctilus" or attacker_name == "wh2_dlc11_cst_pirates_of_sartosa" or attacker_name == "wh2_dlc11_cst_the_drowned" or attacker_name == "wh2_dlc11_cst_vampire_coast" then
					local infamy_reward = attacker_infamy * infamy_kill_income_mod;
					if infamy_reward > infamy_kill_income_cap then
						infamy_reward = infamy_kill_income_cap;
					end
					Infamy_AddInfamy(attacker_name, "wh2_dlc11_resource_factor_battles", infamy_reward);
					already_awarded[attacker_name] = true;
					InfamyPrintBattle(attacker_name, attacker_infamy, attacker_value, defender_value, attacker_multiplier, kill_ratio);
				end
			end
		end
	-- Give any defenders who won their Infamy
	elseif defender_won == true then
		local defender_multiplier = attacker_value / defender_value;
		defender_multiplier = math.clamp(defender_multiplier, 0.5, 1.5);
		local defender_infamy = (attacker_value / 10) * defender_multiplier;
		local kill_ratio = cm:model():pending_battle():percentage_of_attacker_killed();
		defender_infamy = defender_infamy * kill_ratio;
		
		for i = 1, cm:pending_battle_cache_num_defenders() do
			local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);
			
			if already_awarded[defender_name] == nil then
				if defender_name == "wh2_dlc11_cst_noctilus" or defender_name == "wh2_dlc11_cst_pirates_of_sartosa" or defender_name == "wh2_dlc11_cst_the_drowned" or defender_name == "wh2_dlc11_cst_vampire_coast" then
					local infamy_reward = defender_infamy * infamy_kill_income_mod;
					if infamy_reward > infamy_kill_income_cap then
						infamy_reward = infamy_kill_income_cap;
					end
					Infamy_AddInfamy(defender_name, "wh2_dlc11_resource_factor_battles", infamy_reward);
					already_awarded[defender_name] = true;
					InfamyPrintBattle(defender_name, defender_infamy, attacker_value, defender_value, defender_multiplier, kill_ratio);
				end
			end
		end
	end
end

function InfamyPrintBattle(faction, infamy_amount, aval, dval, bonus_mult, kill_ratio)
	infamy_amount = tonumber(string.format("%.0f", infamy_amount));
	out.design("--------------------------------------------");
	out.design("Infamy Battle Fought");
	out.design("\tWinner: "..faction);
	out.design("\tInfamy: "..infamy_amount);
	out.design("\t\tAttacker Value: "..aval);
	out.design("\t\tDefender Value: "..dval);
	out.design("\t\tStrength Ratio: "..bonus_mult);
	out.design("\t\tKill Ratio: "..kill_ratio);
	out.design("--------------------------------------------");
end

function InfamyCharacterRazedSettlement(context)
	local faction_key = context:character():faction():name();
	
	if faction_key == "wh2_dlc11_cst_noctilus" or faction_key == "wh2_dlc11_cst_pirates_of_sartosa" or faction_key == "wh2_dlc11_cst_the_drowned" or faction_key == "wh2_dlc11_cst_vampire_coast" then
		Infamy_AddInfamy(faction_key, "wh2_dlc11_resource_factor_razing", 200);
		cm:remove_effect_bundle("wh2_dlc11_bundle_infamy_razing_dummy", faction_key);
	end
end

local infamy_assassination_results = {
	["wh2_main_agent_action_champion_hinder_agent_assassinate"] = true,
	["wh2_main_agent_action_spy_hinder_agent_assassinate"] = true,
	["wh2_main_agent_action_champion_hinder_agent_wound"] = true,
	["wh2_main_agent_action_dignitary_hinder_agent_wound"] = true,
	["wh2_main_agent_action_engineer_hinder_agent_wound"] = true,
	["wh2_main_agent_action_runesmith_hinder_agent_wound"] = true,
	["wh2_main_agent_action_wizard_hinder_agent_wound"] = true
};

function InfamyAssassination(context)
	if infamy_assassination_results[context:agent_action_key()] then
		local faction = context:character():faction();
		local faction_key = faction:name();
		
		if faction_key == "wh2_dlc11_cst_noctilus" or faction_key == "wh2_dlc11_cst_pirates_of_sartosa" or faction_key == "wh2_dlc11_cst_the_drowned" or faction_key == "wh2_dlc11_cst_vampire_coast" then
			Infamy_AddInfamy(faction_key, "wh2_dlc11_resource_factor_assassination", 100);
		end
	end
end

function Infamy_AddInfamy(faction_key, factor, amount)
	if faction_key == cm:get_local_faction_name(true) then
		core:trigger_event("ScriptEventPlayerInfamyIncreases");
	end
	amount = math.floor(amount);
	out("Infamy: Adding " .. tostring(amount) .. " infamy to " .. tostring(faction_key) .. ", factor is " .. tostring(factor));
	cm:faction_add_pooled_resource(faction_key, "cst_infamy", factor, amount);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("infamy_faction_list", infamy_faction_list, context);
		cm:save_named_value("infamy_shanty_level", infamy_shanty_level, context);
		cm:save_named_value("infamy_shanty_level_complete", infamy_shanty_level_complete, context);
		cm:save_named_value("harpoon_has_harpoon", harpoon_has_harpoon, context);
		cm:save_named_value("harpoon_has_launcher", harpoon_has_launcher, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			infamy_faction_list = cm:load_named_value("infamy_faction_list", infamy_faction_list, context);
			infamy_shanty_level = cm:load_named_value("infamy_shanty_level", infamy_shanty_level, context);
			infamy_shanty_level_complete = cm:load_named_value("infamy_shanty_level_complete", infamy_shanty_level_complete, context);
			harpoon_has_harpoon = cm:load_named_value("harpoon_has_harpoon", harpoon_has_harpoon, context);
			harpoon_has_launcher = cm:load_named_value("harpoon_has_launcher", harpoon_has_launcher, context);
		end
	end
);