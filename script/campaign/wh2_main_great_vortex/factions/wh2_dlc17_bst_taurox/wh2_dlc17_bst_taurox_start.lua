


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	Custom script for this faction starts here. This script loads in additional
--	scripts depending on the mode the campaign is being started in (first turn vs
--	open), sets up the faction_start object and does some other things
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

cam_start_x = 144.2;
cam_start_y = 435.1;
cam_start_d = 23.6;
cam_start_b = -0.44;
cam_start_h = 12.3;

---------------------------------------------------------------
--	Intro Cutscene
---------------------------------------------------------------

function cutscene_intro_play()
	out("cutscene_intro_play() called - first turn MAIN");
	
	local advice_to_play = {};
	advice_to_play[1] = "wh2_dlc17.camp.vortex.flyby.taurox.001";
	advice_to_play[2] = "wh2_dlc17.camp.vortex.flyby.taurox.002";
	advice_to_play[3] = "wh2_dlc17.camp.vortex.flyby.taurox.003";
	advice_to_play[4] = "wh2_dlc17.camp.vortex.flyby.taurox.004";
	advice_to_play[5] = "wh2_dlc17.camp.vortex.flyby.taurox.005";
	
	local cutscene_intro = campaign_cutscene:new(
		cm:get_local_faction_name(true) .. "_intro",					-- string name for this cutscene
		65.5,															-- length of cutscene in seconds
		function() start_open_campaign_from_intro_cutscene() end		-- end callback
	);

	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true, function() cutscene_intro_skipped(advice_to_play) end);
	cutscene_intro:set_skip_camera(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(false);
			cm:set_camera_position(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
			cutscene_intro:cindy_playback("script/campaign/wh2_main_great_vortex/factions/wh2_dlc17_bst_taurox/scenes/taurox_vortex_flyby_01.CindyScene", 0, 5);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[1]);
		end,
		1
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		12.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		13.0
	);
		
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		26
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		26.5
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		39
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		39.5
	);
	
		cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		52
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[5]);
		end,
		52.5
	);

	cutscene_intro:start();
end;

function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	-- clear advice history, and then show all the advice for the intro cutscene
	effect.clear_advice_session_history();
	for i = 1, #advice_to_play do
		cm:show_advice(advice_to_play[i]);
	end;
	
	cm:callback(function() cm:override_ui("disable_advice_audio", false) end, 0.5);
end;

---------------------------------------------------------------
--	Get CQI of player legendary lord
--	(and any other characters we want)
---------------------------------------------------------------

if cm:is_multiplayer() then
	out("MP campaign script loaded for " .. cm:get_local_faction_name(true));
else
	player_legendary_lord_char_cqi = cm:get_cached_value(
		"player_legendary_lord_char_cqi",
		function()
			local character = cm:get_faction(cm:get_local_faction_name()):faction_leader();
			if character then
				return character:cqi();
			end;
		end
	);

	out("SP campaign script loaded for " .. cm:get_local_faction_name() .. ", player_legendary_lord_char_cqi is " .. tostring(player_legendary_lord_char_cqi));
end;






---------------------------------------------------------------
--	Position the enemy army starts at in the full intro
---------------------------------------------------------------

initial_enemy_force_x = 527;
initial_enemy_force_y = 78;


---------------------------------------------------------------
--	Work out if we should be loading first-turn scripts
---------------------------------------------------------------

if cm:get_saved_value("bool_first_turn_main_completed") or core:svr_load_bool("sbool_player_has_just_completed_second_intro_battle") or (not cm:get_saved_value("bool_prelude_first_turn_was_loaded") and not core:svr_load_bool("sbool_player_selected_first_turn_intro_on_frontend")) then
	-- we've completed the first turn, or it was never selected, so load the open campaign script
	cm:set_saved_value("bool_first_turn_main_completed", true);
	core:svr_save_bool("sbool_player_has_just_completed_second_intro_battle", false);
	cm:load_global_script(cm:get_local_faction_name(true) .. "_open_start", true);
	
elseif cm:get_saved_value("bool_first_turn_intro_completed") then
	-- we've completed the first turn intro, so load the main first turn script
	cm:load_global_script(cm:get_local_faction_name(true) .. "_first_turn_main", true);
	cm:set_saved_value("bool_prelude_first_turn_was_loaded", true);			-- we set this value here as well, if the script has been jumped to it would mess up which units are granted to this army
else
	-- load part one of the first turn
	cm:load_global_script(cm:get_local_faction_name(true) .. "_first_turn_intro", true);
	cm:set_saved_value("bool_prelude_first_turn_was_loaded", true);
	cm:set_saved_value("first_turn_count_modifier", 1);
end;
	
-- set this value back to false, otherwise it could cause problems with loading from this into other savegames
core:svr_save_bool("sbool_player_selected_first_turn_intro_on_frontend", false);


---------------------------------------------------------------
--	First-Tick callbacks
---------------------------------------------------------------

cm:add_first_tick_callback_sp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new singleplayer game here
		

		
		cm:start_intro_cutscene_on_loading_screen_dismissed(function() cutscene_intro_play() end);
	end
);


cm:add_first_tick_callback_mp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new multiplayer game here
		core:add_listener(
			"set_camera_position_campaign_start",
			"ScriptEventStartGameAllFactionsCompleted",
			true,
			function()
				cm:set_camera_position(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
			end,
			true
		);
	end
);


cm:add_first_tick_callback_sp_each(
	function() 
		-- put faction-specific calls that should get triggered each time a singleplayer game loads here
		
		if cm:get_saved_value("bool_first_turn_main_completed") and cm:get_saved_value("bool_prelude_first_turn_was_loaded") and not cm:get_saved_value("bool_open_campaign_started_from_first_turn") then
			-- we are playing the first turn, and have completed the second battle - load into the open campaign
			start_open_campaign_from_intro_first_turn();
			
			cm:set_saved_value("bool_open_campaign_started_from_first_turn", true);
		end;
	end
);


cm:add_first_tick_callback_mp_each(
	function()
		-- put faction-specific calls that should get triggered each time a multiplayer game loads here
	end
);



---------------------------------------------------------------
--	Chapter objectives
---------------------------------------------------------------

if not cm:is_multiplayer() then
	local local_faction = cm:get_local_faction_name();
	
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_main_objective_skv_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_main_objective_skv_02");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_main_objective_skv_03");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_main_objective_skv_04");
end;