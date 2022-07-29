

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	HELP PAGE SCRIPTS
--	Battle help pages are defined here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function setup_battle_help_pages()

	out.help_pages("");
	out.help_pages("***");
	out.help_pages("*** setup_battle_help_pages() called");
	out.help_pages("***");

	--	Setup link parser
	--	This parses [[sl:link]]text[[/sl]] links in help page records	
	local parser = get_link_parser();	
	
	-- Set up help page to info button mapping
	-- (this is for the ? button on each panel)
	local hpm = get_help_page_manager();
	
	-- first argument is the help page link name, second is a unique parent name of the button (doesn't have to be immediate parent)
	-- optional third argument is a component to test if visible, as it seems that unique parent is not enough of a test >:0(
	--[[
	hpm:register_help_page_to_info_button_mapping("script_link_campaign_army_panel", "main_units_panel");
	]]
	
	hpm:set_display_game_guide_links(false);
	
	local bm = get_bm();
	local uim = bm:get_battle_ui_manager();
	
	--
	-- advanced_controls
	--
	
	hp_advanced_controls = help_page:new(
		"script_link_battle_advanced_controls",
		hpr_header("war.battle.hp.advanced_controls.001"),
		hpr_normal("war.battle.hp.advanced_controls.002"),
		hpr_bulleted("war.battle.hp.advanced_controls.003"),
		hpr_bulleted("war.battle.hp.advanced_controls.004"),
		hpr_bulleted("war.battle.hp.advanced_controls.005"),
		hpr_bulleted("war.battle.hp.advanced_controls.006"),
		hpr_bulleted("war.battle.hp.advanced_controls.007")
	);
	parser:add_record("battle_advanced_controls", "script_link_battle_advanced_controls", "tooltip_battle_advanced_controls");
	tp_advanced_controls = tooltip_patcher:new("tooltip_battle_advanced_controls");
	tp_advanced_controls:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_advanced_controls", "ui_text_replacements_localised_text_hp_battle_description_advanced_controls");
	
	
	
	--
	-- advice_history_buttons
	--

	parser:add_record("battle_advice_history_buttons", "script_link_battle_advice_history_buttons", "tooltip_battle_advice_history_buttons");
	tp_advice_history_buttons = tooltip_patcher:new("tooltip_battle_advice_history_buttons");
	tp_advice_history_buttons:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_campaign_description_advice_history_buttons");
	
	tl_advisor_history_buttons = tooltip_listener:new(
		"tooltip_battle_advice_history_buttons", 
		function() 
			uim:highlight_advice_history_buttons(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- advisor
	--
	
	hp_advisor = help_page:new(
		"script_link_battle_advisor",
		hpr_header("war.battle.hp.advisor.001"),
		hpr_normal("war.battle.hp.advisor.002"),
		hpr_bulleted("war.battle.hp.advisor.003"),
		hpr_bulleted("war.battle.hp.advisor.004"),
		hpr_bulleted("war.battle.hp.advisor.005")
	);
	parser:add_record("battle_advisor", "script_link_battle_advisor", "tooltip_battle_advisor");
	tp_advisor = tooltip_patcher:new("tooltip_battle_advisor");
	tp_advisor:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_advisor", "ui_text_replacements_localised_text_hp_battle_description_advisor");
	
	tl_advisor = tooltip_listener:new(
		"tooltip_battle_advisor", 
		function() 
			uim:highlight_advisor(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- advisor_link
	--
	
	parser:add_record("battle_advisor_link", "script_link_battle_advisor_link", "tooltip_battle_advisor_link");
	tp_advisor_link = tooltip_patcher:new("tooltip_battle_advisor_link");
	tp_advisor_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_advisor_link");
	
	tl_advisor_link = tooltip_listener:new(
		"tooltip_battle_advisor_link", 
		function() 
			uim:highlight_advisor(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
		
	

	--
	-- ambush_battles
	--
	
	hp_ambush_battles = help_page:new(
		"script_link_battle_ambush_battles",
		hpr_header("war.battle.hp.ambush_battles.001"),
		hpr_normal("war.battle.hp.ambush_battles.002"),
		hpr_bulleted("war.battle.hp.ambush_battles.003")
	);
	parser:add_record("battle_ambush_battles", "script_link_battle_ambush_battles", "tooltip_battle_ambush_battles");
	tp_ambush_battles = tooltip_patcher:new("tooltip_battle_ambush_battles");
	tp_ambush_battles:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_ambush_battles", "ui_text_replacements_localised_text_hp_battle_description_ambush_battles");
	
	
	--
	-- armies
	--
	
	hp_armies = help_page:new(
		"script_link_battle_armies",
		hpr_header("war.battle.hp.armies.001"),
		hpr_normal("war.battle.hp.armies.002"),
		hpr_bulleted("war.battle.hp.armies.003"),
		hpr_bulleted("war.battle.hp.armies.004"),
		hpr_bulleted("war.battle.hp.armies.005"),
		hpr_bulleted("war.battle.hp.armies.006"),
		hpr_bulleted("war.battle.hp.armies.007")
	);
	parser:add_record("battle_armies", "script_link_battle_armies", "tooltip_battle_armies");
	tp_armies = tooltip_patcher:new("tooltip_battle_armies");
	tp_armies:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_armies", "ui_text_replacements_localised_text_hp_battle_description_armies");
	
	
	
	
	
	--
	-- army_abilities
	--
	
	hp_army_abilities = help_page:new(
		"script_link_battle_army_abilities",
		hpr_header("war.battle.hp.army_abilities.001"),
		hpr_normal("war.battle.hp.army_abilities.002"),
		hpr_bulleted("war.battle.hp.army_abilities.003")
	);
	parser:add_record("battle_army_abilities", "script_link_battle_army_abilities", "tooltip_battle_army_abilities");
	tp_army_abilities = tooltip_patcher:new("tooltip_battle_army_abilities");
	tp_army_abilities:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_army_abilities", "ui_text_replacements_localised_text_hp_battle_description_army_abilities");
	
	tl_army_abilities = tooltip_listener:new(
		"tooltip_battle_army_abilities", 
		function() 
			uim:highlight_army_abilities(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- army_abilities_link
	--
	
	parser:add_record("battle_army_abilities_link", "script_link_battle_army_abilities_link", "tooltip_battle_army_abilities_link");
	tp_army_abilities_link = tooltip_patcher:new("tooltip_battle_army_abilities_link");
	tp_army_abilities_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_army_abilities_title_link");
	
	tl_army_abilities_link = tooltip_listener:new(
		"tooltip_battle_army_abilities_link", 
		function() 
			uim:highlight_army_abilities(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- army_panel
	--

	parser:add_record("battle_army_panel", "script_link_battle_army_panel", "tooltip_battle_army_panel");
	tp_army_panel = tooltip_patcher:new("tooltip_battle_army_panel");
	tp_army_panel:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_bottom_panel");
	
	tl_army_panel = tooltip_listener:new(
		"tooltip_battle_army_panel", 
		function() 
			uim:highlight_army_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- artillery
	--
	
	hp_artillery = help_page:new(
		"script_link_battle_artillery",
		hpr_header("war.battle.hp.artillery.001"),
		hpr_normal("war.battle.hp.artillery.002"),
		hpr_bulleted("war.battle.hp.artillery.003"),
		hpr_bulleted("war.battle.hp.artillery.004"),
		hpr_bulleted("war.battle.hp.artillery.005")
	);
	parser:add_record("battle_artillery", "script_link_battle_artillery", "tooltip_battle_artillery");
	tp_artillery = tooltip_patcher:new("tooltip_battle_artillery");
	tp_artillery:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_artillery", "ui_text_replacements_localised_text_hp_battle_description_artillery");
	
	
	
	--
	-- balance_of_power
	--

	parser:add_record("battle_balance_of_power", "script_link_battle_balance_of_power", "tooltip_battle_balance_of_power");
	tp_balance_of_power = tooltip_patcher:new("tooltip_battle_balance_of_power");
	tp_balance_of_power:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_top_item");
	
	tl_balance_of_power = tooltip_listener:new(
		"tooltip_battle_balance_of_power", 
		function() 
			uim:highlight_balance_of_power(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- controls_cheat_sheet
	--
	
	hp_controls_cheat_sheet = help_page:new(
		"script_link_battle_controls_cheat_sheet",
		hpr_header("war.battle.hp.controls_cheat_sheet.001"),
		hpr_battle_camera_controls("war.battle.hp.controls_cheat_sheet.002"),
		hpr_battle_camera_facing_controls("war.battle.hp.controls_cheat_sheet.003"),
		hpr_battle_camera_altitude_controls("war.battle.hp.controls_cheat_sheet.004")
		
		--[[
		hpr_battle_camera_speed_controls("war.battle.hp.controls_cheat_sheet.005")
		hpr_header("war.battle.hp.controls_cheat_sheet.006"),
		hpr_battle_selection_controls("war.battle.hp.controls_cheat_sheet.007"),
		hpr_battle_multiple_selection_controls("war.battle.hp.controls_cheat_sheet.008"),
		hpr_header("war.battle.hp.controls_cheat_sheet.009"),
		hpr_battle_movement_controls("war.battle.hp.controls_cheat_sheet.010"),
		hpr_battle_drag_out_formation_controls("war.battle.hp.controls_cheat_sheet.011"),
		hpr_battle_unit_destination_controls("war.battle.hp.controls_cheat_sheet.012"),
		hpr_battle_halt_controls("war.battle.hp.controls_cheat_sheet.013"),
		hpr_battle_attack_controls("war.battle.hp.controls_cheat_sheet.014")
		]]
	);
	parser:add_record("battle_controls_cheat_sheet", "script_link_battle_controls_cheat_sheet", "tooltip_battle_controls_cheat_sheet");
	-- tp_controls_cheat_sheet = tooltip_patcher:new("tooltip_battle_controls_cheat_sheet");
	-- tp_controls_cheat_sheet:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_controls_cheat_sheet", "ui_text_replacements_localised_text_hp_battle_description_controls_cheat_sheet");
	
	

	--
	-- battle_game
	--
	
	hp_battle_game = help_page:new(
		"script_link_battle_battle_game",
		hpr_header("war.battle.hp.battle_game.001"),
		hpr_normal("war.battle.hp.battle_game.002"),
		hpr_bulleted("war.battle.hp.battle_game.003"),
		hpr_bulleted("war.battle.hp.battle_game.004"),
		hpr_bulleted("war.battle.hp.battle_game.005"),
		hpr_bulleted("war.battle.hp.battle_game.006"),
		hpr_bulleted("war.battle.hp.battle_game.007")
	);
	parser:add_record("battle_battle_game", "script_link_battle_battle_game", "tooltip_battle_battle_game");
	tp_battle_game = tooltip_patcher:new("tooltip_battle_battle_game");
	tp_battle_game:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_battle_game", "ui_text_replacements_localised_text_hp_battle_description_battle_game");
	
	
	

	--
	-- battle_interface
	--
	
	hp_battle_interface = help_page:new(
		"script_link_battle_battle_interface",
		hpr_header("war.battle.hp.battle_interface.001"),
		hpr_normal("war.battle.hp.battle_interface.002"),
		hpr_bulleted("war.battle.hp.battle_interface.003"),
		hpr_bulleted("war.battle.hp.battle_interface.004"),
		hpr_bulleted("war.battle.hp.battle_interface.005"),
		hpr_bulleted("war.battle.hp.battle_interface.006"),
		hpr_bulleted("war.battle.hp.battle_interface.007")
	);
	parser:add_record("battle_battle_interface", "script_link_battle_battle_interface", "tooltip_battle_battle_interface");
	tp_battle_interface = tooltip_patcher:new("tooltip_battle_battle_interface");
	tp_battle_interface:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_battle_interface", "ui_text_replacements_localised_text_hp_battle_description_battle_interface");
	
	
	

	--
	-- battlefield
	--
	
	hp_battlefield = help_page:new(
		"script_link_battle_battlefield",
		hpr_header("war.battle.hp.battlefield.001"),
		hpr_normal("war.battle.hp.battlefield.002"),
		hpr_bulleted("war.battle.hp.battlefield.003"),
		hpr_bulleted("war.battle.hp.battlefield.004")
	);
	parser:add_record("battle_battlefield", "script_link_battle_battlefield", "tooltip_battle_battlefield");
	tp_battlefield = tooltip_patcher:new("tooltip_battle_battlefield");
	tp_battlefield:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_battlefield", "ui_text_replacements_localised_text_hp_battle_description_battlefield");
	
	
	
	--
	-- camera_controls
	--
	
	hp_camera_controls = help_page:new(
		"script_link_battle_camera_controls",
		hpr_header("war.battle.hp.camera_controls.001"),
		hpr_normal("war.battle.hp.camera_controls.002"),
		hpr_bulleted("war.battle.hp.camera_controls.003"),
		hpr_bulleted("war.battle.hp.camera_controls.004"),
		hpr_bulleted("war.battle.hp.camera_controls.005"),
		hpr_bulleted("war.battle.hp.camera_controls.006"),
		hpr_bulleted("war.battle.hp.camera_controls.007")
	);
	parser:add_record("battle_camera_controls", "script_link_battle_camera_controls", "tooltip_battle_camera_controls");
	tp_camera_controls = tooltip_patcher:new("tooltip_battle_camera_controls");
	tp_camera_controls:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_camera_controls", "ui_text_replacements_localised_text_hp_battle_description_camera_controls");
	
	
	

	--
	-- capture_points
	--
	
	hp_capture_points = help_page:new(
		"script_link_battle_capture_points",
		hpr_header("war.battle.hp.capture_points.001"),
		hpr_normal("war.battle.hp.capture_points.002"),
		hpr_bulleted("war.battle.hp.capture_points.003"),
		hpr_bulleted("war.battle.hp.capture_points.004"),
		hpr_bulleted("war.battle.hp.capture_points.005"),
		hpr_bulleted("war.battle.hp.capture_points.006")
	);
	parser:add_record("battle_capture_points", "script_link_battle_capture_points", "tooltip_battle_capture_points");
	tp_capture_points = tooltip_patcher:new("tooltip_battle_capture_points");
	tp_capture_points:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_capture_points", "ui_text_replacements_localised_text_hp_battle_description_capture_points");
	
	
	

	--
	-- deployment
	--
	
	hp_deployment = help_page:new(
		"script_link_battle_deployment",
		hpr_header("war.battle.hp.deployment.001"),
		hpr_normal("war.battle.hp.deployment.002"),
		hpr_bulleted("war.battle.hp.deployment.003"),
		hpr_bulleted("war.battle.hp.deployment.004"),
		hpr_bulleted("war.battle.hp.deployment.005"),
		hpr_bulleted("war.battle.hp.deployment.006")
	);
	parser:add_record("battle_deployment", "script_link_battle_deployment", "tooltip_battle_deployment");
	tp_deployment = tooltip_patcher:new("tooltip_battle_deployment");
	tp_deployment:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_deployment", "ui_text_replacements_localised_text_hp_battle_description_deployment");
	
	
	
	--
	-- drop_equipment_button
	--

	parser:add_record("battle_drop_equipment_button", "script_link_battle_drop_equipment_button", "tooltip_battle_drop_equipment_button");
	tp_drop_equipment_button = tooltip_patcher:new("tooltip_battle_drop_equipment_button");
	tp_drop_equipment_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_drop_siege_equipment_button");
	
	tl_drop_equipment_button = tooltip_listener:new(
		"tooltip_battle_drop_equipment_button", 
		function() 
			uim:highlight_drop_equipment_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	--
	-- extra_powder
	--
	
	hp_extra_powder = help_page:new(
		"script_link_battle_extra_powder",
		hpr_header("war.battle.hp.extra_powder.001"),
		hpr_normal("war.battle.hp.extra_powder.002"),
		hpr_bulleted("war.battle.hp.extra_powder.003"),
		hpr_bulleted("war.battle.hp.extra_powder.004"),
		hpr_bulleted("war.battle.hp.extra_powder.005")
	);
	parser:add_record("battle_extra_powder", "script_link_battle_extra_powder", "tooltip_battle_extra_powder");
	tp_extra_powder = tooltip_patcher:new("tooltip_battle_extra_powder");
	tp_extra_powder:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_extra_powder", "ui_text_replacements_localised_text_hp_battle_description_extra_powder");
	
	
	
	--
	-- fire_at_will
	--
	
	hp_fire_at_will = help_page:new(
		"script_link_battle_fire_at_will",
		hpr_header("war.battle.hp.fire_at_will.001"),
		hpr_normal("war.battle.hp.fire_at_will.002"),
		hpr_bulleted("war.battle.hp.fire_at_will.003"),
		hpr_bulleted("war.battle.hp.fire_at_will.004")
	);
	parser:add_record("battle_fire_at_will", "script_link_battle_fire_at_will", "tooltip_battle_fire_at_will");
	tp_fire_at_will = tooltip_patcher:new("tooltip_battle_fire_at_will");
	tp_fire_at_will:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_fire_at_will", "ui_text_replacements_localised_text_hp_battle_description_fire_at_will");
	
	tl_fire_at_will = tooltip_listener:new(
		"tooltip_battle_fire_at_will", 
		function() 
			uim:highlight_fire_at_will_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- fire_at_will_link
	--
	
	parser:add_record("battle_fire_at_will_link", "script_link_battle_fire_at_will_link", "tooltip_battle_fire_at_will_link");
	tp_fire_at_will_link = tooltip_patcher:new("tooltip_battle_fire_at_will_link");
	tp_fire_at_will_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_fire_at_will_link");
	
	tl_fire_at_will_link = tooltip_listener:new(
		"tooltip_battle_fire_at_will_link", 
		function() 
			uim:highlight_fire_at_will_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- fire_at_will_button
	--

	parser:add_record("battle_fire_at_will_button", "script_link_battle_fire_at_will_button", "tooltip_battle_fire_at_will_button");
	tp_fire_at_will_button = tooltip_patcher:new("tooltip_battle_fire_at_will_button");
	tp_fire_at_will_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_fire_at_will_button");
	
	tl_fire_at_will_button = tooltip_listener:new(
		"tooltip_battle_fire_at_will_button", 
		function() 
			uim:highlight_fire_at_will_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- flanking
	--
	
	hp_flanking = help_page:new(
		"script_link_battle_flanking",
		hpr_header("war.battle.hp.flanking.001"),
		hpr_normal("war.battle.hp.flanking.002"),
		hpr_bulleted("war.battle.hp.flanking.003"),
		hpr_bulleted("war.battle.hp.flanking.004")
	);
	parser:add_record("battle_flanking", "script_link_battle_flanking", "tooltip_battle_flanking");
	tp_flanking = tooltip_patcher:new("tooltip_battle_flanking");
	tp_flanking:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_flanking", "ui_text_replacements_localised_text_hp_battle_description_flanking");
	
	
	
	--
	-- flying_units
	--
	
	hp_flying_units = help_page:new(
		"script_link_battle_flying_units",
		hpr_header("war.battle.hp.flying_units.001"),
		hpr_normal("war.battle.hp.flying_units.002"),
		hpr_bulleted("war.battle.hp.flying_units.003"),
		hpr_bulleted("war.battle.hp.flying_units.004"),
		hpr_bulleted("war.battle.hp.flying_units.005"),
		hpr_bulleted("war.battle.hp.flying_units.006")
	);
	parser:add_record("battle_flying_units", "script_link_battle_flying_units", "tooltip_battle_flying_units");
	tp_flying_units = tooltip_patcher:new("tooltip_battle_flying_units");
	tp_flying_units:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_flying_units", "ui_text_replacements_localised_text_hp_battle_description_flying_units");
	
	
	
	--
	-- formations
	--
	
	hp_formations = help_page:new(
		"script_link_battle_formations",
		hpr_header("war.battle.hp.formations.001"),
		hpr_normal("war.battle.hp.formations.002"),
		hpr_bulleted("war.battle.hp.formations.003"),
		hpr_bulleted("war.battle.hp.formations.004"),
		hpr_bulleted("war.battle.hp.formations.005")
	);
	parser:add_record("battle_formations", "script_link_battle_formations", "tooltip_battle_formations");
	tp_formations = tooltip_patcher:new("tooltip_battle_formations");
	tp_formations:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_formations", "ui_text_replacements_localised_text_hp_battle_description_formations");
	
	tl_formations = tooltip_listener:new(
		"tooltip_battle_formations", 
		function() 
			uim:highlight_formations_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- formations_link
	--
	
	parser:add_record("battle_formations_link", "script_link_battle_formations_link", "tooltip_battle_formations_link");
	tp_formations_link = tooltip_patcher:new("tooltip_battle_formations_link");
	tp_formations_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_formations_link");
	
	tl_formations_link = tooltip_listener:new(
		"tooltip_battle_formations_link", 
		function() 
			uim:highlight_formations_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
		
	
	
	--
	-- formations_button
	--

	parser:add_record("battle_formations_button", "script_link_battle_formations_button", "tooltip_battle_formations_button");
	tp_formations_button = tooltip_patcher:new("tooltip_battle_formations_button");
	tp_formations_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_formations_button");
	
	tl_formations_button = tooltip_listener:new(
		"tooltip_battle_formations_button", 
		function() 
			uim:highlight_formations_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- fortifications
	--
	
	hp_fortifications = help_page:new(
		"script_link_battle_fortifications",
		hpr_header("war.battle.hp.fortifications.001"),
		hpr_normal("war.battle.hp.fortifications.002"),
		hpr_bulleted("war.battle.hp.fortifications.003"),
		hpr_bulleted("war.battle.hp.fortifications.004"),
		hpr_bulleted("war.battle.hp.fortifications.005"),
		hpr_bulleted("war.battle.hp.fortifications.006"),
		hpr_bulleted("war.battle.hp.fortifications.007")
	);
	parser:add_record("battle_fortifications", "script_link_battle_fortifications", "tooltip_battle_fortifications");
	tp_fortifications = tooltip_patcher:new("tooltip_battle_fortifications");
	tp_fortifications:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_fortifications", "ui_text_replacements_localised_text_hp_battle_description_fortifications");
	
		
	
	
	--
	-- grouping
	--
	
	hp_grouping = help_page:new(
		"script_link_battle_grouping",
		hpr_header("war.battle.hp.grouping.001"),
		hpr_normal("war.battle.hp.grouping.002"),
		hpr_bulleted("war.battle.hp.grouping.003"),
		hpr_bulleted("war.battle.hp.grouping.004"),
		hpr_bulleted("war.battle.hp.grouping.005"),
		hpr_bulleted("war.battle.hp.grouping.006")
	);
	parser:add_record("battle_grouping", "script_link_battle_grouping", "tooltip_battle_grouping");
	tp_grouping = tooltip_patcher:new("tooltip_battle_grouping");
	tp_grouping:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_grouping", "ui_text_replacements_localised_text_hp_battle_description_grouping");
	
	tl_grouping = tooltip_listener:new(
		"tooltip_battle_grouping", 
		function() 
			uim:highlight_group_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- grouping_link
	--
	
	parser:add_record("battle_grouping_link", "script_link_battle_grouping_link", "tooltip_battle_grouping_link");
	tp_grouping_link = tooltip_patcher:new("tooltip_battle_grouping_link");
	tp_grouping_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_grouping_link");
	
	tl_grouping_link = tooltip_listener:new(
		"tooltip_battle_grouping_link", 
		function() 
			uim:highlight_group_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- group_button
	--

	parser:add_record("battle_group_button", "script_link_battle_group_button", "tooltip_battle_group_button");
	tp_group_button = tooltip_patcher:new("tooltip_battle_group_button");
	tp_group_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_group_button");
	
	tl_group_button = tooltip_listener:new(
		"tooltip_battle_group_button", 
		function() 
			uim:highlight_group_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- guard_button
	--

	parser:add_record("battle_guard_button", "script_link_battle_guard_button", "tooltip_battle_guard_button");
	tp_guard_button = tooltip_patcher:new("tooltip_battle_guard_button");
	tp_guard_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_guard_button");
	
	tl_guard_button = tooltip_listener:new(
		"tooltip_battle_guard_button", 
		function() 
			uim:highlight_guard_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	--
	-- infantry
	--
	
	hp_infantry = help_page:new(
		"script_link_battle_infantry",
		hpr_header("war.battle.hp.infantry.001"),
		hpr_normal("war.battle.hp.infantry.002"),
		hpr_bulleted("war.battle.hp.infantry.003"),
		hpr_bulleted("war.battle.hp.infantry.004"),
		hpr_bulleted("war.battle.hp.infantry.005"),
		hpr_bulleted("war.battle.hp.infantry.006"),
		hpr_bulleted("war.battle.hp.infantry.007")
	);
	parser:add_record("battle_infantry", "script_link_battle_infantry", "tooltip_battle_infantry");
	tp_infantry = tooltip_patcher:new("tooltip_battle_infantry");
	tp_infantry:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_infantry", "ui_text_replacements_localised_text_hp_battle_description_infantry");
	
	
	
	--
	-- leadership
	--
	
	hp_leadership = help_page:new(
		"script_link_battle_leadership",
		hpr_header("war.battle.hp.leadership.001"),
		hpr_normal("war.battle.hp.leadership.002"),
		hpr_bulleted("war.battle.hp.leadership.003"),
		hpr_bulleted("war.battle.hp.leadership.004"),
		hpr_bulleted("war.battle.hp.leadership.005"),
		hpr_bulleted("war.battle.hp.leadership.006"),
		hpr_bulleted("war.battle.hp.leadership.007")
	);
	parser:add_record("battle_leadership", "script_link_battle_leadership", "tooltip_battle_leadership");
	tp_leadership = tooltip_patcher:new("tooltip_battle_leadership");
	tp_leadership:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_leadership", "ui_text_replacements_localised_text_hp_battle_description_leadership");
	
	
	
	--
	-- lore_panel
	--

	parser:add_record("battle_lore_panel", "script_link_battle_lore_panel", "tooltip_battle_lore_panel");
	tp_lore_panel = tooltip_patcher:new("tooltip_battle_lore_panel");
	tp_lore_panel:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_lore_panel");
	
	tl_lore_panel = tooltip_listener:new(
		"tooltip_battle_lore_panel", 
		function() 
			uim:highlight_lore_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
		
	
	
	--
	-- melee_mode_button
	--

	parser:add_record("battle_melee_mode_button", "script_link_battle_melee_mode_button", "tooltip_battle_melee_mode_button");
	tp_melee_mode_button = tooltip_patcher:new("tooltip_battle_melee_mode_button");
	tp_melee_mode_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_melee_mode_button");
	
	tl_melee_mode_button = tooltip_listener:new(
		"tooltip_battle_melee_mode_button", 
		function() 
			uim:highlight_melee_mode_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- missile_units
	--
	
	hp_missile_units = help_page:new(
		"script_link_battle_missile_units",
		hpr_header("war.battle.hp.missile_units.001"),
		hpr_normal("war.battle.hp.missile_units.002"),
		hpr_bulleted("war.battle.hp.missile_units.003"),
		hpr_bulleted("war.battle.hp.missile_units.004"),
		hpr_bulleted("war.battle.hp.missile_units.005"),
		hpr_bulleted("war.battle.hp.missile_units.006"),
		hpr_bulleted("war.battle.hp.missile_units.007")
	);
	parser:add_record("battle_missile_units", "script_link_battle_missile_units", "tooltip_battle_missile_units");
	tp_missile_units = tooltip_patcher:new("tooltip_battle_missile_units");
	tp_missile_units:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_missile_units", "ui_text_replacements_localised_text_hp_battle_description_missile_units");
	
	

	--
	-- monsters
	--
	
	hp_monsters = help_page:new(
		"script_link_battle_monsters",
		hpr_header("war.battle.hp.monsters.001"),
		hpr_normal("war.battle.hp.monsters.002"),
		hpr_bulleted("war.battle.hp.monsters.003"),
		hpr_bulleted("war.battle.hp.monsters.004")
	);
	parser:add_record("battle_monsters", "script_link_battle_monsters", "tooltip_battle_monsters");
	tp_monsters = tooltip_patcher:new("tooltip_battle_monsters");
	tp_monsters:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_monsters", "ui_text_replacements_localised_text_hp_battle_description_monsters");
	
	
	
	--
	-- mounted_units
	--
	
	hp_mounted_units = help_page:new(
		"script_link_battle_mounted_units",
		hpr_header("war.battle.hp.mounted_units.001"),
		hpr_normal("war.battle.hp.mounted_units.002"),
		hpr_bulleted("war.battle.hp.mounted_units.003"),
		hpr_bulleted("war.battle.hp.mounted_units.004"),
		hpr_bulleted("war.battle.hp.mounted_units.005"),
		hpr_bulleted("war.battle.hp.mounted_units.006")
	);
	parser:add_record("battle_mounted_units", "script_link_battle_mounted_units", "tooltip_battle_mounted_units");
	tp_mounted_units = tooltip_patcher:new("tooltip_battle_mounted_units");
	tp_mounted_units:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_mounted_units", "ui_text_replacements_localised_text_hp_battle_description_mounted_units");
	
	
	
	--
	-- murderous_prowess
	--
	
	hp_murderous_prowess = help_page:new(
		"script_link_battle_murderous_prowess",
		hpr_header("war.battle.hp.murderous_prowess.001"),
		hpr_normal("war.battle.hp.murderous_prowess.002"),
		hpr_bulleted("war.battle.hp.murderous_prowess.003")
	);
	parser:add_record("battle_murderous_prowess", "script_link_battle_murderous_prowess", "tooltip_battle_murderous_prowess");
	tp_murderous_prowess = tooltip_patcher:new("tooltip_battle_murderous_prowess");
	tp_murderous_prowess:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_murderous_prowess", "ui_text_replacements_localised_text_hp_battle_description_murderous_prowess");
	
	
	
	--
	-- power_reserve_bar
	--

	parser:add_record("battle_power_reserve_bar", "script_link_battle_power_reserve_bar", "tooltip_battle_power_reserve_bar");
	tp_power_reserve_bar = tooltip_patcher:new("tooltip_battle_power_reserve_bar");
	tp_power_reserve_bar:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_power_reserve_bar");
	
	tl_power_reserve_bar = tooltip_listener:new(
		"tooltip_battle_power_reserve_bar", 
		function() 
			uim:highlight_power_reserve_bar(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- radar_map
	--

	parser:add_record("battle_radar_map", "script_link_battle_radar_map", "tooltip_battle_radar_map");
	tp_radar_map = tooltip_patcher:new("tooltip_battle_radar_map");
	tp_radar_map:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_top_item");
	
	tl_radar_map = tooltip_listener:new(
		"tooltip_battle_radar_map", 
		function() 
			uim:highlight_radar_map(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- rallying
	--
	
	hp_rallying = help_page:new(
		"script_link_battle_rallying",
		hpr_header("war.battle.hp.rallying.001"),
		hpr_normal("war.battle.hp.rallying.002"),
		hpr_bulleted("war.battle.hp.rallying.003"),
		hpr_bulleted("war.battle.hp.rallying.004"),
		hpr_bulleted("war.battle.hp.rallying.005")
	);
	parser:add_record("battle_rallying", "script_link_battle_rallying", "tooltip_battle_rallying");
	tp_rallying = tooltip_patcher:new("tooltip_battle_rallying");
	tp_rallying:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_rallying", "ui_text_replacements_localised_text_hp_battle_description_rallying");
	
	
	
	--
	-- rampaging
	--
	
	hp_rampaging = help_page:new(
		"script_link_battle_rampaging",
		hpr_header("war.battle.hp.rampaging.001"),
		hpr_normal("war.battle.hp.rampaging.002"),
		hpr_bulleted("war.battle.hp.rampaging.003")
	);
	parser:add_record("battle_rampaging", "script_link_battle_rampaging", "tooltip_battle_rampaging");
	tp_rampaging = tooltip_patcher:new("tooltip_battle_rampaging");
	tp_rampaging:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_rampaging", "ui_text_replacements_localised_text_hp_battle_description_rampaging");
	
	
	
	--
	-- realm_of_souls
	--
	
	hp_realm_of_souls = help_page:new(
		"script_link_battle_realm_of_souls",
		hpr_header("war.battle.hp.realm_of_souls.001"),
		hpr_normal("war.battle.hp.realm_of_souls.002"),
		hpr_bulleted("war.battle.hp.realm_of_souls.003"),
		hpr_bulleted("war.battle.hp.realm_of_souls.004"),
		hpr_bulleted("war.battle.hp.realm_of_souls.005")
	);
	parser:add_record("battle_realm_of_souls", "script_link_battle_realm_of_souls", "tooltip_battle_realm_of_souls");
	tp_realm_of_souls = tooltip_patcher:new("tooltip_battle_realm_of_souls");
	tp_realm_of_souls:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_realm_of_souls", "ui_text_replacements_localised_text_hp_battle_description_realm_of_souls");
	
	tl_realm_of_souls = tooltip_listener:new(
		"tooltip_battle_realm_of_souls", 
		function() 
			uim:highlight_realm_of_souls(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- realm_of_souls
	--
	
	parser:add_record("battle_realm_of_souls_link", "script_link_battle_realm_of_souls_link", "tooltip_battle_realm_of_souls_link");
	tp_realm_of_souls_link = tooltip_patcher:new("tooltip_battle_realm_of_souls_link");
	tp_realm_of_souls_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_realm_of_souls_link");
	
	tl_realm_of_souls_link = tooltip_listener:new(
		"tooltip_battle_realm_of_souls_link", 
		function() 
			uim:highlight_realm_of_souls(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- reinforcements
	--
	
	hp_reinforcements = help_page:new(
		"script_link_battle_reinforcements",
		hpr_header("war.battle.hp.reinforcements.001"),
		hpr_normal("war.battle.hp.reinforcements.002"),
		hpr_bulleted("war.battle.hp.reinforcements.003")
	);
	parser:add_record("battle_reinforcements", "script_link_battle_reinforcements", "tooltip_battle_reinforcements");
	tp_reinforcements = tooltip_patcher:new("tooltip_battle_reinforcements");
	tp_reinforcements:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_reinforcements", "ui_text_replacements_localised_text_hp_battle_description_reinforcements");
	
	
	
	--
	-- siege_battles
	--
	
	hp_siege_battles = help_page:new(
		"script_link_battle_siege_battles",
		hpr_header("war.battle.hp.siege_battles.001"),
		hpr_normal("war.battle.hp.siege_battles.002"),
		hpr_bulleted("war.battle.hp.siege_battles.003"),
		hpr_bulleted("war.battle.hp.siege_battles.004"),
		hpr_bulleted("war.battle.hp.siege_battles.005"),
		hpr_bulleted("war.battle.hp.siege_battles.006"),
		hpr_bulleted("war.battle.hp.siege_battles.007")
	);
	parser:add_record("battle_siege_battles", "script_link_battle_siege_battles", "tooltip_battle_siege_battles");
	tp_siege_battles = tooltip_patcher:new("tooltip_battle_siege_battles");
	tp_siege_battles:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_siege_battles", "ui_text_replacements_localised_text_hp_battle_description_siege_battles");
	
	
	
	--
	-- siege_weapons
	--
	
	hp_siege_weapons = help_page:new(
		"script_link_battle_siege_weapons",
		hpr_header("war.battle.hp.siege_weapons.001"),
		hpr_normal("war.battle.hp.siege_weapons.002"),
		hpr_bulleted("war.battle.hp.siege_weapons.003"),
		hpr_bulleted("war.battle.hp.siege_weapons.004"),
		hpr_bulleted("war.battle.hp.siege_weapons.005"),
		hpr_bulleted("war.battle.hp.siege_weapons.006"),
		hpr_bulleted("war.battle.hp.siege_weapons.007")
	);
	parser:add_record("battle_siege_weapons", "script_link_battle_siege_weapons", "tooltip_battle_siege_weapons");
	tp_siege_weapons = tooltip_patcher:new("tooltip_battle_siege_weapons");
	tp_siege_weapons:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_siege_weapons", "ui_text_replacements_localised_text_hp_battle_description_siege_weapons");
	
	
	
	--
	-- skirmishing
	--
	
	hp_skirmishing = help_page:new(
		"script_link_battle_skirmishing",
		hpr_header("war.battle.hp.skirmishing.001"),
		hpr_normal("war.battle.hp.skirmishing.002"),
		hpr_bulleted("war.battle.hp.skirmishing.003"),
		hpr_bulleted("war.battle.hp.skirmishing.004")
	);
	parser:add_record("battle_skirmishing", "script_link_battle_skirmishing", "tooltip_battle_skirmishing");
	tp_skirmishing = tooltip_patcher:new("tooltip_battle_skirmishing");
	tp_skirmishing:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_skirmishing", "ui_text_replacements_localised_text_hp_battle_description_skirmishing");
	
	tl_skirmishing = tooltip_listener:new(
		"tooltip_battle_skirmishing", 
		function() 
			uim:highlight_skirmish_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- skirmishing_link
	--
	
	parser:add_record("battle_skirmishing_link", "script_link_battle_skirmishing_link", "tooltip_battle_skirmishing_link");
	tp_skirmishing_link = tooltip_patcher:new("tooltip_battle_skirmishing_link");
	tp_skirmishing_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_skirmishing_link");
	
	tl_skirmishing_link = tooltip_listener:new(
		"tooltip_battle_skirmishing_link", 
		function() 
			uim:highlight_skirmish_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- skirmish_button
	--

	parser:add_record("battle_skirmish_button", "script_link_battle_skirmish_button", "tooltip_battle_skirmish_button");
	tp_skirmish_button = tooltip_patcher:new("tooltip_battle_skirmish_button");
	tp_skirmish_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_description_skirmish_button");
	
	tl_skirmish_button = tooltip_listener:new(
		"tooltip_battle_skirmish_button", 
		function() 
			uim:highlight_skirmish_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- spells
	--
	
	hp_spells = help_page:new(
		"script_link_battle_spells",
		hpr_header("war.battle.hp.spells.001"),
		hpr_normal("war.battle.hp.spells.002"),
		hpr_bulleted("war.battle.hp.spells.003"),
		hpr_bulleted("war.battle.hp.spells.004"),
		hpr_bulleted("war.battle.hp.spells.005"),
		hpr_bulleted("war.battle.hp.spells.006"),
		hpr_bulleted("war.battle.hp.spells.007")
	);
	parser:add_record("battle_spells", "script_link_battle_spells", "tooltip_battle_spells");
	tp_spells = tooltip_patcher:new("tooltip_battle_spells");
	tp_spells:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_spells", "ui_text_replacements_localised_text_hp_battle_description_spells");
	
	tl_spells = tooltip_listener:new(
		"tooltip_battle_spells", 
		function() 
			uim:highlight_spells(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- spells_link
	--
	
	parser:add_record("battle_spells_link", "script_link_battle_spells_link", "tooltip_battle_spells_link");
	tp_spells_link = tooltip_patcher:new("tooltip_battle_spells_link");
	tp_spells_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_winds_of_magic_link");
	
	tl_spells_link = tooltip_listener:new(
		"tooltip_battle_spells_link", 
		function() 
			uim:highlight_spells(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- tactical_map
	--
	
	hp_tactical_map = help_page:new(
		"script_link_battle_tactical_map",
		hpr_header("war.battle.hp.tactical_map.001"),
		hpr_normal("war.battle.hp.tactical_map.002"),
		hpr_bulleted("war.battle.hp.tactical_map.003"),
		hpr_bulleted("war.battle.hp.tactical_map.004"),
		hpr_bulleted("war.battle.hp.tactical_map.005"),
		hpr_bulleted("war.battle.hp.tactical_map.006")
	);
	parser:add_record("battle_tactical_map", "script_link_battle_tactical_map", "tooltip_battle_tactical_map");
	tp_tactical_map = tooltip_patcher:new("tooltip_battle_tactical_map");
	tp_tactical_map:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_tactical_map", "ui_text_replacements_localised_text_hp_battle_description_tactical_map");
	
	tl_tactical_map = tooltip_listener:new(
		"tooltip_battle_tactical_map", 
		function() 
			uim:highlight_tactical_map_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- tactical_map_link
	--
	
	parser:add_record("battle_tactical_map_link", "script_link_battle_tactical_map_link", "tooltip_battle_tactical_map_link");
	tp_tactical_map_link = tooltip_patcher:new("tooltip_battle_tactical_map_link");
	tp_tactical_map_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_tactical_map_link");
	
	tl_tactical_map_link = tooltip_listener:new(
		"tooltip_battle_tactical_map_link", 
		function() 
			uim:highlight_tactical_map_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- terrain
	--
	
	hp_terrain = help_page:new(
		"script_link_battle_terrain",
		hpr_header("war.battle.hp.terrain.001"),
		hpr_normal("war.battle.hp.terrain.002"),
		hpr_bulleted("war.battle.hp.terrain.003"),
		hpr_bulleted("war.battle.hp.terrain.004"),
		hpr_bulleted("war.battle.hp.terrain.005"),
		hpr_bulleted("war.battle.hp.terrain.006")
	);
	parser:add_record("battle_terrain", "script_link_battle_terrain", "tooltip_battle_terrain");
	tp_terrain = tooltip_patcher:new("tooltip_battle_terrain");
	tp_terrain:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_terrain", "ui_text_replacements_localised_text_hp_battle_description_terrain");
	
	
	
	--
	-- the_general
	--
	
	hp_the_general = help_page:new(
		"script_link_battle_the_general",
		hpr_header("war.battle.hp.the_general.001"),
		hpr_normal("war.battle.hp.the_general.002"),
		hpr_bulleted("war.battle.hp.the_general.003"),
		hpr_bulleted("war.battle.hp.the_general.004"),
		hpr_bulleted("war.battle.hp.the_general.005")
	);
	parser:add_record("battle_the_general", "script_link_battle_the_general", "tooltip_battle_the_general");
	tp_the_general = tooltip_patcher:new("tooltip_battle_the_general");
	tp_the_general:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_the_general", "ui_text_replacements_localised_text_hp_battle_description_the_general");
	
	
	
	--
	-- time_controls
	--

	parser:add_record("battle_time_controls", "script_link_battle_time_controls", "tooltip_battle_time_controls");
	tp_time_controls = tooltip_patcher:new("tooltip_battle_time_controls");
	tp_time_controls:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_top_item");
	
	tl_time_controls = tooltip_listener:new(
		"tooltip_battle_time_controls", 
		function() 
			uim:highlight_time_controls(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- time_limit
	--

	parser:add_record("battle_time_limit", "script_link_battle_time_limit", "tooltip_battle_time_limit");
	tp_time_limit = tooltip_patcher:new("tooltip_battle_time_limit");
	tp_time_limit:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_top_item");
	
	tl_time_limit = tooltip_listener:new(
		"tooltip_battle_time_limit", 
		function() 
			uim:highlight_time_limit(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- unit_abilities
	--
	
	hp_unit_abilities = help_page:new(
		"script_link_battle_unit_abilities",
		hpr_header("war.battle.hp.unit_abilities.001"),
		hpr_normal("war.battle.hp.unit_abilities.002"),
		hpr_bulleted("war.battle.hp.unit_abilities.003"),
		hpr_bulleted("war.battle.hp.unit_abilities.004"),
		hpr_bulleted("war.battle.hp.unit_abilities.005")
	);
	parser:add_record("battle_unit_abilities", "script_link_battle_unit_abilities", "tooltip_battle_unit_abilities");
	tp_unit_abilities = tooltip_patcher:new("tooltip_battle_unit_abilities");
	tp_unit_abilities:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_abilities", "ui_text_replacements_localised_text_hp_battle_description_unit_abilities");
	
	tl_unit_abilities = tooltip_listener:new(
		"tooltip_battle_unit_abilities", 
		function() 
			uim:highlight_unit_abilities(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- unit_abilities_link
	--
	
	parser:add_record("battle_unit_abilities_link", "script_link_battle_unit_abilities_link", "tooltip_battle_unit_abilities_link");
	tp_unit_abilities_link = tooltip_patcher:new("tooltip_battle_unit_abilities_link");
	tp_unit_abilities_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_unit_abilities_link");
	
	tl_unit_abilities_link = tooltip_listener:new(
		"tooltip_battle_unit_abilities_link", 
		function() 
			uim:highlight_unit_abilities(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	

	--
	-- unit_cards
	--
	
	hp_unit_cards = help_page:new(
		"script_link_battle_unit_cards",
		hpr_header("war.battle.hp.unit_cards.001"),
		hpr_normal("war.battle.hp.unit_cards.002"),
		hpr_bulleted("war.battle.hp.unit_cards.003"),
		hpr_bulleted("war.battle.hp.unit_cards.004"),
		hpr_bulleted("war.battle.hp.unit_cards.005"),
		hpr_bulleted("war.battle.hp.unit_cards.006"),
		hpr_bulleted("war.battle.hp.unit_cards.007")
	);
	parser:add_record("battle_unit_cards", "script_link_battle_unit_cards", "tooltip_battle_unit_cards");
	tp_unit_cards = tooltip_patcher:new("tooltip_battle_unit_cards");
	tp_unit_cards:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_cards", "ui_text_replacements_localised_text_hp_battle_description_unit_cards");
	
	tl_unit_cards = tooltip_listener:new(
		"tooltip_battle_unit_cards", 
		function() 
			uim:highlight_unit_cards(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- unit_cards_link
	--
	
	parser:add_record("battle_unit_cards_link", "script_link_battle_unit_cards_link", "tooltip_battle_unit_cards_link");
	tp_unit_cards_link = tooltip_patcher:new("tooltip_battle_unit_cards_link");
	tp_unit_cards_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_unit_cards_link");
	
	tl_unit_cards_link = tooltip_listener:new(
		"tooltip_battle_unit_cards_link", 
		function() 
			uim:highlight_unit_cards(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	--
	-- unit_details_button
	--

	parser:add_record("battle_unit_details_button", "script_link_battle_unit_details_button", "tooltip_battle_unit_details_button");
	tp_unit_details_button = tooltip_patcher:new("tooltip_battle_unit_details_button");
	tp_unit_details_button:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_bottom_button");
	
	tl_unit_details_button = tooltip_listener:new(
		"tooltip_battle_unit_details_button", 
		function() 
			uim:highlight_unit_details_button(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- unit_details_panel
	--
	
	hp_unit_details_panel = help_page:new(
		"script_link_battle_unit_details_panel",
		hpr_header("war.battle.hp.unit_details_panel.001"),
		hpr_normal("war.battle.hp.unit_details_panel.002"),
		hpr_bulleted("war.battle.hp.unit_details_panel.003"),
		hpr_bulleted("war.battle.hp.unit_details_panel.004")
	);
	parser:add_record("battle_unit_details_panel", "script_link_battle_unit_details_panel", "tooltip_battle_unit_details_panel");
	tp_unit_details_panel = tooltip_patcher:new("tooltip_battle_unit_details_panel");
	tp_unit_details_panel:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_details_panel", "ui_text_replacements_localised_text_hp_battle_description_unit_details_panel");
	
	tl_unit_details_panel = tooltip_listener:new(
		"tooltip_battle_unit_details_panel", 
		function() 
			uim:highlight_unit_details_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	--
	-- unit_details_panel_link
	--
	
	parser:add_record("battle_unit_details_panel_link", "script_link_battle_unit_details_panel_link", "tooltip_battle_unit_details_panel_link");
	tp_unit_details_panel_link = tooltip_patcher:new("tooltip_battle_unit_details_panel_link");
	tp_unit_details_panel_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_unit_details_panel_link");
	
	tl_unit_details_panel_link = tooltip_listener:new(
		"tooltip_battle_unit_details_panel_link", 
		function() 
			uim:highlight_unit_details_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- unit_movement
	--
	
	hp_unit_movement = help_page:new(
		"script_link_battle_unit_movement",
		hpr_header("war.battle.hp.unit_movement.001"),
		hpr_normal("war.battle.hp.unit_movement.002"),
		hpr_bulleted("war.battle.hp.unit_movement.003"),
		hpr_bulleted("war.battle.hp.unit_movement.004"),
		hpr_bulleted("war.battle.hp.unit_movement.005"),
		hpr_bulleted("war.battle.hp.unit_movement.006"),
		hpr_bulleted("war.battle.hp.unit_movement.007")
	);
	parser:add_record("battle_unit_movement", "script_link_battle_unit_movement", "tooltip_battle_unit_movement");
	tp_unit_movement = tooltip_patcher:new("tooltip_battle_unit_movement");
	tp_unit_movement:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_movement", "ui_text_replacements_localised_text_hp_battle_description_unit_movement");
	
	
	
	--
	-- unit_portrait_panel
	--

	parser:add_record("battle_unit_portrait_panel", "script_link_battle_unit_portrait_panel", "tooltip_battle_unit_portrait_panel");
	tp_unit_portrait_panel = tooltip_patcher:new("tooltip_battle_unit_portrait_panel");
	tp_unit_portrait_panel:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_bottom_panel");
	
	tl_unit_portrait_panel = tooltip_listener:new(
		"tooltip_battle_unit_portrait_panel", 
		function() 
			uim:highlight_unit_portrait_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- unit_selection
	--
	
	hp_unit_selection = help_page:new(
		"script_link_battle_unit_selection",
		hpr_header("war.battle.hp.unit_selection.001"),
		hpr_normal("war.battle.hp.unit_selection.002"),
		hpr_bulleted("war.battle.hp.unit_selection.003"),
		hpr_bulleted("war.battle.hp.unit_selection.004"),
		hpr_bulleted("war.battle.hp.unit_selection.005"),
		hpr_bulleted("war.battle.hp.unit_selection.006")
	);
	parser:add_record("battle_unit_selection", "script_link_battle_unit_selection", "tooltip_battle_unit_selection");
	tp_unit_selection = tooltip_patcher:new("tooltip_battle_unit_selection");
	tp_unit_selection:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_selection", "ui_text_replacements_localised_text_hp_battle_description_unit_selection");
	
	
	

	--
	-- unit_types
	--
	
	hp_unit_types = help_page:new(
		"script_link_battle_unit_types",
		hpr_header("war.battle.hp.unit_types.001"),
		hpr_normal("war.battle.hp.unit_types.002"),
		hpr_bulleted("war.battle.hp.unit_types.003"),
		hpr_bulleted("war.battle.hp.unit_types.004"),
		hpr_bulleted("war.battle.hp.unit_types.005"),
		hpr_bulleted("war.battle.hp.unit_types.006"),
		hpr_bulleted("war.battle.hp.unit_types.007")
	);
	parser:add_record("battle_unit_types", "script_link_battle_unit_types", "tooltip_battle_unit_types");
	tp_unit_types = tooltip_patcher:new("tooltip_battle_unit_types");
	tp_unit_types:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_unit_types", "ui_text_replacements_localised_text_hp_battle_description_unit_types");
	
	
	

	--
	-- units
	--
	
	hp_units = help_page:new(
		"script_link_battle_units",
		hpr_header("war.battle.hp.units.001"),
		hpr_normal("war.battle.hp.units.002"),
		hpr_bulleted("war.battle.hp.units.003"),
		hpr_bulleted("war.battle.hp.units.004"),
		hpr_bulleted("war.battle.hp.units.005"),
		hpr_bulleted("war.battle.hp.units.006"),
		hpr_bulleted("war.battle.hp.units.007")
	);
	parser:add_record("battle_units", "script_link_battle_units", "tooltip_battle_units");
	tp_units = tooltip_patcher:new("tooltip_battle_units");
	tp_units:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_units", "ui_text_replacements_localised_text_hp_battle_description_units");
	
	tl_units = tooltip_listener:new(
		"tooltip_battle_units", 
		function() 
			uim:highlight_unit_cards(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- units_link
	--
	
	parser:add_record("battle_units_link", "script_link_battle_units_link", "tooltip_battle_units_link");
	tp_units_link = tooltip_patcher:new("tooltip_battle_units_link");
	tp_units_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_units_link");
	
	tl_units_link = tooltip_listener:new(
		"tooltip_battle_units_link", 
		function() 
			uim:highlight_unit_cards(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	

	--
	-- victory_points
	--
	
	hp_victory_points = help_page:new(
		"script_link_battle_victory_points",
		hpr_header("war.battle.hp.victory_points.001"),
		hpr_normal("war.battle.hp.victory_points.002"),
		hpr_bulleted("war.battle.hp.victory_points.003"),
		hpr_bulleted("war.battle.hp.victory_points.004"),
		hpr_bulleted("war.battle.hp.victory_points.005"),
		hpr_bulleted("war.battle.hp.victory_points.006")
	);
	parser:add_record("battle_victory_points", "script_link_battle_victory_points", "tooltip_battle_victory_points");
	tp_victory_points = tooltip_patcher:new("tooltip_battle_victory_points");
	tp_victory_points:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_victory_points", "ui_text_replacements_localised_text_hp_battle_description_victory_points");
	
	
	
	--
	-- vigour
	--
	
	hp_vigour = help_page:new(
		"script_link_battle_vigour",
		hpr_header("war.battle.hp.vigour.001"),
		hpr_normal("war.battle.hp.vigour.002"),
		hpr_bulleted("war.battle.hp.vigour.003"),
		hpr_bulleted("war.battle.hp.vigour.004"),
		hpr_bulleted("war.battle.hp.vigour.005")
	);
	parser:add_record("battle_vigour", "script_link_battle_vigour", "tooltip_battle_vigour");
	tp_vigour = tooltip_patcher:new("tooltip_battle_vigour");
	tp_vigour:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_vigour", "ui_text_replacements_localised_text_hp_battle_description_vigour");
	
	
	
	--
	-- visibility
	--
	
	hp_visibility = help_page:new(
		"script_link_battle_visibility",
		hpr_header("war.battle.hp.visibility.001"),
		hpr_normal("war.battle.hp.visibility.002"),
		hpr_bulleted("war.battle.hp.visibility.003"),
		hpr_bulleted("war.battle.hp.visibility.004"),
		hpr_bulleted("war.battle.hp.visibility.005"),
		hpr_bulleted("war.battle.hp.visibility.006")
	);
	parser:add_record("battle_visibility", "script_link_battle_visibility", "tooltip_battle_visibility");
	tp_visibility = tooltip_patcher:new("tooltip_battle_visibility");
	tp_visibility:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_visibility", "ui_text_replacements_localised_text_hp_battle_description_visibility");
	
	
	

	--
	-- weapon_types
	--
	
	hp_weapon_types = help_page:new(
		"script_link_battle_weapon_types",
		hpr_header("war.battle.hp.weapon_types.001"),
		hpr_normal("war.battle.hp.weapon_types.002"),
		hpr_bulleted("war.battle.hp.weapon_types.003"),
		hpr_bulleted("war.battle.hp.weapon_types.004"),
		hpr_bulleted("war.battle.hp.weapon_types.005")
	);
	parser:add_record("battle_weapon_types", "script_link_battle_weapon_types", "tooltip_battle_weapon_types");
	tp_weapon_types = tooltip_patcher:new("tooltip_battle_weapon_types");
	tp_weapon_types:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_weapon_types", "ui_text_replacements_localised_text_hp_battle_description_weapon_types");
	
	
	
	
	--
	-- winds_of_magic
	--
	
	hp_winds_of_magic = help_page:new(
		"script_link_battle_winds_of_magic",
		hpr_header("war.battle.hp.winds_of_magic.001"),
		hpr_normal("war.battle.hp.winds_of_magic.002"),
		hpr_bulleted("war.battle.hp.winds_of_magic.003"),
		hpr_bulleted("war.battle.hp.winds_of_magic.004"),
		hpr_bulleted("war.battle.hp.winds_of_magic.005"),
		hpr_bulleted("war.battle.hp.winds_of_magic.006")
	);
	parser:add_record("battle_winds_of_magic", "script_link_battle_winds_of_magic", "tooltip_battle_winds_of_magic");
	tp_winds_of_magic = tooltip_patcher:new("tooltip_battle_winds_of_magic");
	tp_winds_of_magic:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_winds_of_magic", "ui_text_replacements_localised_text_hp_battle_description_winds_of_magic");
	
	tl_winds_of_magic = tooltip_listener:new(
		"tooltip_battle_winds_of_magic", 
		function() 
			uim:highlight_winds_of_magic_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- winds_of_magic_link
	--
	
	parser:add_record("battle_winds_of_magic_link", "script_link_battle_winds_of_magic_link", "tooltip_battle_winds_of_magic_link");
	tp_winds_of_magic_link = tooltip_patcher:new("tooltip_battle_winds_of_magic_link");
	tp_winds_of_magic_link:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_winds_of_magic_link");
	
	tl_winds_of_magic_link = tooltip_listener:new(
		"tooltip_battle_winds_of_magic_link", 
		function() 
			uim:highlight_winds_of_magic_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	--
	-- winds_of_magic_panel
	--

	parser:add_record("battle_winds_of_magic_panel", "script_link_battle_winds_of_magic_panel", "tooltip_battle_winds_of_magic_panel");
	tp_winds_of_magic_panel = tooltip_patcher:new("tooltip_battle_winds_of_magic_panel");
	tp_winds_of_magic_panel:set_layout_data("tooltip_text_only", "ui_text_replacements_localised_text_hp_battle_title_bottom_panel");
	
	tl_winds_of_magic_panel = tooltip_listener:new(
		"tooltip_battle_winds_of_magic_panel", 
		function() 
			uim:highlight_winds_of_magic_panel(true);
		end,
		function() 
			uim:unhighlight_all_for_tooltips();
		end
	);
	
	
	
	
	--
	-- wizards
	--
	
	hp_wizards = help_page:new(
		"script_link_battle_wizards",
		hpr_header("war.battle.hp.wizards.001"),
		hpr_normal("war.battle.hp.wizards.002"),
		hpr_bulleted("war.battle.hp.wizards.003"),
		hpr_bulleted("war.battle.hp.wizards.004"),
		hpr_bulleted("war.battle.hp.wizards.005"),
		hpr_bulleted("war.battle.hp.wizards.006")
	);
	parser:add_record("battle_wizards", "script_link_battle_wizards", "tooltip_battle_wizards");
	wizards = tooltip_patcher:new("tooltip_battle_wizards");
	wizards:set_layout_data("tooltip_title_and_text", "ui_text_replacements_localised_text_hp_battle_title_wizards", "ui_text_replacements_localised_text_hp_battle_description_wizards");
end;








----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- infotext state mapping
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


do
	local infotext = get_infotext_manager();
	
	-- camera
	infotext:set_state_override("wh2.battle.intro.info_201", "prelude_controls_battle_camera");
	infotext:set_state_override("wh2.battle.intro.info_202", "prelude_controls_battle_camera_facing");
	infotext:set_state_override("wh2.battle.intro.info_203", "prelude_controls_battle_camera_altitude");
	-- infotext:set_state_override("wh2.battle.intro.info_204", "prelude_controls_battle_camera_speed");
	
	-- selection
	infotext:set_state_override("wh2.battle.intro.info_021", "prelude_controls_battle_selection");
	infotext:set_state_override("wh2.battle.intro.info_022", "prelude_controls_battle_multiple_selection");
	
	-- movement
	infotext:set_state_override("wh2.battle.intro.info_031", "prelude_controls_battle_unit_movement");
	infotext:set_state_override("wh2.battle.intro.info_051", "prelude_controls_battle_unit_destinations");
	infotext:set_state_override("wh2.battle.intro.info_052", "prelude_controls_battle_drag_out_formation");
	infotext:set_state_override("wh2.battle.intro.info_053", "prelude_controls_battle_halt");
	
	-- attacking
	infotext:set_state_override("wh2.battle.intro.info_061", "prelude_controls_battle_attacking");
	
end;



----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- cheat sheet functions
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


function show_battle_controls_cheat_sheet(show_help_panel_close_button)
	hp_controls_cheat_sheet:link_clicked();
	local hpm = get_help_page_manager();
	hpm:set_max_height(800);
	hpm:show_title_bar_buttons(false, show_help_panel_close_button);

	local uic_panel = hpm:get_uicomponent();
	local uic_listview = find_uicomponent(uic_panel, "listview");
	
	uic_listview:SetCanResizeWidth(true);
	uic_panel:SetCanResizeWidth(true);
	uic_panel:Resize(260, uic_panel:Height());
	uic_panel:SetCanResizeWidth(false);
	uic_listview:SetCanResizeWidth(false);
	
	local screen_x, screen_y = core:get_screen_resolution();
	local panel_x, panel_y = uic_panel:Position();
	local panel_size_x, panel_size_y = uic_panel:Bounds();
	
	uic_panel:MoveTo(screen_x - panel_size_x, 0);
end;



function append_selection_controls_to_cheat_sheet()
	hp_controls_cheat_sheet:append_help_page_record(hpr_header("war.battle.hp.controls_cheat_sheet.006"));
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_selection_controls("war.battle.hp.controls_cheat_sheet.007"));
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_multiple_selection_controls("war.battle.hp.controls_cheat_sheet.008"));
	hp_controls_cheat_sheet:append_help_page_record(hpr_header("war.battle.hp.controls_cheat_sheet.009"));
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_movement_controls("war.battle.hp.controls_cheat_sheet.010"));
end;


function append_movement_controls_to_cheat_sheet()
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_drag_out_formation_controls("war.battle.hp.controls_cheat_sheet.011"));
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_unit_destination_controls("war.battle.hp.controls_cheat_sheet.012"));
	-- hp_controls_cheat_sheet:append_help_page_record(hpr_battle_halt_controls("war.battle.hp.controls_cheat_sheet.013"));
end;


function append_attack_controls_to_cheat_sheet()
	hp_controls_cheat_sheet:append_help_page_record(hpr_battle_attack_controls("war.battle.hp.controls_cheat_sheet.014"));
end;
