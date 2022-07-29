




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
		{cam_start_x, cam_start_y, 5.6, cam_start_b, 4.0},
		{cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h}
	);
	
	cm:callback(
		function() 
			-- Your sacred peak is secure, my lord. The mountains rumble at the march of your army. Yet the threat to your kind has scarcely diminished.
			cm:show_advice("war.camp.prelude.dwf.ft.001");
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

	-- set up Grungni lookat point
	local cutscene_grungni = campaign_cutscene:new("grungni", 17);
	cutscene_grungni:action(function() cm:scroll_camera_from_current(false, 10, {490.8, 276.6, 5.6, 1.01, 4.0}) end, 0);
	cutscene_grungni:action(function() cm:scroll_camera_with_direction(true, 7, {490.8, 276.6, 5.6, 1.01, 4.0}, {491.0, 276.0, 5.6, 1.59, 4.0}) end, 10);
	
	local lookat_position_grungni = {};
	lookat_position_grungni.x, lookat_position_grungni.y = cm:settlement_display_pos(pillars_of_grungni_settlement_str);
	-- The Greenskins of the Bloody Spearz continue to defile your most sacred monuments. They must be expelled from these mountains with all haste!
	lookat_position_grungni.advice = "war.camp.prelude.dwf.ft.003";
	lookat_position_grungni.cutscene = cutscene_grungni;
	
	-- set up Barak Varr lookat point 
	local cutscene_barak_varr = campaign_cutscene:new("barak_varr", 13);
	cutscene_barak_varr:action(function() cm:scroll_camera_from_current(false, 7, {450.4, 263.6, 5.6, 0.30, 4.0}) end, 0);
	cutscene_barak_varr:action(function() cm:make_region_visible_in_shroud(local_faction, varenka_hills_region_str) end, 0);
	cutscene_barak_varr:action(function() cm:scroll_camera_with_direction(true, 6, {450.4, 263.6, 5.6, 0.30, 4.0}, {451.1, 263.0, 5.6, 0.89, 4.0}) end, 7);
	
	local lookat_position_barak_varr = {};
	lookat_position_barak_varr.x, lookat_position_barak_varr.y = cm:settlement_display_pos(varenka_hills_settlement_str);
	-- The Dwarfs of Barak Varr look kindly upon your cause, my Lord. With sufficient persuasion they would likely join your struggle against the Greenskins.
	lookat_position_barak_varr.advice = "war.camp.prelude.dwf.ft.004";
	lookat_position_barak_varr.cutscene = cutscene_barak_varr;
	
	
	-- set up scabby eye lookat point 
	local cutscene_scabby_eye = campaign_cutscene:new("scabby_eye", 11);
	cutscene_scabby_eye:action(function() cm:scroll_camera_from_current(false, 6, {455.458893, 247.071716, 5.593533, 0.889995, 4.0}) end, 0);
	cutscene_scabby_eye:action(function() cm:make_region_visible_in_shroud(local_faction, barag_dawazbag_region_str) end, 0);
	cutscene_scabby_eye:action(function() cm:scroll_camera_with_direction(true, 5, {455.458893, 247.071716, 5.593533, 0.889995, 4.0}, {455.458893, 247.071716, 5.593533, 0.589995, 4.0}) end, 6);
	
	local lookat_position_scabby_eye = {};
	lookat_position_scabby_eye.x, lookat_position_scabby_eye.y = cm:settlement_display_pos(barag_dawazbag_settlement_str);
	-- The Scabby Eye tribe of Greenskins maintain their hostilities against you from their base upon the plains. Be sure to watch their movements carefully.
	lookat_position_scabby_eye.advice = "war.camp.prelude.dwf.ft.005";
	lookat_position_scabby_eye.cutscene = cutscene_scabby_eye;
	
	
	-- declare camera tutorial
	local ct = camera_tutorial:new(
		function() ft_start_movement_tutorial() end,		-- end callback
		lookat_position_grungni,							-- lookat_positions ...
		lookat_position_barak_varr,
		lookat_position_scabby_eye
	);
	
	-- start camera tutorial
	ct:start();
	
	-- The lands around us remain infested with Greenskins. See for yourself!
	cm:show_advice("war.camp.prelude.dwf.ft.002");
	cm:add_infotext(1, "war.camp.prelude.ft_camera_tutorial.info_001", "war.camp.prelude.ft_camera_tutorial.info_002", "war.camp.prelude.ft_camera_tutorial.info_003");
end;



function ft_start_movement_tutorial()
	out("ft_start_movement_tutorial() called");
		
	local mt = movement_tutorial:new(
		local_faction,													-- faction
		vip_cqi, 														-- character cqi
		vip_army_move_to_x, 											-- x destination (display co-ord)
		vip_army_move_to_y,												-- y destination (display co-ord)
		-- The Bloody Spearz cannot be allowed to regroup after their defeat. Press forward, and maintain the offensive.
		"war.camp.prelude.dwf.ft.006",									-- start advice
		"war.camp.prelude.dwf.ft_movement_tutorial.obj_001",			-- selection objective key
		"war.camp.prelude.dwf.ft_movement_tutorial.obj_002",			-- movement objective key
		-- Good! The enemy will no doubt have picked up your movements. They will be frantically barricading their hovels in preparation for your arrival.
		"war.camp.prelude.dwf.ft.007",									-- end advice
		function() ft_start_recruitment_tutorial() end					-- end callback
	);
	
	mt:start();
end;


function ft_start_recruitment_tutorial()
	local rt = recruitment_tutorial:new(
		local_faction,													-- faction name
		vip_cqi,														-- target char cqi
		"war.camp.prelude.dwf.ft_recruitment_tutorial.obj_001",			-- selection objective
		-- More of your kin stand ready to take up arms against the invaders, my Lord. Recruit them, and they will be ready to fight in the battles that are to come.
		"war.camp.prelude.dwf.ft.008",									-- start advice
		3,																-- number of units to recruit
		-- The recruits will make first-rate soldiers I'm sure. Until then, the army must remain in place to train them.
		"war.camp.prelude.dwf.ft.009",									-- end advice
		function() ft_start_province_panel_tutorial() end				-- end callback
	);
	rt:start();
	set_first_turn_resources_bar_allowed(true);
end;


function ft_start_province_panel_tutorial()
	local pp = province_panel_tutorial:new(
		-- Let us also look at improving our infrastructure at home. A solid base of operations will repay itself on the battlefront.
		"war.camp.prelude.dwf.ft.010",									-- start_advice
		"war.camp.prelude.dwf.ft_province_panel_tutorial.obj_001",		-- objective
		karaz_a_karak_region_str,										-- region_name
		karaz_a_karak_province_str,										-- province_name
		function() ft_start_building_construction_tutorial() end		-- end_callback
	);
	pp:start();
end;


function ft_start_building_construction_tutorial()
	local ct = construction_tutorial:new(
		karaz_a_karak_region_str,										-- region_name
		karaz_a_karak_province_str,										-- province_name
		-- Upgraded training facilities will allow you to better train your Dawi to fight, my Lord.
		"war.camp.prelude.dwf.ft.011",									-- start advice
		"war.camp.prelude.dwf.ft_construction_tutorial.001",			-- start objective
		"wh_main_dwf_barracks_1",										-- base building card
		"wh_main_dwf_barracks_2",										-- upgrade building card
		"war.camp.prelude.dwf.ft_construction_tutorial.002",			-- upgrade objective
		-- Excellent! Stout hands will be set to work immediately.
		"war.camp.prelude.dwf.ft.012",									-- end advice
		function() ft_start_technology_tutorial() end					-- end callback
	);
	ct:start();
end;


function ft_start_technology_tutorial()
	local tt = technology_tutorial:new(
		-- We must seek ways to further our methods of war if we are to drive the Greenskins from the mountains. Put your finest minds to work on improving your practises and knowledge.
		"war.camp.prelude.dwf.ft.013",									-- start advice
		-- Good! In time, the knowledge they will gain will surely aide our cause.
		"war.camp.prelude.dwf.ft.014",									-- end advice
		function() ft_start_end_turn_tutorial() end						-- end callback
	);
	tt:start();
	
	cm:callback(function() play_component_animation("show", "faction_buttons_docker") end, 1);
end;



function ft_start_end_turn_tutorial()
	local et = end_turn_tutorial:new(
		-- There is nothing more to do for now, my Lord. Let us see what actions the Spearz may take.
		"war.camp.prelude.dwf.ft.015",									-- start advice
		function() ft_player_ends_turn() end							-- end callback
	);
	et:start();
end;

	






function ft_player_ends_turn()

	-- unrestrict building construction here
	cm:restrict_buildings_for_faction(local_faction, restricted_buildings_list, false);

	-- prevent Bloody Spearz moving until we want
	cm:disable_movement_for_faction(bloody_spearz_faction_str);
	
	-- Bloody Spearz end-turn behaviour
	core:add_listener(
		"bloody_spearz_end_turn",
		"FactionTurnStart",
		function(context) return context:faction():name() == bloody_spearz_faction_str end,
		function() ft_bloody_spearz_start_turn_one() end,
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




function ft_bloody_spearz_start_turn_one()
	
	cm:disable_end_turn(true);
	
	local bloody_spearz_mf_cqi = get_first_enemy_army_cqi();
	
	local model = cm:model();
	
	if not model:has_military_force_command_queue_index(bloody_spearz_mf_cqi) then
		script_error("ERROR: ft_bloody_spearz_start_turn_one() could not find bloody spearz military force");
		ft_bloody_spearz_army_arrives_turn_one();
		return;
	end;
	
	local mf = model:military_force_for_command_queue_index(bloody_spearz_mf_cqi);
	
	if not mf:has_general() then
		script_error("ERROR: ft_bloody_spearz_start_turn_one() found bloody spearz military force but it has no general");
		ft_bloody_spearz_army_arrives_turn_one();
		return;
	end;
	
	local bloody_spearz_cqi = mf:general_character():cqi();
	local bloody_spearz_char_str = cm:char_lookup_str(bloody_spearz_cqi);
	
	cm:cai_disable_movement_for_character(bloody_spearz_char_str);
	cm:enable_movement_for_character(bloody_spearz_char_str);
	
	cm:move_character(
		bloody_spearz_cqi, 
		enemy_army_move_to_x, 
		enemy_army_move_to_y, 
		true, 
		false, 
		function()
			ft_bloody_spearz_army_arrives_turn_one(bloody_spearz_char_str);
		end,
		function()
			script_error("WARNING: Bloody Spearz army did not arrive at destination");
			ft_bloody_spearz_army_arrives_turn_one(bloody_spearz_char_str);
		end
	);
end;


function ft_bloody_spearz_army_arrives_turn_one(char_str)
	cm:disable_movement_for_faction(bloody_spearz_faction_str);
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
	start_dwarfs_prelude();
end;



restricted_buildings_list = {
	"wh_main_dwf_barracks_1",
	"wh_main_dwf_barracks_3",
	"wh_main_dwf_barracks_4",
	"wh_main_dwf_engineer_1",
	"wh_main_dwf_engineer_2",
	"wh_main_dwf_farm_1",
	"wh_main_dwf_farm_2",
	"wh_main_dwf_farm_3",
	"wh_main_dwf_farm_4",
	"wh_main_dwf_garrison_1",
	"wh_main_dwf_garrison_2",
	"wh_main_dwf_industry_1",
	"wh_main_dwf_industry_2",
	"wh_main_dwf_industry_3",
	"wh_main_dwf_industry_4",
	"wh_main_dwf_port_1",
	"wh_main_dwf_port_2",
	"wh_main_dwf_port_3",
	"wh_main_dwf_resource_beer_1",
	"wh_main_dwf_resource_beer_2",
	"wh_main_dwf_resource_beer_3",
	"wh_main_dwf_resource_beer_4",
	"wh_main_dwf_resource_dyes_1",
	"wh_main_dwf_resource_dyes_2",
	"wh_main_dwf_resource_dyes_3",
	"wh_main_dwf_resource_dyes_4",
	"wh_main_dwf_resource_game_1",
	"wh_main_dwf_resource_game_2",
	"wh_main_dwf_resource_game_3",
	"wh_main_dwf_resource_game_4",
	"wh_main_dwf_resource_gems_1",
	"wh_main_dwf_resource_gems_2",
	"wh_main_dwf_resource_gems_3",
	"wh_main_dwf_resource_gems_4",
	"wh_main_dwf_resource_gold_1",
	"wh_main_dwf_resource_gold_2",
	"wh_main_dwf_resource_gold_3",
	"wh_main_dwf_resource_gold_4",
	"wh_main_dwf_resource_iron_1",
	"wh_main_dwf_resource_iron_2",
	"wh_main_dwf_resource_iron_3",
	"wh_main_dwf_resource_iron_4",
	"wh_main_dwf_resource_iron_military",
	"wh_main_dwf_resource_marble_1",
	"wh_main_dwf_resource_marble_2",
	"wh_main_dwf_resource_marble_3",
	"wh_main_dwf_resource_marble_4",
	"wh_main_dwf_resource_pastures_1",
	"wh_main_dwf_resource_pastures_2",
	"wh_main_dwf_resource_pastures_3",
	"wh_main_dwf_resource_pastures_4",
	"wh_main_dwf_resource_salt_1",
	"wh_main_dwf_resource_salt_2",
	"wh_main_dwf_resource_salt_3",
	"wh_main_dwf_resource_salt_4",
	"wh_main_dwf_resource_salt_military",
	"wh_main_dwf_resource_timber_1",
	"wh_main_dwf_resource_timber_2",
	"wh_main_dwf_resource_timber_3",
	"wh_main_dwf_resource_timber_4",
	"wh_main_dwf_settlement_major_1",
	"wh_main_dwf_settlement_major_1_coast",
	"wh_main_dwf_settlement_major_2",
	"wh_main_dwf_settlement_major_2_coast",
	"wh_main_dwf_settlement_major_3",
	"wh_main_dwf_settlement_major_3_coast",
	"wh_main_dwf_settlement_major_4",
	"wh_main_dwf_settlement_major_4_coast",
	"wh_main_dwf_settlement_major_5",
	"wh_main_dwf_settlement_major_5_coast",
	"wh_main_dwf_settlement_minor_1",
	"wh_main_dwf_settlement_minor_1_coast",
	"wh_main_dwf_settlement_minor_2",
	"wh_main_dwf_settlement_minor_2_coast",
	"wh_main_dwf_settlement_minor_3",
	"wh_main_dwf_settlement_minor_3_coast",
	"wh_main_dwf_slayer_1",
	"wh_main_dwf_slayer_2",
	"wh_main_dwf_smith_1",
	"wh_main_dwf_smith_2",
	"wh_main_dwf_smith_3",
	"wh_main_dwf_tavern_1",
	"wh_main_dwf_tavern_2",
	"wh_main_dwf_tavern_3",
	"wh_main_dwf_trade_depot_1",
	"wh_main_dwf_trade_depot_2",
	"wh_main_dwf_wall_1",
	"wh_main_dwf_wall_2",
	"wh_main_dwf_wall_3",
	"wh_main_dwf_workshop_1",
	"wh_main_dwf_workshop_2",
	"wh_main_dwf_workshop_3",
	"wh_main_dwf_workshop_4",
	"wh_main_special_settlement_karaz_a_karak_1_dwf",
	"wh_main_special_settlement_karaz_a_karak_2_dwf",
	"wh_main_special_settlement_karaz_a_karak_3_dwf",
	"wh_main_special_settlement_karaz_a_karak_4_dwf",
	"wh_main_special_settlement_karaz_a_karak_5_dwf"
};