-- Karl Franz, Threat from the North/Reikland Runefang, Defending 

load_script_libraries();

m = battle_manager:new(empire_battle:new());

local gc = generated_cutscene:new(true);

--generated_cutscene:add_element(sfx_name, subtitle, camera, min_length, wait_for_vo, wait_for_camera, taunt)
gc:add_element(nil, nil, "gc_medium_absolute_reikland_skull_pan_01_to_absolute_reikland_skull_pan_02", 9000, false, false, false);
gc:add_element("EMP_KF_GS_Qbattle_Prelude_reikland_runefang_pt_01", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_pt_01", nil, 4000, true, false, false);
gc:add_element("EMP_KF_GS_Qbattle_Prelude_reikland_runefang_pt_02", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_pt_02", "gc_medium_enemy_army_pan_front_left_to_front_right_medium_medium_02", 4000, true, false, true);
gc:add_element("EMP_KF_GS_Qbattle_Prelude_reikland_runefang_pt_04", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_pt_04", "gc_orbit_ccw_360_slow_commander_front_right_close_low_01", 4000, true, false, false);
gc:add_element("EMP_KF_GS_Qbattle_ghal_maraz_v5_pt_03", "wh_main_qb_emp_karl_franz_ghal_maraz_stage_4_pt_03", "gc_medium_absolute_reikland_distant_pan_01_to_absolute_reikland_distant_pan_02", 4000, true, false, true);

gb = generated_battle:new(
	false,                                      -- screen starts black
	false,                                      -- prevent deployment for player
	false,                                      	-- prevent deployment for ai
	function() gb:start_generated_cutscene(gc) end, 	-- intro cutscene function
	false                                      	-- debug mode
);

gb:set_cutscene_during_deployment(true);


Orc_Horn = new_sfx("EGX_Orc_Reinforcements_Horn");

-------GENERALS SPEECH--------


-------ARMY SETUP-------
ga_ai_01 = gb:get_army(gb:get_non_player_alliance_num(), 1); -- Initial Force
ga_ai_01_r1 = gb:get_army(gb:get_non_player_alliance_num(), 1, "reinforcement_1"); -- Reinforcements
ga_ai_02 = gb:get_army(gb:get_non_player_alliance_num(), 2); -- Reinforcements
ga_ai_02_r1	= gb:get_army(gb:get_non_player_alliance_num(), 2, "reinforcement_1"); -- Reinforcements
ga_ai_02_r2	= gb:get_army(gb:get_non_player_alliance_num(), 2, "reinforcement_2"); -- Reinforcements
ga_ai_03 = gb:get_army(gb:get_non_player_alliance_num(), 3); -- Reinforcements
ga_ai_03_r1 = gb:get_army(gb:get_non_player_alliance_num(), 3, "reinforcement_1"); -- Reinforcements


-------OBJECTIVES-------
gb:set_objective_on_message("deployment_started", "wh_main_qb_objective_defend_defeat_army");

-------HINTS-------
gb:queue_help_on_message("battle_started", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_hint_objective");

--gb:play_sound_on_message("reinforcements_1", Orc_Horn, v(-300, 100, -660), 2000);
gb:queue_help_on_message("reinforcements_2", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_hint_reinforcements", 13000, 2000, 2000);

--gb:play_sound_on_message("reinforcements_4", Orc_Horn, v(-300, 100, -660), 2000);
gb:queue_help_on_message("reinforcements_4", "wh_main_qb_emp_karl_franz_reikland_runefang_stage_3_hint_reinforcements_2", 13000, 2000, 2000);

-------ORDERS-------
gb:message_on_time_offset("reinforcements_1", 60000);
gb:message_on_time_offset("reinforcements_2", 240000);
gb:message_on_time_offset("reinforcements_3", 487500);
gb:message_on_time_offset("reinforcements_4", 511000);
gb:message_on_time_offset("reinforcements_5", 524200);
gb:message_on_time_offset("reinforcements_6", 531200);

ga_ai_01_r1:reinforce_on_message("reinforcements_1");
ga_ai_02:reinforce_on_message("reinforcements_2");	
ga_ai_02_r1:reinforce_on_message("reinforcements_3");
ga_ai_02_r2:reinforce_on_message("reinforcements_4");
ga_ai_03:reinforce_on_message("reinforcements_5");
ga_ai_03_r1:reinforce_on_message("reinforcements_6");