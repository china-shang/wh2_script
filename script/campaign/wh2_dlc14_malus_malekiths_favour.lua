local malus_faction = "wh2_main_def_hag_graef";
local malekith_faction = "wh2_main_def_naggarond";
local malus_character_spawned = false;

function add_malus_malekiths_favour_listeners()
	out("#### Adding Malus Malekith's Favour Listeners ####");

	local malus_interface = cm:model():world():faction_by_key(malus_faction); 
	local malekith_interface = cm:model():world():faction_by_key(malekith_faction); 

	--check if Malus is human
	if malus_interface:is_null_interface() == false and malus_interface:is_human() == true then

		if cm:is_new_game() == true then
			local secondary_army = cm:get_closest_character_to_position_from_faction(malus_faction, 195, 612, true, false);
			cm:disable_event_feed_events(true, "", "wh_event_subcategory_character_development", "");
			cm:modify_character_personal_loyalty_factor(cm:char_lookup_str(secondary_army), 10);
			out.design("### Loyalty for secondary character set to 10 ###")
			cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_character_development", "") end, 0.5);
		end

		core:add_listener(
			"Malus_trigger_dilemma",
			"CharacterPerformsSettlementOccupationDecision",
			function(context)
				local faction = context:character():faction():name();
				local region = context:garrison_residence():region():name();
				local occupation_option = tostring(context:occupation_decision());
				--occupy or loot and occupy
				if occupation_option == "1027" or occupation_option == "1024" then
					-- check if Hag Graef is owned and that its not its beyond turn 5:  
					--##### Making assumption player doesnt take 5 turns to take first region and doesnt lose it and have to retake it within those 5 turns #####
					if cm:model():campaign_name("main_warhammer") == true and cm:turn_number() <= 5 then 
						local hag_graef_owned_by_malus = cm:is_region_owned_by_faction("wh2_main_the_black_flood_hag_graef", malus_faction);
						return faction == malus_faction and region == "wh2_main_dragon_isles_dragon_fang_mount" and hag_graef_owned_by_malus;
					elseif cm:model():campaign_name("wh2_main_great_vortex") == true and cm:turn_number() <= 5 then
						local hag_graef_owned_by_malus = cm:is_region_owned_by_faction("wh2_main_vor_the_black_flood_hag_graef", malus_faction);
						return faction == malus_faction and region == "wh2_main_vor_sea_of_dread_tower_of_the_sun" and hag_graef_owned_by_malus;
					end
					return false;
				end
			end,
			function(context)
				cm:trigger_dilemma(malus_faction, "wh2_dlc14_malus_start_dilemma");
			end,
			true
		);
		core:add_listener(
			"Malus_DilemmaChoiceMadeEvent",
			"DilemmaChoiceMadeEvent",
			function(context)
				return context:dilemma() == "wh2_dlc14_malus_start_dilemma";
			end,
			function(context)
				local choice = context:choice();

				if choice == 0 then
					hag_graef_region_change();	
					local secondary_army = cm:get_closest_character_to_position_from_faction(malus_faction, 195, 612, true, false);		
								
					if secondary_army:has_region() then 
						if secondary_army:region():name() == "wh2_main_the_black_flood_hag_graef" or secondary_army:region():name() == "wh2_main_vor_the_black_flood_hag_graef" then
							cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
							cm:kill_character(secondary_army:command_queue_index(), true, false);
							cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
						end
					end
				end
			end,
			true
		);
	else
		if cm:is_new_game() == true then

			--give region to Malus before he loses Hag Graef
			if cm:model():campaign_name("main_warhammer") == true then 
				region_change("wh2_main_dragon_isles_dragon_fang_mount", malus_faction);
			elseif cm:model():campaign_name("wh2_main_great_vortex") == true then
				region_change("wh2_main_vor_sea_of_dread_tower_of_the_sun", malus_faction);
			end
			--give away Hag Graef
			hag_graef_region_change();
			local secondary_army = cm:get_closest_character_to_position_from_faction(malus_faction, 195, 612, true, false);
			cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
			cm:kill_character(secondary_army:command_queue_index(), true, false);
			cm:disable_event_feed_events(false, "wh_event_category_character", "", "");
		end
	end
	core:add_listener(
		"Malus_quest_spawn_beastmen",
		"MissionIssued",
		function(context)
			return context:mission():mission_record_key():find("def_malus_warpsword_of_khaine_stage_2");
		end,
		function(context)
			local mission_key = context:mission():mission_record_key();
			
			--declaring following 4 variables for use if the correct mission is found
			local quest_faction = "wh_dlc03_bst_beastmen_qb1";
			local quest_unit_list = "wh_dlc03_bst_cha_bray_shaman_beasts_0,wh_dlc03_bst_inf_ungor_herd_1,wh_dlc03_bst_inf_ungor_herd_1,wh_dlc03_bst_inf_ungor_herd_1,wh_dlc03_bst_inf_ungor_raiders_0,wh_dlc03_bst_inf_ungor_raiders_0,wh_dlc03_bst_inf_gor_herd_0,wh_dlc03_bst_inf_gor_herd_0,wh_dlc03_bst_inf_chaos_warhounds_0,wh_dlc03_bst_inf_chaos_warhounds_0,wh_dlc03_bst_mon_chaos_spawn_0,wh_dlc03_bst_inf_minotaurs_1";
			local quest_spawn_pos = {x = 0, y = 0};
			local quest_patrol = {{x = 1, y = 1}, {x = 0, y = 0}};
			local mission_check_bool = false;
			
			if (mission_key == "wh2_dlc14_vortex_def_malus_warpsword_of_khaine_stage_2") then --checks the campaign and mission then spawn army
				quest_spawn_pos = {x = 600, y = 65};
				quest_patrol = {{x = 600, y = 65}, {x = 543, y = 30}};
				mission_check_bool = true;
			elseif (mission_key == "wh2_dlc14_main_def_malus_warpsword_of_khaine_stage_2") then
				quest_spawn_pos = {x = 694, y = 290};
				quest_patrol = {{x = 682, y = 248}, {x = 694, y = 290}};
				mission_check_bool = true;
			end;
			
			if (mission_check_bool) then
				--create new army for targeting before creating mission
				local quest_inv = invasion_manager:new_invasion("malus_quest_inv", quest_faction, quest_unit_list, quest_spawn_pos);
				quest_inv:set_target("PATROL", quest_patrol);
				--quest_inv:add_aggro_radius(300, {malus_faction}, 5, 3);
				quest_inv:create_general(false, "dlc03_bst_beastlord", "names_name_2147358597", "", "names_name_2147358622", "");
				quest_inv:start_invasion(nil,false,false,false);
				
				cm:force_diplomacy("all", "faction:"..quest_faction, "all", false, false, true);						--set all factions to not do diplomacy with inv faction
				cm:force_diplomacy("faction:"..quest_faction, "all", "all", false, false, true);						--set inv faction to not do diplomacy with all factions 
			end;
		end,
		true
	);
	core:add_listener(
		"Malus_quest_declare_war_beastmen",
		"MissionIssued",
		function(context)
			return context:mission():mission_record_key():find("def_malus_warpsword_of_khaine_stage_3");
		end,
		function(context)
			cm:force_declare_war(malus_faction, "wh_dlc03_bst_beastmen_qb1", true, true);	
		end,
		true
	);	
	core:add_listener(
		"Malus_quest_kill_beastmen",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key():find("def_malus_warpsword_of_khaine_stage_3");
		end,
		function(context)
			cm:kill_all_armies_for_faction(cm:get_faction("wh_dlc03_bst_beastmen_qb1")); --kill army for faction after mission completed
		end,
		true
	);	
	--Adding catch for beastmen army not existing when attempting to start stage 3
		core:add_listener(
		"Malus_quest_generation_fallback",
		"MissionGenerationFailed",
		true,
		function(context)
			local mission = context:mission();
			out.design("\n\n\t\t print the mission id here: "..mission.."\n");
			if mission:find("wh2_dlc14_vortex_def_malus_warpsword_of_khaine_stage_3") then
				cm:trigger_mission(malus_faction, "wh2_dlc14_vortex_def_malus_warpsword_of_khaine_stage_4", true);
			elseif mission:find("wh2_dlc14_main_def_malus_warpsword_of_khaine_stage_3") then
				cm:trigger_mission(malus_faction, "wh2_dlc14_main_def_malus_warpsword_of_khaine_stage_4", true);
			end
		end,
		true
	);
	

	core:add_listener(
		"malus_RitualCompletedEvent",
		"RitualCompletedEvent",
		function(context)
			return context:succeeded();
		end,
		function(context)
			local faction = context:performing_faction();
			local faction_key = faction:name();
			local ritual = context:ritual():ritual_key();
			
			if ritual == "wh2_dlc14_ritual_def_witch_king" then
				if faction:is_human() == true then
					cm:trigger_dilemma(faction_key, "wh2_dlc14_def_witch_king_agent_select");
				else
					local agent_rand = cm:random_number(100);
	
					if agent_rand > 75 then
						-- Death Hag
						rite_agent_spawn(faction_key, "dignitary", "wh2_main_def_death_hag");
					elseif agent_rand > 50 then
						-- Khainite Assassin
						rite_agent_spawn(faction_key, "spy", "wh2_main_def_khainite_assassin");
					elseif agent_rand > 25 then
						-- Sorceress
						local sorceress_rand = cm:random_number(75);
						if sorceress_rand > 50 then
							rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_dark");
						elseif sorceress_rand > 25 then
							rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_fire");
						else
							rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_shadow");
						end
					else
						-- Master
						rite_agent_spawn(faction_key, "champion", "wh2_dlc14_def_master");
					end
				end
			end
		end,
		true
	);
	core:add_listener(
		"malus_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		function(context)
			return context:dilemma() == "wh2_dlc14_def_witch_king_agent_select";
		end,
		function(context)
			local faction_key = context:faction():name();
			local choice = context:choice();
	
			if choice == 0 then
				-- Death Hag
				rite_agent_spawn(faction_key, "dignitary", "wh2_main_def_death_hag");
			elseif choice == 1 then
				-- Khainite Assassin
				rite_agent_spawn(faction_key, "spy", "wh2_main_def_khainite_assassin");
			elseif choice == 2 then
				-- Sorceress
				local sorceress_rand = cm:random_number(75);
				if sorceress_rand > 50 then
					rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_dark");
				elseif sorceress_rand > 25 then
					rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_fire");
				else
					rite_agent_spawn(faction_key, "wizard", "wh2_main_def_sorceress_shadow");
				end
			else
				-- Master
				rite_agent_spawn(faction_key, "champion", "wh2_dlc14_def_master");
			end

		end,
		true
	);
	core:add_listener(
		"malus_CharacterCreated",
		"CharacterCreated",
		function(context)
			local faction = context:character():faction():name();
			return faction == malus_faction and rite_character_spawned == true;
		end,
		function(context)
			local character = context:character();
			local malekith_interface = cm:model():world():faction_by_key(malekith_faction);
			local rank = 0;

			if malekith_interface:is_null_interface() == false then
				rank = malekith_interface:region_list():num_items() + 1;
			end

			if rank > 0 then
				-- be careful if its above rank 40 it explodes
				if rank > 39 then
					cm:add_agent_experience(cm:char_lookup_str(character), 40, true);
				else
					cm:add_agent_experience(cm:char_lookup_str(character), rank, true);
				end
			end
			rite_character_spawned = false;
		end,
		true
	);
end

function hag_graef_region_change()
	local hag_graef_new_owner = "";
	local malekith_interface = cm:model():world():faction_by_key(malekith_faction); 
	
	if malekith_interface:is_null_interface() == false and malekith_interface:is_human() == true then
		hag_graef_new_owner = "wh2_main_def_clar_karond";
	else
		hag_graef_new_owner = malekith_faction;
	end
	
	if cm:model():campaign_name("main_warhammer") == true then 
		region_change("wh2_main_the_black_flood_hag_graef", hag_graef_new_owner);
	elseif cm:model():campaign_name("wh2_main_great_vortex") == true then
		region_change("wh2_main_vor_the_black_flood_hag_graef", hag_graef_new_owner);
	end
end

function region_change(region, faction)
	
	local region_name = region;
	local faction_name = faction;
	
	--check the region key is a string
	if not is_string(region_name) then
		script_error("ERROR: region_change() called but supplied target region key [" .. tostring(region_name) .. "] is not a string");
		return false;
	end;
	
	--check the faction key is a string
	if not is_string(faction_name) then
		script_error("ERROR: region_change() called but supplied target faction key [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end
	cm:disable_event_feed_events(true, "wh_event_category_conquest", "", "")
		
	cm:transfer_region_to_faction(region_name, faction_name);
	cm:callback(
		function() 
		cm:heal_garrison(cm:get_region(region_name):cqi());
		cm:disable_event_feed_events(false, "wh_event_category_conquest", "", "");
		end, 0.5
	);
end