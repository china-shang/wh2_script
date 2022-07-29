local greenskin = "wh_main_sc_grn_greenskins"
local wagh_per_turn = 1;
local wagh_ended = -100;
local wagh_battle_mod = 0.015;
local wagh_battle_cap = 6;
local wagh_ai_min_cap = 50;
local wagh_ai_reduction = -2;
local wagh_ai_boost = 100;
local wagh_state = false;
local wagh_ai_state = false;
local wagh_ai_counter = 0;
local wagh_button_key = "shard_animation";
local wagh_ritual_key = "wh2_main_ritual_grn_waaagh"
local ritual_region_key = "";
local ai_ritual_region_key = "";
local wagh_ai_cooldown = 30;
local wagh_success = false;
local wagh_god = "";
local wagh_composite_scene = "waaagh_ui_target";
local advice_reminder_counter = 0;

local wagh_greenskin_ai = {
	"wh_main_grn_greenskins",
	"wh_main_grn_crooked_moon",
	"wh_main_grn_orcs_of_the_bloody_hand",
	"wh2_dlc15_grn_broken_axe",
	"wh2_dlc15_grn_bonerattlaz"
}

local event_messages_greenskins = {
	title = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_title_grimgor",
	description = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_description_grimgor"
}
local event_messages_crooked_moon = {
	title = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_title_skarsnik",
	description = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_description_skarsnik"
}
local event_messages_orcs_of_the_bloody_hand = {
	title = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_title_wurrzag",
	description = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_description_wurrzag"
}
local event_messages_broken_axe = {
	title = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_title_grom",
	description = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_description_grom"
}
local event_messages_bonerattlaz = {
	title = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_title_azhag",
	description = "event_feed_strings_text_wh2_main_event_feed_string_scripted_event_grn_waaagh_description_azhag"
}

local reward_level = ""
local reward_culture = ""
local previous_reward_level = ""
local previous_reward_culture = ""
local gork_counter = 0
local mork_counter = 0

local wagh_rewards ={
	["humans"] = {
		points = 0,
		culture = {"wh_main_emp_empire", "wh_main_brt_bretonnia"}
	},
	["dwarfs"] = {
		points = 0,
		culture = {"wh_main_dwf_dwarfs"}
	},
	["chaos"] = {
		points = 0,
		culture = {"wh_main_chs_chaos", "wh_dlc08_nor_norsca", "wh2_main_rogue","wh_dlc03_bst_beastmen"}
	},
	["undead"] = {
		points = 0,
		culture = {"wh2_dlc09_tmb_tomb_kings", "wh2_dlc11_cst_vampire_coast", "wh_main_vmp_vampire_counts"}
	},
	["elves"] = {
		points = 0,
		culture = {"wh2_main_def_dark_elves", "wh2_main_hef_high_elves", "wh_dlc05_wef_wood_elves"}
	},
	["greenskins"] = {
		points = 0,
		culture = {"wh_main_grn_greenskins"}
	},
	["lizards"] = {
		points = 0,
		culture = {"wh2_main_lzd_lizardmen"}
	},
	["rats"] = {
		points = 0,
		culture = {"wh2_main_skv_skaven"}
	}
}

local wagh_units_level1 = {
	"wh2_dlc15_grn_cav_forest_goblin_spider_riders_waaagh_0",
	"wh_dlc06_grn_inf_squig_explosive_0"
}

local wagh_units_level2 = {
	"wh2_dlc15_grn_cav_squig_hoppers_waaagh_0",
	"wh2_dlc15_grn_mon_wyvern_waaagh_0"
}

local wagh_units_level3 = {
	"wh_dlc15_grn_mon_arachnarok_spider_waaagh_0",
	"wh2_dlc15_grn_mon_feral_hydra_waaagh_0"
}

GREENSKIN_CONFEDERATION_DILEMMA = "wh2_main_grn_confederate_";
GREENSKIN_CONFEDERATION_PLAYER = "";

function add_wagh_listeners()
	out("#### Adding wagh Listeners ####");

	if cm:is_new_game() == true or wagh_state == false then
		effect.set_context_value("wagh_state", "false");
	end


	core:add_listener(
		"Wagh_FactionTurnStart_PlayerGreenskin_listener",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			if context:faction():subculture() == greenskin then
				return true
			end
		end,
		function(context)
			local faction = context:faction():name();
			
			Wagh_FactionTurnStart_PlayerGreenskin(context:faction());

			if mork_counter == 3 then
				cm:trigger_incident(faction,"wh2_main_incident_grn_mork_is_happy");
				mork_counter = 0
			elseif gork_counter == 3 then
				cm:trigger_incident(faction,"wh2_main_incident_grn_gork_is_happy");
				gork_counter = 0
			end
		end,
		true
	);
	core:add_listener(
		"Wagh_FactionTurnStart_Player_listener",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			if context:faction():subculture() ~= greenskin then
				return true
			end
		end,
		function(context)			
			Wagh_FactionTurnStart_Player(context:faction());
		end,
		true
	);
	cm:add_faction_turn_start_listener_by_subculture(
		"Wagh_FactionTurnStart_AI_listener",
		greenskin,
		function(context)
			if not context:faction():is_human() then
				Wagh_FactionTurnStart_AI(context:faction());
			end;
		end,
		true
	);
	core:add_listener(
		"Wagh_BattleCompleted_listener",
		"BattleCompleted",
		function(context)
			return cm:model():pending_battle():has_been_fought();
		end,
		function(context)
			Wagh_BattleCompleted(context);
		end,
		true
	);
	core:add_listener(
		"Wagh_Started_listener",
		"RitualStartedEvent",
		function(context)
			return context:ritual():ritual_key() == wagh_ritual_key
		end,
		function(context)
			if context:performing_faction():is_human() == true then
				Wagh_Started(context);
				wagh_state = true;
				effect.set_context_value("wagh_state", "true");
			else
				wagh_ai_state = true;
				wagh_ai_counter = 0;
			end
		end,
		true
	);
	core:add_listener(
		"Wagh_Completed_listener",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_key() == wagh_ritual_key
		end,
		function(context)
			if context:performing_faction():is_human() == true then
				Wagh_Ended(context);
				wagh_state = false;
				effect.set_context_value("wagh_state", "false");
			else
				Wagh_Ended_AI(context);
				wagh_ai_state = false;
			end
		end,
		true
	);
	core:add_listener(
		"Wagh_Target_Razed_listener",
		"CharacterRazedSettlement",
		function(context)
			return context:garrison_residence():region():name() == ritual_region_key and context:character():faction():is_human() and context:character():faction():subculture() == greenskin
		end,
		function(context)
			local faction = context:character():faction():name()
			wagh_success = true;
			out.design("### Waaagh target has been razed: WAAAGH! was a success")
			cm:trigger_incident(faction,"wh_main_incident_grn_waaagh_success_raze", true)
		end,
		true
	);
	core:add_listener(
		"Wagh_Target_Occupied_listener",
		"GarrisonOccupiedEvent",
		function(context)
			return context:garrison_residence():region():name() == ritual_region_key and context:character():faction():is_human() and context:character():faction():subculture() == greenskin
		end,
		function(context)
			local faction = context:character():faction():name()
			out.design("### Waaagh target has been occupied and needs to be held")
			cm:trigger_incident(faction,"wh_main_incident_grn_waaagh_success_occupy", true)
		end,
		true
	);
	-- if Greenskins are confederated during an active Waaagh, check if LL and apply Waaagh bundle for LL
	core:add_listener(
		"Wagh_FactionJoinsConfederation_listener",
		"FactionJoinsConfederation",
		function(context)
			return context:confederation():is_human() and context:confederation():subculture() == greenskin
		end,
		function(context)
			local faction = context:confederation();
			local bundles = faction:effect_bundles();
			local waaagh_turns = 1;
			for i = 0, bundles:num_items() - 1 do
				if bundles:item_at(i) == "wh2_main_faction_boost_gork" or bundles:item_at(i) == "wh2_main_faction_boost_mork" then
					waaagh_turns = bundles:item_at(i):duration();
				end
			end

			Battle_Big_Waaagh_Upgrade(faction, waaagh_turns);
		end,
		true
	);
	-- if during an active Waaagh and LL is recruited, make sure to apply Waaagh bundle for LL
	core:add_listener(
		"Wagh_MilitaryForceCreated_listener",
		"MilitaryForceCreated",
		function(context)
			return context:military_force_created():faction():is_human() and context:military_force_created():faction():subculture() == greenskin
		end,
		function(context)
			local faction = context:military_force_created():faction();
			local bundles = faction:effect_bundles();
			local waaagh_turns = 1;
			for i = 0, bundles:num_items() - 1 do
				if bundles:item_at(i) == "wh2_main_faction_boost_gork" or bundles:item_at(i) == "wh2_main_faction_boost_mork" then
					waaagh_turns = bundles:item_at(i):duration();
				end
			end

			Battle_Big_Waaagh_Upgrade(faction, waaagh_turns);
		end,
		true
	);
	-- if during an active Waaagh and LL replaces general of existing military force, make sure to apply Waaagh bundle for LL
			core:add_listener(
		"Wagh_CharacterReplacingGeneral",
		"CharacterReplacingGeneral",
		function(context)
			return context:character():faction():is_human() and context:character():faction():subculture() == greenskin
		end,
		function(context)
			local faction = context:character():faction();
			local bundles = faction:effect_bundles();
			local waaagh_turns = 1;
			for i = 0, bundles:num_items() - 1 do
				if bundles:item_at(i) == "wh2_main_faction_boost_gork" or bundles:item_at(i) == "wh2_main_faction_boost_mork" then
					waaagh_turns = bundles:item_at(i):duration();
				end
			end

			Battle_Big_Waaagh_Upgrade(faction, waaagh_turns);
		end,
		true
	);
	-- Gork or Mork selection
	core:add_listener(
		"Wagh_ComponentLClickUp_listener",
		"ComponentLClickUp",
		function(context)
			if context.string == "mork_button" or context.string == "gork_button" then
				return true;
			end
		end,
		function(context)
			local local_faction = cm:whose_turn_is_it();
			local faction = cm:model():world():faction_by_key(local_faction);
			
			if context.string == "mork_button" then
				if faction:is_null_interface() == false then
					local faction_cqi = faction:command_queue_index();
					CampaignUI.TriggerCampaignScriptEvent(faction_cqi, "wagh_mork_selection");
				end
			elseif context.string == "gork_button" then
				if faction:is_null_interface() == false then
					local faction_cqi = faction:command_queue_index();
					CampaignUI.TriggerCampaignScriptEvent(faction_cqi, "wagh_gork_selection");
				end
			end
		end,
		true
	);
	core:add_listener(
		"Wagh_mork_selection_listener",
		"UITrigger",
		function(context)
			return context:trigger() == "wagh_mork_selection";
		end,
		function(context)
			local local_faction = cm:whose_turn_is_it();
			local faction = cm:model():world():faction_by_key(local_faction);
			local faction_name = faction:name();

			wagh_god = "mork";
			out.design("### WAAAGH! dedicated to "..wagh_god.."!");
			cm:apply_effect_bundle("wh2_main_faction_boost_mork", faction_name, 20);
			mork_counter = mork_counter + 1;
			gork_counter = 0;
			effect.set_context_value("wagh_god", wagh_god);
			Battle_Big_Waaagh_Upgrade(faction, 20);
		end,
		true
	);
	core:add_listener(
		"Wagh_gork_selection_listener",
		"UITrigger",
		function(context)
			return context:trigger() == "wagh_gork_selection";
		end,
		function(context)
			local local_faction = cm:whose_turn_is_it();
			local faction = cm:model():world():faction_by_key(local_faction);
			local faction_name = faction:name();

			wagh_god = "gork";
			out.design("### WAAAGH! dedicated to "..wagh_god.."!");
			cm:apply_effect_bundle("wh2_main_faction_boost_gork", faction_name, 20);
			gork_counter = gork_counter + 1;
			mork_counter = 0;
			effect.set_context_value("wagh_god", wagh_god);
			Battle_Big_Waaagh_Upgrade(faction, 20);
		end,
		true
	);
	-- Confederation via Defeat Leader
	core:add_listener(
		"Greenskin_Confed_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		function(context)
			return context:dilemma():starts_with(GREENSKIN_CONFEDERATION_DILEMMA);
		end,
		function(context)
			Greenskin_Confederation_Choice(context);
		end,
		true
	);
	core:add_listener(
		"character_completed_battle_greenskin_confederation_dilemma",
		"CharacterCompletedBattle",
		true,
		function(context)
			local character = context:character();
			
			if character:won_battle() == true and character:faction():subculture() == greenskin then
				local enemies = cm:pending_battle_cache_get_enemies_of_char(character);
				local enemy_count = #enemies;
				
				if context:pending_battle():night_battle() == true or context:pending_battle():ambush_battle() == true then
					enemy_count = 1;
				end

				local character_cqi = character:command_queue_index();
				local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(1);
				local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(1);
				
				if character_cqi == attacker_cqi or character_cqi == defender_cqi then
					for i = 1, enemy_count do
						local enemy = enemies[i];
						
						if enemy ~= nil and enemy:is_null_interface() == false and enemy:is_faction_leader() == true and enemy:faction():subculture() == greenskin then
							if enemy:has_military_force() == true and enemy:military_force():is_armed_citizenry() == false then
								if character:faction():is_human() == true and enemy:faction():is_human() == false and enemy:faction():is_dead() == false then
									-- Trigger dilemma to offer confederation
									GREENSKIN_CONFEDERATION_PLAYER = character:faction():name();
									cm:trigger_dilemma(GREENSKIN_CONFEDERATION_PLAYER, GREENSKIN_CONFEDERATION_DILEMMA..enemy:faction():name());
									--Play_Norsca_Advice("dlc08.camp.advice.nor.confederation.001", norsca_info_text_confederation);
								elseif character:faction():is_human() == false and enemy:faction():is_human() == false then
									-- AI confederation
									cm:force_confederation(character:faction():name(), enemy:faction():name());
									out.design("###### AI GREENSKIN CONFEDERATION");
									out.design("Faction: "..character:faction():name().." is confederating "..enemy:faction():name());
								end
							end
						end
					end
				end
			end
		end,
		true
	);
	core:add_listener(
		"Wagh_ComponentLClickUp",
		"ComponentLClickUp",
		function(context)
			if context.string == wagh_button_key then
				return true;
			end
		end,
		function(context)
			core:trigger_event("ScriptEventWaghSelect");
		end,
		true
	);
	core:add_listener(
		"Wagh_Cancelled",
		"RitualCancelledEvent",
		function(context)
			return context:ritual():ritual_key() == wagh_ritual_key
		end,
		function(context)
			local comp_scene;
			if context:performing_faction():is_human() == true then
				comp_scene = "wagh_"..ritual_region_key;
				ritual_region_key = "";
				wagh_state = false;
			else
				comp_scene = "wagh_ai_"..ai_ritual_region_key;
				ai_ritual_region_key = "";
				wagh_ai_state = false;
			end
			cm:remove_scripted_composite_scene(comp_scene);
			out.design("### WAAAGH! ended removing VFX "..comp_scene)
		end,
		true
	);	
end

--function to apply and remove the LL versions of the Big Waaagh! battle army abilities
function Battle_Big_Waaagh_Upgrade(faction, waaagh_turns)
	
	local mf_list = faction:military_force_list();

	--loop through list to find any GS LL
	for i = 0, mf_list:num_items() - 1 do
		local force = mf_list:item_at(i);
		local character = force:general_character();
		local character_cqi = 0;

		if character:character_subtype("grn_azhag_the_slaughterer") then
			character_cqi = character:command_queue_index();
			cm:apply_effect_bundle_to_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi, waaagh_turns, false);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi);
		end
		if character:character_subtype("grn_grimgor_ironhide") then
			character_cqi = character:command_queue_index();
			cm:apply_effect_bundle_to_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi, waaagh_turns, false);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi);
		end
		if character:character_subtype("wh2_dlc15_grn_grom_the_paunch") then
			character_cqi = character:command_queue_index();
			cm:apply_effect_bundle_to_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi, waaagh_turns, false);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi);
		end
		if character:character_subtype("dlc06_grn_skarsnik") then
			character_cqi = character:command_queue_index();
			cm:apply_effect_bundle_to_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi, waaagh_turns, false);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi);
		end
		if character:character_subtype("dlc06_grn_wurrzag_da_great_prophet") then
			character_cqi = character:command_queue_index();
			cm:apply_effect_bundle_to_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi, waaagh_turns, false);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi);
		end

		--this step is important in case a character replaces a LL, the effect bundle would stay on the force - this removes that possibility
		if character:character_subtype_key() ~= "grn_azhag_the_slaughterer" and character:character_subtype_key() ~= "grn_grimgor_ironhide" and character:character_subtype_key() ~= "wh2_dlc15_grn_grom_the_paunch" 
				and character:character_subtype_key() ~= "dlc06_grn_skarsnik" and character:character_subtype_key() ~= "dlc06_grn_wurrzag_da_great_prophet" then
			
			character_cqi = character:command_queue_index();
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_azhags_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_grimgors_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_groms_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_skarsniks_big_waaagh_army_ability", character_cqi);
			cm:remove_effect_bundle_from_characters_force("wh2_dlc15_bundle_wurrzags_big_waaagh_army_ability", character_cqi);
		end
	end
	
end

function Greenskin_Confederation_Choice(context)
	local faction = string.gsub(context:dilemma(), GREENSKIN_CONFEDERATION_DILEMMA, "");
	local choice = context:choice();
	
	if choice == 0 then
		-- Confederate
		cm:force_confederation(GREENSKIN_CONFEDERATION_PLAYER, faction);
	elseif choice == 1 then
		-- Kill leader
		local enemy = cm:model():world():faction_by_key(faction);
		
		if enemy:has_faction_leader() == true then
			local leader = enemy:faction_leader();
			
			if leader:character_subtype("dlc06_grn_skarsnik") == false and leader:character_subtype("dlc06_grn_wurrzag_da_great_prophet") == false and leader:character_subtype("grn_grimgor_ironhide") == false and leader:character_subtype("wh2_dlc15_grn_grom_the_paunch") == false and leader:character_subtype("grn_azhag_the_slaughterer") == false then
				local cqi = leader:command_queue_index();
				cm:set_character_immortality("character_cqi:"..cqi, false);
				cm:kill_character(cqi, false, true);
			end
		end
	end
	
	-- autosave on legendary
	if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then
		cm:callback(function() cm:autosave_at_next_opportunity() end, 0.5);
	end;
end

function Wagh_Started(context)
	local ritual_target = context:ritual():ritual_target()
	local ritual_region = ritual_target:get_target_region()
	local ritual_region_owner = ritual_region:owning_faction()
	local ritual_region_owner_culture = ritual_region_owner:culture()
	local faction = context:performing_faction():name()
	ritual_region_key = ritual_region:name()

	out.design("##### Wagh Started - Ritual target region name: "..ritual_region_key)
	
	for key, value in pairs(wagh_rewards) do
		for i = 1, #value.culture do
			if ritual_region_owner_culture == value.culture[i] then
				reward_culture = key
			end
		end
	end	

	local uic_wagh_top_bar = find_uicomponent("waaaagh_holder", "waaagh_top_bar")

	if not uic_wagh_top_bar then
		script_error("ERROR: uic_wagh_top_bar could not be found")
		return
	end

	local reward_value = uic_wagh_top_bar:InterfaceFunction("GetWaaaghTargetFactionRank", ritual_region_key)

	if reward_value < 11 then
		reward_level = "level3"
	elseif reward_value < 31 then
		reward_level = "level2"
	else
		reward_level = "level1"
	end

	-- Apply current preview reward
	cm:apply_effect_bundle("wh2_main_faction_boost_reward_preview_"..reward_level.."_"..reward_culture, faction, 0);

	-- Add Waaagh VFX
	local comp_scene = "wagh_"..ritual_region_key
	local scene_type = wagh_composite_scene;
	local settlement = "settlement:"..ritual_region_key;

	cm:add_scripted_composite_scene_to_settlement(comp_scene, scene_type, settlement, 0, 0, false, true, true);
end

function Wagh_Ended(context)
	local faction = context:performing_faction():name()
	local current_ritual_region_owner = cm:get_region(ritual_region_key):owning_faction():name()

	out.design("##### Wagh Ended - Ritual target region name: "..ritual_region_key)

	-- Remove reward preview
	cm:remove_effect_bundle("wh2_main_faction_boost_reward_preview_"..reward_level.."_"..reward_culture, faction);

	-- Switch active reward
	cm:remove_effect_bundle("wh2_main_faction_boost_reward_"..previous_reward_level.."_"..previous_reward_culture, faction);

	-- Set Waaagh to 0
	Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_triggered", wagh_ended)

	if current_ritual_region_owner == faction or wagh_success == true then
		cm:apply_effect_bundle("wh2_main_faction_boost_reward_"..reward_level.."_"..reward_culture, faction, 0);
		previous_reward_level = reward_level;
		previous_reward_culture = reward_culture;

		-- Xiao request for elf trophy
		if reward_culture == "elves" then
			core:trigger_event("PlayerGainedWaghElfTrophy");
		end

		-- trigger successful WAAAGH event
		cm:trigger_incident(faction, "wh_main_incident_grn_waaagh_success", true)
		core:trigger_event("PlayerWaghEndedSuccessful");

		out.design("#### Wagh ended! Reward for culture: "..reward_culture.."! Level: "..reward_level)

		-- Award wagh and additional unit for successful WAAAGH!
		if reward_level == "level1" then
			Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_success", 10)
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level1[1], 1);
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level1[2], 1);
			out.design("### Adding Waaagh units to mercenary pool")
		elseif reward_level == "level2" then
			Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_success", 20)
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level2[1], 1);
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level2[2], 1);
			out.design("### Adding Waaagh units to mercenary pool")
		elseif reward_level == "level3" then
			Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_success", 30)
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level3[1], 1);
			cm:add_units_to_faction_mercenary_pool(context:performing_faction():command_queue_index(), wagh_units_level3[2], 1);
			out.design("### Adding Waaagh units to mercenary pool")
		end

		wagh_success = false;
	else
		-- trigger fail WAAAGH event
		cm:trigger_incident(faction,"wh_main_incident_grn_waaagh_failed", true)
		core:trigger_event("PlayerWaghEndedUnsuccessful");		

		previous_reward_level = "";
		previous_reward_culture = "";
	end

	local comp_scene = "wagh_"..ritual_region_key;
	cm:remove_scripted_composite_scene(comp_scene);

	ritual_region_key = "";
	wagh_god = "";
end

function Wagh_FactionTurnStart_PlayerGreenskin(faction)
	local faction_name = faction:name()

	-- passive wagh gain per turn for greenskin players
	Wagh_ModifyWagh(faction_name, "wh2_dlc15_resource_factor_waaagh_per_turn", wagh_per_turn);

	if faction:has_technology("tech_grn_final_1_2") then
		Wagh_ModifyWagh(faction_name, "wh2_dlc15_resource_factor_waaagh_per_turn", 5);
	end
	
	if wagh_state == true then
		local bundles = faction:effect_bundles();
		local waaagh_turns = 1;
		for i = 0, bundles:num_items() - 1 do
			if bundles:item_at(i) == "wh2_main_faction_boost_gork" or bundles:item_at(i) == "wh2_main_faction_boost_mork" then
				waaagh_turns = bundles:item_at(i):duration();
			end
		end

		Battle_Big_Waaagh_Upgrade(faction, waaagh_turns);

		core:trigger_event("ScriptEventWaghTransportedArmies")
	else
		effect.set_context_value("wagh_state", "false");
	end

	-- Count turns for advice reminder to trigger Waaagh!
	if faction:pooled_resource("grn_waaagh"):value() == 100 and wagh_state == false then
		advice_reminder_counter = advice_reminder_counter + 1;
		core:trigger_event("ScriptEventWaghResourceMax")
	else 
		advice_reminder_counter = 0
	end

	if advice_reminder_counter > 5 and wagh_state == false then
		core:trigger_event("ScriptEventWaghReminder")
	end

	-- AI has not triggered a WAAAGH!
	if wagh_ai_state == false then
		wagh_ai_counter = wagh_ai_counter + 1;
	end

	local turns_to_waaagh = wagh_ai_cooldown - wagh_ai_counter
	out.design("### Turns to next AI Waaagh Boost: "..turns_to_waaagh)
end

function Wagh_FactionTurnStart_Player(faction)
	local faction_name = faction:name()

	-- AI has not triggered a WAAAGH!
	if wagh_ai_state == false then
		wagh_ai_counter = wagh_ai_counter + 1;
	end

	local turns_to_waaagh = wagh_ai_cooldown - wagh_ai_counter
	out.design("### Turns to next AI Waaagh Boost: "..turns_to_waaagh)
end

function Wagh_FactionTurnStart_AI(faction)
	local faction_name = faction:name();
	local current_wagh = faction:pooled_resource("grn_waaagh"):value();

	out.design("### Current Waaagh of "..faction_name.." is "..current_wagh)
	-- IF appropriate AI faction has 100 wagh trigger WAAAAGH!
	if current_wagh == 100 and wagh_ai_state == false then
		for i = 0, #wagh_greenskin_ai do
			if wagh_greenskin_ai[i] == faction:name() then
				Wagh_Started_AI(faction);
			end
		end

	-- IF AI did not have a WAAAGH! for a period boost one of the appropriate factions
	elseif wagh_ai_counter > wagh_ai_cooldown and wagh_ai_state == false then
		local rand = cm:random_number(5)
		for i = 0, #wagh_greenskin_ai do
			if wagh_greenskin_ai[i] == faction:name() and rand == 5 then
				Wagh_ModifyWagh(faction_name, "wh2_dlc15_resource_factor_waaagh_other", wagh_ai_boost);
				out.design("### Applied Waaagh AI boost to faction: "..faction_name);
				wagh_ai_counter = 0;
			end
		end

	-- IF AI above 50 reduce wagh
	elseif current_wagh > 50 then
		Wagh_ModifyWagh(faction_name, "wh2_dlc15_resource_factor_waaagh_other", wagh_ai_reduction);
	-- IF AI below 50 increase wagh
	elseif current_wagh < 50 then
		local add_waaagh = wagh_ai_reduction * -1
		Wagh_ModifyWagh(faction_name, "wh2_dlc15_resource_factor_waaagh_other", add_waaagh);
	end
end

function Wagh_Started_AI(faction)
	local target_faction_key = "";
	local target_pos_x = 0;
	local target_pos_y = 0;
	local ritual_setup = cm:create_new_ritual_setup(faction, wagh_ritual_key)
	local war_factions = faction:factions_at_war_with();
	local ritual_target = ritual_setup:target();
	local unique_war_factions = unique_table:faction_list_to_unique_table(war_factions);
	local possible_factions = unique_war_factions:to_table();
	
	-- Find and set target region
	if #possible_factions > 0 then
		local rand = cm:random_number(#possible_factions);
		target_faction_key = possible_factions[rand];
		local target_faction = cm:model():world():faction_by_key(target_faction_key);

		
		--- for some reason "has_home_region" can return true even if the home region is null interface, so check directly if it's null
		if target_faction:home_region():is_null_interface() then
			return
		end

		local home_region = target_faction:home_region()
		local settlement = home_region:settlement();
		target_pos_x = settlement:logical_position_x();
		target_pos_y = settlement:logical_position_y();

		if ritual_target:is_region_valid_target(home_region) then
			ritual_target:set_target_region(home_region);
			out.design("####### Target record key is: ".. ritual_target:get_target_region():name())
		end
		
	end

	-- Fire the ritual with above setup
	if ritual_target:valid() == true then
		cm:perform_ritual_with_setup(ritual_setup);
		local event_pic = 1313;
		local human_factions = cm:get_human_factions();
		local title = "";
		local description = "";

		if faction:name() == "wh_main_grn_greenskins" then
			title = event_messages_greenskins.title
			description = event_messages_greenskins.description
		elseif faction:name() == "wh_main_grn_crooked_moon" then
			title = event_messages_crooked_moon.title
			description = event_messages_crooked_moon.description
		elseif faction:name() == "wh_main_grn_orcs_of_the_bloody_hand" then
			title = event_messages_orcs_of_the_bloody_hand.title
			description = event_messages_orcs_of_the_bloody_hand.description
		elseif faction:name() == "wh2_dlc15_grn_broken_axe" then
			title = event_messages_broken_axe.title
			description = event_messages_broken_axe.description
		elseif faction:name() == "wh2_dlc15_grn_bonerattlaz" then
			title = event_messages_bonerattlaz.title
			description = event_messages_bonerattlaz.description
		end

		-- Tell the target
		for i = 1, #human_factions do
			cm:show_message_event_located(
				human_factions[i],
				title,
				"regions_onscreen_"..ritual_target:get_target_region():name(),
				description,
				target_pos_x, 
				target_pos_y,
				true,
				event_pic
			);
		end;
	end

	if ritual_target:valid() == true then
		ai_ritual_region_key = ritual_target:get_target_region():name()
	end

	-- Add Waaagh VFX for AI
	local region = ritual_target:get_target_region():name()
	local comp_scene = "wagh_ai_"..region
	local scene_type = wagh_composite_scene;
	local settlement = "settlement:"..region;

	out.design("### WAAAGH! started adding VFX "..comp_scene)
	cm:add_scripted_composite_scene_to_settlement(comp_scene, scene_type, settlement, 0, 0, false, true, true);
end

function Wagh_Ended_AI(context)
	local human_factions = cm:get_human_factions();
	local faction = context:performing_faction():name()
	local current_ritual_region_owner = cm:get_region(ai_ritual_region_key):owning_faction():name()

	-- Set Waaagh to 0
	Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_triggered", wagh_ended)

	for i = 1, #human_factions do
		if current_ritual_region_owner == faction then
			-- trigger successful WAAAGH event
			cm:trigger_incident(human_factions[i],"wh_main_incident_grn_waaagh_ai_success", true)
			Wagh_ModifyWagh(faction, "wh2_dlc15_resource_factor_waaagh_success", 50)
		else
			-- trigger fail WAAAGH event
			cm:trigger_incident(human_factions[i],"wh_main_incident_grn_waaagh_ai_failed", true)
		end
	end;

	-- Remove Waaagh VFX for AI
	local comp_scene = "wagh_ai_"..ai_ritual_region_key
	out.design("### WAAAGH! ended removing VFX "..comp_scene)
	cm:remove_scripted_composite_scene(comp_scene);
	ai_ritual_region_key = "";
end


function Wagh_BattleCompleted(context)
	local attacker_result = cm:model():pending_battle():attacker_battle_result();
	local defender_result = cm:model():pending_battle():defender_battle_result();
	local attacker_won = (attacker_result == "heroic_victory") or (attacker_result == "decisive_victory") or (attacker_result == "close_victory") or (attacker_result == "pyrrhic_victory");
	local defender_won = (defender_result == "heroic_victory") or (defender_result == "decisive_victory") or (defender_result == "close_victory") or (defender_result == "pyrrhic_victory");
	local attacker_value = cm:pending_battle_cache_attacker_value();
	local defender_value = cm:pending_battle_cache_defender_value();
	local already_awarded = {};
	local attacker_multiplier = defender_value / attacker_value;
	attacker_multiplier = math.clamp(attacker_multiplier, 0.5, 1.5);
	local attacker_wagh = (defender_value / 10) * attacker_multiplier;
	local kill_ratio_attacker = cm:model():pending_battle():percentage_of_defender_killed();
	attacker_wagh = attacker_wagh * kill_ratio_attacker;
	local defender_multiplier = attacker_value / defender_value;
	defender_multiplier = math.clamp(defender_multiplier, 0.5, 1.5);
	local defender_wagh = (attacker_value / 10) * defender_multiplier;
	local kill_ratio_defender = cm:model():pending_battle():percentage_of_attacker_killed();
	defender_wagh = defender_wagh * kill_ratio_defender;
	local rebels = false;
	local human_attacker = "";
	local human_defender = "";
	local turn = cm:model():turn_number();

	if turn > 100 then
		wagh_battle_cap = wagh_battle_cap - 1
	elseif turn > 150 then
		wagh_battle_cap = wagh_battle_cap - 2
	end

	-- Find if rebels or humans are part of the battle
	for i = 1, cm:pending_battle_cache_num_attackers() do
		local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);
		local attacker = cm:model():world():faction_by_key(attacker_name);

		if attacker_name == "rebels" then
			rebels = true;
		elseif attacker:is_human() then
			human_attacker = attacker:name();
		end
	end

	for i = 1, cm:pending_battle_cache_num_defenders() do
		local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);
		local defender = cm:model():world():faction_by_key(defender_name);

		if defender_name == "rebels" then
			rebels = true;
		elseif defender:is_human() then
			human_defender = defender:name();
		end
	end

	-- Waaagh inactive, add waaagh resource for battles
	if rebels == false then
		for i = 1, cm:pending_battle_cache_num_attackers() do
			local attacker_cqi, attacker_force_cqi, attacker_name = cm:pending_battle_cache_get_attacker(i);
			local faction_object = cm:get_faction(attacker_name);
			
			if already_awarded[attacker_name] == nil then
				if faction_object:subculture() == greenskin then
					local wagh_reward = attacker_wagh * wagh_battle_mod;

					if wagh_reward > wagh_battle_cap then
						wagh_reward = wagh_battle_cap;
					end
					Wagh_ModifyWagh(attacker_name, "wh2_dlc15_resource_factor_waaagh_battle_other", wagh_reward);
					already_awarded[attacker_name] = true;
					Wagh_PrintBattle(attacker_name, wagh_reward, attacker_value, defender_value, attacker_multiplier, kill_ratio_attacker);

					-- Check pooled resource for Advice trigger
					if faction_object:pooled_resource("grn_waaagh"):value() == 100 and faction_object:is_human()  then
						core:trigger_event("ScriptEventWaghResourceMax")
					end
				end
			end
		end

		for i = 1, cm:pending_battle_cache_num_defenders() do
			local defender_cqi, defender_force_cqi, defender_name = cm:pending_battle_cache_get_defender(i);
			local faction_object = cm:get_faction(defender_name);
			
			if already_awarded[defender_name] == nil then
				if faction_object:subculture() == greenskin then
					local wagh_reward = defender_wagh * wagh_battle_mod;
					if wagh_reward > wagh_battle_cap then
						wagh_reward = wagh_battle_cap;
					end
					Wagh_ModifyWagh(defender_name, "wh2_dlc15_resource_factor_waaagh_battle_other", wagh_reward);
					already_awarded[defender_name] = true;
					Wagh_PrintBattle(defender_name, wagh_reward, attacker_value, defender_value, defender_multiplier, kill_ratio_defender);

					-- Check pooled resource for Advice trigger
					if faction_object:pooled_resource("grn_waaagh"):value() == 100 and faction_object:is_human() then
						core:trigger_event("ScriptEventWaghResourceMax")
					end
				end
			end
		end

		core:trigger_event("ScriptEventWaghBattle");
	end
end

function Wagh_ModifyWagh(faction, factor, amount)
	cm:faction_add_pooled_resource(faction, "grn_waaagh", factor, amount);
end

function Wagh_SelectUnit(units)
	local rand = cm:random_number(#units);
	selected_unit = units[rand];
	return selected_unit
end

function Wagh_PrintBattle(faction, wagh_amount, aval, dval, bonus_mult, kill_ratio)
	wagh_amount = tonumber(string.format("%.0f", wagh_amount));
	out.design("--------------------------------------------");
	out.design("Waaagh Battle Fought");
	out.design("\tFaction: "..faction);
	out.design("\tWaaagh: "..wagh_amount);
	out.design("\t\tAttacker Value: "..aval);
	out.design("\t\tDefender Value: "..dval);
	out.design("\t\tStrength Ratio: "..bonus_mult);
	out.design("\t\tKill Ratio: "..kill_ratio);
	out.design("--------------------------------------------");
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------

cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("wagh_state", wagh_state, context);
		cm:save_named_value("reward_level", reward_level, context);
		cm:save_named_value("reward_culture", reward_culture, context);
		cm:save_named_value("previous_reward_level", previous_reward_level, context);
		cm:save_named_value("previous_reward_culture", previous_reward_culture, context);
		cm:save_named_value("gork_counter", gork_counter, context);
		cm:save_named_value("mork_counter", mork_counter, context);
		cm:save_named_value("wagh_ai_counter", wagh_ai_counter, context);
		cm:save_named_value("ritual_region_key", ritual_region_key, context);
		cm:save_named_value("ai_ritual_region_key", ai_ritual_region_key, context);
		cm:save_named_value("wagh_ai_state", wagh_ai_state, context);	
		cm:save_named_value("wagh_success", wagh_success, context);
		cm:save_named_value("wagh_god", wagh_god, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			wagh_state = cm:load_named_value("wagh_state", wagh_state, context);
			reward_level = cm:load_named_value("reward_level", reward_level, context);
			reward_culture = cm:load_named_value("reward_culture", reward_culture, context);
			previous_reward_level = cm:load_named_value("previous_reward_level", previous_reward_level, context);
			previous_reward_culture = cm:load_named_value("previous_reward_culture", previous_reward_culture, context);
			gork_counter = cm:load_named_value("gork_counter", gork_counter, context);
			mork_counter = cm:load_named_value("mork_counter", mork_counter, context);
			wagh_ai_counter = cm:load_named_value("wagh_ai_counter", wagh_ai_counter, context);
			ritual_region_key = cm:load_named_value("ritual_region_key", ritual_region_key, context);
			ai_ritual_region_key = cm:load_named_value("ai_ritual_region_key", ai_ritual_region_key, context);
			wagh_ai_state = cm:load_named_value("wagh_ai_state", wagh_ai_state, context);
			wagh_success = cm:load_named_value("wagh_success", wagh_success, context);
			wagh_god = cm:load_named_value("wagh_god", wagh_god, context);
		end
	end
);