local death_night_faction = "wh2_main_def_har_ganeth";
local death_night = {};
death_night.max_value = 25;
death_night.value = 20;
death_night.lock_level = 0;
death_night.lock_reasons = {};
death_night.slave_cost = -800;
death_night.slave_cost_increase = 100;
death_night.slave_cost_cap = -2000;
death_night.active = false;
death_night.faction_cqi = 0;
death_night.loot_value = 1000;
death_night.free_slaves = false;
local death_night_vfx = "scripted_effect6";
local blood_voyage_faction = "wh2_dlc10_def_blood_voyage";
local blood_voyage = {};
blood_voyage.active = false;
blood_voyage.loot = 0;
blood_voyage.target = "";
blood_voyage.human = false;
blood_voyage.cooldown = 25;

local ulthuan_target_regions = {
	["main_warhammer"] = {
		-- OUTER
		["wh2_main_eataine_lothern"] = true,
		["wh2_main_caledor_vauls_anvil"] = true,
		["wh2_main_caledor_tor_sethai"] = true,
		["wh2_main_tiranoc_whitepeak"] = true,
		["wh2_main_tiranoc_tor_anroc"] = true,
		["wh2_main_nagarythe_tor_dranil"] = true,
		["wh2_main_nagarythe_tor_anlec"] = true,
		["wh2_main_nagarythe_shrine_of_khaine"] = true,
		["wh2_main_chrace_tor_achare"] = true,
		["wh2_main_chrace_elisia"] = true,
		["wh2_main_cothique_mistnar"] = true,
		["wh2_main_cothique_tor_koruali"] = true,
		["wh2_main_yvresse_tor_yvresse"] = true,
		["wh2_main_yvresse_elessaeli"] = true,
		["wh2_main_yvresse_tralinia"] = true,
		["wh2_main_yvresse_shrine_of_loec"] = true,
		-- INNER
		["wh2_main_eataine_tower_of_lysean"] = true,
		["wh2_main_ellyrion_tor_elyr"] = true,
		["wh2_main_eagle_gate"] = true,
		["wh2_main_ellyrion_whitefire_tor"] = true,
		["wh2_main_griffon_gate"] = true,
		["wh2_main_avelorn_evershale"] = true,
		["wh2_main_unicorn_gate"] = true,
		["wh2_main_phoenix_gate"] = true,
		["wh2_main_avelorn_tor_saroir"] = true,
		["wh2_main_avelorn_gaean_vale"] = true,
		["wh2_main_saphery_tor_finu"] = true,
		["wh2_main_saphery_tower_of_hoeth"] = true,
		["wh2_main_saphery_port_elistor"] = true,
		["wh2_main_eataine_angerrial"] = true,
		["wh2_main_eataine_shrine_of_asuryan"] = true
	},
	["wh2_main_great_vortex"] = {
		-- OUTER
		["wh2_main_vor_straits_of_lothern_lothern"] = true,
		["wh2_main_vor_straits_of_lothern_glittering_tower"] = true,
		["wh2_main_vor_caledor_vauls_anvil"] = true,
		["wh2_main_vor_caledor_caledors_repose"] = true,
		["wh2_main_vor_caledor_tor_sethai"] = true,
		["wh2_main_vor_tiranoc_whitepeak"] = true,
		["wh2_main_vor_tiranoc_tor_anroc"] = true,
		["wh2_main_vor_tiranoc_the_high_vale"] = true,
		["wh2_main_vor_tiranoc_salvation_isle"] = true,
		["wh2_main_vor_nagarythe_tor_dranil"] = true,
		["wh2_main_vor_nagarythe_tor_anlec"] = true,
		["wh2_main_vor_nagarythe_shrine_of_khaine"] = true,
		["wh2_main_vor_chrace_tor_gard"] = true,
		["wh2_main_vor_chrace_tor_achare"] = true,
		["wh2_main_vor_chrace_elisia"] = true,
		["wh2_main_vor_cothique_tor_koruali"] = true,
		["wh2_main_vor_northern_yvresse_sardenath"] = true,
		["wh2_main_vor_northern_yvresse_tor_yvresse"] = true,
		["wh2_main_vor_northern_yvresse_tralinia"] = true,
		["wh2_main_vor_southern_yvresse_elessaeli"] = true,
		["wh2_main_vor_southern_yvresse_shrine_of_loec"] = true,
		["wh2_main_vor_southern_yvresse_cairn_thel"] = true,
		-- INNER
		["wh2_main_vor_straits_of_lothern_tower_of_lysean"] = true,
		["wh2_main_vor_ellyrion_the_arc_span"] = true,
		["wh2_main_vor_eagle_gate"] = true,
		["wh2_main_vor_ellyrion_tor_elyr"] = true,
		["wh2_main_vor_griffon_gate"] = true,
		["wh2_main_vor_ellyrion_reavers_mark"] = true,
		["wh2_main_vor_unicorn_gate"] = true,
		["wh2_main_vor_avelorn_evershale"] = true,
		["wh2_main_vor_phoenix_gate"] = true,
		["wh2_main_vor_avelorn_tor_saroir"] = true,
		["wh2_main_vor_avelorn_gaean_vale"] = true,
		["wh2_main_vor_saphery_tor_finu"] = true,
		["wh2_main_vor_saphery_shadow_peak"] = true,
		["wh2_main_vor_saphery_tower_of_hoeth"] = true,
		["wh2_main_vor_saphery_port_elistor"] = true,
		["wh2_main_vor_eataine_angerrial"] = true,
		["wh2_main_vor_eataine_shrine_of_asuryan"] = true
	}
};

function add_hellebron_listeners()
	out("#### Adding Hellebron Listeners ####");
	local hellebron = cm:model():world():faction_by_key(death_night_faction);
	local alarielle = cm:model():world():faction_by_key("wh2_main_hef_avelorn");
	local blood_voyage_faction_interface = cm:get_faction(blood_voyage_faction);
	
	if hellebron:is_human() == true then
		core:add_listener(
			"death_night_button_pressed",
			"ComponentLClickUp",
			function(context)
				return context.string == "death_night_button";
			end,
			function(context)
				local local_faction = cm:get_local_faction_name(true);
				local faction = cm:model():world():faction_by_key(local_faction);
				death_night_button_pressed(context, faction);
			end,
			true
		);
		core:add_listener(
			"death_night_triggered",
			"UITrigger",
			function(context)
				return context:trigger() == "death_night_event";
			end,
			function(context)
				local faction_cqi = context:faction_cqi();
				death_night_triggered(faction_cqi);
			end,
			true
		);
		cm:add_faction_turn_start_listener_by_name(
			"death_night_turn_start",
			death_night_faction,
			function(context)
				death_night_turn_start()
			end,
			true
		);
		core:add_listener(
			"death_night_mission_succeeded",
			"MissionSucceeded",
			function(context)
				return context:faction():command_queue_index() == death_night.faction_cqi;
			end,
			function(context)
				death_night_mission_succeeded(context);
			end,
			true
		);
		core:add_listener(
			"blood_voyage_battle_completed",
			"CharacterCompletedBattle",
			true,
			function(context)
				death_night_battle_completed(context);
			end,
			true
		);
		
		death_night_initialize();
		death_night_apply_effects(hellebron);
		if blood_voyage_faction_interface ~= false then
			death_night_apply_effects(blood_voyage_faction_interface);
		end
		death_night_update_ui();
	elseif alarielle:is_human() == true then
		cm:add_faction_turn_start_listener_by_name(
			"death_night_turn_start_ai",
			death_night_faction,
			function(context)
				death_night_ai_turn_start()
			end,
			true
		);
	end
	
	death_night_setup_army();
end

function death_night_initialize()
	out.design("DEATH NIGHT: death_night_initialize");
	local faction = cm:model():world():faction_by_key(death_night_faction);
	
	out.design("\tInitialize death_night");
	death_night.max_value = death_night.max_value or 25;
	death_night.value = death_night.value or 20;
	death_night.lock_level = death_night.lock_level or 0;
	death_night.lock_reasons = death_night.lock_reasons or {};
	death_night.slave_cost = death_night.slave_cost or -800;
	death_night.slave_cost_increase = death_night.slave_cost_increase or 100;
	death_night.slave_cost_cap = death_night.slave_cost_cap or -2000;
	if death_night.active == nil then
		death_night.active = false;
	end
	death_night.faction_cqi = faction:command_queue_index();
	death_night.loot_value = death_night.loot_value or 1000;
	if death_night.active == nil then
		death_night.active = false;
	end
	
	out.design("\tInitialize blood_voyage");
	if blood_voyage.active == nil then
		blood_voyage.active = false;
	end
	blood_voyage.loot = blood_voyage.loot or 0;
	blood_voyage.target = blood_voyage.target or "";
	if blood_voyage.human == nil then
		blood_voyage.human = false;
	end
	blood_voyage.cooldown = blood_voyage.cooldown or 25;
end

function death_night_button_pressed(context, faction)
	out.design("DEATH NIGHT: death_night_button_pressed");
	
	if faction:is_null_interface() == false then
		local faction_cqi = faction:command_queue_index();
		out.design("\tSending CQI of "..tostring(faction_cqi).." with event key 'death_night_event'");
		CampaignUI.TriggerCampaignScriptEvent(faction_cqi, "death_night_event"); --calls function death_night_triggered
	end
end

function death_night_triggered(faction_cqi)
	out.design("DEATH NIGHT: death_night_triggered - CQI: "..tostring(faction_cqi));
	
	if cm:model():has_faction_command_queue_index(tonumber(faction_cqi)) == true then
		local faction = cm:model():faction_for_command_queue_index(faction_cqi);
		local slaves_capped = false;
		
		death_night.active = true;
		death_night.faction_cqi = faction_cqi;
		death_night.value = death_night.max_value;
		
		-- Remove the slave cost from the factions slave pool
		cm:modify_faction_slaves_in_a_faction(faction:name(), death_night.slave_cost);
		death_night.slave_cost = death_night.slave_cost - death_night.slave_cost_increase;
		
		if death_night.slave_cost < death_night.slave_cost_cap then
			death_night.slave_cost = death_night.slave_cost_cap;
			slaves_capped = true;
		end
		
		death_night_apply_effects(faction);
		if cm:get_faction(blood_voyage_faction) ~= false then
			death_night_apply_effects(cm:get_faction(blood_voyage_faction));
		end
		
		death_night_update_ui();
		
		death_night_trigger_event(faction, slaves_capped);
		core:trigger_event("ScriptEventDeathNightTriggered");
	end
end

function death_night_trigger_event(faction, slaves_capped)
	local har_ganeth = nil;
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_vor_the_road_of_skulls_har_ganeth");
	else
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_the_road_of_skulls_har_ganeth");
	end
	
	local garrison_residence = har_ganeth:garrison_residence();
	local garrison_residence_cqi = garrison_residence:command_queue_index();
	cm:add_garrison_residence_vfx(garrison_residence_cqi, death_night_vfx, true);
	
	-- Trigger an event for the owner of Death Night
	local death_night_event_key = "wh2_dlc10_incident_def_death_night";
	
	if blood_voyage.active == true then
		death_night_event_key = death_night_event_key.."_no_voyage";
	end
	if slaves_capped == true then
		death_night_event_key = death_night_event_key.."_no_slaves";
	end
	
	cm:trigger_incident(faction:name(), death_night_event_key, true);
	
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction == death_night_faction then
		cm:scroll_camera_from_current(true, 3, {har_ganeth:settlement():display_position_x(), har_ganeth:settlement():display_position_y(), 10.5, 0.0, 6.8});
	end
end

function death_night_turn_start()
	out.design("DEATH NIGHT: death_night_turn_start()");
	out.design("\tdeath_night.value: "..tostring(death_night.value));
	out.design("\tdeath_night.lock_level: "..tostring(death_night.lock_level));
	out.design("\tdeath_night.lock_reasons: "..tostring(#death_night.lock_reasons));
	out.design("\tdeath_night.active: "..tostring(death_night.active));
	out.design("\tdeath_night.faction_cqi: "..tostring(death_night.faction_cqi));
	out.design("\tblood_voyage.active: "..tostring(blood_voyage.active));
	out.design("\tblood_voyage.loot: "..tostring(blood_voyage.loot));
	out.design("\tblood_voyage.target: "..tostring(blood_voyage.target));
	out.design("\tblood_voyage.human: "..tostring(blood_voyage.human));
	
	if cm:model():has_faction_command_queue_index(death_night.faction_cqi) then
		local faction = cm:model():faction_for_command_queue_index(death_night.faction_cqi);
		
		if death_night.active == true then
			death_night.active = false;
			
			if blood_voyage.active == false then
				death_night_blood_voyage();
			else
				out.design("Blood Voyage is already active, not spawning new one!");
			end
		end
		
		if death_night.value > 0 then
			death_night.value = death_night.value - 1;
		end
		
		death_night_apply_effects(faction);
		if cm:get_faction(blood_voyage_faction) ~= false then
			death_night_apply_effects(cm:get_faction(blood_voyage_faction));
		end
		death_night_update_ui();
	
		if blood_voyage.active == true then
			if blood_voyage.human == false then
				local blood_voyage_fac = cm:model():world():faction_by_key(blood_voyage_faction);
				
				out.design("\tStatus: "..tostring(blood_voyage_fac).." / "..tostring(blood_voyage_fac:is_null_interface()).." / "..tostring(blood_voyage_fac:is_dead()));
				if blood_voyage_fac:is_null_interface() == true or blood_voyage_fac:is_dead() == true then
					cm:trigger_custom_incident(death_night_faction, "wh2_dlc10_incident_hef_blood_voyage_ends", true, "payload{money "..blood_voyage.loot..";}");
					core:trigger_event("ScriptEventDeathBloodVoyageDead");
					out.design("++1++ Blood Voyage Active False!");
					blood_voyage.active = false;
					blood_voyage.target = "";
				elseif blood_voyage.target ~= "" then
					local bv_target = cm:model():world():faction_by_key(blood_voyage.target);
					
					if bv_target:is_null_interface() == true or bv_target:is_dead() == true then
						local ulthuan_target, ulthuan_target_faction, human_high_elves = death_night_generate_ulthuan_target();
						
						if ulthuan_target ~= nil then
							cm:force_declare_war(blood_voyage_faction, ulthuan_target_faction, true, true);
						end
					end
				end
			else
				out.design("++2++ Blood Voyage Active False!");
				blood_voyage.active = false;
				blood_voyage.target = "";
			end
		end
	end
	
	local turn_number = cm:model():turn_number();
	
	if turn_number == 2 then
		local mm1 = mission_manager:new(death_night_faction, "wh2_dlc10_death_night_alarielle_mission");
		local mm2 = mission_manager:new(death_night_faction, "wh2_dlc10_death_night_morathi_mission");
		
		mm1:add_new_objective("CAPTURE_REGIONS");
		mm2:add_new_objective("CAPTURE_REGIONS");
		mm1:set_mission_issuer("CLAN_ELDERS");
		mm2:set_mission_issuer("CLAN_ELDERS");
		
		if cm:model():campaign_name("wh2_main_great_vortex") then
			mm1:add_condition("region wh2_main_vor_avelorn_gaean_vale");
			mm2:add_condition("region wh2_main_vor_iron_peaks_ancient_city_of_quintex");
		else
			mm1:add_condition("region wh2_main_avelorn_gaean_vale");
			mm2:add_condition("region wh2_main_titan_peaks_ancient_city_of_quintex");
		end
		
		mm1:add_condition("ignore_allies");
		mm2:add_condition("ignore_allies");
		mm1:add_payload("effect_bundle{bundle_key wh2_dlc10_bundle_death_night_alarielle;turns 0;}");
		mm2:add_payload("effect_bundle{bundle_key wh2_dlc10_bundle_death_night_morathi;turns 0;}");
		mm2:add_payload("effect_bundle{bundle_key wh2_dlc10_bundle_death_night_morathi_untainted;turns 20;}");
		mm1:set_should_whitelist(false);
		mm2:set_should_whitelist(false);
		mm1:trigger();
		mm2:trigger();
	end
end

function death_night_ai_turn_start()
	out.design("DEATH NIGHT: death_night_ai_turn_start()");
	out.design("\tblood_voyage.active: "..tostring(blood_voyage.active));
	out.design("\tblood_voyage.loot: "..tostring(blood_voyage.loot));
	out.design("\tblood_voyage.target: "..tostring(blood_voyage.target));
	out.design("\tblood_voyage.human: "..tostring(blood_voyage.human));
	out.design("\tblood_voyage.cooldown: "..tostring(blood_voyage.cooldown));
	
	local har_ganeth = nil;
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_vor_the_road_of_skulls_har_ganeth");
	else
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_the_road_of_skulls_har_ganeth");
	end
	
	if har_ganeth ~= nil and har_ganeth:is_null_interface() == false and har_ganeth:owning_faction():name() == death_night_faction then
		cm:apply_effect_bundle("wh2_dlc10_death_night_effect_4", blood_voyage_faction, 0);
		if blood_voyage.active == false and blood_voyage.cooldown <= 0 then
			death_night_blood_voyage();
			blood_voyage.cooldown = -1;
		elseif blood_voyage.active == false and blood_voyage.cooldown > 0 then
			blood_voyage.cooldown = blood_voyage.cooldown - 1;
		elseif blood_voyage.active == true then
		
			local blood_voyage_fac = cm:model():world():faction_by_key(blood_voyage_faction);
			out.design("\tStatus: "..tostring(blood_voyage_fac).." / "..tostring(blood_voyage_fac:is_null_interface()).." / "..tostring(blood_voyage_fac:is_dead()));
			
			if blood_voyage_fac:is_null_interface() == true or blood_voyage_fac:is_dead() == true then
				core:trigger_event("ScriptEventDeathBloodVoyageDead");
				out.design("++3++ Blood Voyage Active False!");
				blood_voyage.active = false;
				blood_voyage.target = "";
				blood_voyage.cooldown = 30;
				cm:remove_effect_bundle("wh2_dlc10_bundle_blood_voyage_active", "wh2_main_hef_avelorn");
			elseif blood_voyage.human == false and blood_voyage.target ~= "" then
				local bv_target = cm:model():world():faction_by_key(blood_voyage.target);
				
				if bv_target:is_null_interface() == true or bv_target:is_dead() == true then
					local ulthuan_target, ulthuan_target_faction, human_high_elves = death_night_generate_ulthuan_target();
					
					if ulthuan_target ~= nil then
						cm:force_declare_war(blood_voyage_faction, ulthuan_target_faction, true, true);
					end
				end
			end
		end
	end
end

function death_night_blood_voyage()
	out.design("DEATH NIGHT: death_night_blood_voyage");
	local turn_number = cm:model():turn_number();
	local unit_list = random_army_manager:generate_force("death_night_army_2", 19);
	local spawn_pos = {x = 156, y = 625};
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		spawn_pos = {x = 286, y = 637};
	end
	
	local blood_voyage_inv = nil;
	local ulthuan_target, ulthuan_target_faction, human_high_elves = death_night_generate_ulthuan_target();
	local player_blood_voyage = false;
	local force_player_blood_voyage = false; -- Debug
	local har_ganeth = cm:model():world():faction_by_key(death_night_faction);
	
	if har_ganeth:is_human() == true then
		if cm:is_multiplayer() == false then
			if ulthuan_target ~= nil and force_player_blood_voyage == false then
				-- AI CONTROLLED BLOOD VOYAGE (SP) (Player Hellebron)
				blood_voyage_inv = invasion_manager:new_invasion("blood_voyage_inv_"..turn_number, blood_voyage_faction, unit_list, spawn_pos);
				blood_voyage_inv:set_target("REGION", ulthuan_target, ulthuan_target_faction);
				blood_voyage.target = ulthuan_target_faction;
				blood_voyage.human = false;
			else
				-- PLAYER CONTROLLED BLOOD VOYAGE (SP)
				player_blood_voyage = true;
				unit_list = random_army_manager:generate_force("death_night_army_player", 19);
				blood_voyage_inv = invasion_manager:new_invasion("blood_voyage_inv_"..turn_number, death_night_faction, unit_list, spawn_pos);
				blood_voyage.target = "";
				blood_voyage.human = true;
			end
		else
			-- PLAYER CONTROLLED BLOOD VOYAGE (MP) (Player Hellebron)
			player_blood_voyage = true;
			unit_list = random_army_manager:generate_force("death_night_army_player", 19);
			blood_voyage_inv = invasion_manager:new_invasion("blood_voyage_inv_"..turn_number, death_night_faction, unit_list, spawn_pos);
			blood_voyage.target = "";
			blood_voyage.human = true;
		end
	elseif ulthuan_target ~= nil then
		if turn_number <= 30 then
			unit_list = random_army_manager:generate_force("death_night_army_1", 19);
		end
		
		-- AI CONTROLLED BLOOD VOYAGE (SP & MP) (AI Hellebron)
		blood_voyage_inv = invasion_manager:new_invasion("blood_voyage_inv_"..turn_number, blood_voyage_faction, unit_list, spawn_pos);
		blood_voyage_inv:set_target("REGION", ulthuan_target, ulthuan_target_faction);
		blood_voyage.target = ulthuan_target_faction;
		blood_voyage.human = false;
		
		local difficulty = cm:get_difficulty(true);
		
		if difficulty == "very hard" then
			blood_voyage_inv:add_unit_experience(1);
		elseif difficulty == "legendary" then
			blood_voyage_inv:add_unit_experience(3);
		end
	else
		out.design("\tDidn't spawn Blood Voyage!");
		return;
	end
	
	local hellebron = har_ganeth:faction_leader();
	
	if hellebron and hellebron:is_null_interface() == false and hellebron:has_skill("wh2_dlc10_skill_def_crone_unique_blood_queen") == true then
		blood_voyage_inv:add_unit_experience(3);
	end
	
	if player_blood_voyage == true then
		blood_voyage_inv:apply_effect("wh2_dlc10_bundle_blood_voyage_player", 15);
	else
		blood_voyage_inv:apply_effect("wh2_dlc10_bundle_blood_voyage", 0);
	end
	
	blood_voyage_inv:abort_on_target_owner_change(true);
	blood_voyage_inv:start_invasion(
	function(self)
		local force_leader = self:get_general();
		local local_faction = cm:get_local_faction_name(true);
	
		if local_faction == death_night_faction then
			cm:scroll_camera_from_current(false, 3, {force_leader:display_position_x(), force_leader:display_position_y(), 14.768, 0.0, 12.0});
		end
		
		blood_voyage.active = true;
		blood_voyage.loot = 300 + cm:random_number(600);
		
		cm:force_alliance(death_night_faction, blood_voyage_faction, true);
		cm:add_character_vfx(force_leader:command_queue_index(), death_night_vfx, false);
		
		out.design("DEATH NIGHT: Blood Voyage Invasion Started");
		out.design("\tblood_voyage.active: "..tostring(blood_voyage.active));
		out.design("\tblood_voyage.loot: "..tostring(blood_voyage.loot));
		out.design("\tblood_voyage.target: "..tostring(blood_voyage.target));
		out.design("\tblood_voyage.human: "..tostring(blood_voyage.human));
		out.design("\tblood_voyage.cooldown: "..tostring(blood_voyage.cooldown));
	end,
	true, false, false
	);
	core:trigger_event("ScriptEventDeathBloodVoyage");
	cm:force_diplomacy("all", "faction:"..blood_voyage_faction, "all", false, false, true);
	cm:force_diplomacy("faction:"..death_night_faction, "faction:"..blood_voyage_faction, "join war", true, true, false);
	cm:force_diplomacy("all", "faction:"..blood_voyage_faction, "war", true, true, false);
	cm:force_diplomacy("faction:"..death_night_faction, "faction:"..blood_voyage_faction, "war", false, false, true);
	
	if cm:model():has_faction_command_queue_index(death_night.faction_cqi) then
		local faction = cm:model():faction_for_command_queue_index(death_night.faction_cqi);
		local owner = "_";
		
		if player_blood_voyage == true then
			owner = "_owner_";
		end
		
		cm:show_message_event_located(
			faction:name(),
			"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage"..owner.."title",
			"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage"..owner.."primary_detail",
			"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage"..owner.."secondary_detail",
			spawn_pos.x,
			spawn_pos.y,
			true,
			1011
		);
	end
	
	for elf, value in pairs(human_high_elves) do
		if value then
			blood_voyage_warning_event(elf);
		end
	end
	
	cm:apply_effect_bundle("wh2_dlc10_bundle_blood_voyage_active", "wh2_main_hef_avelorn", 0);

	
	local har_ganeth = nil;
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_vor_the_road_of_skulls_har_ganeth");
	else
		har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_the_road_of_skulls_har_ganeth");
	end
	
	local garrison_residence = har_ganeth:garrison_residence();
	local garrison_residence_cqi = garrison_residence:command_queue_index();
	cm:remove_garrison_residence_vfx(garrison_residence_cqi, death_night_vfx);
end

function death_night_generate_ulthuan_target()
	local possible_targets = {};
	local human_high_elves = {};
	local campaign_key = "main_warhammer";
	
	if cm:model():campaign_name("wh2_main_great_vortex") then
		campaign_key = "wh2_main_great_vortex";
	end
	
	for region_key, value in pairs(ulthuan_target_regions[campaign_key]) do
		local region = cm:model():world():region_manager():region_by_key(region_key);
		
		if region:is_abandoned() == false and region:owning_faction():culture() == "wh2_main_hef_high_elves" then
			table.insert(possible_targets, region);
			
			if region:owning_faction():is_human() == true then
				human_high_elves[region:owning_faction():name()] = true;
			end
		end
	end
	
	if #possible_targets > 0 then
		local har_ganeth = nil;

		if cm:model():campaign_name("wh2_main_great_vortex") then
			har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_vor_the_road_of_skulls_har_ganeth");
		else
			har_ganeth = cm:model():world():region_manager():region_by_key("wh2_main_the_road_of_skulls_har_ganeth");
		end
		
		local hgx = har_ganeth:settlement():logical_position_x();
		local hgy = har_ganeth:settlement():logical_position_y();
		local target = nil;
		local closest = 999999;
		
		for i = 1, #possible_targets do
			local possible_target = possible_targets[i];
			local x = possible_target:settlement():logical_position_x();
			local y = possible_target:settlement():logical_position_y();
			local distance = distance_squared(x, y, hgx, hgy);
			
			if distance <= closest then
				target = possible_target;
				closest = distance;
			end
		end
		
		if target ~= nil then
			return target:name(), target:owning_faction():name(), human_high_elves;
		end
	end

	return nil, nil, human_high_elves;
end

function death_night_battle_completed(context)
	local character = context:character();
	local faction = character:faction();
	
	if faction:name() == blood_voyage_faction and character:won_battle() == true then
		out.design("Blood Voyage: Increasing Loot!");
		blood_voyage.loot = blood_voyage.loot + death_night.loot_value + cm:random_number(death_night.loot_value);
	end
end

function death_night_mission_succeeded(context)
	local mission_key = context:mission():mission_record_key();
	
	if mission_key == "wh2_dlc10_death_night_morathi_mission" then
		death_night.lock_level = death_night.lock_level + 1;
		table.insert(death_night.lock_reasons, "wh2_dlc10_death_night_lock_morathi");
		core:trigger_event("ScriptEventDeathMorathiDefeated");
	elseif mission_key == "wh2_dlc10_death_night_alarielle_mission" then
		death_night.lock_level = death_night.lock_level + 1;
		table.insert(death_night.lock_reasons, "wh2_dlc10_death_night_lock_alarielle");
		core:trigger_event("ScriptEventDeathAlarielleDefeated");
	end
	
	death_night_apply_effects(context:faction());
	if cm:get_faction(blood_voyage_faction) ~= false then
		death_night_apply_effects(cm:get_faction(blood_voyage_faction));
	end
	death_night_update_ui();
end

function death_night_apply_effects(faction)
	out.design("DEATH NIGHT: death_night_apply_effects");
	local bar_effect = "";
	local percent = death_night.value / death_night.max_value;
	local lock_percent = death_night.lock_level * 0.2;
	
	if percent < lock_percent then
		percent = lock_percent;
	end
	
	if percent >= 0.8 then
		bar_effect = "wh2_dlc10_death_night_effect_5";
	elseif percent >= 0.6 then
		bar_effect = "wh2_dlc10_death_night_effect_4";
	elseif percent >= 0.4 then
		bar_effect = "wh2_dlc10_death_night_effect_3";
		core:trigger_event("ScriptEventDeathNightLevel3");
	elseif percent >= 0.2 then
		bar_effect = "wh2_dlc10_death_night_effect_2";
	else
		bar_effect = "wh2_dlc10_death_night_effect_1";
		core:trigger_event("ScriptEventDeathNightLevel1");
		
		if death_night.free_slaves == false then
			cm:trigger_incident(death_night_faction, "wh2_dlc10_death_night_free_slave", true);
			death_night.free_slaves = true;
		end
	end
	
	out.design("\tEffect: "..bar_effect.." ("..tostring(percent)..")");
	
	if faction ~= nil and faction:is_null_interface() == false then
		death_night_remove_effects(faction);
		cm:apply_effect_bundle(bar_effect, faction:name(), 0);
	else
		if cm:model():has_faction_command_queue_index(death_night.faction_cqi) then
			local faction = cm:model():faction_for_command_queue_index(death_night.faction_cqi);
			
			if faction:is_null_interface() == false then
				death_night_remove_effects(faction);
				cm:apply_effect_bundle(bar_effect, faction:name(), 0);
			end
		end
	end
end

function death_night_remove_effects(faction)
	for i = 1, 5 do
		cm:remove_effect_bundle("wh2_dlc10_death_night_effect_"..i, faction:name());
	end
end

function death_night_update_ui()
	local local_faction = cm:get_local_faction_name(true);
	
	if local_faction == death_night_faction then
		out.design("DEATH NIGHT: death_night_update_ui");
		local ui_root = core:get_ui_root();
		local death_night_holder = find_uicomponent(ui_root, "death_night_holder");
		
		if death_night_holder and death_night_holder:Visible() == true then
			local percent = death_night.value / death_night.max_value;
			local lock_percent = death_night.lock_level * 0.2;
			
			if percent < lock_percent then
				percent = lock_percent;
			end
			
			out.design("\tSetBarLevel: "..tostring(percent).." ("..death_night.value..")");
			death_night_holder:InterfaceFunction("SetBarLevel", percent);
			
			out.design("\tSetBarLock: "..tostring(death_night.lock_level));
			if death_night.lock_level > 0 then
				death_night_holder:InterfaceFunction("SetBarLock", death_night.lock_level, unpack(death_night.lock_reasons));
			else
				death_night_holder:InterfaceFunction("SetBarLock", 0);
			end
			
			local death_night_button = find_uicomponent(death_night_holder, "death_night_button");
			
			if death_night_button and death_night_button:Visible() == true then
				out.design("\tSetProperty - slaves_needed: "..tostring(-death_night.slave_cost));
				death_night_button:SetProperty("slaves_needed", tostring(-death_night.slave_cost));
				
				if death_night.active == true then
					-- Death Night was triggered this turn
					out.design("\tSetStateFlag - inactive_used");
					death_night_holder:InterfaceFunction("SetStateFlag", "inactive_used");
				else
					out.design("\tSetStateFlag - active");
					death_night_holder:InterfaceFunction("SetStateFlag", "active");
				end
			end
		end
	end
end

function blood_voyage_warning_event(faction_name)

	cm:add_faction_turn_start_listener_by_name(
		"death_night_turn_start_ai",
		faction_name,
		function(context)
			local blood_voyage_fac = cm:model():world():faction_by_key(blood_voyage_faction);
			local blood_voyage_leader = blood_voyage_fac:faction_leader();
			local bx = blood_voyage_leader:logical_position_x();
			local by = blood_voyage_leader:logical_position_y();
			local bdx = blood_voyage_leader:display_position_x();
			local bdy = blood_voyage_leader:display_position_y();
		
			cm:show_message_event_located(
				context:faction():name(),
				"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage_target_title",
				"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage_target_primary_detail",
				"event_feed_strings_text_wh_dlc10_event_feed_string_scripted_event_blood_voyage_target_secondary_detail",
				bx,
				by,
				true,
				1015
			);
			
			local spawn_region = "wh2_main_sea_sea_of_malice";
			
			if cm:model():campaign_name("wh2_main_great_vortex") then
				spawn_region = "wh2_main_vor_sea_sea_of_malice";
			end
			
			cm:make_region_visible_in_shroud(context:faction():name(), spawn_region);
			
			local local_faction = cm:get_local_faction_name(true);
		
			if local_faction == context:faction():name() then
				cm:scroll_camera_from_current(true, 3, {bdx, bdy, 10.5, 0.0, 6.8});
			end
		end,
		false
	);
end

function death_night_setup_army()
	-- First army spawned by Death Night
	random_army_manager:new_force("death_night_army_1");
	
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_inf_har_ganeth_executioners_0", 2);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_dlc10_def_inf_sisters_of_slaughter", 2);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_cav_cold_one_knights_1", 2);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_mon_black_dragon", 1);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_mon_war_hydra", 1);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_inf_bleakswords_0", 4);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_inf_dreadspears_0", 4);
	random_army_manager:add_mandatory_unit("death_night_army_1", "wh2_main_def_inf_witch_elves_0", 2);
	
	-- Any army spawned after the first Death Night
	random_army_manager:new_force("death_night_army_2");
	
	random_army_manager:add_mandatory_unit("death_night_army_2", "wh2_main_def_inf_har_ganeth_executioners_0", 4);
	random_army_manager:add_mandatory_unit("death_night_army_2", "wh2_dlc10_def_inf_sisters_of_slaughter", 4);
	random_army_manager:add_mandatory_unit("death_night_army_2", "wh2_main_def_cav_cold_one_knights_1", 2);
	random_army_manager:add_mandatory_unit("death_night_army_2", "wh2_main_def_inf_witch_elves_0", 5);
	random_army_manager:add_mandatory_unit("death_night_army_2", "wh2_main_def_mon_war_hydra", 1);
	
	random_army_manager:add_unit("death_night_army_2", "wh2_main_def_mon_black_dragon", 1);
	random_army_manager:add_unit("death_night_army_2", "wh2_main_def_mon_war_hydra", 1);
	random_army_manager:add_unit("death_night_army_2", "wh2_main_def_inf_bleakswords_0", 2);
	random_army_manager:add_unit("death_night_army_2", "wh2_main_def_inf_shades_1", 2);
	random_army_manager:add_unit("death_night_army_2", "wh2_main_def_inf_black_guard_0", 2);
	
	-- Player controlled army
	random_army_manager:new_force("death_night_army_player");
	
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_dlc10_def_inf_sisters_of_slaughter", 4);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_cav_cold_one_knights_1", 2);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_mon_black_dragon", 1);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_mon_war_hydra", 1);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_inf_bleakswords_0", 5);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_inf_dreadspears_0", 4);
	random_army_manager:add_mandatory_unit("death_night_army_player", "wh2_main_def_inf_witch_elves_0", 2);
end

function death_night_accessor()
	return death_night, blood_voyage;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("death_night", death_night, context);
		cm:save_named_value("blood_voyage", blood_voyage, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			death_night = cm:load_named_value("death_night", death_night, context);
			blood_voyage = cm:load_named_value("blood_voyage", blood_voyage, context);
		end
	end
);