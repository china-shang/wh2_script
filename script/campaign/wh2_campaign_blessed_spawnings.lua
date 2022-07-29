-- chance of awarding a blessed unit on faction turn start (if it's possible to award one)
local chance = 10;

-- minimum turns until next blessed spawn mission
local blessed_spawn_timer = 0;
local blessed_spawn_timer_reset = 15;

-- turn numbers before units begin to be awarded
local turn_number_for_blessed_units = 15;

-- 3 common, 2 uncommon, 1 rare
local units = {
	{num_units = 3, unit_key = "wh2_main_lzd_inf_chameleon_skinks_blessed_0"},
	{num_units = 3, unit_key = "wh2_main_lzd_inf_saurus_spearmen_blessed_1"},
	{num_units = 3, unit_key = "wh2_main_lzd_inf_saurus_warriors_blessed_1"},
	{num_units = 3, unit_key = "wh2_main_lzd_inf_skink_skirmishers_blessed_0"},

	{num_units = 2, unit_key = "wh2_main_lzd_cav_cold_one_spearriders_blessed_0"},
	{num_units = 2, unit_key = "wh2_main_lzd_cav_terradon_riders_blessed_1"},
	{num_units = 2, unit_key = "wh2_main_lzd_inf_temple_guards_blessed"},
	{num_units = 2, unit_key = "wh2_main_lzd_mon_kroxigors_blessed"},

	{num_units = 1, unit_key = "wh2_main_lzd_cav_horned_ones_blessed_0"},
	{num_units = 1, unit_key = "wh2_main_lzd_mon_bastiladon_blessed_2"},
	{num_units = 1, unit_key = "wh2_main_lzd_mon_carnosaur_blessed_0"},
	{num_units = 1, unit_key = "wh2_main_lzd_mon_stegadon_blessed_1"}
};

-- AI Blessed Spawnings

cm:add_faction_turn_start_listener_by_culture(
	"award_blessed_units",
	"wh2_main_lzd_lizardmen",
	function(context)
		local faction = context:faction();
		local turn_number = cm:model():turn_number();	
		--10% for AI to gain a blessed unit reward after turn 15
		if cm:random_number(100) <= chance and faction:is_human() == false and turn_number > turn_number_for_blessed_units then		
			local unit = units[cm:random_number(#units)];			
			cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), unit.unit_key, unit.num_units);
		end
	end,
	true
);


-- try and generate a mission for the player if blessed_spawn_timer is <= 0
core:add_listener(
	"generate_spawning_mission",
	"ScriptEventHumanFactionTurnStart",
	function(context)
		local faction = context:faction();
		return faction:culture() == "wh2_main_lzd_lizardmen" and faction:name() ~= "wh2_dlc13_lzd_spirits_of_the_jungle";
	end,
	function(context) generate_spawning_mission(context) end,
	true
);

-- if a spawning mission successfully fires then reset the counter
-- if the spawning mission doesnt fire this wont be called so the next turn a spawning mission should try and fire again
core:add_listener(
	"reset_blessed_timer",
	"MissionIssued",
	function(context)
		local faction = context:faction();
		return faction:is_human() == true and faction:culture() == "wh2_main_lzd_lizardmen";
	end,
	function(context)
		if context:mission():mission_record_key():starts_with("wh2_main_spawning_") then
			out.design("Blessed Spawning: Resetting timer");
			blessed_spawn_timer = blessed_spawn_timer_reset;
		end
	end,
	true
);

function generate_spawning_mission(context)
	
	blessed_spawn_timer = blessed_spawn_timer - 1;
	local missions = {};
	local turn = cm:turn_number();
	
	if turn < 5 then
		return false;
	end
	
	if (turn <= 50) then
		missions = {
			"wh2_main_spawning_capture_x_battle_captives",
			"wh2_main_spawning_capture_x_battle_captives_rare",
			"wh2_main_spawning_defeat_n_armies_of_faction",
			"wh2_main_spawning_defeat_n_armies_of_faction_rare",
			"wh2_main_spawning_kill_x_entities",
			"wh2_main_spawning_kill_x_entities_rare",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including_rare"
		};
	elseif (turn <= 100) then
		missions = {
			"wh2_main_spawning_capture_x_battle_captives_mid",
			"wh2_main_spawning_capture_x_battle_captives_mid_rare",
			"wh2_main_spawning_defeat_n_armies_of_faction_mid",
			"wh2_main_spawning_defeat_n_armies_of_faction_mid_rare",
			"wh2_main_spawning_kill_x_entities_mid",
			"wh2_main_spawning_kill_x_entities_mid_rare",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including_mid",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including_mid_rare"
		};
	else
		missions = {
			"wh2_main_spawning_capture_x_battle_captives_late",
			"wh2_main_spawning_capture_x_battle_captives_late_rare",
			"wh2_main_spawning_defeat_n_armies_of_faction_late",
			"wh2_main_spawning_defeat_n_armies_of_faction_late_rare",
			"wh2_main_spawning_kill_x_entities_late",
			"wh2_main_spawning_kill_x_entities_late_rare",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including_late",
			"wh2_main_spawning_raze_or_sack_n_different_settlements_including_late_rare"
		};
	end;
	
	if blessed_spawn_timer <= 0 then
		local faction_key = context:faction():name();
		local rand_num = cm:random_number(#missions);
		local mission_key = missions[rand_num];
		
		for i = 1, #missions do
			cm:cancel_custom_mission(faction_key, missions[i], false);
		end
		
		out.design("Blessed Spawning: Spawning mission "..tostring(mission_key).." for "..tostring(faction_key));
		cm:trigger_mission(faction_key, mission_key, true);
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("blessed_spawn_timer", blessed_spawn_timer, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		blessed_spawn_timer = cm:load_named_value("blessed_spawn_timer", blessed_spawn_timer, context);
	end
);