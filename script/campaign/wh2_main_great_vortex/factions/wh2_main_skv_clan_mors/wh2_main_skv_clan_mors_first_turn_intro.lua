

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FIRST TURN INTRO SCRIPT
--
--	Script for first section of intro first-turn
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------





---------------------------------------------------------------
--	Customise starting armies
---------------------------------------------------------------

do
	-- get player char
	local player_char = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	if not player_char then
		script_error("ERROR: could not find player's legendary lord with cqi [" .. player_legendary_lord_char_cqi .. "]");
		return false;
	end;
	
	local player_char_str = cm:char_lookup_str(player_legendary_lord_char_cqi);
	
	-- teleport player general to starting position for the intro
	cm:teleport_to(player_char_str,  515, 78, true);
	
	-- increase the movement range of the player's army slightly, for one turn
	cm:apply_effect_bundle_to_characters_force("wh_main_increased_movement_range_15", player_legendary_lord_char_cqi, 1, false);
	
	-- remove all units from the player's starting army
	cm:remove_all_units_from_general(player_char);
	
	-- add customised unit setup
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
	
	-- create initial enemy force
	cm:create_force_with_general(
		-- faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader, success_callback
		fortress_of_dawn_faction_str,
		"wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0,wh2_main_hef_inf_spearmen_0",
		dawns_light_region_str,
		initial_enemy_force_x,
		initial_enemy_force_y,
		"general",
		"wh2_main_hef_prince",
		"names_name_2147359373",		-- Harathrel
		"",
		"",
		"",
		false,
		function(cqi)
			-- prevent player from ambushing this enemy
			cm:apply_effect_bundle_to_characters_force("wh2_main_bundle_scripted_prevent_ambush", cqi, 2, true);
		end
	);
	
	-- prevent player from being ambushed this turn
	cm:apply_effect_bundle_to_characters_force("wh2_main_bundle_scripted_prevent_ambush", player_legendary_lord_char_cqi, 2, true);
	
	setup_second_enemy_force();
end;






---------------------------------------------------------------
--	First Turn Intro Cutscene
---------------------------------------------------------------

function cutscene_intro_play()		-- called from <faction_name>_start.lua
	out("cutscene_intro_play() called - first turn INTRO");
	
	-- disable ui
	cm:get_campaign_ui_manager():display_first_turn_ui(false);
	
	local hpm = get_help_page_manager();
	
	-- help panel does not close when ESC menu opened
	hpm:set_close_on_game_menu_opened(false);
	
	-- disable the ? help page button
	hpm:enable_menu_bar_index_button(false);
	
	-- end camera position
	local end_x = 352.1;
	local end_y = 60.4;
	local end_d = 13.8;
	local end_b = 0;
	local end_h = 11.0;
	
	local local_faction = cm:get_local_faction_name();
	
	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",
		53.5,
		function() start_first_turn_intro(end_x, end_y, end_d, end_b, end_h) end
	);
	
	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true);
	cutscene_intro:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:set_camera_position(343.9, 61.0, 3.2, 0.0, 2.0);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			-- raise altitude
			cm:scroll_camera_from_current(false, 18, {343.9, 61.0, 11.0, 0.0, 8.0});
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			-- Such a magnificent specimen! I am unworthy to be in your presence. Yet, I risk my neck and approach you, Warlord Headtaker, for I have many secrets that will bring you success and even greater status.
			cm:show_advice("wh2.camp.prelude.ft.001.skv");
			show_first_turn_intro_infotext();
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			-- Lothern
			cm:scroll_camera_from_current(
				true,
				35, 
				{352.45816, 61.395367, 11.0, 0.457008, 8.0},
				{355.667328, 60.31728, 11.0, 0.552007, 8.0},
				{350.628235, 55.751602, 11.0, 0.457008, 8.0},
				{341.944366, 56.368023; 11.0, 0.570009, 8.0},
				{345.913086, 59.171181; 11.0, 0.199004, 8.0},
				{end_x, end_y, end_d, end_b, end_h}	
				
				
				--[[
				{355.2, 63.9, 7.3, 0.26, 5.0},
				{360.8, 63.0, 7.3, 0.1, 5.0},
				{end_x, end_y, end_d, end_b, end_h}	
				]]				
			);
		end,
		18.5
	);
	
	cutscene_intro:wait_for_advisor(18);
	
	cutscene_intro:action(
		function()
			-- Your arrival at Yuatek comes not a moment too soon, great and powerful Queek. High Elves from across the seas have launched a full-scale invasion of the Southlands, and are pressing fast towards your lair!
			cm:show_advice("wh2.camp.prelude.ft.002.skv");
		end,
		18.5
	);
	
	cutscene_intro:wait_for_advisor(33);
	
	cutscene_intro:action(
		function()
			-- To the south, the 'Elf-things' have overrun several ruined settlements, and established defensive positions in each. Whatever they are seeking remains a mystery.
			cm:show_advice("wh2.camp.prelude.ft.003.skv");
		end,
		33.5
	);
	
	cutscene_intro:wait_for_advisor(45);
	
	cutscene_intro:action(
		function()
			play_final_first_turn_intro_advice()
		end,
		45.5
	);
	
	cutscene_intro:start();
end;



bool_final_first_turn_intro_advice_played = false;

function play_final_first_turn_intro_advice()
	if bool_final_first_turn_intro_advice_played then
		return;
	end;
	
	bool_final_first_turn_intro_advice_played = true;
	
	-- Though your rapid return brings some welcome additional forces, the situation remains grim. See for yourself!
	cm:show_advice("wh2.camp.prelude.ft.004.skv");
	show_first_turn_intro_infotext();
end;


bool_first_turn_intro_infotext_shown = false;

function show_first_turn_intro_infotext()
	if bool_first_turn_intro_infotext_shown then
		return;
	end;
	
	bool_first_turn_intro_infotext_shown = true;
	
	cm:add_infotext(
		1,
		"wh2.camp.intro.info_001",
		"wh2.camp.intro.info_002",
		"wh2.camp.intro.info_003"
	);
end;





---------------------------------------------------------------
--	Camera Tutorial
---------------------------------------------------------------

function start_first_turn_intro(end_x, end_y, end_d, end_b, end_h)
	out("start_first_turn_intro() called")
	
	-- try and play last line of intro cutscene advice
	play_final_first_turn_intro_advice();
	
	
	
	
	
	--
	-- Player capital marker
	--
	
	local settlement_yuatek = cm:get_region(yuatek_region_str):settlement();
	local camera_marker_player_capital = intro_campaign_camera_marker:new(
		"player_capital",
		settlement_yuatek:display_position_x(),
		settlement_yuatek:display_position_y(),
		23			-- cutscene duration
	);
	
	camera_marker_player_capital:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_capital:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(
				false,
				8,
				{363.6, 63.0, 9.2, 0.43, 5.0}
			);
		end,
		0
	);
	
	camera_marker_player_capital:action(
		function()
			-- The ruined Lizardmen city of Yuatek dominates this province, my Lord. The reptiles have long-since abandoned their holdings here and now your Clan Mors contest control of the ruins that remain.
			cm:show_advice("wh2.camp.prelude.ft.010.skv");
		end,
		0.5
	);
	
	camera_marker_player_capital:action(
		function()
			-- pan around settlement
			cm:scroll_camera_from_current(
				false,
				6,
				{363.6, 63.3, 9.2, 0.72, 5.0}
			);
		end,
		8
	);
	
	
	camera_marker_player_capital:wait_for_advisor(14);
	
	-- pan back
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				true,
				9,
				{363.6, 63.3, 9.2, 0.72, 5.0},
				{end_x, end_y, end_d, end_b, end_h}
			);
		end,
		14
	);
	
	camera_marker_player_capital:action(
		function()
			-- Your warren is well defended, yet the Elves press forward in ever greater numbers. Do not let Yuatek fall, Lord Queek!
			cm:show_advice("wh2.camp.prelude.ft.011.skv");
		end,
		14.5
	);
	
	
	
	--
	-- Enemy settlement marker
	--
	
	local settlement_dawns_light = cm:get_region(dawns_light_region_str):settlement();
	local camera_marker_enemy_settlement = intro_campaign_camera_marker:new(
		"enemy_settlement",
		settlement_dawns_light:display_position_x(),
		settlement_dawns_light:display_position_y(),
		29			-- cutscene duration
	);
	
	camera_marker_enemy_settlement:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_enemy_settlement:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(false, 8, {337.3, 58.2, 9.2, 0.0, 5.0});
		end,
		0
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- The 'Elf-things' have launched a full invasion of the Southlands, my verminous Lord. Outposts have been established in ancient ruins throughout the province, with any underground entrances magically sealed.
			cm:show_advice("wh2.camp.prelude.ft.020.skv");
		end,
		0.5
	);
		
	camera_marker_enemy_settlement:action(
		function()
			-- pan around settlement
			cm:scroll_camera_from_current(false, 7, {338.2, 58.1, 9.2, 0.38, 5.0});
		end,
		8
	);
	
	camera_marker_enemy_settlement:wait_for_advisor(14.5);
	
	camera_marker_enemy_settlement:action(
		function()
			-- Even now they march upon your burrows in Yuatek. Skaven control of the Southlands rests upon you holding this warren. Lord Gnawdwell will not look kindly on us if Clan Mors lose this lair!
			cm:show_advice("wh2.camp.prelude.ft.021.skv");
		end,
		15
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- return
			cm:scroll_camera_from_current(false, 14, {end_x, end_y, end_d, end_b, end_h});
		end,
		15
	);
	
	
	
	
	
	--
	-- Player army marker
	--
	
	local player_char = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	local player_char_x = player_char:display_position_x();
	local player_char_y = player_char:display_position_y();
		local camera_marker_player_army = intro_campaign_camera_marker:new(
		"enemy_capital",
		player_char_x,
		player_char_y,
		12			-- cutscene duration
	);
	
	camera_marker_player_army:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_army:action(
		function()
			-- zoom to army
			cm:scroll_camera_from_current(false, 4, {343.9, 61.0, 3.2, 0.0, 2.0});
		end,
		0
	);

	local end_x = 350.4;
	local end_y = 62.4;
	local end_d = 13.8;
	local end_b = 0;
	local end_h = 11.0;
	
	camera_marker_player_army:action(
		function()
			-- Your vicious Skaven army emerges into the theatre of war, Lord Queek. Each rat you command yearns for the taste of Elven blood. It will come soon!
			cm:show_advice("wh2.camp.prelude.ft.030.skv");
		end,
		0.5
	);
	
	camera_marker_player_army:action(
		function()
			-- pan around army
			cm:scroll_camera_from_current(false, 3.5, {343.9, 61.0, 3.2, 0.25, 2.0});
		end,
		4
	);
	
	camera_marker_player_army:action(
		function()
			-- pan back
			cm:scroll_camera_from_current(false, 4.5, {end_x, end_y, end_d, end_b, end_h});
		end,
		7.5
	);
	
	
	

	
	--
	-- Container
	--
	
	local ca = intro_campaign_camera_positions_advice:new(
		-- Move the camera to inspect the points of interest
		"wh2.camp.camera_advice.001",
		function() start_select_and_attack_advice() end,
		{camera_marker_player_capital, camera_marker_enemy_settlement, camera_marker_player_army}
	);
	
	-- ca.should_skip = true;	-- uncomment to immdiately skip camera advice section
	ca:start();
end;










---------------------------------------------------------------
--	Select and Attack Advice
---------------------------------------------------------------


function start_select_and_attack_advice()

	-- find enemy target cqi
	local enemy_char = cm:get_closest_general_to_position_from_faction(fortress_of_dawn_faction_str, initial_enemy_force_x, initial_enemy_force_y, false); 
	if not enemy_char then
		script_error("ERROR: start_select_and_attack_advice() could not find enemy character");
		return;
	end;
	
	local enemy_cqi = enemy_char:cqi();
	
	local sa = intro_campaign_select_and_attack_advice:new(
		-- player_cqi, enemy_cqi, initial_advice, selection_objective, attack_advice, attack_objective, end_callback
		player_legendary_lord_char_cqi,
		enemy_cqi,
		-- Your arrival has caught the 'Elf-things' by surprise, Lord Queek! Now is the perfect time to attack. Select your army first.
		"wh2.camp.prelude.ft.040.skv",
		"wh2.camp.army_selection_advice.001",
		-- Good! Now, issue an order to engage the enemy, my Lord. They are scattered, and are not prepared for an attack so soon.
		"wh2.camp.prelude.ft.050",
		"wh2.camp.attack_advice.001",
		function() attack_initiated() end
	);
	
	sa:set_camera_position_override(347.9, 64.2, 14.1, 0.0, 8.0);		-- x, y, d, b, h

	-- infotext
	sa:add_initial_infotext(
		1,
		"wh2.camp.intro.info_010",
		"wh2.camp.intro.info_011",
		"wh2.camp.intro.info_012"
	);
	
	sa:add_attack_infotext(
		1,
		"wh2.camp.intro.info_020",
		"wh2.camp.intro.info_021"
	);
	
	sa:set_enemy_marker_altitude(5);
	
	sa:start();
end;

function attack_initiated()
	local attack_button_clicked = false;
	local attack_button_highlighted = false;
	
	-- close help panel
	get_help_page_manager():show_panel(false);
	
	-- close menace below panel
	set_component_visible(false, "popup_pre_battle", "allies_combatants_panel", "ability_charge_panel");
	
	-- disable scout terrain button
	set_component_active_with_parent(false, core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "button_preview_map");
	
	-- show advice, infotext and highlight button
	cm:callback(
		function()
			if not attack_button_clicked then
				-- highlight attack button
				highlight_component(true, true, "button_attack_container", "button_attack");
				attack_button_highlighted = true;
				
				-- Battle is upon you, Lord Queek! Your Clanrats are vicious and strong when motivated, but will be well-matched by the agile and deadly foe. Prepare yourself for bloodshed!
				cm:show_advice("wh2.camp.prelude.ft.060.skv");
				cm:add_infotext(
					1,
					"wh2.camp.intro.info_030",
					"wh2.camp.intro.info_031",
					"wh2.camp.intro.info_032"
				);
			end;
		end,
		0.5
	);
	
	-- listen for button being clicked
	core:add_listener(
		"attack_button_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_attack" end,
		function()
			attack_button_clicked = true;
			load_intro_battle(attack_button_highlighted);
		end,
		false
	);
end;


function load_intro_battle(attack_button_highlighted)
	-- ensure that next time we load into this campaign, we load into part two of the first turn
	cm:set_saved_value("bool_first_turn_intro_completed", true);
	
	-- unhighlight attack button
	if attack_button_highlighted then
		highlight_component(false, true, "button_attack_container", "button_attack");
	end;
	
	cm:set_character_experience_disabled(true);
	
	cm:win_next_autoresolve_battle(cm:get_local_faction_name());
	cm:modify_next_autoresolve_battle(
		1, 			-- attacker win chance
		0,	 		-- defender win chance
		1,	 		-- attacker losses modifier
		5,			-- defender losses modifier
		true
	);

	-- ensure the next battle we load (i.e. the one we're immediately about to launch) is the intro battle
	remove_battle_script_override();
	cm:add_custom_battlefield(
		"intro_battle_1",												-- string identifier
		0,																-- x co-ord
		0,																-- y co-ord
		5000,															-- radius around position
		false,															-- will campaign be dumped
		"",																-- loading override
		"",																-- script override
		"script/battle/intro_battles/skaven/first/battle.xml",			-- entire battle override
		0,																-- human alliance when battle override
		false,															-- launch battle immediately
		true,															-- is land battle (only for launch battle immediately)
		true															-- force application of autoresolver result
	);
end;








