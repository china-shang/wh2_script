--variable claim
ikit_faction_cqi = 0;
ikit_faction = "wh2_main_skv_clan_skyre";
ikit_subtype = "wh2_dlc12_skv_ikit_claw";
engineer_subtype = "wh2_main_skv_warlock_engineer";
master_engineer_subtype = "wh2_dlc12_skv_warlock_master";

---key, progress_threshold, progress_reward
workshop_category = {
					"weapon_team", 
					"doom_wheel",
					"doom_flayer"
};

workshop_category_detail = {
					[workshop_category[1]] = {1, {2,4,5,6,7}, {"wh2_dlc12_anc_banner_incendiary_rounds","wh2_dlc12_anc_banner_cape_of_sniper"}},
					[workshop_category[2]] = {2, {2,4,6,7,8}, {"wh2_dlc12_anc_talisman_warp_field_generator","wh2_dlc12_anc_weapon_thing_zapper","wh2_dlc12_anc_enchanted_modulated_doomwheel_assembly_kit","wh2_dlc12_anc_enchanted_item_warp_lightning_battery"}},
					[workshop_category[3]] = {3, {2,4,6,7,8}, {"wh2_dlc12_anc_armour_alloy_shield","wh2_dlc12_anc_weapon_retractable_fistblade","wh2_dlc12_anc_weapon_mechanical_arm","wh2_dlc12_anc_armour_power_armour"}}
};

workshop_category_unit = {
					[workshop_category[1]] = {["5"] = "wh2_dlc12_skv_inf_warpfire_thrower_ror_tech_lab_0", ["6"] = "wh2_dlc12_skv_art_warplock_jezzails_ror_tech_lab_0", ["7"] = "wh2_dlc12_skv_inf_ratling_gun_ror_tech_lab_0"},
					[workshop_category[2]] = {["8"] = "wh2_dlc12_skv_veh_doomwheel_ror_tech_lab_0"},
					[workshop_category[3]] = {["8"] = "wh2_dlc12_skv_veh_doom_flayer_ror_tech_lab_0"}
};

workshop_progression_reward_incident = "wh2_dlc12_incident_skv_progression_reward";

workshop_category_progress = {
					[workshop_category[1]] = 0,
					[workshop_category[2]] = 0,
					[workshop_category[3]] = 0	
};

workshop_category_progress_default = {
					[workshop_category[1]] = 0,
					[workshop_category[2]] = 0,
					[workshop_category[3]] = 0	
};

workshop_upgrade_incidents = {
					"",
					"wh2_dlc12_incident_skv_workshop_upgrade_2",
					"wh2_dlc12_incident_skv_workshop_upgrade_3",
					"wh2_dlc12_incident_skv_workshop_upgrade_4"
};

workshop_nuke_rite_keys = {
					"wh2_dlc12_ikit_workshop_nuke_part_0",
					"wh2_dlc12_ikit_workshop_nuke_part_1",
					"wh2_dlc12_ikit_workshop_nuke_part_2",
					"wh2_dlc12_ikit_workshop_nuke_part_3",
					"wh2_dlc12_ikit_workshop_nuke_part_4",
					"wh2_dlc12_ikit_workshop_nuke_part_5"

};

workshop_rite_details = {
							["wh2_dlc12_ikit_workshop_gatling_part_1"] = {1, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_2"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_0"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_2"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_6"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_9"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_1"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_5"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_6"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_9"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_gatling_part_2"] = {2, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_2"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_1"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_4"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_8"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_0"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_2"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_7"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_gatling_part_0"] = {3, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_1"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_0"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_5"] = {3, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_7"] = {3, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_3"] = {3, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_8"] = {3, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_3"] = {4, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_4"] = {4, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_nuke_part_0"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_1"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_2"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_3"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_4"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_5"] = {0, "", false}
};

workshop_rite_details_check_list = {
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_0", "wh2_dlc12_ikit_workshop_poison_wind_mortar_0", "wh2_dlc12_ikit_workshop_warpgrinder_0",
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_1", "wh2_dlc12_ikit_workshop_poison_wind_mortar_1", "wh2_dlc12_ikit_workshop_warpgrinder_1",
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_2", "wh2_dlc12_ikit_workshop_poison_wind_mortar_2", "wh2_dlc12_ikit_workshop_warpgrinder_2"
}

workshop_rite_details_default = {
							["wh2_dlc12_ikit_workshop_gatling_part_1"] = {1, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_2"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_0"] = {1, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_0"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_2"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_6"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_9"] = {1, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_1"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_5"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_6"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_9"] = {1, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_gatling_part_2"] = {2, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_2"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_1"] = {2, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_1"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_4"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_8"] = {2, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_0"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_2"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_7"] = {2, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_gatling_part_0"] = {3, workshop_category[1], false},
							["wh2_dlc12_ikit_workshop_jezail_part_1"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpfire_part_0"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_globaldier_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_poison_wind_mortar_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_warpgrinder_2"] = {3, workshop_category[1], false}, 
							["wh2_dlc12_ikit_workshop_doomwheel_part_5"] = {3, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_7"] = {3, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_3"] = {3, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_8"] = {3, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_doomwheel_part_3"] = {4, workshop_category[2], false},
							["wh2_dlc12_ikit_workshop_doomflayer_part_4"] = {4, workshop_category[3], false},
							["wh2_dlc12_ikit_workshop_nuke_part_0"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_1"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_2"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_3"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_4"] = {0, "", false},
							["wh2_dlc12_ikit_workshop_nuke_part_5"] = {0, "", false}
};

workshop_rite_keys = {
						{	"wh2_dlc12_ikit_workshop_gatling_part_1", 
							"wh2_dlc12_ikit_workshop_jezail_part_0",  
							"wh2_dlc12_ikit_workshop_warpfire_part_2", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_0", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_2", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_6", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_9", 
							"wh2_dlc12_ikit_workshop_doomflayer_part_1", 
							"wh2_dlc12_ikit_workshop_doomflayer_part_5", 
							"wh2_dlc12_ikit_workshop_doomflayer_part_6",
							"wh2_dlc12_ikit_workshop_doomflayer_part_9",
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_0",
							"wh2_dlc12_ikit_workshop_poison_wind_mortar_0",
							"wh2_dlc12_ikit_workshop_warpgrinder_0"
							},
						{	"wh2_dlc12_ikit_workshop_gatling_part_2",
							"wh2_dlc12_ikit_workshop_jezail_part_2", 
							"wh2_dlc12_ikit_workshop_warpfire_part_1",
							"wh2_dlc12_ikit_workshop_doomwheel_part_1",
							"wh2_dlc12_ikit_workshop_doomwheel_part_4",
							"wh2_dlc12_ikit_workshop_doomwheel_part_8",
							"wh2_dlc12_ikit_workshop_doomflayer_part_0",
							"wh2_dlc12_ikit_workshop_doomflayer_part_2",
							"wh2_dlc12_ikit_workshop_doomflayer_part_7",
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_1",
							"wh2_dlc12_ikit_workshop_poison_wind_mortar_1",
							"wh2_dlc12_ikit_workshop_warpgrinder_1"
							},
						{	"wh2_dlc12_ikit_workshop_gatling_part_0", 
							"wh2_dlc12_ikit_workshop_jezail_part_1", 
							"wh2_dlc12_ikit_workshop_warpfire_part_0", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_5", 
							"wh2_dlc12_ikit_workshop_doomwheel_part_7", 
							"wh2_dlc12_ikit_workshop_doomflayer_part_3",
							"wh2_dlc12_ikit_workshop_doomflayer_part_8",
							"wh2_dlc12_ikit_workshop_poison_wind_globaldier_2",
							"wh2_dlc12_ikit_workshop_poison_wind_mortar_2",
							"wh2_dlc12_ikit_workshop_warpgrinder_2"
							},
						{	"wh2_dlc12_ikit_workshop_doomwheel_part_3", 
							"wh2_dlc12_ikit_workshop_doomflayer_part_4"
							}
};

nuke_resource_key = "skv_nuke";
nuke_rite_key = "wh2_dlc12_ikit_nuke_rite";
nuke_resource_factor_key = {
						["add"] = "wh2_dlc12_resource_factor_workshop_production",
						["negative"] = "wh2_dlc12_resource_factor_battle_consumed"
};
nuke_limit_default = 5;
nuke_limit_improved = 8;
nuke_limit = 5;

additional_nuke_chance = 25; 
nuke_effect_bundle_key = {	"wh2_dlc12_nuke_ability_enable",
							"wh2_dlc12_nuke_ability_upgrade_enable"
};

nuke_ability_key = "wh2_dlc12_army_abilities_warpstorm_doomrocket";
nuke_ability_upgrade_key = "wh2_dlc12_army_abilities_warpstorm_doomrocket_upgraded";

nuke_drop_chance_step = 25;
nuke_drop_chance_current = 0;
nuke_replenish_effect_bundle = "wh2_dlc12_force_temporary_replenish";
nuke_reacotr_cost = 3;

reactor_resource_key = "skv_reactor_core";
reactor_resource_factor_key = {
						["add"] = "wh2_dlc12_resource_factor_loot",
						["add_alt"] = "wh2_dlc12_resource_factor_action",
						["add_mission"] = "wh2_dlc12_resource_factor_workshop_upgrade",
						["negative"] = "wh2_dlc12_resource_factor_workshop"
};
reactor_add_chances = {
						[ikit_subtype] = {40, 1, 0},
						[master_engineer_subtype] = {20, 1, 0},
						[engineer_subtype] = {30, 1, 0},
						["extra_loot"] = {12, 1, 0}
};

reactor_add_chances_default = {
						[ikit_subtype] = {40, 1, 0},
						[master_engineer_subtype] = {20, 1, 0},
						[engineer_subtype] = {30, 1, 0},
						["extra_loot"] = {12, 1, 0}
};

reactor_extra_loot_skill_key = "wh2_dlc12_skill_skv_ikit_unique_2";

workshop_level_dummy_effect_bundle ={	"wh2_dlc12_workshop_level_0_dummy",
										"wh2_dlc12_workshop_level_1_dummy",
										"wh2_dlc12_workshop_level_2_dummy",
										"wh2_dlc12_workshop_level_3_dummy"
};

workshop_level_reactor_core_reward = 5;

workshop_lvl_missions = {
					{"wh2_dlc12_ikit_workshop_tier_1_0", "wh2_dlc12_ikit_workshop_tier_1_1", "wh2_dlc12_ikit_workshop_tier_1_2"},
					{"wh2_dlc12_ikit_workshop_tier_2_0", "wh2_dlc12_ikit_workshop_tier_2_1", "wh2_dlc12_ikit_workshop_tier_2_2"},
					{"wh2_dlc12_ikit_workshop_tier_3_1", "wh2_dlc12_ikit_workshop_tier_3_2"},
					{}
};

workshop_lvl_missions_scripted = {
					"wh2_dlc12_ikit_workshop_tier_1_2",
					"wh2_dlc12_ikit_workshop_tier_2_0",
					"wh2_dlc12_ikit_workshop_tier_2_1",
					"wh2_dlc12_ikit_workshop_tier_3_1"
};

workshop_lvl_incident = {
					nil,
					"wh2_dlc12_incident_skv_workshop_upgrade_2",
					"wh2_dlc12_incident_skv_workshop_upgrade_3",
					"wh2_dlc12_incident_skv_workshop_upgrade_4"
};

workshop_lvl_missions_scripted_listener = {
					["wh2_dlc12_ikit_workshop_tier_1_2"] = false,
					["wh2_dlc12_ikit_workshop_tier_2_0"] = false,
					["wh2_dlc12_ikit_workshop_tier_2_1"] = false,
					["wh2_dlc12_ikit_workshop_tier_3_0"] = false,
					["wh2_dlc12_ikit_workshop_tier_3_1"] = false
};

workshop_lvl_missions_scripted_listener_default = {
					["wh2_dlc12_ikit_workshop_tier_1_2"] = false,
					["wh2_dlc12_ikit_workshop_tier_2_0"] = false,
					["wh2_dlc12_ikit_workshop_tier_2_1"] = false,
					["wh2_dlc12_ikit_workshop_tier_3_0"] = false,
					["wh2_dlc12_ikit_workshop_tier_3_1"] = false
};

workshop_lvl_mission_scripted_prefix = "wh2_dlc12_objective_override_";

workshop_lvl_progress = {
					{false, false, false},
					{false, false, false},
					{false, false},
					{}
 };

workshop_lvl_progress_default = {
					{false, false, false},
					{false, false, false},
					{false, false},
					{}
 };
 
current_workshop_lvl = 1;

current_workshop_lvl_default = 1;

initialized = false;


--initialization
--[[
core:add_listener(
	"faction_turn_start_ikit_initialisation",
	"FactionTurnStart",
	true,
	function(context)
	if initialized == false then
		ikit_faction_cqi = cm:model():world():faction_by_key(ikit_faction);
		issue_missions(current_workshop_lvl);
		initialized = true;
	end,
	true
);
]]

--updated content
function check_and_update_rite_details()
	for i=1, #workshop_rite_details_check_list do
		local rite_key = workshop_rite_details_check_list[i];
		--out(rite_key);
		if workshop_rite_details[rite_key] == nil then
			workshop_rite_details[rite_key] = workshop_rite_details[rite_key];
			--out("fixing table");
		end
	end
	for i=1, current_workshop_lvl do
		unlock_rites(i);
		--out("unlock rites~!")
	end
end

cm:add_faction_turn_start_listener_by_name(
	"faction_turn_start_ikit_initialisation",
	ikit_faction,
	function(context)
		check_and_update_rite_details();
	end,
	true
);


-------mission control-------
--upgrading workshop
core:add_listener(
	"mission_succeeded_ikit_upgrading_workshop",
	"MissionSucceeded",
	true,
	function(context)
		if current_workshop_lvl < #workshop_lvl_missions then
			local mission_key = context:mission():mission_record_key();
			check_workshop_mission(mission_key);
		end
	end,
	true
);


function check_workshop_mission(mission_key)
	local need_checking = false;
	for i =1, #workshop_lvl_missions[current_workshop_lvl] do
		--out(mission_key);
		--out(workshop_lvl_missions[current_workshop_lvl][i]);
		if mission_key == workshop_lvl_missions[current_workshop_lvl][i] then
			--out("found mission key");
			workshop_lvl_progress[current_workshop_lvl][i] = true;
			need_checking = true;
			cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_missions_objectives", "");
			cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_faction_missions_objectives", "") end, 1);
		end
	end
	if check_workshop_upgrade(current_workshop_lvl) then
		core:trigger_event("ScriptEventPlayerWorkshopUpgraded");
		upgrade_workshop(current_workshop_lvl);
	end
end

function check_workshop_upgrade(lvl)
	if lvl <= #workshop_lvl_progress then 
		local checker = true;
		for i=1, #workshop_lvl_progress[lvl] do
			if workshop_lvl_progress[lvl][i] ~= true then
				checker = false; 
			end
		end
		return checker;
	else
	return false;
	end
end

function unlock_rites(lvl) 
	if lvl <= #workshop_rite_keys then
		local ikit_faction_interface = cm:model():world():faction_by_key(ikit_faction);
		for i=1, #workshop_rite_keys[lvl] do
			cm:unlock_ritual(ikit_faction_interface, workshop_rite_keys[lvl][i]);
			--out("unlocking lvl "..lvl);
			--out(workshop_rite_keys[lvl][i]);
		end
	end
end

function upgrade_workshop()
	local local_faction_name = cm:get_local_faction_name(true);
	current_workshop_lvl = current_workshop_lvl+1;
	unlock_rites(current_workshop_lvl);
	cm:callback(function() issue_missions(current_workshop_lvl) end, 0.1);
	--issue_missions(current_workshop_lvl);
	cm:faction_add_pooled_resource(ikit_faction, reactor_resource_key, reactor_resource_factor_key["add_mission"], workshop_level_reactor_core_reward);
	if local_faction_name and local_faction_name == ikit_faction then
		find_uicomponent(core:get_ui_root(), "layout"):InterfaceFunction("ShowPooledResourceAnimation", reactor_resource_key, workshop_level_reactor_core_reward);
	end
	if workshop_upgrade_incidents[current_workshop_lvl]~=nil then
		cm:trigger_incident(ikit_faction, workshop_upgrade_incidents[current_workshop_lvl], true);
	end
end

function issue_missions(current_workshop_lvl)
	for i = 1, #workshop_level_dummy_effect_bundle do
		cm:remove_effect_bundle(workshop_level_dummy_effect_bundle[i], ikit_faction);
	end
	cm:apply_effect_bundle(workshop_level_dummy_effect_bundle[current_workshop_lvl], ikit_faction, -1);
	cm:disable_event_feed_events(true, "", "wh_event_subcategory_faction_missions_objectives", "");
	for i =1, #workshop_lvl_missions[current_workshop_lvl] do
		local checker = false;
		for j=1, #workshop_lvl_missions_scripted do
			if workshop_lvl_missions_scripted[j] == workshop_lvl_missions[current_workshop_lvl][i] then
				checker = true;
				--trigger scripted mission--
				setup_scripted_mission(workshop_lvl_missions[current_workshop_lvl][i]);
				--script_error("WARNING:"..workshop_lvl_missions[current_workshop_lvl][i]);
			end
		end
		if checker == false then
			if cm:model():world():faction_by_key(ikit_faction):is_human() then
				cm:trigger_mission(ikit_faction, workshop_lvl_missions[current_workshop_lvl][i], true);
			end
		end
	end
	cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_faction_missions_objectives", "") end, 1);
end

function setup_scripted_mission(mission_key)
	if cm:model():world():faction_by_key(ikit_faction):is_human() then
	local mm = mission_manager:new(ikit_faction, mission_key);
		mm:add_new_objective("SCRIPTED");
		mm:add_condition("script_key "..mission_key);
		mm:add_condition("override_text mission_text_text_"..workshop_lvl_mission_scripted_prefix..mission_key);

		mm:add_payload("money 1500");
		mm:set_should_whitelist(false);
		mm:trigger();
		
		--add the listener thing
		setup_scripted_mission_listener(mission_key);
		if workshop_lvl_missions_scripted_listener[mission_key] ~= nil then
			workshop_lvl_missions_scripted_listener[mission_key] = true;
		end
	end
end

function reconstruct_scripted_mission()
	for i=1, #workshop_lvl_missions_scripted do
		if workshop_lvl_missions_scripted_listener[workshop_lvl_missions_scripted[i]] == true then
			setup_scripted_mission_listener(workshop_lvl_missions_scripted[i]);
		end
	end
end

function setup_scripted_mission_listener(mission_key)
	--first check if the mission_key is valid
	local key_valid = false;
	--if it is valid, use a case to setup each one
	out("setup scripted mission listener for "..mission_key);
	for i=1, #workshop_lvl_missions_scripted do
		if mission_key == workshop_lvl_missions_scripted[i] then
			key_valid = true;
			if i==1 then
				--this is checked in nuke control session
			elseif i==2 then
				local checker = false;
				--check if there's already one
				local faction = cm:model():world():faction_by_key(ikit_faction);
				local char_list = faction:character_list()
				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);
					if current_char:rank() >= 15 and current_char:character_subtype_key() == engineer_subtype then
						checker = true;
					end;
				end;
				out(tostring(checker));
				if checker == true then
					cm:complete_scripted_mission_objective(mission_key, mission_key, true);
					workshop_lvl_missions_scripted_listener[mission_key] = false;
				else
					--if there's no one than setup a listener
					core:add_listener(
						mission_key,
						"CharacterRankUp", 
						function(context)
									return true;
						end,
						function(context)
							local character = context:character();
							local faction = character:faction();
							local faction_name = faction:name();
								if ikit_faction == faction_name and character:character_subtype_key() == engineer_subtype and character:rank() >=15 then
									cm:complete_scripted_mission_objective(mission_key, mission_key, true);
									workshop_lvl_missions_scripted_listener[mission_key] = false;
									core:remove_listener(mission_key);
								end
						end,
						true
						);
				end
			elseif i==3 then
				local checker = false;
				--check if there's already one
				local faction = cm:model():world():faction_by_key(ikit_faction);
				local char_list = faction:character_list()
				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);
					if current_char:rank() >= 15 and current_char:character_subtype_key() == master_engineer_subtype then
						checker = true;
					end;
				end;
				if checker == true then
					cm:complete_scripted_mission_objective(mission_key, mission_key, true);
					workshop_lvl_missions_scripted_listener[mission_key] = false;
				else
					--if there's no one than setup a listener
					core:add_listener(
						mission_key,
						"CharacterRankUp", 
						function(context)
									return true;
						end,
						function(context)
							local character = context:character();
							local faction = character:faction();
							local faction_name = faction:name();
								if ikit_faction == faction_name and character:character_subtype_key() == master_engineer_subtype and character:rank() >=15 then
									cm:complete_scripted_mission_objective(mission_key, mission_key, true);
									workshop_lvl_missions_scripted_listener[mission_key] = false;
									core:remove_listener(mission_key);
								end
						end,
						true
						);
				end
			elseif i==4 then
				local checker = false;
				--check if there's already one
				local faction = cm:model():world():faction_by_key(ikit_faction);
				local char_list = faction:character_list()
				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);
					if current_char:rank() >= 25 and current_char:character_subtype_key() == ikit_subtype then
						checker = true;
					end;
				end;
				if checker == true then
					cm:complete_scripted_mission_objective(mission_key, mission_key, true);
					workshop_lvl_missions_scripted_listener[mission_key] = false;
				else
					--if there's no one than setup a listener
					core:add_listener(
						mission_key,
						"CharacterRankUp", 
						function(context)
							return true;
						end,
						function(context)
							local character = context:character();
							local faction = character:faction();
							local faction_name = faction:name();
							
							if ikit_faction == faction_name and character:character_subtype_key() == ikit_subtype and character:rank() >=25 then
								cm:complete_scripted_mission_objective(mission_key, mission_key, true);
								workshop_lvl_missions_scripted_listener[mission_key] = false;
								core:remove_listener(mission_key);
							end
						end,
						true
					);
				end
			end
		end
	end
end


-------nuke control-------
--producing nuke
core:add_listener(
	"ritual_started_ikit_producing_nuke",
	"RitualStartedEvent",
	true,
	function(context)
		--local total_count = 0;
		if context:ritual():ritual_key() == nuke_rite_key then
			-- --add one nuke
			cm:faction_add_pooled_resource(ikit_faction, nuke_resource_key, nuke_resource_factor_key["add"], 1);
			if workshop_rite_details[workshop_nuke_rite_keys[5]][3] == true and additional_nuke_chance > cm:random_number(100) then
				cm:faction_add_pooled_resource(ikit_faction, nuke_resource_key, nuke_resource_factor_key["add"], 1);
			end
			updated_nuke_functions_based_on_nuke_resource();
		end
	end,
	true
);

--reducing nuke
core:add_listener(
	"battle_completed_ikit_reducing_nuke",
	"BattleCompleted",
	true,
	function(context)
		--out(nuke_ability_key..cm:model():pending_battle():get_how_many_times_ability_has_been_used_in_battle(ikit_faction_cqi, nuke_ability_key));
		--out(nuke_ability_upgrade_key..cm:model():pending_battle():get_how_many_times_ability_has_been_used_in_battle(ikit_faction_cqi, nuke_ability_upgrade_key));
		if cm:pending_battle_cache_faction_is_involved(ikit_faction) and (cm:model():pending_battle():get_how_many_times_ability_has_been_used_in_battle(ikit_faction_cqi, nuke_ability_key) > 0 or cm:model():pending_battle():get_how_many_times_ability_has_been_used_in_battle(ikit_faction_cqi, nuke_ability_upgrade_key)>0) then
			cm:faction_add_pooled_resource(ikit_faction, nuke_resource_key, nuke_resource_factor_key["negative"], -1);
			out("changing nuke number to:");
			out(cm:model():world():faction_by_key(ikit_faction):pooled_resource(nuke_resource_key):value());
			updated_nuke_functions_based_on_nuke_resource();
			--checking scripted missions
			if workshop_lvl_missions_scripted_listener[workshop_lvl_missions_scripted[1]] == true then
				cm:complete_scripted_mission_objective(workshop_lvl_missions_scripted[1], workshop_lvl_missions_scripted[1], true);
				workshop_lvl_missions_scripted_listener[workshop_lvl_missions_scripted[1]] = false;
			end
			--checking if nuke parts researched, additional reward
			if workshop_rite_details[workshop_nuke_rite_keys[3]][3] == true then
				cm:faction_add_pooled_resource(ikit_faction, reactor_resource_key, reactor_resource_factor_key["add"], 1);
			end
			--checking if nuke parts researched, additional replenish
			if workshop_rite_details[workshop_nuke_rite_keys[4]][3] == true then
					if cm:pending_battle_cache_num_attackers() >= 1 then
						for i = 1, cm:pending_battle_cache_num_attackers() do
							local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
							local character = cm:model():character_for_command_queue_index(this_char_cqi);
							if not character:is_null_interface() and character:faction():name() == ikit_faction then
								cm:apply_effect_bundle_to_characters_force(nuke_replenish_effect_bundle, this_char_cqi, 5, true);
							end
						end
					end
					if cm:pending_battle_cache_num_defenders() >= 1 then
						for i = 1, cm:pending_battle_cache_num_defenders() do
							local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
							local character = cm:model():character_for_command_queue_index(this_char_cqi);
							if (not character:is_null_interface()) and character:faction():name() == ikit_faction then
								cm:apply_effect_bundle_to_characters_force(nuke_replenish_effect_bundle, this_char_cqi, 5, true);
							end
						end
					end
			end
			--intervention for nuke
			if cm:model():world():faction_by_key(ikit_faction):pooled_resource(nuke_resource_key):value() == 0 and cm:model():world():faction_by_key(ikit_faction):pooled_resource(reactor_resource_key):value() > nuke_reacotr_cost then
				core:trigger_event("ScriptEventPlayerNukeReadyToBuy");
			end
		end
	end,
	true
);


--controlling nuke and rite availability
function updated_nuke_functions_based_on_nuke_resource()
	local ikit_faction_interface = cm:model():world():faction_by_key(ikit_faction);
	local nuke_resource          = ikit_faction_interface:pooled_resource(nuke_resource_key);
	local nuke_resource_amount   = nuke_resource:value();

	if nuke_resource_amount == 0 then
		--nuke is 0 and remove effect bundle
		cm:remove_effect_bundle(nuke_effect_bundle_key[1], ikit_faction);
		if workshop_rite_details[workshop_nuke_rite_keys[6]][3] == true then
			cm:remove_effect_bundle(nuke_effect_bundle_key[2], ikit_faction);
		end
	else
		--nuke is higher than 0 and apply effect bundle
		cm:apply_effect_bundle(nuke_effect_bundle_key[1], ikit_faction, 0)
		-- out(workshop_nuke_rite_keys[6]);
		-- out(workshop_rite_details[workshop_nuke_rite_keys[6]]);
		if workshop_rite_details[workshop_nuke_rite_keys[6]][3] == true then
			cm:remove_effect_bundle(nuke_effect_bundle_key[1], ikit_faction);
			cm:apply_effect_bundle(nuke_effect_bundle_key[2], ikit_faction, 0);
		end

		if nuke_resource_amount == nuke_resource:maximum_value() then
			--nuke is max
			--lock rite
			cm:lock_ritual(ikit_faction_interface, nuke_rite_key);
		else 
			cm:unlock_ritual(ikit_faction_interface, nuke_rite_key);
		end
	end
end

--------progress reward---------
core:add_listener(
	"ritual_completed_ikit_progress_reward",
	"RitualCompletedEvent",
	true,
	function(context)
		--check if that's the proper rite
		local faction = context:performing_faction();
		local ritual = context:ritual();
		local ritual_key = ritual:ritual_key();
		if workshop_rite_details[ritual_key] ~= nil then
			workshop_rite_details[ritual_key][3] = true;
			updated_nuke_functions_based_on_nuke_resource();
			if workshop_category_progress[workshop_rite_details[ritual_key][2]] ~= nil then
				workshop_category_progress[workshop_rite_details[ritual_key][2]] = workshop_category_progress[workshop_rite_details[ritual_key][2]]+1;
				local total_count = 0;
				--intervention events--
				for i = 1, #workshop_category do
					 total_count = total_count + workshop_category_progress[workshop_category[i]];
					 out.design("total count = :" .. tostring(total_count));
				end
				if total_count >= 5 then
					core:trigger_event("ScriptEventPlayer5WorkshopUpgrades");
				elseif total_count >= 2 then
					core:trigger_event("ScriptEventPlayer2WorkshopUpgrades");
				end 
				if ritual_key == workshop_nuke_rite_keys[2] then
					--increase stockpile
					nuke_limit = nuke_limit_improved;
				end
				if ritual_key == workshop_nuke_rite_keys[6] then
					updated_nuke_functions_based_on_nuke_resource();
				end
				for i = 1, #workshop_category_detail[workshop_rite_details[ritual_key][2]][2] do
					if workshop_category_progress[workshop_rite_details[ritual_key][2]] == workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i] then
						--dispose the reward based on workshop_category_detail[ritual_key][3][i] --
						if workshop_category_detail[workshop_rite_details[ritual_key][2]][3][i] ~= nil then
							--give ancillary
							cm:add_ancillary_to_faction(faction, workshop_category_detail[workshop_rite_details[ritual_key][2]][3][i], false);
						else
							--give unit
							--workshop_category_unit[workshop_rite_details[ritual_key][2]][tostring(workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i])];
							cm:remove_event_restricted_unit_record_for_faction(workshop_category_unit[workshop_rite_details[ritual_key][2]][tostring(workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i])], ikit_faction);
							out("unlocking unit "..workshop_category_unit[workshop_rite_details[ritual_key][2]][tostring(workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i])]);
							cm:trigger_incident(ikit_faction, workshop_category_unit[workshop_rite_details[ritual_key][2]][tostring(workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i])], true);
							-- for j = 1, #workshop_category_unit[workshop_rite_details[ritual_key][2]] do
								-- cm:remove_event_restricted_unit_record_for_faction(workshop_category_unit[workshop_rite_details[ritual_key][2]][j], ikit_faction);
								-- out("unlocking unit "..workshop_category_unit[workshop_rite_details[ritual_key][2]][j]);
								-- cm:trigger_incident(ikit_faction, workshop_category_unit[workshop_rite_details[ritual_key][2]][j], true);
							-- end
						end
					end
				end
			end
		end
	end,
	true
);


--------reactor core control----------
-----post battle loot-----
core:add_listener(
	"battle_completed_ikit_post_battle_loot",
	"BattleCompleted",
	true,
	function(context)
		local engineers_in_battle = {
									[ikit_subtype] = {},
									[master_engineer_subtype] = {}
									};
		
		if cm:pending_battle_cache_num_attackers() >= 1 then
			for i = 1, cm:pending_battle_cache_num_attackers() do
				local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
				local character = cm:model():character_for_command_queue_index(this_char_cqi);
				if not character:is_null_interface() and character:faction():name() == ikit_faction and character:character_subtype_key() == ikit_subtype and character:won_battle() then
					table.insert(engineers_in_battle[ikit_subtype], this_char_cqi);
				elseif not character:is_null_interface() and character:faction():name() == ikit_faction and character:character_subtype_key() == master_engineer_subtype and character:won_battle() then
					table.insert(engineers_in_battle[master_engineer_subtype], this_char_cqi);
				end
			end
		end
		
		if cm:pending_battle_cache_num_defenders() >= 1 then
			for i = 1, cm:pending_battle_cache_num_defenders() do
				local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
				local character = cm:model():character_for_command_queue_index(this_char_cqi);
				if (not character:is_null_interface()) and character:faction():name() == ikit_faction and character:character_subtype_key() == ikit_subtype and character:won_battle() then
					table.insert(engineers_in_battle[ikit_subtype], this_char_cqi);
				elseif (not character:is_null_interface()) and character:faction():name() == ikit_faction and character:character_subtype_key() == master_engineer_subtype and character:won_battle() then
					table.insert(engineers_in_battle[master_engineer_subtype], this_char_cqi);
				end
			end
		end
		
		-- generate loot tables and check skills and other factors that affects loot chance --
		--local loot_rolls_engineer = {};
		local loot_rolls_ikit = {};
		local loot_rolls_master_engineer = {};
		local loot_rolls_extra = {};
		for i=1, #engineers_in_battle[ikit_subtype] do
			table.insert(loot_rolls_ikit, reactor_add_chances[ikit_subtype]);
			if cm:model():character_for_command_queue_index(engineers_in_battle[ikit_subtype][i]):has_skill(reactor_extra_loot_skill_key) then
				table.insert(loot_rolls_extra, reactor_add_chances["extra_loot"]);
			end
		end
		for i=1, #engineers_in_battle[master_engineer_subtype] do
			table.insert(loot_rolls_master_engineer, reactor_add_chances[master_engineer_subtype]);
		end
		-- process loot ---
		process_reactor_loot_rolls(#loot_rolls_ikit, ikit_subtype);
		process_reactor_loot_rolls(#loot_rolls_master_engineer, master_engineer_subtype);
		process_reactor_loot_rolls(#loot_rolls_extra, "extra_loot");
	end,
	true
);


function process_reactor_loot_rolls(loot_rolls, index)
	local local_faction_name = cm:get_local_faction_name(true);
	for i=1, loot_rolls do
		if reactor_add_chances[index][1] * (reactor_add_chances[index][3]+1)> cm:random_number(100) then
			if index == engineer_subtype then
				cm:faction_add_pooled_resource(ikit_faction, reactor_resource_key, reactor_resource_factor_key["add_alt"], reactor_add_chances[index][2]);
				if local_faction_name and local_faction_name == ikit_faction then
					find_uicomponent(core:get_ui_root(), "layout"):InterfaceFunction("ShowPooledResourceAnimation", reactor_resource_key, reactor_add_chances[index][2]);
				end
			else
				cm:faction_add_pooled_resource(ikit_faction, reactor_resource_key, reactor_resource_factor_key["add"], reactor_add_chances[index][2]);
				if local_faction_name and local_faction_name == ikit_faction then
					find_uicomponent(core:get_ui_root(), "layout"):InterfaceFunction("ShowPooledResourceAnimation", reactor_resource_key, reactor_add_chances[index][2]);
				end
			end
			out("giving core!");
			if local_faction_name and local_faction_name == ikit_faction then
				find_uicomponent(core:get_ui_root(), "cores_icon"):TriggerAnimation("play");
			end
			reactor_add_chances[index][3] = 0; 
		else
			reactor_add_chances[index][3] = reactor_add_chances[index][3] + 1;
			out("not giving core, increase probability");
		end
	end
end

--agent action loot
core:add_listener(
	"character_character_target_action_ikit_agent_action_loot",
	"CharacterCharacterTargetAction",
	true,
	function (context)
		--out(context:target_character():character_subtype_key());
		if context:mission_result_critial_success() or context:mission_result_success() then
			if context:character():character_subtype_key() == engineer_subtype and context:character():faction():name() == ikit_faction and context:target_character():faction():name() ~= ikit_faction then
				process_reactor_loot_rolls(1, engineer_subtype);
			end
		end
	end,
	true
);


core:add_listener(
	"character_garrison_target_action_ikit_agent_action_loot",
	"CharacterGarrisonTargetAction",
	true,
	function(context)
		if context:mission_result_critial_success() or context:mission_result_success() then
			if context:character():character_subtype_key() == engineer_subtype and context:character():faction():name() == ikit_faction then
				process_reactor_loot_rolls(1, engineer_subtype);
			end
		end
	end,
	true
);


--------save/load---------------
function initialize_workshop_listeners()
	ikit_faction_cqi = cm:model():world():faction_by_key(ikit_faction):command_queue_index();
	if cm:model():world():faction_by_key(ikit_faction):is_human() then
		check_and_update_rite_details();
	end
	if initialized == false then
		--ikit_faction_cqi = cm:model():world():faction_by_key(ikit_faction):command_queue_index();
		issue_missions(current_workshop_lvl);
		initialized = true;
		unlock_rites(1);
		--cm:faction_add_pooled_resource(ikit_faction, reactor_resource_key, reactor_resource_factor_key["add"], 5);
		--cm:faction_add_pooled_resource(ikit_faction, nuke_resource_key, nuke_resource_factor_key["add"], 1);
		updated_nuke_functions_based_on_nuke_resource();
		--locking RoR
			for k = 1, #workshop_category do
				for i = 1, #workshop_category_detail[workshop_category[k]][2] do
						if workshop_category_detail[workshop_category[k]][3][i] ~= nil then
							--it's an ancillary, do nothing
						else
							--give unit
							--workshop_category_unit[workshop_rite_details[ritual_key][2]][tostring(workshop_category_detail[workshop_rite_details[ritual_key][2]][2][i])];
							cm:add_event_restricted_unit_record_for_faction(workshop_category_unit[workshop_category[k]][tostring(workshop_category_detail[workshop_category[k]][2][i])], ikit_faction);
							out("locking unit "..workshop_category_unit[workshop_category[k]][tostring(workshop_category_detail[workshop_category[k]][2][i])]);
							-- for j = 1, #workshop_category_unit[workshop_rite_details[ritual_key][2]] do
								-- cm:remove_event_restricted_unit_record_for_faction(workshop_category_unit[workshop_rite_details[ritual_key][2]][j], ikit_faction);
								-- out("unlocking unit "..workshop_category_unit[workshop_rite_details[ritual_key][2]][j]);
								-- cm:trigger_incident(ikit_faction, workshop_category_unit[workshop_rite_details[ritual_key][2]][j], true);
							-- end
						end
				end
			end	
				
		-- for i=1, #workshop_category do
			-- for j=1, #workshop_category_unit[workshop_category[i]] do
				-- --lock units
				-- cm:add_event_restricted_unit_record_for_faction(workshop_category_unit[workshop_category[i]][j], ikit_faction, "workshop_ror_unlock_reason");
				-- --out("locking "..workshop_category_unit[workshop_category[i]][j]);
			-- end
		-- end
	end
	reconstruct_scripted_mission();
end

cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("workshop_lvl_missions_scripted_listener", workshop_lvl_missions_scripted_listener, context);
		cm:save_named_value("workshop_lvl_progress", workshop_lvl_progress, context);
		cm:save_named_value("current_workshop_lvl", current_workshop_lvl, context);
		cm:save_named_value("nuke_limit", nuke_limit, context);
		cm:save_named_value("workshop_category_progress", workshop_category_progress, context);
		cm:save_named_value("initialized", initialized, context);
		cm:save_named_value("nuke_drop_chance_current", nuke_drop_chance_current, context);	
		cm:save_named_value("reactor_add_chances", reactor_add_chances, context);	
		cm:save_named_value("workshop_rite_details", workshop_rite_details, context);	
	end
);

cm:add_loading_game_callback(
	function(context)
		if (not cm:is_new_game()) then
			workshop_lvl_missions_scripted_listener = cm:load_named_value("workshop_lvl_missions_scripted_listener", workshop_lvl_missions_scripted_listener_default, context);
			workshop_lvl_progress = cm:load_named_value("workshop_lvl_progress", workshop_lvl_progress_default, context);
			current_workshop_lvl = cm:load_named_value("current_workshop_lvl", current_workshop_lvl_default, context);
			nuke_limit = cm:load_named_value("nuke_limit", nuke_limit_default, context);
			workshop_category_progress = cm:load_named_value("workshop_category_progress", workshop_category_progress_default, context);
			initialized = cm:load_named_value("initialized", false, context);
			nuke_drop_chance_current = cm:load_named_value("nuke_drop_chance_current", 0, context);
			--reactor_add_chances = cm:load_named_value("reactor_add_chances", reactor_add_chances_default, context);
			workshop_rite_details = cm:load_named_value("workshop_rite_details", workshop_rite_details_default, context);
		end
	end
);
