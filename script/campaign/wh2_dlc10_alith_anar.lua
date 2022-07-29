local assassination_faction = "wh2_main_hef_nagarythe";
local assassination_turns_per_cycle = 20;
local assassination_new_targets_upon_completion = true;
local assassination_targets = {};
assassination_targets.timer = 0;
assassination_targets.last_targets = {};
assassination_targets.last_missions = {};
assassination_targets.targets_killed = 0;
assassination_targets.targets_complete = 0;
assassination_targets.force_new_targets = false;

local assassination_reward_money_base_reward = 2000;		-- The base amount that will be given as a reward
local assassination_reward_money_distance_reward = 20000;	-- The reward based on the targets distance to the player
local assassination_reward_money_per_rank_reward = 100;		-- The reward for each level of the target character
local assassination_reward_money_per_target_ally = 300;		-- The reward for a target you are not at war with, given per ally they have
local assassination_reward_money_per_force_reward = 100;	-- The reward given for every force in the target faction
local assassination_reward_money_unit_value_mod = 0.2;		-- The modifier applied to the reward value of the target forces units
local assassination_reward_money_max_reward = 25000;		-- The maximum amount of money that can be given as a reward

local assassination_reward_influence_base_reward = 20;		-- The base amount of influence rewarded for influence rewards
local assassination_reward_influence_neutral = 10;			-- The amount of extra influence rewarded for neutral targets
local assassination_reward_influence_forces = 1;			-- The amount of influence awarded for every force the target faction has
local assassination_reward_influence_elf = 10;				-- The amount of extra influence rewarded if the target is a High Elf
local assassination_reward_influence_distance = 100;		-- The influence reward based on the targets distance to the player
local assassination_reward_influence_max = 120;				-- The maximum amount of influence that can be given as a reward

local assassination_reward_max_distance = 1300000;
local assassination_reward_max_target_distance = assassination_reward_max_distance / 3;
local assassination_reward_effect_turns = 20;

local assassination_reward_money_extras = {
	["wh2_dlc10_alith_anar_assassination_hellebron"] = "effect",
	["wh2_dlc10_alith_anar_assassination_malekith"] = "effect",
	["wh2_dlc10_alith_anar_assassination_morathi"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_peace_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_3"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_3"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_leader_1"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_leader_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_peace_dark_elf_leader_3"] = "influence",
	["wh2_dlc10_alith_anar_assassination_peace_leader_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_peace_leader_2"] = "influence",
	["wh2_dlc10_alith_anar_assassination_peace_leader_3"] = "influence",
	["wh2_dlc10_alith_anar_assassination_war_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_war_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_3"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_3"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_leader_1"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_leader_2"] = "influence",
	["wh2_dlc10_alith_anar_assassination_war_dark_elf_leader_3"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_leader_1"] = "influence",
	["wh2_dlc10_alith_anar_assassination_war_leader_2"] = "effect",
	["wh2_dlc10_alith_anar_assassination_war_leader_3"] = "effect"
};

local assassination_targets_first_turn_exclusions = {
	subtypes = {
		["brt_louen_leoncouer"] = true,
		["chs_archaon"] = true,
		["chs_kholek_suneater"] = true,
		["chs_prince_sigvald"] = true,
		["dlc03_bst_khazrak"] = true,
		["dlc03_bst_malagor"] = true,
		["dlc04_emp_volkmar"] = true,
		["dlc04_vmp_helman_ghorst"] = true,
		["dlc04_vmp_vlad_con_carstein"] = true,
		["dlc05_bst_morghur"] = true,
		["dlc05_wef_durthu"] = true,
		["dlc05_wef_orion"] = true,
		["dlc06_dwf_belegar"] = true,
		["dlc06_grn_skarsnik"] = true,
		["dlc06_grn_wurrzag_da_great_prophet"] = true,
		["dlc07_brt_alberic"] = true,
		["dlc07_brt_fay_enchantress"] = true,
		["dwf_thorgrim_grudgebearer"] = true,
		["dwf_ungrim_ironfist"] = true,
		["emp_balthasar_gelt"] = true,
		["emp_karl_franz"] = true,
		["grn_azhag_the_slaughterer"] = true,
		["grn_grimgor_ironhide"] = true,
		["pro01_dwf_grombrindal"] = true,
		["pro02_vmp_isabella_von_carstein"] = true,
		["vmp_heinrich_kemmler"] = true,
		["vmp_mannfred_von_carstein"] = true,
		["wh2_dlc09_skv_tretch_craventail"] = true,
		["wh2_dlc09_tmb_arkhan"] = true,
		["wh2_dlc09_tmb_khalida"] = true,
		["wh2_dlc09_tmb_khatep"] = true,
		["wh2_dlc09_tmb_settra"] = true,
		["wh2_main_def_malekith"] = true,
		["wh2_main_def_morathi"] = true,
		["wh2_main_hef_teclis"] = true,
		["wh2_main_hef_tyrion"] = true,
		["wh2_main_lzd_kroq_gar"] = true,
		["wh2_main_lzd_lord_mazdamundi"] = true,
		["wh2_main_skv_lord_skrolk"] = true,
		["wh2_main_skv_queek_headtaker"] = true,
		["wh_dlc08_nor_throgg"] = true,
		["wh_dlc08_nor_wulfrik"] = true,
		["wh2_dlc10_def_crone_hellebron"] = true
	},
	named = {
		["wh2_main_def_scourge_of_khaine"] = {
			["1396496474"] = true
		}
	}
};

function add_alith_anar_listeners()
	out("#### Adding Alith Anar Listeners ####");
	local alith_anar = cm:model():world():faction_by_key(assassination_faction);
	
	if alith_anar:is_human() == true then
		if cm:model():campaign_name("wh2_main_great_vortex") then
			-- Vortex: 850000, Mortal Empires: 1300000
			assassination_reward_max_distance = 850000;
			assassination_reward_max_target_distance = assassination_reward_max_distance / 3;
		end
		
		cm:add_faction_turn_start_listener_by_name(
			"assassination_target_turnstart",
			assassination_faction,
			function(context)
				assassination_turn_start(context)
			end,
			true
		);
		
		core:add_listener(
			"assassination_MissionSucceeded",
			"MissionSucceeded",
			true,
			function(context) assassination_mission_completed(context, true) end,
			true
		);
		core:add_listener(
			"assassination_MissionCancelled",
			"MissionCancelled",
			true,
			function(context) assassination_mission_completed(context, false) end,
			true
		);
		
		if cm:is_new_game() == true then
			-- The initial assassination missions
			cm:callback(function()
				assassination_generate_targets(true);
			end, 0.9);
		else
			local ui_root = core:get_ui_root();
			local alith_anar_holder = find_uicomponent(ui_root, "alith_anar_holder");
			alith_anar_holder:InterfaceFunction("SetCountDown", assassination_targets.timer);
		end
	end
end

function assassination_turn_start(context)
	if assassination_targets.timer == 20 and assassination_targets.force_new_targets == true then
		assassination_targets.force_new_targets = false;
		out("assassination_targets.force_new_targets = false");
	end

	assassination_targets.timer = assassination_targets.timer - 1;
	
	if assassination_targets.timer == 0 then
		-- FAIL THE CURRENT MISSIONS
		for i = 1, #assassination_targets.last_missions do
			out("Cancelling previous Assassination: "..assassination_targets.last_missions[i]);
			cm:cancel_custom_mission(assassination_faction, assassination_targets.last_missions[i], false);
		end
		
		-- GENERATE NEW ONES
		assassination_generate_targets(false);
	elseif assassination_new_targets_upon_completion == true and assassination_targets.force_new_targets == true then
		-- FAIL THE CURRENT MISSIONS
		for i = 1, #assassination_targets.last_missions do
			out("Cancelling previous Assassination: "..assassination_targets.last_missions[i]);
			cm:cancel_custom_mission(assassination_faction, assassination_targets.last_missions[i], false);
		end
		
		assassination_targets.force_new_targets = false;
		out("assassination_targets.force_new_targets = false");
		
		-- GENERATE NEW ONES
		assassination_generate_targets(false);
	end
	
	local ui_root = core:get_ui_root();
	local alith_anar_holder = find_uicomponent(ui_root, "alith_anar_holder");
	alith_anar_holder:InterfaceFunction("SetCountDown", assassination_targets.timer);
end

function assassination_generate_targets(new_game)
	out.design("------------------------------------------------------------------------------------------------------------------------------");
	out.design("---- GENERATING ASSASSINATION TARGETS");
	out.design("------------------------------------------------------------------------------------------------------------------------------");
	local alith_anar = cm:model():world():faction_by_key(assassination_faction);
	local selected_targets = {};
	
	local dark_elf_factions = assassination_pick_random_factions(nil, "all", "wh2_main_sc_def_dark_elves");
	local war_factions = assassination_pick_random_factions(nil, "at_war", nil);
	local known_factions = assassination_pick_random_factions(nil, "known", nil);
	
	-- STRONGEST DARK ELF
	out.design("Evaluating Strongest Dark Elf target:");
	out.inc_tab("design");
	local dark_elf_target = {};
	dark_elf_target.faction = "";
	dark_elf_target.strength = 0;
	
	for i = 1, #dark_elf_factions do
		local faction = dark_elf_factions[i];
		local force_list = faction:military_force_list();
		out.design(faction:name());
		
		for j = 0, force_list:num_items() - 1 do
			local force = force_list:item_at(j);
			local log_failed = true;
			local log_distance = 0;
			local log_strength = 0;
			
			-- Isn't a garrison
			if force:is_armed_citizenry() == false
			-- Has a general
			and force:has_general() == true
			-- Wasn't a target in the last assassination round
			and assassination_targets.last_targets[force:general_character():family_member():command_queue_index()] == nil
			-- Isn't one of the targets we exclude on the first target generation
			and (new_game == false or assassination_target_is_excluded(force:general_character()) ~= true)
			-- Has 15 or more units, but only if its not a new game
			and (new_game == true or force:unit_list():num_items() >= 10) then
				local pos_x = force:general_character():logical_position_x();
				local pos_y = force:general_character():logical_position_y();
				local distance = assassination_distance_to_assassin(alith_anar, pos_x, pos_y);
				log_distance = distance;
				
				if distance <= assassination_reward_max_target_distance then
					local strength = force:strength();
					log_strength = strength;
					 
					if strength > dark_elf_target.strength then
						dark_elf_target = {};
						dark_elf_target.cqi = force:general_character():family_member():command_queue_index();
						dark_elf_target.faction = faction:name();
						dark_elf_target.subculture = faction:subculture();
						dark_elf_target.strength = strength;
						dark_elf_target.leader = force:general_character():is_faction_leader();
						dark_elf_target.subtype = force:general_character():character_subtype_key();
						dark_elf_target.rank = force:general_character():rank();
						dark_elf_target.at_war = faction:at_war_with(alith_anar);
						dark_elf_target.pos = {};
						dark_elf_target.pos.x = pos_x;
						dark_elf_target.pos.y = pos_y;
						dark_elf_target.distance = distance;
						dark_elf_target.ally_count = faction:num_allies();
						dark_elf_target.force_count = force_list:num_items();
						dark_elf_target.force_value = assassination_get_army_cost(force);
						log_failed = false;
					end
				end
			end
			
			if log_failed == true then
				local reason = "";
				
				if (force:is_armed_citizenry() == false) == false then
					--out.design("Failed "..j..": ".."Garrison");
				elseif (force:has_general() == true) == false then
					out.design("Failed "..j..": ".."No General");
				elseif (assassination_targets.last_targets[force:general_character():family_member():command_queue_index()] == nil) == false then
					out.design("Failed "..j..": ".."Was Previous Target");
				elseif ((new_game == false or assassination_target_is_excluded(force:general_character()) ~= true)) == false then
					out.design("Failed "..j..": ".."Excluded Target");
				elseif ((new_game == true or force:unit_list():num_items() >= 10)) == false then
					out.design("Failed "..j..": ".."Less Than 10 Units");
				elseif (log_distance <= assassination_reward_max_target_distance) == false then
					out.design("Failed "..j..": ".."Distance - "..log_distance.." / "..assassination_reward_max_target_distance);
				else
					out.design("Failed "..j..": ".."Strength - "..log_strength.." / "..dark_elf_target.strength);
				end
			else
				out.design("Passed "..j..": "..dark_elf_target.faction);
			end
		end
	end
	
	-- SOMEONE YOU ARE AT WAR WITH
	out.dec_tab("design");
	out.design("Evaluating War target:");
	out.inc_tab("design");
	local war_targets = {};
	local war_target = {};
	war_target.faction = "";
	
	for i = 1, #war_factions do
		local faction = war_factions[i];
		out.design(faction:name());
		
		-- Exclude the faction we selected above
		if faction:name() ~= dark_elf_target.faction then
			local force_list = faction:military_force_list();
			
			for j = 0, force_list:num_items() - 1 do
				local force = force_list:item_at(j);
				
				-- Isn't a garrison
				if force:is_armed_citizenry() == false
				-- Has a general
				and force:has_general() == true
				-- Wasn't a target in the last assassination round
				and assassination_targets.last_targets[force:general_character():family_member():command_queue_index()] == nil
				-- Isn't one of the targets we exclude on the first target generation
				and (new_game == false or assassination_target_is_excluded(force:general_character()) ~= true)
				-- Isn't High Elf Legendary Lord
				and (force:general_character():character_subtype("wh2_main_hef_tyrion")
				or force:general_character():character_subtype("wh2_main_hef_teclis")
				or force:general_character():character_subtype("wh2_dlc10_hef_alarielle")) == false
				-- Has 15 or more units
				and (new_game or force:unit_list():num_items() >= 10) then
					local pos_x = force:general_character():logical_position_x();
					local pos_y = force:general_character():logical_position_y();
					local distance = assassination_distance_to_assassin(alith_anar, pos_x, pos_y);
					
					if distance <= assassination_reward_max_target_distance then
						local new_target = {};
						new_target.cqi = force:general_character():family_member():command_queue_index();
						new_target.faction = faction:name();
						new_target.subculture = faction:subculture();
						new_target.leader = force:general_character():is_faction_leader();
						new_target.subtype = force:general_character():character_subtype_key();
						new_target.rank = force:general_character():rank();
						new_target.at_war = faction:at_war_with(alith_anar);
						new_target.pos = {};
						new_target.pos.x = pos_x;
						new_target.pos.y = pos_y;
						new_target.distance = distance;
						new_target.ally_count = faction:num_allies();
						new_target.force_count = force_list:num_items();
						new_target.force_value = assassination_get_army_cost(force);
						table.insert(war_targets, new_target);
					end
				end
			end
		end
	end
	
	if #war_targets > 0 then
		local rand = cm:random_number(#war_targets);
		war_target = war_targets[rand];
	end
	
	-- NEUTRAL KNOWN FACTION
	out.dec_tab("design");
	out.design("Evaluating Neutral target:");
	out.inc_tab("design");
	local neutral_targets = {};
	local neutral_target = {};
	
	for i = 1, #known_factions do
		local faction = known_factions[i];
		out.design(faction:name());
		
		-- Make sure this faction is neutral with the player...
		if faction:at_war_with(alith_anar) == false and faction:is_ally_vassal_or_client_state_of(alith_anar) == false
		-- ...and not one of the ones selected above or a Elf
		and faction:name() ~= dark_elf_target.faction and faction:name() ~= war_target.faction then
			local subculture_exclude = "wh2_main_sc_hef_high_elves";
			
			if new_game == false then
				subculture_exclude = "wh2_main_sc_def_dark_elves";
			end
			
			if faction:subculture() ~= subculture_exclude then
				local force_list = faction:military_force_list();
				
				for j = 0, force_list:num_items() - 1 do
					local force = force_list:item_at(j);
					
					-- Isn't a garrison
					if force:is_armed_citizenry() == false
					-- Has a general
					and force:has_general() == true
					-- Wasn't a target in the last assassination round
					and assassination_targets.last_targets[force:general_character():family_member():command_queue_index()] == nil
					-- Isn't one of the targets we exclude on the first target generation
					and (new_game == false or assassination_target_is_excluded(force:general_character()) ~= true)
					-- Isn't High Elf Legendary Lord
					and (force:general_character():character_subtype("wh2_main_hef_tyrion")
					or force:general_character():character_subtype("wh2_main_hef_teclis")
					or force:general_character():character_subtype("wh2_dlc10_hef_alarielle")) == false
					-- Has 15 or more units
					and (new_game or force:unit_list():num_items() >= 10) then
						local pos_x = force:general_character():logical_position_x();
						local pos_y = force:general_character():logical_position_y();
						local distance = assassination_distance_to_assassin(alith_anar, pos_x, pos_y);
						
						if distance <= assassination_reward_max_target_distance then
							neutral_target = {};
							neutral_target.cqi = force:general_character():family_member():command_queue_index();
							neutral_target.faction = faction:name();
							neutral_target.subculture = faction:subculture();
							neutral_target.leader = force:general_character():is_faction_leader();
							neutral_target.subtype = force:general_character():character_subtype_key();
							neutral_target.rank = force:general_character():rank();
							neutral_target.at_war = faction:at_war_with(alith_anar);
							neutral_target.pos = {};
							neutral_target.pos.x = pos_x;
							neutral_target.pos.y = pos_y;
							neutral_target.distance = distance;
							neutral_target.ally_count = faction:num_allies();
							neutral_target.force_count = force_list:num_items();
							neutral_target.force_value = assassination_get_army_cost(force);
							table.insert(neutral_targets, neutral_target);
						end
					end
				end
			end
		end
	end
	
	if #neutral_targets > 0 then
		local rand = cm:random_number(#neutral_targets);
		neutral_target = neutral_targets[rand];
	end
	
	out.dec_tab("design");
	
	-- BACKUP TARGETS
	-- If we still don't have 3 targets given the above criteria we're going to pick random ones to get any remaining
		
	if dark_elf_target.cqi ~= nil then
		out.design("Found Dark Elf target... ("..tostring(dark_elf_target.cqi)..") ("..tostring(dark_elf_target)..")");
		table.insert(selected_targets, dark_elf_target);
	else
		out.design("Didn't find Dark Elf target...");
	end
	if war_target.cqi ~= nil then
		out.design("Found War target... ("..tostring(war_target.cqi)..") ("..tostring(war_target)..")");
		table.insert(selected_targets, war_target);
	else
		out.design("Didn't find War target...");
	end
	if neutral_target.cqi ~= nil then
		out.design("Found Neutral target... ("..tostring(neutral_target.cqi)..") ("..tostring(neutral_target)..")");
		table.insert(selected_targets, neutral_target);
	else
		out.design("Didn't find Neutral target...");
	end
	out.dec_tab("design");
	
	if #selected_targets < 3 then
		out.design("NOT ENOUGH TARGETS FOUND (Found: "..tostring(#selected_targets)..")");
		selected_targets = assassination_generate_backup_targets(selected_targets, false);
		
		if #selected_targets < 3 then
			selected_targets = assassination_generate_backup_targets(selected_targets, true);
		end
		
		if #selected_targets < 3 then
			-- This should never happen but we STILL don't have 3 targets... just go on with however many we have and pray to Sigmar
			out.design("~~~~ WARNING: Assassination backup target selection didn't have enough factions ~~~~");
		end
	end
	
	-- Actually trigger the missions
	out.design("Triggering Missions...");
	out.inc_tab("design");
	assassination_targets.last_targets = {};
	assassination_targets.last_missions = {};
	
	cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_missions_objectives", "");
	
	for i = 1, #selected_targets do
		local mission_prefix, append_num = assassination_get_mission_key(selected_targets[i]);
		local mission_key = mission_prefix;
		local reward_key = mission_prefix;
		
		if append_num == true then
			mission_key = mission_key.."_"..i;
			reward_key = reward_key.."_"..cm:random_number(3, 1);
		end
		
		out.design("Mission Key: "..mission_key);
		out.design("Reward Key: "..reward_key);
		out.design("Target CQI: "..selected_targets[i].cqi);
		out.design("Target Subculture: "..selected_targets[i].subculture);
		
		local mm = mission_manager:new(assassination_faction, mission_key);
		mm:set_mission_issuer("CLAN_ELDERS");
		mm:add_new_objective("KILL_CHARACTER_BY_ANY_MEANS");
		mm:add_condition("family_member "..selected_targets[i].cqi);
		mm:set_turn_limit(assassination_turns_per_cycle);
		
		local reward = assassination_calculate_mission_reward(selected_targets[i], "money");
		reward = math.ceilTo(reward, 100); -- Round up to nearest 100
		out.design("Money Payload: "..reward);
		mm:add_payload("money "..reward);
		
		local influence_reward = assassination_calculate_mission_reward(selected_targets[i], "influence");
		out.design("Influence Payload: "..influence_reward);
		mm:add_payload("influence "..influence_reward);
		
		if assassination_reward_money_extras[reward_key] ~= nil then
			out.design("Adding Extra Reward...");
			if assassination_reward_money_extras[reward_key] == "effect" then
				mm:add_payload("effect_bundle{bundle_key "..reward_key..";turns "..assassination_reward_effect_turns..";}");
				out.design("Effect Payload: "..reward_key.." for "..assassination_reward_effect_turns.." turns");
			end
		end
		
		mm:set_should_whitelist(false);
		mm:trigger();
		
		assassination_targets.last_targets[selected_targets[i].cqi] = true;
		table.insert(assassination_targets.last_missions, mission_key);
	end
	out.dec_tab("design");
	
	cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_faction_missions_objectives", "") end, 1);
	
	assassination_targets.timer = assassination_turns_per_cycle;
	assassination_targets.targets_killed = 0;
	assassination_targets.targets_complete = 0;
	assassination_update_ui(assassination_targets.last_missions);
	
	if new_game == true then
		core:trigger_event("ScriptEventAssassinationFirstTargets");
	else
		core:trigger_event("ScriptEventAssassinationNewTargets");
	end
	
	cm:show_message_event(
		assassination_faction,
		"event_feed_strings_text_wh2_dlc10_event_feed_string_scripted_event_assassination_targets_title",
		"event_feed_strings_text_wh2_dlc10_event_feed_string_scripted_event_assassination_targets_primary_detail",
		"event_feed_strings_text_wh2_dlc10_event_feed_string_scripted_event_assassination_targets_secondary_detail",
		false,
		1014
	);
	
	out.design("------------------------------------------------------------------------------------------------------------------------------");
	out.design("------------------------------------------------------------------------------------------------------------------------------");
end

function assassination_generate_backup_targets(selected_targets, distance_check)
	local alith_anar = cm:model():world():faction_by_key(assassination_faction);
	local random_factions = assassination_pick_random_factions(nil, "all", nil);
	out.design("Selecting "..(3 - #selected_targets).." random backup targets...");
	out.inc_tab("design");
	
	for i = 1, #random_factions do
		local faction = random_factions[i];
		local force_list = faction:military_force_list();
		local real_forces = {};
		
		for j = 0, force_list:num_items() - 1 do
			local force = force_list:item_at(j);
			
			-- Isn't a garrison and has a general
			if force:is_armed_citizenry() == false
			-- Has a general
			and force:has_general() == true
			-- Wasn't a target in the last assassination round
			and assassination_targets.last_targets[force:general_character():family_member():command_queue_index()] == nil
			-- Isn't one of the targets we exclude on the first target generation
			and (new_game == false or assassination_target_is_excluded(force:general_character()) ~= true)
			-- Isn't High Elf Legendary Lord
			and (force:general_character():character_subtype("wh2_main_hef_tyrion")
			or force:general_character():character_subtype("wh2_main_hef_teclis")
			or force:general_character():character_subtype("wh2_dlc10_hef_alarielle")) == false then
				if distance_check == true then
					local pos_x = force:general_character():logical_position_x();
					local pos_y = force:general_character():logical_position_y();
					local distance = assassination_distance_to_assassin(alith_anar, pos_x, pos_y);
						
					if distance <= assassination_reward_max_target_distance then
						table.insert(real_forces, force);
					end
				else
					table.insert(real_forces, force);
				end
			end
		end
		
		if #real_forces > 0 then
			local rand = cm:random_number(#real_forces);
			local force = real_forces[rand];
			local pos_x = force:general_character():logical_position_x();
			local pos_y = force:general_character():logical_position_y();
			local distance = assassination_distance_to_assassin(alith_anar, pos_x, pos_y);
			
			local random_target = {};
			random_target.cqi = force:general_character():family_member():command_queue_index();
			random_target.subculture = faction:subculture();
			random_target.leader = force:general_character():is_faction_leader();
			random_target.subtype = force:general_character():character_subtype_key();
			random_target.rank = force:general_character():rank();
			random_target.at_war = faction:at_war_with(alith_anar);
			random_target.pos = {};
			random_target.pos.x = pos_x;
			random_target.pos.y = pos_y;
			random_target.distance = distance;
			random_target.ally_count = faction:num_allies();
			random_target.force_count = faction:military_force_list():num_items();
			random_target.force_value = assassination_get_army_cost(force);
			table.insert(selected_targets, random_target);
			
			if #selected_targets >= 3 then
				break;
			end
		end
	end
	out.dec_tab("design");
	
	return selected_targets;
end

function assassination_update_ui(target_missions)
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction == assassination_faction then
		out.design("Updating Assassination Target UI for "..local_faction);
		local ui_root = core:get_ui_root();
		local alith_anar_holder = find_uicomponent(ui_root, "alith_anar_holder");
		out.design("\talith_anar_holder: "..tostring(alith_anar_holder));
		
		if alith_anar_holder then
			out.design("\ttarget_missions: "..#target_missions);
			if #target_missions >= 3 then
				alith_anar_holder:InterfaceFunction("SetTargets", target_missions[1], target_missions[2], target_missions[3]);
				out.design("\tInterface Function called!");
			else
				alith_anar_holder:InterfaceFunction("SetTargets", unpack(target_missions));
				out.design("\tInterface Function called!");
			end
		end
		
		alith_anar_holder:InterfaceFunction("SetCountDown", assassination_targets.timer);
	end
end

function assassination_pick_random_factions(amount, faction_type, optional_subculture)
	local assassin = cm:model():world():faction_by_key(assassination_faction);
	local possible_factions = {};
	local selected_factions = {};
	local faction_list = nil;
	faction_type = faction_type or "all";
	out.design("assassination_pick_random_factions : "..faction_type.." - "..tostring(optional_subculture or ""));
	
	if faction_type == "known" then
		faction_list = assassin:factions_met();
	elseif faction_type == "at_war" then
		faction_list = assassin:factions_at_war_with();
	else
		faction_list = cm:model():world():faction_list();
	end
	
	out.design("\tFaction List: "..faction_list:num_items());
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		-- Exclude the players own faction and factions with no forces
		if faction:name() ~= assassination_faction and faction:military_force_list():num_items() > 0 then
			if optional_subculture == nil then
				table.insert(possible_factions, faction);
			else
				if faction:subculture() == optional_subculture then
					table.insert(possible_factions, faction);
				end
			end
		end
	end
	
	-- If amount was not supplied then return all of the results
	amount = amount or #possible_factions;
	out.design("\tAmount Required: "..tostring(amount));
	out.design("\tpossible_factions: "..tostring(#possible_factions));
	
	for i = 1, amount do
		local rand = cm:random_number(#possible_factions);
		local pick = possible_factions[rand];
		table.insert(selected_factions, pick);
		table.remove(possible_factions, rand);
	end
	
	out.design("\tselected_factions: "..tostring(#selected_factions));
	return selected_factions;
end

function assassination_get_mission_key(target)
	if target.subtype == "wh2_main_def_malekith" then
		return "wh2_dlc10_alith_anar_assassination_malekith", false;
	elseif target.subtype == "wh2_main_def_morathi" then
		return "wh2_dlc10_alith_anar_assassination_morathi", false;
	elseif target.subtype == "wh2_dlc10_def_crone_hellebron" then
		return "wh2_dlc10_alith_anar_assassination_hellebron", false;
	end
	
	local key = "wh2_dlc10_alith_anar_assassination";
	
	if target.at_war == true then
		key = key.."_war";
	else
		key = key.."_peace";
	end
	
	if target.subculture == "wh2_main_sc_def_dark_elves" then
		key = key.."_dark_elf";
	end
	
	return key, true;
end

function assassination_calculate_mission_reward(target, reward_type)
	out.design("Calculating reward ("..reward_type..")...");
	local reward = 0;
	local complex_distance_reward = false;
	
	if reward_type == "money" then
		out.inc_tab("design");
		
		-- Base Reward
		reward = reward + assassination_reward_money_base_reward;
		out.design("Base Reward: "..reward);
		
		-- Lord Rank
		local rank_reward = target.rank * assassination_reward_money_per_rank_reward;
		reward = reward + rank_reward;
		out.design("Lord Rank Reward: "..rank_reward.." ("..reward..")");
		
		-- Force Value
		local force_reward = target.force_value * assassination_reward_money_unit_value_mod;
		reward = reward + force_reward;
		out.design("Force Value Reward: "..force_reward.." ("..reward..")");
		
		-- Force Count
		local force_reward = target.force_count * assassination_reward_money_per_force_reward;
		reward = reward + force_reward;
		out.design("Force Count Reward: "..force_reward.." ("..reward..")");
		
		-- Allies (If target is neutral)
		if target.at_war == false then
			local neutral_reward = target.ally_count * assassination_reward_money_per_target_ally;
			reward = reward + neutral_reward;
			out.design("Neutrality Reward: "..neutral_reward.." ("..reward..")");
		end
		
		-- Distance
		local distance = target.distance;
		local distance_reward = (distance / assassination_reward_max_distance) * assassination_reward_money_distance_reward;
		
		if complex_distance_reward == true then
			local temp_max =  assassination_reward_money_distance_reward;
			local bracket1 = assassination_reward_max_distance * 0.3;
			local bracket2 = assassination_reward_max_distance * 0.6;
			local bracket3 = assassination_reward_max_distance * 1;
			
			local rate1 = 2;
			local rate2 = 2;
			local rate3 = 0.5;	
			
			local endpoint = bracket1 * rate1 + (bracket2 - bracket1) * rate2 + (bracket3 - bracket2) * rate3;
			local bounty_relative = endpoint / assassination_reward_max_distance;
			temp_max = temp_max * bounty_relative;
			
			if distance <= bracket1 then
				distance_reward = distance * rate1 / endpoint * temp_max;
			elseif distance <= bracket2 then
				distance_reward = (bracket1 * rate1 + (distance - bracket1) * rate2) / endpoint * temp_max;
			else
				distance_reward = (bracket1 * rate1 + (bracket2-bracket1) * rate2 + (distance - bracket2) * rate3) / endpoint * temp_max;
			end
		end
		
		reward = reward + distance_reward;
		out.design("Distance Reward: "..distance_reward.." ("..reward..")");
		
		-- Half money reward for High Elf target because influence is increased
		if target.subculture == "wh2_main_sc_hef_high_elves" then
			reward = reward / 2;
			out.design("Reward halved due to High Elf target... ("..reward..")");
		end
		
		reward = math.ceil(reward);
		out.design("Rounding reward... ("..reward..")");
		
		if reward > assassination_reward_money_max_reward then
			reward = assassination_reward_money_max_reward;
			out.design("Clamping reward... ("..reward..")");
		end
		
		out.dec_tab("design");
	elseif reward_type == "influence" then
		out.inc_tab("design");
		
		-- Base Influence
		reward = reward + assassination_reward_influence_base_reward;
		out.design("Base Reward: "..reward);
		
		-- Neutral Target
		if target.at_war == false then
			reward = reward + assassination_reward_influence_neutral;
			out.design("Neutrality Reward: "..assassination_reward_influence_neutral.." ("..reward..")");
		end
		
		-- Rough Faction Strength
		local strength_reward = target.force_count * assassination_reward_influence_forces;
		reward = reward + strength_reward;
		out.design("Faction Strength Reward: "..strength_reward.." ("..reward..")");
		
		-- High Elf Target
		if target.subculture == "wh2_main_sc_hef_high_elves" then
			reward = reward + assassination_reward_influence_elf;
			out.design("High Elf Reward: "..assassination_reward_influence_elf.." ("..reward..")");
		end
		
		-- Distance
		local distance = target.distance;
		local distance_reward = (distance / assassination_reward_max_distance) * assassination_reward_influence_distance;
		
		if complex_distance_reward == true then
			local temp_max =  assassination_reward_influence_distance;
			local bracket1 = assassination_reward_max_distance * 0.2;
			local bracket2 = assassination_reward_max_distance * 0.5;
			local bracket3 = assassination_reward_max_distance * 1;
			
			local rate1 = 2;
			local rate2 = 2;
			local rate3 = 0.5;
			
			local endpoint = bracket1 * rate1 + (bracket2 - bracket1) * rate2 + (bracket3 - bracket2) * rate3;
			local bounty_relative = endpoint / assassination_reward_max_distance;
			temp_max = temp_max * bounty_relative;
			
			if distance <= bracket1 then
				distance_reward = distance * rate1 / endpoint * temp_max;
			elseif distance <= bracket2 then
				distance_reward = (bracket1 * rate1 + (distance - bracket1) * rate2) / endpoint * temp_max;
			else
				distance_reward = (bracket1 * rate1 + (bracket2-bracket1) * rate2 + (distance - bracket2) * rate3) / endpoint * temp_max;
			end
		end
		
		reward = reward + distance_reward;
		out.design("Distance Reward: "..distance_reward.." ("..reward..")");
		
		reward = math.ceil(reward);
		out.design("Rounding reward... ("..reward..")");
		
		if reward > assassination_reward_influence_max then
			reward = assassination_reward_influence_max;
			out.design("Clamping reward... ("..reward..")");
		end
		
		out.dec_tab("design");
	end
	
	return reward;
end

function assassination_get_army_cost(force)
	local total_cost = 0;
	
	if force ~= nil and force:is_null_interface() == false then
		local unit_list = force:unit_list();
		
		for i = 0, unit_list:num_items() - 1 do
			local unit = unit_list:item_at(i);
			total_cost = total_cost + unit:get_unit_custom_battle_cost(); -- Best indicator of unit value
		end
	end
	
	return total_cost;
end

function assassination_distance_to_assassin(assassin, x, y)
	local force_list = assassin:military_force_list();
	local closest_distance = 0;
	
	for i = 0, force_list:num_items() - 1 do
		local force = force_list:item_at(i);
		
		if force:has_general() == true and force:is_armed_citizenry() == false then
			local force_x = force:general_character():logical_position_x();
			local force_y = force:general_character():logical_position_y();
			
			local distance = distance_squared(x, y, force_x, force_y);
			
			if closest_distance == 0 then
				closest_distance = distance;
			elseif distance < closest_distance then
				closest_distance = distance;
			end
		end
	end
	
	return closest_distance;
end

function assassination_target_is_excluded(character)
	if assassination_targets_first_turn_exclusions.subtypes[character:character_subtype_key()] == true then
		return true;
	end
	if assassination_targets_first_turn_exclusions.named[character:faction()] ~= nil then
		if assassination_targets_first_turn_exclusions.named[character:faction()][character:get_forename()] == true then
			return true;
		end
	end
	return false;
end

function assassination_mission_completed(context, completed)
	if context:mission():mission_record_key():starts_with("wh2_dlc10_alith_anar_assassination") == true then
		out("wh2_dlc10_alith_anar_assassination mission complete");
		assassination_targets.targets_killed = assassination_targets.targets_killed + 1;
		
		if completed == true then
			assassination_targets.targets_complete = (assassination_targets.targets_complete or 0) + 1;
			core:trigger_event("ScriptEventAssassinationFirstTargetKilled");
		
			if assassination_targets.targets_complete == 3 then
				core:trigger_event("ScriptEventAssassinationAllTargetsKilled");
			end
			
			if assassination_new_targets_upon_completion == true and assassination_targets.targets_killed == 3 then
				assassination_targets.force_new_targets = true;
				out("assassination_targets.force_new_targets = true");
			end
		end
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("assassination_targets", assassination_targets, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		assassination_targets = cm:load_named_value("assassination_targets", assassination_targets, context);
	end
);