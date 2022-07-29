





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
		13, 
		function() ft_cutscene_intro_ends() end,
		{cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h},
		{cam_start_x, cam_start_y, 14.8, cam_start_b, 12.0}
		
		
	);
	
	cm:callback(
		function() 
			-- Drakenhof is secure, my lord. The interloper from the Templehof brood has fled back to his fortress. His lands lay open for conquest.
			cm:show_advice("war.camp.prelude.vmp.ft.001");
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

	-- set up Castle Templehof lookat point
	local cutscene_templehof = campaign_cutscene:new("castle_templehof", 9);
	cutscene_templehof:action(function() cm:scroll_camera_from_current(false, 4, {439.587097, 339.424316, 10.489349, 0.0, 8.0}) end, 0);
	cutscene_templehof:action(function() cm:make_region_visible_in_shroud(local_faction, castle_templehof_region_str) end, 1);
	cutscene_templehof:action(function() cm:scroll_camera_with_direction(true, 5, {439.587097, 339.424316, 10.489349, 0.0, 8.0}, {439.587097, 339.424316, 10.489349, -0.2, 8.0}) end, 4);
	
	local lookat_position_templehof = {};
	lookat_position_templehof.x, lookat_position_templehof.y = cm:settlement_display_pos(castle_templehof_settlement_str);
	-- Van Kruger has retreated to his fortress at Castle Templehof. It will take some effort to wrench him out.
	lookat_position_templehof.advice = "war.camp.prelude.vmp.ft.003";
	lookat_position_templehof.cutscene = cutscene_templehof;
	
	
	-- set up Schwartzhafen lookat point 
	local cutscene_schwartzhafen = campaign_cutscene:new("schwartzhafen", 10);
	cutscene_schwartzhafen:action(function() cm:scroll_camera_from_current(false, 5, {431.1, 311.8, 5.6, 0.47, 4.0}) end, 0);
	cutscene_schwartzhafen:action(function() cm:make_region_visible_in_shroud(local_faction, schwartzhafen_region_str) end, 1);
	cutscene_schwartzhafen:action(function() cm:scroll_camera_with_direction(true, 5, {431.1, 311.8, 5.6, 0.47, 4.0}, {430.9, 312.0, 5.6, 0.65, 4.0}) end, 5);
	
	local lookat_position_schwartzhafen = {};
	lookat_position_schwartzhafen.x, lookat_position_schwartzhafen.y = cm:settlement_display_pos(schwartzhafen_settlement_str);
	-- Passage to the west is blocked by the enemy at Schwartzhafen, my Lord. Nonetheless, the garrison there is weak and not easily supported.
	lookat_position_schwartzhafen.advice = "war.camp.prelude.vmp.ft.004";
	lookat_position_schwartzhafen.cutscene = cutscene_schwartzhafen;
	
	
	-- set up zhufbar lookat point 
	local cutscene_zhufbar = campaign_cutscene:new("zhufbar", 9);
	cutscene_zhufbar:action(function() cm:scroll_camera_from_current(false, 4, {471.484344, 313.31955, 5.593521, 0, 4.0}) end, 0);
	cutscene_zhufbar:action(function() cm:scroll_camera_with_direction(true, 5, {471.484344, 313.31955, 5.593521, 0, 4.0}, {471.484344, 313.31955, 5.593521, 0.2, 4.0}) end, 4);
	
	local lookat_position_zhufbar = {};
	lookat_position_zhufbar.x, lookat_position_zhufbar.y = cm:settlement_display_pos(zhufbar_settlement_str);
	-- The Dwarves control the mountain passes to the south. They are no friends of your kind, and will strike out at you if allowed.
	lookat_position_zhufbar.advice = "war.camp.prelude.vmp.ft.005";
	lookat_position_zhufbar.cutscene = cutscene_zhufbar;
	
	
	-- declare camera tutorial
	local ct = camera_tutorial:new(
		function() ft_start_movement_tutorial() end,		-- end callback
		lookat_position_templehof,							-- lookat_positions ...
		lookat_position_schwartzhafen,
		lookat_position_zhufbar
	);
	
	-- start camera tutorial
	ct:start();
	
	-- Enemies abound on all sides, my Lord. See for yourself.
	cm:show_advice("war.camp.prelude.vmp.ft.002");
	cm:add_infotext(1, "war.camp.prelude.ft_camera_tutorial.info_001", "war.camp.prelude.ft_camera_tutorial.info_002", "war.camp.prelude.ft_camera_tutorial.info_003");
end;



function ft_start_movement_tutorial()
	out("ft_start_movement_tutorial() called");
		
	local mt = movement_tutorial:new(
		local_faction,													-- faction
		vip_cqi, 														-- character cqi
		vip_army_move_to_x, 											-- x destination (display co-ord)
		vip_army_move_to_y,												-- y destination (display co-ord)
		-- Van Kruger cannot be allowed time to raise more forces against you. Let us advance against the Templehof's, seize their possessions and turn their dead against their former masters!
		"war.camp.prelude.vmp.ft.006",									-- start advice
		"war.camp.prelude.vmp.ft_movement_tutorial.obj_001",			-- selection objective key
		"war.camp.prelude.vmp.ft_movement_tutorial.obj_002",			-- movement objective key
		-- Excellent! Our movements will not have gone unnoticed. The enemy will no doubt be hard at work planning maneuvers of their own.
		"war.camp.prelude.vmp.ft.007",									-- end advice
		function() ft_start_recruitment_tutorial() end					-- end callback
	);
	
	-- override duration of initial camera scroll
	mt.initial_t = 9;
	
	mt:start();
end;


function ft_start_recruitment_tutorial()
	local rt = recruitment_tutorial:new(
		local_faction,													-- faction name
		vip_cqi,														-- target char cqi
		"war.camp.prelude.vmp.ft_recruitment_tutorial.obj_001",			-- selection objective
		-- Your forces are depleted by battle, my Lord, yet such a shortfall is easily overcome by your kind. Raise the slain to fight at your banner! March upon the enemy with their own men!
		"war.camp.prelude.vmp.ft.008",									-- start advice
		3,																-- number of units to recruit
		-- Your army must remain in place whilst raising new bodies to fight. Soon it will be swollen with the eager dead, my Lord.
		"war.camp.prelude.vmp.ft.009",									-- end advice
		function() ft_start_province_panel_tutorial() end				-- end callback
	);
	rt:start();
	set_first_turn_resources_bar_allowed(true);
end;


function ft_start_province_panel_tutorial()
	local pp = province_panel_tutorial:new(
		-- Let us also look at improving our infrastructure at home. A solid base of operations will repay itself on the battlefront.
		"war.camp.prelude.vmp.ft.010",									-- start_advice
		"war.camp.prelude.vmp.ft_province_panel_tutorial.obj_001",		-- objective
		castle_drakenhof_region_str,									-- region_name
		castle_drakenhof_province_str,									-- province_name
		function() ft_start_building_construction_tutorial() end		-- end_callback
	);
	pp:start();
end;


function ft_start_building_construction_tutorial()
	local ct = construction_tutorial:new(
		castle_drakenhof_region_str,									-- region_name
		castle_drakenhof_province_str,									-- province_name
		-- Provide more room for the dead to rest and you gain more souls to resurrect. See that the necessary expansion is made.
		"war.camp.prelude.vmp.ft.011",									-- start advice
		"war.camp.prelude.vmp.ft_construction_tutorial.001",			-- start objective
		"wh_main_vmp_cemetary_1" .. local_faction,						-- base building card
		"wh_main_vmp_cemetary_2",										-- upgrade building card
		"war.camp.prelude.vmp.ft_construction_tutorial.002",			-- upgrade objective
		-- Excellent! Construction will begin immediately. 
		"war.camp.prelude.vmp.ft.012",									-- end advice
		function() ft_start_technology_tutorial() end					-- end callback
	);
	ct:start();
end;


function ft_start_technology_tutorial()
	local tt = technology_tutorial:new(
		-- Seek ways to further your knowledge of the dark arts, my Lord. Put your most devious minds to work on improving your methods of war.
		"war.camp.prelude.vmp.ft.013",									-- start advice
		-- Good! In time, the knowledge they will gain will surely aide our cause.
		"war.camp.prelude.vmp.ft.014",									-- end advice
		function() ft_start_end_turn_tutorial() end						-- end callback
	);
	tt:start();
	
	cm:callback(function() play_component_animation("show", "faction_buttons_docker") end, 1);
end;


function ft_start_end_turn_tutorial()
	local et = end_turn_tutorial:new(
		-- My Lord, there is nothing more we can do for now. Let us await our enemy's next move.
		"war.camp.prelude.vmp.ft.015",									-- start advice
		function() ft_player_ends_turn() end							-- end callback
	);
	et:start();
end;

	






function ft_player_ends_turn()

	-- unrestrict building construction here
	cm:restrict_buildings_for_faction(local_faction, restricted_buildings_list, false);

	-- prevent Templehof's moving until we want
	cm:disable_movement_for_faction(templehof_faction_str);
	
	-- Templehof end-turn behaviour
	core:add_listener(
		"red_fang_end_turn",
		"FactionTurnStart",
		function(context) return context:faction():name() == templehof_faction_str end,
		function() ft_templehof_start_turn_one() end,
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




function ft_templehof_start_turn_one()
	
	cm:disable_end_turn(true);
	
	local templehof_mf_cqi = get_first_enemy_army_cqi();
	
	local model = cm:model();
	
	if not model:has_military_force_command_queue_index(templehof_mf_cqi) then
		script_error("ERROR: ft_templehof_start_turn_one() could not find templehof military force");
		ft_templehof_army_arrives_turn_one();
		return;
	end;
	
	local mf = model:military_force_for_command_queue_index(templehof_mf_cqi);
	
	if not mf:has_general() then
		script_error("ERROR: ft_templehof_start_turn_one() found templehof military force but it has no general");
		ft_templehof_army_arrives_turn_one();
		return;
	end;
	
	local templehof_cqi = mf:general_character():cqi();
	local templehof_char_str = cm:char_lookup_str(templehof_cqi);
	
	cm:cai_disable_movement_for_character(templehof_char_str);
	cm:enable_movement_for_character(templehof_char_str);
	
	cm:move_character( 
		templehof_cqi, 
		enemy_army_move_to_x, 
		enemy_army_move_to_y, 
		true, 
		false, 
		function()
			ft_templehof_army_arrives_turn_one(templehof_char_str);
		end,
		function()
			script_error("WARNING: Templehof army did not arrive at destination");
			ft_templehof_army_arrives_turn_one(templehof_char_str);
		end
	);
end;


function ft_templehof_army_arrives_turn_one(char_str)
	cm:disable_movement_for_faction(templehof_faction_str);
	cm:disable_end_turn(false);
	cm:end_turn(false);
	
	if char_str then
		cm:cai_enable_movement_for_character(char_str);
	end;
end;




function ft_player_starts_turn_two()
	-- load the normal script in future
	cm:set_saved_value("bool_prelude_should_load_first_turn", false);
	
	-- re-enable ui
	set_first_turn_ui_allowed(true, local_faction);
	
	-- kick off missions
	start_vampire_counts_prelude();
end;



restricted_buildings_list = {
	"wh_main_special_settlement_castle_drakenhof_1_vmp",
	"wh_main_special_settlement_castle_drakenhof_2_vmp",
	"wh_main_special_settlement_castle_drakenhof_3_vmp",
	"wh_main_special_settlement_castle_drakenhof_4_vmp",
	"wh_main_special_settlement_castle_drakenhof_5_vmp",
	"wh_main_vmp_armoury_1",
	"wh_main_vmp_armoury_2",
	"wh_main_vmp_balefire_1",
	"wh_main_vmp_balefire_2",
	"wh_main_vmp_balefire_3",
	"wh_main_vmp_bindingcircle_1",
	"wh_main_vmp_bindingcircle_2",
	"wh_main_vmp_bindingcircle_3",
	"wh_main_vmp_cemetary_1",
	-- "wh_main_vmp_cemetary_2",
	"wh_main_vmp_cemetary_3",
	"wh_main_vmp_forest_1",
	"wh_main_vmp_forest_2",
	"wh_main_vmp_forest_3",
	"wh_main_vmp_garrison_1",
	"wh_main_vmp_garrison_2",
	"wh_main_vmp_necromancers_1",
	"wh_main_vmp_necromancers_2",
	"wh_main_vmp_ossuary_1",
	"wh_main_vmp_ossuary_2",
	"wh_main_vmp_ossuary_3",
	"wh_main_vmp_port_1",
	"wh_main_vmp_port_2",
	"wh_main_vmp_port_3",
	"wh_main_vmp_port_ruin",
	"wh_main_vmp_repression_1",
	"wh_main_vmp_repression_2",
	"wh_main_vmp_resource_dyes_1",
	"wh_main_vmp_resource_dyes_2",
	"wh_main_vmp_resource_dyes_3",
	"wh_main_vmp_resource_furs_1",
	"wh_main_vmp_resource_furs_2",
	"wh_main_vmp_resource_furs_3",
	"wh_main_vmp_resource_gold_1",
	"wh_main_vmp_resource_gold_2",
	"wh_main_vmp_resource_gold_3",
	"wh_main_vmp_resource_iron_1",
	"wh_main_vmp_resource_iron_2",
	"wh_main_vmp_resource_iron_3",
	"wh_main_vmp_resource_iron_military",
	"wh_main_vmp_resource_marble_1",
	"wh_main_vmp_resource_marble_2",
	"wh_main_vmp_resource_marble_3",
	"wh_main_vmp_resource_pastures_1",
	"wh_main_vmp_resource_pastures_2",
	"wh_main_vmp_resource_pastures_3",
	"wh_main_vmp_resource_pastures_timber_military",
	"wh_main_vmp_resource_pottery_1",
	"wh_main_vmp_resource_pottery_2",
	"wh_main_vmp_resource_pottery_3",
	"wh_main_vmp_resource_salt_1",
	"wh_main_vmp_resource_salt_2",
	"wh_main_vmp_resource_salt_3",
	"wh_main_vmp_resource_timber_1",
	"wh_main_vmp_resource_timber_2",
	"wh_main_vmp_resource_timber_3",
	"wh_main_vmp_resource_wine_1",
	"wh_main_vmp_resource_wine_2",
	"wh_main_vmp_resource_wine_3",
	"wh_main_vmp_settlement_major_1",
	"wh_main_vmp_settlement_major_1_coast",
	"wh_main_vmp_settlement_major_2",
	"wh_main_vmp_settlement_major_2_coast",
	"wh_main_vmp_settlement_major_3",
	"wh_main_vmp_settlement_major_3_coast",
	"wh_main_vmp_settlement_major_4",
	"wh_main_vmp_settlement_major_4_coast",
	"wh_main_vmp_settlement_major_5",
	"wh_main_vmp_settlement_major_5_coast",
	"wh_main_vmp_settlement_minor_1",
	"wh_main_vmp_settlement_minor_1_coast",
	"wh_main_vmp_settlement_minor_2",
	"wh_main_vmp_settlement_minor_2_coast",
	"wh_main_vmp_settlement_minor_3",
	"wh_main_vmp_settlement_minor_3_coast",
	"wh_main_vmp_vampires_1",
	"wh_main_vmp_vampires_2",
	"wh_main_vmp_walls_1",
	"wh_main_vmp_walls_2",
	"wh_main_vmp_walls_3"
};
