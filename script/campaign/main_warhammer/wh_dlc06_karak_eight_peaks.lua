
-- list of karak eight peaks faction keys that we can iterate over
karak_eight_peaks_factions = {
	"wh_main_dwf_karak_izor",
	"wh_main_grn_crooked_moon",
	"wh2_main_skv_clan_mors"
};

-- list of karak eight peaks faction keys that we can lookup easily
karak_eight_peaks_factions_lookup = {};
for i = 1, #karak_eight_peaks_factions do
	karak_eight_peaks_factions_lookup[karak_eight_peaks_factions[i]] = true;
end;


function is_karak_eight_peaks_owner_faction(faction_name)
	return not not karak_eight_peaks_factions_lookup[faction_name];
end;



function apply_karak_diplomacy()
	-- No peace for Belegar and Skarsnik
	cm:force_diplomacy("faction:wh_main_grn_crooked_moon", "faction:wh_main_dwf_karak_izor", "peace", false, false, true);
	cm:force_diplomacy("faction:wh_main_grn_greenskins", "faction:wh_main_grn_necksnappers", "form confederation", false, false, true);
	
	if cm:get_faction("wh_main_grn_crooked_moon"):is_human() or cm:get_faction("wh_main_dwf_karak_izor"):is_human() or cm:get_faction("wh2_main_skv_clan_mors"):is_human() then
		-- No diplomacy for the Mutinous Gits
		cm:force_diplomacy("faction:wh_main_grn_necksnappers", "all", "all", false, false, true);
		-- if the faction re-emerges, they will not be at war with the karak factions, so make sure war is still available
		cm:force_diplomacy("faction:wh_main_grn_necksnappers", "faction:wh_main_grn_crooked_moon", "war", true, true, true);
		cm:force_diplomacy("faction:wh_main_grn_necksnappers", "faction:wh_main_dwf_karak_izor", "war", true, true, true);
		cm:force_diplomacy("faction:wh_main_grn_necksnappers", "faction:wh2_main_skv_clan_mors", "war", true, true, true);
		
		if cm:is_multiplayer() then
			-- A non-Karak player won't know what's going on
			local human_factions = cm:get_human_factions();
			
			for i = 1, #human_factions do
				local current_faction_name = human_factions[i];
				
				if current_faction_name ~= "wh_main_dwf_karak_izor" and current_faction_name ~= "wh_main_grn_crooked_moon" then
					cm:force_diplomacy("faction:" .. current_faction_name, "faction:wh_main_grn_necksnappers", "all", true, true, false);
					cm:force_diplomacy("faction:" .. current_faction_name, "faction:wh_main_grn_necksnappers", "form confederation", false, false, true);
				end;
			end;
		end;
	end;
end;

local belegar_characters = {
	-- Belegar Ironhammer [Lord]
	{forename = "names_name_2147358029", surname = "names_name_2147358036", start_xp = 0, kill_if_AI = false, start_skills = {}},
	-- King Lunn Ironhammer [Thane]
	{forename = "names_name_2147358979", surname = "names_name_2147358036", start_xp = 4200, kill_if_AI = false, start_skills = {"wh_main_skill_all_all_self_blade_master_starter", "wh_main_skill_all_all_self_devastating_charge", "wh_main_skill_all_all_self_hard_to_hit", "wh_main_skill_all_all_self_deadly_blade"}},
	-- Throni Ironbrow [Runesmith]
	{forename = "names_name_2147358988", surname = "names_name_2147358994", start_xp = 4200, kill_if_AI = false, start_skills = {"wh2_dlc17_skill_dwf_runesmith_self_rune_of_speed", "wh_main_skill_dwf_runesmith_self_rune_of_wrath_&_ruin", "wh_main_skill_dwf_runesmith_self_rune_of_oath_&_steel", "wh_main_skill_dwf_runesmith_self_damping"}},
	-- Halkenhaf Stonebeard [Thane]
	{forename = "names_name_2147358982", surname = "names_name_2147358985", start_xp = 4200, kill_if_AI = true, start_skills = {"wh_main_skill_all_all_self_blade_master_starter", "wh_main_skill_all_all_self_devastating_charge", "wh_main_skill_all_all_self_hard_to_hit", "wh_main_skill_all_all_self_deadly_blade"}},
	-- Dramar Hammerfist [Engineer]
	{forename = "names_name_2147359003", surname = "names_name_2147359010", start_xp = 4200, kill_if_AI = true, start_skills = {"wh2_dlc17_skill_dwf_master_engineer_restock","wh2_main_skill_all_hero_assist_army_increase_mobility", "wh_main_skill_dwf_engineer_self_dead_eye", "wh2_main_skill_all_hero_passive_boost_income"}}
};

function belegar_start_experience()	
	local faction = cm:get_faction("wh_main_dwf_karak_izor");
	
	if faction then
		cm:disable_event_feed_events(true, "wh_event_category_traits_ancillaries", "", "");
		cm:disable_event_feed_events(true, "wh_event_category_character", "", "");
		
		local is_human = faction:is_human();
		local character_list = faction:character_list();
		
		for i = 0, character_list:num_items() - 1 do
			local current_char = character_list:item_at(i);
			local char_index = find_belegar_character(current_char);
			
			if char_index > 0 then
				belegar_give_start_experience(current_char, belegar_characters[char_index].start_xp);
				belegar_give_skills(current_char, belegar_characters[char_index].start_skills);
				belegar_kill_start_character(current_char, is_human, belegar_characters[char_index].kill_if_AI);
			end;
		end;
		
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_traits_ancillaries", "", "") end, 1);
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, 1);
	end;
end;

function find_belegar_character(character)
	for i = 1, #belegar_characters do
		if character:get_forename() == belegar_characters[i].forename and character:get_surname() == belegar_characters[i].surname then
			return i;
		end;
	end;
	
	return 0;
end;

function belegar_give_start_experience(character, xp)
	cm:add_agent_experience(cm:char_lookup_str(character:command_queue_index()), xp);
end;

function belegar_give_skills(character, skills)
	for i = 1, #skills do
		cm:force_add_skill(cm:char_lookup_str(character:command_queue_index()), skills[i]);
	end;
end;

function belegar_kill_start_character(character, is_human, kill)
	if not is_human and kill then
		cm:kill_character(character:command_queue_index(), true, true);
	end;
end;

function eight_peaks_setup()
	local skarsnik = cm:get_faction("wh_main_grn_crooked_moon");
	local belegar = cm:get_faction("wh_main_dwf_karak_izor");
	local queek = cm:get_faction("wh2_main_skv_clan_mors");
	local gits = cm:get_faction("wh_main_grn_necksnappers");
	
	if (skarsnik and skarsnik:is_human()) or (belegar and belegar:is_human()) or (queek and queek:is_human()) and gits and gits:has_faction_leader() then
		-- Stop Eight Peaks defender movement
		local gits_leader = gits:faction_leader():command_queue_index();
		local gits_leader_str = cm:char_lookup_str(gits_leader);
		
		cm:cai_disable_movement_for_character(gits_leader_str);
		
		-- Give him some extra units
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_black_orcs");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_black_orcs");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_big_uns");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_big_uns");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_big_uns");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_night_goblin_archers");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_night_goblin_archers");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_arrer_boyz");
		cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_arrer_boyz");
		
		if cm:is_multiplayer() then
			cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_big_uns");
			cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_mon_trolls");
			cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_mon_arachnarok_spider_0");
		else
			local difficulty = ci_get_difficulty();
			
			if difficulty > 1 then
				cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_inf_orc_big_uns");
			end;
			
			if difficulty > 2 then
				cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_mon_trolls");
			end;
			
			if difficulty > 3 then
				cm:grant_unit("settlement:wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_mon_arachnarok_spider_0");
			end;
		end;
		
		-- Give him XP
		cm:add_agent_experience(gits_leader_str, 2000);
		
		-- Give them some effects to survive
		cm:apply_effect_bundle_to_characters_force("wh_dlc06_bundle_eight_peaks_defender", gits_leader, 0, true);
	end;
	
	if skarsnik and skarsnik:is_human() then
		karak_force_ai_personality(true, false);
		
		-- Skarsnik does NOT own Karak Eight Peaks to start with
		cm:apply_effect_bundle("wh_dlc06_skarsnik_karak_owned_false", "wh_main_grn_crooked_moon", 0);
		
		if not cm:is_multiplayer() then
			cm:apply_effect_bundle("wh_dlc06_rival_hidden_boost", "wh_main_dwf_karak_izor", 0);
		end;
	else
		cm:apply_effect_bundle("wh_dlc06_skarsnik_anti_trait", "wh_main_grn_crooked_moon", 0);
	end;
	
	if belegar and belegar:is_human() then
		karak_force_ai_personality(false, true);
		
		-- Belegar does NOT own Karak Eight Peaks to start with
		cm:apply_effect_bundle("wh_dlc06_belegar_karak_owned_false_first", "wh_main_dwf_karak_izor", 0);
		
		if not cm:is_multiplayer() then
			cm:apply_effect_bundle("wh_dlc06_rival_hidden_boost", "wh_main_grn_crooked_moon", 0);
		end;
	end;
	
	if queek and queek:is_human() then
		karak_force_ai_personality(true, true);
		
		-- Queek does NOT own Karak Eight Peaks to start with
		cm:apply_effect_bundle("wh2_main_queek_karak_owned_false", "wh2_main_skv_clan_mors", 0);
	end;
end;

function karak_force_ai_personality(belegar, skarsnik)
	if belegar then
		cm:force_change_cai_faction_personality("wh_main_dwf_karak_izor", "dlc06_skarsnik_belegar_want_karak")
	end;
	
	if skarsnik then
		cm:force_change_cai_faction_personality("wh_main_grn_crooked_moon", "dlc06_skarsnik_belegar_want_karak");
	end;
end;

function Add_Karak_Eight_Peaks_Listeners()
	out("#### Adding Karak Eight Peaks Listeners ####");


	for i = 1, #karak_eight_peaks_factions do
		cm:add_faction_turn_start_listener_by_name(
			"karak_faction_turn_start", 
			karak_eight_peaks_factions, 
			function(context)
				-- this won't do anything ...
				local region = cm:get_region("wh_main_eastern_badlands_karak_eight_peaks");
				if not region then
					local owning_faction = region:owning_faction();
					
					if not owning_faction:is_null_interface() then
						eight_peaks_check(owning_faction:name());
					end
				end
			end, 
			true
		);
	end;

	cm:add_faction_turn_start_listener_by_name(
		"karak_faction_turn_start", 
		"wh_main_grn_necksnappers", 
		function(context)
			local faction = context:faction();
			if faction:has_faction_leader() then
				local skarsnik = cm:get_faction("wh_main_grn_crooked_moon");
				local belegar = cm:get_faction("wh_main_dwf_karak_izor");
				local queek = cm:get_faction("wh2_main_skv_clan_mors");
				
				if (skarsnik and skarsnik:is_human()) or (belegar and belegar:is_human()) or (skarsnik and skarsnik:is_human()) then
					cm:add_agent_experience(cm:char_lookup_str(faction:faction_leader():command_queue_index()), 200);
				end;
			end;
		end,
		true
	);

	cm:add_faction_turn_start_listener_by_name(
		"karak_faction_turn_start", 
		"wh_main_grn_greenskins", 
		function(context)
			cm:force_diplomacy("faction:wh_main_grn_greenskins", "faction:wh_main_grn_necksnappers", "form confederation", false, false, true);
		end,
		true
	);
	
	core:add_listener(
		"karak_eight_peaks_occupied",
		"GarrisonOccupiedEvent",
		function(context)
			return context:garrison_residence():region():name() == "wh_main_eastern_badlands_karak_eight_peaks";
		end,
		function(context)
			local character = context:character();
			local faction = character:faction();
			
			if not character:is_null_interface() and not faction:is_null_interface() then
				eight_peaks_check(faction:name());
			else
				eight_peaks_check(context:garrison_residence():region():owning_faction():name());
			end;
		end,
		true
	);

	core:add_listener(
		"karak_faction_joins_confederation",
		"FactionJoinsConfederation",
		function(context)
			local faction_name = context:faction():name();
			local confederation_name = context:confederation():name();
			
			return is_karak_eight_peaks_owner_faction(faction_name) or is_karak_eight_peaks_owner_faction(confederation_name);
		end,
		function(context)
			local region = cm:get_region("wh_main_eastern_badlands_karak_eight_peaks");
			
			if region and not region:is_abandoned() then
				eight_peaks_check(region:owning_faction():name());
			end;
		end,
		true
	);

	core:add_listener(
		"gits_faction_becomes_vassal",
		"ClanBecomesVassal",
		function(context)
			return context:faction():name() == "wh_main_grn_crooked_moon";
		end,
		function(context)
			local gits = cm:get_faction("wh_main_grn_necksnappers");
			
			if gits and gits:is_vassal() then
				if gits:is_ally_vassal_or_client_state_of(context:faction()) then
					cm:force_diplomacy("faction:wh_main_grn_necksnappers", "all", "all", true, true, true);
				end;
			end;
		end,
		true
	);

	local karak_icon_marker_added = false;
	local camera_moving = false;

	core:add_listener(
		"karak_icon_clicked",
		"ComponentLClickUp",
		function(context)
			return context.string == "glow" and not cm:is_multiplayer() and is_karak_eight_peaks_owner_faction(cm:model():world():whose_turn_is_it():name()) and not cm:model():pending_battle():is_active();
		end,
		function()
			local region = cm:get_region("wh_main_eastern_badlands_karak_eight_peaks");
			local owner = "";
			
			if region and not region:is_abandoned() then
				owner = region:owning_faction():name();
			end;
			
			if not camera_moving then
				cm:scroll_camera_from_current(false, 3, {489.527, 212.885, 14.768, 0.0, 12.0});
				camera_moving = true;
				cm:callback(function() camera_moving = false end, 3);
			end;
			
			if owner ~= cm:model():world():whose_turn_is_it():name() and not karak_icon_marker_added then
				karak_icon_marker_added = true;
				
				cm:add_marker("karak_eight_peaks_marker", "pointer", 489.4, 208.1, 1);
				
				cm:callback(
					function()
						cm:remove_marker("karak_eight_peaks_marker");
						karak_icon_marker_added = false;
					end,
					10
				);
			end;
		end,
		true
	);
end;


function eight_peaks_check(karak_owner)
	out("######## eight_peaks_check() ########");
	out("\tFaction: "..tostring(karak_owner));
	
	local owner_save_value = cm:get_saved_value("eight_peaks_event_" .. karak_owner);
	
	if is_karak_eight_peaks_owner_faction(karak_owner) then
		out("\towner_save_value = " .. tostring(owner_save_value));
		
		if not owner_save_value then
			cm:show_message_event_located(
				karak_owner,
				"event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_captured_karak_eight_peaks_title",
				"event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_captured_karak_eight_peaks_primary_detail_" .. karak_owner,
				"event_feed_strings_text_wh_dlc06_event_feed_string_scripted_event_captured_karak_eight_peaks_secondary_detail_" .. karak_owner,
				732,
				270,
				true,
				601
			);
			
			owner_save_value = true;
			
			cm:set_saved_value("eight_peaks_event_" .. karak_owner, true);
		end;
	end;
	
	if karak_owner == "wh_main_dwf_karak_izor" then
		out("\tRemoving Belegar effect: wh_dlc06_belegar_karak_owned_false_first");
		cm:remove_effect_bundle("wh_dlc06_belegar_karak_owned_false_first", "wh_main_dwf_karak_izor");
	end;
	
	local belegar_owner = (karak_owner == "wh_main_dwf_karak_izor");
	local skarsnik_owner = (karak_owner == "wh_main_grn_crooked_moon");
	local queek_owner = (karak_owner == "wh2_main_skv_clan_mors");
	out("\tBELEGAR OWNS KARAK EIGHT PEAKS : " .. tostring(belegar_owner));
	out("\tSKARSNIK OWNS KARAK EIGHT PEAKS : " .. tostring(skarsnik_owner));
	out("\tQUEEK OWNS KARAK EIGHT PEAKS : " .. tostring(queek_owner));
	
	out("\tRemoving effects...");
	cm:remove_effect_bundle("wh_dlc06_belegar_karak_owned_false", "wh_main_dwf_karak_izor");
	cm:remove_effect_bundle("wh_dlc06_belegar_karak_owned_true", "wh_main_dwf_karak_izor");
	cm:remove_effect_bundle("wh_dlc06_skarsnik_karak_owned_false", "wh_main_grn_crooked_moon");
	cm:remove_effect_bundle("wh_dlc06_skarsnik_karak_owned_true", "wh_main_grn_crooked_moon");
	cm:remove_effect_bundle("wh2_main_queek_karak_owned_false", "wh2_main_skv_clan_mors");
	cm:remove_effect_bundle("wh2_main_queek_karak_owned_true", "wh2_main_skv_clan_mors");
	
	out("\tApplying effects...");
	
	if owner_save_value then
		if karak_owner == "wh_main_dwf_karak_izor" then
			out("\twh_dlc06_belegar_karak_owned_" .. tostring(belegar_owner));
			cm:apply_effect_bundle("wh_dlc06_belegar_karak_owned_" .. tostring(belegar_owner), "wh_main_dwf_karak_izor", 0);
		end;
	end;
	
	out("\twh2_main_queek_karak_owned_" .. tostring(queek_owner));
	cm:apply_effect_bundle("wh2_main_queek_karak_owned_" .. tostring(queek_owner), "wh2_main_skv_clan_mors", 0);
	
	out("\twh_dlc06_skarsnik_karak_owned_" .. tostring(skarsnik_owner));
	cm:apply_effect_bundle("wh_dlc06_skarsnik_karak_owned_" .. tostring(skarsnik_owner), "wh_main_grn_crooked_moon", 0);
	out("#############################");
end;