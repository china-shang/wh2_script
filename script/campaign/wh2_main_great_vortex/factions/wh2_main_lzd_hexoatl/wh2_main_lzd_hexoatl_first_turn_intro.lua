

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
	cm:teleport_to(player_char_str,  105, 371, true);
	
	-- remove all units from the player's starting army
	cm:remove_all_units_from_general(player_char);
	
	-- add customised unit setup
	cm:grant_unit_to_character(player_char_str, "wh2_main_lzd_inf_saurus_warriors_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_lzd_inf_saurus_warriors_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_lzd_inf_saurus_warriors_0");
	
	-- create initial enemy force
	cm:create_force_with_general(
		-- faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader, success_callback
		skeggi_faction_str,
		"wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0,wh_main_nor_inf_chaos_marauders_0",
		monolith_of_fallen_gods_region_str,
		initial_enemy_force_x,
		initial_enemy_force_y,
		"general",
		"nor_marauder_chieftain",
		"names_name_2147345615",		-- Aelfric
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
	local end_x = 80.4;
	local end_y = 295.5;
	local end_d = 20.9;
	local end_b = 0;
	local end_h = 14.3;
		
	local local_faction = cm:get_local_faction_name();
	
	-- make the enemy settlement visible throughout
	cm:make_region_visible_in_shroud(local_faction, monolith_of_fallen_gods_region_str);
	
	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",
		53,
		function() start_first_turn_intro(end_x, end_y, end_d, end_b, end_h) end
	);
	
	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true);
	cutscene_intro:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:set_camera_position(70.513824, 289.264557, 7.452576, 0, 4.101359);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			-- raise altitude
			cm:scroll_camera_from_current(false, 16.5, {70.513824, 289.264557, 13.8, 0.0, 11.0});
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			-- Do not be fooled by this form, Lord Mazdamundi of the Second Generation. I bring you knowledge of the Old Ones, for now is the time to enact the next stage of the Great Plan.
			cm:show_advice("wh2.camp.prelude.ft.001.lzd");
			show_first_turn_intro_infotext();
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			cm:scroll_camera_from_current(
				true, 
				34, 
				{75.4, 298.8, 7.7, 0.3, 5.3},
				{96.0, 292.5, 7.7, 0.4, 5.3},
				{end_x, end_y, end_d, end_b, end_h}				
			);
		end,
		17
	);
	
	cutscene_intro:wait_for_advisor(16.5);
	
	cutscene_intro:action(
		function()
			-- The warmbloods, or 'Norse' as they call themselves, have seen fit to trespass upon your jungles once again. They seek to ransack your sacred temples and carry off the treasure within to distant lands.
			cm:show_advice("wh2.camp.prelude.ft.002.lzd");
		end,
		17
	);
	
	cutscene_intro:wait_for_advisor(32.5);
	
	cutscene_intro:action(
		function()
			-- While the Solar City itself remains uncompromised, the enemy have rampaged across your wider territory, overrunning several smaller cities near the coast.
			cm:show_advice("wh2.camp.prelude.ft.003.lzd");
		end,
		33
	);
	
	cutscene_intro:wait_for_advisor(44);
	
	cutscene_intro:action(
		function()
			play_final_first_turn_intro_advice()
		end,
		44.5
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
	cm:show_advice("wh2.camp.prelude.ft.004.lzd");
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
	
	local settlement_hexoatl = cm:get_region(hexoatl_region_str):settlement();
	local camera_marker_player_capital = intro_campaign_camera_marker:new(
		"player_capital",
		settlement_hexoatl:display_position_x(),
		settlement_hexoatl:display_position_y(),
		22			-- cutscene duration
	);
	
	camera_marker_player_capital:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_player_capital:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(
				false,
				5,
				{66.257545, 288.699554, 7.452576, 0.0, 4.0}
			);
		end,
		0
	);
	
	camera_marker_player_capital:action(
		function()
			-- The city of the sun is well protected, enlightened Lord. Numberless scars on its outer walls bear witness to the enemy attacks it has repulsed over the millennia.
			cm:show_advice("wh2.camp.prelude.ft.010.lzd");
		end,
		0.5
	);
	
	camera_marker_player_capital:action(
		function()
			-- pan around settlement
			cm:scroll_camera_from_current(
				false, 
				5,
				{66.278625, 288.458435, 7.45258, 0.343998, 4.0}
			);
		end,
		5
	);
	
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				false,
				4,
				{69.4, 288.5, 7.5, -0.32, 4.2}
			);
		end,
		10
	);
	
	camera_marker_player_capital:wait_for_advisor(11);
	
	camera_marker_player_capital:action(
		function()
			-- Yet the warmbloods pour forward in great number. Be in no doubt that your capital is gravely threatened, my Lord.
			cm:show_advice("wh2.camp.prelude.ft.011.lzd");
		end,
		11.5
	);
		
	camera_marker_player_capital:action(
		function()
			cm:scroll_camera_from_current(
				false,
				6,
				{end_x, end_y, end_d, end_b, end_h}
			);
		end,
		16
	);
	
	
	
	--
	-- Enemy settlement marker
	--
	
	local settlement_monolith_of_fallen_gods = cm:get_region(monolith_of_fallen_gods_region_str):settlement();
	local camera_marker_enemy_settlement = intro_campaign_camera_marker:new(
		"enemy_settlement",
		settlement_monolith_of_fallen_gods:display_position_x(),
		settlement_monolith_of_fallen_gods:display_position_y(),
		12			-- cutscene duration
	);
	
	camera_marker_enemy_settlement:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_enemy_settlement:action(
		function()
			cm:make_region_visible_in_shroud(cm:get_local_faction_name(), monolith_of_fallen_gods_region_str);
		
			-- zoom to settlement
			cm:scroll_camera_from_current(false, 5, {92.207191, 306.204071, 11.632015, -0.014998, 4.804302});
		end,
		0
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- The Norscans have overrun a number of your monuments in the jungle interior. These are ancient centres of power, and that power cannot be allowed to remain in the hands of such children as the Skeggi!
			cm:show_advice("wh2.camp.prelude.ft.021.lzd");
		end,
		1
	);
		
	camera_marker_enemy_settlement:action(
		function()
			-- zoom to settlement
			cm:scroll_camera_from_current(false, 2.5, {92.207191, 306.204071, 11.632015, 0.2, 4.804302});
		end,
		5
	);
	
	camera_marker_enemy_settlement:action(
		function()
			-- return
			cm:scroll_camera_from_current(false, 5.5, {end_x, end_y, end_d, end_b, end_h});
		end,
		7.5
	);
	
	
	
	
	
	--
	-- Enemy army marker
	--
	
	local enemy_char = cm:get_closest_general_to_position_from_faction(skeggi_faction_str, initial_enemy_force_x, initial_enemy_force_y, false);
	local enemy_char_x = enemy_char:display_position_x();
	local enemy_char_y = enemy_char:display_position_y();
	local camera_marker_enemy_army = intro_campaign_camera_marker:new(
		"enemy_army",
		enemy_char_x,
		enemy_char_y,
		17,			-- cutscene duration
		3			-- trigger threshold override (default 5)
	);
	
	camera_marker_enemy_army:set_skip_camera(end_x, end_y, end_d, end_b, end_h);
	
	camera_marker_enemy_army:action(
		function()
			-- zoom to army
			cm:scroll_camera_from_current(false, 6, {74.3, 299.0, 7.5, 0.0, 4.0});
		end,
		0
	);
	
	camera_marker_enemy_army:action(
		function()
			-- Your kind have often had cause to discipline the Skeggi raiders that dwell on the edge of the jungle, but never have they marched against you in such numbers. It would seem that Sotek’s comet has incited the lesser races into acts of madness!
			cm:show_advice("wh2.camp.prelude.ft.020.lzd");
		end,
		0.5
	);
	
	camera_marker_enemy_army:action(
		function()
			-- zoom to army
			cm:scroll_camera_from_current(false, 5, {74.3, 299.0, 7.5, 0.21, 4.0});
		end,
		6
	);
	
	camera_marker_enemy_army:action(
		function()
			-- pan back
			cm:scroll_camera_from_current(false, 6, {end_x, end_y, end_d, end_b, end_h});
		end,
		11
	);
	
	
	

	
	--
	-- Container
	--
	
	local ca = intro_campaign_camera_positions_advice:new(
		-- Move the camera to inspect the points of interest
		"wh2.camp.camera_advice.001",
		function() start_select_and_attack_advice() end,
		{camera_marker_player_capital, camera_marker_enemy_settlement, camera_marker_enemy_army}
	);
	
	-- ca.should_skip = true;	-- uncomment to immdiately skip camera advice section
	ca:start();
end;










---------------------------------------------------------------
--	Select and Attack Advice
---------------------------------------------------------------


function start_select_and_attack_advice()

	-- find enemy target cqi
	local enemy_char = cm:get_closest_general_to_position_from_faction(skeggi_faction_str, initial_enemy_force_x, initial_enemy_force_y, false); 
	
	if not enemy_char then
		script_error("ERROR: start_select_and_attack_advice() could not find enemy character");
		return;
	end;
	
	local enemy_cqi = enemy_char:cqi();
	
	local sa = intro_campaign_select_and_attack_advice:new(
		-- player_cqi, enemy_cqi, initial_advice, selection_objective, attack_advice, attack_objective, end_callback
		player_legendary_lord_char_cqi,
		enemy_cqi,
		-- The Norse warmbloods have advanced too close to your position, revered Lord Mazdamundi. Now is the perfect time to attack. Select your army first.
		"wh2.camp.prelude.ft.040.lzd",
		"wh2.camp.army_selection_advice.001",
		-- Good! Now, issue an order to engage the enemy, my Lord. They are scattered, and are not prepared for an attack so soon.
		"wh2.camp.prelude.ft.050",
		"wh2.camp.attack_advice.001",
		function() attack_initiated() end
	);
	
	sa:set_camera_position_override(69.3, 292.6, 16.1, -1.2, 8.6);		-- x, y, d, b, h
	
	

	
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
				
				-- Battle is upon you, Lord Mazdamundi! The Norse are strong and savage, but your Saurus warriors are surely more deadly still. Blood shall be shed!
				cm:show_advice("wh2.camp.prelude.ft.060.lzd");
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
		"script/battle/intro_battles/lizardmen/first/battle.xml",		-- entire battle override
		0,																-- human alliance when battle override
		false,															-- launch battle immediately
		true,															-- is land battle (only for launch battle immediately)
		true															-- force application of autoresolver result
	);
end;








