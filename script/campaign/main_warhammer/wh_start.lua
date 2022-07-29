
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--	This file gets loaded before any of the faction scripts
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


cm:add_pre_first_tick_callback(
	function()
		-- load the legendary lord and rite unlock listeners when the ui is loaded
		ll_setup();
		
		rite_unlock_listeners();
		
	end
);

function replace_minor_faction_with_playable_faction(minor_faction_name, playable_faction_name)
	local minor_faction = cm:get_faction(minor_faction_name)
	local playable_faction = cm:get_faction(playable_faction_name)
	
	if not playable_faction:is_human() then
		cm:disable_event_feed_events(true, "wh_event_category_conquest", "", "");
		cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");
		
		local minor_faction_character_list = minor_faction:character_list();
		local minor_faction_region_list = minor_faction:region_list();
		
		for i = 0, minor_faction_character_list:num_items() - 1 do
			local cur_char = minor_faction_character_list:item_at(i);
			
			if cur_char:is_null_interface() == false then
				cm:kill_character(cur_char:command_queue_index(), true, true);
			end
		end;
		
		for i = 0, minor_faction_region_list:num_items() - 1 do
			local region_key = minor_faction_region_list:item_at(i):name()
			cm:transfer_region_to_faction(region_key, playable_faction_name);
			cm:callback(function() 
				cm:heal_garrison(cm:get_region(region_key):cqi());
			end, 0.5);
		end;
		
		cm:callback(
			function()
				cm:disable_event_feed_events(false, "wh_event_category_conquest", "", "");
				cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "");
			end,
			1
		);
	end;
end;


function start_game_all_factions()
	out("start_game_all_factions() called");
	out.inc_tab();
	
	-- start all scripted behaviours that should apply across all campaigns
	setup_wh_campaign();
	
	-- load the Chaos Invasion script
	local ci_stage = cm:get_saved_value("ci_stage");

	if ci_stage == nil then
		CI_setup();
	else
		out.chaos("!!!!! Loading old Chaos script !!!!!");
		ci_setup_old();
	end
	
	-- load the quests script
	q_setup();
	
	-- load the Grudges script
	attempt_to_load_grudges_script();
	
	-- load the horde reemergence script
	add_horde_reemergence_listeners();
	
	add_vampire_bloodlines_listeners();
	add_slann_selection_listeners();
	add_faction_renaming_listeners();
	add_tech_tree_lords_listeners();
	confed_missions:setup();
	Forced_Battle_Manager:load_listeners()
	
	-- disable tax and public order for fortress gates
	disable_tax_and_public_order_for_regions(
		{
			"wh2_main_eagle_gate",
			"wh2_main_griffon_gate",
			"wh2_main_phoenix_gate",
			"wh2_main_unicorn_gate",
			"wh2_main_fort_bergbres",
			"wh2_main_fort_helmgart",
			"wh2_main_fort_soll"
		}
	);
	
	if cm:is_new_game() then
		local vlad = cm:get_faction("wh_main_vmp_schwartzhafen");
			
		-- when playable factions are under ai control, gift them the minor faction's regions that occupy their starting province
		replace_minor_faction_with_playable_faction("wh_main_emp_empire_separatists", "wh_main_emp_empire");
		replace_minor_faction_with_playable_faction("wh2_main_def_cult_of_excess", "wh2_main_hef_eataine");
		if vlad and not vlad:is_human() then
			replace_minor_faction_with_playable_faction("wh_main_vmp_rival_sylvanian_vamps", "wh_main_vmp_vampire_counts");
		end;


		
		-- put the camera at the player's faction leader at the start of a new game
		local_faction = cm:get_local_faction_name(true);
		is_multiplayer = cm:is_multiplayer();
		-- but not for beastmen in mpc as their lords can be teleported
		if not is_multiplayer or (is_multiplayer and local_faction ~= "wh_dlc03_bst_beastmen") then
			cm:callback(function() cm:position_camera_at_primary_military_force(local_faction) end, 0.5); -- delay this in case armies are teleported, their position doesn't update in time
		end;
		
		-- setup subculture-specific diplomacy option exclusions
		apply_default_diplomacy();
		award_faction_trait_effect_bundles_for_vampires();
		award_faction_trait_effect_bundles_for_vlad();
		-- save the chosen legendary lords so we do not unlock them later on
		store_starting_generals();
		-- Give Belegar and his agents start exp
		belegar_start_experience();
		-- If player is a DLC06 faction setup Eight Peaks
		eight_peaks_setup();
		-- add warhorse to louen - adding in start pos has issues
		local bretonnia = cm:get_faction("wh_main_brt_bretonnia");
		if bretonnia then
			cm:force_add_ancillary(bretonnia:faction_leader(), "wh_main_anc_mount_brt_louen_barded_warhorse", true, true);
		end;
		local varg = cm:get_faction("wh_main_nor_varg");
		if varg then
			cm:force_add_ancillary(varg:faction_leader(), "wh_dlc10_anc_mount_nor_surtha_ek_marauder_chariot", true, true);
		end;
		-- Starting Vows
		add_starting_vows();
		-- Add Ungrim start mission
		local karak_kadrin = cm:get_faction("wh_main_dwf_karak_kadrin");
		if karak_kadrin and karak_kadrin:is_human() then
			local mm = mission_manager:new("wh_main_dwf_karak_kadrin", "wh2_main_dwf_ungrim_start_mission");
			mm:add_new_objective("CAPTURE_REGIONS");
			mm:add_condition("region wh_main_peak_pass_gnashraks_lair");
			mm:add_condition("ignore_allies");
			mm:add_payload("money 1000");
			mm:add_payload("faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 30;}");
			mm:set_should_whitelist(false);
			mm:trigger();
		end;
		
	
	end
	
	-- unlock starting generals for AI
	if not cm:get_saved_value("ci_starting_generals_unlocked_ai") then
		core:add_listener(
			"unlock_ai_generals",
			"FactionTurnStart",
			function() return cm:model():turn_number() == 30 end,
			function()
				unlock_ai_starting_generals();
				cm:set_saved_value("ci_starting_generals_unlocked_ai", true);
			end,
			false
		);
	end;
	
	--Campaign Custom Starts
	out("==== Custom Starts ====");
	add_campaign_custom_start_listeners();

	--Marker Manager
	out("==== Marker Manager====")
	if not cm:is_new_game() then
		Interactive_Marker_Manager:reconstruct_markers()
	end
	-- DLC03 Beastmen Features
	out("==== Beastman ====");
	Add_Moon_Phase_Listeners();
	add_beastmen_final_battle_listener();
	apply_beastmen_default_diplomacy();
	
	-- DLC06 Karak Features
	out("==== Karak ====");
	apply_karak_diplomacy();
	add_grombrindal_listeners();
	add_grn_unit_upgrade_listeners();
	
	local wurrzag = cm:get_faction("wh_main_grn_orcs_of_the_bloody_hand");
	
	if wurrzag and not wurrzag:is_human() and not wurrzag:has_effect_bundle("wh_dlc06_wurrzag_anti_trait") then
		-- A.I Wurrzag gets an anti-trait
		cm:apply_effect_bundle("wh_dlc06_wurrzag_anti_trait", "wh_main_grn_orcs_of_the_bloody_hand", 0);
		cm:force_add_trait(cm:char_lookup_str(wurrzag:faction_leader():command_queue_index()), "wh_dlc06_wurrzag_anti_trait", true);
	end;
	
	-- DLC05 Wood Elves Features
	out("==== Wood Elves ====");
	Add_Wood_Elves_Listeners();
	Add_Amber_Listeners();

	-- DLC06 Karak Eight Peaks Features
	Add_Karak_Eight_Peaks_Listeners();
	
	-- DLC07 Bretonnia Features
	out("==== Bretonnia ====");
	Add_Bretonnia_Listeners();
	Add_Lady_Blessing_Listeners();
	Add_Bretonnia_Technology_Listeners();
	Add_Peasant_Economy_Listeners();
	Add_Virtues_and_Traits_Listeners();
	Add_Chivalry_Listeners();
	add_green_knight_listeners();
	add_vlad_isabella_listeners();
	
	-- DLC08 Norsca Features
	out("==== Norsca ====");
	Add_Norsca_Listeners();
	Add_Norscan_Gods_Listeners();
	
	-- DLC09 Tomb Kings Features
	out("==== Tomb Kings ====");
	add_tomb_kings_listeners();
	add_nagash_books_listeners();
	add_nagash_books_effects_listeners();
	add_dynasty_tree_listeners();
	
	-- DLC10 Queen & Crone Features
	out("==== Queen & Crone ====");
	add_alarielle_listeners();
	add_hellebron_listeners();
	add_alith_anar_listeners();
	initiate_sword_button();
	
	-- DLC11 Vampire Coast Features
	out("==== Vampire Coast ====");
	add_vampire_coast_listeners();
	add_infamy_listeners();
	add_vampire_coast_tech_tree_listeners();
	add_treasure_maps_listeners();
	add_ulthuan_monster_listeners();
	add_roving_pirates_listeners();
	add_lokhir_listeners();
	add_ship_upgrade_listeners();
	initialize_encounter_listeners();
	
	-- DLC12 Prophet & Warlock Features
	out("==== Prophet & Warlock ====");
	add_under_empire_listeners();
	add_mount_upgrade_listeners();
	initialize_workshop_listeners();
	add_tehenhauin_listeners();
	add_kroak_listeners();
	
	-- DLC13 Hunter & Beast Features
	out("==== Hunter & Beast ====");
	add_empire_politics_listeners();
	initialize_imperial_guard_listeners();
	add_wulfhart_hunters_listeners();
	add_nakai_hunters_listeners();
	add_nakai_temples_listeners();
	
	-- PRO08 Gotrek & Felix Features
	add_gotrek_felix_listeners();
	
	-- DLC14 The Shadow & The Blade
	out("==== Shadow & Blade ====");
	add_malus_malekiths_favour_listeners();
	add_malus_sanity_listeners();
	add_tzarkans_whispers_listeners();
	add_shadowy_dealings_listeners();
	add_clan_contracts_listeners();
	add_shadow_objectives_listeners();
	add_repanse_confederation_listeners();
	add_snikch_revitalizing_listeners();

	-- DLC15 The Warden & The Paunch
	out("==== Warden & Paunch ====");
	add_eltharion_lair_listeners();
	add_eltharion_story_listeners();
	add_eltharion_mist_listeners();
	add_eltharion_yvresse_defence_listeners();
	add_dragon_encounters_listeners();
	add_wagh_listeners();
	add_grom_food_listeners();
	add_grom_story_listeners();

	---DLC16 The Twisted & the Twilight
	out("==== Twisted & Twilight ====");
	Worldroots:add_worldroots_listeners();
	add_sisters_forge_listeners();
	add_flesh_lab_listeners();
	add_drycha_coeddil_unchained_listeners();
	add_throt_unlock_ghoritch_listeners();

	---TWA03 Rakarth----
	out("==== Rakarth ====");
	RakarthBeastHunts:setup_rakarth_listeners()


	---DLC17 - The Silence and the Fury
	out("==== Silence & Fury =====")
	thorek:initialise();
	add_oxyotl_sanctum_listeners();
	add_oxyotl_threat_map_listeners();
	add_beast_tech_lock_listeners();
	Bloodgrounds:setup()
	add_taurox_rampage_listeners();
	Ruination:add_ruination_listeners()

	---TWA05
	out("==== Ogre Camps ====");
	Ogre_Camp:setup();
	
	if not cm:is_multiplayer() then
		local mission = "wh_main_long_victory";
		
		core:add_listener(
			"victory_dilemma",
			"MissionSucceeded",
			function(context)
				return context:mission():mission_record_key() == mission;
			end,
			function(context)
				out("*** Victory Achieved! Waiting for battle sequence to complete before triggering victory dilemma ***");
				
				local faction_name = context:faction():name();
				
				-- wait until the battle sequence has ended before triggering the victory dilemma (should one be running)
				cm:progress_on_battle_completed(
					"victory_dilemma",
					function()
						out("*** Battle sequence completed - triggering victory dilemma ***");
						
						local dilemma = "wh2_main_dilemma_grand_campaign_victory";
						
						if faction_name == "wh2_dlc09_tmb_followers_of_nagash" then
							dilemma = dilemma .. "_arkhan"
						end;
						
						cm:trigger_dilemma(faction_name, dilemma);
						
						core:add_listener(
							"continue_after_victory_dilemma",
							"DilemmaChoiceMadeEvent",
							function(context)
								return context:dilemma() == dilemma;
							end,
							function()
								CampaignUI:ShowVictoryScreen(true, true, mission);
							end,
							false
						);
					end,
					0.5
				);
			end,
			false
		);
	end;
	
		-- Debug
	add_debug_listeners();
	
	out.dec_tab();

	-- Trigger an event that faction scripts that position the camera will listen for.
	-- Camera position can be reset by some actions that happen while start_game_all_factions() is called, so only position the camera once it's finished.
	core:trigger_event("ScriptEventStartGameAllFactionsCompleted");
end;

core:add_listener(
	"default_diplomacy_listener",
	"ScriptEventAllDiplomacyEnabled",
	true,
	function(context) apply_default_diplomacy() end,
	true
);

function apply_default_diplomacy()
	local timestamp = os.clock();
	
	-- lock off the gift-region option. We really shouldn't be doing this here...
	cm:force_diplomacy("all", "all", "regions", false, false, false);
	
	-- The Empire cannot be at peace with Empire Secessionists
	cm:force_diplomacy("faction:wh_main_emp_empire", "faction:wh_main_emp_empire_separatists", "peace", false, false, true);
	
	local trade_str = "trade agreement,break trade";
	
	-- Greenskins cannot trade
	cm:force_diplomacy("culture:wh_main_grn_greenskins", "all", trade_str, false, false, true);
	
	-- Chaos only have the option to declare war on Empire, Bretonnia or Dwarfs and vice versa
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_emp_empire", "all", false, false, true);
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_emp_empire", "war", true, true, true);
	
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_brt_bretonnia", "all", false, false, true);
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_brt_bretonnia", "war", true, true, true);
	
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_dwf_dwarfs", "all", false, false, true);
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "culture:wh_main_dwf_dwarfs", "war", true, true, true);
	
	-- if Empire/Bretonnia/Dwarfs are human controlled (i.e. MPC) then all options are available to Chaos (except trade)
	local emp = cm:get_faction("wh_main_emp_empire");	
	if emp:is_human() then
		cm:force_diplomacy("faction:wh_main_chs_chaos", "faction:wh_main_emp_empire", "all", true, true, true);
	end;
	
	local brt = cm:get_faction("wh_main_brt_bretonnia");	
	if brt:is_human() then
		cm:force_diplomacy("faction:wh_main_chs_chaos", "faction:wh_main_brt_bretonnia", "all", true, true, true);
	end;
	
	local dwf = cm:get_faction("wh_main_dwf_dwarfs");	
	if dwf:is_human() then
		cm:force_diplomacy("faction:wh_main_chs_chaos", "faction:wh_main_dwf_dwarfs", "all", true, true, true);
	end;
	
	-- if Chaos is not human controlled then Norsca cannot declare war on each other
	local chs = cm:get_faction("wh_main_chs_chaos");
	-- With the addition of Norsca as playable, we now check if either Norscan is human and if so allow Norscan wars
	local nor_1 = cm:get_faction("wh_dlc08_nor_norsca");
	local nor_2 = cm:get_faction("wh_dlc08_nor_wintertooth");
	if (chs:is_human() == false) and (nor_1:is_human() == false) and (nor_2:is_human() == false) then
		cm:force_diplomacy("subculture:wh_main_sc_nor_norsca", "subculture:wh_main_sc_nor_norsca", "war", false, false, true);
	end
	
	-- Chaos cannot trade
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "all", trade_str, false, false, true);
	
	-- some cultures cannot request a faction to become a vassal
	local cultures_with_vassal = {
		"wh_main_chs_chaos",
		"wh_main_vmp_vampire_counts",
		"wh2_dlc09_tmb_tomb_kings"
	};
	
	cm:force_diplomacy("all", "all", "vassal", false, true, true);
	
	for i = 1, #cultures_with_vassal do
		cm:force_diplomacy("culture:" .. cultures_with_vassal[i], "all", "vassal", true, true, false);
	end;
	
	-- sentinels cannot do diplomacy with anyone, but anyone can declare war on the sentinels
	cm:force_diplomacy("faction:wh2_dlc09_tmb_the_sentinels", "all", "all", false, false, true);
	cm:force_diplomacy("all", "faction:wh2_dlc09_tmb_the_sentinels", "war", true, true, false);
	-- nobody can vassal Settra
	cm:force_diplomacy("all", "faction:wh2_dlc09_tmb_khemri", "vassal", false, false, false);	
	
	-- loop through all factions to lock off diplomacy options that can't be locked using the system above
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();
		local current_faction_culture = current_faction:culture();
		
		-- full greenskin factions cannot cancel vassal treaties with their waaagh factions
		if current_faction_culture == "wh_main_grn_greenskins" then		
			local target_faction_name = current_faction_name .. "_waaagh";
			
			if cm:model():world():faction_exists(target_faction_name) then
				cm:force_diplomacy("faction:" .. current_faction_name, "faction:" .. target_faction_name, "war,break vassal", false, false, false);
			end;
		end;
		if current_faction:is_human() then
			-- Dwarfs faction will never approach the player with a peace offer if the player is Greenskins
			if current_faction_culture == "wh_main_grn_greenskins" then
				cm:force_diplomacy("faction:wh_main_dwf_dwarfs", "faction:" .. current_faction_name, "peace", false, false, false);
			else
				-- Greenskins will never approach the player (not Greenskins) with a peace offer
				cm:force_diplomacy("culture:wh_main_grn_greenskins", "faction:" .. current_faction_name, "peace", false, false, false);
			end;
		end;
	end;
	
	out("apply_default_diplomacy() finished, processing custom diplomatic setup took " .. os.clock() - timestamp .. "s");
end;


function apply_beastmen_default_diplomacy()
	--Set up who are they allowed to declare war with 
	
	-- Beastmen can only do peace and war with other factions
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "all", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "war", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "payments", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "peace", true, true, true);	
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", "form confederation", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", trade_str, false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_main_chs_chaos", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_main_chs_chaos", trade_str, false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh2_main_skv_skaven", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh2_main_skv_skaven", trade_str, false, false, true);
	
	-- if Empire/Bretonnia/Dwarfs are human controlled (i.e. MPC) then all options are available to Beastmen (except trade)
	if cm:is_multiplayer() then
		local emp = cm:get_faction("wh_main_emp_empire");	
		local beast = cm:get_faction("wh_dlc03_bst_beastmen");
		if beast and emp:is_human() and beast:is_human() then
			cm:force_diplomacy("faction:wh_dlc03_bst_beastmen", "faction:wh_main_emp_empire", "all", true, true, true);
		end;
		
		local brt = cm:get_faction("wh_main_brt_bretonnia");	
		if beast and brt:is_human() and beast:is_human() then
			cm:force_diplomacy("faction:wh_dlc03_bst_beastmen", "faction:wh_main_brt_bretonnia", "all", true, true, true);
		end;
		
		local dwf = cm:get_faction("wh_main_dwf_dwarfs");	
		if beast and dwf:is_human() and beast:is_human() then
			cm:force_diplomacy("faction:wh_dlc03_bst_beastmen", "faction:wh_main_dwf_dwarfs", "all", true, true, true);
		end;
	end
	
	--Set up diplomatic relationships based on starting leader
	
	local faction_list = cm:model():world():faction_list();
	local beastmen_subculture = "wh_dlc03_sc_bst_beastmen";
	local brayherd_append_str = "_brayherd";
	local faction_prepend_str = "faction:";
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();
		local current_faction_subculture = current_faction:subculture();
		-- full beastmen factions cannot cancel vassal treaties with their brayherd factions
		if current_faction_subculture == beastmen_subculture then		
			local target_faction_name = current_faction_name .. brayherd_append_str;
			if cm:model():world():faction_exists(target_faction_name) then
				cm:force_diplomacy(faction_prepend_str .. current_faction_name, faction_prepend_str .. target_faction_name, "war,break vassal,break alliance,break vassal,break client state", false, false, true);
			end;
		end;
		
	end;
end


function show_benchmark_camera_pan_if_required(callback)
	if not is_function(callback) then
		script_error("ERROR: show_benchmark_camera_pan_if_required() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if not cm:is_benchmark_mode() then
		-- don't do benchmark camera pan
		callback();
		return;
	end;
	
	local ui_root = core:get_ui_root();
	
	core:svr_save_bool("sbool_should_run_campaign_benchmark", false);
	
	cm:set_camera_position(487.6, 111.0, 24.5, 0.0, 24.0);
	cm:show_shroud(false);
	CampaignUI.ToggleCinematicBorders(true);
	ui_root:LockPriority(50)
	--cm:steal_user_input(true);
	cm:override_ui("disable_settlement_labels", true);
	cm:cindy_playback("script/campaign_demo/scenes/camp_demo_cam_pan_01.CindyScene", 0, 5);
	
	cm:callback(
		function()
			--cm:steal_user_input(false);
			ui_root:UnLockPriority()
			ui_root:InterfaceFunction("QuitForScript");
		end,
		74.3
	);
end;



function award_faction_trait_effect_bundles_for_vampires()
	local player_faction = cm:get_faction("wh_main_vmp_vampire_counts");
	
	if player_faction:is_human() then
		local helman_name = "names_name_2147358044";
		local character_list = player_faction:character_list();
		cm:disable_event_feed_events(true, "wh_event_category_traits_ancillaries", "", "");
		
		for i = 0, character_list:num_items() - 1 do
			local current_char = character_list:item_at(i);
			
			if current_char:get_forename() == helman_name then
				cm:force_add_trait("character_cqi:" .. current_char:cqi(), "wh_trait_dlc04_helman_not_shown", true);
			end;
		end;
		
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_traits_ancillaries", "", "") end, 1);
	end;
end;


function award_faction_trait_effect_bundles_for_vlad()
	local player_faction = cm:get_faction("wh_main_vmp_schwartzhafen");
	
	if player_faction:is_human() then
		local vlad_name = "names_name_2147345130";
		local character_list = player_faction:character_list();
		cm:disable_event_feed_events(true, "wh_event_category_traits_ancillaries", "", "");
		
		for i = 0, character_list:num_items() - 1 do
			local current_char = character_list:item_at(i);
			
			if current_char:get_forename() == vlad_name then
				cm:force_add_trait("character_cqi:" .. current_char:cqi(), "wh_trait_dlc04_vlad_vanguard_not_shown", true);
			end;
		end;
		
		cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_traits_ancillaries", "", "") end, 1);
	end;
end;



function add_beastmen_final_battle_listener()
	if not cm:get_saved_value("bst_final_battle_quest") then
		core:add_listener(
			"Beastmen_Final_Battle",
			"ScriptEventHumanFactionTurnStart",
			function(context)
				return context:faction():name() == "wh_dlc03_bst_beastmen" and are_all_beastmen_final_battle_factions_dead();
			end,
			function()
				cm:trigger_mission("wh_dlc03_bst_beastmen", "wh_dlc03_qb_bst_the_final_battle", true);
				cm:set_saved_value("bst_final_battle_quest", true);
			end,
			false
		);
	end;
end;

function are_all_beastmen_final_battle_factions_dead()
	local factions = {
		"wh_main_emp_averland",
		"wh_main_emp_hochland",
		"wh_main_emp_middenland",
		"wh_main_emp_nordland",
		"wh_main_emp_ostland",
		"wh_main_emp_ostermark",
		"wh_main_emp_stirland",
		"wh_main_emp_talabecland",
		"wh_main_emp_wissenland",
		"wh_main_emp_empire",
		"wh_main_brt_bretonnia"
	};
	
	for i = 1, #factions do
		if not cm:get_faction(factions[i]):is_dead() then
			return false;
		end;
	end;
	
	return true;
end;

function add_debug_listeners()
	core:add_listener(
		"DEBUG_FactionListner",
		"DebugFactionEvent",
		true,
		function(context)
			out("Faction Event: " .. context:id());
		end,
		true
	);
	
	core:add_listener(
		"DEBUG_RegionListner",
		"DebugRegionEvent",
		true,
		function(context)
			out("Region Event: " .. context:id());
		end,
		true
	);
	
	core:add_listener(
		"DEBUG_CharacterListner",
		"DebugCharacterEvent",
		true,
		function(context)
			out("Character Event: " .. context:id());
		end,
		true
	);
end;