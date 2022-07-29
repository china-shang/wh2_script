




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
		12, 
		function() ft_cutscene_intro_ends() end,
		{cam_start_x, cam_start_y, 8.3, cam_start_b, 6.1},
		{cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h}
	);
	
	cm:callback(
		function() 
			-- The Greenskins run for their burrows, my Emperor. Their dead and dying litter the field. Altdorf is safe for now.
			cm:show_advice("war.camp.prelude.emp.ft.001");
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

	-- set up Grunburg lookat point
	local cutscene_grunburg = campaign_cutscene:new("grunburg", 7);
	cutscene_grunburg:action(function() cm:scroll_camera_from_current(false, 3, {346.7, 334.9, 5.6, 0.3, 4.0}) end, 0);
	cutscene_grunburg:action(function() cm:make_region_visible_in_shroud(local_faction, grunburg_region_str) end, 1);
	cutscene_grunburg:action(function() cm:scroll_camera_with_direction(true, 4, {346.7, 334.9, 5.6, 0.3, 4.0}, {346.7, 334.9, 5.6, 0.6, 4.0}) end, 3);
	
	local lookat_position_grunburg = {};
	lookat_position_grunburg.x, lookat_position_grunburg.y = cm:settlement_display_pos(grunburg_settlement_str);
	-- Secessionists hostile to your rule try to form a breakaway state to the south. They mobilise against you, and will march against Altdorf when their strength is sufficient.
	lookat_position_grunburg.advice = "war.camp.prelude.emp.ft.003";
	lookat_position_grunburg.cutscene = cutscene_grunburg;
	
	-- set up Middenheim lookat point 
	local cutscene_middenheim = campaign_cutscene:new("middenheim", 9);
	cutscene_middenheim:action(function() cm:scroll_camera_from_current(false, 3, {320.8, 360.3, 5.6, 0.4, 4.0}) end, 0);
	cutscene_middenheim:action(function() cm:scroll_camera_with_direction(true, 6, {320.8, 360.3, 5.6, 0.4, 4.0}, {320.8, 360.3, 5.6, 0.7, 4.0}) end, 3);
	
	local lookat_position_middenheim = {};
	lookat_position_middenheim.x, lookat_position_middenheim.y = cm:settlement_display_pos(carroburg_settlement_str);
	-- The lands to the north of the Reik are controlled from Middenheim, Sire. Elector Count Boris Todbringer, Graf of Middenheim, is no supporter of your claim to Altdorf.
	lookat_position_middenheim.advice = "war.camp.prelude.emp.ft.004";
	lookat_position_middenheim.cutscene = cutscene_middenheim;
	
	-- set up Marienburg lookat point 
	local cutscene_marienburg = campaign_cutscene:new("marienburg", 9);
	cutscene_marienburg:action(function() cm:scroll_camera_from_current(false, 5, {282.9, 361.6, 5.6, 0.0, 4.0}) end, 0);
	cutscene_marienburg:action(function() cm:make_region_visible_in_shroud(local_faction, marienburg_region_str) end, 1);
	cutscene_marienburg:action(function() cm:scroll_camera_with_direction(true, 4, {282.9, 361.6, 5.6, 0.0, 4.0}, {282.9, 361.6, 5.6, -0.2, 4.0}) end, 5);
	
	local lookat_position_marienburg = {};
	lookat_position_marienburg.x, lookat_position_marienburg.y = cm:settlement_display_pos(marienburg_settlement_str);
	-- The wealthy city of Marienburg lies to the west. It has broken away from the Empire, but would make for a glittering prize to reclaim for your burgeoning state.
	lookat_position_marienburg.advice = "war.camp.prelude.emp.ft.005";
	lookat_position_marienburg.cutscene = cutscene_marienburg;
	
	
	-- declare camera tutorial
	local ct = camera_tutorial:new(
		function() ft_start_movement_tutorial() end,		-- end callback
		lookat_position_grunburg,							-- lookat_positions ...
		lookat_position_middenheim,
		lookat_position_marienburg
	);
	
	-- start camera tutorial
	ct:start();
	
	-- The capital may be secure, yet many enemies still surround us. Survey the map for yourself.
	cm:show_advice("war.camp.prelude.emp.ft.002");
	cm:add_infotext(1, "war.camp.prelude.ft_camera_tutorial.info_001", "war.camp.prelude.ft_camera_tutorial.info_002", "war.camp.prelude.ft_camera_tutorial.info_003");
end;



function ft_start_movement_tutorial()
	out("ft_start_movement_tutorial() called");
		
	local mt = movement_tutorial:new(
		local_faction,													-- faction
		vip_cqi, 														-- character cqi
		vip_army_move_to_x, 											-- x destination (display co-ord)
		vip_army_move_to_y,												-- y destination (display co-ord)
		-- The secessionists cannot be allowed to defy your rule and field their own armies. The time to move against against them is now, Sire.
		"war.camp.prelude.emp.ft.006",									-- start advice
		"war.camp.prelude.emp.ft_movement_tutorial.obj_001",			-- selection objective key
		"war.camp.prelude.emp.ft_movement_tutorial.obj_002",			-- movement objective key
		-- Good! Such decisive action will leave the enemy in no doubt as to your intentions. They will be forced to fight, or to capitulate!
		"war.camp.prelude.emp.ft.007",									-- end advice
		function() ft_start_recruitment_tutorial() end					-- end callback
	);
	
	mt:start();
end;


function ft_start_recruitment_tutorial()
	local rt = recruitment_tutorial:new(
		local_faction,													-- faction name
		vip_cqi,														-- target char cqi
		"war.camp.prelude.emp.ft_recruitment_tutorial.obj_001",			-- selection objective
		-- More men stand ready to take up arms for your cause, sire. Recruit them, and they will be ready to fight in the battles that are to come.
		"war.camp.prelude.emp.ft.008",									-- start advice
		3,																-- number of units to recruit
		-- Excellent choices, all. Be aware that your army must remain stationary to train the new recruits.
		"war.camp.prelude.emp.ft.009",									-- end advice
		function() ft_start_province_panel_tutorial() end				-- end callback
	);
	rt:start();
	set_first_turn_resources_bar_allowed(true);
end;


function ft_start_province_panel_tutorial()
	local pp = province_panel_tutorial:new(
		-- Improvements may be made to your capital now that the threat to its security has receded. Altdorf must prosper if your empire is to flourish, my Lord.
		"war.camp.prelude.emp.ft.010",									-- start_advice
		"war.camp.prelude.emp.ft_province_panel_tutorial.obj_001",		-- objective
		altdorf_region_str,												-- region_name
		altdorf_province_str,											-- province_name
		function() ft_start_building_construction_tutorial() end		-- end_callback
	);
	pp:start();
end;


function ft_start_building_construction_tutorial()
	local ct = construction_tutorial:new(
		altdorf_region_str,												-- region_name
		altdorf_province_str,											-- province_name
		-- Upgrade your training facilities to allow you to field better forces against your enemies, Emperor.
		"war.camp.prelude.emp.ft.011",									-- start advice
		"war.camp.prelude.emp.ft_construction_tutorial.001",			-- start objective
		"wh_main_emp_barracks_1" .. local_faction,						-- base building card
		"wh_main_emp_barracks_2",										-- upgrade building card
		"war.camp.prelude.emp.ft_construction_tutorial.002",			-- upgrade objective
		-- Excellent! The Imperial Engineers will begin construction at once.
		"war.camp.prelude.emp.ft.012",									-- end advice
		function() ft_start_end_turn_tutorial() end						-- end callback
	);
	ct:start();
end;


function ft_start_end_turn_tutorial()
	local et = end_turn_tutorial:new(
		-- My Lord, there is nothing more we can do for now. Let us await the enemy's response.
		"war.camp.prelude.emp.ft.013",									-- start advice
		function() ft_player_ends_turn() end							-- end callback
	);
	et:start();
	
	cm:callback(function() play_component_animation("show", "faction_buttons_docker") end, 1);
end;

	






function ft_player_ends_turn()

	-- unrestrict building construction here
	cm:restrict_buildings_for_faction(local_faction, restricted_buildings_list, false);

	-- prevent Secessionists moving until we want
	cm:disable_movement_for_faction(secessionists_faction_str);
	
	-- Secessionists end-turn behaviour
	core:add_listener(
		"secessionists_end_turn",
		"FactionTurnStart",
		function(context) return context:faction():name() == secessionists_faction_str end,
		function() ft_secessionists_start_turn_one() end,
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




function ft_secessionists_start_turn_one()
	
	cm:disable_end_turn(true);
	
	local secessionists_mf_cqi = get_first_enemy_army_cqi();
	
	local model = cm:model();
	
	if not model:has_military_force_command_queue_index(secessionists_mf_cqi) then
		script_error("ERROR: ft_secessionists_start_turn_one() could not find secessionist military force");
		ft_secessionists_army_arrives_turn_one();
		return;
	end;
	
	local mf = model:military_force_for_command_queue_index(secessionists_mf_cqi);
	
	if not mf:has_general() then
		script_error("ERROR: ft_secessionists_start_turn_one() found secessionist military force but it has no general");
		ft_secessionists_army_arrives_turn_one();
		return;
	end;
	
	local secessionists_cqi = mf:general_character():cqi();
	local secessionists_char_str = cm:char_lookup_str(secessionists_cqi);
	
	cm:cai_disable_movement_for_character(secessionists_char_str);
	cm:enable_movement_for_character(secessionists_char_str);
	
	cm:move_character(
		secessionists_cqi, 
		enemy_army_move_to_x, 
		enemy_army_move_to_y, 
		true, 
		false, 
		function()
			ft_secessionists_army_arrives_turn_one(secessionists_char_str);
		end,
		function()
			script_error("WARNING: Secessionists army did not arrive at destination");
			ft_secessionists_army_arrives_turn_one(secessionists_char_str);
		end
	);
end;


function ft_secessionists_army_arrives_turn_one(char_str)
	cm:disable_movement_for_faction(secessionists_faction_str);
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
	start_empire_prelude();
end;



restricted_buildings_list = {
	"wh_main_emp_barracks_1",
	"wh_main_emp_barracks_3",
	"wh_main_emp_farm_basic_1",
	"wh_main_emp_farm_basic_2",
	"wh_main_emp_farm_basic_3",
	"wh_main_emp_forges_1",
	"wh_main_emp_forges_2",
	"wh_main_emp_forges_3",
	"wh_main_emp_garrison_1",
	"wh_main_emp_garrison_2",
	"wh_main_emp_industry_basic_1",
	"wh_main_emp_industry_basic_2",
	"wh_main_emp_industry_basic_3",
	"wh_main_emp_port_1",
	"wh_main_emp_port_2",
	"wh_main_emp_port_3",
	"wh_main_emp_resource_dyes_1",
	"wh_main_emp_resource_dyes_2",
	"wh_main_emp_resource_dyes_3",
	"wh_main_emp_resource_furs_1",
	"wh_main_emp_resource_furs_2",
	"wh_main_emp_resource_furs_3",
	"wh_main_emp_resource_gold_1",
	"wh_main_emp_resource_gold_2",
	"wh_main_emp_resource_gold_3",
	"wh_main_emp_resource_iron_1",
	"wh_main_emp_resource_iron_2",
	"wh_main_emp_resource_iron_3",
	"wh_main_emp_resource_iron_military",
	"wh_main_emp_resource_marble_1",
	"wh_main_emp_resource_marble_2",
	"wh_main_emp_resource_marble_3",
	"wh_main_emp_resource_pastures_1",
	"wh_main_emp_resource_pastures_2",
	"wh_main_emp_resource_pastures_3",
	"wh_main_emp_resource_pastures_military",
	"wh_main_emp_resource_pottery_1",
	"wh_main_emp_resource_pottery_2",
	"wh_main_emp_resource_pottery_3",
	"wh_main_emp_resource_salt_1",
	"wh_main_emp_resource_salt_2",
	"wh_main_emp_resource_salt_3",
	"wh_main_emp_resource_timber_1",
	"wh_main_emp_resource_timber_2",
	"wh_main_emp_resource_timber_3",
	"wh_main_emp_resource_timber_military",
	"wh_main_emp_resource_wine_1",
	"wh_main_emp_resource_wine_2",
	"wh_main_emp_resource_wine_3",
	"wh_main_emp_settlement_major_1",
	"wh_main_emp_settlement_major_1_coast",
	"wh_main_emp_settlement_major_2",
	"wh_main_emp_settlement_major_2_coast",
	"wh_main_emp_settlement_major_3",
	"wh_main_emp_settlement_major_3_coast",
	"wh_main_emp_settlement_major_4",
	"wh_main_emp_settlement_major_4_coast",
	"wh_main_emp_settlement_major_5",
	"wh_main_emp_settlement_major_5_coast",
	"wh_main_emp_settlement_minor_1",
	"wh_main_emp_settlement_minor_1_coast",
	"wh_main_emp_settlement_minor_2",
	"wh_main_emp_settlement_minor_2_coast",
	"wh_main_emp_settlement_minor_3",
	"wh_main_emp_settlement_minor_3_coast",
	"wh_main_emp_smiths_1",
	"wh_main_emp_smiths_2",
	"wh_main_emp_stables_1",
	"wh_main_emp_stables_2",
	"wh_main_emp_stables_3",
	"wh_main_emp_tavern_1",
	"wh_main_emp_tavern_2",
	"wh_main_emp_tavern_3",
	"wh_main_emp_walls_1",
	"wh_main_emp_walls_2",
	"wh_main_emp_walls_3",
	"wh_main_emp_wizards_1",
	"wh_main_emp_wizards_2",
	"wh_main_emp_worship_1",
	"wh_main_emp_worship_2",
	"wh_main_emp_worship_3",
	"wh_main_special_great_temple_of_ulric",
	"wh_main_special_settlement_altdorf_1_emp",
	"wh_main_special_settlement_altdorf_2_emp",
	"wh_main_special_settlement_altdorf_3_emp",
	"wh_main_special_settlement_altdorf_4_emp",
	"wh_main_special_settlement_altdorf_5_emp"
};
