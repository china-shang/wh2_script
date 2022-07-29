

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
	cm:teleport_to(player_char_str, 488, 431, true);
	
	-- remove all units from the player's starting army
	cm:remove_all_units_from_general(player_char);
	
	-- add customised unit setup
	cm:grant_unit_to_character(player_char_str, "wh2_main_hef_inf_spearmen_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_hef_inf_spearmen_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_hef_inf_spearmen_0");
	
	-- create initial enemy force
	cm:create_force_with_general(
		-- faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader, success_callback
		cult_of_excess_faction_str,
		"wh2_main_def_inf_dreadspears_0,wh2_main_def_inf_dreadspears_0,wh2_main_def_inf_dreadspears_0",
		glittering_tower_region_str,
		initial_enemy_force_x,
		initial_enemy_force_y,
		"general",
		"wh2_main_def_dreadlord_fem",
		"names_name_2147359620",		-- Sareth
		"",
		"",
		"",
		false
	);
	
	-- create second enemy force
	create_second_enemy_force();
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
	local end_x = 337.3;
	local end_y = 333.7;
	local end_d = 18.5;
	local end_b = 0;
	local end_h = 16.0;	
	
	local local_faction = cm:get_local_faction_name();
	
	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",
		56,
		function() start_first_turn_intro(end_x, end_y, end_d, end_b, end_h) end
	);
	
	-- cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true);
	cutscene_intro:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:set_camera_position(326.0, 335.7, 7.45, 0.0, 4.0);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			-- raise altitude
			cm:scroll_camera_from_current(false, 14, {326.1, 336.8, 12.5, 0.0, 7.7});
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			-- I humbly beg of your attention, Lord Tyrion. Though I be but a man, my advice may be of some use to you at this black hour.
			cm:show_advice("wh2.camp.prelude.ft.001.hef");
			show_first_turn_intro_infotext();
		end,
		1
	);
	
	cutscene_intro:action(
		function()
			-- Lothern
			cm:scroll_camera_from_current(
				true, 
				40, 
				{341.4, 332.5, 7.5, 0.0, 4.0},
				{347.5, 330.5, 7.5, 0.0, 4.2},
				{353.5, 327.4, 7.5, 0.0, 4.7},
				{353.2, 325.9, 7.7, 0.0, 4.8},
				{349.3, 324.5, 8.0, 0.0, 5},
				{343.3, 329.4, 10.0, 0.0, 6.0},
				{end_x, end_y, end_d, end_b, end_h}				
			);
		end,
		16
	);
	
	cutscene_intro:wait_for_advisor(15.5);
	
	cutscene_intro:action(
		function()
			-- The Dark Elves, or Druchii as they are called by your kind, have yoked the malevolent energies unleashed by the comet's appearance. With them, they have found a route through the Shifting Isles to the southern shores of your homeland, Ulthuan.
			cm:show_advice("wh2.camp.prelude.ft.002.hef");
		end,
		16
	);
	
	cutscene_intro:wait_for_advisor(32);
	
	cutscene_intro:action(
		function()
			-- I regret to inform you that their dreaded forces have run rampant across your unspoilt country. While your capital, Lothern, remains uncompromised, several smaller cities have fallen.
			cm:show_advice("wh2.camp.prelude.ft.003.hef");
		end,
		32.5
	);
	
	cutscene_intro:wait_for_advisor(46.5);
	
	cutscene_intro:action(
		function()
			play_final_first_turn_intro_advice()
		end,
		47
	);
	
	cutscene_intro:start();
end;



bool_final_first_turn_intro_advice_played = false;

function play_final_first_turn_intro_advice()
	if bool_final_first_turn_intro_advice_played then
		return;
	end;
	
	bool_final_first_turn_intro_advice_played = true;
	
	-- Though your rapid march south has brought some welcome additional forces, the situation remains grim. See for yourself!
	cm:show_advice("wh2.camp.prelude.ft.004.hef");
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
	
	local settlement_lothern = cm:get_region(lothern_region_str):settlement();
	local camera_marker_player_capital = intro_campaign_camera_marker:new(
		"player_capital",
		settlement_lothern:display_position_x(),
		settlement_lothern:display_position_y(),
		25			-- cutscene duration
	);
	
	camera_marker_player_capital:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_capital:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(
				false, 
				5,
				{349.15921, 332.0, 5.6, 0.0, 4.0}
			);
		end,
		0
	);
	
	camera_marker_player_capital:action(
		function()
			-- Lothern, your capital, is the seat of the Phoenix King. A garrison defends the city, but it is gravely threatened.
			cm:show_advice("wh2.camp.prelude.ft.010.hef");
		end,
		1
	);
	
	camera_marker_player_capital:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(
				false, 
				6,
				{349.3, 331.9, 5.6, 0.49, 4.0}
			);
		end,
		5
	);
	
	camera_marker_player_capital:action(
		function()
			-- Druchii raiders sack the surrounding countryside, probing the city's defences. The Phoenix Throne cannot be allowed to fall: the Dark Elves must be engaged and driven from Ulthuan!
			cm:show_advice("wh2.camp.prelude.ft.011.hef");
		end,
		11
	);
	
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				false, 
				6,
				{337.1, 332.2, 5.6, 0.2, 4.0}
			);
		end,
		11
	);
	
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				true,
				7,
				{end_x, end_y, end_d, end_b, end_h}
			);
		end,
		18
	);
	
	
	
	
	--
	-- Enemy settlement marker
	--
	
	local settlement_tower_of_lysean = cm:get_region(tower_of_lysean_region_str):settlement();
	local camera_marker_enemy_settlement = intro_campaign_camera_marker:new(
		"enemy_settlement",
		settlement_tower_of_lysean:display_position_x(),
		settlement_tower_of_lysean:display_position_y(),
		44			-- cutscene duration
	);
	
	camera_marker_enemy_settlement:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_enemy_settlement:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(false, 7, {335.2, 349.4, 5.6, -1.81, 4.0});
		end,
		0
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- Lightning strikes by the enemy have gained them control of the Tower of Lysean, Lord Tyrion. It's capture means they now control the straits of Lothern at both ends.
			cm:show_advice("wh2.camp.prelude.ft.020.hef");
		end,
		1
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- pan around settlement
			cm:make_region_visible_in_shroud(cm:get_local_faction_name(), angerrial_region_str);
			cm:scroll_camera_from_current(false, 6, {335.3, 349.5, 5.6, -2.1, 4.0});
		end,
		7
	);
	
	camera_marker_enemy_settlement:wait_for_advisor(13);
	
	camera_marker_enemy_settlement:action(
		function()
			-- zoom to second settlement
			cm:scroll_camera_from_current(false, 12, {364.5, 353.0, 5.6, 0.38, 4.0});
			
			-- Furthermore, scouts report that the Dark Elves have struck at Angerrial, and overrun the defences there. Digging them out of this fortified city will not be easy, my Lord, but the Druchii must not be left to despoil the Inner Kingdoms of Ulthuan!
			cm:show_advice("wh2.camp.prelude.ft.021.hef");
		end,
		13.5
	);	
	
	camera_marker_enemy_settlement:action(
		function()
			-- pan around settlement
			cm:scroll_camera_from_current(false, 6, {365.1, 353.8, 5.6, 0.84, 4.0});
		end,
		25.5
	);
	
	camera_marker_enemy_settlement:wait_for_advisor(31);
	
	camera_marker_enemy_settlement:action(
		function()
			-- Your kind's history with the Druchii goes back millenia, and you are no stranger to their wicked and vicious methods of war. They must not be allowed to enter the capital!
			cm:show_advice("wh2.camp.prelude.ft.022.hef");
			
			-- pan back
			cm:scroll_camera_from_current(false, 12, {end_x, end_y, end_d, end_b, end_h});
		end,
		31.5
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
		10.5			-- cutscene duration
	);
	
	camera_marker_player_army:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_army:action(
		function()
			-- zoom to army
			cm:scroll_camera_from_current(false, 3.5, {326.2, 335.4, 7.4, 0.0, 4.0});
		end,
		0
	);

	
	camera_marker_player_army:action(
		function()
			-- Your army enters the theatre of war, Lord Tyrion. Wield your forces wisely: they are the best hope for averting Lothern's destruction.
			cm:show_advice("wh2.camp.prelude.ft.030.hef");
		end,
		1
	);
	
	camera_marker_player_army:action(
		function()
			-- pan around army
			cm:scroll_camera_from_current(false, 3.5, {326.8, 335.2, 7.4, 0.3, 4.0});
		end,
		3.3
	);
	
	camera_marker_player_army:action(
		function()
			-- pan back
			cm:scroll_camera_from_current(false, 3.5, {end_x, end_y, end_d, end_b, end_h});
		end,
		6.1
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
	local enemy_char = cm:get_closest_general_to_position_from_faction(cult_of_excess_faction_str, initial_enemy_force_x, initial_enemy_force_y, false); 
	
	if not enemy_char then
		script_error("ERROR: start_select_and_attack_advice() could not find enemy character");
		return;
	end;
	
	local enemy_cqi = enemy_char:cqi();
	
	local sa = intro_campaign_select_and_attack_advice:new(
		-- player_cqi, enemy_cqi, initial_advice, selection_objective, attack_advice, attack_objective, end_callback
		player_legendary_lord_char_cqi,
		enemy_cqi,
		-- Your elves may be tired from marching, Lord Tyrion, but now is the perfect time to attack. Select your army first.
		"wh2.camp.prelude.ft.040.hef",
		"wh2.camp.army_selection_advice.001",
		-- Good! Now, issue an order to engage the enemy, my Lord. They are scattered, and are not prepared for an attack so soon.
		"wh2.camp.prelude.ft.050",
		"wh2.camp.attack_advice.001",
		function() attack_initiated() end
	);
	
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
	
	sa:set_camera_position_override(330.2, 338.1, 16.6, 0.0, 9.4);		-- x, y, d, b, h
	
	sa:set_enemy_marker_altitude(5);
	
	sa:start();
end;

function attack_initiated()	
	local attack_button_clicked = false;
	local attack_button_highlighted = false;
	
	-- close help panel
	get_help_page_manager():show_panel(false);
	
	-- disable scout terrain button
	set_component_active_with_parent(false, core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "button_preview_map");
	
	-- show advice, infotext and highlight button
	cm:callback(
		function()
			if not attack_button_clicked then
				-- highlight attack button
				highlight_component(true, true, "button_attack_container", "button_attack");
				attack_button_highlighted = true;
				
				-- Battle is upon you, Lord Tyrion! Have your elves sharpen their swords, fasten their armour, and prepare for bloodshed!
				cm:show_advice("wh2.camp.prelude.ft.060.hef");
				cm:add_infotext(
					1,
					"wh2.camp.intro.info_030",
					"wh2.camp.intro.info_031",
					"wh2.camp.intro.info_032"
				);
			end;
		end,
		1
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
		"script/battle/intro_battles/high_elves/first/battle.xml",		-- entire battle override
		0,																-- human alliance when battle override
		false,															-- launch battle immediately
		true,															-- is land battle (only for launch battle immediately)
		true															-- force application of autoresolver result
	);
end;








