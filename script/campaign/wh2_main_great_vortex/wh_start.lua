-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--	This file gets loaded before any of the faction scripts
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- require a file in the factions subfolder that matches the name of our local faction. The model will be set up by the time
-- the ui is created, so we wait until this event to query who the local faction is. This is why we defer loading of our
-- faction scripts until this time.

-------------------------------------------------------
--	load in faction scripts when the game is created
-------------------------------------------------------

cm:add_pre_first_tick_callback(
	function()
		-- only load faction scripts if we have a local faction
		if not cm:get_local_faction_name(true) then
			return;
		end;
		
		-- load the legendary lord and rite unlock listeners when the ui is loaded
		rite_unlock_listeners();
		
		-- if the tweaker to force the campaign prelude is set, then set the sbool value as if the tickbox had been ticked on the frontend
		if core:is_tweaker_set("FORCE_FULL_CAMPAIGN_PRELUDE") then
			core:svr_save_bool("sbool_player_selected_first_turn_intro_on_frontend", true);
		end;
		
		-- if the tweaker to force the campaign prelude to the main section is set, then set the corresponding savegame value
		if core:is_tweaker_set("FORCE_CAMPAIGN_PRELUDE_TO_SECOND_PART") then
			core:svr_save_bool("sbool_player_selected_first_turn_intro_on_frontend", true);
			cm:set_saved_value("bool_first_turn_intro_completed", true);
		end;
		
		-- load the faction scripts
		-- loads the file in script/campaigns/<campaign_name>/factions/<faction_name>/<faction_name>_start.lua
		cm:load_local_faction_script("_start");
	end
);



-------------------------------------------------------
--	functions to call when the first tick occurs
-------------------------------------------------------

cm:add_first_tick_callback_new(function() start_new_game_all_factions() end);
cm:add_first_tick_callback(function() start_game_all_factions() end);


-- Called when a new campaign game is started.
-- Put things here that need to be initialised only once, at the start 
-- of the first turn, but for all factions
-- This is run before start_game_all_factions()
function start_new_game_all_factions()
	out("start_new_game_all_factions() called");
	
	-- put the camera at the player's faction leader at the start of a new game
	cm:position_camera_at_primary_military_force(cm:get_local_faction_name(true));
	
	add_very_hard_armies();
	
	-- add effect bundle to human factions in co op multiplayer that doubles vortex ritual cost
	if cm:model():is_multiplayer() and cm:model():campaign_type() ~= 2 then
		local human_factions = cm:get_human_factions();
		
		for i = 1, #human_factions do
			cm:apply_effect_bundle("wh2_main_bundle_mpc_vortex_ritual_cost", human_factions[i], 0);
		end;
	end;
end;




-- Called each time a game is started/loaded.
-- Put things here that need to be initialised each time the game/script is
-- loaded here. This is run after start_new_game_all_factions()
function start_game_all_factions()
	out("start_game_all_factions() called");
	out.inc_tab();
	
	-- start all scripted behaviours that should apply across all campaigns
	setup_wh_campaign();
	q_setup();
	
	-- load the vortex rituals script
	vortex_setup();
	
	apply_default_diplomacy();
	
	-- load the horde reemergence script
	add_horde_reemergence_listeners();
	
	add_slann_selection_listeners();
	add_faction_renaming_listeners();
	add_tech_tree_lords_listeners();
	confed_missions:setup();
	
	-- disable tax and public order for fortress gates
	disable_tax_and_public_order_for_regions(
		{
			"wh2_main_vor_eagle_gate",
			"wh2_main_vor_griffon_gate",
			"wh2_main_vor_phoenix_gate",
			"wh2_main_vor_unicorn_gate"
		}
	);
	
	-- listen for ritual 2 completion to change ai personalities
	if not cm:get_saved_value("ai_personalities_changed") then
		switch_ai_personality_listener();
	end;
	
	out.dec_tab();
	
	--Campaign Custom Starts
	out("==== Custom Starts ====");
	add_campaign_custom_start_listeners();

	--Marker Manager
	out("==== Marker Manager====")
	if not cm:is_new_game() then
		Interactive_Marker_Manager:reconstruct_markers()
	end
	
	-- DLC07 Bretonnia Features
	out("==== Bretonnia ====");
	Add_Bretonnia_Listeners();
	Add_Lady_Blessing_Listeners();
	Add_Bretonnia_Technology_Listeners();
	Add_Peasant_Economy_Listeners();
	Add_Virtues_and_Traits_Listeners();
	Add_Chivalry_Listeners();
	add_green_knight_listeners();
	
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
	add_grom_food_listeners();
	add_grom_story_listeners();
	add_grn_unit_upgrade_listeners();
	add_wagh_listeners();

	---DLC16 Twisted and the Twilight	
	out("==== Twisted & Twilight ====");
	Worldroots:add_worldroots_listeners();
	add_sisters_forge_listeners();
	add_flesh_lab_listeners();
	add_twilight_story_listeners();
	add_throt_unlock_ghoritch_listeners();

	---TWA03 Rakarth----
	out("==== Rakarth ====");
	RakarthBeastHunts:setup_rakarth_listeners()

	---DLC17 - The Silence and the Fury
	out("==== Silence & Fury =====")
	thorek:initialise();
	add_oxyotl_sanctum_listeners();
	attempt_to_load_grudges_script();
	add_oxyotl_threat_map_listeners();
	add_beast_tech_lock_listeners();
	Add_Moon_Phase_Listeners();
	Bloodgrounds:setup();
	add_taurox_rampage_listeners();
	Ruination:add_ruination_listeners()
	Oxyotl_Vortex:trigger_starting_vortex_mission()

	---TWA05
	out("==== Ogre Camps ====");
	Ogre_Camp:setup();
	
	-- Debug
	add_debug_listeners();
	
	if cm:is_new_game() == true then
		-- Starting Vows
		add_starting_vows();
	end

	-- Trigger an event that faction scripts that position the camera will listen for.
	-- Camera position can be reset by some actions that happen while start_game_all_factions() is called, so only position the camera once it's finished.
	core:trigger_event("ScriptEventStartGameAllFactionsCompleted");
end


-- switch the ai personalities at a point in the game
function switch_ai_personality_listener()
	core:add_listener(
		"ai_personalities",
		"RitualCompletedEvent",
		function(context)
			return context:succeeded() and context:ritual():ritual_key():find("_2_");
		end,
		function()
			force_personality_change_in_all_factions();
		end,
		false
	);
end;

function force_personality_change_in_all_factions()	
	out.chaos("force_personality_change_in_all_factions() called");
	
	cm:set_saved_value("ai_personalities_changed", true);
	
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if not faction:is_human() then
			cm:cai_force_personality_change(faction:name());
		end;
	end;
end;

core:add_listener(
	"default_diplomacy_listener",
	"ScriptEventAllDiplomacyEnabled",
	true,
	function()
		apply_default_diplomacy()
	end,
	true
);

function apply_default_diplomacy()
	out("apply_default_diplomacy() called");
	
	-- lock off the gift-region option. We really shouldn't be doing this here...
	cm:force_diplomacy("all", "all", "regions", false, false, false);
	
	local trade_str = "trade agreement,break trade";
	
	-- Greenskins cannot trade
	cm:force_diplomacy("culture:wh_main_grn_greenskins", "all", trade_str, false, false, true);
	-- Chaos (cannot trade
	cm:force_diplomacy("subculture:wh_main_sc_chs_chaos", "all", trade_str, false, false, true);
	
	-- only certain cultures can request a faction to become a vassal
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
	-- no peace for Arkhan and Settra
	cm:force_diplomacy("faction:wh2_dlc09_tmb_khemri", "faction:wh2_dlc09_tmb_followers_of_nagash", "all", false, false, true);
	-- nobody can vassal Settra
	cm:force_diplomacy("all", "faction:wh2_dlc09_tmb_khemri", "vassal", false, false, false);	
	
	-- Beastmen can only do peace and war with other factions
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "all", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "war", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "payments", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "all", "peace", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "wh2_dlc17_lzd_oxyotl", "peace", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", "form confederation", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc03_bst_beastmen", trade_str, false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_main_chs_chaos", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_main_chs_chaos", "form confederation", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_main_chs_chaos", trade_str, false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc08_nor_norsca", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc08_nor_norsca", "form confederation", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh_dlc08_nor_norsca", trade_str, false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh2_main_skv_skaven", "all", true, true, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh2_main_skv_skaven", "form confederation", false, false, true);
	cm:force_diplomacy("culture:wh_dlc03_bst_beastmen", "culture:wh2_main_skv_skaven", trade_str, false, false, true);
	
	-- loop through all factions to lock off diplomacy options that can't be locked using the system above
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local current_faction_name = current_faction:name();
		
		-- full greenskin factions cannot cancel vassal treaties with their waaagh factions
		if current_faction:culture() == "wh_main_grn_greenskins" then		
			local target_faction_name = current_faction_name .. "_waaagh";
			
			if cm:model():world():faction_exists(target_faction_name) then
				cm:force_diplomacy("faction:" .. current_faction_name, "faction:" .. target_faction_name, "war,break vassal", false, false, false);
			end;
		end;
	end;
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
			local region = context:region();
			out("Region Event: " .. context:id());
		end,
		true
	);
	
	core:add_listener(
		"DEBUG_CharacterListner",
		"DebugCharacterEvent",
		true,
		function(context)
			local character = context:character();
			out("Character Event: " .. context:id());
		end,
		true
	);
end;