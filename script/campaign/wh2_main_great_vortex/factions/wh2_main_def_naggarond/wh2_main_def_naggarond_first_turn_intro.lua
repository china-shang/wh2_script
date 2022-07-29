

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
	cm:teleport_to(player_char_str, 187, 624, true);
	
	-- prevent player from being ambushed this turn
	cm:apply_effect_bundle_to_characters_force("wh2_main_bundle_scripted_prevent_ambush", player_legendary_lord_char_cqi, 2, true);
	
	-- remove all units from the player's starting army
	cm:remove_all_units_from_general(player_char);
	
	-- add customised unit setup
	cm:grant_unit_to_character(player_char_str, "wh2_main_def_inf_dreadspears_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_def_inf_dreadspears_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_def_inf_dreadspears_0");
	
	-- create initial enemy force
	cm:create_force_with_general(
		-- faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader, success_callback
		clan_septik_faction_str,
		"wh2_main_skv_inf_clanrats_0,wh2_main_skv_inf_clanrats_0,wh2_main_skv_inf_clanrats_0",
		har_kaldra_region_str,
		initial_enemy_force_x,
		initial_enemy_force_y,
		"general",
		"wh2_main_skv_warlord",
		"names_name_2147360602",		-- Boilrer
		"",
		"",
		"",
		false
	);

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
	local end_x = 132.8;
	local end_y = 485.4;
	local end_d = 16.2;
	local end_b = 0;
	local end_h = 14.0;	
	
	local local_faction = cm:get_local_faction_name();
	
	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",
		56.5,
		function() start_first_turn_intro(end_x, end_y, end_d, end_b, end_h) end
	);
	
	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true);
	cutscene_intro:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			-- cm:make_region_visible_in_shroud(local_faction, middenheim_region_str);
			cm:set_camera_position(125.0, 482.8, 3.2, 0.0, 2.0);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			-- raise altitude
			cm:scroll_camera_from_current(false, 20, {125.0, 482.8, 13.8, 0, 11.0});
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			-- Sire… Witch King, Lord of the Druchii, I know to you, I am a fleeting thing - a man, a mortal. But you have received the vision, I humbly attest my advice is worthy of your majesty.
			cm:show_advice("wh2.camp.prelude.ft.001.def");
			show_first_turn_intro_infotext();
		end,
		1
	);
	
	cutscene_intro:action(
		function()
			-- Lothern
			cm:scroll_camera_from_current(
				true, 
				36.5, 
				{143.0, 495.7, 13.8, 0.0, 11.0},
				{129.7, 501.4, 13.8, 0.0, 11.0},
				{127.5, 488.0, 13.8, 0.0, 11.0},
				{end_x, end_y, end_d, end_b, end_h}				
			);
		end,
		20
	);
	
	cutscene_intro:wait_for_advisor(8.5);
	
	cutscene_intro:action(
		function()
			-- The vile Skaven and their Northmen allies have seen fit to invade Naggarond in your absence, sire. Attacking from their subterranean tunnels, the ratmen caught your sentries by surprise.
			cm:show_advice("wh2.camp.prelude.ft.002.def");
		end,
		20
	);
	
	cutscene_intro:wait_for_advisor(34);
	
	cutscene_intro:action(
		function()
			-- While Naggarond itself remains secure, I regret to inform you that their verminous forces have overrun many smaller cities in the hinterlands of your territory.
			cm:show_advice("wh2.camp.prelude.ft.003.def");
		end,
		34.5
	);
	
	cutscene_intro:wait_for_advisor(47);
	
	cutscene_intro:action(
		function()
			play_final_first_turn_intro_advice()
		end,
		47.5
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
	cm:show_advice("wh2.camp.prelude.ft.004.def");
	show_first_turn_intro_infotext();
end;


bool_first_turn_intro_infotext_shown = false;

function show_first_turn_intro_infotext()
	if bool_first_turn_intro_infotext_shown then
		return;
	end;
	
	bool_first_turn_intro_infotext_shown = true;
	
	-- Though your rapid march south has brought some welcome additional forces, the situation remains grim. See for yourself!
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
	
	local settlement_naggarond = cm:get_region(naggarond_region_str):settlement();
	local camera_marker_player_capital = intro_campaign_camera_marker:new(
		"player_capital",
		settlement_naggarond:display_position_x(),
		settlement_naggarond:display_position_y(),
		21.5			-- cutscene duration
	);
	
	camera_marker_player_capital:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_capital:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(
				false, 
				6,
				{143.2, 495.0, 7.3, 0.0, 5.0}
			);
		end,
		0
	);
	
	camera_marker_player_capital:action(
		function()
			-- The black walls of Naggarond have repelled many foolish invaders over your reign, sire. Yet this threat must not be taken lightly.
			cm:show_advice("wh2.camp.prelude.ft.010.def");
		end,
		0.5
	);
	
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				false, 
				5,
				{143.2, 495.0, 7.3, -0.3, 5.0}
			);
		end,
		6
	);
	
	camera_marker_player_capital:wait_for_advisor(7.5);
	
	camera_marker_player_capital:action(
		function()
			-- Just like the Druchii, the vermin are vicious and opportunistic killers, and are doubtless working tirelessly to undermine your fortress.
			cm:show_advice("wh2.camp.prelude.ft.011.def");
		end,
		11.5
	);
	
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				false, 
				10,
				{126.1, 490.4, 7.3, 0.0, 5.0},
				{end_x, end_y, end_d, end_b, end_h}
			);
		end,
		11.5
	);
	
	
	
	
	
	--
	-- Enemy settlement marker
	--
	
	-- local enemy_character = cm:get_character_by_cqi(enemy_secondary_lord_char_cqi);			-- we actually use the position of the enemy lord instead
	local enemy_settlement = cm:get_region(har_kaldra_region_str):settlement();
	
	local camera_marker_enemy_settlement = intro_campaign_camera_marker:new(
		"enemy_settlement",
		enemy_settlement:display_position_x(),
		enemy_settlement:display_position_y(),
		34.5			-- cutscene duration
	);
	
	camera_marker_enemy_settlement:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_enemy_settlement:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(false, 8, {131.060867, 519.182251, 10.001038, 0.0, 4.0});
		end,
		0
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- The hinterland territories are overrun with vermin, your majesty. The Skaven first came into your realm beneath Har Kaldra, gnawing for weeks through frozen rock to enter the ruined city from below.
			cm:show_advice("wh2.camp.prelude.ft.020.def");
		end,
		1
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- pan around settlement
			cm:scroll_camera_from_current(false, 7, {131.889893, 518.622375, 10.000854, 0.454001, 4.0});
		end,
		8
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- pan back
			cm:scroll_camera_from_current(
				true, 
				18.5, 
				{134.620239, 508.112366, 9.999886, 0.265001, 4.395041},
				{end_x, end_y, end_d, end_b, end_h}
			);
		end,
		15
	);
	
	camera_marker_enemy_settlement:wait_for_advisor(16);
	
	camera_marker_enemy_settlement:action(
		function()
			-- What has driven the Skaven to such a suicidal attack remains unknown. Yet it remains an affront that cannot stand: exact your terrible retribution, my dread sovereign. Let not one of them escape alive!
			cm:show_advice("wh2.camp.prelude.ft.022.def");
		end,
		16.5
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
		9.5			-- cutscene duration
	);
	
	camera_marker_player_army:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_army:action(
		function()
			-- zoom to army
			cm:scroll_camera_from_current(false, 3.5, {125.618309, 483.818481, 7.452576, 0.0, 4.0});
		end,
		0
	);

	
	camera_marker_player_army:action(
		function()
			-- Your Druchii forces dominate any battlefield they enter, King Malekith. Direct your Dreadspears against the Skaven enemy. See how they run!
			cm:show_advice("wh2.camp.prelude.ft.030.def");
		end,
		1
	);
	
	camera_marker_player_army:action(
		function()
			-- pan around army
			cm:scroll_camera_from_current(false, 3, {125.757835, 483.64563, 7.452598, 0.271001, 4.0});
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
	local enemy_char = cm:get_closest_general_to_position_from_faction(clan_septik_faction_str, initial_enemy_force_x, initial_enemy_force_y, false); 
	
	if not enemy_char then
		script_error("ERROR: start_select_and_attack_advice() could not find enemy character");
		return;
	end;
	
	local enemy_cqi = enemy_char:cqi();
	
	local sa = intro_campaign_select_and_attack_advice:new(
		-- player_cqi, enemy_cqi, initial_advice, selection_objective, attack_advice, attack_objective, end_callback
		player_legendary_lord_char_cqi,
		enemy_cqi,
		-- The enemy were not prepared for your arrival, my King: now is the perfect time to attack! Select your army first.
		"wh2.camp.prelude.ft.040.def",
		"wh2.camp.army_selection_advice.001",
		-- Good! Now, issue an order to engage the enemy, my Lord. They are scattered, and are not prepared for an attack so soon.
		"wh2.camp.prelude.ft.050",
		"wh2.camp.attack_advice.001",
		function() attack_initiated() end
	);
	
	sa:set_camera_position_override(120.8, 485.9, 15.0, -1.25, 8.6);		-- x, y, d, b, h
	
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
	
	-- disable scout terrain button
	set_component_active_with_parent(false, core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "button_preview_map");
	
	-- show advice, infotext and highlight button
	cm:callback(
		function()
			if not attack_button_clicked then
				-- highlight attack button
				highlight_component(true, true, "button_attack_container", "button_attack");
				attack_button_highlighted = true;
				
				-- Battle is upon you, mighty Witch King! Your elves are vicious and deadly, but the Skaven have a death frenzy upon them and will offer you no quarter: prepare your forces for murderous bloodshed!
				cm:show_advice("wh2.camp.prelude.ft.060.def");
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
		"script/battle/intro_battles/dark_elves/first/battle.xml",		-- entire battle override
		0,																-- human alliance when battle override
		false,															-- launch battle immediately
		true,															-- is land battle (only for launch battle immediately)
		true															-- force application of autoresolver result
	);
end;








