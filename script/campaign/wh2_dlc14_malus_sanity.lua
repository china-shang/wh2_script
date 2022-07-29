local malus_sanity_faction = "wh2_main_def_hag_graef";
local malus_sanity_rite_key = "wh2_dlc14_ritual_def_warmaster";
local malus_sanity_ui_bar_key = "posession_orb";
local malus_sanity_button_key = "malus_potion";
local malus_sanity_ability_key_1 = "wh2_dlc14_lord_abilities_the_blood_price";
local malus_sanity_ability_key_2 = "wh2_dlc14_lord_abilities_the_daemons_curse";
local malus_sanity_ability_use = 1;
local malus_sanity_per_turn = 2;
local malus_sanity_in_settlement = -1;
local malus_sanity_medication_use = -10;
local malus_sanity_cost = 1;
local malus_sanity_cost_base = 1;
local malus_sanity_cost_easy = 200;
local malus_sanity_cost_normal = 400;
local malus_sanity_cost_hard = 500;
local malus_sanity_cost_very_hard = 600;
local malus_sanity_cost_mod = 0.04;

function add_malus_sanity_listeners()
	out("#### Adding Malus Sanity Listeners ####");
	if cm:is_new_game() == true then
		local malus_faction = cm:get_faction(malus_sanity_faction);
		local difficulty = cm:model():difficulty_level()
		local malus_character = malus_faction:faction_leader();

		if difficulty == 1 then
			malus_sanity_cost_base = malus_sanity_cost_easy
		elseif difficulty == 0 then
			malus_sanity_cost_base = malus_sanity_cost_normal
		elseif difficulty == -1 then
			malus_sanity_cost_base = malus_sanity_cost_hard
		else
			malus_sanity_cost_base = malus_sanity_cost_very_hard
		end

		if malus_faction and malus_faction:is_human() then
			sanity_ModifySanity("wh2_dlc14_resource_factor_sanity_deterioration", 10);
			sanity_UpdateUI();
			if cm:get_campaign_name() == "main_warhammer" then
				cm:trigger_mission(malus_sanity_faction,"wh2_dlc14_mortal_empires_elixir_objective",true);
			end
		else 
			sanity_ModifySanity("wh2_dlc14_resource_factor_sanity_deterioration", 10);
			cm:remove_effect_bundle("wh2_dlc14_pooled_resource_malus_sanity_7", malus_sanity_faction);
			cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_ai", malus_character, 0);
		end
	end

	core:add_listener(
		"sanity_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return context:faction():name() == malus_sanity_faction;
		end,
		function(context)
			sanity_FactionTurnStart(context:faction());
		end,
		true
	);
	core:add_listener(
		"sanity_BattleCompleted",
		"BattleCompleted",
		true,
		function(context)
			sanity_BattleCompleted(context);
		end,
		true
	);
	core:add_listener(
		"sanity_ComponentLClickUp",
		"ComponentLClickUp",
		function(context)
			if context.string == "round_small_button" then
				local component = UIComponent(context.component);
				local parent = UIComponent(component:Parent());

				if parent:Id() == malus_sanity_button_key then
					return true;
				end
			end
			return false;
		end,
		function(context)
			local local_faction = cm:get_local_faction_name(true);
			local faction = cm:model():world():faction_by_key(local_faction);
			local faction_cqi = faction:command_queue_index();
			CampaignUI.TriggerCampaignScriptEvent(faction_cqi, "sanity_potion");
			core:trigger_event("ScriptEventElixirButtonClicked");
		end,
		true
	);
	core:add_listener(
		"sanity_UITrigger",
		"UITrigger",
		function(context)
			return context:trigger() == "sanity_potion";
		end,
		function(context)
			sanity_ModifySanity("wh2_dlc14_resource_factor_sanity_medication", malus_sanity_medication_use);
			local faction = cm:model():faction_for_command_queue_index(context:faction_cqi());
			sanity_UpdateEffects(faction);
			sanity_UpdateUI();
		end,
		true
	);
	core:add_listener(
		"dust_RitualCompletedEvent",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_key() == "wh2_dlc14_malus_call_tzarkan";
		end,
		function(context)
			local faction = context:performing_faction();
			sanity_UpdateEffects(faction);
		end,
		true
	);
	core:add_listener(
		"sanity_RegionFactionChangeEvent",
		"RegionFactionChangeEvent",
		function(context)
			local region = context:region();
			local owner = region:owning_faction():name();
			local previous_faction = context:previous_faction():name();
			return owner == malus_sanity_faction or previous_faction == malus_sanity_faction;
		end,
		function(context)
			sanity_UpdateUI();
		end,
		true
	);
	core:add_listener(
		"sanity_MalusWinsFinalBattle",
		"MalusWinsFinalBattle",
		true,
		function(context)
			malus_sanity_cost_base = 0;
			sanity_UpdateUI();
		end,
		true
	);
	core:add_listener(
		"sanity_MissionSucceeded",
		"MissionSucceeded",
		function(context)
			return context:mission():mission_record_key() == "wh2_dlc14_mortal_empires_elixir_objective";
		end,
		function(context)
			malus_sanity_cost_base = 0;
			sanity_UpdateUI();
		end,
		true
	);

	sanity_UpdateUI();
end

function sanity_FactionTurnStart(faction)

	local malus_character = faction:faction_leader();

	if malus_character:in_settlement() == true then
		sanity_ModifySanity("wh2_dlc14_resource_factor_sanity_in_settlement", malus_sanity_in_settlement);
	end

	sanity_ModifySanity("wh2_dlc14_resource_factor_sanity_deterioration", malus_sanity_per_turn);
	sanity_UpdateEffects(faction);
	sanity_UpdateUI();
end

function sanity_UpdateEffects(faction)
	local malus_character = faction:faction_leader();
	
	cm:remove_effect_bundle_from_character("wh2_dlc14_pooled_resource_malus_sanity_4_character", malus_character);
	cm:remove_effect_bundle_from_character("wh2_dlc14_pooled_resource_malus_sanity_5_character", malus_character);
	cm:remove_effect_bundle_from_character("wh2_dlc14_pooled_resource_malus_sanity_6_character", malus_character);
	cm:remove_effect_bundle_from_character("wh2_dlc14_pooled_resource_malus_sanity_7_character", malus_character);

	if faction:has_effect_bundle("wh2_dlc14_pooled_resource_malus_sanity_5") == true then
		cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_5_character", malus_character, 0);
		cm:lock_ritual(faction, malus_sanity_rite_key);
	elseif faction:has_effect_bundle("wh2_dlc14_pooled_resource_malus_sanity_6") == true then
		cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_6_character", malus_character, 0);
		cm:lock_ritual(faction, malus_sanity_rite_key);
	elseif faction:has_effect_bundle("wh2_dlc14_pooled_resource_malus_sanity_7") == true then
		cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_7_character", malus_character, 0);
		cm:lock_ritual(faction, malus_sanity_rite_key);
	elseif faction:has_effect_bundle("wh2_dlc14_pooled_resource_malus_sanity_1") == true then
		cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_4_character", malus_character, 0);
		sanity_UnlockWarmasterRite();
	else
		cm:apply_effect_bundle_to_character("wh2_dlc14_pooled_resource_malus_sanity_4_character", malus_character, 0);
		cm:lock_ritual(faction, malus_sanity_rite_key);
	end

	sanity_UpdateUI();
end

function sanity_BattleCompleted(context)
	local pending_battle = cm:model():pending_battle();
	if pending_battle:has_been_fought() == true then
		local malus_faction_cqi = 0;

		for i = 1, cm:pending_battle_cache_num_attackers() do
			local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);

			if attacker_name == malus_sanity_faction then
				malus_faction_cqi = attacker_cqi;
				break;
			end
		end

		if malus_faction_cqi == 0 then
			for i = 1, cm:pending_battle_cache_num_defenders() do
				local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);

				if defender_name == malus_sanity_faction then
					malus_faction_cqi = defender_cqi;
					break;
				end
			end
		end
		if malus_faction_cqi > 0 then
			local faction = cm:get_faction(malus_sanity_faction);
			local possession = faction:pooled_resource("def_malus_sanity");

			if possession:value() >= 10 then
				core:trigger_event("ScriptEventMalusPossessedPostBattle");
			end
			if cm:turn_number() <= 2 then
				core:trigger_event("ScriptEventFireElixirEGMission");
			end
		end
	end
end

function sanity_ModifySanity(factor, amount)
	cm:faction_add_pooled_resource(malus_sanity_faction, "def_malus_sanity", factor, amount);
end

function sanity_UpdateUI()
	local turn_number = cm:model():turn_number();
	local malus_faction = cm:model():world():faction_by_key(malus_sanity_faction);

	if malus_sanity_cost_base ~= 0 then
		if malus_faction:is_null_interface() == false and malus_faction:is_dead() == false then
			local region_count = malus_faction:region_list():num_items();
			malus_sanity_cost = malus_sanity_cost_base + ((region_count - 1) + (turn_number - 1)) / malus_sanity_cost_mod;
			malus_sanity_cost = math.ceilTo(malus_sanity_cost, 5);
		else
			malus_sanity_cost = 999;
		end
	else malus_sanity_cost = 0
	end

	local ui_root = core:get_ui_root();
	local sanity_ui = find_uicomponent(ui_root, malus_sanity_ui_bar_key);
	local button_ui = find_uicomponent(ui_root, malus_sanity_button_key);
		
	if sanity_ui then
		sanity_ui:InterfaceFunction("UpdateDisplay");
	end
	if button_ui then
		button_ui:InterfaceFunction("UpdateDisplay", malus_sanity_cost);
	end
end

function sanity_UnlockWarmasterRite()
	cm:unlock_ritual(cm:get_faction(malus_sanity_faction), malus_sanity_rite_key);
	cm:callback(
		function()
			cm:show_message_event(
				malus_sanity_faction,
				"event_feed_strings_text_wh2_event_feed_string_scripted_event_rite_unlocked_primary_detail",
				"rituals_display_name_" .. malus_sanity_rite_key,
				"event_feed_strings_text_wh2_event_feed_string_scripted_event_rite_unlocked_secondary_detail_" .. malus_sanity_rite_key,
				true,
				811,
				nil,
				nil,
				true
			);
		end,
		0.2
	);
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("malus_sanity", malus_sanity_cost_base, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			malus_sanity_cost_base = cm:load_named_value("malus_sanity", malus_sanity_cost_base, context);
		end
	end
);