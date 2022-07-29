


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

cam_start_x = 348.7;
cam_start_y = 330.9;
cam_start_d = 10;
cam_start_b = 0;
cam_start_h = 10;

---------------------------------------------------------------
--	Intro Cutscene
---------------------------------------------------------------

function cutscene_intro_play()
	out("cutscene_intro_play() called - first turn MAIN");
	
	local advice_to_play = {};
	advice_to_play[1] = "wh2.camp.vortex.tyrion.intro.001";
	advice_to_play[2] = "wh2.camp.vortex.tyrion.intro.002";
	advice_to_play[3] = "wh2.camp.vortex.tyrion.intro.003";
	advice_to_play[4] = "wh2.camp.vortex.tyrion.intro.004";
	
	local cutscene_intro_length = 54.5;
	
	local cutscene_intro = campaign_cutscene:new(
		cm:get_local_faction_name(true) .. "_intro",							-- string name for this cutscene
		cutscene_intro_length,											-- length of cutscene in seconds
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
			cm:set_camera_position(344.6, 332.6, 8.6, 0, 5.0);
			cm:set_camera_position(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
			cutscene_intro:cindy_playback("script/campaign/wh2_main_great_vortex/factions/wh2_main_hef_eataine/scenes/eataine_flyover_s01.CindyScene", 0, 5);
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
		11.8
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		12.3
	);
		
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		28.0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		28.5
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		42.8
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		43.3
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		cutscene_intro_length
	);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(true);
		end, 
		cutscene_intro_length
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
end







---------------------------------------------------------------
--	Position the enemy army starts at in the full intro
---------------------------------------------------------------

initial_enemy_force_x = 504;
initial_enemy_force_y = 429;

second_enemy_force_start_x = 533;
second_enemy_force_start_y = 422;




---------------------------------------------------------------
--	create second enemy force
---------------------------------------------------------------

function create_second_enemy_force()
	cm:create_force_with_general(
		-- faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader, success_callback
		cult_of_excess_faction_str,
		"wh2_main_def_inf_dreadspears_0,wh2_main_def_inf_dreadspears_0,wh2_main_def_inf_bleakswords_0,wh2_main_def_inf_bleakswords_0,wh2_main_def_inf_darkshards_0,wh2_main_def_art_reaper_bolt_thrower",
		glittering_tower_region_str,
		second_enemy_force_start_x,
		second_enemy_force_start_y,
		"general",
		"wh2_main_def_dreadlord",
		"names_name_2147359554",		-- Khalek
		"",
		"",
		"",
		false
	);
end;







---------------------------------------------------------------
--	Work out if we should be loading first-turn scripts
---------------------------------------------------------------

if cm:get_saved_value("bool_first_turn_main_completed") or core:svr_load_bool("sbool_player_has_just_completed_second_intro_battle") or (not cm:get_saved_value("bool_prelude_first_turn_was_loaded") and not core:svr_load_bool("sbool_player_selected_first_turn_intro_on_frontend")) then
	-- we've completed the first turn, or it was never selected, so load the open campaign script
	cm:set_saved_value("bool_first_turn_main_completed", true);
	core:svr_save_bool("sbool_player_has_just_completed_second_intro_battle", false);
	cm:load_global_script(cm:get_local_faction_name(true) .. "_open_start", true);				-- sp only
	
elseif cm:get_saved_value("bool_first_turn_intro_completed") then
	-- we've completed the first turn intro, so load the main first turn script
	cm:load_global_script(cm:get_local_faction_name(true) .. "_first_turn_main", true);			-- sp only
	cm:set_saved_value("bool_prelude_first_turn_was_loaded", true);			-- we set this value here as well, if the script has been jumped to it would mess up which units are granted to this army
else
	-- load part one of the first turn
	cm:load_global_script(cm:get_local_faction_name(true) .. "_first_turn_intro", true);		-- sp only
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
		
		if cm:get_saved_value("bool_prelude_first_turn_was_loaded") then
			-- set the public order in the player's starting settlement to be low, if we are starting the first-turn intro
			cm:set_public_order_of_province_for_region(lothern_region_str, -10);
		end;
		
		-- set enemy faction personality
		cm:force_change_cai_faction_personality(cult_of_excess_faction_str, "wh_script_foolishly_brave");
		
		cm:start_intro_cutscene_on_loading_screen_dismissed(
			function()
				cm:show_benchmark_if_required(
					function() cutscene_intro_play() end,
					"script/benchmarks/vortex_campaign/scenes/wh2_camp_pan_benchmark.CindyScene",
					92.83,
					cam_start_x,
					cam_start_y,
					cam_start_d,
					cam_start_b,
					cam_start_h
				);
			end
		);
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
	
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_main_objective_hef_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_main_objective_hef_02");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_main_objective_hef_03");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_main_objective_hef_04");
end;