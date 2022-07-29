
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	THE GREAT SCRIPT OF GRUDGES
--	This script delivers Grudge missions when playing as the Dwarfs
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- the factions that should use the grudges script
-- add a key here and the script will pick them up automatically
playable_dwarf_factions = {
	"wh_main_dwf_dwarfs",
	"wh_main_dwf_karak_izor",
	"wh_main_dwf_karak_kadrin",
	"wh2_dlc17_dwf_thorek_ironbrow"
};

human_dwarf_factions = {};

-- set up strings to keep track of active "defeat army" and "assassinate character" missions, using their CQI and faction strings
-- we use two lists - one for each player if the game is an MPC
grudges_list = {
	{["faction"] = "", ["cqi_list"] = {}, ["faction_list"] = {}},
	{["faction"] = "", ["cqi_list"] = {}, ["faction_list"] = {}}
};


starting_grudges_to_faction_leaders = {
	["main_warhammer"] = {
		["names_name_2147343883"] = { -- thorgrim
			"wh2_dlc17_grudge_legendary_enemy_grimgor",
			"wh2_dlc17_grudge_legendary_enemy_snikch",
			"wh2_dlc17_grudge_legendary_settlement_black_crag",
			"wh2_dlc17_grudge_legendary_settlement_karak_azgal",
		},
		["names_name_2147344414"] = { --- ungrim
			"wh2_dlc17_grudge_legendary_enemy_throt",
			"wh2_dlc17_grudge_legendary_settlement_karak_ungor",
			"wh2_dlc17_grudge_legendary_settlement_silver_pinnacle",
			"wh2_dlc17_grudge_legendary_settlement_karak_vlag",
		},
		["names_name_2147358029"] = { --- belegar
			"wh_dlc06_grudge_belegar_eight_peaks",
			"wh_main_grudge_the_dragonback_grudge",
			"wh2_dlc17_grudge_legendary_enemy_skarsnik",
			"wh2_dlc17_grudge_legendary_enemy_queek",
		},
		["names_name_2147358917"] = { --- grombrindal
			"wh2_dlc17_grudge_legendary_settlement_mount_gunbad",
			"wh2_dlc17_grudge_legendary_settlement_mount_silverspear",
			"wh2_dlc17_grudge_legendary_enemy_high_elves",
			"wh2_dlc17_grudge_legendary_enemy_dark_elves",
		},
		["names_name_1460348616"] = { --- thorek -- ME
			"wh2_dlc17_main_grudge_legendary_artefact_beard_rings_of_grimnir",
			"wh2_dlc17_main_grudge_legendary_artefact_blessed_pick_of_grungni",
			"wh2_dlc17_main_grudge_legendary_artefact_keepsake_of_gazuls_favoured",
			"wh2_dlc17_main_grudge_legendary_artefact_lost_gifts_of_valaya",
			"wh2_dlc17_main_grudge_legendary_artefact_morgrims_gears_of_war",
			"wh2_dlc17_main_grudge_legendary_artefact_ratons_collar_of_bestial_control",
			"wh2_dlc17_main_grudge_legendary_artefact_smednirs_metallurgy_cipher",
			"wh2_dlc17_main_grudge_legendary_artefact_thungnis_tongs_of_the_runesmith",
		},
	},
	["wh2_main_great_vortex"] = {
		["names_name_1460348616"] = { --- thorek -- VORTEX
		--"wh2_dlc17_vortex_grudge_legendary_artefact_beard_rings_of_grimnir",	-- final battle rewards
		"wh2_dlc17_vortex_grudge_legendary_artefact_blessed_pick_of_grungni",
		"wh2_dlc17_vortex_grudge_legendary_artefact_keepsake_of_gazuls_favoured",
		"wh2_dlc17_vortex_grudge_legendary_artefact_lost_gifts_of_valaya",
		"wh2_dlc17_vortex_grudge_legendary_artefact_morgrims_gears_of_war",
		"wh2_dlc17_vortex_grudge_legendary_artefact_ratons_collar_of_bestial_control",
		"wh2_dlc17_vortex_grudge_legendary_artefact_smednirs_metallurgy_cipher",
		"wh2_dlc17_vortex_grudge_legendary_artefact_thungnis_tongs_of_the_runesmith",
		}
	}
}


local pooled_resource_payload = "faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_forging_grudges;amount 30;}";

function attempt_to_load_grudges_script()
	for i = 1, #playable_dwarf_factions do
		local current_faction = cm:get_faction(playable_dwarf_factions[i])
		
		if current_faction and current_faction:is_human() then
			-- build a table of all human Dwarf factions
			table.insert(human_dwarf_factions, current_faction:name());
		end;
	end;
	
	-- if there is a human Dwarf faction, load the script
	if #human_dwarf_factions > 0 then
		grudges_setup();
	end;
end;

function grudges_setup()
	out.grudges("grudges_setup() loaded");
	
	-- get the human faction names to track their active grudges
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		grudges_list[i].faction = human_factions[i];
	end;
	
	if cm:is_new_game() then
		for i = 1, #human_dwarf_factions do
			local current_faction_key = human_dwarf_factions[i]
			local current_faction = cm:get_faction(current_faction_key)

			local grudges_table = starting_grudges_to_faction_leaders[cm:get_campaign_name()]
			
			if current_faction:is_human() then
				---load starting grudges
				for faction_leader, missions in pairs(grudges_table) do
					if cm:general_with_forename_exists_in_faction_with_force(current_faction_key, faction_leader) then
						for j = 1, #missions do
							cm:trigger_mission(current_faction_key, missions[j], true)
						end
					end
				end

				-- monitor for the Dwarfs faction losing any regions that they own
				cm:start_faction_region_change_monitor(human_dwarf_factions[i]);
			end;
		end;
	end;
	
	-- listen for the result of the player's land battle
	for i = 1, #human_dwarf_factions do
		local current_faction_name = human_dwarf_factions[i]
		
		core:add_listener(
			"land_battle_result" .. i,
			"BattleCompleted",
			function()
				return not cm:model():pending_battle():seige_battle() and cm:pending_battle_cache_faction_is_involved(current_faction_name);
			end,
			function()
				local pb = cm:model():pending_battle();
				
				if (cm:pending_battle_cache_faction_is_attacker(current_faction_name) and	pb:has_defender() and pb:defender():won_battle())
				or (cm:pending_battle_cache_faction_is_defender(current_faction_name) and	pb:has_attacker() and pb:attacker():won_battle())
				then
					lost_battle_grudge(cm:model():pending_battle(), current_faction_name);
				else
					remove_cqi(cm:model():pending_battle(), current_faction_name);
				end;
			end,
			true
		);
	end;
	
	-- listen for the player losing a region (will not work on turn 1)
	core:add_listener(
		"lost_region",
		"ScriptEventFactionLostRegion",
		true,
		function(context)
			lost_region_grudge(context:region(), context:faction():name());
		end,
		true
	);
	
	-- listen for the player being raided (stance)
	core:add_listener(
		"region_raided",
		"ForceAdoptsStance",
		function(context)
			-- check to see if the player is being raided by a human waaagh faction (this can happen in MPC)
			local mf = context:military_force();
			local faction = mf:faction();
			local faction_name = faction:name();

			
			
			if string.find(faction_name, "_waaagh") then
				-- get the waaagh's parent faction
				local greenskins_faction_name = string.gsub(faction_name, "_waaagh", "");
				local greenskins_faction = cm:get_faction(greenskins_faction_name);
				
				if greenskins_faction:is_human() then
					return false;
				end;
			end;

			--- don't trigger if faction has no regions to raid in return
			if wh_faction_is_horde(faction) then return end
			
			local human_dwarf_region_was_target = false;
			
			for i = 1, #human_dwarf_factions do
				local current_faction_name = human_dwarf_factions[i];
				local current_faction = cm:get_faction(current_faction_name);
				
				local general = mf:general_character();
				local raiding_faction = mf:faction();
				
				if general:has_region() and general:region():owning_faction():name() == current_faction_name and faction_name ~= current_faction_name and not raiding_faction:allied_with(current_faction) and raiding_faction:at_war_with(current_faction) then
					human_dwarf_region_was_target = true;
				end;
			end;
			
			local stance = context:stance_adopted();
			
			return (stance == 3 or stance == 14) and human_dwarf_region_was_target;
		end,
		function(context)
			local mf = context:military_force();
			
			if mf:is_null_interface() == false then
				local mf_cqi = mf:command_queue_index();
				raiding_grudge(mf_cqi, mf:general_character():region():owning_faction():name());
			end
		end,
		true
	);
	
	-- listen for one of the player's settlements being sacked
	core:add_listener(
		"settlement_sacked",
		"CharacterSackedSettlement",
		function(context)
			local human_dwarf_settlement_was_target = false;
			
			for i = 1, #human_dwarf_factions do
				if context:garrison_residence():faction():name() == human_dwarf_factions[i] then
					human_dwarf_settlement_was_target = true;
				end;
			end;
			
			return human_dwarf_settlement_was_target;
		end,
		function(context)
			sacked_settlement_grudge(context:character(), context:garrison_residence():faction():name());
		end,
		true
	);
	
	-- listen for a player rebellion
	core:add_listener(
		"region_rebellion",
		"RegionRebels",
		function(context)
			local human_dwarf_region_was_target = false;
			local region = context:region();
			local owning_faction_name = region:owning_faction():name();
			
			for i = 1, #human_dwarf_factions do
				if owning_faction_name == human_dwarf_factions[i] then
					human_dwarf_region_was_target = true;
				end;
			end;
			
			return human_dwarf_region_was_target and region:religion_proportion("wh_main_religion_chaos") < 0.3 and region:religion_proportion("wh_main_religion_undeath") < 0.3;
		end,
		function(context)
			local region = context:region();
			
			end_rebellion_grudge(region:name(), region:owning_faction():name());
		end,
		true
	);
end;

function lost_region_grudge(region, faction_name)
	local region_name = region:name();
	
	out.grudges("lost_region_grudge() called for " .. faction_name .. ", with a region name of " .. region_name);
	
	local culture = region:owning_faction():culture();
	
	local mission_str = get_grudge_mission_string("wh_main_grudge_recapture_settlement_", culture, cm:random_number(2));
	
	if not mission_str then return end;
	
	local lost_region_grudge_mission = mission_manager:new(
		faction_name,
		mission_str
	);
	
	lost_region_grudge_mission:add_new_objective("CAPTURE_REGIONS");
	lost_region_grudge_mission:add_condition("region " .. region_name);
	lost_region_grudge_mission:add_payload(generate_payload(nil, faction_name));
	lost_region_grudge_mission:add_payload(pooled_resource_payload);
	lost_region_grudge_mission:set_should_cancel_before_issuing(false);
	
	lost_region_grudge_mission:trigger();
end;

function lost_battle_grudge(pb, faction_name)
	-- determine the cqi of the enemy attacker/defender here as we can't pass the pending battle object forward
	local cqi = 0;
	local culture = "";
	
	if pb:has_attacker() and pb:attacker():won_battle() and pb:attacker():has_military_force() and not pb:attacker():faction():is_quest_battle_faction() then
		if pb:attacker():faction():name() == faction_name then
			out.grudges("Tried to issue an ENGAGE_FORCE mission against the player - did the CQI change during AI turns?");
			return;
		end;
		
		cqi = pb:attacker():military_force():command_queue_index();
		culture = pb:attacker():faction():culture();
	elseif pb:has_defender() and pb:defender():has_military_force() and not pb:defender():faction():is_quest_battle_faction() then
		if pb:defender():faction():name() == faction_name then
			out.grudges("Tried to issue an ENGAGE_FORCE mission against the player - did the CQI change during AI turns?");
			return;
		end;
		
		cqi = pb:defender():military_force():command_queue_index();
		culture = pb:defender():faction():culture();
	else
		out.grudges("Tried to issue an ENGAGE_FORCE mission, but the CQI of the winning force could not be found!");
		return;
	end;
	
	if cm:model():world():whose_turn_is_it():name() == faction_name then
		issue_lost_battle_grudge(cqi, culture, faction_name);
	else
		core:add_listener(
			"player_turn",
			"FactionTurnStart",
			function(context)
				return context:faction():name() == faction_name;
			end,
			function()
				issue_lost_battle_grudge(cqi, culture, faction_name);
			end,
			false
		);
	end;
end;

function issue_lost_battle_grudge(cqi, culture, faction_name)
	local cqi = tostring(cqi);
	
	if cqi == "0" then
		out.grudges("Tried to issue an ENGAGE_FORCE mission for " .. faction_name .. ", but the CQI could not be found - has the force died?");
		return;
	end;
	
	for i = 1, #grudges_list do
		if grudges_list[i].faction == faction_name then
			for j = 1, #grudges_list[i].cqi_list do
				if grudges_list[i].cqi_list[j] == cqi then
					out.grudges("Tried to issue an ENGAGE_FORCE mission for " .. faction_name .. ", but the CQI of the winning force already has an active mission!");
					return;
				end;
			end;
		end;
	end;
	
	local mission_str = get_grudge_mission_string("wh_main_grudge_defeat_army_", culture);
	
	if not mission_str then return end;
	
	for i = 1, #grudges_list do
		if grudges_list[i].faction == faction_name then
			out.grudges("Adding CQI " .. cqi .. " to " .. faction_name .. "'s CQI list");
			table.insert(grudges_list[i].cqi_list, cqi);
		end;
	end;
	
	out.grudges("lost_battle_grudge() called for " .. faction_name .. ", with a CQI of " .. cqi .. " with culture " .. culture);
	
	local lost_battle_grudge_mission = mission_manager:new(
		faction_name,
		mission_str
	);

	lost_battle_grudge_mission:add_new_objective("ENGAGE_FORCE");
	lost_battle_grudge_mission:add_condition("cqi " .. cqi);
	lost_battle_grudge_mission:add_condition("requires_victory");
	lost_battle_grudge_mission:add_payload(generate_payload("army", faction_name, culture));
	lost_battle_grudge_mission:add_payload(pooled_resource_payload);
	lost_battle_grudge_mission:set_should_cancel_before_issuing(false);
	
	lost_battle_grudge_mission:trigger();
end;

function sacked_settlement_grudge(char, faction_name)	
	local cqi = char:cqi();
	local faction = char:faction();
	local culture = faction:culture();
	
	local mission_str = get_grudge_mission_string("wh_main_grudge_defeat_sacking_army_", culture);
	
	if not mission_str then return end;
	
	core:add_listener(
		"player_turn",
		"FactionTurnStart",
		function(context)
			return context:faction():name() == faction_name;
		end,
		function()
			local char_on_player_turn = cm:get_character_by_cqi(cqi);
			
			if not char_on_player_turn then
				out.grudges("Tried to issue an ENGAGE_FORCE mission for " .. faction_name .. ", but the CQI of the character could not be found - did they die during the AI turns?");
				return;
			end;
			
			if not char_on_player_turn:has_military_force() then
				out.grudges("Tried to issue an ENGAGE_FORCE mission for " .. faction_name .. ", but the sacking character does not have a military force!");
				return;
			end;
			
			local mf_cqi = tostring(char_on_player_turn:military_force():command_queue_index());
			
			for i = 1, #grudges_list do
				if grudges_list[i].faction == faction_name then
					for j = 1, #grudges_list[i].cqi_list do
						if grudges_list[i].cqi_list[j] == mf_cqi then
							out.grudges("Tried to issue an ENGAGE_FORCE mission for " .. faction_name .. ", but the CQI of the sacking character already has an active mission!");
							return;
						end;
					end;
				end;
			end;
			
			for i = 1, #grudges_list do
				if grudges_list[i].faction == faction_name then
					out.grudges("Adding CQI " .. mf_cqi .. " to " .. faction_name .. "'s CQI list");
					table.insert(grudges_list[i].cqi_list, mf_cqi);
				end;
			end;
			
			out.grudges("sacked_settlement_grudge() called for " .. faction_name .. ", with a CQI of " .. mf_cqi);
			
			local sacked_settlement_grudge_mission = mission_manager:new(
				faction_name,
				mission_str
			);
			
			sacked_settlement_grudge_mission:add_new_objective("ENGAGE_FORCE");
			sacked_settlement_grudge_mission:add_condition("cqi " .. mf_cqi);
			sacked_settlement_grudge_mission:add_condition("requires_victory");
			sacked_settlement_grudge_mission:add_payload(generate_payload("army", faction_name, culture));
			sacked_settlement_grudge_mission:add_payload(pooled_resource_payload);
			sacked_settlement_grudge_mission:set_should_cancel_before_issuing(false);
			
			sacked_settlement_grudge_mission:trigger();
		end,
		false
	);
end;

function end_rebellion_grudge(region_name, faction_name)
	out.grudges("end_rebellion_grudge() called for " .. faction_name .. ", with a region name of " .. region_name);
	
	local end_rebellion_grudge_mission = mission_manager:new(
		faction_name,
		"wh_main_grudge_end_rebellion"
	);
	
	end_rebellion_grudge_mission:add_new_objective("END_REBELLION");
	end_rebellion_grudge_mission:add_condition("region " .. region_name);
	end_rebellion_grudge_mission:add_payload(generate_payload(nil, faction_name));
	end_rebellion_grudge_mission:add_payload(pooled_resource_payload);
	end_rebellion_grudge_mission:set_should_cancel_before_issuing(false);
	
	end_rebellion_grudge_mission:trigger();
end;

function raiding_grudge(mf_cqi, faction_name)
	core:add_listener(
		"player_turn",
		"FactionTurnStart",
		function(context)
			return context:faction():name() == faction_name;
		end,
		function()
			local cqi = tostring(mf_cqi);
			local mf = cm:model():military_force_for_command_queue_index(mf_cqi);


			if cqi == "0" then
				out.grudges("Tried to issue an RAID_SUB_CULTURE mission for " .. faction_name .. ", but the CQI could not be found - has the force died?");
				return;
			elseif mf:faction():name() == faction_name then
				script_error("Raiding grudge: tried to issue an RAID_SUB_CULTURE mission for " .. faction_name .. ", but the military force's faction matches the player's faction - how?");
				return;

			end;

			local raiding_faction =  mf:general_character():faction():name()
			local culture = mf:general_character():faction():culture();
			local subculture = mf:general_character():faction():subculture()
			
			for i = 1, #grudges_list do
				if grudges_list[i].faction == faction_name then
					for j = 1, #grudges_list[i].faction_list do
						if grudges_list[i].faction_list[j] == raiding_faction then
							out.grudges("Tried to issue an RAID_SUB_CULTURE mission for " .. faction_name .. ", but the faction of the raiding force already has an active mission!");
							return;
						end;
					end;
				end;
			end;
			
			
			local mission_str = get_grudge_mission_string("wh_main_grudge_defeat_raiding_army_", culture);
			
			if not mission_str then return end;
			
			for i = 1, #grudges_list do
				if grudges_list[i].faction == faction_name then
					out.grudges("Adding faction " .. raiding_faction .. " to " .. faction_name .. "'s faction list");
					table.insert(grudges_list[i].faction_list, raiding_faction);
				end;
			end;
			
			out.grudges("raiding_grudge() called for " .. faction_name .. ", with a CQI of " .. cqi .. " with culture " .. culture);
			
			local raiding_grudge_mission = mission_manager:new(
				faction_name,
				mission_str
			);			
			
			raiding_grudge_mission:add_new_objective("RAID_SUB_CULTURE");
			raiding_grudge_mission:add_condition("subculture "..subculture);
			raiding_grudge_mission:add_payload(generate_payload("army", faction_name, culture));
			raiding_grudge_mission:add_payload(pooled_resource_payload);
			raiding_grudge_mission:set_should_cancel_before_issuing(false);
			
			raiding_grudge_mission:trigger();
		end,
		false
	);
end;

-- generate a random payload for the grudge
function generate_payload(mis_type, faction_name, culture)
	local payloads = {
		"money 500",
		"money 750",
		"money 1000",
	}
	
	local effect_bundles_army = {
		"effect_bundle{bundle_key wh_main_payload_call_to_arms_army;turns 5;}",
		"effect_bundle{bundle_key wh_main_payload_morale_army;turns 5;}"
	};
	
	local effect_bundles_agents = {};
	
	if culture == "wh_main_emp_empire" or culture == "wh_main_brt_bretonnia" then
		table.insert(payloads, "effect_bundle{bundle_key wh_main_payload_morale_versus_empire;turns 5;}");
	elseif culture == "wh_main_dwf_dwarfs" then
		table.insert(payloads, "effect_bundle{bundle_key wh_main_payload_morale_versus_dwarfs;turns 5;}");
	elseif culture == "wh_main_grn_greenskins" then
		table.insert(payloads, "effect_bundle{bundle_key wh_main_payload_morale_versus_greenskins;turns 5;}");
	elseif culture == "wh_main_vmp_vampire_counts" then
		table.insert(payloads, "effect_bundle{bundle_key wh_main_payload_morale_versus_vampires;turns 5;}");
	elseif culture == "wh_main_chs_chaos" then
		table.insert(payloads, "effect_bundle{bundle_key wh_main_payload_morale_versus_chaos;turns 5;}");
	elseif culture == "wh_dlc03_bst_beastmen" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_beastmen;turns 5;}");
	elseif culture == "wh_dlc05_wef_wood_elves" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_wood_elves;turns 5;}");
	elseif culture == "wh2_main_hef_high_elves" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_high_elves;turns 5;}");
	elseif culture == "wh2_main_def_dark_elves" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_dark_elves;turns 5;}");
	elseif culture == "wh2_main_lzd_lizardmen" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_lizardmen;turns 5;}");
	elseif culture == "wh2_main_skv_skaven" then
		table.insert(payloads, "effect_bundle{bundle_key wh2_main_payload_morale_versus_skaven;turns 5;}");
	end;
	
	if mis_type == "army" then
		for i = 1, #effect_bundles_army do
			table.insert(payloads, effect_bundles_army[i]);
		end;
	elseif mis_type == "agent" then
		-- only select effect bundles related to agents that the player can actually recruit
		local faction = cm:get_faction(faction_name);
		local region_list = faction:region_list();
		local can_recruit_champion = false;
		local can_recruit_engineer = false;
		local can_recruit_runesmith = false;
		
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			
			if current_region:can_recruit_agent_at_settlement("champion") then can_recruit_champion = true end;
			if current_region:can_recruit_agent_at_settlement("engineer") then can_recruit_engineer = true end;
			if current_region:can_recruit_agent_at_settlement("runesmith") then can_recruit_runesmith = true end;
		end;
		
		if can_recruit_champion then table.insert(effect_bundles_agents, "effect_bundle{bundle_key wh_main_payload_improved_agent_dwf_thane;turns 5;}") end;
		if can_recruit_engineer then table.insert(effect_bundles_agents, "effect_bundle{bundle_key wh_main_payload_improved_agent_dwf_engineer;turns 5;}") end;
		if can_recruit_runesmith then table.insert(effect_bundles_agents, "effect_bundle{bundle_key wh_main_payload_improved_agent_dwf_runesmith;turns 5;}") end;
		
		for i = 1, #effect_bundles_agents do
			table.insert(payloads, effect_bundles_agents[i]);
		end;
	end;
	
	local roll = cm:random_number(#payloads);
	local chosen_payload = payloads[roll];
	
	out.grudges("Generated the following payload: " .. chosen_payload);
	return chosen_payload;
end;


-- removes a CQI from the table when the force has been defeated (assume the mission has been completed)
function remove_cqi(pb, faction_name)
	local cqi = 0;
	
	-- get the losing force's CQI
	if pb:has_attacker() and not pb:attacker():won_battle() and pb:attacker():has_military_force() then
		cqi = pb:attacker():military_force():command_queue_index();
	elseif pb:has_defender() and pb:defender():has_military_force() then
		cqi = pb:defender():military_force():command_queue_index();
	else
		out.grudges("Tried to remove a CQI from the CQI tracker, but the CQI of the losing force could not be found!")
		return
	end;
	
	cqi = tostring(cqi);
	out.grudges("remove_cqi() called for " .. faction_name .. ", with a CQI of " .. cqi);
	
	for i = 1, #grudges_list do
		if grudges_list[i].faction == faction_name then
			for j = 1, #grudges_list[i].cqi_list do
				if grudges_list[i].cqi_list[j] == cqi then
					table.remove(grudges_list[i].cqi_list, j);
				end;
			end;
		end;
	end;
end;

-- keep a list of all CQIs that the player has an active grudge against, so we don't issue more than one at a time
cm:add_saving_game_callback(function(context) save_grudges(context) end);
cm:add_loading_game_callback(function(context) load_grudges(context) end);

function save_grudges(context)
	-- save cqi list
	for i = 1, #grudges_list do
		local str = "";
		for j = 1, #grudges_list[i].cqi_list do
			str = str .. grudges_list[i].cqi_list[j] .. ";";
		end;
		
		out.grudges("### save_grudges() called, saving CQI string for player " .. i .. ": " .. str);
		
		cm:save_named_value("grudges_" .. i, str, context);
		
		-- save faction list
		local faction_str = "";
		for j = 1, #grudges_list[i].faction_list do
			faction_str = faction_str .. grudges_list[i].faction_list[j] .. ";";
		end;
		
		out.grudges("### save_grudges() called, saving faction string for player " .. i .. ": " .. faction_str);
		
		cm:save_named_value("grudges_faction_" .. i, faction_str, context);
	end;
	
	-- save a blank value for old save games (pre-Karak)
	cm:save_named_value("grudges", "", context);
end;

function load_grudges(context)
	-- for old save games (pre-Karak)
	-- load cqi list
	local old_str = cm:load_named_value("grudges", "", context);
	
	if old_str and string.len(old_str) > 0 then
		out.grudges("### load_grudges() called, found an old save, CQI string is: " .. old_str);
		
		local ptr = 1;
		
		while true do
			local next_separator = string.find(old_str, ";", ptr);
			
			if not next_separator then
				break;
			end;
			
			local cqi = string.sub(old_str, ptr, next_separator - 1);
			
			out.grudges("\tadding grudge cqi " .. cqi);
			
			-- stick the value in both player lists because can't tell if player is 1 or 2 (but we know there can only be one Dwarf faction if this save value exists!)
			table.insert(grudges_list[1].cqi_list, cqi);
			table.insert(grudges_list[2].cqi_list, cqi);
			
			ptr = next_separator + 1;
		end;
		
		-- load faction list
		local faction_str = cm:load_named_value("grudges_faction", "", context);
		
		out.grudges("### load_grudges() called, found an old save, faction string is: " .. faction_str);
		
		local ptr = 1;
		
		while true do
			local next_separator = string.find(faction_str, ";", ptr);
			
			if not next_separator then
				break;
			end;
			
			local faction = string.sub(faction_str, ptr, next_separator - 1);
			
			out.grudges("\tadding grudge faction " .. faction);
			
			table.insert(grudges_list[1].faction_list, faction);
			table.insert(grudges_list[2].faction_list, faction);
			
			ptr = next_separator + 1;
		end;
	else
		-- for new games (Karak onwards)
		for i = 1, #grudges_list do		
			-- load cqi list
			local str = cm:load_named_value("grudges_" .. i, "", context);
			
			out.grudges("### load_grudges() called, CQI string for player " .. i .. " is: " .. str);
			
			local ptr = 1;
			
			while true do
				local next_separator = string.find(str, ";", ptr);
				
				if not next_separator then
					break;
				end;
				
				local cqi = string.sub(str, ptr, next_separator - 1);
				
				out.grudges("\tadding grudge cqi " .. cqi .. " to player " .. i .. "'s list");
				
				table.insert(grudges_list[i].cqi_list, cqi);
				
				ptr = next_separator + 1;
			end;
			
			-- load faction list
			local faction_str = cm:load_named_value("grudges_faction_" .. i, "", context);
			
			out.grudges("### load_grudges() called, faction string for player " .. i .. " is: " .. faction_str);
			
			local ptr = 1;
			
			while true do
				local next_separator = string.find(faction_str, ";", ptr);
				
				if not next_separator then
					break;
				end;
				
				local faction = string.sub(faction_str, ptr, next_separator - 1);
				
				out.grudges("\tadding grudge faction " .. faction .. " to player " .. i .. "'s list");
				
				table.insert(grudges_list[i].faction_list, faction);
				
				ptr = next_separator + 1;
			end;
		end;
	end;
end;

function get_grudge_mission_string(mission_str, culture, roll)
	if culture:find("wh_dlc03") then
		mission_str = mission_str:gsub("wh_main", "wh_dlc03");
	elseif culture:find("wh_dlc05") then
		mission_str = mission_str:gsub("wh_main", "wh_dlc05");
	elseif culture:find("wh2_main") then
		mission_str = mission_str:gsub("wh_main", "wh2_main");
	elseif culture:find("wh2_dlc09") then
		mission_str = mission_str:gsub("wh_main", "wh2_dlc09");
	elseif culture:find("wh2_dlc11") then
		mission_str = mission_str:gsub("wh_main", "wh2_dlc11");
	end;
	
	if culture == "wh_main_emp_empire" then
		mission_str = mission_str .. "emp";
	elseif culture == "wh_main_grn_greenskins" then
		mission_str = mission_str .. "grn";
		
		if roll then
			mission_str = mission_str .. "_0" .. roll;
		end;
	elseif culture == "wh_main_dwf_dwarfs" then
		mission_str = mission_str .. "dwf";
		
		if roll then
			mission_str = mission_str .. "_0" .. roll;
		end;
	elseif culture == "wh_main_chs_chaos" then
		mission_str = mission_str .. "chs";
	elseif culture == "wh_main_vmp_vampire_counts" then
		mission_str = mission_str .. "vmp";
	elseif culture == "wh_main_brt_bretonnia" then
		mission_str = mission_str .. "brt";
	elseif culture == "wh_dlc03_bst_beastmen" then
		mission_str = mission_str .. "bst";
	elseif culture == "wh_dlc05_wef_wood_elves" then
		mission_str = mission_str .. "wef";
	elseif culture == "wh2_main_hef_high_elves" then
		mission_str = mission_str .. "hef";
	elseif culture == "wh2_main_lzd_lizardmen" then
		mission_str = mission_str .. "lzd";
	elseif culture == "wh2_main_def_dark_elves" then
		mission_str = mission_str .. "def";
	elseif culture == "wh2_main_skv_skaven" then
		mission_str = mission_str .. "skv";
	elseif culture == "wh2_dlc09_tmb_tomb_kings" then
		mission_str = mission_str .. "tmb";
	elseif culture == "wh2_dlc11_cst_vampire_coast" then
		mission_str = mission_str .. "cst";
	else
		return false;
	end;

	
	return mission_str;
end;