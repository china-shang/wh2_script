PEASANTS_EFFECT_PREFIX = "wh_dlc07_bundle_peasant_penalty_";
PEASANTS_PER_REGION = 2;
PEASANTS_BASE_AMOUNT = 6;
PEASANTS_RATIO_POSITIVE = true;
PEASANTS_WARNING_COOLDOWN = 1;
show_peasant_debug = true;

function Add_Peasant_Economy_Listeners()
	out("#### Adding Peasant Economy Listeners ####");
	core:add_listener(
		"BRT_Peasant_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context) Calculate_Economy_Penalty(context:faction()) end,
		true
	);
	core:add_listener(
		"BRT_Peasant_UnitMergedAndDestroyed",
		"UnitMergedAndDestroyed",
		true,
		function(context)
			local faction = context:new_unit():faction();
			cm:callback(function()
				Calculate_Economy_Penalty(faction);
			end, 0.5);
		end,
		true
	);
	core:add_listener(
		"BRT_Peasant_UnitDisbanded",
		"UnitDisbanded",
		true,
		function(context)
			local faction = context:unit():faction();
			cm:callback(function()
				Calculate_Economy_Penalty(faction);
			end, 0.5);
		end,
		true
	);
	core:add_listener(
		"BRT_Peasant_FactionJoinsConfederation",
		"FactionJoinsConfederation",
		true,
		function(context) Calculate_Economy_Penalty(context:confederation()) end,
		true
	);
	core:add_listener(
		"BRT_Peasant_BattleCompleted",
		"BattleCompleted",
		true,
		function(context)
			for i = 1, cm:pending_battle_cache_num_attackers() do
				local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);
				local faction = cm:model():world():faction_by_key(attacker_name);
				Calculate_Economy_Penalty(faction);

			end
			for i = 1, cm:pending_battle_cache_num_defenders() do
				local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);
				local faction = cm:model():world():faction_by_key(defender_name);
				Calculate_Economy_Penalty(faction);
			end
		end,
		true
	);
	
	local bretonnia = cm:model():world():faction_by_key("wh_main_brt_bretonnia");
	
	if bretonnia:is_null_interface() == false and bretonnia:is_dead() == false then
		Calculate_Economy_Penalty(bretonnia);
	end
	
	local carcassonne = cm:model():world():faction_by_key("wh_main_brt_carcassonne");
	
	if carcassonne:is_null_interface() == false and carcassonne:is_dead() == false then
		Calculate_Economy_Penalty(carcassonne);
	end
	
	local bordeleaux = cm:model():world():faction_by_key("wh_main_brt_bordeleaux");
	
	if bordeleaux:is_null_interface() == false and bordeleaux:is_dead() == false then
		Calculate_Economy_Penalty(bordeleaux);
	end
	
	local chevaliers = cm:model():world():faction_by_key("wh2_dlc14_brt_chevaliers_de_lyonesse");
	
	if chevaliers:is_null_interface() == false and chevaliers:is_dead() == false then
		Calculate_Economy_Penalty(chevaliers);
	end
end

function Calculate_Economy_Penalty(faction)
	if faction:is_null_interface() == false and faction:is_dead() == false and faction:is_human() == true and Is_Bretonnian(faction:name()) then
		output_P("---- Calculate_Economy_Penalty ----");
		local peasant_count = 0;
		local force_list = faction:military_force_list();
		local region_count = faction:region_list():num_items();
		
		for i = 0, force_list:num_items() - 1 do
			local force = force_list:item_at(i);
			
			-- Make sure this isn't a garrison!
			if force:is_armed_citizenry() == false and force:has_general() == true then
				local unit_list = force:unit_list();
				
				for j = 0, unit_list:num_items() - 1 do
					local unit = unit_list:item_at(j);
					local key = unit:unit_key();
					local val = Bretonnia_Peasant_Units[key] or 0;
					
					output_P("\t"..key.." - "..val);
					peasant_count = peasant_count + val;
				end
			end
		end
		
		if cm:is_multiplayer() == false then
			if PEASANTS_WARNING_COOLDOWN > 0 then
				PEASANTS_WARNING_COOLDOWN = PEASANTS_WARNING_COOLDOWN - 1;
			end
		end
		
		output_P("\tPeasants: "..peasant_count);
		Remove_Economy_Penalty(faction);
		
		local peasants_per_region_fac = PEASANTS_PER_REGION;
		local peasants_base_amount_fac = PEASANTS_BASE_AMOUNT;
		
		-- Peasants Per Region Modifiers
		if faction:name() == "wh_main_brt_carcassonne" then
			peasants_base_amount_fac = peasants_base_amount_fac + 5;
		end
		if faction:has_technology("tech_dlc07_brt_economy_farm_4") then
			peasants_per_region_fac = peasants_per_region_fac + 1;
		end
		if faction:has_technology("tech_dlc07_brt_heraldry_unification") then
			peasants_base_amount_fac = peasants_base_amount_fac + 10;
		end
		if faction:has_technology("tech_dlc14_brt_rally_the_peasants") then
			peasants_base_amount_fac = peasants_base_amount_fac + 15;
		end
		
		-- Make sure player has regions
		if faction:region_list():num_items() < 1 then
			peasants_base_amount_fac = 0;
		end
		
		local free_peasants = (region_count * peasants_per_region_fac) + peasants_base_amount_fac;
		free_peasants = math.max(1, free_peasants);
		output_P("Free Peasants: "..free_peasants);
		local peasant_percent = (peasant_count / free_peasants) * 100;
		output_P("Peasant Percent: "..peasant_percent.."%");
		peasant_percent = RoundUp(peasant_percent);
		output_P("Peasant Percent Rounded: "..peasant_percent.."%");
		peasant_percent = math.min(peasant_percent, 200);
		output_P("Peasant Percent Clamped: "..peasant_percent.."%");
		
		if peasant_percent > 100 then
			peasant_percent = peasant_percent - 100;
			output_P("Peasant Percent Final: "..peasant_percent);
			cm:apply_effect_bundle(PEASANTS_EFFECT_PREFIX..peasant_percent, faction:name(), 0);
			
			if cm:get_saved_value("ScriptEventNegativePeasantEconomy") ~= true and faction:is_human() then
				core:trigger_event("ScriptEventNegativePeasantEconomy");
				cm:set_saved_value("ScriptEventNegativePeasantEconomy", true);
			end
			
			if cm:is_multiplayer() == false then
				if PEASANTS_RATIO_POSITIVE == true and PEASANTS_WARNING_COOLDOWN < 1 then
					Show_Peasant_Warning(faction:name());
					PEASANTS_WARNING_COOLDOWN = 25;
				end
			end
			
			PEASANTS_RATIO_POSITIVE = false;
		else
			output_P("Peasant Percent Final: 0");
			cm:apply_effect_bundle(PEASANTS_EFFECT_PREFIX.."0", faction:name(), 0);
			
			if cm:get_saved_value("ScriptEventNegativePeasantEconomy") == true and cm:get_saved_value("ScriptEventPositivePeasantEconomy") ~= true and faction:is_human() then
				core:trigger_event("ScriptEventPositivePeasantEconomy");
				cm:set_saved_value("ScriptEventPositivePeasantEconomy", true);
			end
			PEASANTS_RATIO_POSITIVE = true;
		end
	end
end

function Remove_Economy_Penalty(faction)
	output_P("---- Remove_Economy_Penalty ----");
	for i = 0, 100 do
		local bundle = PEASANTS_EFFECT_PREFIX .. i;
		
		if faction:has_effect_bundle(bundle) then
			cm:remove_effect_bundle(bundle, faction:name());
		end;
	end
end

function RoundUp(n)
	return math.floor((math.floor(n*2) + 1)/2);
end

function Is_Peasant_Unit(unit_key)
	local val = Bretonnia_Peasant_Units[unit_key] or 0;
	
	if val > 0 then
		return true;
	end
	return false;
end

function Show_Peasant_Warning(faction)
	cm:show_message_event(
		faction,
		"event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_peasant_negative_title",
		"event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_peasant_negative_primary_detail",
		"event_feed_strings_text_wh_dlc07_event_feed_string_scripted_event_peasant_negative_secondary_detail",
		true,
		703
	);
end

Bretonnia_Peasant_Units = {
	["wh_dlc07_brt_art_blessed_field_trebuchet_0"] = 1,
	["wh_dlc07_brt_inf_battle_pilgrims_0"] = 1,
	["wh_dlc07_brt_inf_foot_squires_0"] = 1,
	["wh_dlc07_brt_inf_grail_reliquae_0"] = 1,
	["wh_dlc07_brt_inf_men_at_arms_1"] = 1,
	["wh_dlc07_brt_inf_men_at_arms_2"] = 1,
	["wh_dlc07_brt_inf_spearmen_at_arms_1"] = 1,
	["wh_dlc07_brt_peasant_mob_0"] = 1,
	["wh_dlc07_brt_inf_peasant_bowmen_1"] = 1,
	["wh_dlc07_brt_inf_peasant_bowmen_2"] = 1,
	["wh_main_brt_art_field_trebuchet"] = 1,
	["wh_main_brt_cav_mounted_yeomen_0"] = 1,
	["wh_main_brt_cav_mounted_yeomen_1"] = 1,
	["wh_main_brt_inf_men_at_arms"] = 1,
	["wh_main_brt_inf_peasant_bowmen"] = 1,
	["wh_main_brt_inf_spearmen_at_arms"] = 1
};

function output_P(txt)
	if show_peasant_debug then
		out(txt);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("PEASANTS_RATIO_POSITIVE", PEASANTS_RATIO_POSITIVE, context);
		cm:save_named_value("PEASANTS_WARNING_COOLDOWN", PEASANTS_WARNING_COOLDOWN, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		PEASANTS_RATIO_POSITIVE = cm:load_named_value("PEASANTS_RATIO_POSITIVE", true, context);
		PEASANTS_WARNING_COOLDOWN = cm:load_named_value("PEASANTS_WARNING_COOLDOWN", 1, context);
	end
);