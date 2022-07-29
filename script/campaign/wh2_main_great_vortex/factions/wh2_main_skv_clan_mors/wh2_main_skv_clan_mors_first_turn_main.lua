


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FIRST TURN MAIN SCRIPT
--
--	Script for second section of intro first-turn - after intro battle
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


bool_skip_to_end_battle = core:is_tweaker_set("SKIP_SCRIPTED_CONTENT_1");
bool_skip_to_settlement_selection = core:is_tweaker_set("SKIP_SCRIPTED_CONTENT_2");



if cm:get_saved_value("bool_first_turn_main_end_reached") then
	-- this is not a new game, so the player must have saved and is reloading
	-- direct the script towards the end-turn section
	
	cm:add_first_tick_callback_sp_each(
		function() 
			-- put faction-specific calls that should get triggered each time a singleplayer game loads here
			skip_to_end_turn_advice();
		end
	);
	
else
	-- This is our first time through this script - customise the player's lord
	-- add units that were granted during the first battle
	
	local player_char = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	
	if not player_char then
		script_error("ERROR: first turn main script could not find player's legendary lord with cqi [" .. player_legendary_lord_char_cqi .. "]");
		return false;
	end;
	
	local player_char_str = cm:char_lookup_str(player_char);
	
	-- debug only - reconstitute the player's army
	if core:is_tweaker_set("FORCE_CAMPAIGN_PRELUDE_TO_SECOND_PART") then
		-- remove all units from the player's starting army
		cm:remove_all_units_from_general(player_char);
		
		-- add customised unit setup
		cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
		cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
		cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_clanrat_spearmen_1");
		
		-- setup second enemy force
		setup_second_enemy_force();
		
		-- teleport player's army
		cm:teleport_to(player_char_str, initial_enemy_force_x, initial_enemy_force_y, false);
	end;
	
	-- award the player some experience
	cm:add_experience_to_units_commanded_by_character(player_char_str, 1);
	
	-- grant some of the extra units that appeared in battle
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_skavenslave_slingers_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_inf_skavenslave_slingers_0");
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_mon_rat_ogres");
	cm:grant_unit_to_character(player_char_str, "wh2_main_skv_mon_rat_ogres");
	
	cm:add_first_tick_callback_sp_each(
		function() 
			-- put faction-specific calls that should get triggered each time a singleplayer game loads here
			start_first_turn_main_from_battle();
		end
	);
end;





---------------------------------------------------------------
--	Intro Cutscene (debug only)
---------------------------------------------------------------

function cutscene_intro_play()			-- called from <faction_name>_start.lua
	out("cutscene_intro_play() called - first turn MAIN");
	
	-- disable ui
	cm:get_campaign_ui_manager():display_first_turn_ui(false);
	
	script_error("cutscene_intro_play() called in first turn main script - this should only happen if skipping the intro battle with debug commands");
	
	cm:set_camera_position(352.2, 61.1, 5.6, 0.0, 4.0);
	
	cm:scroll_camera_with_cutscene(
		9,
		function()
			CampaignUI.ToggleCinematicBorders(false);
		end,
		{352.2, 61.1, 16.7, 0, 14}
	);
	
	cm:callback(
		function()
			-- The Elves are scattered, Lord Queek! All of Skavendom shall chitter of your magnificence. It only remains to decide the fate of those captured in battle.
			cm:show_advice("wh2.camp.prelude.ft.101.skv", true);
			cm:progress_on_advice_dismissed(
				function() 
					if bool_skip_to_settlement_selection then
						start_settlement_advice();
					else
						start_movement_extents_advice();
					end;
				end, 
				1, 
				true
			);
		end,
		1
	);
end;




---------------------------------------------------------------
--	Starting from first battle
---------------------------------------------------------------

function start_first_turn_main_from_battle()

	-- disable ui
	cm:get_campaign_ui_manager():display_first_turn_ui(false);
	
	-- progress when the loading screen is hidden, and when the post-battle panel is visible
	core:progress_on_loading_screen_dismissed(
		function()	
			cm:progress_on_post_battle_panel_visible(
				function()
					play_intro_post_battle_advice();
				end	
			);
		end
	);
end;


function play_intro_post_battle_advice()

	local dismiss_button_highlighted = false;
	local panel_closed = false;

	cm:callback(
		function()
			-- The Elves are scattered, Lord Queek! All of Skavendom shall chitter of your magnificence. It only remains to decide the fate of those captured in battle.
			cm:show_advice("wh2.camp.prelude.ft.101.skv");
			cm:add_infotext(
				1,
				"war.camp.advice.post_battle_options.info_001",
				"war.camp.advice.post_battle_options.info_002"
			);
			
			-- highlight battle results dismiss button
			cm:get_campaign_ui_manager():highlight_post_battle_options_for_click(true);
		end,
		1
	);
	
	-- listen for post battle panel being closed
	core:add_listener(
		"post_battle_panel_close_listener",
		"ScriptEventPostBattlePanelClosed",
		true,
		function()
			panel_closed = true;
			
			cm:get_campaign_ui_manager():highlight_post_battle_options_for_click(false);
			
			cm:callback(function() start_movement_extents_advice() end, 1); 
		end,
		false
	);
end;







---------------------------------------------------------------
--	Movement Extents advice
---------------------------------------------------------------

function start_movement_extents_advice()

	local sa = intro_campaign_select_advice:new(
		player_legendary_lord_char_cqi,
		-- Your forces are weary from battle, yet they still retain some strength to march on. See for yourself.
		"wh2.camp.prelude.ft.110",
		"wh2.camp.army_selection_advice.001",
		function() movement_extents_advice_army_selected() end
	);
	
	sa:add_infotext(
		1,
		"wh2.camp.intro.info_040",
		"wh2.camp.intro.info_041"
	);
	sa:set_highlight_altitude(2);
	
	sa:start();
end;


function movement_extents_advice_army_selected()

	-- get a handle on the player's lord
	local player_char = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	
	local uim = cm:get_campaign_ui_manager();
	
	-- prevent the player from deselecting
	uim:override("selection_change"):lock();
	
	-- allow the player's army to move (shows a yellow extent), but prevent orders from being issued
	cm:enable_movement_for_character(cm:char_lookup_str(player_legendary_lord_char_cqi));
	uim:override("giving_orders"):lock();
	
	-- set up text pointer
	local tp_movement_extents = text_pointer:new("movement_extents", player_char:display_position_x() + 4.5, player_char:display_position_y() + 0.5, 50, "worldspace");
	tp_movement_extents:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_movement_extents");
	tp_movement_extents:set_style("semitransparent_worldspace");
	
	cm:callback(
		function()
			-- The distance your army can still move is shown around it, my Lord. Plan your manoeuvres wisely: your armies cannot defend your realm if they are not present to fight!
			cm:show_advice("wh2.camp.prelude.ft.120", true);
			
			-- flash movement extents
			cm:highlight_movement_extents(true);
			
			-- show text pointer
			cm:callback(function() tp_movement_extents:show() end, 0.5);
		end,
		0.5
	);
	
	cm:progress_on_advice_dismissed(
		function()
			-- hide text pointer
			tp_movement_extents:hide();
			
			-- stop flashing movement extents
			cm:highlight_movement_extents(false);
			
			start_movement_advice();
		end, 
		0, 
		true
	);
end;




---------------------------------------------------------------
--	Move army advice
---------------------------------------------------------------

first_turn_main_movement_destination_x = 533;
first_turn_main_movement_destination_y = 79;

function start_movement_advice()
	
	local ma = intro_campaign_movement_advice:new(
		player_legendary_lord_char_cqi,
		-- Be warned that while the Elves are defeated, they are not destroyed, and may seek to attack again. Move now towards your city, my Lord.
		"wh2.camp.prelude.ft.130.skv",
		"wh2.camp.army_selection_advice.001",
		"wh2.camp.movement_advice.004",					-- Move your army to defend the approach to Yuatek.
		first_turn_main_movement_destination_x,
		first_turn_main_movement_destination_y,
		function() 
			if bool_skip_to_end_battle then
				start_end_turn_advice();
			else
				start_zoc_advice();
			end
		end
	);
	
	ma:add_infotext(
		1,
		"wh2.camp.intro.info_042"
	);
		
	ma:start();
end;





---------------------------------------------------------------
--	ZOC advice
---------------------------------------------------------------

function start_zoc_advice()

	-- get a handle on the player's lord
	local player_char = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	
	-- set up text pointer
	local tp_zocs = text_pointer:new("zocs", player_char:display_position_x() - 2.5, player_char:display_position_y() + 2.5, 50, "worldspace");
	tp_zocs:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_campaign_zones_of_control");
	tp_zocs:set_style("semitransparent_worldspace");
	
	-- Good! Your army now blocks the approach to your capital. Any attack by the enemy will need to get by you first. See for yourself how your forces control the area around them.
	cm:show_advice("wh2.camp.prelude.ft.140", true);
	cm:clear_infotext();
	cm:add_infotext(
		1,
		"wh2.camp.intro.info_050",
		"wh2.camp.intro.info_051",
		"wh2.camp.intro.info_052"
	);
	
	-- flash ZOC
	cm:highlight_selected_character_zoc(true);
	
	-- label ZOC
	cm:callback(function() tp_zocs:show() end, 0.5);
	
	cm:progress_on_advice_dismissed(
		function()
			-- stop flashing ZOC
			cm:highlight_selected_character_zoc(false);
			
			tp_zocs:hide();
			
			-- allow the player to change selection again
			cm:get_campaign_ui_manager():override("selection_change"):unlock();
			
			start_recruitment_advice();
		end, 
		1, 
		true
	);
end;






---------------------------------------------------------------
--	Unit Recruitment advice
---------------------------------------------------------------

function start_recruitment_advice()
	
	local ra = intro_campaign_recruitment_advice:new(
		player_legendary_lord_char_cqi,
		-- Your Skaven society is a vicious contest. The weak are consumed, and only the strongest survive to serve in arms. Recruit them now, and they will be ready to fight in the battles to come.
		"wh2.camp.prelude.ft.150.skv",
		"wh2.camp.army_selection_advice.001",	-- Select your army.
		"wh2.camp.recruitment_advice.001",		-- Open the Recruitment panel.
		"wh2.camp.recruitment_advice.002",		-- Recruit some extra units
		3,
		-- Excellent choices, my Lord. Be aware that the recruits will take time to train, and that your army must remain stationary while they do so.
		"wh2.camp.prelude.ft.160",
		function() start_finances_advice() end
	);
	
	ra:add_initial_infotext(
		1,
		"war.camp.prelude.ft_recruitment_tutorial.info_001",
		"war.camp.prelude.ft_recruitment_tutorial.info_002"
	);
		
	ra:add_unit_card_infotext(
		"war.camp.prelude.ft_recruitment_tutorial.info_003",
		"war.camp.prelude.ft_recruitment_tutorial.info_004"
	);
	
	ra:start();	
end;




function start_finances_advice()

	cm:clear_infotext();

	start_finances_first_turn_advice_wrapper(
		-- You will of course be aware that armed forces cost currency to build and maintain. Be sure to keep watch on your finances, lest ruin overtakes you.
		"wh2.camp.prelude.ft.165",
		{
			"wh2.camp.intro.info_065",
			"wh2.camp.intro.info_066",
			"wh2.camp.intro.info_067",
			"wh2.camp.intro.info_068"
		},
		function() start_settlement_advice() end
	)
end;





---------------------------------------------------------------
--	Settlements advice
---------------------------------------------------------------

function start_settlement_advice()
	
	local sa = intro_campaign_select_settlement_advice:new(
		yuatek_region_str,
		yuatek_province_str,
		-- Let us review what destruction the 'Elf-things' have wrought on the surrounding territory, mightiest of Lords. Select your city to inspect the province.
		"wh2.camp.prelude.ft.170.skv",
		"wh2.camp.select_settlement_advice.004",
		function() start_province_advice() end
	);
	
	sa:add_initial_infotext(
		1,
		"wh2.camp.intro.info_070",
		"wh2.camp.intro.info_071",
		"wh2.camp.intro.info_072"
	);
	
	sa:set_highlight_altitude(2);
	
	sa:start();
end;






---------------------------------------------------------------
--	Province advice
---------------------------------------------------------------

function start_province_advice()

	bool_regions_higlighted = false;
	
	cm:callback(
		function()
		
			local local_faction = cm:get_local_faction_name();
		
			-- lift shroud on regions in subject province
			cm:take_shroud_snapshot();
			cm:make_region_visible_in_shroud(local_faction, yuatek_region_str);
			cm:make_region_visible_in_shroud(local_faction, scrag_hole_region_str);
			cm:make_region_visible_in_shroud(local_faction, dawns_light_region_str);
			
			-- highlight province
			cm:callback(
				function()
					bool_regions_higlighted = true;
					CampaignUI.SetOverlayMode(20, yuatek_region_str, scrag_hole_region_str, dawns_light_region_str);
					CampaignUI.SetOverlayVisible(true);
				end,
				2,
				"highlighting_regions"
			);
			
			cm:scroll_camera_with_cutscene(
				3, 
				nil,
				{380.761536, 49.706436, 38.078575, -0.643008, 35.0}
			);
			
			cm:show_advice(
				-- The province surrounding your capital is shown here, my Lord. A province may contain many cities, each exerting authority over the territory surrounding them. Control the cities and you control the land.
				"wh2.camp.prelude.ft.175",
				true
			);
		end,
		0.5
	);	
	
	cm:progress_on_advice_dismissed(
		function()
			-- restore shroud
			cm:restore_shroud_from_snapshot();
		
			-- stop highlighting province
			cm:remove_callback("highlighting_regions");
			if bool_regions_higlighted then
				bool_regions_higlighted = false;
				CampaignUI.SetOverlayVisible(false);
			end;
			
			start_province_overview_panel_advice();
		end, 
		1, 
		true
	);
end;










---------------------------------------------------------------
--	Province Overview Panel advice
---------------------------------------------------------------

function start_province_overview_panel_advice()

	cm:clear_infotext();

	start_province_overview_panel_first_turn_advice_chain_wrapper(
		-- Cities within the local province are shown here, my Lord, along with any facilities they contain.
		"wh2.camp.prelude.ft.190",
		-- Shown also are those cities in the province that were recently lost to the enemy: a reminder of the need to reclaim them, my Lord.
		"wh2.camp.prelude.ft.195",
		-- Your capital, and the buildings it contains are shown here, my Lord. Work needs to be done to improve its readiness for war.
		"wh2.camp.prelude.ft.200",
		function() start_province_info_panel_advice() end
	);
end;






---------------------------------------------------------------
--	Province Info Panel advice
---------------------------------------------------------------

function start_province_info_panel_advice()
	cm:clear_infotext();
	
	start_province_info_panel_first_turn_advice_wrapper(
		-- Here we may see the state of the province that surrounds your capital. The enemy raids have caused considerable unrest: public order is suffering as you can see, my Lord. They will need calming in time, but matters of defence are more pressing.
		"wh2.camp.prelude.ft.180",
		function() start_building_construction_advice() end
	);
end;







---------------------------------------------------------------
--	Buildings advice
---------------------------------------------------------------

function start_building_construction_advice()
	cm:clear_infotext();

	-- region_name, province_name, start_advice, start_objective, base_building_card, upgrade_building_card, upgrade_objective, end_advice, end_callback
	local ba = intro_campaign_building_construction_advice:new(
		yuatek_region_str,
		yuatek_province_str,
		-- Your cities are the backbone of your state, my Lord. Taxes are raised through them, and they provide the infrastructure necessary to support your armies. I humbly suggest you commission upgrades to your capital as soon as possible.
		"wh2.camp.prelude.ft.210",
		"wh2.camp.select_settlement_advice.004", 				-- Select Yuatek
		"wh2_main_skv_settlement_major_1",
		"wh2_main_skv_settlement_major_2",
		"wh2.camp.building_construction_advice.001",
		-- Good! Construction will begin immediately, but will take some time to complete.
		"wh2.camp.prelude.ft.220",
		function() start_end_turn_advice() end
	);
	
	ba:add_initial_infotext(
		1,
		"wh2.camp.intro.info_100",
		"wh2.camp.intro.info_101",
		"wh2.camp.intro.info_102"
	);
	
	ba:add_completion_infotext(
		1,
		"wh2.camp.intro.info_103"
	);
	
	ba:start();
end;









---------------------------------------------------------------
--	Ending-turn advice
---------------------------------------------------------------

function skip_to_end_turn_advice()
	out("skipping to end turn advice");
	
	-- disable ui
	cm:get_campaign_ui_manager():display_first_turn_ui(false);
	
	-- progress when the loading screen is hidden, and when the post-battle panel is visible
	core:progress_on_loading_screen_dismissed(
		function()	
			play_end_turn_advice();
		end
	);
end;


function start_end_turn_advice()

	-- ensure that next time we load into this campaign, we load into the main open script
	cm:set_saved_value("bool_first_turn_main_end_reached", true);
	
	-- autosave now
	cm:save(function() play_end_turn_advice() end, true);
end;


function play_end_turn_advice()
	
	-- show button cluster in bottom-right of screen (if not already displayed)
	cm:callback(function() cm:get_campaign_ui_manager():display_faction_buttons(true) end, 1);
	
	-- scroll camera back to usable altitude
	cm:scroll_camera_with_cutscene(
		3, 
		nil,
		{362.1, 56.8, 9.2, 0.0, 5}
	);
	
	local ea = intro_campaign_end_turn_advice:new(
		-- There is nothing more you can do for now, my Lord. Let us await your enemy's next move.
		"wh2.camp.prelude.ft.250",
		"wh2.camp.end_turn_advice.001", 			-- End the turn.
		function() player_ends_turn() end
	);
	
	ea:add_infotext(
		1,
		"war.camp.prelude.ft_end_turn_tutorial.info_001",
		"war.camp.prelude.ft_end_turn_tutorial.info_002",
		"war.camp.prelude.ft_end_turn_tutorial.info_003"
	);
	
	ea:start();
end;


function player_ends_turn()

	-- failsafe: if the player's army is not in the correct location, teleport it
	local char_player = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	
	local player_lord_x = char_player:logical_position_x();
	local player_lord_y = char_player:logical_position_y();
	
	if player_lord_x ~= first_turn_main_movement_destination_x or player_lord_y ~= first_turn_main_movement_destination_y then
		script_error("WARNING: player's lord is at [" .. player_lord_x .. ", " .. player_lord_y .. "], should be at [" .. first_turn_main_movement_destination_x .. ", " .. first_turn_main_movement_destination_y .. "], performing failsafe teleportation");
		cm:teleport_to(cm:char_lookup_str(char_player),  first_turn_main_movement_destination_x, first_turn_main_movement_destination_y, true);
	end;
	
	local enemy_faction_str = fortress_of_dawn_faction_str;
	
	-- listen for main enemy faction starting their turn
	core:add_listener(
		"enemy_first_turn_listener",
		"FactionBeginTurnPhaseNormal",
		function(context) return context:faction():name() == enemy_faction_str end,
		function() enemy_faction_starts_turn(enemy_faction_str) end,
		false
	);
end;









---------------------------------------------------------------
--	Enemy attack during end-turn
---------------------------------------------------------------

function enemy_faction_starts_turn(enemy_faction_str)

	-- prevent the AI from ending turn
	cm:disable_end_turn(true);

	-- get a handle on the attacking lord
	local char_enemy = cm:get_character_by_cqi(enemy_secondary_lord_char_cqi);
	
	if not char_enemy then
		script_error("ERROR: enemy_faction_starts_turn() couldn't find the enemy lord");
		
		cm:disable_end_turn(false);
		cm:end_turn();
		
		return false;
	end;
		
	-- get the player's character
	local char_player = cm:get_character_by_cqi(player_legendary_lord_char_cqi);
	
	if not char_player then
		script_error("ERROR: enemy_faction_starts_turn() couldn't find the player's lord");
		
		cm:disable_end_turn(false);
		cm:end_turn();
		
		return false;
	end;
	
	local char_str_enemy = cm:char_lookup_str(char_enemy);
	local char_str_player = cm:char_lookup_str(char_player);
	
	-- prevent the ai from moving the enemy lord itself
	cm:cai_disable_movement_for_character(char_str_enemy);
	cm:enable_movement_for_faction(enemy_faction_str);
	cm:enable_movement_for_character(char_str_enemy);
	
	-- tell the enemy lord to attack
	cm:attack(char_str_enemy, char_str_player, true);
	
	-- listen for battle being joined
	core:add_listener(
		"first_turn_pre_battle_panel_listener",
		"ScriptEventPreBattlePanelOpened",
		true,
		function() enemy_attack_launched() end,
		false	
	);
end;


function enemy_attack_launched()
	out("enemy_attack_launched() called");
	
	local attack_button_clicked = false;
	local attack_button_highlighted = false;
	
	-- close menace below panel
	set_component_visible(false, "popup_pre_battle", "allies_combatants_panel", "ability_charge_panel");
	
	-- The enemy opt to attack, my Lord! Ready your forces, for battle is upon you!
	cm:show_advice("wh2.camp.prelude.ft.260");
	cm:add_infotext(
		1,
		"war.camp.advice.pre_battle_panel.info_001",
		"war.camp.advice.pre_battle_panel.info_002",
		function()
			if not attack_button_clicked then
				-- highlight attack button
				highlight_component(true, true, "button_attack_container", "button_attack");
				attack_button_highlighted = true;
				
				show_balance_of_power_text_point_first_turn();
			end;
		end
	);
	
	-- remove the first battle override, so that it doesn't trigger again
	cm:remove_custom_battlefield("intro_battle_1");
	
	-- prevent the winds of magic gambler appearing in battle
	cm:skip_winds_of_magic_gambler(true);
	
	-- ensure the next battle we load is the second intro battle
	remove_battle_script_override();
	cm:add_custom_battlefield(
		"intro_battle_2",														-- string identifier
		0,																		-- x co-ord
		0,																		-- y co-ord
		5000,																	-- radius around position
		false,																	-- will campaign be dumped
		"",																		-- loading override
		"script/battle/intro_battles/skaven/second/battle_start.lua",			-- script override
		"",																		-- entire battle override
		0,																		-- human alliance when battle override
		false,																	-- launch battle immediately
		true,																	-- is land battle (only for launch battle immediately)
		false																	-- force application of autoresolver result
	);
	
	-- listen for button being clicked
	core:add_listener(
		"attack_button_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_attack" end,
		function()
			attack_button_clicked = true;
			
			if attack_button_highlighted then
				highlight_component(false, true, "button_attack_container", "button_attack");
			end;
		end,
		false
	);
end;





