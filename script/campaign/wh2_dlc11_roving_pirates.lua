local roving_pirates = {
	["wh2_main_great_vortex"] = {
		{faction_key = "wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast",	spawn_pos = {x = 372, y = 329},	effect = "wh_main_reduced_movement_range_20", xp = 0, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Ashuk da Bloody (Greenskin)
			patrol_route = {"start", {x = 352, y = 351}, {x = 349, y = 236}, {x = 298, y = 253}, {x = 298, y = 360}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_freebooters_of_port_royale",	spawn_pos = {x = 166, y = 340},	effect = "wh_main_reduced_movement_range_20", xp = 0, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Gentleman Jenkins (Empire)
			patrol_route = {"start", {x = 200, y = 334}, {x = 293, y = 382}, {x = 336, y = 307}, {x = 324, y = 293}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_the_churning_gulf_raiders",		spawn_pos = {x = 423, y = 226},	effect = "wh_main_reduced_movement_range_20", xp = 1, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Reik-Admiral Houghstein (Empire)
			patrol_route = {"start", {x = 380, y = 272}, {x = 371, y = 294}, {x = 327, y = 290}, {x = 311, y = 233}, {x = 362, y = 212}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_middle_sea_brigands",			spawn_pos = {x = 355, y = 370}, effect = "wh2_dlc11_bundle_shanty_pirate_01", xp = 1, level = 25, item_owned = "sea_shanty",		behaviour = "attack",	-- Mad Mulletsson (Norscan)
		},
		{faction_key = "wh2_dlc11_cst_rogue_bleak_coast_buccaneers",		spawn_pos = {x = 586, y = 388},	effect = "wh_main_reduced_movement_range_20", xp = 2, level = 25, item_owned = "piece_of_eight",	behaviour = "roving",	-- Black Buckthorn (Dwarf)
			patrol_route = {"start", {x = 500, y = 357}, {x = 333, y = 353}, {x = 410, y = 404}, {x = 578, y = 416}, {x = 646, y = 325}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_grey_point_scuttlers",			spawn_pos = {x = 442, y = 609},	effect = "wh_main_reduced_movement_range_20", xp = 2, level = 30, item_owned = "piece_of_eight",	behaviour = "roving",	-- Fhiron Wavemaker (High Elf)
			patrol_route = {"start", {x = 326, y = 556}, {x = 378, y = 526}, {x = 364, y = 576}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_dragon_spine_privateers",		spawn_pos = {x = 400, y = 370},	effect = "wh2_dlc11_bundle_shanty_pirate_02", xp = 3, level = 30, item_owned = "sea_shanty",		behaviour = "attack",	-- Sloppy Cruickshank (Skaven)
		},
		{faction_key = "wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean",	spawn_pos = {x = 95, y = 69},	effect = "wh_main_reduced_movement_range_20", xp = 3, level = 35, item_owned = "piece_of_eight",	behaviour = "roving",	-- Dastan Coldeye (Dark Elves)
			patrol_route = {"start", {x = 227, y = 442}, {x = 243, y = 409}, {x = 303, y = 412}, {x = 318, y = 449}, {x = 289, y = 473}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_terrors_of_the_dark_straights",	spawn_pos = {x = 694, y = 76},	effect = "wh_main_reduced_movement_range_20", xp = 4, level = 35, item_owned = "piece_of_eight",	behaviour = "roving",	-- Capitano Sisicco (Vampire Coast)
			patrol_route = {"start", {x = 318, y = 358}, {x = 376, y = 359}, {x = 412, y = 370}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_shark_straight_seadogs",		spawn_pos = {x = 445, y = 370},	effect = "wh2_dlc11_bundle_shanty_pirate_03", xp = 5, level = 40, item_owned = "sea_shanty",		behaviour = "attack",	-- Barron Von Heastie (Vampire Coast)
		}
	},
	["main_warhammer"] = {
		{faction_key = "wh2_dlc11_cst_rogue_boyz_of_the_forbidden_coast",	spawn_pos = {x = 310, y = 98},	effect = "wh_main_reduced_movement_range_20", xp = 0, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 290, y = 180}, {x = 144, y = 232}, {x = 140, y = 210}, {x = 264, y = 176}, {x = 294, y = 91}, {x = 338, y = 117}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_freebooters_of_port_royale",	spawn_pos = {x = 220, y = 237},	effect = "wh_main_reduced_movement_range_20", xp = 0, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 313, y = 230}, {x = 412, y = 216}, {x = 456, y = 164}, {x = 402, y = 144}, {x = 293, y = 162}, {x = 337, y = 84}, {x = 392, y = 157}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_the_churning_gulf_raiders",		spawn_pos = {x = 370, y = 223},	effect = "wh_main_reduced_movement_range_20", xp = 1, level = 20, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 371, y = 164}, {x = 418, y = 170}, {x = 441, y = 209}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_middle_sea_brigands",			spawn_pos = {x = 403, y = 205},	effect = "wh2_dlc11_bundle_shanty_pirate_01", xp = 1, level = 25, item_owned = "sea_shanty",		behaviour = "attack"	-- Sea Shanty
		},
		{faction_key = "wh2_dlc11_cst_rogue_bleak_coast_buccaneers",		spawn_pos = {x = 628, y = 318},	effect = "wh_main_reduced_movement_range_20", xp = 2, level = 25, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 382, y = 124}, {x = 336, y = 198}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_grey_point_scuttlers",			spawn_pos = {x = 383, y = 317},	effect = "wh_main_reduced_movement_range_20", xp = 2, level = 30, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 348, y = 295}, {x = 325, y = 326}, {x = 334, y = 380}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_dragon_spine_privateers",		spawn_pos = {x = 349, y = 320},	effect = "wh2_dlc11_bundle_shanty_pirate_02", xp = 3, level = 30, item_owned = "sea_shanty",		behaviour = "attack"	-- Sea Shanty
		},
		{faction_key = "wh2_dlc11_cst_rogue_tyrants_of_the_black_ocean",	spawn_pos = {x = 161, y = 452},	effect = "wh_main_reduced_movement_range_20", xp = 3, level = 35, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 321, y = 235}, {x = 332, y = 303}, {x = 344, y = 382}, {x = 275, y = 515}, {x = 344, y = 382}, {x = 332, y = 303}, {x = 321, y = 235}}
		},
		{faction_key = "wh2_dlc11_cst_rogue_terrors_of_the_dark_straights",	spawn_pos = {x = 283, y = 544},	effect = "wh_main_reduced_movement_range_20", xp = 4, level = 35, item_owned = "piece_of_eight",	behaviour = "roving",	-- Piece of Eight
			patrol_route = {"start", {x = 299, y = 513}, {x = 327, y = 478}, {x = 202, y = 477}, {x = 223, y = 530}}
		},
		{faction_key = "wh2_dlc11_cst_shanty_shark_straight_seadogs",		spawn_pos = {x = 415, y = 180},	effect = "wh2_dlc11_bundle_shanty_pirate_03", xp = 4, level = 40, item_owned = "sea_shanty",		behaviour = "attack"	-- Sea Shanty
		}
	}
};
local roving_pirates_aggro_radius = 300;
local roving_pirates_aggro_cooldown = 5;
local roving_pirates_aggro_abort = 3;

local vampire_coast_ror_mission_unlocks = {
	["wh2_dlc11_cst_vortex_harkon_quest_for_slann_gold_stage_4"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_harkon_quest_for_slann_gold_stage_4"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_vortex_noctilus_captain_roths_moondial_stage_4"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_noctilus_captain_roths_moondial_stage_4"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_great_vortex_cst_aranessa_krakens_bane_stage_5"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_aranessa_krakens_bane_stage_5"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_great_vortex_cst_cylostra_shifting_isles_high_elf"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_great_vortex_cst_cylostra_shifting_isles_bretonnia"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_cylostra_shifting_isles_high_elf"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0",
	["wh2_dlc11_cst_cylostra_shifting_isles_bretonnia"] = "wh2_dlc11_cst_mon_necrofex_colossus_ror_0"
};
local vampire_coast_ror_mission_winners = {};
local vampire_coast_ror = {
	"wh2_dlc11_cst_inf_zombie_deckhands_mob_ror_0",
	"wh2_dlc11_cst_inf_zombie_gunnery_mob_ror_0",
	"wh2_dlc11_cst_cav_deck_droppers_ror_0",
	"wh2_dlc11_cst_mon_mournguls_ror_0",
	"wh2_dlc11_cst_mon_rotting_prometheans_gunnery_mob_ror",
	"wh2_dlc11_cst_inf_deck_gunners_ror_0",
	"wh2_dlc11_cst_inf_depth_guard_ror_0",
	"wh2_dlc11_cst_mon_necrofex_colossus_ror_0"
};
local harpoon_mission_faction = "wh2_dlc11_cst_harpoon_the_sunken_land_corsairs";
local harpoon_mission_location = {
	["wh2_dlc11_cst_vampire_coast"] = {x = 327, y = 309},
	["wh2_dlc11_cst_pirates_of_sartosa"] = {x = 545, y = 380},
	["wh2_dlc11_cst_the_drowned"] = {x = 250, y = 405},
	["wh2_dlc11_cst_noctilus"] = {x = 428, y = 364}
};

function add_roving_pirates_listeners()
	out("#### Adding Roving Pirates Listeners ####");
	local campaign_name = "main_warhammer";
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		campaign_name = "wh2_main_great_vortex";
	end
	
	-- setup count for how many pieces of eight have been collected in sp
	if not cm:is_multiplayer() and not cm:get_saved_value("pieces_of_eight_collected_sp") then
		cm:set_saved_value("pieces_of_eight_collected_sp", 0);
	end
	
	if cm:is_new_game() == true then
		local human_factions = cm:get_human_factions();
		local human_vampire_coast = false;
		
		for i = 1, #human_factions do
			if human_factions[i] == "wh2_dlc11_cst_noctilus" or human_factions[i] == "wh2_dlc11_cst_pirates_of_sartosa" or human_factions[i] == "wh2_dlc11_cst_the_drowned" or human_factions[i] == "wh2_dlc11_cst_vampire_coast" then
				human_vampire_coast = true;
				
				if cm:is_multiplayer() == false and campaign_name == "wh2_main_great_vortex" then
					setup_harpoon_force(human_factions[i]);
				end
				break;
			end
		end
		setup_roving_pirates(human_vampire_coast);
		
		-- Lock all ROR
		local ror_lock_factions = {"wh2_dlc11_cst_noctilus", "wh2_dlc11_cst_pirates_of_sartosa", "wh2_dlc11_cst_the_drowned", "wh2_dlc11_cst_vampire_coast"};
		
		for i = 1, #ror_lock_factions do
			for j = 1, #vampire_coast_ror do
				cm:add_event_restricted_unit_record_for_faction(vampire_coast_ror[j], ror_lock_factions[i], "dlc11_ror_unlock_reason_"..j);
			end
		end
	end
	
	-- Add mission unlocks for ROR
	for i = 1, 7 do
		vampire_coast_ror_mission_unlocks["wh2_dlc11_mission_piece_of_eight_"..i] = vampire_coast_ror[i];
	end
	
	core:add_listener(
		"PieceOfEight_MissionSucceeded",
		"MissionSucceeded",
		true,
		function(context)
			piece_of_eight_completed(context);
		end,
		true
	);
	
	-- Add listener for a Pirate being respawned, so we can restart missions for those who haven't completed them
	core:add_listener(
		"PieceOfEight_Respawn",
		"ScriptEventInvasionManagerRespawn",
		true,
		function(context)
			piece_of_eight_respawn(context);
		end,
		true
	);
end

core:add_listener(
	"HarpoonPendingBattle",
	"PendingBattle",
	function(context) return cm:is_multiplayer() == false end,
	function(context)
		harpoon_pending_battle(context);
	end,
	true
);
core:add_listener(
	"HarpoonCompletedBattle",
	"ScriptEventPlayerBattleSequenceCompleted",
	function(context) return cm:is_multiplayer() == false end,
	function(context)
		harpoon_completed_battle(context);
	end,
	true
);

function setup_roving_pirates(human_vampire_coast)
	local campaign_name = "main_warhammer";
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		campaign_name = "wh2_main_great_vortex";
	end
	
	local piece_of_eight_mission_count = 1;
	local human_factions = cm:get_human_factions();
	cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_missions_objectives", "");
	
	for i = 1, #roving_pirates[campaign_name] do
		local pirate = roving_pirates[campaign_name][i];
		local invasion_key = pirate.faction_key.."_PIRATE";
		
		-- Spawn force and create patrol route invasion
		if pirate.behaviour == "roving" then
			cm:spawn_rogue_army(pirate.faction_key, pirate.spawn_pos.x, pirate.spawn_pos.y);
			
			cm:force_diplomacy("all", "faction:"..pirate.faction_key, "all", false, false, true);
			cm:force_diplomacy("all", "faction:"..pirate.faction_key, "payments", false, false, true);
			for j = 1, #human_factions do
				local faction_key = human_factions[j];
				cm:force_diplomacy("faction:"..faction_key, "faction:"..pirate.faction_key, "war", true, true, false);
				cm:force_diplomacy("faction:"..pirate.faction_key, "faction:"..faction_key, "war", false, false, false);
			end
			
			local rogue_force = cm:get_faction(pirate.faction_key):faction_leader():military_force();
			local roving_pirate = invasion_manager:new_invasion_from_existing_force(invasion_key, rogue_force);
			
			roving_pirate:set_target("PATROL", pirate.patrol_route);
			roving_pirate:add_aggro_radius(roving_pirates_aggro_radius, human_factions, roving_pirates_aggro_cooldown, roving_pirates_aggro_abort);
			
			if pirate.effect ~= nil and pirate.effect ~= "" then
				roving_pirate:apply_effect(pirate.effect, -1);
			end
			if pirate.xp ~= nil and pirate.xp > 0 then
				roving_pirate:add_unit_experience(pirate.xp);
			end
			if pirate.level ~= nil and pirate.level > 0 then
				roving_pirate:add_character_experience(pirate.level, true);
			end
			
			if cm:model():campaign_name("main_warhammer") == false then
				if cm:is_multiplayer() == false then
					roving_pirate:add_respawn(true, 3, 20);
				else
					roving_pirate:add_respawn(true, -1, 20);
				end
			end
			roving_pirate:should_maintain_army(true, 50);
			roving_pirate:start_invasion();
		end
		
		-- Trigger Piece of Eight missions
		if pirate.item_owned == "piece_of_eight" and human_vampire_coast == true then
			local pirate_force = cm:get_faction(pirate.faction_key):faction_leader():military_force();
			
			for j = 1, #human_factions do
				local faction_key = human_factions[j];
				
				if faction_key == "wh2_dlc11_cst_noctilus" or faction_key == "wh2_dlc11_cst_pirates_of_sartosa" or faction_key == "wh2_dlc11_cst_the_drowned" or faction_key == "wh2_dlc11_cst_vampire_coast" then
					local mission_key = "wh2_dlc11_mission_piece_of_eight_"..piece_of_eight_mission_count;
					local mm = mission_manager:new(faction_key, mission_key);
					mm:set_mission_issuer("CLAN_ELDERS");
					
					mm:add_new_objective("ENGAGE_FORCE");
					mm:add_condition("cqi "..pirate_force:command_queue_index());
					mm:add_condition("requires_victory");
					
					mm:add_payload("effect_bundle{bundle_key wh2_dlc11_ror_reward_"..piece_of_eight_mission_count..";turns 0;}");
					mm:trigger();
					vampire_coast_ror_mission_winners[faction_key] = {};
					vampire_coast_ror_mission_winners[faction_key][mission_key] = false;
				end
			end
			pirate.item_num = piece_of_eight_mission_count;
			piece_of_eight_mission_count = piece_of_eight_mission_count + 1;
		end
	end
	cm:disable_event_feed_events(false, "", "wh_event_subcategory_faction_missions_objectives", "");
end

function setup_harpoon_force(player)
	-- Create the rogue army
	cm:spawn_rogue_army(harpoon_mission_faction, harpoon_mission_location[player].x, harpoon_mission_location[player].y);
	
	local rogue_leader = cm:get_faction(harpoon_mission_faction):faction_leader();
	local rogue_force = rogue_leader:military_force();
	local rogue_pirate = invasion_manager:new_invasion_from_existing_force("HARPOON_PIRATE", rogue_force);
	
	rogue_pirate:add_character_experience(5, true);
	rogue_pirate:set_target("NONE", nil, player);
	rogue_pirate:apply_effect("wh2_dlc11_bundle_harpoon_force", -1);
	rogue_pirate:should_stop_at_end(true);
	rogue_pirate:start_invasion(
	function()
		cm:force_diplomacy("all", "faction:"..harpoon_mission_faction, "all", false, false, true);
	end);
	
	core:add_listener(
		"setup_harpoon_force_marker_listener",
		"ScriptEventEGSearchForTheVengeanceCameraScrollComplete",			-- triggered by advice scripts
		true,
		function()
			local rogue_leader = cm:get_faction(harpoon_mission_faction):faction_leader();
			
			-- Add VFX
			cm:add_character_vfx(rogue_leader:command_queue_index(), "scripted_effect13", true);
			-- Add offscreen marker
			cm:add_marker("harpoon_marker", "pointer", rogue_leader:display_position_x(), rogue_leader:display_position_y(), 0);
		end,
		false
	);
end


-- allow autoresolving if it has been disabled by harpoon scripts
function allow_autoresolving_after_disabled_for_harpoon_battle()
	if cm:get_saved_value("autoresolve_disabled_for_harpoon_battle") then
		cm:set_saved_value("autoresolve_disabled_for_harpoon_battle", false);
		cm:get_campaign_ui_manager():override("autoresolve"):set_allowed(true);
	end;
end;


-- disable autoresolving when attacking the harpoon mission faction
function disable_autoresolving_for_harpoon_battle()
	cm:set_saved_value("autoresolve_disabled_for_harpoon_battle", true);
	cm:get_campaign_ui_manager():override("autoresolve"):set_allowed(false);
end;


function harpoon_pending_battle(context)
	allow_autoresolving_after_disabled_for_harpoon_battle();
	local primary_defender_char_cqi, primary_defender_mf_cqi, primary_defender_faction_name = cm:pending_battle_cache_get_defender(1);
	
	if primary_defender_faction_name == harpoon_mission_faction then
		disable_autoresolving_for_harpoon_battle();
		
		core:add_listener(
			"HarpoonPanelClosedCampaign",
			"PanelClosedCampaign",
			function(context)
				return context.string == "popup_pre_battle";
			end,
			function(context)
				allow_autoresolving_after_disabled_for_harpoon_battle();
			end,
			false
		);
	end
end

function harpoon_completed_battle(context)
	local primary_defender_char_cqi, primary_defender_mf_cqi, primary_defender_faction_name = cm:pending_battle_cache_get_defender(1);
	
	if primary_defender_faction_name == harpoon_mission_faction then
		allow_autoresolving_after_disabled_for_harpoon_battle();
	end
end

function piece_of_eight_respawn(context)
	local invasion = context:table_data();
	out("ScriptEventInvasionManagerRespawn - "..invasion.key);
	local general = invasion:get_general();
	
	if general:is_null_interface() == false then
		local general_cqi = general:family_member():command_queue_index();
		
		-- Go through all pirates until we find the one relating to this invasion
		for i = 1, #roving_pirates[campaign_name] do
			local pirate = roving_pirates[campaign_name][i];
			
			if invasion.faction == pirate.faction_key and pirate.item_owned == "piece_of_eight" then
				local human_factions = cm:get_human_factions();
				
				-- Go through all humans and if they aren't in the complete table give them the mission
				for j = 1, #human_factions do
					local faction_key = human_factions[j];
					if faction_key == "wh2_dlc11_cst_noctilus" or faction_key == "wh2_dlc11_cst_pirates_of_sartosa" or faction_key == "wh2_dlc11_cst_the_drowned" or faction_key == "wh2_dlc11_cst_vampire_coast" then
						local mission_key = "wh2_dlc11_mission_piece_of_eight_"..pirate.item_num;
						
						if vampire_coast_ror_mission_winners[faction_key][mission_key] == false then
							local mm = mission_manager:new(human_factions[j], mission_key);
							mm:set_mission_issuer("CLAN_ELDERS");
							mm:add_new_objective("KILL_CHARACTER_BY_ANY_MEANS");
							mm:add_condition("family_member "..general_cqi);
							mm:add_payload("effect_bundle{bundle_key wh2_dlc11_ror_reward_"..pirate.item_num..";turns 0;}");
							mm:trigger();
						end
					end
				end
				
				-- Stop diplomacy again
				cm:force_diplomacy("all", "faction:"..pirate.faction_key, "all", false, false, true);
				cm:force_diplomacy("all", "faction:"..pirate.faction_key, "war", true, true, true);
				break;
			end
		end
	end
end

function piece_of_eight_completed(context)
	local mission_key = context:mission():mission_record_key();
	local faction = context:faction();
	local faction_key = faction:name();
	
	if vampire_coast_ror_mission_unlocks[mission_key] ~= nil then
		if vampire_coast_ror_mission_winners[faction_key] then
			vampire_coast_ror_mission_winners[faction_key][mission_key] = true;
		end
		cm:remove_event_restricted_unit_record_for_faction(vampire_coast_ror_mission_unlocks[mission_key], faction_key);
		
		cm:callback(function()
			for i = 1, 8 do
				if faction:has_effect_bundle("wh2_dlc11_ror_reward_"..i) then
					cm:remove_effect_bundle("wh2_dlc11_ror_reward_"..i, faction_key);
				end
			end
		end, 1);
		
		-- Trigger script event for advice
		local pieces_of_eight_collected_sp = cm:get_saved_value("pieces_of_eight_collected_sp");			-- only for use in singleplayer
		if not cm:is_multiplayer() then
			pieces_of_eight_collected_sp = pieces_of_eight_collected_sp + 1;
			core:trigger_event("ScriptEventPieceOfEightCollected", pieces_of_eight_collected_sp);
		end;
	elseif mission_key == "wh2_dlc11_mission_harpoon" then
		-- Complete the victory condition
		cm:complete_scripted_mission_objective("wh_main_long_victory", "gain_harpoon", true);
		-- Kill off Harpoon faction
		local harpoon_faction = cm:model():world():faction_by_key(harpoon_mission_faction);
		cm:kill_all_armies_for_faction(harpoon_faction);
		-- Trigger Harpoon movie
		-- wait for battle completed otherwise it will play before selecting a post battle option etc.
		core:add_listener(
			"harpoon_movie",
			"BattleCompleted",
			true,
			function()
				core:svr_save_registry_bool("cst_wreck", true);
				cm:register_instant_movie("warhammer2/cst/cst_wreck");
			end,
			false
		);
		-- Remove marker
		cm:remove_marker("harpoon_marker");
		-- Enable UI
		allow_autoresolving_after_disabled_for_harpoon_battle();
	end
end

function roving_pirates_accessor()
	local campaign_name = "main_warhammer";
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		campaign_name = "wh2_main_great_vortex";
	end
	return roving_pirates[campaign_name];
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("roving_pirates", roving_pirates, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			roving_pirates = cm:load_named_value("roving_pirates", roving_pirates, context);
		end
	end
);