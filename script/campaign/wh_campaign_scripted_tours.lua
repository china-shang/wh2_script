

enable_scripted_tours = not (core:is_tweaker_set("DISABLE_FULL_SCRIPTED_TOURS") or core:is_tweaker_set("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS"));
-- enable_scripted_tours = false;


function start_scripted_tours()
	if enable_scripted_tours then
		out("#### start_scripted_tours() ####");
		character_skill_point_tour:start();
		in_settlement_sieged_tour:start();
		in_interventions_tour:start();

		--Starting Flesh Lab Scripted tour in here instead of early_game.lua so it is used in both campaigns
		local throt_interface = cm:model():world():faction_by_key("wh2_main_skv_clan_moulder");
		if throt_interface:is_null_interface() == false and throt_interface:is_human() == true  then
			in_flesh_lab_tour:start();
		end

		--Starting Beastmen Panel Scripted tour in here instead of early_game.lua so it is used in both campaigns
		local khazrak_interface = cm:model():world():faction_by_key("wh_dlc03_bst_beastmen");
		local malagor_interface = cm:model():world():faction_by_key("wh2_dlc17_bst_malagor");
		local morghur_interface = cm:model():world():faction_by_key("wh_dlc05_bst_morghur_herd");
		local taurox_interface = cm:model():world():faction_by_key("wh2_dlc17_bst_taurox");

		if (khazrak_interface:is_null_interface() == false and khazrak_interface:is_human() == true) or (malagor_interface:is_null_interface() == false and malagor_interface:is_human() == true) or
			(morghur_interface:is_null_interface() == false and morghur_interface:is_human() == true) or (taurox_interface:is_null_interface() == false and taurox_interface:is_human() == true) then
			
			in_beastmen_panel_tour:start();
		end


	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Major Settlement Siege Tour
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
in_settlement_sieged_tour = intervention:new(
	"in_settlement_sieged_tour",			 							-- string name
	5, 																	-- cost
	function() trigger_settlement_siege_advice_tour() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);

in_settlement_sieged_tour:set_wait_for_battle_complete(false);

in_settlement_sieged_tour:add_advice_key_precondition("war.camp.advice.siege_weapons.001");

in_settlement_sieged_tour:add_precondition(
	function()
		return get_cm():get_campaign_name() == "wh2_main_great_vortex";				-- remove this in time
	end
);



in_settlement_sieged_tour:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedProvinceCapital",
	true
);

function trigger_settlement_siege_advice_tour()
	out("#### trigger_settlement_siege_advice_tour() ####");
	
	local advice_level = effect.get_advice_level();
	out("\tAdvice: "..advice_level);
	
	-- Get a handle to the siege panel. This may fail if the siege advice intervention was queued up
	-- behind something else and the panel was closed before this got called.
	local uic_siege_panel = find_uicomponent(core:get_ui_root(), "siege_information_panel");
	if not uic_siege_panel then
		script_error("WARNING: trigger_settlement_siege_advice_tour() could not find uic_siege_panel, exiting siege advice tour prematurely");
		in_settlement_sieged_tour:cancel();
		return;
	end;

	if advice_level == 2 then
		-- Long advice
		cm:show_advice("war.camp.advice.siege_weapons.001");
		cm:add_infotext(1, "war.camp.advice.siege_warfare.info_001", "war.camp.advice.siege_warfare.info_002");
		
		core:progress_on_uicomponent_animation_finished(
			uic_siege_panel,		
			function()
				settlement_sieged_advice_tour(uic_siege_panel)
			end
		);
	else
		-- Short advice
		cm:show_advice("war.camp.advice.siege_weapons.001", true);
		cm:add_infotext(1, "war.camp.advice.siege_warfare.info_001", "war.camp.advice.siege_warfare.info_002", "war.camp.advice.siege_warfare.info_003");
		
		cm:progress_on_advice_dismissed(
			function()
				in_settlement_sieged_tour:complete();
			end, 
			0, 
			true
		);
	end
end

function settlement_sieged_advice_tour(uic_siege_panel)
	out("#### settlement_sieged_advice_tour() ####");
	
	local uim = cm:get_campaign_ui_manager();
	uim:override("selection_change"):lock();
	uim:override("esc_menu"):lock();
	
	local uic_size_x, uic_size_y = uic_siege_panel:Dimensions();
	local uic_pos_x, uic_pos_y = uic_siege_panel:Position();
	
	local tp_siege_panel = text_pointer:new("siege_panel", uic_pos_x + 50, uic_pos_y + (uic_size_y / 2), 100, "right");
	tp_siege_panel:set_layout("text_pointer_title_and_text");
	tp_siege_panel:add_component_text("title", "ui_text_replacements_localised_text_hp_campaign_title_siege_panel");
	tp_siege_panel:add_component_text("text", "ui_text_replacements_localised_text_hp_campaign_description_siege_panel");
	tp_siege_panel:set_style("semitransparent_2_sec_highlight");
	tp_siege_panel:set_panel_width(350);
	
	-- Shows the next text pointer when this one is closed
	tp_siege_panel:set_close_button_callback(
		function()
			pulse_uicomponent(uic_siege_panel, false, 3, true)
			start_surrender_timer_advice();
		end
	);
	
	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	
	-- Show UI highlight
	cm:steal_user_input(true);
	cm:callback(
		function()
			cm:steal_user_input(false);
			core:show_fullscreen_highlight_around_components(25, false, uic_siege_panel);
		end,
		0.5
	);
	
	pulse_uicomponent(uic_siege_panel, true, 3, true);
	
	cm:callback(function() tp_siege_panel:show() end, 2);
end


function start_surrender_timer_advice()
	out("#### start_surrender_timer_advice() ####");
	
	-- get a handle to the siege panel
	local uic_siege_panel = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "regular_deployment");
	if not uic_siege_panel then
		print_all_uicomponent_children(core:get_ui_root());
		script_error("ERROR: start_surrender_timer_advice() can't find uic_siege_panel, how can this be?");
		return;
	end
	local uic_killometer = find_uicomponent(uic_siege_panel, "killometer");
	if not uic_killometer then
		script_error("ERROR: start_surrender_timer_advice() can't find uic_killometer, how can this be?");
		return;
	end
	local uic_turns = find_uicomponent(uic_siege_panel, "icon_turns");
	if not uic_turns then
		script_error("ERROR: start_surrender_timer_advice() can't find uic_turns, how can this be?");
		return;
	end
	local uic_attrition = find_uicomponent(uic_siege_panel, "icon_attrition");
	if not uic_attrition then
		script_error("ERROR: start_surrender_timer_advice() can't find uic_attrition, how can this be?");
		return;
	end
	
	pulse_uicomponent(uic_killometer, false, 3, true);
	pulse_uicomponent(uic_turns, true, 3, true);
	pulse_uicomponent(uic_attrition, true, 3, true);
	
	
	local uic_size_x_attrition, uic_size_y_attrition = uic_attrition:Dimensions();
	local uic_pos_x_attrition, uic_pos_y_attrition = uic_attrition:Position();
	
	local tp_siege_attrition = text_pointer:new("siege_attrition", uic_pos_x_attrition + (uic_size_x_attrition / 2), uic_pos_y_attrition, 50, "bottom");
	tp_siege_attrition:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_surrender_1");
	tp_siege_attrition:set_style("semitransparent");
	tp_siege_attrition:set_label_offset(-155, 0);
	tp_siege_attrition:set_panel_width(350);
	
	
	local uic_size_x_surrender, uic_size_y_surrender = uic_turns:Dimensions();
	local uic_pos_x_surrender, uic_pos_y_surrender = uic_turns:Position();
	
	local tp_siege_turns = text_pointer:new("siege_turns", uic_pos_x_surrender + (uic_size_x_surrender / 2), uic_pos_y_surrender, 50, "bottom");
	tp_siege_turns:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_surrender_2");
	tp_siege_turns:set_style("semitransparent_2_sec_highlight");
	tp_siege_turns:set_label_offset(155, 0);
	tp_siege_turns:set_panel_width(350);
	
	
	-- Shows the next text pointer when this one is closed
	tp_siege_turns:set_close_button_callback(
		function()
			tp_siege_turns:hide();
			tp_siege_attrition:hide();
			start_manpower_advice();
		end
	);
	
	cm:callback(function() tp_siege_attrition:show() end, 0.5);
	cm:callback(function() tp_siege_turns:show() end, 1);
end

function start_manpower_advice()
	out("#### start_manpower_advice() ####");
	
	-- get a handle to the siege panel
	local uic_siege_panel = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "regular_deployment");
	if not uic_siege_panel then
		script_error("ERROR: start_manpower_advice() can't find uic_siege_panel, how can this be?");
		return;
	end
	local uic_turns = find_uicomponent(uic_siege_panel, "icon_turns");
	if not uic_turns then
		script_error("ERROR: start_manpower_advice() can't find uic_turns, how can this be?");
		return;
	end
	local uic_attrition = find_uicomponent(uic_siege_panel, "icon_attrition");
	if not uic_attrition then
		script_error("ERROR: start_manpower_advice() can't find uic_attrition, how can this be?");
		return;
	end
	
	local uic_labour = find_uicomponent(uic_siege_panel, "dy_construction_strength");
	if not uic_labour then
		script_error("ERROR: start_manpower_advice() can't find uic_labour, how can this be?");
		return;
	end;
	
	local uic_labour_per = find_uicomponent(uic_siege_panel, "dy_construction_effort");
	if not uic_labour_per then
		script_error("ERROR: start_manpower_advice() can't find uic_labour_per, how can this be?");
		return;
	end
	
	pulse_uicomponent(uic_turns, false, 3, true);
	pulse_uicomponent(uic_attrition, false, 3, true);
	
	pulse_uicomponent(uic_labour, true, 3, true);
	pulse_uicomponent(uic_labour_per, true, 3, true);
	
	local uic_size_x, uic_size_y = uic_labour:Dimensions();
	local uic_pos_x, uic_pos_y = uic_labour:Position();
	
	local tp_siege_labour = text_pointer:new("siege", uic_pos_x + (uic_size_x / 2), uic_pos_y, 75, "bottom");
	tp_siege_labour:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_manpower_1");
	tp_siege_labour:set_style("semitransparent_2_sec_highlight");
	tp_siege_labour:set_label_offset(0, 0);
	tp_siege_labour:set_panel_width(400);
	
	-- Shows the next text pointer when this one is closed
	tp_siege_labour:set_close_button_callback(
		function() 
			tp_siege_labour:hide();
			start_siege_weapon_advice()
		end
	);
	
	cm:callback(function() tp_siege_labour:show() end, 0.5);
end

function start_siege_weapon_advice()
	out("#### start_siege_weapon_advice() ####");
	
	-- get a handle to the siege panel
	local uic_siege_panel = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "regular_deployment");
	if not uic_siege_panel then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_siege_panel, how can this be?");
		return;
	end
	
	local uic_labour = find_uicomponent(uic_siege_panel, "dy_construction_strength");
	if not uic_labour then
		script_error("ERROR: start_manpower_advice() can't find uic_labour, how can this be?");
		return;
	end
	local uic_labour_per = find_uicomponent(uic_siege_panel, "dy_construction_effort");
	if not uic_labour_per then
		script_error("ERROR: start_manpower_advice() can't find uic_labour_per, how can this be?");
		return;
	end
	
	local uic_siege_list = find_uicomponent(uic_siege_panel, "construction_options");
	if not uic_siege_list then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_siege_list, how can this be?");
		return;
	end
	
	pulse_uicomponent(uic_labour, false, 3, true);
	pulse_uicomponent(uic_labour_per, false, 3, true);
	
	local siege_weapons = {};
	local siege_count = uic_siege_list:ChildCount();
	
	for i = 0, siege_count - 1 do
		local child = UIComponent(uic_siege_list:Find(i));
		out("\tFound child: "..child:Id());
		
		table.insert(siege_weapons, child);
		
		pulse_uicomponent(child, true, 3, true);
	end
	
	local first_siege = siege_weapons[1];
	
	local uic_size_x, uic_size_y = first_siege:Dimensions();
	local uic_pos_x, uic_pos_y = first_siege:Position();
	
	local tp_siege_weapons = text_pointer:new("siege_weapons", uic_pos_x + (uic_size_x / 2), uic_pos_y, 150, "bottom");
	tp_siege_weapons:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_siege_weapons_1");
	tp_siege_weapons:set_style("semitransparent_2_sec_highlight");
	tp_siege_weapons:set_panel_width(400);
	
	-- Shows the next text pointer when this one is closed
	tp_siege_weapons:set_close_button_callback(
		function() 
			tp_siege_weapons:hide();
			start_siege_buttons_advice();
		end
	);
	
	cm:callback(function() tp_siege_weapons:show() end, 1);
end


function start_siege_buttons_advice()
	out("#### start_siege_buttons_advice() ####");
	
	core:hide_all_text_pointers();
	
	-- get a handle to the siege panel
	local uic_siege_panel = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "mid", "battle_deployment", "regular_deployment");
	if not uic_siege_panel then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_siege_panel, how can this be?");
		return;
	end
	
	local uic_siege_list = find_uicomponent(uic_siege_panel, "attacker_recruitment_options");
	if not uic_siege_list then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_siege_list, how can this be?");
		return;
	end
	
	local uic_button_attack = find_uicomponent(core:get_ui_root(), "button_attack");
	if not uic_button_attack then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_button_attack, how can this be?");
		return;
	end
	local uic_button_autoresolve = find_uicomponent(core:get_ui_root(), "button_autoresolve");
	if not uic_button_autoresolve then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_button_autoresolve, how can this be?");
		return;
	end
	local uic_button_retreat = find_uicomponent(core:get_ui_root(), "button_retreat");
	if not uic_button_retreat then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_button_retreat, how can this be?");
		return;
	end
	local uic_button_continue_siege = find_uicomponent(core:get_ui_root(), "button_continue_siege");
	if not uic_button_continue_siege then
		script_error("ERROR: start_siege_weapon_advice() can't find uic_button_continue_siege, how can this be?");
		return;
	end
	
	local siege_count = uic_siege_list:ChildCount();
	
	for i = 0, siege_count - 1 do
		local child = UIComponent(uic_siege_list:Find(i));
		pulse_uicomponent(child, false, 3, true);
	end
	
	local siege_buttons = {uic_button_attack, uic_button_autoresolve, uic_button_retreat, uic_button_continue_siege};
	
	pulse_uicomponent(uic_button_attack, true, 3, true);
	pulse_uicomponent(uic_button_autoresolve, true, 3, true);
	pulse_uicomponent(uic_button_retreat, true, 3, true);
	pulse_uicomponent(uic_button_continue_siege, true, 3, true);
	
	core:hide_fullscreen_highlight();
	core:show_fullscreen_highlight_around_components(25, false, unpack(siege_buttons));
	
	local uic_size_x_attack, uic_size_y_attack = uic_button_attack:Dimensions();
	local uic_pos_x_attack, uic_pos_y_attack = uic_button_attack:Position();
	
	local tp_siege_attack = text_pointer:new("siege_attack", uic_pos_x_attack + (uic_size_x_attack / 2), uic_pos_y_attack, 100, "bottom");
	tp_siege_attack:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_siege_buttons_1");
	tp_siege_attack:set_style("semitransparent");
	tp_siege_attack:set_label_offset(-150, 0);
	tp_siege_attack:set_panel_width(350);
	
	local uic_size_x_retreat, uic_size_y_retreat = uic_button_retreat:Dimensions();
	local uic_pos_x_retreat, uic_pos_y_retreat = uic_button_retreat:Position();
	
	local tp_siege_retreat = text_pointer:new("siege_retreat", uic_pos_x_retreat + (uic_size_x_retreat / 2), uic_pos_y_retreat, 100, "bottom");
	tp_siege_retreat:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_siege_buttons_2");
	tp_siege_retreat:set_style("semitransparent");
	tp_siege_retreat:set_label_offset(125, 0);
	tp_siege_retreat:set_panel_width(300);
	
	local uic_size_x_continue, uic_size_y_continue = uic_button_continue_siege:Dimensions();
	local uic_pos_x_continue, uic_pos_y_continue = uic_button_continue_siege:Position();
	
	local tp_siege_continue = text_pointer:new("siege_continue", uic_pos_x_continue + uic_size_x_continue, uic_pos_y_continue + uic_size_y_continue / 2, 100, "left");
	tp_siege_continue:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_siege_buttons_3");
	tp_siege_continue:set_style("semitransparent_2_sec_highlight");
	tp_siege_continue:set_label_offset(0, -40);
	tp_siege_continue:set_panel_width(300);
	
	tp_siege_continue:set_close_button_callback(
		function()
			tp_siege_attack:hide();
			tp_siege_retreat:hide();
			tp_siege_continue:hide();
			
			pulse_uicomponent(uic_button_attack, false, 3, true);
			pulse_uicomponent(uic_button_autoresolve, false, 3, true);
			pulse_uicomponent(uic_button_retreat, false, 3, true);
			pulse_uicomponent(uic_button_continue_siege, false, 3, true);
			
			core:hide_fullscreen_highlight();
			
			complete_settlement_siege_tour();
		end
	);
	
	cm:callback(function() tp_siege_attack:show() end, 1);
	cm:callback(function() tp_siege_retreat:show() end, 1.5);
	cm:callback(function() tp_siege_continue:show() end, 2);
end


function complete_settlement_siege_tour()
	out("#### start_siege_buttons_advice() ####");
	
	local uim = cm:get_campaign_ui_manager();
	uim:override("esc_menu"):unlock();
	uim:override("selection_change"):unlock();
	
	cm:modify_advice(true);
	
	in_settlement_sieged_tour:complete();
end





















--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Character Skill Point Tour
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
character_skill_point_tour = intervention:new(
	"character_skill_point_tour",			 							-- string name
	5, 																	-- cost
	function() trigger_skill_point_advice_tour() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);

character_skill_point_tour:add_precondition(
	function()
		return get_cm():get_campaign_name() == "wh2_main_great_vortex";				-- remove this in time
	end
);

character_skill_point_tour:add_advice_key_precondition("war.camp.advice.character_skills.001");

character_skill_point_tour:add_trigger_condition(
	"CharacterRankUp",
	function(context)	
		if context:character():faction():is_human() then
			character_skill_point_tour.char_cqi = context:character():cqi();
			character_skill_point_tour.is_general = context:character():character_type("general");
			character_skill_point_tour.is_faction_leader = context:character():is_faction_leader();
			return true;
		end
	end
);

function trigger_skill_point_advice_tour()
	out("#### trigger_skill_point_advice_tour() ####");
	
	-- clear selection, so that we always have to reselect the character
	CampaignUI.ClearSelection();
	
	local advice_level = effect.get_advice_level();
	out("\tAdvice: "..advice_level);
	
	-- we can't trigger for embedded heroes
	if advice_level == 2 and (character_skill_point_tour.is_general or not cm:get_character_by_cqi(character_skill_point_tour.char_cqi):is_embedded_in_military_force()) then
		-- Long advice
		character_selected_skill_point_advice_tour();
	else
		-- Short advice
		cm:show_advice("war.camp.advice.character_skills.001", true);
		cm:add_infotext(1, "war.camp.advice.character_skills.info_001", "war.camp.advice.character_skills.info_002", "war.camp.advice.character_skills.info_003", "war.camp.advice.character_skills.info_004");
		
		cm:progress_on_advice_dismissed(
			function()
				character_skill_point_tour:complete();
			end, 
			0, 
			true
		);
	end
end


function character_skill_points_tour_lock_ui(value)
	value = not not value;
	
	local overrides_to_lock = {
		"stances",
		"radar_rollout_buttons",
		"recruit_units",
		"disband_unit",
		"diplomacy",
		"technology",
		"rituals",
		"finance",
		"tactical_map",
		"faction_button",
		"missions",
		"intrigue_at_the_court",
		"geomantic_web",
		"slaves",
		"skaven_corruption",
		"esc_menu",
		"help_panel_button",
		"spell_browser",
		"camera_settings",
		"end_turn_options",
		"province_overview_panel_help_button",
		"mortuary_cult",
		"books_of_nagash",
		"regiments_of_renown",
		"sword_of_khaine"
	};
	
	if value then
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):lock();
		end;
	else
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):unlock();
		end;
	end;
end;







function character_selected_skill_point_advice_tour()
	out("#### character_selected_skill_point_advice_tour() ####");
	
	character_skill_points_tour_lock_ui(true);
	
	local objective_key = "wh2.camp.army_selection_advice.001";
	
	if not character_skill_point_tour.is_general then
		objective_key = "wh2.camp.army_selection_advice.002";
	end;
	
	local selected_advice = intro_campaign_select_advice:new(
		character_skill_point_tour.char_cqi,						-- Character CQI
		"war.camp.advice.character_skills.001",						-- Advice Key
		objective_key,												-- Objective Key
		function()													-- Completion Callback
			cm:override_ui("disable_selection_change", true);
			cm:callback(function() start_info_button_advice() end, 0.5);
		end
	);
	
	selected_advice:add_infotext(1, "war.camp.advice.character_skills.info_001", "war.camp.advice.character_skills.info_002", "war.camp.advice.character_skills.info_003");
	
	selected_advice:set_allow_selection_with_objective(true);
	selected_advice:start();
	
	cm:steal_user_input(true);
	
	cm:callback(
		function()
			cm:steal_user_input(false);
			cm:scroll_camera_with_cutscene_to_character(
				2,
				function()
					out("\tScrolling Camera...");
				end, 
				character_skill_point_tour.char_cqi
			);
		end,
		1
	);
end;


function start_info_button_advice()
	out("#### start_info_button_advice() ####");
	
	-- make the character info panel invisible
	find_uicomponent(core:get_ui_root(), "layout", "secondary_info_panel_holder"):SetVisible(false);
	
	-- get a handle to the character info panel
	local uic_character_info = find_uicomponent(core:get_ui_root(), "info_panel_holder");
	if not uic_character_info then
		script_error("ERROR: start_info_button_advice() can't find uic_character_info, how can this be?");
		return;
	end
	
	-- get a handle to the info button
	local uic_info_button = find_uicomponent(uic_character_info, "button_general");
	if not uic_info_button then
		script_error("ERROR: start_info_button_advice() can't find uic_info_button, how can this be?");
		return;
	end
	
	-- get a handle to the skill button
	local uic_skill_button = find_uicomponent(uic_character_info, "skill_button");
	if not uic_skill_button then
		script_error("ERROR: start_skill_point_advice() can't find uic_skill_button, how can this be?");
		return;
	end
	
	-- disable character details buttons
	uic_info_button:SetDisabled(true);
	uic_skill_button:SetDisabled(true);
	
	local info_size_x, info_size_y = uic_info_button:Dimensions();
	local info_pos_x, info_pos_y = uic_info_button:Position();
	
	local skill_size_x, skill_size_y = uic_skill_button:Dimensions();
	local skill_pos_x, skill_pos_y = uic_skill_button:Position();
	
	local tp_character_details_button = text_pointer:new("character_details_button", info_pos_x + (info_size_x / 2) + 15, (info_pos_y + (info_size_y / 2)) - 10, 250, "left");
	tp_character_details_button:set_layout("text_pointer_text_only");
	tp_character_details_button:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_character_details");
	tp_character_details_button:set_style("semitransparent_2_sec_highlight");
	tp_character_details_button:set_label_offset(0, -20);
	tp_character_details_button:set_topmost();
	tp_character_details_button:set_panel_width(400);
	
	local tp_character_skills_button = text_pointer:new("character_skills_button", skill_pos_x + (skill_size_x / 2) + 10, skill_pos_y + (skill_size_y / 2), 200, "bottom");
	tp_character_skills_button:set_layout("text_pointer_text_only");
	tp_character_skills_button:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_character_skills");
	tp_character_skills_button:set_style("semitransparent_2_sec_highlight");
	tp_character_skills_button:set_label_offset(180, 0);
	tp_character_skills_button:set_topmost();
	tp_character_skills_button:set_panel_width(400);
	
	-- Shows the next text pointer when this one is closed
	tp_character_details_button:set_close_button_callback(
		function()
			cm:callback(function() tp_character_skills_button:show() end, 0.5);
		end
	);
	
	tp_character_skills_button:set_close_button_callback(
		function()
			-- hide text pointers
			tp_character_details_button:hide();
			tp_character_skills_button:hide();
			
			-- dismiss fullscreen highlight
			core:hide_fullscreen_highlight();
			
			-- enable skill button
			uic_skill_button:SetDisabled(false);
			
			skill_point_advice_closed(uic_info_button);
		end
	);
	
	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	-- Show UI highlight
	core:show_fullscreen_highlight_around_components(25, false, uic_character_info);
	
	cm:callback(function() tp_character_details_button:show() end, 0.5);
end


function skill_point_advice_closed(uic_info_button)
	out("#### skill_point_advice_closed() ####");
	
	if character_skill_point_tour.is_faction_leader then
		cm:show_advice("wh2.camp.advice.skills.legendary.001", false);
	else
		cm:show_advice("wh2.camp.advice.skills.lord.001", false);
	end
	
	cm:set_objective("wh2.camp.open_character_panel_advice.001");
	
	core:add_listener(
		"skill_point_panel_opened",
		"PanelOpenedCampaign", 
		function(context) return context.string == "character_details_panel" end,
		function(context)
			cm:remove_callback("skill_button_highlight");
			
			-- re-enable the details button at this point
			uic_info_button:SetDisabled(false);
			
			highlight_component(false, false, "info_panel_holder", "skill_button");
			
			skill_point_panel_opened();
		end,
		false
	);
	
	cm:callback(function() highlight_component(true, false, "info_panel_holder", "skill_button") end, 0.5, "skill_button_highlight");
end

function skill_point_panel_opened()
	out("#### skill_point_panel_opened() ####");
		
	cm:complete_objective("wh2.camp.open_character_panel_advice.001");
	
	-- disable certain buttons
	character_skills_tour_enable_character_details_panel_close_button(false);
	character_skills_tour_enable_character_details_panel_details_tab_button(false);
	character_skills_tour_enable_character_details_panel_skills_tab_button(false);
	
	cm:callback(function() character_skills_tour_enable_character_details_panel_replace_lord_button(false) end, 0.1);
	
	cm:callback(
		function()
			cm:remove_objective("wh2.camp.open_character_panel_advice.001");
			start_skill_points_advice();
		end, 
		1
	);
end

function start_skill_points_advice()
	out("#### start_skill_points_advice() ####");
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_skill_point_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the skill points
	local uic_skill_points = find_uicomponent(uic_character_details_panel, "dy_pts");
	if not uic_skill_points then
		script_error("ERROR: start_skill_points_advice() can't find uic_skill_points, how can this be?");
		return;
	end
	-- get a handle to the skill points text
	local uic_skill_points_txt = find_uicomponent(uic_character_details_panel, "tx_skill");
	if not uic_skill_points_txt then
		script_error("ERROR: start_skill_points_advice() can't find uic_skill_points_txt, how can this be?");
		return;
	end
	
	local skill_size_x, skill_size_y = uic_skill_points:Dimensions();
	local skill_pos_x, skill_pos_y = uic_skill_points:Position();
	
	-- set up text pointers
	local tp_skill_points = text_pointer:new("skill_points", skill_pos_x + (skill_size_x / 2), skill_pos_y + (skill_size_y / 2) + 15, 150, "top");
	tp_skill_points:set_layout("text_pointer_text_only");
	tp_skill_points:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_skill_points");
	tp_skill_points:set_style("semitransparent_2_sec_highlight");
	tp_skill_points:set_label_offset(-180, 0);
	tp_skill_points:set_topmost();
	tp_skill_points:set_panel_width(400);
	
	local skill_components = {uic_skill_points, uic_skill_points_txt};
	
	core:show_fullscreen_highlight_around_components(25, false, unpack(skill_components));
	
	-- Shows the next text pointer when this one is closed
	tp_skill_points:set_close_button_callback(
		function()
			tp_skill_points:hide();
			start_skill_tree_advice();
		end
	);
	
	cm:callback(
		function()
			tp_skill_points:show();
		end, 
		1
	);
end

function start_skill_tree_advice()
	out("#### start_skill_tree_advice() ####");

	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_skill_tree_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the skill tree
	local uic_skill_tree = find_uicomponent(uic_character_details_panel, "skills_subpanel");
	if not uic_skill_tree then
		script_error("ERROR: start_skill_tree_advice() can't find uic_skill_tree, how can this be?");
		return;
	end
	
	core:hide_fullscreen_highlight();
	
	local skill_size_x, skill_size_y = uic_skill_tree:Dimensions();
	local skill_pos_x, skill_pos_y = uic_skill_tree:Position();
	
	-- set up text pointers
	local tp_skill_tree = text_pointer:new("skill_tree", skill_pos_x + 150, skill_pos_y + (skill_size_y / 2) + 200, 180, "right");
	tp_skill_tree:set_layout("text_pointer_text_only");
	tp_skill_tree:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_skill_tree");
	tp_skill_tree:set_style("semitransparent_2_sec_highlight");
	tp_skill_tree:set_label_offset(0, -50);
	tp_skill_tree:set_topmost();
	-- tp_skill_tree:set_panel_width(300);
	
	core:show_fullscreen_highlight_around_components(0, false, uic_skill_tree);
	
	-- Shows the next text pointer when this one is closed
	tp_skill_tree:set_close_button_callback(
		function()
			tp_skill_tree:hide();
			start_skill_point_task();
		end
	);
	
	cm:callback(
		function()
			tp_skill_tree:show();
		end, 
		1
	);
end


function start_skill_point_task()
	out("#### start_skill_point_task() ####");
	
	core:hide_fullscreen_highlight();
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_skill_tree_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the skill tree
	local uic_skill_tree = find_uicomponent(uic_character_details_panel, "skills_subpanel");
	if not uic_skill_tree then
		script_error("ERROR: start_skill_tree_advice() can't find uic_skill_tree, how can this be?");
		return;
	end
	
	-- Use interface function on detail panel to return Lua table of all skill component names
	local uic_table = uic_character_details_panel:InterfaceFunction("GetAllSkillComponents");
	local available_count = 0;
	local available_skills_cards = {};
	
	for i = 1, #uic_table do
		-- For each component name, find the corresponding component 
		local component = find_uicomponent(uic_character_details_panel, uic_table[i]);
		local card = UIComponent(component:Find("card"));
		
		-- Check if it is in the available state
		if card ~= nil then
			if card:CurrentState() == "available" then
				pulse_uicomponent(component, true, 3, true);
				table.insert(available_skills_cards, card);
			end
		end
	end;
	
	-- if there are no available skill points, then complete immediately
	if #available_skills_cards == 0 then
		skill_point_task_complete();
		return;
	end;
	
	cm:set_objective("wh2.camp.spend_skill_point.001");
	
	core:add_listener(
		"skill_point_task",
		"ComponentLClickUp", 
		function(context)
			local uic = UIComponent(context.component);
			output_uicomponent(uic)
			for i = 1, #available_skills_cards do
				if available_skills_cards[i] == uic then
					return true;
				end;
			end;
		end,
		function(context)
			skill_point_task_complete(true);
		end,
		false
	);
end


function character_skills_tour_enable_character_details_panel_close_button(value)
	if value == false then
		set_component_active_with_parent(false, core:get_ui_root(), "character_details_panel", "button_ok");
		cm:override_ui("disable_character_details_panel_closing", true);
	else
		cm:override_ui("disable_character_details_panel_closing", false);
		set_component_active_with_parent(true, core:get_ui_root(), "character_details_panel", "button_ok");
	end;
end;


function character_skills_tour_enable_character_details_panel_details_tab_button(value)
	if value == false then
		set_component_active_with_parent(false, core:get_ui_root(), "character_details_panel", "TabGroup", "details");
		cm:override_ui("disable_character_details_panel_details_tab", true);
	else
		cm:override_ui("disable_character_details_panel_details_tab", false);
		set_component_active_with_parent(true, core:get_ui_root(), "character_details_panel", "TabGroup", "details");
	end;
end;


function character_skills_tour_enable_character_details_panel_skills_tab_button(value)
	if value == false then
		set_component_active_with_parent(false, core:get_ui_root(), "character_details_panel", "TabGroup", "skills");
		cm:override_ui("disable_character_details_panel_skills_tab", true);
	else
		cm:override_ui("disable_character_details_panel_skills_tab", false);
		set_component_active_with_parent(true, core:get_ui_root(), "character_details_panel", "TabGroup", "skills");
	end;
end;


function character_skills_tour_enable_character_details_panel_replace_lord_button(value)
	if value == false then
		set_component_active_with_parent(false, core:get_ui_root(), "character_details_panel", "background", "bottom_buttons", "button_replace_general");
		cm:override_ui("disable_replace_general", true);
	else
		cm:override_ui("disable_replace_general", false);
		set_component_active_with_parent(true, core:get_ui_root(), "character_details_panel", "background", "bottom_buttons", "button_replace_general");
	end;
end;


function character_skills_tour_enable_character_details_panel_rename_button(value)
	if value == false then
		set_component_active_with_parent(false, core:get_ui_root(), "character_details_panel", "background", "button_rename");
	else
		set_component_active_with_parent(true, core:get_ui_root(), "character_details_panel", "background", "button_rename");
	end;
end;


function skill_point_task_complete(objective_was_set)
	out("#### skill_point_task_complete() ####");
	
	if objective_was_set then
		cm:complete_objective("wh2.camp.spend_skill_point.001");
	end;
	
	core:add_listener(
		"details_tab_clicked",
		"ComponentLClickUp",
		function(context)
			if context.string == "details" then
				local parent = UIComponent(context.component):Parent();
				if UIComponent(parent):Id() == "TabGroup" then
					return true;
				end
			end
			return false;
		end,
		function()
			details_tab_clicked();
		end,
		false
	);
	
	cm:callback(
		function()
			if objective_was_set then
				cm:remove_objective("wh2.camp.spend_skill_point.001");
			end;
			
			-- re-enable and highlight panel tab button	
			character_skills_tour_enable_character_details_panel_details_tab_button(true);
			highlight_component(true, true, "character_details_panel", "TabGroup" , "details");
			
			cm:set_objective("wh2.camp.open_details_tab.001");
		end, 
		1
	);
end

function details_tab_clicked()
	out("#### details_tab_clicked() ####");
	
	highlight_component(false, true, "character_details_panel", "TabGroup" , "details");
	
	character_skills_tour_enable_character_details_panel_details_tab_button(false);
	
	cm:complete_objective("wh2.camp.open_details_tab.001");
	
	cm:callback(function()
		cm:remove_objective("wh2.camp.open_details_tab.001");
		
		start_followers_advice();
	end, 1);
end

function start_followers_advice()
	out("#### start_followers_advice() ####");
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_followers_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the followers panel
	local uic_followers_panel = find_uicomponent(uic_character_details_panel, "ancillary_general");
	if not uic_followers_panel then
		script_error("ERROR: start_followers_advice() can't find uic_followers_panel, how can this be?");
		return;
	end
	
	local uic_followers_parent = find_uicomponent(uic_followers_panel, "list_parent");
	if not uic_followers_parent then
		script_error("ERROR: start_followers_advice() can't find uic_followers_parent, how can this be?");
		return;
	end
	
	-- get a handle to the first follower
	local uic_first_follower = UIComponent(uic_followers_parent:Find(0));
	
	-- pulse all the followers
	for i = 0, uic_followers_parent:ChildCount() - 1 do		
		pulse_uicomponent(UIComponent(uic_followers_parent:Find(i)), true, 5, true)
	end;
		
	local follower_size_x, follower_size_y = uic_first_follower:Dimensions();
	local follower_pos_x, follower_pos_y = uic_first_follower:Position();
		
	-- set up text pointers
	local tp_follower_1 = text_pointer:new("follower1", follower_pos_x + 20, follower_pos_y + (follower_size_y / 2), 200, "bottom");
	tp_follower_1:set_layout("text_pointer_text_only");
	tp_follower_1:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_followers_1");
	tp_follower_1:set_style("semitransparent_2_sec_highlight");
	tp_follower_1:set_label_offset(0, 0);
	tp_follower_1:set_topmost();
	tp_follower_1:set_panel_width(200);
	
	local tp_follower_2 = text_pointer:new("follower2", 0, 0, 0, "bottom");
	tp_follower_2:set_layout("text_pointer_text_only");
	tp_follower_2:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_followers_2");
	tp_follower_2:set_style("semitransparent_2_sec_highlight");
	tp_follower_2:set_label_offset(0, 0);
	tp_follower_2:set_topmost();
	tp_follower_2:set_panel_width(200);
	
	tp_follower_2:set_position_offset_to_text_pointer(tp_follower_1, 30, 0);
	
	local tp_follower_3 = text_pointer:new("follower3", 0, 0, 0, "bottom");
	tp_follower_3:set_layout("text_pointer_text_only");
	tp_follower_3:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_followers_3");
	tp_follower_3:set_style("semitransparent_2_sec_highlight");
	tp_follower_3:set_label_offset(0, 0);
	tp_follower_3:set_topmost();
	tp_follower_3:set_panel_width(200);
	
	tp_follower_3:set_position_offset_to_text_pointer(tp_follower_2, 30, 0);
	
	core:show_fullscreen_highlight_around_components(20, false, uic_followers_panel);
		
	-- Shows the next text pointer when this one is closed
	tp_follower_1:set_close_button_callback(
		function() 
			tp_follower_2:show();
		end
	);
	tp_follower_2:set_close_button_callback(
		function() 
			tp_follower_3:show();
		end
	);
	tp_follower_3:set_close_button_callback(
		function() 
			tp_follower_1:hide();
			tp_follower_2:hide();
			tp_follower_3:hide();
			
			for i = 0, uic_followers_parent:ChildCount() - 1 do		
				pulse_uicomponent(UIComponent(uic_followers_parent:Find(i)), false, 5, true)
			end;
		
			start_character_items_advice();
		end
	);
	
	cm:callback(
		function()
			tp_follower_1:show();
		end, 
		1
	);
end

function start_character_items_advice()
	out("#### start_character_items_advice() ####");

	core:hide_fullscreen_highlight();
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_followers_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	
	-- get a handle to the followers panel
	local uic_followers_panel = find_uicomponent(uic_character_details_panel, "ancillary_general");
	if not uic_followers_panel then
		script_error("ERROR: start_followers_advice() can't find uic_followers_panel, how can this be?");
		return;
	end
	
	-- get a handle to the items panel
	local uic_items_panel = find_uicomponent(uic_character_details_panel, "ancillary_equipment");
	if not uic_items_panel then
		script_error("ERROR: start_followers_advice() can't find uic_items_panel, how can this be?");
		return;
	end
	
	local uic_armour = find_uicomponent(uic_items_panel, "armour_0");
	local uic_weapon = find_uicomponent(uic_items_panel, "weapon_1");
	local uic_talisman = find_uicomponent(uic_items_panel, "talisman_2");
	local uic_item = find_uicomponent(uic_items_panel, "enchanted_item_3");
	local uic_mount = find_uicomponent(uic_items_panel, "mount_0");
	
	core:show_fullscreen_highlight_around_components(20, false, uic_items_panel);
	
	pulse_uicomponent(uic_armour, true, 3, true);
	pulse_uicomponent(uic_weapon, true, 3, true);
	pulse_uicomponent(uic_talisman, true, 3, true);
	pulse_uicomponent(uic_item, true, 3, true);
	pulse_uicomponent(uic_mount, true, 3, true);
		
	local talisman_size_x, talisman_size_y = uic_talisman:Dimensions();
	local talisman_pos_x, talisman_pos_y = uic_talisman:Position();
	
	-- set up text pointers
	local tp_weapon_1 = text_pointer:new("tp_weapon_1", talisman_pos_x + (talisman_size_x / 2), talisman_pos_y + (talisman_size_y / 2), 150, "top");
	tp_weapon_1:set_layout("text_pointer_text_only");
	tp_weapon_1:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_items_1");
	tp_weapon_1:set_style("semitransparent_2_sec_highlight");
	tp_weapon_1:set_label_offset(0, 0);
	tp_weapon_1:set_topmost();
	tp_weapon_1:set_panel_width(300);
	
	local tp_weapon_2 = text_pointer:new("tp_weapon_2", 0, 0, 0, "top");
	tp_weapon_2:set_layout("text_pointer_text_only");
	tp_weapon_2:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_items_2");
	tp_weapon_2:set_style("semitransparent_2_sec_highlight");
	tp_weapon_2:set_label_offset(0, 0);
	tp_weapon_2:set_topmost();
	tp_weapon_2:set_panel_width(300);
	
	tp_weapon_2:set_position_offset_to_text_pointer(tp_weapon_1, 30, 0);
	
	local tp_weapon_3 = text_pointer:new("tp_weapon_3", 0, 0, 0, "top");
	tp_weapon_3:set_layout("text_pointer_text_only");
	tp_weapon_3:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_items_3");
	tp_weapon_3:set_style("semitransparent_2_sec_highlight");
	tp_weapon_3:set_label_offset(0, 0);
	tp_weapon_3:set_topmost();
	tp_weapon_3:set_panel_width(300);
	
	tp_weapon_3:set_position_offset_to_text_pointer(tp_weapon_2, 30, 0);
	
	tp_weapon_1:set_close_button_callback(
		function()
			tp_weapon_2:show();
		end
	);
	tp_weapon_2:set_close_button_callback(
		function()
			tp_weapon_3:show();
		end
	);
	tp_weapon_3:set_close_button_callback(
		function()
			tp_weapon_1:hide();
			tp_weapon_2:hide();
			tp_weapon_3:hide();
		
			start_trait_advice();
		end
	);
	
	cm:callback(function() tp_weapon_1:show() end, 1);
end

function start_trait_advice()
	out("#### start_trait_advice() ####");

	core:hide_fullscreen_highlight();
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_followers_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the items panel
	local uic_items_panel = find_uicomponent(uic_character_details_panel, "ancillary_equipment");
	if not uic_items_panel then
		script_error("ERROR: start_followers_advice() can't find uic_items_panel, how can this be?");
		return;
	end
	-- get a handle to the traits panel
	local uic_traits_panel = find_uicomponent(uic_character_details_panel, "traits_subpanel");
	if not uic_traits_panel then
		script_error("ERROR: start_followers_advice() can't find uic_traits_panel, how can this be?");
		return;
	end
	
	local uic_armour = find_uicomponent(uic_items_panel, "armour_0");
	local uic_weapon = find_uicomponent(uic_items_panel, "weapon_1");
	local uic_talisman = find_uicomponent(uic_items_panel, "talisman_2");
	local uic_item = find_uicomponent(uic_items_panel, "enchanted_item_3");
	local uic_mount = find_uicomponent(uic_items_panel, "mount_0");
	
	pulse_uicomponent(uic_armour, false, 3, true);
	pulse_uicomponent(uic_weapon, false, 3, true);
	pulse_uicomponent(uic_talisman, false, 3, true);
	pulse_uicomponent(uic_item, false, 3, true);
	pulse_uicomponent(uic_mount, false, 3, true);
	
	core:show_fullscreen_highlight_around_components(20, false, uic_traits_panel);
	pulse_uicomponent(uic_traits_panel, true, 3, true);
	
	local traits_size_x, traits_size_y = uic_traits_panel:Dimensions();
	local traits_pos_x, traits_pos_y = uic_traits_panel:Position();
	
	-- set up text pointers
	local tp_traits = text_pointer:new("tp_traits", traits_pos_x + (traits_size_x / 3), traits_pos_y + 10, 100, "bottom");
	tp_traits:set_layout("text_pointer_text_only");
	tp_traits:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_traits");
	tp_traits:set_style("semitransparent_2_sec_highlight");
	tp_traits:set_label_offset(0, 0);
	tp_traits:set_topmost();
	
	tp_traits:set_close_button_callback(
		function()
			tp_traits:hide();
			start_character_info_advice();
		end
	);
	
	cm:callback(function()
		tp_traits:show();
	end, 1);
	cm:callback(function()
		pulse_uicomponent(uic_traits_panel, false, 3, true);
	end, 3);
end

function start_character_info_advice()
	out("#### start_character_info_advice() ####");
	
	core:hide_fullscreen_highlight();
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: start_character_info_advice() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the info panel
	local uic_info_panel = find_uicomponent(uic_character_details_panel, "background", "character_details_subpanel", "frame", "details");
	if not uic_info_panel then
		script_error("ERROR: start_character_info_advice() can't find uic_info_panel, how can this be?");
		return;
	end
	
	core:show_fullscreen_highlight_around_components(20, false, uic_info_panel);
	pulse_uicomponent(uic_info_panel, true, 3, true);
	
	local info_size_x, info_size_y = uic_info_panel:Dimensions();
	local info_pos_x, info_pos_y = uic_info_panel:Position();
	
	local info_type = "wh2_intro_campaign_character_info_1";
	local info_width = 400;
	if character_skill_point_tour.is_general then
		info_type = "wh2_intro_campaign_character_info_2";
		-- info_width = 800;
	end
	
	-- set up text pointers
	local tp_info_1 = text_pointer:new("tp_info_1", info_pos_x + (info_size_x / 4), info_pos_y, 100, "bottom");
	tp_info_1:set_layout("text_pointer_text_only");
	tp_info_1:add_component_text("text", "ui_text_replacements_localised_text_"..info_type);
	tp_info_1:set_style("semitransparent_2_sec_highlight");
	tp_info_1:set_label_offset(0, 0);
	tp_info_1:set_topmost();
	tp_info_1:set_panel_width(info_width);
		
	local uic_loyalty = find_uicomponent(uic_info_panel, "tx_loyalty");
		
	if uic_loyalty and uic_loyalty:Visible() == true then
		local loyalty_size_x, loyalty_size_y = uic_loyalty:Dimensions();
		local loyalty_pos_x, loyalty_pos_y = uic_loyalty:Position();
		
		local tp_info_2 = text_pointer:new("tp_info_2", loyalty_pos_x + (loyalty_size_x / 2), loyalty_pos_y + (loyalty_size_y / 2), 200, "left");
		tp_info_2:set_layout("text_pointer_text_only");
		tp_info_2:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_character_info_3");
		tp_info_2:set_style("semitransparent_2_sec_highlight");
		tp_info_2:set_label_offset(0, 0);
		tp_info_2:set_topmost();
		tp_info_2:set_panel_width(400);
		
		tp_info_1:set_close_button_callback(
			function()
				tp_info_2:show();
			end
		);
		tp_info_2:set_close_button_callback(
			function()
				tp_info_1:hide();
				tp_info_2:hide();
				complete_character_details_tour();
			end
		);
	else
		out("\tSkipping loyalty advice...");
		tp_info_1:set_close_button_callback(
			function()
				tp_info_1:hide();
				complete_character_details_tour();
			end
		);
	end
	
	cm:callback(function() tp_info_1:show() end, 1);
end

function complete_character_details_tour()
	out("#### complete_character_details_tour() ####");
	
	cm:override_ui("disable_selection_change", false);
	
	core:hide_fullscreen_highlight();
	
	-- get a handle to the character info panel
	local uic_character_details_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	if not uic_character_details_panel then
		script_error("ERROR: complete_character_details_tour() can't find uic_character_details_panel, how can this be?");
		return;
	end
	-- get a handle to the info panel
	local uic_info_panel = find_uicomponent(uic_character_details_panel, "background", "character_details_subpanel", "frame", "details");
	if not uic_info_panel then
		script_error("ERROR: complete_character_details_tour() can't find uic_info_panel, how can this be?");
		return;
	end
	
	pulse_uicomponent(uic_info_panel, false, 3, true);
	
	cm:set_objective("wh2.camp.close_details_panel.001");
	
	highlight_component(true, false, "character_details_panel", "button_ok");
	
	-- re-enable UI
	character_skills_tour_enable_character_details_panel_close_button(true);
	character_skills_tour_enable_character_details_panel_details_tab_button(true);
	character_skills_tour_enable_character_details_panel_skills_tab_button(true);	
	character_skills_tour_enable_character_details_panel_replace_lord_button(true);
	character_skills_tour_enable_character_details_panel_rename_button(true);
	
	character_skill_points_tour_lock_ui(false);
	
	core:add_listener(
		"skill_point_panel_closed",
		"PanelClosedCampaign",
		function(context) return context.string == "character_details_panel" end,
		function(context)

			-- make the character info panel visible again
			find_uicomponent(core:get_ui_root(), "layout", "secondary_info_panel_holder"):SetVisible(true);

			cm:complete_objective("wh2.camp.close_details_panel.001");
			highlight_component(false, false, "character_details_panel", "button_ok");
			cm:callback(function() cm:remove_objective("wh2.camp.close_details_panel.001") end, 1);
			character_skill_point_tour:complete();
			
			-- show advisor close button
			cm:modify_advice(true);
		end,
		false
	);
end






--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Interventions Tour
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

in_interventions_tour = intervention:new(
	"interventions_tour",			 									-- string name
	5, 																	-- cost
	function() trigger_interventions_advice_tour() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);

in_interventions_tour:add_precondition(
	function()
		return get_cm():get_campaign_name() == "wh2_main_great_vortex" and cm:get_faction(cm:get_local_faction_name()):has_pooled_resource("wh2_main_ritual_currency") and cm:get_local_faction_name() ~= "wh2_main_def_hag_graef";
	end
);

in_interventions_tour:add_advice_key_precondition("wh2.camp.advice.intervention_armies.001");

in_interventions_tour:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context) return cm:get_saved_value("ai_starts_first_ritual_intervention_triggered") end
);


function interventions_tour_lock_ui(value)

	value = not not value;

	CampaignUI.ClearSelection();
	
	local overrides_to_lock = {
		"selection_change",
		"stances",
		"radar_rollout_buttons",
		"recruit_units",
		"disband_unit",
		"diplomacy",
		"technology",
		"rituals",
		"finance",
		"tactical_map",
		"faction_button",
		"missions",
		"intrigue_at_the_court",
		"geomantic_web",
		"slaves",
		"skaven_corruption",
		"esc_menu",
		"help_panel_button",
		"spell_browser",
		"camera_settings",
		"end_turn_options",
		"mortuary_cult",
		"books_of_nagash",
		"regiments_of_renown",
		"sword_of_khaine"
	};
	
	if value then
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):lock();
		end;
	else
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):unlock();
		end;
	end;
end;


function trigger_interventions_advice_tour()

	interventions_tour_lock_ui(true);

	cm:show_advice("wh2.camp.advice.intervention_armies.001");
	cm:add_infotext(1, "wh2.camp.advice.intervention_armies.info_001", "wh2.camp.advice.intervention_armies.info_002", "wh2.camp.advice.intervention_armies.info_003");
	
	if effect.get_advice_level() == 2 then
		cm:modify_advice(false);
	
		local uic_interventions_button = find_uicomponent(core:get_ui_root(), "toggle_interrupt_button");
		
		local uic_interventions_button_size_x, uic_interventions_button_size_y = uic_interventions_button:Dimensions();
		local uic_interventions_button_pos_x, uic_interventions_button_pos_y = uic_interventions_button:Position();
		
		local tp_interventions_button = text_pointer:new("interventions_button", uic_interventions_button_pos_x + (uic_interventions_button_size_x / 2), uic_interventions_button_pos_y + uic_interventions_button_size_y, 125, "top");
		tp_interventions_button:set_layout("text_pointer_text_only");
		tp_interventions_button:set_panel_width(300);
		tp_interventions_button:add_component_text("text", "ui_text_replacements_localised_text_hp_campaign_point_1_intervention_armies");
		tp_interventions_button:set_style("semitransparent_2_sec_highlight");
		tp_interventions_button:set_hide_on_close_button_clicked(true);
		
		tp_interventions_button:set_close_button_callback(
			function()
				cm:modify_advice(true);
				interventions_tour_lock_ui(false);
				in_interventions_tour:complete();
			end
		);
		
		tp_interventions_button:show();
	else
		cm:modify_advice(true);
		cm:progress_on_advice_dismissed(
			function()
				interventions_tour_lock_ui(false);
				in_interventions_tour:complete();
			end, 
			0, 
			true
		);
	end;
end;




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Flesh Lab Tour
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

in_flesh_lab_tour = intervention:new(
	"in_flesh_lab_tour",			 									-- string name
	5, 																	-- cost
	function() 															-- trigger callback
		--dismiss the advisor to get him out of the tour
		cm:dismiss_advice()
		trigger_flesh_lab_scripted_tour() 
	end,					
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);


in_flesh_lab_tour:add_advice_key_precondition("wh2_dlc16.camp.advice.skv.flesh_lab.004.augmentation");

in_flesh_lab_tour:set_wait_for_fullscreen_panel_dismissed(true);

in_flesh_lab_tour:add_trigger_condition(
	"ScriptEventPlayerStartsOpenCampaignFromNormal",
	true
);


function flesh_lab_tour_lock_ui(value)

	local uim = cm:get_campaign_ui_manager();

	value = not not value;

	CampaignUI.ClearSelection();
	
	local overrides_to_lock = {
		"selection_change",
		"stances",
		"radar_rollout_buttons",
		"recruit_units",
		"disband_unit",
		"diplomacy",
		"technology",
		"rituals",
		"finance",
		"tactical_map",
		"faction_button",
		"missions",
		"intrigue_at_the_court",
		"geomantic_web",
		"slaves",
		"skaven_corruption",
		"esc_menu",
		"help_panel_button",
		"spell_browser",
		"camera_settings",
		"end_turn_options",
		"mortuary_cult",
		"books_of_nagash",
		"regiments_of_renown",
		"sword_of_khaine"
	};
	
	if value then
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):lock();
		end;
	else
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):unlock();			
		end;
		-- lift fullscreen highlight
		core:hide_fullscreen_highlight();
		cm:dismiss_advice();
		in_flesh_lab_tour:complete();
	end;
end;


function trigger_flesh_lab_scripted_tour()
	

	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	cm:show_advice("wh2_dlc16.camp.advice.skv.flesh_lab.004.augmentation");


	if cm:get_campaign_ui_manager():is_panel_open("augment_panel") then
		local uic_panel = find_child_uicomponent(core:get_ui_root(), "augment_panel");
		if not uic_panel then
			script_error("ERROR: flesh_lab_scripted_tour_open_panel() could not find the flesh lab panel, how can this be?");
			flesh_lab_tour_lock_ui(false);
			return false;
		end;
		flesh_lab_scripted_tour_tabs_advice(uic_panel)

	else

		local uic_flesh_lab_button = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_flesh_lab");
		if not uic_flesh_lab_button then
			script_error("ERROR: trigger_flesh_lab_scripted_tour() could not find the flesh lab button, how can this be?");
			return false;
		end;
		
		-- lock ui
		flesh_lab_tour_lock_ui(true);
		
		-- show fullscreen highlight around the flesh lab button
		core:show_fullscreen_highlight_around_components(25, false, uic_flesh_lab_button);
		
		-- pulse the button
		pulse_uicomponent(uic_flesh_lab_button, true, 5);
		
		-- set up button text pointer
		local uic_flesh_lab_button_size_x, uic_flesh_lab_button_size_y = uic_flesh_lab_button:Dimensions();
		local uic_flesh_lab_button_pos_x, uic_flesh_lab_button_pos_y = uic_flesh_lab_button:Position();
		
		local tp_flesh_lab_button = text_pointer:new("flesh_lab_button", uic_flesh_lab_button_pos_x + uic_flesh_lab_button_size_x / 5, uic_flesh_lab_button_pos_y + (uic_flesh_lab_button_size_y / 2), 100, "right");
		tp_flesh_lab_button:set_layout("text_pointer_text_only");
		tp_flesh_lab_button:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_button");
		tp_flesh_lab_button:set_style("semitransparent_2_sec_highlight");
		tp_flesh_lab_button:set_panel_width(300);
		
		tp_flesh_lab_button:set_close_button_callback(
			function()
				-- hide text pointer
				tp_flesh_lab_button:hide();

				-- stop pulsing button
				pulse_uicomponent(uic_flesh_lab_button, false, 5);

				flesh_lab_scripted_tour_open_panel(uic_flesh_lab_button)
			end
		);
		
		cm:callback(
			function()
				tp_flesh_lab_button:show();
			end,
			0.5
		);
	end

end;

function flesh_lab_scripted_tour_open_panel(uic_flesh_lab_button)
	
	local event_name = "flesh_lab_scripted_tour";		
				
	-- lift fullscreen highlight
	core:hide_fullscreen_highlight();

	-- establish listener for the flesh lab panel opening						
	core:add_listener(
		event_name,
		"PanelOpenedCampaign",
		function(context)
			return context.string == "augment_panel"
		end,
		function(context)
			out("%%%%% Flesh Lab panel opened");
		
			cm:remove_callback(event_name);
			
			local uic_panel = find_uicomponent(core:get_ui_root(), "augment_panel");
			if not uic_panel then
				script_error("ERROR: flesh_lab_scripted_tour_open_panel() could not find the flesh lab panel, how can this be?");
				flesh_lab_tour_lock_ui(false);
				return false;
			end;
			
			-- wait for the panel to finish animating
			core:progress_on_uicomponent_animation(
				event_name, 
				uic_panel, 
				function()	
					flesh_lab_scripted_tour_tabs_advice(uic_panel)
				end
			);
		end,
		false
	);
	-- failsafe: panel hasn't opened for some reason, exit
	cm:callback(
		function()
			script_error("WARNING: flesh_lab_scripted_tour_open_panel() attempted to open the Flesh Lab panel but it didn't open, exiting");
			core:remove_listener(event_name);
			flesh_lab_tour_lock_ui(false);
			return false;
		end,
		0.5,
		event_name
	);						
	
	-- simulate click on flesh lab button to open the flesh lab panel
	uic_flesh_lab_button:SimulateLClick();

end

function flesh_lab_scripted_tour_tabs_advice(uic_panel)
	
	--uic_panel:StealShortcutKey(false);

	local uic_flesh_lab_tabs = find_uicomponent(uic_panel, "top_bar_holder", "button_tab_holder");
	local uic_augment_inf_button = find_uicomponent(uic_flesh_lab_tabs, "button_infantry_augments");
	local uic_augment_mon_button = find_uicomponent(uic_flesh_lab_tabs, "button_monster_augments");
	
	if not uic_flesh_lab_tabs then
		script_error("WARNING: flesh_lab_scripted_tour_tabs_advice() could not find the button_tab_holder uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;

	if not uic_augment_inf_button then
		script_error("WARNING: trigger_flesh_lab_flesh_lab_scripted_tour_tabs_advicescripted_tour() could not find the infantry augment button uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;

	if not uic_augment_mon_button then
		script_error("WARNING: flesh_lab_scripted_tour_tabs_advice() could not find the monster augment button uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the tabs
	core:show_fullscreen_highlight_around_components(25, false, uic_flesh_lab_tabs);
	
	-- pulse each of the augment tabs
	pulse_uicomponent(uic_augment_inf_button, true, 5, true);
	pulse_uicomponent(uic_augment_mon_button, true, 5, true);
	
	-- set up text pointer
	local uic_flesh_lab_tabs_size_x, uic_flesh_lab_tabs_size_y = uic_flesh_lab_tabs:Dimensions();
	local uic_flesh_lab_tabs_pos_x, uic_flesh_lab_tabs_pos_y = uic_flesh_lab_tabs:Position();
	
	local tp_flesh_lab_tabs = text_pointer:new("flesh_lab_tabs", uic_flesh_lab_tabs_pos_x + 7*(uic_flesh_lab_tabs_size_x/48), uic_flesh_lab_tabs_pos_y + uic_flesh_lab_tabs_size_y, 100, "top");
	tp_flesh_lab_tabs:set_layout("text_pointer_text_only");
	tp_flesh_lab_tabs:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_tabs");
	tp_flesh_lab_tabs:set_style("semitransparent_2_sec_highlight");
	tp_flesh_lab_tabs:set_panel_width(300);
	
	tp_flesh_lab_tabs:set_close_button_callback(
		function()
			-- hide text pointer
			tp_flesh_lab_tabs:hide();

			-- stop pulsing highlight of augment tabs
			pulse_uicomponent(uic_augment_inf_button, false, 5, true);
			pulse_uicomponent(uic_augment_mon_button, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();
		
			flesh_lab_scripted_tour_augment_hex_advice(uic_panel)
		
		end
	);

	cm:callback(
		function()
			tp_flesh_lab_tabs:show();
		end,
		0.5
	);

end

function flesh_lab_scripted_tour_augment_hex_advice(uic_panel)
	
	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()

	local uic_augments_hex = find_uicomponent(uic_panel, "augment_holder", "augment_upgrades_holder",  "upgrades_holder", "hex_map_holder");

	if not uic_augments_hex then
		script_error("WARNING: flesh_lab_scripted_tour_augment_hex_advice() could not find the uic_augments_hex uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;
	
	local uic_inf_augment_3 = find_uicomponent(uic_augments_hex, "hex_map", "3_INFANTRY",  "hex_item");

	if not uic_inf_augment_3 then
		script_error("WARNING: flesh_lab_scripted_tour_augment_hex_advice() could not find the uic_inf_augment_3 uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;

	-- simulate click on the third infantry hex to see its effects during tour
	uic_inf_augment_3:SimulateLClick();

	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_augments_hex);
	
	-- pulse the hex grid
	pulse_uicomponent(uic_augments_hex, true, 5, true);
	
	-- set up text pointer
	local uic_augments_hex_size_x, uic_augments_hex_size_y = uic_augments_hex:Dimensions();
	local uic_augments_hex_pos_x, uic_augments_hex_pos_y = uic_augments_hex:Position();
	
	local tp_augments_hex = text_pointer:new("augment_hex", uic_augments_hex_pos_x + uic_augments_hex_size_x, uic_augments_hex_pos_y + (uic_augments_hex_size_y / 2), 50, "left");
	tp_augments_hex:set_layout("text_pointer_text_only");
	tp_augments_hex:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_augment_hex");
	tp_augments_hex:set_style("semitransparent_2_sec_highlight");
	tp_augments_hex:set_panel_width(350);

	tp_augments_hex:set_close_button_callback(
		function()
			-- hide text pointer
			tp_augments_hex:hide();
			
			-- stop pulsing the hex grid
			pulse_uicomponent(uic_augments_hex, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();

			flesh_lab_scripted_tour_augment_effects_advice(uic_panel)
		end
	);	
	
	cm:callback(
		function()
			tp_augments_hex:show();
		end,
		0.5
	);

end

function flesh_lab_scripted_tour_augment_effects_advice(uic_panel)
	
	
	local uic_augments_effects = find_uicomponent(uic_panel, "augment_holder", "augment_upgrades_holder",  "upgrades_holder", "upgrade_info_holder");

	if not uic_augments_effects then
		script_error("WARNING: flesh_lab_scripted_tour_augment_effects_advice() could not find the upgrade_info_holder uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_augments_effects);
	
	-- pulse the augment effects holder
	pulse_uicomponent(uic_augments_effects, true, 5, true);
	
	-- set up text pointer
	local uic_augments_effects_size_x, uic_augments_effects_size_y = uic_augments_effects:Dimensions();
	local uic_augments_effects_pos_x, uic_augments_effects_pos_y = uic_augments_effects:Position();
	
	local tp_augments_effects = text_pointer:new("augment_effects", uic_augments_effects_pos_x, uic_augments_effects_pos_y + (uic_augments_effects_size_y / 2), 50, "right");
	tp_augments_effects:set_layout("text_pointer_text_only");
	tp_augments_effects:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_augment_effects");
	tp_augments_effects:set_style("semitransparent_2_sec_highlight");
	tp_augments_effects:set_panel_width(350);

	tp_augments_effects:set_close_button_callback(
		function()
			-- hide text pointer
			tp_augments_effects:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_augments_effects, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			flesh_lab_scripted_tour_units_holder_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_augments_effects:show();
		end,
		0.5
	);

end

function flesh_lab_scripted_tour_units_holder_advice(uic_panel)

	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	--show the instability advice
	cm:show_advice("wh2_dlc16.camp.advice.skv.flesh_lab.006.instability")
	
	local uic_units = find_uicomponent(uic_panel, "augment_tab", "units_holder");

	if not uic_units then
		script_error("WARNING: flesh_lab_scripted_tour_units_holder_advice() could not find the units_holder uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_units);
	
	-- set up text pointer
	local uic_units_size_x, uic_units_size_y = uic_units:Dimensions();
	local uic_units_pos_x, uic_units_pos_y = uic_units:Position();
	
	local tp_units = text_pointer:new("unit_holder", uic_units_pos_x + (uic_units_size_x/2), uic_units_pos_y + (uic_units_size_y/5), 100, "bottom");
	tp_units:set_layout("text_pointer_text_only");
	tp_units:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_unit_holder");
	tp_units:set_style("semitransparent_2_sec_highlight");
	tp_units:set_panel_width(500);

	tp_units:set_close_button_callback(
		function()	
			-- hide text pointer
			tp_units:hide();
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();

			flesh_lab_scripted_tour_growth_vat_advice(uic_panel);
		end
	);

	cm:callback(
		function()
			tp_units:show();
		end,
		0.5
	);

end

function flesh_lab_scripted_tour_growth_vat_advice(uic_panel)																		

	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()

	local uic_growth_vat = find_uicomponent(uic_panel, "growth_vat_bar_holder", "growth_vat_bar");

	if not uic_growth_vat then
		script_error("WARNING: flesh_lab_scripted_tour_growth_vat_advice() could not find the growth_vat_bar uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(40, false, uic_growth_vat);
	
	-- pulse the growth vat
	pulse_uicomponent(uic_growth_vat, true, 5, true);
	
	-- set up text pointer
	local uic_growth_vat_size_x, uic_growth_vat_size_y = uic_growth_vat:Dimensions();
	local uic_growth_vat_pos_x, uic_growth_vat_pos_y = uic_growth_vat:Position();
	
	local tp_growth_vat = text_pointer:new("growth_vat", uic_growth_vat_pos_x + (uic_growth_vat_size_x/2), uic_growth_vat_pos_y + uic_growth_vat_size_y, 50, "top");
	tp_growth_vat:set_layout("text_pointer_text_only");
	tp_growth_vat:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_growth_vat");
	tp_growth_vat:set_style("semitransparent_2_sec_highlight");
	tp_growth_vat:set_panel_width(400);
	tp_growth_vat:set_close_button_callback(
		function()
			-- hide text pointer
			tp_growth_vat:hide();

			-- stop pulsing highlight of the growth vat
			pulse_uicomponent(uic_growth_vat, false, 5, true);

			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();

			flesh_lab_scripted_tour_lab_upgrades_advice(uic_panel)
		end
	);
	cm:callback(
		function()
			tp_growth_vat:show();
		end,
		0.5
	);
end

function flesh_lab_scripted_tour_lab_upgrades_advice(uic_panel)	

	local event_name = "flesh_lab_scripted_tour_lab";	
	local uic_augment_lab_button = find_uicomponent(uic_panel, "top_bar_holder", "button_tab_holder", "button_lab");

	if not uic_augment_lab_button then
		script_error("WARNING: flesh_lab_scripted_tour_lab_upgrades_advice() could not find the lab upgrades button uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_augment_lab_button);

	--this was declared earlier, pulse highlight the lab upgrade tab
	pulse_uicomponent(uic_augment_lab_button, true, 5, true);

	local uic_augment_lab_button_size_x, uic_augment_lab_button_size_y = uic_augment_lab_button:Dimensions();
	local uic_augment_lab_button_pos_x, uic_augment_lab_button_pos_y = uic_augment_lab_button:Position();
	
	local tp_lab_upgrades = text_pointer:new("lab_upgrades_tab", uic_augment_lab_button_pos_x + (uic_augment_lab_button_size_x/2), uic_augment_lab_button_pos_y + uic_augment_lab_button_size_y, 30, "top");
	tp_lab_upgrades:set_layout("text_pointer_text_only");
	tp_lab_upgrades:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_upgrades_tab");
	tp_lab_upgrades:set_style("semitransparent_2_sec_highlight");
	tp_lab_upgrades:set_panel_width(300);
	tp_lab_upgrades:set_close_button_callback(
		function()	

			-- establish listener for the flesh lab panel opening						
			core:add_listener(
				event_name,
				"ComponentLClickUp", 
				function(context) 
					return UIComponent(context.component) == find_uicomponent(uic_augment_lab_button);
				end, 
				function(context)
					out("%%%%% Lab Upgrades tab opened");
				
					cm:remove_callback(event_name);

					-- wait for the panel to finish animating
					core:progress_on_uicomponent_animation(
						event_name, 
						uic_augment_lab_button, 
						function()
							-- hide text pointer
							tp_lab_upgrades:hide();
							
							-- stop pulsing highlight of the units holder
							pulse_uicomponent(uic_augment_lab_button, false, 5, true);
							
							-- lift fullscreen highlight
							core:hide_fullscreen_highlight();

							flesh_lab_scripted_tour_upgrades_holder_advice(uic_panel)
						end
					);
				end, 
				false
			);
			-- failsafe: tab hasn't opened for some reason, exit
			cm:callback(
				function()
					script_error("WARNING: flesh_lab_scripted_tour_lab_upgrades_advice() attempted to open Lab Upgrades tab but it didn't open, exiting");
					core:remove_listener(event_name);
					flesh_lab_tour_lock_ui(false);
					return false;
				end,
				0.5,
				event_name
			);						
			
			-- simulate click on lab upgrades tab to open it in the flesh lab panel
			uic_augment_lab_button:SimulateLClick();							
				
		end
	);
	cm:callback(
		function()
			tp_lab_upgrades:show();
		end,
		0.5
	);
end

function flesh_lab_scripted_tour_upgrades_holder_advice(uic_panel)

	local uic_upgrades_holder = find_uicomponent(uic_panel, "laboratory_tab", "upgrades_holder", "ritual_upgrades_holder", "listview", "list_clip");

	if not uic_upgrades_holder then
		script_error("WARNING: trigger_flesh_lab_scripted_tour() could not find the upgrades_holder uicomponent in the flesh lab, how can this be?");
		flesh_lab_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_upgrades_holder);
	
	-- pulse the growth vat
	pulse_uicomponent(uic_upgrades_holder, true, 5, true);
	
	-- set up text pointer
	local uic_upgrades_holder_size_x, uic_upgrades_holder_size_y = uic_upgrades_holder:Dimensions();
	local uic_upgrades_holder_pos_x, uic_upgrades_holder_pos_y = uic_upgrades_holder:Position();
	
	local tp_upgrades_holder = text_pointer:new("upgrades", uic_upgrades_holder_pos_x, uic_upgrades_holder_pos_y + (uic_upgrades_holder_size_y / 2), 50, "right");
	tp_upgrades_holder:set_layout("text_pointer_text_only");
	tp_upgrades_holder:add_component_text("text", "ui_text_replacements_localised_text_dlc16_text_pointer_flesh_lab_upgrades");
	tp_upgrades_holder:set_style("semitransparent_2_sec_highlight");
	tp_upgrades_holder:set_panel_width(325);
	tp_upgrades_holder:set_close_button_callback(
		function()
			
			-- hide text pointer
			tp_upgrades_holder:hide();
			
			-- stop pulsing highlight of book icons
			pulse_uicomponent(uic_upgrades_holder, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();
			
			--end the tour
			flesh_lab_tour_lock_ui(false);
			
		end
	);
	cm:callback(
		function()
			tp_upgrades_holder:show();
		end,
		0.5
	);

end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Beastmen Panel Tour
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

in_beastmen_panel_tour = intervention:new(
	"in_beastmen_panel_tour",			 								-- string name
	0, 																	-- cost
	function() 															-- trigger callback
		--dismiss the advisor to get him out of the tour
		cm:dismiss_advice()
		trigger_beastmen_panel_scripted_tour() 
	end,					
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);

in_beastmen_panel_tour:add_advice_key_precondition("wh2.dlc17.camp.advice.bst.panel.001.open");

in_beastmen_panel_tour:set_wait_for_fullscreen_panel_dismissed(true);

in_beastmen_panel_tour:add_trigger_condition(
	"ScriptEventBeastmenCampaignStart",
	true
);


function beastmen_panel_tour_lock_ui(value)

	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()

	local uim = cm:get_campaign_ui_manager();

	value = not not value;

	CampaignUI.ClearSelection();
	
	local overrides_to_lock = {
		"selection_change",
		"stances",
		"radar_rollout_buttons",
		"recruit_units",
		"disband_unit",
		"diplomacy",
		"technology",
		"rituals",
		"finance",
		"tactical_map",
		"faction_button",
		"missions",
		"intrigue_at_the_court",
		"geomantic_web",
		"slaves",
		"skaven_corruption",
		"esc_menu",
		"help_panel_button",
		"spell_browser",
		"camera_settings",
		"end_turn_options",
		"mortuary_cult",
		"books_of_nagash",
		"regiments_of_renown",
		"sword_of_khaine"
	};
	
	if value then
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):lock();
		end;
	else
		for i = 1, #overrides_to_lock do
			uim:override(overrides_to_lock[i]):unlock();			
		end;
		-- lift fullscreen highlight
		core:hide_fullscreen_highlight();
		cm:dismiss_advice();
		in_beastmen_panel_tour:complete();
	end;
end;


function trigger_beastmen_panel_scripted_tour()
	
	if cm:get_campaign_ui_manager():is_panel_open("beastmen_panel") then
		local uic_panel = find_child_uicomponent(core:get_ui_root(), "beastmen_panel");
		if not uic_panel then
			script_error("ERROR: beastmen_panel_scripted_tour_open_panel() could not find the beastmen panel, how can this be?");
			beastmen_panel_tour_lock_ui(false);
			return false;
		end;
		beastmen_panel_scripted_tour_tabs_advice(uic_panel)

	else

		local uic_beastmen_panel_button = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_group_management", "button_beastmen_panel");
		if not uic_beastmen_panel_button then
			script_error("ERROR: trigger_beastmen_panel_scripted_tour() could not find the beastmen panel button, how can this be?");
			return false;
		end;
		
		-- lock ui
		beastmen_panel_tour_lock_ui(true);
		
		-- show fullscreen highlight around the beastmen panel button
		core:show_fullscreen_highlight_around_components(25, false, uic_beastmen_panel_button);
		
		-- pulse the button
		pulse_uicomponent(uic_beastmen_panel_button, true, 5);
		
		-- set up button text pointer
		local uic_beastmen_panel_button_size_x, uic_beastmen_panel_button_size_y = uic_beastmen_panel_button:Dimensions();
		local uic_beastmen_panel_button_pos_x, uic_beastmen_panel_button_pos_y = uic_beastmen_panel_button:Position();
		
		local tp_beastmen_panel_button = text_pointer:new("beastmen_panel_button", uic_beastmen_panel_button_pos_x + uic_beastmen_panel_button_size_x / 5, uic_beastmen_panel_button_pos_y + (uic_beastmen_panel_button_size_y / 2), 100, "right");
		tp_beastmen_panel_button:set_layout("text_pointer_text_only");
		tp_beastmen_panel_button:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_button");
		tp_beastmen_panel_button:set_style("semitransparent_2_sec_highlight");
		tp_beastmen_panel_button:set_panel_width(300);
		
		tp_beastmen_panel_button:set_close_button_callback(
			function()
				-- hide text pointer
				tp_beastmen_panel_button:hide();

				-- stop pulsing button
				pulse_uicomponent(uic_beastmen_panel_button, false, 5);

				beastmen_panel_scripted_tour_open_panel(uic_beastmen_panel_button)
			end
		);
		
		cm:callback(
			function()
				tp_beastmen_panel_button:show();
			end,
			0.5
		);
	end

end;

function beastmen_panel_scripted_tour_open_panel(uic_beastmen_panel_button)
	
	local event_name = "beastmen_panel_scripted_tour";		
				
	-- lift fullscreen highlight
	core:hide_fullscreen_highlight();

	-- establish listener for the beastmen panel opening						
	core:add_listener(
		event_name,
		"PanelOpenedCampaign",
		function(context)
			return context.string == "beastmen_panel"
		end,
		function(context)
			out("%%%%% Beastmen panel opened");
		
			cm:remove_callback(event_name);
			
			local uic_panel = find_uicomponent(core:get_ui_root(), "beastmen_panel");
			if not uic_panel then
				script_error("ERROR: beastmen_panel_scripted_tour_open_panel() could not find the beastmen panel, how can this be?");
				beastmen_panel_tour_lock_ui(false);
				return false;
			end;
			
			-- wait for the panel to finish animating
			core:progress_on_uicomponent_animation(
				event_name, 
				uic_panel, 
				function()	
					beastmen_panel_scripted_tour_tabs_advice(uic_panel)
				end
			);
		end,
		false
	);
	-- failsafe: panel hasn't opened for some reason, exit
	cm:callback(
		function()
			script_error("WARNING: beastmen_panel_scripted_tour_open_panel() attempted to open the beastmen panel but it didn't open, exiting");
			core:remove_listener(event_name);
			beastmen_panel_tour_lock_ui(false);
			return false;
		end,
		0.5,
		event_name
	);						
	
	-- simulate click on beastmen button to open the beastmen panel
	uic_beastmen_panel_button:SimulateLClick();

end

function beastmen_panel_scripted_tour_tabs_advice(uic_panel)
	
	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	cm:show_advice("wh2.dlc17.camp.advice.bst.panel.001.open");

	--uic_panel:StealShortcutKey(false);

	local uic_beastmen_panel_tabs = find_uicomponent(uic_panel, "tab_holder", "button_tab_holder");
	local uic_unit_caps_button = find_uicomponent(uic_beastmen_panel_tabs, "unit_caps");
	local uic_lords_and_heroes_button = find_uicomponent(uic_beastmen_panel_tabs, "lords_and_heroes");
	local uic_upgrades_button = find_uicomponent(uic_beastmen_panel_tabs, "upgrades");
	local uic_items_button = find_uicomponent(uic_beastmen_panel_tabs, "items");
	
	if not uic_beastmen_panel_tabs then
		script_error("WARNING: beastmen_panel_scripted_tour_tabs_advice() could not find the button_tab_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_unit_caps_button then
		script_error("WARNING: beastmen_panel_scripted_tour_tabs_advice() could not find the unit caps button uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_lords_and_heroes_button then
		script_error("WARNING: beastmen_panel_scripted_tour_tabs_advice() could not find the lords and heroes button uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_upgrades_button then
		script_error("WARNING: beastmen_panel_scripted_tour_tabs_advice() could not find the upgrades button uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_items_button then
		script_error("WARNING: beastmen_panel_scripted_tour_tabs_advice() could not find the items button uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the tabs
	core:show_fullscreen_highlight_around_components(25, false, uic_beastmen_panel_tabs);
	
	-- pulse each of the augment tabs
	pulse_uicomponent(uic_unit_caps_button, true, 5, true);
	pulse_uicomponent(uic_lords_and_heroes_button, true, 5, true);
	pulse_uicomponent(uic_upgrades_button, true, 5, true);
	pulse_uicomponent(uic_items_button, true, 5, true);
	
	-- set up text pointer
	local uic_beastmen_panel_tabs_size_x, uic_beastmen_panel_tabs_size_y = uic_beastmen_panel_tabs:Dimensions();
	local uic_beastmen_panel_tabs_pos_x, uic_beastmen_panel_tabs_pos_y = uic_beastmen_panel_tabs:Position();
	
	local tp_beastmen_panel_tabs = text_pointer:new("beastmen_panel_tabs", uic_beastmen_panel_tabs_pos_x + (uic_beastmen_panel_tabs_size_x/2), uic_beastmen_panel_tabs_pos_y + (uic_beastmen_panel_tabs_size_y/3), 100, "top");
	tp_beastmen_panel_tabs:set_layout("text_pointer_text_only");
	tp_beastmen_panel_tabs:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_tabs");
	tp_beastmen_panel_tabs:set_style("semitransparent_2_sec_highlight");
	tp_beastmen_panel_tabs:set_panel_width(300);
	
	tp_beastmen_panel_tabs:set_close_button_callback(
		function()
			-- hide text pointer
			tp_beastmen_panel_tabs:hide();

			-- stop pulsing highlight of augment tabs
			pulse_uicomponent(uic_unit_caps_button, false, 5, true);
			pulse_uicomponent(uic_lords_and_heroes_button, false, 5, true);
			pulse_uicomponent(uic_upgrades_button, false, 5, true);
			pulse_uicomponent(uic_items_button, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();
		
			beastmen_panel_scripted_tour_unit_cap_advice(uic_panel)
		
		end
	);

	cm:callback(
		function()
			tp_beastmen_panel_tabs:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_unit_cap_advice(uic_panel)
	
	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()
	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	cm:show_advice("wh2.dlc17.camp.advice.bst.panel.002.units")

	local uic_unit_caps_holder = find_uicomponent(uic_panel, "mid_colum", "unit_caps",  "content_holder");

	if not uic_unit_caps_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_unit_caps_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;
	local faction_cqi = cm:get_local_faction(true):command_queue_index();
	local uic_string = "CcoCampaignRitual" .. tostring(faction_cqi) .."wh2_dlc17_bst_ritual_unit_cap_ungor_herd_spearmen_herd"
	local uic_ungor_unit_cap = find_uicomponent(uic_unit_caps_holder, uic_string);

	if not uic_ungor_unit_cap then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_ungor_unit_cap uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over uic_ungor_unit_cap
	core:show_fullscreen_highlight_around_components(25, false, uic_ungor_unit_cap);
	
	-- pulse uic_ungor_unit_cap
	pulse_uicomponent(uic_ungor_unit_cap, true, 5, true);
	
	-- set up text pointer
	local uic_unit_caps_holder_size_x, uic_unit_caps_holder_size_y = uic_unit_caps_holder:Dimensions();
	local uic_unit_caps_holder_pos_x, uic_unit_caps_holder_pos_y = uic_unit_caps_holder:Position();
	
	local tp_unit_caps_holder = text_pointer:new("unit_caps_holder", uic_unit_caps_holder_pos_x + (uic_unit_caps_holder_size_x/5), uic_unit_caps_holder_pos_y + (uic_unit_caps_holder_size_y/5), 125, "left");
	tp_unit_caps_holder:set_layout("text_pointer_text_only");
	tp_unit_caps_holder:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_unit_caps_holder");
	tp_unit_caps_holder:set_style("semitransparent_2_sec_highlight");
	tp_unit_caps_holder:set_panel_width(350);

	tp_unit_caps_holder:set_close_button_callback(
		function()
			-- hide text pointer
			tp_unit_caps_holder:hide();
			
			-- stop pulsing the ungor unit group
			pulse_uicomponent(uic_ungor_unit_cap, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();

			beastmen_panel_scripted_tour_unit_caps_dread_advice(uic_panel, uic_unit_caps_holder, uic_ungor_unit_cap)
		end
	);	
	
	cm:callback(
		function()
			tp_unit_caps_holder:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_unit_caps_dread_advice(uic_panel, uic_unit_caps_holder, uic_ungor_unit_cap)

	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice();

	local uic_unit_caps_button = find_uicomponent(uic_ungor_unit_cap, "cost_and_button_holder");

	if not uic_unit_caps_button then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_caps_dread_advice() could not find the cost_and_button_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(15, false, uic_unit_caps_button);
	
	-- pulse the augment effects holder
	pulse_uicomponent(uic_unit_caps_button, true, 5, true);
	
	-- set up text pointer
	local uic_unit_caps_button_size_x, uic_unit_caps_button_size_y = uic_unit_caps_button:Dimensions();
	local uic_unit_caps_button_pos_x, uic_unit_caps_button_pos_y = uic_unit_caps_button:Position();
	
	local tp_unit_caps_button = text_pointer:new("unit_caps_button", uic_unit_caps_button_pos_x + (uic_unit_caps_button_size_x/2), uic_unit_caps_button_pos_y + uic_unit_caps_button_size_y, 100, "top");
	tp_unit_caps_button:set_layout("text_pointer_text_only");
	tp_unit_caps_button:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_unit_caps_dread");
	tp_unit_caps_button:set_style("semitransparent_2_sec_highlight");
	tp_unit_caps_button:set_panel_width(350);

	tp_unit_caps_button:set_close_button_callback(
		function()
			-- hide text pointer
			tp_unit_caps_button:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_unit_caps_button, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_unit_caps_marks_advice(uic_panel, uic_unit_caps_holder)
		end
	);

	cm:callback(
		function()
			tp_unit_caps_button:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_unit_caps_marks_advice(uic_panel, uic_unit_caps_holder)

	local faction_cqi = cm:get_local_faction(true):command_queue_index();
	local uic_string = "CcoCampaignRitual" .. tostring(faction_cqi) .."wh2_dlc17_bst_ritual_unit_cap_bestigor_herd"
	local uic_bestigor_unit_cap = find_uicomponent(uic_unit_caps_holder, uic_string);

	if not uic_bestigor_unit_cap then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_bestigor_unit_cap uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	local uic_bestigor_marks = find_uicomponent(uic_bestigor_unit_cap, "locked_requirement");

	if not uic_bestigor_marks then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_bestigor_marks uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;
	
	-- show fullscreen highlight over the map
	core:show_fullscreen_highlight_around_components(25, false, uic_bestigor_unit_cap);
	
	-- pulse the augment effects holder
	pulse_uicomponent(uic_bestigor_marks, true, 5, true);
	
	-- set up text pointer
	local uic_bestigor_marks_size_x, uic_bestigor_marks_size_y = uic_bestigor_marks:Dimensions();
	local uic_bestigor_marks_pos_x, uic_bestigor_marks_pos_y = uic_bestigor_marks:Position();
	
	local tp_bestigor_marks = text_pointer:new("bestigor_marks", uic_bestigor_marks_pos_x, uic_bestigor_marks_pos_y + (uic_bestigor_marks_size_y / 2), 50, "right");
	tp_bestigor_marks:set_layout("text_pointer_text_only");
	tp_bestigor_marks:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_unit_caps_marks");
	tp_bestigor_marks:set_style("semitransparent_2_sec_highlight");
	tp_bestigor_marks:set_panel_width(350);

	tp_bestigor_marks:set_close_button_callback(
		function()
			-- hide text pointer
			tp_bestigor_marks:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_bestigor_marks, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_unit_caps_pooled_resources_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_bestigor_marks:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_unit_caps_pooled_resources_advice(uic_panel)

	local uic_marks_holder = find_uicomponent(uic_panel, "header_parent", "marks_of_ruination_holder");
	local uic_treasury_holder = find_uicomponent(uic_panel, "header_parent", "dy_treasury");
	local uic_dread_holder = find_uicomponent(uic_panel, "header_parent", "dy_dread");

	if not uic_marks_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_marks_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_treasury_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_treasury_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	if not uic_dread_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_dread_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(25, false, uic_marks_holder, uic_treasury_holder, uic_dread_holder);
	
	-- pulse the holders
	pulse_uicomponent(uic_marks_holder, true, 5, true);
	pulse_uicomponent(uic_treasury_holder, true, 5, true);
	pulse_uicomponent(uic_dread_holder, true, 5, true);
	
	-- set up text pointer
	local uic_marks_holder_size_x, uic_marks_holder_size_y = uic_marks_holder:Dimensions();
	local uic_marks_holder_pos_x, uic_marks_holder_pos_y = uic_marks_holder:Position();
	
	local tp_marks_holder = text_pointer:new("marks_holder", uic_marks_holder_pos_x + (uic_marks_holder_size_x/2), uic_marks_holder_pos_y + uic_marks_holder_size_y, 100, "top");
	tp_marks_holder:set_layout("text_pointer_text_only");
	tp_marks_holder:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_pooled_resources");
	tp_marks_holder:set_style("semitransparent_2_sec_highlight");
	tp_marks_holder:set_panel_width(350);

	tp_marks_holder:set_close_button_callback(
		function()
			-- hide text pointer
			tp_marks_holder:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_marks_holder, false, 5, true);
			pulse_uicomponent(uic_treasury_holder, false, 5, true);
			pulse_uicomponent(uic_dread_holder, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_lords_and_heroes_tab_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_marks_holder:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_lords_and_heroes_tab_advice(uic_panel)

	local event_name = "beastmen_panel_scripted_tour";
	local uic_lords_and_heroes_tab = find_uicomponent(uic_panel, "tab_holder", "button_tab_holder", "lords_and_heroes");

	if not uic_lords_and_heroes_tab then
		script_error("WARNING: beastmen_panel_scripted_tour_unit_cap_advice() could not find the uic_lords_and_heroes_tab uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the button
	core:show_fullscreen_highlight_around_components(25, false, uic_lords_and_heroes_tab);
	
	-- pulse the holders
	pulse_uicomponent(uic_lords_and_heroes_tab, true, 5, true);
	
	-- set up text pointer
	local uic_lords_and_heroes_tab_size_x, uic_lords_and_heroes_tab_size_y = uic_lords_and_heroes_tab:Dimensions();
	local uic_lords_and_heroes_tab_pos_x, uic_lords_and_heroes_tab_pos_y = uic_lords_and_heroes_tab:Position();
	
	local tp_lords_and_heroes_tab = text_pointer:new("lords_and_heroes_tab", uic_lords_and_heroes_tab_pos_x + (uic_lords_and_heroes_tab_size_x/2), uic_lords_and_heroes_tab_pos_y + (uic_lords_and_heroes_tab_size_y / 2), 50, "top");
	tp_lords_and_heroes_tab:set_layout("text_pointer_text_only");
	tp_lords_and_heroes_tab:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_lords_and_heroes_tab");
	tp_lords_and_heroes_tab:set_style("semitransparent_2_sec_highlight");
	tp_lords_and_heroes_tab:set_panel_width(350);

	tp_lords_and_heroes_tab:set_close_button_callback(
		function()	

			-- stop pulsing highlight of the lords and heroes holder
			pulse_uicomponent(uic_lords_and_heroes_tab, false, 5, true);

			-- establish listener for the Lords and Heroes tab opening						
			core:add_listener(
				event_name,
				"ComponentLClickUp", 
				function(context) 
					return UIComponent(context.component) == uic_lords_and_heroes_tab;
				end, 
				function(context)
					out("%%%%% Lords and Heroes tab opened");
				
					cm:remove_callback(event_name);

					-- wait for the panel to finish animating
					core:progress_on_uicomponent_animation(
						event_name, 
						uic_lords_and_heroes_tab, 
						function()
							-- hide text pointer
							tp_lords_and_heroes_tab:hide();
							
							-- lift fullscreen highlight
							core:hide_fullscreen_highlight();

							beastmen_panel_scripted_tour_legendary_lords_advice(uic_panel)
						end
					);
				end, 
				false
			);
			-- failsafe: tab hasn't opened for some reason, exit
			cm:callback(
				function()
					script_error("WARNING: beastmen_panel_scripted_tour_lords_and_heroes_tab_advice() attempted to open Lords and Heroes tab but it didn't open, exiting");
					core:remove_listener(event_name);
					beastmen_panel_tour_lock_ui(false);
					return false;
				end,
				0.5,
				event_name
			);						
			
			-- simulate click on lords and heroes tab to open it in the beastmen panel
			uic_lords_and_heroes_tab:SimulateLClick();	
							
		end
	);
	cm:callback(
		function()
			tp_lords_and_heroes_tab:show();
		end,
		0.5
	);
end

function beastmen_panel_scripted_tour_legendary_lords_advice(uic_panel)

	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);	
	cm:show_advice("wh2.dlc17.camp.advice.bst.panel.003.lords")

	local uic_lords_holder = find_uicomponent(uic_panel, "lords_and_heroes", "lords_list");

	if not uic_lords_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_legendary_lords_advice() could not find the uic_lords_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(25, false, uic_lords_holder);
	
	-- pulse the holders
	pulse_uicomponent(uic_lords_holder, true, 5, true);
	
	-- set up text pointer
	local uic_lords_holder_size_x, uic_lords_holder_size_y = uic_lords_holder:Dimensions();
	local uic_lords_holder_pos_x, uic_lords_holder_pos_y = uic_lords_holder:Position();
	
	local tp_lords_holder = text_pointer:new("lords_holder", uic_lords_holder_pos_x + uic_lords_holder_size_x, uic_lords_holder_pos_y + (uic_lords_holder_size_y / 2), 50, "left");
	tp_lords_holder:set_layout("text_pointer_text_only");
	tp_lords_holder:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_lords");
	tp_lords_holder:set_style("semitransparent_2_sec_highlight");
	tp_lords_holder:set_panel_width(350);

	tp_lords_holder:set_close_button_callback(
		function()
			-- hide text pointer
			tp_lords_holder:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_lords_holder, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_heroes_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_lords_holder:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_heroes_advice(uic_panel)

	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()

	local uic_hero_holder = find_uicomponent(uic_panel, "lords_and_heroes", "character_list_parent");

	if not uic_hero_holder then
		script_error("WARNING: beastmen_panel_scripted_tour_heroes_advice() could not find the uic_hero_holder uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(25, false, uic_hero_holder);
	
	-- pulse the holders
	pulse_uicomponent(uic_hero_holder, true, 5, true);
	
	-- set up text pointer
	local uic_hero_holder_size_x, uic_hero_holder_size_y = uic_hero_holder:Dimensions();
	local uic_hero_holder_pos_x, uic_hero_holder_pos_y = uic_hero_holder:Position();
	
	local tp_hero_holder = text_pointer:new("hero_holder", uic_hero_holder_pos_x, uic_hero_holder_pos_y + (uic_hero_holder_size_y / 2), 50, "right");
	tp_hero_holder:set_layout("text_pointer_text_only");
	tp_hero_holder:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_heroes");
	tp_hero_holder:set_style("semitransparent_2_sec_highlight");
	tp_hero_holder:set_panel_width(350);

	tp_hero_holder:set_close_button_callback(
		function()
			-- hide text pointer
			tp_hero_holder:hide();
			
			-- stop pulsing highlight of the augment effects holder
			pulse_uicomponent(uic_hero_holder, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_upgrades_tab_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_hero_holder:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_upgrades_tab_advice(uic_panel)

	local event_name = "beastmen_panel_scripted_tour";
	local uic_upgrades_tab = find_uicomponent(uic_panel, "tab_holder", "button_tab_holder", "upgrades");

	if not uic_upgrades_tab then
		script_error("WARNING: beastmen_panel_scripted_tour_upgrades_tab_advice() could not find the uic_upgrades_tab uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the button
	core:show_fullscreen_highlight_around_components(25, false, uic_upgrades_tab);
	
	-- pulse the holders
	pulse_uicomponent(uic_upgrades_tab, true, 5, true);
	
	-- set up text pointer
	local uic_upgrades_tab_size_x, uic_upgrades_tab_size_y = uic_upgrades_tab:Dimensions();
	local uic_upgrades_tab_pos_x, uic_upgrades_tab_pos_y = uic_upgrades_tab:Position();
	
	local tp_upgrades_tab = text_pointer:new("upgrades_tab", uic_upgrades_tab_pos_x + (uic_upgrades_tab_size_x/2), uic_upgrades_tab_pos_y + (uic_upgrades_tab_size_y / 2), 50, "top");
	tp_upgrades_tab:set_layout("text_pointer_text_only");
	tp_upgrades_tab:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_upgrades_tab");
	tp_upgrades_tab:set_style("semitransparent_2_sec_highlight");
	tp_upgrades_tab:set_panel_width(350);

	tp_upgrades_tab:set_close_button_callback(
		function()	

			-- stop pulsing highlight of the units holder
			pulse_uicomponent(uic_upgrades_tab, false, 5, true);

			-- establish listener for the flesh lab panel opening						
			core:add_listener(
				event_name,
				"ComponentLClickUp", 
				function(context) 
					return UIComponent(context.component) == uic_upgrades_tab;
				end, 
				function(context)
					out("%%%%% Upgrades tab opened");
				
					cm:remove_callback(event_name);

					-- wait for the panel to finish animating
					core:progress_on_uicomponent_animation(
						event_name, 
						uic_upgrades_tab, 
						function()
							-- hide text pointer
							tp_upgrades_tab:hide();
													
							-- lift fullscreen highlight
							core:hide_fullscreen_highlight();

							beastmen_panel_scripted_tour_herdstone_upgrades_advice(uic_panel)
						end
					);
				end, 
				false
			);
			-- failsafe: tab hasn't opened for some reason, exit
			cm:callback(
				function()
					script_error("WARNING: beastmen_panel_scripted_tour_upgrades_tab_advice() attempted to open Upgrades tab but it didn't open, exiting");
					core:remove_listener(event_name);
					beastmen_panel_tour_lock_ui(false);
					return false;
				end,
				0.5,
				event_name
			);						
			
			-- simulate click on lords and heroes tab to open it in the beastmen panel
			uic_upgrades_tab:SimulateLClick();							
				
		end
	);
	cm:callback(
		function()
			tp_upgrades_tab:show();
		end,
		0.5
	);
end

function beastmen_panel_scripted_tour_herdstone_upgrades_advice(uic_panel)

	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);	
	cm:show_advice("wh2.dlc17.camp.advice.bst.panel.005.upgrades")

	local uic_herdstone = find_uicomponent(uic_panel, "herdstone_upgrades_content_holder", "herdtsone_upgrades_list");

	if not uic_herdstone then
		script_error("WARNING: beastmen_panel_scripted_tour_herdstone_upgrades_advice() could not find the uic_herdstone uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(25, false, uic_herdstone);
	
	-- pulse the holders
	pulse_uicomponent(uic_herdstone, true, 5, true);
	
	-- set up text pointer
	local uic_herdstone_size_x, uic_herdstone_size_y = uic_herdstone:Dimensions();
	local uic_herdstone_pos_x, uic_herdstone_pos_y = uic_herdstone:Position();
	
	local tp_herdstone = text_pointer:new("herdstone", uic_herdstone_pos_x + uic_herdstone_size_x, uic_herdstone_pos_y + (uic_herdstone_size_y / 2), 50, "left");
	tp_herdstone:set_layout("text_pointer_text_only");
	tp_herdstone:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_herdstone_upgrades");
	tp_herdstone:set_style("semitransparent_2_sec_highlight");
	tp_herdstone:set_panel_width(350);

	tp_herdstone:set_close_button_callback(
		function()
			-- hide text pointer
			tp_herdstone:hide();
			
			-- stop pulsing highlight of the herdstone holder
			pulse_uicomponent(uic_herdstone, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_faction_upgrades_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_herdstone:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_faction_upgrades_advice(uic_panel)

	--dismiss the advisor to get him out of the tour
	cm:dismiss_advice()

	local uic_faction_upgrades = find_uicomponent(uic_panel, "faction_upgrades_content_holder", "herdtsone_upgrades_list");

	if not uic_faction_upgrades then
		script_error("WARNING: beastmen_panel_scripted_tour_herdstone_upgrades_advice() could not find the uic_faction_upgrades uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(75, false, uic_faction_upgrades);
	
	-- pulse the holders
	pulse_uicomponent(uic_faction_upgrades, true, 5, true);
	
	-- set up text pointer
	local uic_faction_upgrades_size_x, uic_faction_upgrades_size_y = uic_faction_upgrades:Dimensions();
	local uic_faction_upgrades_pos_x, uic_faction_upgrades_pos_y = uic_faction_upgrades:Position();
	
	local tp_faction_upgrades = text_pointer:new("faction_upgrades", uic_faction_upgrades_pos_x, uic_faction_upgrades_pos_y + (uic_faction_upgrades_size_y / 2), 50, "right");
	tp_faction_upgrades:set_layout("text_pointer_text_only");
	tp_faction_upgrades:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_faction_upgrades");
	tp_faction_upgrades:set_style("semitransparent_2_sec_highlight");
	tp_faction_upgrades:set_panel_width(350);

	tp_faction_upgrades:set_close_button_callback(
		function()
			-- hide text pointer
			tp_faction_upgrades:hide();
			
			-- stop pulsing highlight of the herdstone holder
			pulse_uicomponent(uic_faction_upgrades, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			beastmen_panel_scripted_tour_items_tab_advice(uic_panel)
		end
	);

	cm:callback(
		function()
			tp_faction_upgrades:show();
		end,
		0.5
	);

end

function beastmen_panel_scripted_tour_items_tab_advice(uic_panel)

	local event_name = "beastmen_panel_scripted_tour";
	local uic_items_tabs = find_uicomponent(uic_panel, "tab_holder", "button_tab_holder", "items");

	if not uic_items_tabs then
		script_error("WARNING: beastmen_panel_scripted_tour_items_tab_advice() could not find the uic_items_tabs uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the button
	core:show_fullscreen_highlight_around_components(25, false, uic_items_tabs);
	
	-- pulse the holders
	pulse_uicomponent(uic_items_tabs, true, 5, true);
	
	-- set up text pointer
	local uic_items_tabs_size_x, uic_items_tabs_size_y = uic_items_tabs:Dimensions();
	local uic_items_tabs_pos_x, uic_items_tabs_pos_y = uic_items_tabs:Position();
	
	local tp_items_tab = text_pointer:new("items_tab", uic_items_tabs_pos_x + (uic_items_tabs_size_x/2), uic_items_tabs_pos_y + (uic_items_tabs_size_y / 2), 50, "top");
	tp_items_tab:set_layout("text_pointer_text_only");
	tp_items_tab:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_items_tab");
	tp_items_tab:set_style("semitransparent_2_sec_highlight");
	tp_items_tab:set_panel_width(350);

	tp_items_tab:set_close_button_callback(
		function()	

			-- stop pulsing highlight of the units holder
			pulse_uicomponent(uic_items_tabs, false, 5, true);

			-- establish listener for the flesh lab panel opening						
			core:add_listener(
				event_name,
				"ComponentLClickUp", 
				function(context) 
					return UIComponent(context.component) == find_uicomponent(uic_items_tabs);
				end, 
				function(context)
					out("%%%%% Items tab opened");
				
					cm:remove_callback(event_name);

					-- wait for the panel to finish animating
					core:progress_on_uicomponent_animation(
						event_name, 
						uic_items_tabs, 
						function()
							-- hide text pointer
							tp_items_tab:hide();
														
							-- lift fullscreen highlight
							core:hide_fullscreen_highlight();

							beastmen_panel_scripted_tour_items_advice(uic_panel)
						end
					);
				end, 
				false
			);
			-- failsafe: tab hasn't opened for some reason, exit
			cm:callback(
				function()
					script_error("WARNING: beastmen_panel_scripted_tour_items_tab_advice() attempted to open Iems tab but it didn't open, exiting");
					core:remove_listener(event_name);
					beastmen_panel_tour_lock_ui(false);
					return false;
				end,
				0.5,
				event_name
			);						
			
			-- simulate click on lords and heroes tab to open it in the beastmen panel
			uic_items_tabs:SimulateLClick();							
				
		end
	);
	cm:callback(
		function()
			tp_items_tab:show();
		end,
		0.5
	);
end

function beastmen_panel_scripted_tour_items_advice(uic_panel)

	-- Move advice topmost
	core:cache_and_set_advisor_priority(1500, true);
	
	cm:show_advice("wh2.dlc17.camp.advice.bst.panel.004.items")

	local uic_items = find_uicomponent(uic_panel, "mid_colum", "tab_contents", "item_central_docker", "items");

	if not uic_items then
		script_error("WARNING: beastmen_panel_scripted_tour_herdstone_upgrades_advice() could not find the uic_items uicomponent in the beastmen panel, how can this be?");
		beastmen_panel_tour_lock_ui(false);
		return false;
	end;

	-- show fullscreen highlight over the holders
	core:show_fullscreen_highlight_around_components(25, false, uic_items);
	
	-- pulse the holders
	pulse_uicomponent(uic_items, true, 5, true);
	
	-- set up text pointer
	local uic_items_size_x, uic_items_size_y = uic_items:Dimensions();
	local uic_items_pos_x, uic_items_pos_y = uic_items:Position();
	
	local tp_items = text_pointer:new("items", uic_items_pos_x + (uic_items_size_x/2), uic_items_pos_y + 49*(uic_items_size_y/50), 25, "top");
	tp_items:set_layout("text_pointer_text_only");
	tp_items:add_component_text("text", "ui_text_replacements_localised_text_dlc17_text_pointer_beastmen_panel_items");
	tp_items:set_style("semitransparent_2_sec_highlight");
	tp_items:set_panel_width(800);

	tp_items:set_close_button_callback(
		function()
			-- hide text pointer
			tp_items:hide();
			
			-- stop pulsing highlight of the herdstone holder
			pulse_uicomponent(uic_items, false, 5, true);
			
			-- lift fullscreen highlight
			core:hide_fullscreen_highlight();	
			
			--end the tour
			beastmen_panel_tour_lock_ui(false);
		end
	);

	cm:callback(
		function()
			tp_items:show();
		end,
		0.5
	);

end