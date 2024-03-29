--Karl Franz, Bloodpine Intro, Attacker
load_script_libraries();

m = battle_manager:new(empire_battle:new());

local gc = generated_cutscene:new(true, true);

gb = generated_battle:new(
	false,                                      -- screen starts black
	false,                                      -- prevent deployment for player
	false,                                      	-- prevent deployment for ai
	function() gb:start_generated_cutscene(gc) end, 	-- intro cutscene function
	false                                      	-- debug mode
);


--generated_cutscene:add_element(sfx_name, subtitle, camera, min_length, wait_for_vo, wait_for_camera, loop_camera)
	gc:add_element(nil, nil, "gc_medium_absolute_bloodpine_church_01_to_absolute_bloodpine_church_02", 6000, false, false, false);
	
-- This stops the game playing the regular cutscene if the player has NOT brought Karl Franz into the battle.
if gb:get_army(gb:get_player_alliance_num(), 1):are_unit_types_in_army("wh_main_emp_cha_karl_franz_0", "wh_main_emp_cha_karl_franz_1", "wh_main_emp_cha_karl_franz_2", "wh_main_emp_cha_karl_franz_3", "wh_main_emp_cha_karl_franz_4") then
	gc:add_element("EMP_KF_GS_Qbattle_KF_Prelude_pt_01", "wh_main_qb_emp_karl_franz_intro_battle_of_bloodpine_woods_pt_01", nil, 6000, true, false, false);
	gc:add_element("EMP_KF_GS_Qbattle_KF_Prelude_pt_02", "wh_main_qb_emp_karl_franz_intro_battle_of_bloodpine_woods_pt_02", "gc_orbit_90_medium_commander_front_close_low_01", 4000, true, false, false);
	gc:add_element("EMP_KF_GS_Qbattle_KF_Prelude_pt_03", "wh_main_qb_emp_karl_franz_intro_battle_of_bloodpine_woods_pt_03", nil, 4000, true, false, false);
	gc:add_element("EMP_KF_GS_Qbattle_KF_Prelude_pt_04", "wh_main_qb_emp_karl_franz_intro_battle_of_bloodpine_woods_pt_04", "gc_medium_absolute_bloodpine_road_01_to_absolute_bloodpine_road_02", 4000, true, false, false);
	gc:add_element("EMP_KF_GS_Qbattle_KF_Prelude_pt_05", "wh_main_qb_emp_karl_franz_intro_battle_of_bloodpine_woods_pt_05", "qb_final_position_bloodpine", 4000, true, true, false);
else
	gc:add_element(nil, nil, "gc_slow_army_pan_front_left_to_front_right_close_medium_01", 6000, false, false, false);
	gc:add_element(nil, nil, "qb_final_position_bloodpine", 6000, false, true, false);
end

gb:set_cutscene_during_deployment(true);


Orc_Horn = new_sfx("EGX_Orc_Reinforcements_Horn");

-------GENERALS SPEECH--------


-------ARMY SETUP-------
ga_ai_01 = gb:get_army(gb:get_non_player_alliance_num(), 1); -- Initial Force of Middenheim
ga_ai_02 = gb:get_army(gb:get_non_player_alliance_num(), 2); -- Reinforcements Secessionists

-------OBJECTIVES-------
gb:set_objective_on_message("deployment_started", "wh_main_qb_emp_karl_franz_intro_main_objective");
gb:set_objective_on_message("deployment_started", "wh_main_qb_emp_karl_franz_intro_second_objective");
gb:complete_objective_on_message("initial_army_defeated", "wh_main_qb_emp_karl_franz_intro_main_objective");

-------HINTS-------
gb:queue_help_on_message("battle_started", "wh_main_qb_emp_karl_franz_intro_hint_objective", 8000, 2000, 1000);

gb:play_sound_on_message("initial_army_defeated", Orc_Horn, v(-300, 100, -660), 8000);
gb:queue_help_on_message("initial_army_defeated", "wh_main_qb_emp_karl_franz_intro_hint_reinforcements", 8000, 2000, 1000);


-------ORDERS-------
ga_ai_01:message_on_rout_proportion("initial_army_defeated", 0.7);

ga_ai_02:reinforce_on_message("initial_army_defeated");
-- Queued attack orders to we can make sure it get's given as early as possible.
ga_ai_02:attack_on_message("initial_army_defeated", 20000);
ga_ai_02:attack_on_message("initial_army_defeated", 30000);
ga_ai_02:attack_on_message("initial_army_defeated", 40000);




