--Ungrim, Slayer Crown 5, Attacker, Ancient Dragon Crown
load_script_libraries();

m = battle_manager:new(empire_battle:new());

local gc = generated_cutscene:new(true, true);

--generated_cutscene:add_element(sfx_name, subtitle, camera, min_length, wait_for_vo, wait_for_camera, loop_camera)
gc:add_element(nil, nil, "gc_medium_absolute_ancient_dragon_cave_intro", 4000, false, false, false);
gc:add_element("DWF_Un_GS_Qbattle_slayer_crown2_pt_01", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_pt_01", nil, 4000, true, false, false);
gc:add_element("DWF_Un_GS_Qbattle_slayer_crown2_pt_02", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_pt_02", "gc_slow_army_pan_back_left_to_back_right_far_high_01", 4000, true, false, false);
gc:add_element("DWF_Un_GS_Qbattle_slayer_crown2_pt_03", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_pt_03", nil, 4000, true, false, false);
gc:add_element("DWF_Un_GS_Qbattle_slayer_crown2_pt_04", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_pt_04", "qb_final_position_short", 4000, true, true, false);

gb = generated_battle:new(
	false,                                      -- screen starts black
	false,                                      -- prevent deployment for player
	false,                                      -- prevent deployment for ai
	function() gb:start_generated_cutscene(gc) end, 	-- intro cutscene function
	false                                      	-- debug mode
);

gb:set_cutscene_during_deployment(true);


Orc_Horn = new_sfx("EGX_Orc_Reinforcements_Horn");

-------GENERALS SPEECH--------


-------ARMY SETUP-------
ga_player_01 = gb:get_army(gb:get_player_alliance_num(), 1);

ga_ai_01 = gb:get_army(gb:get_non_player_alliance_num(), 1);
ga_ai_02 = gb:get_army(gb:get_non_player_alliance_num(), 2);

ga_ai_02.army:suppress_reinforcement_adc();

-------OBJECTIVES-------
gb:set_objective_on_message("deployment_started", "wh_main_qb_objective_attack_defeat_army");
gb:set_objective_on_message("reinforce", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_6_secondary_objective", 36000);

-------HINTS-------
gb:play_sound_on_message("reinforce", Orc_Horn, v(-300, 100, -660), 3000);
gb:queue_help_on_message("battle_started", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_6_hint_objective", 4000, 2000, 1000);
gb:queue_help_on_message("reinforce", "wh_main_qb_dwf_ungrim_ironfist_slayer_crown_stage_5_6_hint_reinforcements", 5000, 2000, 36000);

-------ORDERS-------
ga_player_01:message_on_proximity_to_enemy("reinforce", 10);
ga_ai_02:reinforce_on_message("reinforce", 30000);