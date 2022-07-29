NORSCA_ARCHAON_DILEMMA = "wh_dlc08_nor_archaon_choice";
NORSCA_CHAOS_INVASION_FACTION_KEY = "wh_main_chs_chaos";
NORSCA_BEASTMEN_INVASION_FACTION_KEY = "wh_dlc03_bst_beastmen_chaos";
NORSCAN_CHAOS_INVASION_STATUS = "not started";
NORSCAN_CHAOS_INVASION_RESPAWN = -1;
NORSCAN_CHAOS_BUILDINGS = {"wh_main_horde_chaos_settlement_3", "wh_main_horde_chaos_warriors_2", "wh_main_horde_chaos_forge_1"};
NORSCAN_CHAOS_SPAWN = {766, 780, 612, 625};

NCI_archaon = {
	["id"] = "NCI_archaon",
	["agent_subtype"] = "chs_archaon",
	["forename"] = "names_name_2147343903",
	["family_name"] = "names_name_2147357364",
	["faction_leader"] = true,
	["force"] = ""
};
NCI_sigvald = {
	["id"] = "NCI_sigvald",
	["agent_subtype"] = "chs_prince_sigvald",
	["forename"] = "names_name_2147345922",
	["family_name"] = "names_name_2147357370",
	["faction_leader"] = false,
	["force"] = ""
};
NCI_kholek = {
	["id"] = "NCI_kholek",
	["agent_subtype"] = "chs_kholek_suneater",
	["forename"] = "names_name_2147345931",
	["family_name"] = "names_name_2147345934",
	["faction_leader"] = false,
	["force"] = ""
};
NCI_sarthorael = {
	["id"] = "NCI_sarthorael",
	["agent_subtype"] = "chs_lord_of_change",
	["forename"] = "names_name_2147357518",
	["family_name"] = "names_name_2147357523",
	["faction_leader"] = false,
	["force"] = ""
};

function Setup_Norsca_Chaos_Invasion()
	out.chaos("#### Preparing Norscan Chaos Invasion ####");
	
	if cm:is_multiplayer() then
		script_error("Norsca Chaos Invasion happening in multiplayer?!");
		return;
	end
	
	core:add_listener(
		"NCI_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) NCI_DilemmaChoiceMadeEvent(context) end,
		true
	);
	core:add_listener(
		"NCI_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context) NCI_FactionTurnStart(context) end,
		true
	);
	
	if cm:is_new_game() == true then
		cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");
		local chaos_fac = cm:model():world():faction_by_key(NORSCA_CHAOS_INVASION_FACTION_KEY);
		out.chaos("\tKilling Archaon! - '"..chaos_fac:faction_leader():command_queue_index().."'");
		cm:kill_character(chaos_fac:faction_leader():command_queue_index(), true, false);
		cm:lock_starting_general_recruitment("2140782858", NORSCA_CHAOS_INVASION_FACTION_KEY);
		cm:lock_starting_general_recruitment("2140783662", NORSCA_CHAOS_INVASION_FACTION_KEY);
		cm:lock_starting_general_recruitment("2140783672", NORSCA_CHAOS_INVASION_FACTION_KEY);
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "") end, 1);
	end
	
	NCI_Setup_Armies();
end

function NCI_DilemmaChoiceMadeEvent(context)
	local faction_key = context:faction():name();
	local dilemma = context:dilemma();
	local choice = context:choice();
	
	if dilemma == NORSCA_ARCHAON_DILEMMA then
		NORSCAN_CHAOS_INVASION_STATUS = "dilemma choice "..tostring(choice);
		
		if choice == 0 then
			-- Sided with Archaon
			NCI_Start_Invasion(faction_key, true);
		else
			-- Opposed Archaon
			NCI_Start_Invasion(faction_key, false);
		end
	end
end

function NCI_Start_Invasion(faction_key, is_ally)
	out.chaos("NCI_Start_Invasion()");
	out.chaos("\tFaction: "..tostring(faction_key));
	out.chaos("\tIs Ally: "..tostring(is_ally));
	
	out.chaos("\tPlaying movie...");
	cm:register_instant_movie("Warhammer/chs_rises");
	
	out.chaos("\tLocking Archaon, Sigvald and Kholek!");
	--cm:lock_starting_general_recruitment("2140782858", NORSCA_CHAOS_INVASION_FACTION_KEY);
	cm:lock_starting_general_recruitment("2140783662", NORSCA_CHAOS_INVASION_FACTION_KEY);
	cm:lock_starting_general_recruitment("2140783672", NORSCA_CHAOS_INVASION_FACTION_KEY);
	--cm:unlock_starting_general_recruitment("2140782858", NORSCA_CHAOS_INVASION_FACTION_KEY);
	--cm:unlock_starting_general_recruitment("2140783662", NORSCA_CHAOS_INVASION_FACTION_KEY);
	--cm:unlock_starting_general_recruitment("2140783672", NORSCA_CHAOS_INVASION_FACTION_KEY);
	
	out.chaos("Spawning Archaon!");
	NCI_Create_Character(NCI_archaon, 775, 607);
	out.chaos("Spawning Sigvald!");
	NCI_Create_Character(NCI_sigvald, 769, 611);
	out.chaos("Spawning Kholek!");
	NCI_Create_Character(NCI_kholek, 780, 611);
	out.chaos("Spawning Sarthorael!");
	NCI_Create_Character(NCI_sarthorael, 775, 618);
	
	if is_ally == true then
		NORSCAN_CHAOS_INVASION_STATUS = "allied";
		cm:set_camera_position(519.04, 476.16, 14.77, 0, 12);
		NORSCAN_CHAOS_INVASION_RESPAWN = 10;
		
		cm:callback(function()
			NCI_Spawn_Extra_Chaos_Army("chaos", 774, 594);
			NCI_Spawn_Extra_Chaos_Army("chaos", 777, 593);
			NCI_Spawn_Extra_Chaos_Army("chaos", 768, 620);
			NCI_Spawn_Extra_Chaos_Army("chaos", 781, 618);
			NCI_Chaos_Declare_War(faction_key, is_ally);
			NCI_Kill_Chaos_Characters();
			cm:callback(function()
				NCI_Legendary_Autosave();
			end, 0.5);
		end, 0.5);
	else
		NORSCAN_CHAOS_INVASION_STATUS = "enemy";
		
		cm:callback(function()
			NCI_Spawn_Extra_Chaos_Army("chaos");
			NCI_Spawn_Extra_Chaos_Army("chaos");
			NCI_Chaos_Declare_War(faction_key, is_ally);
			NCI_Kill_Chaos_Characters();
			cm:callback(function()
				NCI_Legendary_Autosave();
			end, 0.5);
		end, 0.5);
	end
	
	NCI_Change_Personalities();
end

function NCI_Kill_Chaos_Characters()
	out.chaos("NCI_Kill_Chaos_Characters()");
	local chaos_fac = cm:model():world():faction_by_key(NORSCA_CHAOS_INVASION_FACTION_KEY);
	local char_list = chaos_fac:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		if current_char:has_military_force() == false then
			cm:set_character_immortality("character_cqi:"..current_char:command_queue_index(), false);
			cm:kill_character(current_char:command_queue_index(), true, true);
		end
	end
	
	--cm:lock_starting_general_recruitment("2140782858", NORSCA_CHAOS_INVASION_FACTION_KEY);
	cm:lock_starting_general_recruitment("2140783662", NORSCA_CHAOS_INVASION_FACTION_KEY);
	cm:lock_starting_general_recruitment("2140783672", NORSCA_CHAOS_INVASION_FACTION_KEY);
end

function NCI_Chaos_Declare_War(faction_key, is_ally)
	out.chaos("NCI_Chaos_Declare_War()");
	
	if is_ally == true then	
		-- Chaos and player should fight everyone!
		local faction_list = cm:model():world():faction_list();
	
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			local fac_name = current_faction:name();
			
			if current_faction:is_null_interface() == false and current_faction:is_dead() == false and current_faction:culture() ~= "wh_main_chs_chaos" and current_faction:culture() ~= "wh_dlc03_bst_beastmen" then
				out.chaos("\tChaos declaring war on: "..tostring(fac_name));
				cm:force_declare_war(NORSCA_CHAOS_INVASION_FACTION_KEY, fac_name, false, false);
				cm:force_declare_war(faction_key, fac_name, false, false);
				cm:force_diplomacy("faction:"..NORSCA_CHAOS_INVASION_FACTION_KEY, "faction:"..fac_name, "peace", false, false, true);
			end
		end
		-- Become friends!
		cm:force_alliance(NORSCA_CHAOS_INVASION_FACTION_KEY, faction_key, true);
		cm:force_diplomacy("faction:"..NORSCA_CHAOS_INVASION_FACTION_KEY, "faction:"..faction_key, "break alliance,break non aggression pact,war,join war", false, false, true);
	else
		-- Chaos should fight the player only!
		cm:force_declare_war(NORSCA_CHAOS_INVASION_FACTION_KEY, faction_key, false, false);
		cm:force_diplomacy("faction:"..NORSCA_CHAOS_INVASION_FACTION_KEY, "faction:"..faction_key, "peace", false, false, true);
		
		local faction_list = cm:model():world():faction_list();
	
		for i = 0, faction_list:num_items() - 1 do
			local current_faction = faction_list:item_at(i);
			local fac_name = current_faction:name();
			
			if fac_name ~= faction_key then
				cm:force_diplomacy("faction:"..NORSCA_CHAOS_INVASION_FACTION_KEY, "faction:"..fac_name, "war", false, false, true);
			end
		end
	end
end

function NCI_Create_Character(char_details, x1, y1)
	local valid = false;
	local x = x1 or 0;
	local y = y1 or 0;
	local failsafe = 0;
	local first_try = true;
	
	if x == 0 and y == 0 then
		first_try = false;
	end
	
	while not valid do
		if first_try == false then
			x = cm:random_number(NORSCAN_CHAOS_SPAWN[2], NORSCAN_CHAOS_SPAWN[1]);
			y = cm:random_number(NORSCAN_CHAOS_SPAWN[4], NORSCAN_CHAOS_SPAWN[3]);
		end
		first_try = false;
		failsafe = failsafe + 1;
	
		if is_valid_spawn_point(x, y) then
			--[[
			if char_details["agent_subtype"] == "chs_archaon" then
				cm:add_listener(
					"archaon_skills",
					"CharacterCreated",
					true,
					function(context)
						local current_char = context:character();
						
						if current_char:character_subtype("chs_archaon") then
							NCI_Archaon_Skills("character_cqi:"..current_char:command_queue_index());
						end
					end,
					false
				);
			end
			]]--
			cm:create_force_with_general(
				NORSCA_CHAOS_INVASION_FACTION_KEY,
				char_details["force"],
				"wh_main_goromandy_mountains_baersonlings_camp",
				x,
				y,
				"general",
				char_details["agent_subtype"],
				char_details["forename"],
				"",
				char_details["family_name"],
				"",
				-- char_details["id"],				-- no longer needed
				char_details["faction_leader"],
				function(cqi)
					local char_str = cm:char_lookup_str(cqi);
					cm:apply_effect_bundle_to_characters_force("wh_main_bundle_military_upkeep_free_force_unbreakable", cqi, 0, true);
					cm:set_character_immortality(char_str, true);
					--cm:set_character_unique(char_str, true);
					cm:add_agent_experience(char_str, 40, true);
				
					local char = cm:get_character_by_cqi(cqi);
					local mf_cqi = char:military_force():command_queue_index();
					cm:add_building_to_force(mf_cqi, NORSCAN_CHAOS_BUILDINGS);
					
					if char_details["faction_leader"] == true then
						NCI_Add_Army_XP(cqi, 9);
					else
						NCI_Add_Army_XP(cqi);
					end
				end
			);
			out.chaos("\tSpawned character after "..failsafe.." attempts");
			valid = true;
		elseif failsafe >= 1000 then
			script_error("Failed to find a spawn point for character after 1000 attempts");
			return;
		end
	end
end

function NCI_Spawn_Extra_Chaos_Army(faction, x1, y1)
	faction = faction or "chaos";
	local valid = false;
	local x = x1 or 0;
	local y = y1 or 0;
	local faction_name = NORSCA_CHAOS_INVASION_FACTION_KEY;
	local ram = random_army_manager;
	local army_string = ram:generate_force("NCI_extra", 19, false);
	local buildings = NORSCAN_CHAOS_BUILDINGS;
	local failsafe = 0;
	local first_try = true;
	
	if x == 0 and y == 0 then
		first_try = false;
	end
	
	if faction == "beastmen" then
		faction_name = NORSCA_BEASTMEN_INVASION_FACTION_KEY;
		army_string = ram:generate_force("NCI_beastmen", 19, false);
		buildings = {"wh_dlc03_horde_beastmen_herd_3", "wh_dlc03_horde_beastmen_gors_3", "wh_dlc03_horde_beastmen_minotaurs_1"};
	end
	
	while not valid do
		if first_try == false then
			x = cm:random_number(NORSCAN_CHAOS_SPAWN[2], NORSCAN_CHAOS_SPAWN[1]);
			y = cm:random_number(NORSCAN_CHAOS_SPAWN[4], NORSCAN_CHAOS_SPAWN[3]);
		end
		first_try = false;
		failsafe = failsafe + 1;

		if is_valid_spawn_point(x, y) then
			cm:create_force(
				faction_name,
				army_string,
				"wh_main_goromandy_mountains_baersonlings_camp",
				x,
				y,
				true,
				function(cqi)
					cm:apply_effect_bundle_to_characters_force("wh_main_bundle_military_upkeep_free_force", cqi, 0, true);
					cm:add_agent_experience(cm:char_lookup_str(cqi), 40, true);
					NCI_Add_Army_XP(cqi);
					
					local char = cm:get_character_by_cqi(cqi);
					local mf_cqi = char:military_force():command_queue_index();
					cm:add_building_to_force(mf_cqi, buildings);
				end
			);
			valid = true;
		elseif failsafe >= 1000 then
			script_error("Failed to find a spawn point for character after 1000 attempts");
			return;
		end
	end
end

function NCI_Setup_Armies()
	local ram = random_army_manager;
	
	ram:new_force("NCI_archaon");
	ram:new_force("NCI_sigvald");
	ram:new_force("NCI_kholek");
	ram:new_force("NCI_sarthorael");
	ram:new_force("NCI_extra");
	ram:new_force("NCI_beastmen");
	
	-- ARCHAON
	ram:add_mandatory_unit("NCI_archaon", "wh_pro04_chs_cav_chaos_knights_ror_0", 1);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_cav_chaos_knights_0", 1);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_cav_chaos_knights_1", 2);
	ram:add_mandatory_unit("NCI_archaon", "wh_pro04_chs_art_hellcannon_ror_0", 1);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_art_hellcannon", 1);
	ram:add_mandatory_unit("NCI_archaon", "wh_dlc06_chs_inf_aspiring_champions_0", 2);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_inf_chosen_0", 4);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_inf_chosen_1", 4);
	ram:add_mandatory_unit("NCI_archaon", "wh_dlc01_chs_inf_chosen_2", 2);
	ram:add_mandatory_unit("NCI_archaon", "wh_main_chs_mon_giant", 1);
	
	-- SIGVALD
	ram:add_mandatory_unit("NCI_sigvald", "wh_pro04_chs_inf_chaos_warriors_ror_0", 1);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_cav_chaos_knights_0", 2);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_art_hellcannon", 2);
	ram:add_mandatory_unit("NCI_sigvald", "wh_dlc06_chs_cav_marauder_horsemasters_0", 2);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_inf_chaos_marauders_1", 2);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_inf_chaos_marauders_0", 3);
	ram:add_mandatory_unit("NCI_sigvald", "wh_dlc06_chs_inf_aspiring_champions_0", 2);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_inf_chaos_warriors_0", 3);
	ram:add_mandatory_unit("NCI_sigvald", "wh_main_chs_inf_chaos_warriors_1", 2);
	
	-- KHOLEK
	ram:add_mandatory_unit("NCI_kholek", "wh_pro04_chs_mon_dragon_ogre_ror_0", 1);
	ram:add_mandatory_unit("NCI_kholek", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 3);
	ram:add_mandatory_unit("NCI_kholek", "wh_dlc01_chs_mon_dragon_ogre", 6);
	ram:add_mandatory_unit("NCI_kholek", "wh_main_chs_art_hellcannon", 2);
	ram:add_mandatory_unit("NCI_kholek", "wh_main_chs_inf_chaos_warriors_0", 3);
	ram:add_mandatory_unit("NCI_kholek", "wh_main_chs_inf_chaos_warriors_1", 4);
	
	-- SARTHORAEL
	ram:add_mandatory_unit("NCI_sarthorael", "wh_pro04_chs_inf_forsaken_ror_0", 1);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_pro04_chs_mon_chaos_spawn_ror_0", 1);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_main_chs_art_hellcannon", 2);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_dlc01_chs_inf_forsaken_0", 6);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_main_chs_mon_trolls", 2);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_dlc01_chs_mon_trolls_1", 1);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_main_chs_mon_chaos_spawn", 2);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_main_chs_mon_giant", 2);
	ram:add_mandatory_unit("NCI_sarthorael", "wh_main_chs_mon_chaos_warhounds_1", 2);
	
	-- EXTRA ARMY
	ram:add_mandatory_unit("NCI_extra", "wh_main_chs_art_hellcannon", 1);
	ram:add_mandatory_unit("NCI_extra", "wh_main_chs_cav_chaos_knights_0", 2);
	ram:add_mandatory_unit("NCI_extra", "wh_dlc06_chs_inf_aspiring_champions_0", 1);
	ram:add_mandatory_unit("NCI_extra", "wh_main_chs_inf_chaos_warriors_0", 2);
	ram:add_mandatory_unit("NCI_extra", "wh_main_chs_inf_chaos_marauders_0", 2);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chosen_0", 1);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chosen_1", 1);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chaos_warriors_0", 2);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chaos_warriors_1", 2);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chaos_marauders_1", 2);
	ram:add_unit("NCI_extra", "wh_main_chs_inf_chaos_marauders_0", 2);
	ram:add_unit("NCI_extra", "wh_main_chs_mon_giant", 1);
	ram:add_unit("NCI_extra", "wh_main_chs_mon_chaos_spawn", 1);
	ram:add_unit("NCI_extra", "wh_main_chs_mon_trolls", 1);
	ram:add_unit("NCI_extra", "wh_main_chs_mon_chaos_warhounds_0", 1);
	
	-- BEASTMEN
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_gor_herd_0", 17);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_gor_herd_1", 17);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_ungor_spearmen_1", 12);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_ungor_raiders_0", 12);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_bestigor_herd_0", 10);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_minotaurs_0", 8);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_minotaurs_1", 8);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_inf_cygor_0", 7);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_mon_giant_0", 5);
	ram:add_unit("NCI_beastmen", "wh_dlc03_bst_cav_razorgor_chariot_0", 4);
	
	-- Add extras just to be safe
	ram:add_unit("NCI_archaon", "wh_main_chs_inf_chaos_warriors_0", 1);
	ram:add_unit("NCI_sigvald", "wh_main_chs_inf_chaos_warriors_0", 1);
	ram:add_unit("NCI_kholek", "wh_main_chs_inf_chaos_warriors_0", 1);
	ram:add_unit("NCI_sarthorael", "wh_main_chs_inf_chaos_warriors_0", 1);
	
	-- Create the force strings
	NCI_archaon["force"] = ram:generate_force("NCI_archaon", 19, false);
	NCI_sigvald["force"] = ram:generate_force("NCI_sigvald", 19, false);
	NCI_kholek["force"] = ram:generate_force("NCI_kholek", 19, false);
	NCI_sarthorael["force"] = ram:generate_force("NCI_sarthorael", 19, false);
end

function NCI_Add_Army_XP(cqi, force_xp)
	local xp = force_xp;
	
	if xp == nil then
		local difficulty = cm:model():difficulty_level();
		
		if difficulty == -1 then
			-- Hard
			xp = 2;
		elseif difficulty == -2 then
			-- Very Hard
			xp = 4;
		elseif difficulty == -3 then
			-- Legendary
			xp = 7;
		else
			xp = 0;
		end
	end
	
	cm:add_experience_to_units_commanded_by_character(cm:char_lookup_str(cqi), xp);
end

function NCI_Archaon_Skills(archaon)
	out.chaos("NCI_Archaon_Skills()");
	out.chaos("\t"..archaon);
	
	cm:force_add_skill(archaon, "wh_main_skill_chs_lord_self_eye_of_the_gods");
	cm:force_add_skill(archaon, "wh_main_skill_chs_lord_battle_dominating_presence");
	cm:force_add_skill(archaon, "wh_main_skill_all_lord_campaign_route_marcher");
	cm:force_add_skill(archaon, "wh_main_skill_all_magic_fire_01_fireball");
	
	cm:callback(function()
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_thick-skinned");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_thick-skinned");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_thick-skinned");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_hard_to_hit");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_hard_to_hit");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_hard_to_hit");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_deadly_blade_2");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_deadly_blade_2");
		cm:force_add_skill(archaon, "wh_main_skill_all_all_self_deadly_blade_2");
		
		cm:force_add_skill(archaon, "wh_main_skill_all_magic_fire_05_the_burning_head");
		cm:force_add_skill(archaon, "wh_main_skill_all_magic_fire_05_the_burning_head");
		
		cm:callback(function()
			cm:force_add_skill(archaon, "wh_main_skill_all_all_self_foe-seeker");
			
			cm:callback(function()
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_wound-maker_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_wound-maker_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_wound-maker_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_scarred_veteran_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_scarred_veteran_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_scarred_veteran_2");
				cm:force_add_skill(archaon, "wh_main_skill_all_all_self_blade_shield");
				
				cm:callback(function()
					cm:force_add_skill(archaon, "wh_main_skill_all_all_self_deadly_onslaught");
				
					cm:force_add_skill(archaon, "wh_main_skill_chs_lord_unique_archaon_dorghar");
					cm:force_add_skill(archaon, "wh_main_skill_chs_lord_unique_archaon_chosen_of_the_gods");
					cm:force_add_skill(archaon, "wh_main_skill_chs_lord_unique_archaon_chosen_of_the_gods");
					cm:force_add_skill(archaon, "wh_main_skill_chs_lord_unique_archaon_chosen_of_the_gods");
					cm:force_add_skill(archaon, "wh_main_skill_chs_all_unique_aura_of_chaos");
				end, 0.5);
			end, 0.5);
		end, 0.5);
	end, 0.5);
end

function NCI_Change_Personalities()
	out.chaos("NCI_Change_Personalities()");
	local difficulty = ci_get_difficulty();
	local use_hard_personalities = false;
	
	if difficulty == 4 or difficulty == 5 then
		use_hard_personalities = true;
	end
	
	local empire_personalities = {"wh_empire_default_allied", "wh_empire_subordinate_allied", "wh_empire_variant1_allied"};
	local empire_personalities_hard = {"wh_empire_default_hard_allied", "wh_empire_subordinate_hard_allied", "wh_empire_variant1_hard_allied"};
	local dwarfs_personalities = {"wh_dwarfs_default_allied", "wh_dwarfs_subordinate_allied", "wh_dwarfs_variant1_allied"};
	local dwarfs_personalities_hard = {"wh_dwarfs_default_hard_allied", "wh_dwarfs_subordinate_hard_allied", "wh_dwarfs_variant1_hard_allied"};
	
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:is_human() == false then
			if faction:culture() == "wh_main_emp_empire" or faction:culture() == "wh_main_brt_bretonnia" then
				if faction:name() == "wh_main_emp_empire" or faction:name() == "wh_main_brt_bretonnia" then
					if use_hard_personalities then
						cm:force_change_cai_faction_personality(faction:name(), "wh_empire_subjugator_hard_allied");
					else
						cm:force_change_cai_faction_personality(faction:name(), "wh_empire_subjugator_allied");
					end
				else
					if use_hard_personalities then
						cm:force_change_cai_faction_personality(faction:name(), empire_personalities_hard[cm:random_number(#empire_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction:name(), empire_personalities[cm:random_number(#empire_personalities)]);
					end
				end
			elseif faction:culture() == "wh_main_dwf_dwarfs" then
				if faction:name() == "wh_main_dwf_dwarfs" then
					if use_hard_personalities then
						cm:force_change_cai_faction_personality(faction:name(), "wh_dwarfs_subjugator_hard_allied");
					else
						cm:force_change_cai_faction_personality(faction:name(), "wh_dwarfs_subjugator_allied");
					end
				else
					if use_hard_personalities then
						cm:force_change_cai_faction_personality(faction:name(), dwarfs_personalities_hard[cm:random_number(#dwarfs_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction:name(), dwarfs_personalities[cm:random_number(#dwarfs_personalities)]);
					end
				end
			end
		end
	end
end


core:add_listener(
	"character_completed_battle_nci_chaos_died",
	"CharacterCompletedBattle",
	true,
	function(context)
		if NORSCAN_CHAOS_INVASION_STATUS == "allied" or NORSCAN_CHAOS_INVASION_STATUS == "enemy" then
			local character = context:character();
			
			if cm:char_is_general_with_army(character) == true and character:faction():is_human() == true and character:faction():subculture() == NORSCA_SUBCULTURE then
				local is_alive = NCI_Is_Chaos_Alive();
				local faction_key = character:faction():name();
				
				if is_alive == false then
					if NORSCAN_CHAOS_INVASION_STATUS == "allied" then
						NCI_Chaos_Died(faction_key, true);
					elseif NORSCAN_CHAOS_INVASION_STATUS == "enemy" then
						NCI_Chaos_Died(faction_key, false);
					end
				end
			end
		end
	end,
	true
);


function NCI_FactionTurnStart(context)
	if context:faction():subculture() == NORSCA_SUBCULTURE then
		local faction_key = context:faction():name();
		
		if NORSCAN_CHAOS_INVASION_STATUS == "allied" or NORSCAN_CHAOS_INVASION_STATUS == "enemy" then
			local is_alive, force_count = NCI_Is_Chaos_Alive();
			
			if is_alive == false then
				if NORSCAN_CHAOS_INVASION_STATUS == "allied" then
					NCI_Chaos_Died(faction_key, true);
					NORSCAN_CHAOS_INVASION_RESPAWN = -1;
				elseif NORSCAN_CHAOS_INVASION_STATUS == "enemy" then
					NCI_Chaos_Died(faction_key, false);
				end
			else
				-- Chaos is still alive, give them more forces (up to 10) if the player is allied
				if NORSCAN_CHAOS_INVASION_STATUS == "allied" then
					NORSCAN_CHAOS_INVASION_RESPAWN = NORSCAN_CHAOS_INVASION_RESPAWN - 1;
					
					if NORSCAN_CHAOS_INVASION_RESPAWN < 0 then
						NORSCAN_CHAOS_INVASION_RESPAWN = 0;
					end
				
					if force_count <= 8 then
						if NORSCAN_CHAOS_INVASION_RESPAWN == 0 then
							out.chaos("CHAOS IS SPAWNING MORE!");
							NCI_Spawn_Extra_Chaos_Army("chaos");
							NCI_Spawn_Extra_Chaos_Army("chaos");
							NORSCAN_CHAOS_INVASION_RESPAWN = 10;
						end
					end
				end
			end
		end
	end
end

function NCI_Is_Chaos_Alive()
	local faction = cm:model():world():faction_by_key(NORSCA_CHAOS_INVASION_FACTION_KEY);
	
	if faction:is_null_interface() == false and faction:is_dead() == false then
		return true, faction:military_force_list():num_items();
	end
	return false, 0;
end

function NCI_Chaos_Died(faction_key, is_ally)
	if is_ally == true then
		-- Remove bonus
		cm:remove_effect_bundle("wh_dlc08_bundle_follow_archaon", faction_key);
	else
		-- Give (real) bonus
		cm:remove_effect_bundle("wh_dlc08_bundle_true_everchosen_dummy", faction_key);
		cm:remove_effect_bundle("wh_dlc08_bundle_true_everchosen", faction_key);
		cm:apply_effect_bundle("wh_dlc08_bundle_true_everchosen", faction_key, 0);
	end
	NORSCAN_CHAOS_INVASION_STATUS = "dead";
end

function NCI_Legendary_Autosave()
	out.chaos("NCI_Legendary_Autosave()");
	local difficulty = cm:model():difficulty_level();
	
	if difficulty == -3 and cm:is_multiplayer() == false then
		-- Legendary
		out.chaos("\tLegendary Difficulty - Autosaving...");
		cm:autosave_at_next_opportunity();
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("NORSCAN_CHAOS_INVASION_STATUS", NORSCAN_CHAOS_INVASION_STATUS, context);
		cm:save_named_value("NORSCAN_CHAOS_INVASION_RESPAWN", NORSCAN_CHAOS_INVASION_RESPAWN, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		NORSCAN_CHAOS_INVASION_STATUS = cm:load_named_value("NORSCAN_CHAOS_INVASION_STATUS", "not started", context);
		NORSCAN_CHAOS_INVASION_RESPAWN = cm:load_named_value("NORSCAN_CHAOS_INVASION_RESPAWN", -1, context);
	end
);