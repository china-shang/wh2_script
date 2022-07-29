local books_collected = 0;
local books_collected_list = {};
local books_mission_regions = {};
local books_mission_characters = {};
local books_mission_factions = {};
local books_faction_specific = true;
local books_vfx_key = "scripted_effect3";

local book_objective_overrides = {
	["CAPTURE_REGIONS"] = "wh2_dlc09_objective_override_occupy_settlement",
	["ENGAGE_FORCE"] = "wh2_dlc09_objective_override_defeat_rogue_army"
};

core:add_listener(
	"NagashBooks_MissionSucceeded",
	"MissionSucceeded",
	true,
	function(context)
		if cm:model():campaign_name("wh2_main_great_vortex") then
			if cm:is_multiplayer() == false then
				NagashBooks_MissionSucceeded(context);
			else
				NagashBooks_MissionSucceeded_MP(context);
			end
		else
			NagashBooks_MissionSucceeded_ME(context);
		end
	end,
	true
);

function add_nagash_books_listeners()
	out("#### Adding Books of Nagash Listeners ####");
	if cm:model():campaign_name("main_warhammer") then
		-- Sets lists for Mortal Empires
		book_objective_list = book_objective_list_grand;
		book_objective_list_faction = book_objective_list_faction_grand;
	else
		-- show the epilogue event in vortex campaign
		local human_factions = cm:get_human_factions();
		
		for i = 1, #human_factions do
			if cm:get_faction(human_factions[i]):culture() == "wh2_dlc09_tmb_tomb_kings" then
				core:add_listener(
					"epilogue_tomb_kings",
					"ScriptEventShowEpilogueEvent_" .. human_factions[i],
					true,
					function(context)
						local faction_name = context.string;
						local secondary_detail = "event_feed_strings_text_wh2_event_feed_string_scripted_event_epilogue_secondary_detail_tmb";
						
						if faction_name == "wh2_dlc09_tmb_followers_of_nagash" then
							secondary_detail = secondary_detail .. "_arkhan";
						end;
						
						cm:show_message_event(
							faction_name,
							"event_feed_strings_text_wh2_event_feed_string_scripted_event_epilogue_primary_detail",
							"",
							secondary_detail,
							true,
							910
						);
					end,
					false
				);
			end
		end
	end
	
	-- SINGLEPLAYER
	if cm:is_multiplayer() == false then
		if cm:is_new_game() == true then
			local player_faction = cm:get_local_faction_name();
			
			if player_faction then
				if cm:get_faction(player_faction):culture() == "wh2_dlc09_tmb_tomb_kings" then
					setup_book_missions(player_faction, true, false);
				end
			end
		end
	-- MULTIPLAYER
	else
		if cm:is_new_game() == true then
			local human_factions = cm:get_human_factions();
			local not_yet_spawned = true;
			
			for i = 1, #human_factions do
				if cm:get_faction(human_factions[i]):culture() == "wh2_dlc09_tmb_tomb_kings" then
					setup_book_missions(human_factions[i], not_yet_spawned, true);
					not_yet_spawned = false;
				end
			end
		end
	end
end

function setup_book_missions(faction_key, spawn_forces, is_MP)
	cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_missions_objectives", "");
	
	if books_faction_specific == true and is_MP == false then
		-- Switch the books to specific locations for certain factions in singleplayer
		if book_objective_list_faction[faction_key] ~= nil then
			book_objective_list = book_objective_list_faction[faction_key];
		end
	end
	
	-- Create the book objectives
	local book_objective_count = #book_objective_list;
	
	for i = 1, book_objective_count do
		local mm = mission_manager:new(faction_key, "wh2_dlc09_books_of_nagash_"..i);
		
		local book_objective_number = cm:random_number(#book_objective_list);
		
		if is_MP == true then
			book_objective_number = i;
		end
		
		local book_objective = book_objective_list[book_objective_number];
		
		mm:add_new_objective(book_objective.objective);
		
		mm:set_mission_issuer("BOOK_NAGASH");
		
		if book_objective.objective == "CAPTURE_REGIONS" then
			mm:add_condition("region "..book_objective.target);
			mm:add_condition("ignore_allies");
			
			books_mission_regions["wh2_dlc09_books_of_nagash_"..i] = book_objective.target;
			
			local region = cm:model():world():region_manager():region_by_key(book_objective.target);
			local garrison_residence = region:garrison_residence();
			local garrison_residence_CQI = garrison_residence:command_queue_index();
			cm:add_garrison_residence_vfx(garrison_residence_CQI, books_vfx_key, true);
			out("Adding scripted VFX to garrison...\n\tGarrison CQI: "..garrison_residence_CQI.."\n\tVFX: "..books_vfx_key);
		elseif book_objective.objective == "ENGAGE_FORCE" then
			if spawn_forces == true then
				cm:spawn_rogue_army(book_objective.target, book_objective.pos.x, book_objective.pos.y);
				cm:force_diplomacy("all", "faction:"..book_objective.target, "all", false, false, true);
				
				if book_objective.patrol ~= nil then
					out("Setting patrol path for "..book_objective.target);
					local im = invasion_manager;
					local rogue_force = cm:get_faction(book_objective.target):faction_leader():military_force();
					local book_patrol = im:new_invasion_from_existing_force("BOOK_PATROL_"..book_objective.target, rogue_force);
					book_patrol:set_target("PATROL", book_objective.patrol);
					book_patrol:apply_effect("wh2_dlc09_bundle_book_rogue_army", -1);
					book_patrol:start_invasion();
				end
			end
			cm:force_diplomacy("faction:"..faction_key, "faction:"..book_objective.target, "war", true, true, false);
			
			local force_cqi = cm:get_faction(book_objective.target):faction_leader():military_force():command_queue_index();
			mm:add_condition("cqi "..force_cqi);
			mm:add_condition("requires_victory");
			
			local leader_cqi = cm:get_faction(book_objective.target):faction_leader():command_queue_index();
			out("Adding scripted VFX to character...\n\tCharacter CQI: "..leader_cqi.."\n\tVFX: "..books_vfx_key);
			cm:add_character_vfx(leader_cqi, books_vfx_key, true);
			
			books_mission_characters["wh2_dlc09_books_of_nagash_"..i] = leader_cqi;
			books_mission_factions["wh2_dlc09_books_of_nagash_"..i] = book_objective.target;
		end
		
		if book_objective_overrides[book_objective.objective] ~= nil then
			mm:add_condition("override_text mission_text_text_"..book_objective_overrides[book_objective.objective]);
		end
		
		mm:add_payload("effect_bundle{bundle_key wh2_dlc09_books_of_nagash_reward_"..i..";turns 0;}");
		mm:set_should_whitelist(false);
		mm:trigger();
		
		if is_MP == false then
			table.remove(book_objective_list, book_objective_number);
		end
	end
	
	local is_arkhan = (faction_key == "wh2_dlc09_tmb_followers_of_nagash");
	local mm2 = mission_manager:new(faction_key, "wh2_dlc09_books_of_nagash_9");
	mm2:add_new_objective("SCRIPTED");
	mm2:add_condition("script_key arkhan_book_mission_"..faction_key);
	
	if is_arkhan then
		mm2:add_condition("override_text mission_text_text_wh2_dlc09_objective_override_arkhan_book_owned");
	else
		mm2:add_condition("override_text mission_text_text_wh2_dlc09_objective_override_arkhan_book");
	end
	
	mm2:add_payload("effect_bundle{bundle_key wh2_dlc09_books_of_nagash_reward_9;turns 0;}");
	mm2:set_should_whitelist(false);
	mm2:trigger();
	cm:complete_scripted_mission_objective("wh2_dlc09_books_of_nagash_9", "arkhan_book_mission_"..faction_key, is_arkhan);
	
	cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_faction_missions_objectives", "") end, 1);
end

function NagashBooks_MissionSucceeded(context)
	local faction_key = context:faction():name();
	local mission_key = context:mission():mission_record_key();
	
	if mission_key:starts_with("wh2_dlc09_books_of_nagash_") then
		core:trigger_event("ScriptEventBookOfNagashAcquired");
		books_collected = books_collected + 1;
		nagashbooks_play_movie(faction_key, books_collected);
		
		local book_number = string.gsub(mission_key, "wh2_dlc09_books_of_nagash_", "");
		out(faction_key.." completed book mission "..mission_key.." (#"..book_number..") - SP");
		
		local book_objective_key = "collect_books_of_nagash_"..faction_key_to_book_key(faction_key);
		out("\tBook objective key: "..book_objective_key);
		
		if books_collected <= 5 then
			cm:set_scripted_mission_text("wh_main_long_victory", book_objective_key, "mission_text_text_mis_activity_collect_books_of_nagash_"..books_collected);
		end
		
		if books_collected == 5 then
			cm:complete_scripted_mission_objective("wh_main_long_victory", book_objective_key, true);
			trigger_final_book_battle(faction_key);
		end
		
		remove_book_region_vfx(mission_key);
		remove_book_character_vfx(mission_key);
		books_mission_factions[mission_key] = nil;
	elseif mission_key == "wh2_dlc09_great_vortex_tmb_arkhan_the_staff_of_nagash_stage_5" then
		cm:trigger_mission(faction_key, "wh2_dlc09_qb_tmb_final_battle_arkhan", true);
		nagashbooks_update_black_pyramid(faction_key);
		nagashbooks_play_movie(faction_key, 6, true);
	elseif mission_key:starts_with("wh2_dlc09_qb_tmb_final_battle_") then
		cm:trigger_incident(faction_key, "wh2_dlc09_incident_tmb_campaign_won", true);
		nagashbooks_play_movie(faction_key, 5, false, true);
		cm:add_turn_countdown_event(faction_key, 2, "ScriptEventShowEpilogueEvent_" .. faction_key, faction_key);
	end
end

function NagashBooks_MissionSucceeded_ME(context)
	local mission_key = context:mission():mission_record_key();
	remove_book_region_vfx(mission_key);
	remove_book_character_vfx(mission_key);
	books_mission_factions[mission_key] = nil;
end

function NagashBooks_MissionSucceeded_MP(context)
	local faction_key = context:faction():name();
	local mission_key = context:mission():mission_record_key();
	
	if mission_key:starts_with("wh2_dlc09_books_of_nagash_") then
		books_collected = books_collected + 1;
		local book_number = string.gsub(mission_key, "wh2_dlc09_books_of_nagash_", "");
		local coop = false;
		
		if cm:model():campaign_type() == 4 then
			coop = true;
			out(faction_key.." completed book mission "..mission_key.." (#"..book_number..") - MP Coop");
		else
			out(faction_key.." completed book mission "..mission_key.." (#"..book_number..") - MP H2H");
		end
		
		local book_objective_key = "collect_books_of_nagash_"..faction_key_to_book_key(faction_key);
		
		if coop == true then
			-- Coop
			books_collected_list[faction_key] = books_collected_list[faction_key] or 0;
			books_collected_list[faction_key] = books_collected_list[faction_key] + 1;
			
			book_objective_key = "collect_books_of_nagash_coop";
			out("\tBook objective key: "..book_objective_key);
			out("\tbooks_collected: "..books_collected);
			
			if books_collected <= 8 then
				cm:set_scripted_mission_text("wh_main_mp_coop_victory", book_objective_key, "mission_text_text_mis_activity_collect_books_of_nagash_coop_"..books_collected);
			end
			
			if books_collected == 5 then
				trigger_final_book_battle(faction_key);
			elseif books_collected == 8 then
				cm:complete_scripted_mission_objective("wh_main_mp_coop_victory", book_objective_key, true);
				nagashbooks_update_black_pyramid(faction_key);
			end
		else
			-- Head To Head
			books_collected_list[faction_key] = books_collected_list[faction_key] or 0;
			books_collected_list[faction_key] = books_collected_list[faction_key] + 1;
			
			local book_objective_key = "collect_books_of_nagash_"..faction_key_to_book_key(faction_key);
			out("\tBook objective key: "..book_objective_key);
			out("\tbooks_collected: "..books_collected);
			
			if books_collected_list[faction_key] <= 5 then
				cm:set_scripted_mission_text("wh_main_mp_versus_victory", book_objective_key, "mission_text_text_mis_activity_collect_books_of_nagash_"..books_collected_list[faction_key]);
			end
			
			if books_collected_list[faction_key] == 5 then
				cm:complete_scripted_mission_objective("wh_main_mp_versus_victory", book_objective_key, true);
				nagashbooks_update_black_pyramid(faction_key);
				trigger_final_book_battle(faction_key);
			end
		end
		
		abort_other_players_mission(mission_key, faction_key);
		remove_book_region_vfx(mission_key);
		remove_book_character_vfx(mission_key);
		books_mission_factions[mission_key] = nil;
	end
end

function trigger_final_book_battle(faction_key)
	local mission_key = "";
	
	if cm:is_multiplayer() == false then
		if faction_key == "wh2_dlc09_tmb_khemri" then
			-- SETTRA
			mission_key = "wh2_dlc09_qb_tmb_final_battle_settra";
			nagashbooks_update_black_pyramid(faction_key);
		elseif faction_key == "wh2_dlc09_tmb_lybaras" then
			-- KHALIDA
			mission_key = "wh2_dlc09_qb_tmb_final_battle_khalida";
			nagashbooks_update_black_pyramid(faction_key);
		elseif faction_key == "wh2_dlc09_tmb_exiles_of_nehek" then
			-- KHATEP
			mission_key = "wh2_dlc09_qb_tmb_final_battle_khatep";
			nagashbooks_update_black_pyramid(faction_key);
		end
	end
	
	if faction_key == "wh2_dlc09_tmb_followers_of_nagash" then
		-- ARKHAN
		mission_key = "wh2_dlc09_great_vortex_tmb_arkhan_the_staff_of_nagash_stage_5";
		
		if cm:model():campaign_name("main_warhammer") then
			mission_key = "wh2_dlc09_qb_tmb_arkhan_the_staff_of_nagash_stage_5";
		end
		
		local x = 599;
		local y = 257;
		
		if cm:model():campaign_name("main_warhammer") then
			x = 558;
			y = 42;
		end
		
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_staff_of_nagash_title",
			"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_staff_of_nagash_primary_detail",
			"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_staff_of_nagash_secondary_detail",
			x,
			y,
			true,
			906
		);
	end
	
	if mission_key ~= "" then
		cm:trigger_mission(faction_key, mission_key, true);
	end
end

function abort_other_players_mission(mission_key, exclude_faction)
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		if human_factions[i] ~= exclude_faction then
			cm:cancel_custom_mission(human_factions[i], mission_key);
		end
	end
end

function faction_key_to_book_key(faction_key)
	if faction_key == "wh2_dlc09_tmb_khemri" then
		return "settra";
	elseif faction_key == "wh2_dlc09_tmb_lybaras" then
		return "khalida";
	elseif faction_key == "wh2_dlc09_tmb_exiles_of_nehek" then
		return "khatep";
	elseif faction_key == "wh2_dlc09_tmb_followers_of_nagash" then
		return "arkhan";
	end
end

function nagashbooks_update_black_pyramid(faction_key)
	local buildings = {
		"wh2_dlc09_special_settlement_pyramid_of_nagash_tmb",
		"wh2_main_special_settlement_pyramid_of_nagash_brt",
		"wh2_main_special_settlement_pyramid_of_nagash_def",
		"wh2_main_special_settlement_pyramid_of_nagash_dwf",
		"wh2_main_special_settlement_pyramid_of_nagash_emp",
		"wh2_main_special_settlement_pyramid_of_nagash_grn",
		"wh2_main_special_settlement_pyramid_of_nagash_hef",
		"wh2_main_special_settlement_pyramid_of_nagash_lzd",
		"wh2_main_special_settlement_pyramid_of_nagash_norsca",
		"wh2_main_special_settlement_pyramid_of_nagash_savage",
		"wh2_main_special_settlement_pyramid_of_nagash_skv",
		"wh2_main_special_settlement_pyramid_of_nagash_vmp",
	};
	
	-- Make the Black Pyramid fly!
	for i = 1, #buildings do
		cm:override_building_chain_display(buildings[i], "wh2_dlc09_special_settlement_pyramid_of_nagash_floating");
	end
	
	local x = 628;
	local y = 264;
	
	if cm:model():campaign_name("main_warhammer") then
		x = 584;
		y = 74;
	end
	
	cm:show_message_event_located(
		faction_key,
		"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_black_pyramid_flying_title",
		"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_black_pyramid_flying_primary_detail",
		"event_feed_strings_text_wh2_dlc09_event_feed_string_scripted_event_black_pyramid_flying_secondary_detail",
		x,
		y,
		true,
		905
	);
end

function remove_book_region_vfx(mission_key)
	if books_mission_regions[mission_key] ~= nil then
		local region_key = books_mission_regions[mission_key];
		local region = cm:model():world():region_manager():region_by_key(region_key);
		local garrison_residence = region:garrison_residence();
		local garrison_residence_CQI = garrison_residence:command_queue_index();
		cm:remove_garrison_residence_vfx(garrison_residence_CQI, books_vfx_key);
	end
end

function remove_book_character_vfx(mission_key)
	if books_mission_characters[mission_key] ~= nil then
		local character_cqi = books_mission_characters[mission_key];
		cm:remove_character_vfx(character_cqi, books_vfx_key);
	end
end

function nagashbooks_play_movie(faction_name, book_number, staff_of_nagash, won)	
	local movie_str = "warhammer2/tmb/book_";
	local is_arkhan = (faction_name == "wh2_dlc09_tmb_followers_of_nagash");
	
	if is_arkhan and not won then
		book_number = book_number - 1;
	end;
	
	if book_number > 5 or not book_number or book_number == 0 then
		return;
	elseif book_number < 5 then
		movie_str = movie_str .. tostring(book_number);
	else
		if won then
			movie_str = movie_str:gsub("book_", "win");
		else
			if is_arkhan and not staff_of_nagash then
				return; -- collected 5 books already but haven't won the staff of nagash yet - don't play anything
			end;
			
			movie_str = movie_str:gsub("book_", "battle");
		end;
		
		if faction_name == "wh2_dlc09_tmb_khemri" then
			movie_str = movie_str .. "_settra";
		elseif faction_name == "wh2_dlc09_tmb_lybaras" then
			movie_str = movie_str .. "_khalida";
		elseif faction_name == "wh2_dlc09_tmb_exiles_of_nehek" then
			movie_str = movie_str .. "_khatep";
		end;
	end;
	
	if is_arkhan then
		movie_str = movie_str .. "_arkhan";
	end;
	
	core:svr_save_registry_bool(movie_str:gsub("warhammer2/tmb/", ""), true);
	
	cm:progress_on_battle_completed(
		"nagashbooks_movie_" .. movie_str,
		function()
			cm:register_instant_movie(movie_str);
		end,
		0.5
	);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("books_collected", books_collected, context);
		cm:save_named_value("books_collected_list", books_collected_list, context);
		cm:save_named_value("books_mission_regions", books_mission_regions, context);
		cm:save_named_value("books_mission_characters", books_mission_characters, context);
		cm:save_named_value("books_mission_factions", books_mission_factions, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		books_collected = cm:load_named_value("books_collected", 0, context);
		books_collected_list = cm:load_named_value("books_collected_list", books_collected_list, context);
		books_mission_regions = cm:load_named_value("books_mission_regions", books_mission_regions, context);
		books_mission_characters = cm:load_named_value("books_mission_characters", books_mission_characters, context);
		books_mission_factions = cm:load_named_value("books_mission_factions", books_mission_factions, context);
	end
);