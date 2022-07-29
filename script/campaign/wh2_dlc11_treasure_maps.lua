
--variables go here

--global variables
active_treasure = 1
level3_missions = 1
map_chance = 15
map_chance_increase_per_turn = 0

treasure_map_list = {
["island"] = {false, 10, 8}, --is mission active, amount of missions in vortex, amount of missions in mortal empires
["volcano"] = {false, 8, 8},
["animal"] = {false, 8, 8},
["skull"] = {false, 8, 8},
["structure"] = {false, 8, 8},
["lake"] = {false, 8, 9},
["symbols"] = {false, 7, 8},
["river"] = {false, 8, 8},
["unique"] = {false, 7, 8}
}

local pirate_factions = {"wh2_dlc11_cst_rogue_bleak_coast_buccaneers",
"wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast",
"wh2_dlc11_cst_rogue_freebooters_of_port_royale",
"wh2_dlc11_cst_rogue_grey_point_scuttlers",
"wh2_dlc11_cst_rogue_terrors_of_the_dark_straights",
"wh2_dlc11_cst_rogue_the_churning_gulf_raiders",
"wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean",
"wh2_dlc11_cst_shanty_dragon_spine_privateers",
"wh2_dlc11_cst_shanty_middle_sea_brigands",
"wh2_dlc11_cst_shanty_shark_straight_seadogs" }

local vampire_coast_factions = {"wh2_dlc11_cst_pirates_of_sartosa",
"wh2_dlc11_cst_noctilus",
"wh2_dlc11_cst_the_drowned",
"wh2_dlc11_cst_vampire_coast"
}


function add_treasure_maps_listeners()
	-- start the treasure maps listeners if any of the vampire coast factions are controlled by a human
	for j = 1, #vampire_coast_factions do	
		local faction = cm:get_faction(vampire_coast_factions[j]) 
		if faction and faction:is_human() then
			TreasureMapListeners()
			return;
		end
	end
end

function TreasureMapListeners()
	out("#### Adding Treasure Maps Listeners ####");
	-- other variables here

	-- initialise this value at the start of a new singleplayer campaign - it's used by advice
	if cm:is_new_game() and not cm:get_saved_value("num_treasure_missions_succeeded_sp") then
		cm:set_saved_value("num_treasure_missions_succeeded_sp", 0);
	end;
		
	local is_vortex_campaign = cm:model():campaign_name("wh2_main_great_vortex");
	
	-- only start this listener in a multiplayer game or if we're not playing the vortex campaign - in a sp vortex campaign the triggering of the initial mission is handled in wh2_early_game.lua
	if cm:is_multiplayer() or not is_vortex_campaign then
		core:add_listener(
			"FactionTurnStart_Treasure_Map",
			"ScriptEventHumanFactionTurnStart",
			function(context)
				return cm:model():turn_number() == 1 and context:faction():culture() == "wh2_dlc11_cst_vampire_coast";
			end,
			function(context)
				local faction_name = context:faction():name();
				
				if faction_name == "wh2_dlc11_cst_vampire_coast" then
					cm:trigger_mission(faction_name, "wh2_dlc11_cst_treasure_map_starting_treasure_luthor_me", true);
				elseif faction_name == "wh2_dlc11_cst_pirates_of_sartosa" then
					cm:trigger_mission(faction_name, "wh2_dlc11_cst_treasure_map_starting_treasure_aranessa_me", true);
				elseif faction_name == "wh2_dlc11_cst_noctilus" then
					cm:trigger_mission(faction_name, "wh2_dlc11_cst_treasure_map_starting_treasure_noctilus_me", true);
				elseif faction_name == "wh2_dlc11_cst_the_drowned" then
					cm:trigger_mission(faction_name, "wh2_dlc11_cst_treasure_map_starting_treasure_cylostra_me", true);
				end
			end,
			true
		);
	end;
	
	core:add_listener(
		"FactionTurnEnd_Treasure_Map",
		"FactionTurnEnd",
		function(context)
			return context:faction():is_human() == true and context:faction():culture() == "wh2_dlc11_cst_vampire_coast";
		end,
		function(context)
			if active_treasure < 6 then
				map_chance_increase_per_turn = map_chance_increase_per_turn + 5;
			end
		end,
		true
	);
	
	core:add_listener( 
		"BattleCompleted_Treasure_Map",
		"BattleCompleted",
		function(context) 
			return cm:pending_battle_cache_human_is_involved();
		end,
		function(context) 
			local main_defender_faction = cm:pending_battle_cache_get_defender_faction_name(1);
			local main_attacker_faction = cm:pending_battle_cache_get_attacker_faction_name(1);
			
			for i = 1, #pirate_factions do
				if main_attacker_faction == pirate_factions[i] then
					if cm:pending_battle_cache_defender_victory() then
						TriggerTreasureMapMission(main_defender_faction, 30);
						return;
					end
				elseif main_defender_faction == pirate_factions[i] then
					if cm:pending_battle_cache_attacker_victory() then
						TriggerTreasureMapMission(main_attacker_faction, 30);
						return;
					end
				end
			end
			
			if cm:model():world():faction_by_key(main_attacker_faction):is_human() and cm:model():world():faction_by_key(main_attacker_faction):culture() == "wh2_dlc11_cst_vampire_coast" and cm:pending_battle_cache_attacker_victory() then
				TriggerTreasureMapMission(main_attacker_faction, 0);
			elseif cm:model():world():faction_by_key(main_defender_faction):is_human() and cm:model():world():faction_by_key(main_defender_faction):culture() == "wh2_dlc11_cst_vampire_coast" and cm:pending_battle_cache_defender_victory() then
				TriggerTreasureMapMission(main_defender_faction, 0);
			end	
		end,
		true
	);
	 
	core:add_listener(
		"MissionSucceeded_Treasure_Map",
		"MissionSucceeded",
		function(context)
			local current_culture = context:faction():culture();
			return current_culture == "wh2_dlc11_cst_vampire_coast" and context:faction():is_human();
		end,
		function(context)
			local current_mission = context:mission():mission_record_key();
			local faction_name = context:faction():name();
			
			if IsTreasureMapMission(current_mission) then
				--local mission_category = GetTreasureMapMissionCategory(current_mission);
				
				SetTreasureMapEndVariables(GetTreasureMapMissionCategory(current_mission));
				
				-- mission success advice
				if not cm:is_multiplayer() then
					local num_treasure_missions_succeeded_sp = cm:get_saved_value("num_treasure_missions_succeeded_sp") + 1;
					cm:set_saved_value("num_treasure_missions_succeeded_sp", num_treasure_missions_succeeded_sp);
					if num_treasure_missions_succeeded_sp >= 1 and num_treasure_missions_succeeded_sp <= 2 then
						core:trigger_event("ScriptEventFirstTreasureMapMissionSucceeded");
					elseif num_treasure_missions_succeeded_sp >= 5 and num_treasure_missions_succeeded_sp <= 8 then
						core:trigger_event("ScriptEventFifthTreasureMapMissionSucceeded");
					end;
				end;
				
				CalculateTreasureMapReward(context, current_mission);
				
				-- delay triggering the next mission for a small period to give mission-success/hoard-uncovered event messages a chance to show
				cm:callback(function() TriggerTreasureMapMission(faction_name, 0) end, 0.5);
			end	
			
			if current_mission == "wh2_dlc11_noctilus_declare_war" then
				cm:callback(function() treasure_map_reward(faction_name) end, 0.5);
			end
		end,
		true
	);	
	
	core:add_listener(
		"MissionIssued_Treasure_Map",
		"MissionIssued",
		function(context)
			local current_culture = context:faction():culture();
			return current_culture == "wh2_dlc11_cst_vampire_coast" and context:faction():is_human();
		end,
		function(context)
			--local current_mission = context:mission():mission_record_key();
			if IsTreasureMapMission(context:mission():mission_record_key()) then
				map_chance_increase_per_turn = 0;
			end
		end,
		true
	);
	
	core:add_listener(
		"MissionCancelled_Treasure_Map",
		"MissionCancelled",
		function(context)
			out("TREASURE WAS TRASHED")
			local current_culture = context:faction():culture();
			return current_culture == "wh2_dlc11_cst_vampire_coast" and context:faction():is_human();
		end,
		function(context)
			out("TREASURE WAS TRASHED AGAIN")
			--local current_mission = context:mission():mission_record_key();
			if IsTreasureMapMission(context:mission():mission_record_key()) then
				--local mission_category = GetTreasureMapMissionCategory(context:mission():mission_record_key());
				
				SetTreasureMapEndVariables(GetTreasureMapMissionCategory(context:mission():mission_record_key()));
			end
		end,
		true
	);
	
	-- listen for treasure searches being failed
	do
		local num_treasure_hunt_missions_succeeded = 0;
		local num_treasure_hunt_missions_failed = 0;
		
		core:add_listener(
			"treasure_not_found_listener",
			"HaveCharacterWithinRangeOfPositionMissionEvaluationResultEvent",
			function(context)
				-- we don't test for the search being successful here as it allows the first instance of the trigger callback (which is triggered for each active treasure hunt mission) 
				-- to cancel subsequent failure tests - if the first is a success we don't want any failure events showing, and in this way they will be cancelled.
				return --[[not context:was_successful() and]] string.find(context:mission_key(), "treasure_map") and cm:model():world():whose_turn_is_it():subculture() == "wh2_dlc11_sc_cst_vampire_coast";
			end,
			function(context)			
				if context:was_successful() then
					num_treasure_hunt_missions_succeeded = num_treasure_hunt_missions_succeeded + 1;
				else
					num_treasure_hunt_missions_failed = num_treasure_hunt_missions_failed + 1;
				end;
				
				cm:remove_callback("treasure_not_found_listener");
				
				cm:callback(
					function()
						out(" * HaveCharacterWithinRangeOfPositionMissionEvaluationResultEvent is responding after half a second, missions succeeded: " .. num_treasure_hunt_missions_succeeded .. ", missions failed: " .. num_treasure_hunt_missions_failed);
					
						if num_treasure_hunt_missions_succeeded == 0 and num_treasure_hunt_missions_failed > 0 then
							local faction_key = cm:model():world():whose_turn_is_it():name();
							cm:show_message_event(
								faction_key,						-- assumes that factions can only generate these failure events on their turn
								"event_feed_strings_text_wh2_scripted_event_treasure_hunt_search_failed_title",
								"factions_screen_name_" .. faction_key,
								"event_feed_strings_text_wh2_scripted_event_treasure_hunt_search_failed_secondary_detail",
								true,
								786
							);
						end;
						
						num_treasure_hunt_missions_succeeded = 0;
						num_treasure_hunt_missions_failed = 0;
					end,
					0.3,
					"treasure_not_found_listener"
				);
			end,
			true
		);
	end;
end

function IsTreasureMapMission(current_mission)
	local mission_key = "wh2_dlc11_cst_treasure_map_";
	
	if string.find(current_mission, mission_key) then
		return true;
	else
		return false;
	end
end

function treasure_map_reward(faction_name)
	if cm:get_faction(faction_name):has_effect_bundle("wh2_dlc11_award_treasure_map") then
		TriggerTreasureMapMission(faction_name, 100);
		cm:remove_effect_bundle("wh2_dlc11_award_treasure_map",faction_name);
	end
end

function GetTreasureMapMissionCategory(current_mission)
	local mission_key = "wh2_dlc11_cst_treasure_map_";
	local mission_key_length = string.len(mission_key);
	local position_of_final_underscore = string.find(current_mission, "_", string.len(mission_key) + 1);
	
	local mission_category = string.sub(current_mission, mission_key_length + 1, position_of_final_underscore - 1);
	
	return mission_category;
end

--Triggering a treasure map mission
function TriggerTreasureMapMission(faction, chance)
	
	--If player is Aranessa, increase chance by 25
	if faction == "wh2_dlc11_cst_pirates_of_sartosa" then
		chance = chance + 25;
	end
	
	if active_treasure == 0 and cm:random_number(100) <= map_chance + chance + 50 then
		chance = 100;
	end
	
	--check if player has 6 active treasure missions
	if active_treasure < 6 then
		if cm:random_number(100) <= map_chance + chance + map_chance_increase_per_turn then
			local random_number = 0;
			local mission_category;
			local random_mission;
			local mission_level = 1;
			
			--unique_treasure must be the last item in the list
			local mission_categories_list = {"island", "volcano", "animal", "skull", "structure", "lake", "symbols", "river"};
			local mission_categories_with_levels_vortex = false;
			
			if level3_missions < 2 and cm:random_number(100) <= 40 then
				mission_category = "unique";
			else
				--randomise treasure category until finding a category that is not active
				repeat
					random_number = cm:random_number(8);
					mission_category = mission_categories_list[random_number];
				until(treasure_map_list[mission_category][1] == false)
			end
			
			--check which campaign it is
			if cm:model():campaign_name("wh2_main_great_vortex") then
				random_mission = cm:random_number(treasure_map_list[mission_category][2]);
				mission_categories_with_levels =
				{
					["island"] = {2, 2, 2, 1, 1, 1, 2, 2, 2, 1},
					["volcano"] = {1, 1, 1, 1, 2, 2, 2, 2},
					["animal"] = {2, 2, 1, 1, 2, 2, 2, 2},
					["skull"] = {2, 1, 1, 2, 1, 2, 2, 2},
					["structure"] = {1, 1, 1, 2, 2, 1, 2, 2},
					["lake"] = {1, 2, 2, 1, 1, 1, 2, 1},
					["symbols"] = {2, 2, 2, 1, 2, 1, 1},
					["river"] = {2, 2, 2, 1, 1, 2, 2, 2},
					["unique"] = {3, 3, 3, 3, 3, 3, 3}
				}
			else
				random_mission = cm:random_number(treasure_map_list[mission_category][3]);
				mission_categories_with_levels =
				{
					["island"] = {1, 1, 1, 2, 2, 2, 1, 1},
					["volcano"] = {2, 2, 2, 2, 2, 2, 1, 1},
					["animal"] = {1, 1, 1, 1, 2, 2, 2, 1},
					["skull"] = {2, 1, 2, 1, 1, 2, 2, 2},
					["structure"] = {2, 2, 1, 1, 2, 1, 1, 1},
					["lake"] = {1, 1, 1, 2, 1, 2, 1, 2, 2},
					["symbols"] = {1, 1, 1, 1, 2, 1, 2, 1},
					["river"] = {1, 1, 1, 1, 2, 2, 1, 1},
					["unique"] = {3, 3, 3, 3, 3, 3, 3, 3}
				}
			end 
			
			mission_level = mission_categories_with_levels[mission_category][random_mission];
			
			SetTreasureMapTriggeredVariables(mission_level, mission_category);

			--out("!!!!!!!!!!!!!!!!!!!!!Mission is: wh2_dlc11_cst_treasure_map_"..mission_category.."_treasure_"..random_mission.."_level_"..mission_level)
			--trigger mission
			if cm:model():campaign_name("wh2_main_great_vortex") then

				TriggerTreasureMapMissionAction(faction, "wh2_dlc11_cst_treasure_map_"..mission_category.."_treasure_"..random_mission.."_level_"..mission_level);

				--if cm:trigger_mission(faction, "wh2_dlc11_cst_treasure_map_"..mission_category.."_treasure_"..random_mission.."_level_"..mission_level, true) then
					--SetTreasureMapVariables(mission_level, mission_category);
				--end
				--cm:trigger_mission(faction, "wh2_dlc11_cst_treasure_map_unique_treasure_"..random_mission.."_level_"..mission_level, true);
			else
				TriggerTreasureMapMissionAction(faction, "wh2_dlc11_cst_treasure_map_"..mission_category.."_treasure_me_"..random_mission.."_level_"..mission_level);

				--if cm:trigger_mission(faction, "wh2_dlc11_cst_treasure_map_"..mission_category.."_treasure_me_"..random_mission.."_level_"..mission_level, true) then
					--SetTreasureMapVariables(mission_level, mission_category);
				--end
			end
		end
	end
end


function TriggerTreasureMapMissionAction(faction_key, mission_key)
	local mission_triggered_by_intervention = false;
	
	if not cm:is_multiplayer() and faction_key == cm:get_local_faction_name(true) then
		-- if we can trigger advice about our first treasure map mission then do so
		if in_treasure_map_mission and in_treasure_map_mission.is_started and in_treasure_map_mission:passes_precondition_check() then
			core:trigger_event("ScriptEventIssueTreasureMapMission");
			mission_triggered_by_intervention = true;
			cm:trigger_mission(faction_key, mission_key, true);
		
		-- if we can trigger advice about having six treasure maps then do so
		elseif active_treasure == 6 and in_full_treasure_map_log and in_full_treasure_map_log.is_started and in_full_treasure_map_log:passes_precondition_check() then
			core:trigger_event("ScriptEventIssueTreasureMapMissionFullLog");
			mission_triggered_by_intervention = true;
			cm:trigger_mission(faction_key, mission_key, true);
		end;
	end;
	
	if not mission_triggered_by_intervention then
		cm:trigger_mission(faction_key, mission_key, true);
	end;
end;


function SetTreasureMapTriggeredVariables(mission_level, mission_category)
	active_treasure = active_treasure + 1;
	if mission_level == 3 then
		level3_missions = level3_missions + 1;
	else
		treasure_map_list[mission_category][1] = true;
	end
end

function SetTreasureMapEndVariables(mission_category)
	if mission_category == "unique" or mission_category == "starting" then
		level3_missions = level3_missions - 1;
	else
		treasure_map_list[mission_category][1] = false;
	end
	
	active_treasure = active_treasure - 1;
end

level_3_ancillaries = { "wh2_dlc11_anc_talisman_kraken_fang", "wh2_dlc11_anc_weapon_masamune", "wh2_dlc10_anc_arcane_item_scroll_of_arnizipals_black_horror", "wh2_dlc11_anc_armour_the_gunnarsson_kron", "wh2_dlc11_anc_magic_standard_ships_colors", "wh2_dlc11_anc_weapon_double_barrel", "wh2_dlc11_anc_weapon_lucky_levis_hookhand",  "wh_main_anc_arcane_item_book_of_ashur", "wh_main_anc_talisman_talisman_of_preservation", "wh_main_anc_weapon_giant_blade", "wh_main_anc_weapon_sword_of_bloodshed", "wh_main_anc_magic_standard_rampagers_standard", "wh_main_anc_arcane_item_scroll_of_leeching", "wh_main_anc_armour_armour_of_destiny", "wh_main_anc_armour_tricksters_helm", "wh_main_anc_enchanted_item_the_other_tricksters_shard", "wh_main_anc_magic_standard_rangers_standard", "wh_main_anc_magic_standard_wailing_banner", "wh_main_anc_weapon_obsidian_blade" }

level_2_ancillaries = { "wh2_dlc10_anc_arcane_item_scroll_of_assault_of_stone", "wh2_dlc10_anc_arcane_item_scroll_of_fear_of_aramar", "wh2_dlc11_anc_magic_standard_bloodied_banner_of_slayers", "wh2_dlc11_anc_magic_standard_burnt_banner_of_knights", "wh2_dlc11_anc_magic_standard_holed_banner_of_militia", "wh2_dlc11_anc_magic_standard_torn_banner_of_pilgrims", "wh2_dlc11_anc_talisman_blackpearl_eye", "wh2_dlc11_anc_talisman_jellyfish_in_a_jar", "wh_main_anc_armour_armour_of_silvered_steel", "wh_main_anc_magic_standard_razor_standard", "wh_main_anc_talisman_obsidian_lodestone", "wh_main_anc_weapon_ogre_blade", "wh_main_anc_weapon_sword_of_strife", "wh_main_anc_arcane_item_forbidden_rod", "wh_main_anc_armour_armour_of_fortune", "wh_main_anc_enchanted_item_crown_of_command", "wh_main_anc_enchanted_item_healing_potion", "wh_main_anc_magic_standard_war_banner", "wh_main_anc_weapon_fencers_blades", "wh_dlc03_anc_weapon_the_brass_cleaver", "wh_main_anc_arcane_item_tricksters_shard", "wh_main_anc_armour_helm_of_discord", "wh_main_anc_talisman_obsidian_amulet", "wh_main_anc_talisman_talisman_of_endurance", "wh_main_anc_weapon_sword_of_anti-heroes" }

level_1_ancillaries = {"wh2_dlc11_anc_magic_standard_dead_mans_chest", "wh2_main_anc_weapon_dagger_of_sotek", "wh_main_anc_arcane_item_earthing_rod", "wh_main_anc_arcane_item_wand_of_jet", "wh_main_anc_armour_glittering_scales", "wh_main_anc_armour_shield_of_ptolos", "wh_main_anc_enchanted_item_featherfoe_torc", "wh_main_anc_enchanted_item_ruby_ring_of_ruin",  "wh_main_anc_enchanted_item_the_terrifying_mask_of_eee", "wh_main_anc_magic_standard_the_screaming_banner", "wh_main_anc_talisman_dawnstone", "wh_main_anc_weapon_sword_of_swift_slaying", "wh2_dlc10_anc_arcane_item_scroll_of_blast", "wh2_dlc10_anc_arcane_item_scroll_of_speed_of_lykos", "wh2_dlc10_anc_arcane_item_scroll_of_the_amber_trance", "wh_main_anc_arcane_item_power_scroll", "wh_main_anc_arcane_item_power_stone", "wh_main_anc_armour_gamblers_armour", "wh_main_anc_armour_spellshield", "wh_main_anc_enchanted_item_potion_of_strength", "wh_main_anc_enchanted_item_potion_of_toughness", "wh_main_anc_weapon_berserker_sword", "wh_main_anc_weapon_sword_of_battle", "wh_main_anc_weapon_sword_of_might", "wh_main_anc_magic_standard_lichbone_pennant", "wh_main_anc_arcane_item_channelling_staff", "wh_main_anc_arcane_item_sceptre_of_stability", "wh_main_anc_arcane_item_scroll_of_shielding", "wh_main_anc_magic_standard_banner_of_swiftness", "wh_main_anc_magic_standard_standard_of_discipline", "wh_main_anc_talisman_obsidian_trinket", "wh_main_anc_talisman_opal_amulet", "wh_main_anc_talisman_talisman_of_protection", "wh_main_anc_weapon_gold_sigil_sword", "wh_main_anc_weapon_sword_of_striking", "wh_main_anc_armour_dragonhelm", "wh_main_anc_magic_standard_banner_of_eternal_flame", "wh_main_anc_weapon_biting_blade", "wh_main_anc_weapon_relic_sword", "wh_main_anc_weapon_shrieking_blade", "wh_main_anc_armour_charmed_shield", "wh_main_anc_armour_enchanted_shield", "wh_main_anc_enchanted_item_ironcurse_icon", "wh_main_anc_enchanted_item_potion_of_foolhardiness", "wh_main_anc_enchanted_item_potion_of_speed", "wh_main_anc_magic_standard_gleaming_pennant", "wh_main_anc_magic_standard_scarecrow_banner", "wh_main_anc_talisman_dragonbane_gem", "wh_main_anc_talisman_luckstone", "wh_main_anc_talisman_pidgeon_plucker_pendant", "wh_main_anc_weapon_tormentor_sword", "wh_main_anc_weapon_warrior_bane", "wh2_dlc11_anc_magic_standard_boatswain", "wh2_dlc11_anc_magic_standard_corpse_surgeon", "wh2_dlc11_anc_magic_standard_rookie_gunner", "wh2_dlc11_anc_follower_cst_drawn_chef", "wh2_dlc11_anc_follower_cst_sartosa_navigator", "wh2_dlc11_anc_follower_cst_shipwright", "wh2_dlc11_anc_follower_cst_siren", "wh2_dlc11_anc_follower_cst_travelling_necromancer", "wh2_main_anc_follower_sea_cucumber","wh_main_anc_follower_all_men_outrider"}

function CalculateTreasureMapReward(context, current_mission)
	local faction = context:faction();
	local ancillary;
	local payload;
	local mission_level = string.sub(current_mission, -1)
	local treasury_to_add = "0";
	
	if GetTreasureMapMissionCategory(current_mission) == "starting" then
		treasury_to_add = "2000";
		payload = "money "..treasury_to_add..";faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount 150;}";
		GiveTheTreasureReward(faction, payload, false);
	elseif GetTreasureMapMissionCategory(current_mission) == "unique" then
		treasury_to_add = "5000";
		payload = "money "..treasury_to_add..";faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount 150;}";
		ancillary = FindAncillaryRewardForTreasure(context, level_3_ancillaries);
		GiveTheTreasureReward(faction, payload, true, ancillary);
	else 
		if mission_level == "2" then
			if current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_me_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_me_9_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_me_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_me_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_6_level_2" then
				treasury_to_add = "4000";
				payload = "money "..treasury_to_add..";faction_pooled_resource_transaction{resource cst_infamy;factor wh2_main_resource_factor_missions;amount 150;}";
				ancillary = FindAncillaryRewardForTreasure(context, level_3_ancillaries);
			elseif current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_me_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_9_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_me_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_me_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_1_level_2" then
				treasury_to_add = "3000";
				payload = "money "..treasury_to_add..";"
				ancillary = FindAncillaryRewardForTreasure(context, level_2_ancillaries);
			elseif current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_me_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_me_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_me_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_me_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_me_4_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_me_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_8_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_7_level_2" then
				treasury_to_add = "2500";
				payload = "money "..treasury_to_add..";"
				ancillary = FindAncillaryRewardForTreasure(context, level_2_ancillaries);
			elseif current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_me_4_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_me_7_level_2"  or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_5_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_symbols_treasure_1_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_7_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_3_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_2_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_6_level_2" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_7_level_2" then
				treasury_to_add = "2000";
				payload = "money "..treasury_to_add..";"
				ancillary = FindAncillaryRewardForTreasure(context, level_1_ancillaries);
			end
			
			
			GiveTheTreasureReward(faction, payload, true, ancillary);
		else
			if current_mission == "wh2_dlc11_cst_treasure_map_animal_treasure_me_4_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_6_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_2_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_3_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_structure_treasure_me_4_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_island_treasure_4_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_lake_treasure_me_7_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_me_8_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_river_treasure_me_7_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_7_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_1_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_volcano_treasure_me_8_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_4_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_2_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_me_5_level_1" or current_mission == "wh2_dlc11_cst_treasure_map_skull_treasure_2_level_1" then
				treasury_to_add = "1500";
			else
				treasury_to_add = "1000";
			end
			
			payload = "money "..treasury_to_add..";"
			GiveTheTreasureReward(faction, payload, false);
		end
	end

end

function FindAncillaryRewardForTreasure(context, level)

	local ancillary;
	local random_number = 0;
	
	repeat
		random_number = cm:random_number(#level);
		ancillary = level[random_number];
	until(context:faction():ancillary_exists(ancillary) == false)
	
	return ancillary;
end

function GiveTheTreasureReward(faction, payload, reward_ancillary, ancillary)
	cm:trigger_custom_incident(faction:name(), "wh2_dlc11_incident_cst_found_treasure", true, "payload{"..payload.."}");
	
	if reward_ancillary == true then
		cm:add_ancillary_to_faction(faction, ancillary, true)
	end
	
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("treasure_map_list", treasure_map_list, context);
		cm:save_named_value("map_chance", map_chance, context);
		cm:save_named_value("active_treasure", active_treasure, context);
		cm:save_named_value("level3_missions", level3_missions, context);
		cm:save_named_value("map_chance_increase_per_turn", map_chance_increase_per_turn, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		treasure_map_list = cm:load_named_value("treasure_map_list", treasure_map_list, context);
		map_chance = cm:load_named_value("map_chance", 15, context);
		active_treasure = cm:load_named_value("active_treasure", 1, context);
		level3_missions = cm:load_named_value("level3_missions", 1, context);
		map_chance_increase_per_turn = cm:load_named_value("map_chance_increase_per_turn", 0, context);
	end
);