-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- Morathi
-- Heartrender and the Darksword
-- Arnheim
-- Attacker

-------------------------------------------------------------------------------------------------
------------------------------------------- PRELOADS --------------------------------------------
-------------------------------------------------------------------------------------------------

load_script_libraries();
bm = battle_manager:new(empire_battle:new());

bm:camera():fade(true, 0);

gb = generated_battle:new(
	true,                                      		    -- screen starts black
	false,                                      		-- prevent deployment for player
	true,                                      		    -- prevent deployment for ai
	function() end_deployment_phase() end,          	-- intro cutscene function
	false                                      			-- debug mode
);

--preload stuttering fix
intro_cinematic_file = "script/battle/quest_battles/_cutscene/managers/hds.CindySceneManager";
bm:cindy_preload(intro_cinematic_file);
-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO VO & SUBS ----------------------------------------
-------------------------------------------------------------------------------------------------

wh2_main_sfx_01 = new_sfx("Play_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_01");
wh2_main_sfx_02 = new_sfx("Play_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_02");
wh2_main_sfx_03 = new_sfx("Play_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_03");
wh2_main_sfx_04 = new_sfx("Play_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_04");

-------------------------------------------------------------------------------------------------
------------------------------------------- CUTSCENE --------------------------------------------
-------------------------------------------------------------------------------------------------

function end_deployment_phase()
	bm:out("\tend_deployment_phase() called");
		
	local cam = bm:camera();
	
	-- REMOVE ME
	cam:fade(true, 0);
	
	-- declare cutscene
	local cutscene_intro = cutscene:new(
		"cutscene_intro", 						-- unique string name for cutscene
		ga_attacker_01.sunits,					-- unitcontroller over player's army
		36000, 									-- duration of cutscene in ms
		function() intro_cutscene_end() end		-- what to call when cutscene is finished
	);
	
	local player_units_hidden = false;
	
	-- set up subtitles
	local subtitles = cutscene_intro:subtitles();
	subtitles:set_alignment("bottom_centre");
	subtitles:clear();
	
	-- cutscene_intro:set_post_cutscene_fade_time(0);
	
	-- skip callback
	cutscene_intro:set_skippable(
		true, 
		function()
			local cam = bm:camera();
			cam:fade(true, 0);
			bm:stop_cindy_playback(true);
			
			if player_units_hidden then
				ga_attacker_01:set_enabled(true)
			end;
						
			bm:callback(function() cam:fade(false, 0.5) end, 500);
		end
	);
	
	-- set up actions on cutscene
	cutscene_intro:action(function() cam:fade(false, 1) end, 1000);
	
	-- cutscene_intro:action(function() cam:move_to(v(-781.747, 84.081, 5.09), v(-770.503, 81.635, 21.587), 0, false, 30) end, 0);	

	cutscene_intro:action(function() bm:cindy_playback("script/battle/quest_battles/_cutscene/managers/hds.CindySceneManager", true) end, 200);
	cutscene_intro:action(
		function()
			player_units_hidden = false;
			ga_attacker_01:set_enabled(true) 
		end, 
		200
	);	
	cutscene_intro:action(
		function() 
			player_units_hidden = false;
			ga_attacker_01:set_enabled(true) 
		end, 
		25000
	);		
	
	-- Voiceover and Subtitles --
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_01) end, 3000);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_01", "subtitle_with_frame", 5.5) end, 3100);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 9500);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_02) end, 10000);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_02", "subtitle_with_frame", 6.5) end, 10100);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 17200);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_03) end, 18000);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_03", "subtitle_with_frame", 6.5) end, 18100);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 26000);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_04) end, 26800);
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_pt_04", "subtitle_with_frame", 7) end, 26900);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 35900);
	

	
	cutscene_intro:start();
end;

function intro_cutscene_end()
	gb.sm:trigger_message("01_intro_cutscene_end")
end;

-------------------------------------------------------------------------------------------------
------------------------------------------ ARMY SETUP -------------------------------------------
-------------------------------------------------------------------------------------------------

ga_attacker_01 = gb:get_army(gb:get_player_alliance_num(), 1);
ga_defender_01 = gb:get_army(gb:get_non_player_alliance_num(), 1,"enemy_army");
ga_gate_first = gb:get_army(gb:get_non_player_alliance_num(), 2,"enemy_first");
ga_gate_second = gb:get_army(gb:get_non_player_alliance_num(), 2,"enemy_second");
ga_gate_third = gb:get_army(gb:get_non_player_alliance_num(), 2,"enemy_third");
ga_gate_fourth = gb:get_army(gb:get_non_player_alliance_num(), 2,"enemy_fourth");
ga_gate_fifth = gb:get_army(gb:get_non_player_alliance_num(), 2,"enemy_fifth");


-------------------------------------------------------------------------------------------------
-------------------------------------------- ORDERS ---------------------------------------------
-------------------------------------------------------------------------------------------------

--ga_defender_01:halt();
--ga_defender_01.sunits:change_behaviour_active("fire_at_will", false)
ga_defender_01:goto_location_offset_on_message("battle_started", 0, 50, false);
ga_attacker_01:goto_location_offset_on_message("battle_started", 0, 50, false);

ga_defender_01:message_on_proximity_to_enemy("attack", 360);
ga_defender_01:release_on_message("attack");


gb:message_on_time_offset("reinforcements", 220000);
ga_gate_first:release_on_message("reinforcements");
ga_gate_second:release_on_message("reinforcements");
ga_gate_third:release_on_message("reinforcements");
ga_gate_fourth:release_on_message("reinforcements");
ga_gate_fifth:release_on_message("reinforcements");
ga_defender_01:message_on_proximity_to_enemy("reinforcements", 50);
ga_gate_first:reinforce_on_message("reinforcements", 10000);
ga_gate_second:reinforce_on_message("reinforcements", 45000);
ga_gate_third:reinforce_on_message("reinforcements", 90000);
ga_gate_fourth:reinforce_on_message("reinforcements", 135000);
ga_gate_fifth:reinforce_on_message("reinforcements", 180000);




-------------------------------------------------------------------------------------------------
------------------------------------------- OBJECTIVES ------------------------------------------
-------------------------------------------------------------------------------------------------

gb:set_locatable_objective_on_message("01_intro_cutscene_end", "wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_hints_main_objective", 100, v(173, 356, 39), v(142, 364, 70), 2);    
gb:add_ping_icon_on_message("01_intro_cutscene_end", v(56, 349, 201), 15, 100, 5000);

-------------------------------------------------------------------------------------------------
--------------------------------------------- HINTS ---------------------------------------------
-------------------------------------------------------------------------------------------------
gb:queue_help_on_message("01_intro_cutscene_end", "wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_hints_advance", 6000, nil, 5000);
gb:queue_help_on_message("attack", "wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_hints_attack");
gb:queue_help_on_message("reinforcements", "wh2_main_qb_def_morathi_heartrender_and_the_darksword_stage_6_arnheim_hints_reinforcements", 10000, nil, 5000);

-------------------------------------------------------------------------------------------------
--------------------------------------------- MISC ----------------------------------------------
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
--------------------------------------------- VICTORY -------------------------------------------
-------------------------------------------------------------------------------------------------
