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

cam_start_x = 220.4;
cam_start_y = 301.6;
cam_start_d = 9.6;
cam_start_b = 0;
cam_start_h = 7.2

---------------------------------------------------------------
--	Intro Cutscene
---------------------------------------------------------------

function cutscene_intro_play()
	out("cutscene_intro_play() called - first turn MAIN");
	
	local advice_to_play = {};
	advice_to_play[1] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.001"
	advice_to_play[2] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.002"
	advice_to_play[3] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.003"
	advice_to_play[4] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.004"
	advice_to_play[5] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.005"
	advice_to_play[6] = "wh2_dlc11.camp.vortex.Count_Noctilus.intro.006"
	
	local cutscene_intro = campaign_cutscene:new(
		cm:get_local_faction_name(true) .. "_intro",							-- string name for this cutscene
		89,																-- length of cutscene in seconds
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
			cutscene_intro:cindy_playback("script/campaign/wh2_main_great_vortex/factions/wh2_dlc11_cst_noctilus/scenes/noctilus_flyby_01_vortex.CindyScene", 0, 5);
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
			cutscene_intro:wait_for_advisor();
		end,
		15.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		16
	);
		
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor();
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
			cutscene_intro:wait_for_advisor();
		end,
		41.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		42
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor();
		end,
		54
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[5]);
		end,
		54.5
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor();
		end,
		68.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[6]);
		end,
		69
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
--	Loading faction scripts
---------------------------------------------------------------

cm:load_global_script(cm:get_local_faction_name(true) .. "_open_start", true);				-- sp only

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
	
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_main_objective_def_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_main_objective_def_02");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_main_objective_def_03");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_main_objective_def_04");
end;