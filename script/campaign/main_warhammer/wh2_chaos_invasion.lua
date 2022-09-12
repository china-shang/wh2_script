CI_DEBUG = false;
CI_EVENTS = {
	{key = "INTRO", required_stage = 0, first_turn = 15, last_turn = 25, army_spawns = 0, agent_spawns = 0, chaos_effect = ""},
	{key = "MID_GAME", required_stage = 1, first_turn = 90, last_turn = 95, army_spawns = 4, agent_spawns = 5, chaos_effect = "rises"}, -- rises
	{key = "END_GAME", required_stage = 2, first_turn = 140, last_turn = 145, army_spawns = 8, agent_spawns = 3, chaos_effect = ""}, -- invasion
	{key = "END_GAME", required_stage = 3, first_turn = 160, last_turn = 165, army_spawns = 12, agent_spawns = 6, chaos_effect = ""}, -- invasion
	{key = "END_GAME", required_stage = 4, first_turn = 180, last_turn = 185, army_spawns = 3, agent_spawns = 2, chaos_effect = ""}, -- invasion
	{key = "VICTORY", required_stage = -1, first_turn = -1, last_turn = -1, army_spawns = 0, agent_spawns = 0, chaos_effect = ""}
};
SEL = nil
KILLING = nil
CI_CHAOS_CHARACTERS = {
	["archaon"] = {
		["id"] = "archaon",
		["agent_subtype"] = "chs_archaon",
		["forename"] = "names_name_2147343903",
		["family_name"] = "names_name_2147357364",
		["faction_leader"] = true,
		["immortal"] = true,
		["force"] = "",
		["force_xp"] = 9,
		["effect"] = "wh_main_bundle_military_upkeep_free_force_unbreakable",
		["spawn_pos_center"] = {x = 775, y = 609}
	},
	["kholek"] = {
		["id"] = "kholek",
		["agent_subtype"] = "chs_kholek_suneater",
		["forename"] = "names_name_2147345931",
		["family_name"] = "names_name_2147345934",
		["faction_leader"] = false,
		["immortal"] = true,
		["force"] = "",
		["force_xp"] = 9,
		["effect"] = "wh_main_bundle_military_upkeep_free_force_unbreakable",
		["spawn_pos_center"] = {x = 780, y = 611}
	},
	["sigvald"] = {
		["id"] = "sigvald",
		["agent_subtype"] = "chs_prince_sigvald",
		["forename"] = "names_name_2147345922",
		["family_name"] = "names_name_2147357370",
		["faction_leader"] = false,
		["immortal"] = true,
		["force"] = "",
		["force_xp"] = 9,
		["effect"] = "wh_main_bundle_military_upkeep_free_force_unbreakable",
		["spawn_pos_center"] = {x = 770, y = 611}
	},
	["sarthorael"] = {
		["id"] = "sarthorael",
		["agent_subtype"] = "chs_lord_of_change",
		["forename"] = "names_name_2147357518",
		["family_name"] = "names_name_2147357523",
		["faction_leader"] = false,
		["immortal"] = true,
		["force"] = "",
		["force_xp"] = 9,
		["effect"] = "wh_main_bundle_military_upkeep_free_force_unbreakable",
		["spawn_pos_center"] = {x = 766, y = 657}
	}
};
CI_CHAOS_AGENTS = {
	agent_types = {
		{agent = "wizard", subtype = "chs_sorcerer_fire", weight = 1},
		{agent = "wizard", subtype = "chs_sorcerer_metal", weight = 1},
		{agent = "wizard", subtype = "chs_sorcerer_death", weight = 1},
		{agent = "champion", subtype = "chs_exalted_hero", weight = 3}
	},
	positions = {
		{487, 438},	{516, 428},	{503, 483},	{681, 352},	{751, 358},	{687, 334},	{738, 311}, {704, 283}, {755, 278},
		{671, 411},	{673, 446},	{647, 394},	{496, 520},	{680, 532},	{542, 372},	{412, 399},	{652, 257}
	}
};
CI_CHAOS_ARMY_SPAWNS = {
	faction_key = "wh_main_chs_chaos",
	effect_bundle = "wh_main_bundle_military_upkeep_free_force",
	-- buildings = {"wh_main_horde_chaos_settlement_3", "wh_main_horde_chaos_warriors_2", "wh_main_horde_chaos_forge_1"},
	buildings = {"wh_main_horde_chaos_settlement_5",	"wh_main_horde_chaos_warriors_3", "wh_main_horde_chaos_trolls_1", "wh_main_horde_chaos_magic_2", "wh_main_horde_chaos_knights_2", "wh_main_horde_chaos_dragon_ogres_2", "wh_main_horde_chaos_giants_1", "wh_main_horde_chaos_marauders_3"},
	invasions = {
		{
			key = "chaos_wastes",
			positions = {
				{775, 609+5}, {770, 611+5}, {780, 611+5},
				{775, 609+10}, {770, 611+10}, {780, 611+10},
				{775, 609+15}, {770, 611+15}, {780, 611+15},
				{775, 609+20}, {770, 611+20}, {780, 611+20},
				{775, 609+25}, {770, 611+25}, {780, 611+25}
			}
		},
		{
			key = "naggaroth",
			positions = {
				{49, 712}, {91, 712}, {130, 711}, {172, 713}, {213, 710}
			}
		}
	}
};
CI_BEASTMEN_ARMY_SPAWNS = {
	faction_key = "wh_dlc03_bst_beastmen_chaos",
	effect_bundle = "wh_main_bundle_military_upkeep_free_force",
	buildings = {"wh_dlc03_horde_beastmen_herd_5", "wh_dlc03_horde_beastmen_gors_3", "wh_dlc03_horde_beastmen_minotaurs_1"},
	army_count = 1,
	positions = {
		{788, 605}
	}
};
CI_NORSCA_ARMY_SPAWNS = {
	faction_key = "wh_main_nor_bjornling",
	effect_bundle = "wh_main_bundle_military_upkeep_free_force",
	army_count = 4,
	positions = {
		{630, 680},	{697, 659}, {588, 708}, {540, 698}, {520, 693}, {494, 675}, {411, 673}, {374, 644},
		{420, 625}, {447, 639}, {519, 662}, {589, 688}, {495, 635}, {437, 610},
		{504, 609}, {448, 589}, {377, 565}
	}
};
CI_DATA = {
	CI_LAST_UPDATE = -1,
	CI_INVASION_STAGE = 0,
	CI_SETTING = 2,
	CI_RAZED_REGIONS = 0,
	CI_LAST_EFFECT = "",
	CI_AUTORUN = false,
	CI_EARLY_TURNS = 0,
	CI_EXTRA_ARMIES = 0
};

CI_EXTRA_DATA = {
	CI_END_STAGE = 0
}

CI_ARMY_SETTINGS = {
	{key = "Off", multiplier = 2},
	{key = "On", multiplier = 2},
	{key = "Hard", multiplier = 4},
	{key = "Very Hard", multiplier = 6},
	{key = "Legendary", multiplier = 2}
};

function CI_setup()
	out.chaos("CI_setup()");
	out.inc_tab("chaos");

	if cm:get_local_faction_name(true) then
		CI_DATA.CI_AUTORUN = false;
	else
		out.chaos("Autorun detected!");
		CI_DATA.CI_AUTORUN = true;
	end

	if CI_DATA.CI_AUTORUN == false then
		if cm:is_multiplayer() == false then
			local human_norscan = false;
			local human_factions = cm:get_human_factions();
			local player_faction = cm:model():world():faction_by_key(human_factions[1]);

			if player_faction:subculture() == "wh_main_sc_nor_norsca" then
				human_norscan = true;
			end
			
			if human_norscan == true then
				out.chaos("Aborting Chaos invasion script, a player is Norsca!");
				out.dec_tab("chaos");
				Setup_Norsca_Chaos_Invasion();
				return;
			end
		end

		if cm:is_new_game() == true then
			if cm:is_multiplayer() == false then
				out.chaos("Reading Singleplayer Chaos Setting");
				local shared_states_manager = cm:model():shared_states_manager();
				local chaos_setting_value = shared_states_manager:get_state_as_float_value("ChaosInvasion");
				CI_DATA.CI_SETTING = chaos_setting_value + 1;
			else
				out.chaos("Defaulting Multiplayer Chaos Setting");
				CI_DATA.CI_SETTING = 2;
			end
		end
		out.chaos("Frontend Setting: "..tostring(CI_ARMY_SETTINGS[CI_DATA.CI_SETTING].key).." ("..tostring(CI_DATA.CI_SETTING)..")");
	else
		if cm:is_new_game() == true then
			out.chaos("Reading Autorun Chaos Setting");
			local shared_states_manager = cm:model():shared_states_manager();
			local chaos_setting_value = shared_states_manager:get_state_as_float_value("ChaosInvasion");
			CI_DATA.CI_SETTING = chaos_setting_value + 1;
			out.chaos("Preferences Setting: "..tostring(CI_ARMY_SETTINGS[CI_DATA.CI_SETTING].key).." ("..tostring(CI_DATA.CI_SETTING)..")");
		end
	end

	local chaos_faction = cm:model():world():faction_by_key(CI_CHAOS_ARMY_SPAWNS.faction_key);
	
	CI_debug_setup();
	if chaos_faction:is_human() == false then
		CI_setup_armies();
		
		if cm:is_new_game() == true then
			cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");
			
			out.chaos("Killing Archaon! - '"..chaos_faction:faction_leader():command_queue_index().."'");
			cm:set_character_immortality("character_cqi:"..chaos_faction:faction_leader():command_queue_index(), false);
			cm:kill_character(chaos_faction:faction_leader():command_queue_index(), true, false);
			
			cm:callback(function()
				cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "");
			end, 1);
		end

		if CI_DATA.CI_SETTING >= 1 then
			out.chaos("Creating Script Listeners");
			out.chaos(CI_DATA.CI_SETTING);
			-- character selected
			core:add_listener(
				"killKey",
				"ShortcutPressed",
				function(context)
					out("ShortcutPressed event occurred, context.string is " .. context.string);
					return context.string == "script_ctrl_F4"
				end,
				function(context)
					if is_nil(SEL) then
						out("SEL NIL")
						return
					end
					if not is_nil(KILLING) then
						out("KILLING NOT NULL")
						return
					end
					KILLING = SEL;
					SEL = nil;
					local character = KILLING;
					out("select Character will kill, forename " .. tostring(character:get_forename()) .. ", surname " .. tostring(character:get_surname()) .. ", position [" .. character:logical_position_x() .. ", " .. character:logical_position_y() .. "], faction " .. character:faction():name() .. ", cqi " .. tostring(character:cqi()));
					cm:set_character_immortality("character_cqi:"..character:command_queue_index(), false);
					cm:kill_character(character:command_queue_index(), true);
					out.ui("Character killed, forename " .. tostring(character:get_forename()) .. ", surname " .. tostring(character:get_surname()) .. ", position [" .. character:logical_position_x() .. ", " .. character:logical_position_y() .. "], faction " .. character:faction():name() .. ", cqi " .. tostring(character:cqi()));
					KILLING = nil
				end,
				true
			);
			core:add_listener(
				"campaign_selection_listener2",
				"CharacterSelected",
				true,
				function(context)
					SEL = context:character();
				end,
				true
			);
			core:add_listener(
				"CI_FactionTurnStart",
				"FactionTurnStart",
				true,
				function(context) CI_FactionTurnStart(context) end,
				true
			);
			core:add_listener(
				"CI_CharacterRazedSettlement",
				"CharacterRazedSettlement",
				true,
				function(context) CI_CharacterRazedSettlement(context) end,
				true
			);
			core:add_listener(
				"CI_CharacterConvalescedOrKilled",
				"CharacterConvalescedOrKilled",
				true,
				function(context) CI_CharacterConvalescedOrKilled(context) end,
				true
			);
		else
			out.chaos("Disabling Chaos Invasion! (Off Setting)");
			cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_spawned", true);
			cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_spawned", true);
			cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_defeated", true);
			cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_defeated", true);
		end
	else
		out.chaos("Disabling Chaos Invasion! (Human Chaos)");
	end
	out.dec_tab("chaos");
end

function CI_FactionTurnStart(context)
	if context:faction():is_human() == true or CI_DATA.CI_AUTORUN == true then
		local turn_number = cm:model():turn_number();

		if CI_DATA.CI_LAST_UPDATE < turn_number then
			out.chaos("Chaos Event Update : Turn "..turn_number);
			out.inc_tab("chaos");
			CI_DATA.CI_LAST_UPDATE = turn_number;

			for i = 1, #CI_EVENTS do
				if CI_EVENTS[i].required_stage == CI_DATA.CI_INVASION_STAGE then
					local turn_min = CI_EVENTS[i].first_turn;
					local turn_max = CI_EVENTS[i].last_turn;

					if CI_EVENTS[i].key == "END_GAME" then
						CI_DATA.CI_EARLY_TURNS = CI_DATA.CI_EARLY_TURNS or 0; -- Savegame compatibility
						turn_min = turn_min - CI_DATA.CI_EARLY_TURNS;
						turn_max = turn_max - CI_DATA.CI_EARLY_TURNS;
					end

					local chance = ((turn_number - turn_min) / (turn_max - turn_min)) * 100;

					out.chaos("Next Event: "..CI_EVENTS[i].key);
					out.chaos("\tFirst Possible Turn: "..turn_min);
					out.chaos("\tLast Possible Turn: "..turn_max);
					out.chaos("\tTurns Early: "..CI_DATA.CI_EARLY_TURNS);
					out.chaos("\tCurrent Chance: "..chance.."%");

					if chance > 0 then
						if cm:model():random_percent(chance) then
							out.chaos("\t\tSuccess!");
							if CI_EVENTS[i].key == "INTRO" then
								CI_Event_1_Intro(CI_EVENTS[i]);
							elseif CI_EVENTS[i].key == "MID_GAME" then
								CI_Event_2_MidGame(CI_EVENTS[i]);
							elseif CI_EVENTS[i].key == "END_GAME" then
								CI_Event_3_EndGame(CI_EVENTS[i]);
							end
							break;
						else
							out.chaos("\t\tFailed!");
						end
					end
				end
			end
		end
	end
	out.dec_tab("chaos");
end

function CI_CharacterRazedSettlement(context)
	if CI_DATA.CI_INVASION_STAGE == 3 then
		local faction = context:character():faction();
		local faction_key = faction:name();

		if faction_key == CI_CHAOS_ARMY_SPAWNS.faction_key or faction_key == CI_BEASTMEN_ARMY_SPAWNS.faction_key or faction_key == CI_NORSCA_ARMY_SPAWNS.faction_key then
			CI_DATA.CI_RAZED_REGIONS = CI_DATA.CI_RAZED_REGIONS + 2;
			CI_invasion_effect_bundle_update();
		end
	end
end

function CI_CharacterConvalescedOrKilled(context)
	out("killed some thing")
	if CI_DATA.CI_INVASION_STAGE >= 3 then
		local character = context:character();
		local faction = character:faction();

		if faction:name() == CI_CHAOS_ARMY_SPAWNS.faction_key then
			if (character:character_subtype("chs_archaon") == true and character:is_faction_leader() == true) or 
					character:character_subtype("chs_kholek_suneater") == true or 
					character:character_subtype("chs_prince_sigvald") == true then

				local archaon, kholek, sigvald = CI_invasion_deaths();

				CI_invasion_effect_bundle_update();

				if archaon == 0 and kholek == 0 and sigvald == 0 then
					if CI_EXTRA_DATA.CI_END_STAGE >= 3 then
						CI_Event_4_Victory(CI_EVENTS[6]);
					end
					if CI_EXTRA_DATA.CI_END_STAGE < 3 then
						CI_Event_3_EndGame(CI_EVENTS[3 + CI_EXTRA_DATA.CI_END_STAGE])
					end
				end
			end
		end
	end
end

function CI_Event_1_Intro(event)
	out.chaos("CI_Event_1_Intro()");
	out.inc_tab("chaos");
	CI_DATA.CI_INVASION_STAGE = 1;
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		cm:show_message_event(
			human_factions[i],
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_early_primary_detail",
			"",
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_early_secondary_detail",
			true, 29
		);
		out.chaos("Showing Chaos Event : "..human_factions[i]);
	end

	CI_apply_chaos_corruption(event.chaos_effect);
	out.dec_tab("chaos");
end

function CI_Event_2_MidGame(event)
	out.chaos("CI_Event_2_MidGame()");
	out.inc_tab("chaos");
	CI_DATA.CI_INVASION_STAGE = 2;
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		cm:show_message_event_located(
			human_factions[i],
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_mid_primary_detail",
			"",
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_mid_secondary_detail",
			CI_CHAOS_CHARACTERS["archaon"]["spawn_pos_center"].x,
			CI_CHAOS_CHARACTERS["archaon"]["spawn_pos_center"].y,
			true, 30
		);
		out.chaos("Showing Chaos Event : "..human_factions[i]);
		cm:make_region_visible_in_shroud(human_factions[i], "wh_main_chaos_wastes");
	end

	CI_spawn_chaos(event.army_spawns);
	CI_spawn_agents(event.agent_spawns);
	CI_declare_war(CI_CHAOS_ARMY_SPAWNS.faction_key);
	CI_apply_chaos_corruption(event.chaos_effect);
	CI_personality_swap(2);
	cm:set_camera_position(518.37, 473.95, 10.83, 0.0, 11.30);
	out.dec_tab("chaos");
end

function CI_Event_3_EndGame(event)
	out.chaos("CI_Event_3_EndGame()");
	out.inc_tab("chaos");
	CI_DATA.CI_INVASION_STAGE = CI_DATA.CI_INVASION_STAGE + 1;
	CI_EXTRA_DATA.CI_END_STAGE = CI_EXTRA_DATA.CI_END_STAGE + 1;
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		cm:show_message_event_located(
			human_factions[i],
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_end_primary_detail",
			"",
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_end_secondary_detail",
			CI_CHAOS_CHARACTERS["archaon"]["spawn_pos_center"].x,
			CI_CHAOS_CHARACTERS["archaon"]["spawn_pos_center"].y,
			true, 31
		);
		out.chaos("Showing Chaos Event : "..human_factions[i]);
		cm:make_region_visible_in_shroud(human_factions[i], "wh_main_chaos_wastes");
	end

	-- CI_spawn_unique_characters();

	out.chaos("CI_spawn_unique_characters()");
	out.inc_tab("chaos");
	if CI_EXTRA_DATA.CI_END_STAGE == 1 then
		CI_spawn_character(CI_CHAOS_CHARACTERS["kholek"]);
		out.chaos("Spawned Kholek");
	end
	if CI_EXTRA_DATA.CI_END_STAGE == 2 then
		CI_spawn_character(CI_CHAOS_CHARACTERS["archaon"]);
		out.chaos("Spawned Archaon");
		CI_spawn_character(CI_CHAOS_CHARACTERS["sarthorael"]);
		out.chaos("Spawned Sarthorael");
		cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_spawned", true);
		cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_spawned", true);
	end
	if CI_EXTRA_DATA.CI_END_STAGE == 3 then
		CI_spawn_character(CI_CHAOS_CHARACTERS["sigvald"]);
		out.chaos("Spawned Sigvald");
	end
	out.dec_tab("chaos");

	CI_spawn_chaos(event.army_spawns);
	CI_spawn_agents(event.agent_spawns);
	CI_declare_war(CI_CHAOS_ARMY_SPAWNS.faction_key);
	CI_apply_chaos_corruption(event.chaos_effect);
	CI_personality_swap(3);
	CI_spawn_norsca();
	CI_spawn_beastmen();
	CI_invasion_effect_bundle_update();
	
	if CI_EXTRA_DATA.CI_END_STAGE == 2 then
		cm:register_instant_movie("Warhammer/chs_rises");
	end
	cm:set_camera_position(518.37, 473.95, 10.83, 0.0, 11.30);
	out.dec_tab("chaos");
end

function CI_Event_4_Victory(event)
	out.chaos("CI_Event_4_Victory()");
	out.inc_tab("chaos");
	CI_DATA.CI_INVASION_STAGE = 4;

	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		cm:show_message_event(
			human_factions[i],
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_defeated_primary_detail",
			"",
			"event_feed_strings_text_wh_event_feed_string_scripted_event_chaos_invasion_defeated_secondary_detail",
			true, 35
		);
		cm:remove_effect_bundle("wh2_main_bundle_chaos_invasion", human_factions[i]);
		out.chaos("Showing Chaos Event : "..human_factions[i]);
	end
	
	local region_list = cm:model():world():region_manager():region_list();

	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		local region_key = current_region:name();

		if current_region:is_province_capital() == true then
			cm:remove_effect_bundle_from_region("wh2_main_bundle_chaos_invasion_region", region_key);
		end
	end

	local chaos_faction = cm:model():world():faction_by_key(CI_CHAOS_ARMY_SPAWNS.faction_key);
	local chaos_force_list = chaos_faction:military_force_list();
	
	for i = 0, chaos_force_list:num_items() - 1 do
		local force = chaos_force_list:item_at(i);

		if force:has_general() == true then
			local force_cqi = force:general_character():command_queue_index();
			cm:kill_character(force_cqi, true, true);
		end
	end
	
	cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_spawned", true);
	cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_spawned", true);

	cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_defeated", true);
	cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_defeated", true);

	CI_apply_chaos_corruption(event.chaos_effect);
	CI_personality_swap(4);
	out.dec_tab("chaos");
end

function CI_spawn_unique_characters()
	out.chaos("CI_spawn_unique_characters()");
	out.inc_tab("chaos");
	CI_spawn_character(CI_CHAOS_CHARACTERS["archaon"]);
	out.chaos("Spawned Archaon");
	CI_spawn_character(CI_CHAOS_CHARACTERS["sigvald"]);
	out.chaos("Spawned Sigvald");
	CI_spawn_character(CI_CHAOS_CHARACTERS["kholek"]);
	out.chaos("Spawned Kholek");
	CI_spawn_character(CI_CHAOS_CHARACTERS["sarthorael"]);
	out.chaos("Spawned Sarthorael");
	out.dec_tab("chaos");
	
	cm:complete_scripted_mission_objective("wh_main_short_victory", "archaon_spawned", true);
	cm:complete_scripted_mission_objective("wh_main_long_victory", "archaon_spawned", true);
end

function CI_spawn_character(char_details)
	local invasion_key = "CI_"..char_details["id"];
	local spawn_pos = char_details["spawn_pos_center"];

	local x, y = cm:find_valid_spawn_location_for_character_from_position(CI_CHAOS_ARMY_SPAWNS.faction_key, spawn_pos.x, spawn_pos.y, true);

	if x > -1 and y > -1 then
		local chaos_invasion = invasion_manager:new_invasion(invasion_key, CI_CHAOS_ARMY_SPAWNS.faction_key, char_details["force"], {x, y});
		chaos_invasion:create_general(
			char_details["faction_leader"], char_details["agent_subtype"],
			char_details["forename"], "", char_details["family_name"], ""
		);
		chaos_invasion:set_general_immortal(char_details["immortal"]);
		chaos_invasion:add_character_experience(40, true);
		chaos_invasion:apply_effect(char_details["effect"], 0);
		
		if char_details["force_xp"] > 0 then
			chaos_invasion:add_unit_experience(char_details["force_xp"]);
		else
			local xp = CI_army_xp();
			if xp > 0 then
					chaos_invasion:add_unit_experience(xp);
				end
			end
		
		chaos_invasion:start_invasion(
		function(self)
			local force = self:get_force();
			local force_cqi = force:command_queue_index();
			cm:add_building_to_force(force_cqi, CI_CHAOS_ARMY_SPAWNS.buildings);
		end);
	end
end

function CI_spawn_chaos(num_armies)
	out.chaos("CI_spawn_chaos("..tostring(num_armies)..")");
	if num_armies > 0 then
		local multiplier = CI_ARMY_SETTINGS[CI_DATA.CI_SETTING].multiplier;
		local num_armies_mod = num_armies * multiplier;
		num_armies_mod = math.ceil(num_armies_mod);
		CI_DATA.CI_EXTRA_ARMIES = CI_DATA.CI_EXTRA_ARMIES or 0; -- Savegame compatibility
		num_armies_mod = num_armies_mod + CI_DATA.CI_EXTRA_ARMIES;
		out.inc_tab("chaos");
		out.chaos("Army Count Modified: "..tostring(num_armies_mod).." (("..num_armies.." * "..multiplier..") + "..tostring(CI_DATA.CI_EXTRA_ARMIES)..")");

		for inv = 1, #CI_CHAOS_ARMY_SPAWNS.invasions do
			local position_key = CI_CHAOS_ARMY_SPAWNS.invasions[inv].key;
			local positions = {unpack(CI_CHAOS_ARMY_SPAWNS.invasions[inv].positions)};
			local pos_i = 1;
			out.chaos("Invasion Area: "..position_key);
			out.inc_tab("chaos");

			for i = 1, num_armies_mod do
				local temp_pos = positions[pos_i];
				pos_i = pos_i + 1;

				if pos_i > #positions then
					pos_i = 1;
				end

				local x, y = cm:find_valid_spawn_location_for_character_from_position(CI_CHAOS_ARMY_SPAWNS.faction_key, temp_pos[1], temp_pos[2], true);
			
				if x > -1 and y > -1 then
					local force = random_army_manager:generate_force("CI_chaos_high", 19, false);
					if CI_DATA.CI_INVASION_STAGE < 3 then
						force = random_army_manager:generate_force("CI_chaos", 19, false);
					end
					local turn_number = cm:model():turn_number();
					local invasion_key = "CI_chaos_"..position_key.."_T"..turn_number.."_"..core:get_unique_counter();
					local chaos_invasion = invasion_manager:new_invasion(invasion_key, CI_CHAOS_ARMY_SPAWNS.faction_key, force, {x, y});
					-- chaos_invasion:add_character_experience(19 * (CI_DATA.CI_INVASION_STAGE - 1), true);
					chaos_invasion:add_character_experience(13 + 6 * (CI_DATA.CI_INVASION_STAGE - 1), true);
					chaos_invasion:apply_effect(CI_CHAOS_ARMY_SPAWNS.effect_bundle, 0);
					
					local xp = CI_army_xp();
					if xp > 0 then
						if xp >= 6 then
							chaos_invasion:add_unit_experience(CI_DATA.CI_INVASION_STAGE * 3);
						else
							chaos_invasion:add_unit_experience(xp);
						end
					end
					
					chaos_invasion:start_invasion(
					function(self)
						local force = self:get_force();
						local force_cqi = force:command_queue_index();
						cm:add_building_to_force(force_cqi, CI_CHAOS_ARMY_SPAWNS.buildings);
					end);
					out.chaos("Spawned Chaos Army "..i.." ("..position_key..") ("..tostring(x).." / "..tostring(y)..")");
				else
					out.chaos("FAILED Chaos Army Spawn "..i.." ("..tostring(temp_pos[1]).." / "..tostring(temp_pos[2])..")");
				end
			end
			out.dec_tab("chaos");
		end
	end
	out.dec_tab("chaos");
end

function CI_spawn_norsca()
	out.chaos("CI_spawn_norsca("..tostring(CI_NORSCA_ARMY_SPAWNS.army_count)..")");
	out.inc_tab("chaos");
	if cm:is_multiplayer() == false then
		if CI_NORSCA_ARMY_SPAWNS.army_count > 0 then
			local positions = {unpack(CI_NORSCA_ARMY_SPAWNS.positions)};

			for i = 1, CI_NORSCA_ARMY_SPAWNS.army_count do
				local rand_pos = cm:random_number(#positions);
				local temp_pos = positions[rand_pos];
				local x, y = cm:find_valid_spawn_location_for_character_from_position(CI_NORSCA_ARMY_SPAWNS.faction_key, temp_pos[1], temp_pos[2], true);
			
				if x > -1 and y > -1 then
					local force = random_army_manager:generate_force("CI_norsca", 19, false);
					local invasion_key = "CI_norsca_"..core:get_unique_counter();
					local norsca_invasion = invasion_manager:new_invasion(invasion_key, CI_NORSCA_ARMY_SPAWNS.faction_key, force, {x, y});
					norsca_invasion:add_character_experience(30, true);
					norsca_invasion:apply_effect(CI_NORSCA_ARMY_SPAWNS.effect_bundle, 0);
					norsca_invasion:start_invasion();
					out.chaos("Spawned Norsca Army "..i.." ("..tostring(x).." / "..tostring(y)..")");
				else
					out.chaos("FAILED Norsca Army Spawn "..i.." ("..tostring(temp_pos[1]).." / "..tostring(temp_pos[2])..")");
				end
			end
			CI_declare_war(CI_NORSCA_ARMY_SPAWNS.faction_key);
		end
	end
	out.dec_tab("chaos");
end

function CI_spawn_beastmen()
	out.chaos("CI_spawn_beastmen("..tostring(CI_BEASTMEN_ARMY_SPAWNS.army_count)..")");
	out.inc_tab("chaos");
	if cm:is_multiplayer() == false then
		if CI_BEASTMEN_ARMY_SPAWNS.army_count > 0 then
			local positions = {unpack(CI_BEASTMEN_ARMY_SPAWNS.positions)};

			for i = 1, CI_BEASTMEN_ARMY_SPAWNS.army_count do
				local rand_pos = cm:random_number(#positions);
				local temp_pos = positions[rand_pos];
				local x, y = cm:find_valid_spawn_location_for_character_from_position(CI_BEASTMEN_ARMY_SPAWNS.faction_key, temp_pos[1], temp_pos[2], true);
			
				if x > -1 and y > -1 then
					local force = random_army_manager:generate_force("CI_beastmen", 19, false);
					local invasion_key = "CI_beastmen_"..core:get_unique_counter();
					local beastmen_invasion = invasion_manager:new_invasion(invasion_key, CI_BEASTMEN_ARMY_SPAWNS.faction_key, force, {x, y});
					beastmen_invasion:add_character_experience(30, true);
					beastmen_invasion:apply_effect(CI_BEASTMEN_ARMY_SPAWNS.effect_bundle, 0);
					beastmen_invasion:start_invasion(
					function(self)
						local force = self:get_force();
						local force_cqi = force:command_queue_index();
						cm:add_building_to_force(force_cqi, CI_BEASTMEN_ARMY_SPAWNS.buildings);
					end);
					out.chaos("Spawned Beastmen Army "..i.." ("..tostring(x).." / "..tostring(y)..")");
				else
					out.chaos("FAILED Beastmen Army Spawn "..i.." ("..tostring(temp_pos[1]).." / "..tostring(temp_pos[2])..")");
				end
			end
			CI_declare_war(CI_BEASTMEN_ARMY_SPAWNS.faction_key);
		end
	end
	out.dec_tab("chaos");
end

function CI_spawn_agents(num_agents)
	out.chaos("CI_spawn_agents("..tostring(num_agents)..")");
	out.inc_tab("chaos");
	if num_agents > 0 then
		local weighted_agents = weighted_list:new();
		local positions = {unpack(CI_CHAOS_AGENTS.positions)};

		for i = 1, #CI_CHAOS_AGENTS.agent_types do
			local agent = CI_CHAOS_AGENTS.agent_types[i];
			weighted_agents:add_item(agent, agent.weight);
		end

		for i = 1, num_agents do
			local selected_agent = weighted_agents:weighted_select();
			local rand_pos = cm:random_number(#positions);
			local temp_pos = positions[rand_pos];
			local x, y = cm:find_valid_spawn_location_for_character_from_position(CI_CHAOS_ARMY_SPAWNS.faction_key, temp_pos[1], temp_pos[2], true);

			if x > -1 and y > -1 then
				cm:create_agent(
					CI_CHAOS_ARMY_SPAWNS.faction_key,
					selected_agent.agent,
					selected_agent.subtype,
					x, y,
					false,
					function(cqi)
						cm:add_agent_experience("character_cqi:"..cqi, 30, true);
					end
				);
				out.chaos("Spawned Chaos Agent "..i.." ("..tostring(x).." / "..tostring(y)..")");
				table.remove(positions, rand_pos);
			else
				out.chaos("FAILED Chaos Agent Spawn "..i.." ("..tostring(temp_pos[1]).." / "..tostring(temp_pos[2])..")");
			end
		end
	end
	out.dec_tab("chaos");
end

function CI_apply_chaos_corruption(new_effect)
	if new_effect == "" and CI_DATA.CI_LAST_EFFECT == "" then
		return;
	end
	out.chaos("CI_apply_chaos_corruption()");
	out.inc_tab("chaos");

	local faction_effect_bundle = "wh_main_bundle_faction_chaos_"..new_effect;
	local region_effect_bundle = "wh_main_bundle_region_chaos_"..new_effect;
	local remove_faction_effect_bundle = "";
	local remove_region_effect_bundle = "";
	local last_effect = CI_DATA.CI_LAST_EFFECT;

	if last_effect ~= "" then
		remove_faction_effect_bundle = "wh_main_bundle_faction_chaos_"..last_effect;
		remove_region_effect_bundle = "wh_main_bundle_region_chaos_"..last_effect;
		out.chaos("Old Effects:");
		out.chaos("\tFaction: "..remove_faction_effect_bundle);
		out.chaos("\tRegion: "..remove_region_effect_bundle);
	end
	CI_DATA.CI_LAST_EFFECT = new_effect;

	if new_effect ~= "" then
		out.chaos("New Effects:");
		out.chaos("\tFaction: "..faction_effect_bundle);
		out.chaos("\tRegion: "..region_effect_bundle);
	end

	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:is_human() == true then
			local faction_key = current_faction:name();

			if current_faction:state_religion() == "wh_main_religion_chaos" then
				if last_effect ~= "" then
					cm:remove_effect_bundle(remove_faction_effect_bundle.."_good", faction_key);
				end
				if new_effect ~= "" then
					cm:apply_effect_bundle(faction_effect_bundle.."_good", faction_key, 0);
				end
			else
				if last_effect ~= "" then
					cm:remove_effect_bundle(remove_faction_effect_bundle, faction_key);
				end
				if new_effect ~= "" then
					cm:apply_effect_bundle(faction_effect_bundle, faction_key, 0);
				end
			end
		end
	end

	local region_list = cm:model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		local region_key = current_region:name();

		if current_region:is_province_capital() == true then
			if last_effect ~= "" then
				cm:remove_effect_bundle_from_region(remove_region_effect_bundle, region_key);
			end
			if new_effect ~= "" then
				cm:apply_effect_bundle_to_region(region_effect_bundle, region_key, 0);
			end
		end
	end
	out.dec_tab("chaos");
end

function CI_personality_swap(override)
	out.chaos("CI_personality_swap("..tostring(override)..")");
	local round_override = 0;
	
	if override == 2 then
		round_override = 30;
	elseif override == 3 then
		round_override = 100;
	elseif override == 4 then
		round_override = 150;
	end
	
	local faction_list = cm:model():world():faction_list();
	
	local skip_norsca = false;	
	
	if cm:get_faction("wh_dlc03_bst_beastmen"):is_human() == true and cm:is_multiplayer() == false then
		skip_norsca = true;
	end
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:is_human() == false then
			if skip_norsca == true and faction:subculture() == "wh_main_sc_nor_norsca" then
				break;
			end
			
			local faction_name = faction:name();
			
			if override then
				cm:cai_force_personality_change_with_override_round_number(faction_name, round_override);
			else
				cm:cai_force_personality_change(faction_name);
			end
		end
	end
	
	if override == 3 then
		local difficulty = ci_get_difficulty();
		local use_hard_personalities = false;
		local append = "allied";
		
		if (difficulty == 4 or difficulty == 5) and cm:is_multiplayer() == false then
			use_hard_personalities = true;
			append = "hard_allied";
		end
		
		local empire_personalities = {
			"wh_empire_default_allied",
			"wh_empire_subordinate_allied",
			"wh_empire_variant1_allied"
		};
		local empire_personalities_hard = {
			"wh_empire_default_hard_allied",
			"wh_empire_subordinate_hard_allied",
			"wh_empire_variant1_hard_allied"
		};
		local dwarfs_personalities = {
			"wh_dwarfs_default_allied",
			"wh_dwarfs_subordinate_allied",
			"wh_dwarfs_variant1_allied"
		};
		local dwarfs_personalities_hard = {
			"wh_dwarfs_default_hard_allied",
			"wh_dwarfs_subordinate_hard_allied",
			"wh_dwarfs_variant1_hard_allied"
		};
		local high_elves_personalities = {
			"wh2_highelf_allied",
			"wh2_highelf_defensive_allied",
			"wh2_highelf_internally_hostile_defensive_allied"
		};
		local high_elves_personalities_hard = {
			"wh2_highelf_hard_allied",
			"wh2_highelf_defensive_hard_allied",
			"wh2_highelf_internally_hostile_defensive_less_diplomatic_hard_allied"
		};
		local lizardmen_personalities = {
			"wh2_lizardmen_allied",
			"wh2_passive_straightforward_allied"
		};
		local lizardmen_personalities_hard = {
			"wh2_lizardmen_hard_allied",
			"wh2_passive_straightforward_hard_allied"
		};
		
		local faction_list = cm:model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local faction_name = faction:name();
			local faction_culture = faction:culture();
			
			if faction:is_human() == false then
				if faction_culture == "wh_main_emp_empire" or faction_culture == "wh_main_brt_bretonnia" then
					if faction_name == "wh_main_emp_empire" or faction_name == "wh_main_brt_bretonnia" then
						cm:force_change_cai_faction_personality(faction_name, "wh_empire_subjugator_"..append);
					elseif faction:subculture() == "wh_main_sc_teb_teb" or faction:subculture() == "wh_main_sc_ksl_kislev" then
						cm:force_change_cai_faction_personality(faction_name, "wh_teb_default_"..append);
					elseif use_hard_personalities == true then
						cm:force_change_cai_faction_personality(faction_name, empire_personalities_hard[cm:random_number(#empire_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction_name, empire_personalities[cm:random_number(#empire_personalities)]);
					end
				elseif faction_culture == "wh_main_dwf_dwarfs" then
					if faction_name == "wh_main_dwf_dwarfs" then
						cm:force_change_cai_faction_personality(faction_name, "wh_dwarfs_subjugator_"..append);
					elseif use_hard_personalities == true then
						cm:force_change_cai_faction_personality(faction_name, dwarfs_personalities_hard[cm:random_number(#dwarfs_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction_name, dwarfs_personalities[cm:random_number(#dwarfs_personalities)]);
					end
				elseif faction_culture == "wh2_main_hef_high_elves" then
					if faction_name == "wh2_main_hef_eataine" or faction_name == "wh2_main_hef_order_of_loremasters" then
						cm:force_change_cai_faction_personality(faction_name, "wh2_highelf_major_"..append);
					elseif use_hard_personalities == true then
						cm:force_change_cai_faction_personality(faction_name, high_elves_personalities_hard[cm:random_number(#high_elves_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction_name, high_elves_personalities[cm:random_number(#high_elves_personalities)]);
					end
				elseif faction_culture == "wh2_main_lzd_lizardmen" then
					if faction_name == "wh2_main_lzd_hexoatl" or faction_name == "wh2_main_lzd_last_defenders" then
						cm:force_change_cai_faction_personality(faction_name, "wh2_lizardmen_major_"..append);
					elseif use_hard_personalities == true then
						cm:force_change_cai_faction_personality(faction_name, lizardmen_personalities_hard[cm:random_number(#lizardmen_personalities_hard)]);
					else
						cm:force_change_cai_faction_personality(faction_name, lizardmen_personalities[cm:random_number(#lizardmen_personalities)]);
					end
				end
			end
		end
	end
end

function CI_kill_invasion()
	local chaos_faction = cm:model():world():faction_by_key(CI_CHAOS_ARMY_SPAWNS.faction_key);
	local archaon = 0;
	local kholek = 0;
	local sigvald = 0;
	local char_list = chaos_faction:character_list();
	out.chaos("Killing Archaon! - '"..chaos_faction:faction_leader():command_queue_index().."'");
	cm:set_character_immortality("character_cqi:"..chaos_faction:faction_leader():command_queue_index(), false);
	cm:kill_character(chaos_faction:faction_leader():command_queue_index(), true, false);
	out.chaos("Killing Archaon END! - '"..chaos_faction:faction_leader():command_queue_index().."'");
	
	for i = 0, char_list:num_items() - 1 do
		if current_char:character_subtype("chs_archaon") or current_char:character_subtype("chs_kholek_suneater") or current_char:character_subtype("chs_prince_sigvald") then
			if current_char:has_military_force() == true then
				if current_char:is_wounded() == false then
					if current_char:character_subtype("chs_archaon") == true and current_char:is_faction_leader() == true then
						archaon = 1;
						out.chaos("Killing Archaon! - '"..chaos_faction:faction_leader():command_queue_index().."'");
						cm:set_character_immortality("character_cqi:"..current_char:command_queue_index(), false);
						cm:kill_character(chaos_faction:faction_leader():command_queue_index(), true, false);
					elseif current_char:character_subtype("chs_kholek_suneater") == true  then
						kholek = 1;
						out.chaos("Killing kholek! - '"..current_char:command_queue_index().."'");
						cm:set_character_immortality("character_cqi:"..current_char:command_queue_index(), false);
						cm:kill_character(current_char:command_queue_index(), true, false);
					elseif current_char:character_subtype("chs_prince_sigvald") == true  then
						out.chaos("Killing sigvald! - '"..current_char:command_queue_index().."'");
						cm:set_character_immortality("character_cqi:"..current_char:command_queue_index(), false);
						cm:kill_character(current_char:command_queue_index(), true, false);
						sigvald = 1;
					end
				end
			end
		end
	end
	return archaon, kholek, sigvald;
end

function CI_invasion_deaths()
	local chaos_faction = cm:model():world():faction_by_key(CI_CHAOS_ARMY_SPAWNS.faction_key);
	local archaon = 0;
	local kholek = 0;
	local sigvald = 0;
	local char_list = chaos_faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);

		if current_char:character_subtype("chs_archaon") or current_char:character_subtype("chs_kholek_suneater") or current_char:character_subtype("chs_prince_sigvald") then
			if current_char:has_military_force() == true then
				if current_char:is_wounded() == false then
					if current_char:character_subtype("chs_archaon") == true and current_char:is_faction_leader() == true then
						archaon = 1;
					elseif current_char:character_subtype("chs_kholek_suneater") == true  then
						kholek = 1;
					elseif current_char:character_subtype("chs_prince_sigvald") == true  then
						sigvald = 1;
					end
				end
			end
		end
	end
	return archaon, kholek, sigvald;
end

function CI_invasion_effect_bundle_update()
	local chaos_corruption = 1 + (CI_DATA.CI_RAZED_REGIONS / 10);
	chaos_corruption = math.floor(chaos_corruption);

	local effect_bundle_faction = cm:create_new_custom_effect_bundle("wh2_main_bundle_chaos_invasion");
	effect_bundle_faction:add_effect("wh2_main_dummy_chaos_regions_razed", "faction_to_faction_own_unseen", CI_DATA.CI_RAZED_REGIONS);
	effect_bundle_faction:add_effect("wh_main_effect_religion_conversion_chaos_events_bad_dummy", "faction_to_province_own", chaos_corruption);
	effect_bundle_faction:set_duration(0);

	local archaon, kholek, sigvald = CI_invasion_deaths();

	if archaon == 1 then
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_archaon_alive", "faction_to_faction_own_unseen", 1);
	else
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_archaon_dead", "faction_to_faction_own_unseen", 1);
	end
	if kholek == 1 then
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_kholek_alive", "faction_to_faction_own_unseen", 1);
	else
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_kholek_dead", "faction_to_faction_own_unseen", 1);
	end
	if sigvald == 1 then
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_sigvald_alive", "faction_to_faction_own_unseen", 1);
	else
		effect_bundle_faction:add_effect("wh2_main_dummy_chaos_sigvald_dead", "faction_to_faction_own_unseen", 1);
	end
	
	local effect_bundle_region = cm:create_new_custom_effect_bundle("wh2_main_bundle_chaos_invasion_region");
	effect_bundle_region:add_effect("wh_main_effect_religion_conversion_chaos_events_bad", "region_to_province_own", chaos_corruption);
	effect_bundle_region:set_duration(0);

	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		local faction = cm:model():world():faction_by_key(human_factions[i]);
		cm:remove_effect_bundle("wh2_main_bundle_chaos_invasion", human_factions[i]);
		cm:apply_custom_effect_bundle_to_faction(effect_bundle_faction, faction);
	end

	local region_list = cm:model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		local region_key = current_region:name();

		if current_region:is_province_capital() == true then
			cm:remove_effect_bundle_from_region("wh2_main_bundle_chaos_invasion_region", region_key);
			cm:apply_custom_effect_bundle_to_region(effect_bundle_region, current_region);
		end
	end
end

function CI_declare_war(warring_faction)
	local faction_list = cm:model():world():faction_list();

	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local faction_key = faction:name();
		
		if faction:is_null_interface() == false and faction:is_dead() == false and faction:culture() ~= "wh_main_chs_chaos" and faction:culture() ~= "wh_dlc03_bst_beastmen" then
			cm:force_declare_war(warring_faction, faction_key, false, false);
			cm:force_diplomacy("faction:"..warring_faction, "faction:"..faction_key, "peace", false, false, true);
		end
	end
end

function CI_setup_armies()
	random_army_manager:new_force("CI_archaon");
	random_army_manager:new_force("CI_sigvald");
	random_army_manager:new_force("CI_kholek");
	random_army_manager:new_force("CI_sarthorael");
	random_army_manager:new_force("CI_chaos");
	random_army_manager:new_force("CI_chaos_high");
	random_army_manager:new_force("CI_norsca");
	random_army_manager:new_force("CI_beastmen");
	
	-- ARCHAON
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_pro04_chs_art_hellcannon_ror_0", 3);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_pro04_chs_cav_chaos_knights_ror_0", 3);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_pro04_chs_mon_dragon_ogre_ror_0", 3);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 2);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_main_chs_cav_chaos_knights_1", 2);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_main_chs_inf_chosen_0", 1);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_main_chs_inf_chosen_1", 1);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_dlc01_chs_inf_chosen_2", 1);
	random_army_manager:add_mandatory_unit("CI_archaon", "wh_main_chs_mon_giant", 1);
	random_army_manager:add_unit("CI_archaon", "wh_pro04_chs_cav_chaos_knights_ror_0", 2);
	random_army_manager:add_unit("CI_archaon", "wh_pro04_chs_mon_dragon_ogre_ror_0", 2);
	random_army_manager:add_unit("CI_archaon", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 2);
	
	-- SIGVALD
	random_army_manager:add_mandatory_unit("CI_sigvald", "wh_pro04_chs_inf_chaos_warriors_ror_0", 1);
	random_army_manager:add_unit("CI_sigvald", "wh_main_chs_cav_chaos_knights_0", 4);
	random_army_manager:add_unit("CI_sigvald", "wh_main_chs_cav_chaos_knights_1", 4);
	random_army_manager:add_unit("CI_sigvald", "wh_main_chs_art_hellcannon", 2);
	
	-- KHOLEK
	random_army_manager:add_mandatory_unit("CI_kholek", "wh_pro04_chs_mon_dragon_ogre_ror_0", 1);
	random_army_manager:add_unit("CI_kholek", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 12);
	random_army_manager:add_unit("CI_kholek", "wh_dlc01_chs_mon_dragon_ogre", 6);
	random_army_manager:add_unit("CI_kholek", "wh_main_chs_art_hellcannon", 2);
	
	-- SARTHORAEL
	random_army_manager:add_mandatory_unit("CI_sarthorael", "wh_pro04_chs_inf_forsaken_ror_0", 1);
	random_army_manager:add_mandatory_unit("CI_sarthorael", "wh_main_chs_art_hellcannon", 3);
	random_army_manager:add_unit("CI_sarthorael", "wh_main_chs_cav_chaos_chariot", 2);
	random_army_manager:add_unit("CI_sarthorael", "wh_main_chs_mon_giant", 2);
	random_army_manager:add_unit("CI_sarthorael", "wh_main_chs_cav_chaos_knights_0", 2);
	random_army_manager:add_unit("CI_sarthorael", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 2);
	random_army_manager:add_unit("CI_sarthorael", "wh_dlc01_chs_mon_dragon_ogre", 2);
	
	-- EXTRA CHAOS
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_art_hellcannon", 2);
	random_army_manager:add_mandatory_unit("CI_chaos", "wh_dlc01_chs_inf_chosen_2", 2);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_cav_chaos_chariot", 1);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_mon_giant", 1);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_cav_chaos_knights_0", 1);
	random_army_manager:add_unit("CI_chaos", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 1);
	random_army_manager:add_unit("CI_chaos", "wh_dlc01_chs_mon_dragon_ogre", 1);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_inf_chosen_0", 4);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_inf_chosen_1", 6);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_mon_chaos_spawn", 1);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_mon_trolls", 1);
	random_army_manager:add_unit("CI_chaos", "wh_main_chs_mon_chaos_warhounds_0", 1);

	-- EXTRA CHAOS
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_art_hellcannon", 4);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_mon_giant", 3);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_cav_chaos_knights_0", 1);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_cav_chaos_knights_1", 5);
	random_army_manager:add_unit("CI_chaos_high", "wh_dlc01_chs_mon_dragon_ogre_shaggoth", 3);
	random_army_manager:add_unit("CI_chaos_high", "wh_dlc01_chs_mon_dragon_ogre", 3);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_cav_chaos_chariot", 2);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_inf_chosen_0", 2);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_inf_chosen_1", 2);
	random_army_manager:add_unit("CI_chaos_high", "wh_dlc01_chs_inf_chosen_2", 1);
	random_army_manager:add_unit("CI_chaos_high", "wh_main_chs_mon_chaos_warhounds_1", 1);
	-- NORSCA
	random_army_manager:add_mandatory_unit("CI_norsca", "wh_dlc08_nor_inf_marauder_champions_0", 2);
	random_army_manager:add_mandatory_unit("CI_norsca", "wh_main_nor_inf_chaos_marauders_0", 6);
	random_army_manager:add_mandatory_unit("CI_norsca", "wh_dlc08_nor_inf_marauder_spearman_0", 4);
	random_army_manager:add_mandatory_unit("CI_norsca", "wh_dlc08_nor_inf_marauder_hunters_0", 2);
	random_army_manager:add_mandatory_unit("CI_norsca", "wh_dlc08_nor_mon_war_mammoth_0", 2);
	random_army_manager:add_unit("CI_norsca", "wh_dlc08_nor_mon_skinwolves_0", 1);
	random_army_manager:add_unit("CI_norsca", "wh_main_nor_mon_chaos_trolls", 1);

	-- BEASTMEN
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_inf_bestigor_herd_0", 4);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_inf_minotaurs_2", 2);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_inf_minotaurs_1", 2);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_inf_cygor_0", 2);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_mon_giant_0", 2);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_cav_razorgor_chariot_0", 2);
	random_army_manager:add_mandatory_unit("CI_beastmen", "wh_dlc03_bst_inf_ungor_raiders_0", 2);
	random_army_manager:add_unit("CI_beastmen", "wh_dlc03_bst_inf_gor_herd_1", 1);
	
	-- Create the force strings for the unique characters
	CI_CHAOS_CHARACTERS["archaon"]["force"] = random_army_manager:generate_force("CI_archaon", 19, false);
	CI_CHAOS_CHARACTERS["sigvald"]["force"] = random_army_manager:generate_force("CI_sigvald", 19, false);
	CI_CHAOS_CHARACTERS["kholek"]["force"] = random_army_manager:generate_force("CI_kholek", 19, false);
	CI_CHAOS_CHARACTERS["sarthorael"]["force"] = random_army_manager:generate_force("CI_sarthorael", 19, false);
end

function CI_army_xp()
	local difficulty = cm:model():difficulty_level();
	local xp = 0;
	
	if difficulty == 0 then
		xp = 0; -- Normal
	elseif difficulty == -1 then
		xp = 3; -- Hard
	elseif difficulty == -2 then
		xp = 9; -- Very Hard
	elseif difficulty == -3 then
		xp = 9; -- Legendary
	end
	return xp;
end

	function CI_debug_setup()
		out(" setting dubug")
		out(CI_DATA.CI_SETTING)
		out("\n")
		if CI_DEBUG == true or CI_DATA.CI_SETTING == 5 then
			out.chaos("!!!! DEBUG IS ACTIVE !!!!");
			CI_EVENTS[1].first_turn = 1;
			CI_EVENTS[1].last_turn = 2;
			CI_EVENTS[2].first_turn = 2;
			CI_EVENTS[2].last_turn = 3;
			CI_EVENTS[3].first_turn = 4;
			CI_EVENTS[3].last_turn = 5;
			CI_EVENTS[4].first_turn = 5;
			CI_EVENTS[4].last_turn = 6;
			CI_EVENTS[5].first_turn = 6;
			CI_EVENTS[5].last_turn = 7;
			local player = cm:get_local_faction_name(true);
			if player then
				cm:make_region_visible_in_shroud(player, "wh_main_chaos_wastes");
			end
		else if CI_DATA.CI_SETTING == 1 then
			CI_EVENTS[1].first_turn = CI_EVENTS[1].first_turn - 30;
			CI_EVENTS[1].last_turn = CI_EVENTS[1].last_turn - 30;
			CI_EVENTS[2].first_turn = CI_EVENTS[2].first_turn - 30;
			CI_EVENTS[2].last_turn = CI_EVENTS[2].last_turn - 30;
			CI_EVENTS[3].first_turn = CI_EVENTS[3].first_turn - 30;
			CI_EVENTS[3].last_turn = CI_EVENTS[3].last_turn - 30;
			CI_EVENTS[4].first_turn = CI_EVENTS[4].first_turn - 30;
			CI_EVENTS[4].last_turn = CI_EVENTS[4].last_turn - 30;
			CI_EVENTS[5].first_turn = CI_EVENTS[5].first_turn - 30;
			CI_EVENTS[5].last_turn = CI_EVENTS[5].last_turn - 30;
		end
	end
end

function CI_event(num)
	if num == 1 then
		CI_Event_1_Intro(CI_EVENTS[num]);
	elseif num == 2 then
		CI_Event_2_MidGame(CI_EVENTS[num]);
	elseif num == 3 or num == 4 or num == 5 then
		CI_Event_3_EndGame(CI_EVENTS[num]);
	elseif num == 6 then
		CI_Event_4_Victory(CI_EVENTS[num]);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("CI_DATA", CI_DATA, context);
		cm:save_named_value("CI_EXTRA_DATA", CI_EXTRA_DATA, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			CI_DATA = cm:load_named_value("CI_DATA", CI_DATA, context);
			CI_EXTRA_DATA = cm:load_named_value("CI_EXTRA_DATA", CI_DATA, context);
		end
	end
);