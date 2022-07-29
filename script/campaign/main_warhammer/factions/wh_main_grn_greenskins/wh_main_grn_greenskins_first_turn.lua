




-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	INTRO CUTSCENE
--
--	This function declares and configures the cutscene,
--	loads it with actions and plays it.
--	Customise it to suit.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


function ft_cutscene_intro_play()

	cm:cut_and_scroll_camera_with_cutscene(
		14, 
		function() ft_cutscene_intro_ends() end,
		{cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h},
		{483.5, 225.4, 15.4, 0, 12.5}
	);
	
	cm:callback(
		function() 
			-- Black Crag is yours, my savage lord. The cretinous Gorfang and his Red Fang brethren retreat to lick their wounds. The world lays open for conquest.
			cm:show_advice("war.camp.prelude.grn.ft.001");
			cm:add_infotext(1, "war.camp.prelude.ft_campaign_map.info_001", "war.camp.prelude.ft_campaign_map.info_002", "war.camp.prelude.ft_campaign_map.info_003");
		end, 
		1
	);
end;


function ft_cutscene_intro_ends()
	if core:is_tweaker_set("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS") then
		out("Tweaker DISABLE_PRELUDE_CAMPAIGN_SCRIPTS is set so not running any first-turn prelude scripts");
		return false;
	end;

	-- restrict building construction here
	cm:restrict_buildings_for_faction(local_faction, restricted_buildings_list, true);

	cm:modify_advice(true, true);
	cm:progress_on_advice_dismissed(function() ft_start_camera_tutorial() end, 1);
end;


function ft_start_camera_tutorial()

	-- set up iron rock lookat point
	local cutscene_iron_rock = campaign_cutscene:new("iron_rock", 11);
	cutscene_iron_rock:action(function() cm:scroll_camera_from_current(false, 5, {468.2, 232.7, 5.6, 0.92, 4.0}) end, 0);
	cutscene_iron_rock:action(function() cm:make_region_visible_in_shroud(local_faction, iron_rock_region_str) end, 1);
	cutscene_iron_rock:action(function() cm:scroll_camera_with_direction(true, 6, {468.2, 232.7, 5.6, 0.92, 4.0}, {468.2, 232.3, 5.6, 1.28, 4.0}) end, 5);
	
	local lookat_position_iron_rock = {};
	lookat_position_iron_rock.x, lookat_position_iron_rock.y = cm:settlement_display_pos(iron_rock_settlement_str);
	-- Word reaches us that Gorfang has retreated to his stronghold at Iron Rock. Even now he will be gathering his strength against you my lord.
	lookat_position_iron_rock.advice = "war.camp.prelude.grn.ft.003";
	lookat_position_iron_rock.cutscene = cutscene_iron_rock;
	
	
	-- set up crooked moon lookat point 
	local cutscene_crooked_moon = campaign_cutscene:new("crooked moon", 11);
	cutscene_crooked_moon:action(function() cm:scroll_camera_from_current(false, 6, {489.8, 209.6, 5.6, -0.14, 4.0}) end, 0);
	cutscene_crooked_moon:action(function() cm:scroll_camera_with_direction(true, 5, {489.8, 209.6, 5.6, -0.14, 4.0}, {490.6, 209.4, 5.6, 0.16, 4.0}) end, 6);
	
	local lookat_position_crooked_moon = {};
	lookat_position_crooked_moon.x, lookat_position_crooked_moon.y = cm:settlement_display_pos(karak_eight_peaks_settlement_str);
	-- The Crooked Moon tribe have agreed to stay out of our fight against the Red Fang, my lord. Time will tell if they are good to their word.
	lookat_position_crooked_moon.advice = "war.camp.prelude.grn.ft.004";
	lookat_position_crooked_moon.cutscene = cutscene_crooked_moon;
	
	
	-- set up valayas sorrow lookat point 
	local cutscene_valayas_sorrow = campaign_cutscene:new("valayas_sorrow", 9);
	cutscene_valayas_sorrow:action(function() cm:scroll_camera_from_current(false, 5, {473.3, 199.1, 5.6, 0.07, 4.0}) end, 0);
	cutscene_valayas_sorrow:action(function() cm:make_region_visible_in_shroud(local_faction, valayas_sorrow_region_str) end, 1);
	cutscene_valayas_sorrow:action(function() cm:scroll_camera_with_direction(true, 4, {473.3, 199.1, 5.6, 0.07, 4.0}, {473.7, 199.4, 5.6, 0.45, 4.0}) end, 5);
	
	local lookat_position_valayas_sorrow = {};
	lookat_position_valayas_sorrow.x = 472.8;
	lookat_position_valayas_sorrow.y = 198.9;
	-- The Red Fang maintain a fortress at Valaya's Sorrow from which they may launch attacks against us. It must fall!
	lookat_position_valayas_sorrow.advice = "war.camp.prelude.grn.ft.005";
	lookat_position_valayas_sorrow.cutscene = cutscene_valayas_sorrow;
	
	
	-- declare camera tutorial
	local ct = camera_tutorial:new(
		function() ft_start_movement_tutorial() end,		-- end callback
		lookat_position_iron_rock,							-- lookat_positions ...
		lookat_position_crooked_moon,
		lookat_position_valayas_sorrow
	);
	
	-- start camera tutorial
	ct:start();
	
	-- The Badlands are dominated by tribes of your green brethren. See for yourself!
	cm:show_advice("war.camp.prelude.grn.ft.002");
	cm:add_infotext(1, "war.camp.prelude.ft_camera_tutorial.info_001", "war.camp.prelude.ft_camera_tutorial.info_002", "war.camp.prelude.ft_camera_tutorial.info_003");
end;



function ft_start_movement_tutorial()
	out("ft_start_movement_tutorial() called");
		
	local mt = movement_tutorial:new(
		local_faction,													-- faction
		vip_cqi, 														-- character cqi
		vip_army_move_to_x, 											-- x destination (display co-ord)
		vip_army_move_to_y,												-- y destination (display co-ord)
		-- Gorfang cannot be allowed to sit behind his walls and raise another army. The time to move against his strongholds on the plains is now. Let us move out against him.
		"war.camp.prelude.grn.ft.006",									-- start advice
		"war.camp.prelude.grn.ft_movement_tutorial.obj_001",			-- selection objective key
		"war.camp.prelude.grn.ft_movement_tutorial.obj_002",			-- movement objective key
		-- Good! No doubt the Red Fang will be alerted to our advance. If it serves to spread panic amongst their forces, so much the better!
		"war.camp.prelude.grn.ft.007",									-- end advice
		function() ft_start_recruitment_tutorial() end					-- end callback
	);
	
	mt:start();
end;


function ft_start_recruitment_tutorial()
	local rt = recruitment_tutorial:new(
		local_faction,													-- faction name
		vip_cqi,														-- target char cqi
		"war.camp.prelude.grn.ft_recruitment_tutorial.obj_001",			-- selection objective
		"war.camp.prelude.grn.ft.008",									-- start advice
		3,																-- number of units to recruit
		-- An excellent choice. The recruits will begin their training immediately my Lord. The army must remain in place while their exercises continue.
		"war.camp.prelude.grn.ft.009",									-- end advice
		function() ft_start_province_panel_tutorial() end				-- end callback
	);
	rt:start();
	set_first_turn_resources_bar_allowed(true);
end;


function ft_start_province_panel_tutorial()
	local pp = province_panel_tutorial:new(
		"war.camp.prelude.grn.ft.010",									-- start_advice
		"war.camp.prelude.grn.ft_province_panel_tutorial.obj_001",		-- objective
		karak_drazh_region_str,											-- region_name
		karak_drazh_province_str,										-- province_name
		function() ft_start_building_construction_tutorial() end		-- end_callback
	);
	pp:start();
end;


function ft_start_building_construction_tutorial()
	local ct = construction_tutorial:new(
		karak_drazh_region_str,											-- region name
		karak_drazh_province_str,										-- province name
		"war.camp.prelude.grn.ft.011",									-- start advice
		"war.camp.prelude.grn.ft_construction_tutorial.001",			-- start objective
		"wh_main_grn_military_1",										-- base building card
		"wh_main_grn_military_2",										-- upgrade building card
		"war.camp.prelude.grn.ft_construction_tutorial.002",			-- upgrade objective
		"war.camp.prelude.grn.ft.012",									-- end advice
		function() ft_start_end_turn_tutorial() end						-- end callback
	);
	ct:start();
end;


function ft_start_end_turn_tutorial()
	local et = end_turn_tutorial:new(
		"war.camp.prelude.grn.ft.013",									-- start advice
		function() ft_player_ends_turn() end							-- end callback
	);
	et:start();
	
	cm:callback(function() play_component_animation("show", "faction_buttons_docker") end, 1);
end;

	






function ft_player_ends_turn()

	-- unrestrict building construction here
	cm:restrict_buildings_for_faction(local_faction, restricted_buildings_list, false);

	-- prevent the Red Fang moving until we want
	cm:disable_movement_for_faction(red_fang_faction_str);
	
	-- Red Fang end-turn behaviour
	core:add_listener(
		"red_fang_end_turn",
		"FactionTurnStart",
		function(context) return context:faction():name() == red_fang_faction_str end,
		function() ft_red_fang_starts_turn_one() end,
		false
	);
	
	core:add_listener(
		"second_turn_start",
		"FactionTurnStart",
		function(context) return context:faction():name() == local_faction end,
		function() ft_player_starts_turn_two() end,
		false
	);
end;




function ft_red_fang_starts_turn_one()
	
	cm:disable_end_turn(true);
	
	local red_fang_mf_cqi = get_first_enemy_army_cqi();
	
	local model = cm:model();
	
	if not model:has_military_force_command_queue_index(red_fang_mf_cqi) then
		script_error("ERROR: ft_red_fang_start_turn_one() could not find red fang military force");
		ft_red_fang_army_arrives_turn_one();
		return;
	end;
	
	local mf = model:military_force_for_command_queue_index(red_fang_mf_cqi);
	
	if not mf:has_general() then
		script_error("ERROR: ft_red_fang_start_turn_one() found red fang military force but it has no general");
		ft_red_fang_army_arrives_turn_one();
		return;
	end;
	
	local red_fang_cqi = mf:general_character():cqi();
	local red_fang_char_str = cm:char_lookup_str(red_fang_cqi);
	
	cm:cai_disable_movement_for_character(red_fang_char_str);
	cm:enable_movement_for_character(red_fang_char_str);
	
	cm:move_character(
		red_fang_cqi, 
		enemy_army_move_to_x, 
		enemy_army_move_to_y, 
		true, 
		false, 
		function()
			ft_red_fang_army_arrives_turn_one(red_fang_char_str);
		end,
		function()
			script_error("WARNING: Red Fang army did not arrive at destination");
			ft_red_fang_army_arrives_turn_one(red_fang_char_str);
		end
	);
end;



function ft_red_fang_army_arrives_turn_one(char_str)
	cm:disable_movement_for_faction(red_fang_faction_str);
	cm:disable_end_turn(false);
	cm:end_turn(false);
	
	if char_str then
		cm:cai_enable_movement_for_character(char_str);
	end;
end;





function ft_player_starts_turn_two()

	-- load the normal script in future
	cm:set_saved_value("bool_prelude_should_load_first_turn", false);

	-- disable bits of ui
	set_first_turn_ui_allowed(true, local_faction);
	
	-- kick off missions
	start_greenskins_prelude();
end;


restricted_buildings_list = {
	"wh_main_grn_boars_1",
	"wh_main_grn_boars_2",
	"wh_main_grn_boss_1",
	"wh_main_grn_boss_2",
	"wh_main_grn_boss_3",
	"wh_main_grn_farm_1",
	"wh_main_grn_farm_2",
	"wh_main_grn_farm_3",
	"wh_main_grn_forest_beasts_1",
	"wh_main_grn_forest_beasts_2",
	"wh_main_grn_forest_beasts_3",
	"wh_main_grn_garrison_1",
	"wh_main_grn_garrison_2",
	"wh_main_grn_industry_1",
	"wh_main_grn_industry_2",
	"wh_main_grn_industry_3",
	"wh_main_grn_military_1",
	"wh_main_grn_military_3",
	"wh_main_grn_military_4",
	"wh_main_grn_monsters_1",
	"wh_main_grn_monsters_2",
	"wh_main_grn_port_1",
	"wh_main_grn_port_2",
	"wh_main_grn_port_3",
	"wh_main_grn_port_ruin",
	"wh_main_grn_resource_gems_1",
	"wh_main_grn_resource_gems_2",
	"wh_main_grn_resource_gems_3",
	"wh_main_grn_resource_gold_1",
	"wh_main_grn_resource_gold_2",
	"wh_main_grn_resource_gold_3",
	"wh_main_grn_resource_iron_military",
	"wh_main_grn_resource_pasture_furs_military",
	"wh_main_grn_resource_timber_military",
	"wh_main_grn_settlement_major_1",
	"wh_main_grn_settlement_major_1_coast",
	"wh_main_grn_settlement_major_2",
	"wh_main_grn_settlement_major_2_coast",
	"wh_main_grn_settlement_major_3",
	"wh_main_grn_settlement_major_3_coast",
	"wh_main_grn_settlement_major_4",
	"wh_main_grn_settlement_major_4_coast",
	"wh_main_grn_settlement_major_5",
	"wh_main_grn_settlement_major_5_coast",
	"wh_main_grn_settlement_minor_1",
	"wh_main_grn_settlement_minor_1_coast",
	"wh_main_grn_settlement_minor_2",
	"wh_main_grn_settlement_minor_2_coast",
	"wh_main_grn_settlement_minor_3",
	"wh_main_grn_settlement_minor_3_coast",
	"wh_main_grn_settlement_ruin_major",
	"wh_main_grn_settlement_ruin_major_coast",
	"wh_main_grn_settlement_ruin_minor",
	"wh_main_grn_settlement_ruin_minor_coast",
	"wh_main_grn_shaman_1",
	"wh_main_grn_shaman_2",
	"wh_main_grn_walls_1",
	"wh_main_grn_walls_2",
	"wh_main_grn_walls_3",
	"wh_main_grn_workshop_1",
	"wh_main_grn_workshop_2",
	"wh_main_special_settlement_black_crag_1_grn",
	"wh_main_special_settlement_black_crag_2_grn",
	"wh_main_special_settlement_black_crag_3_grn",
	"wh_main_special_settlement_black_crag_4_grn",
	"wh_main_special_settlement_black_crag_5_grn",
	"wh_main_special_settlement_black_crag_grn_ruin"
};