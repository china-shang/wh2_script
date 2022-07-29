




kraka_drak_faction_str = "wh_main_dwf_kraka_drak";
varg_faction_str = "wh_main_nor_varg";
skaeling_faction_str = "wh_main_nor_skaeling";
chaos_separatists_faction_str = "wh_main_chs_chaos_separatists";

-- set to true to test chaos events out
test_chaos_invasion_events = false;

lord_of_change_turn_number = 100;

if test_chaos_invasion_events then
	lord_of_change_turn_number = 3;
end;



-------------------------------------------------------
--	Initial camera co-ords
--	Should ideally be used for the start/end points 
--	of the intro camera pan
-------------------------------------------------------

cam_start_x = 519.6;				-- camera target x position
cam_start_y = 465.0;				-- camera target y position
cam_start_d = 14.8;					-- camera distance
cam_start_b = 0;					-- camera heading
cam_start_h = 12;					-- camera height

-- intro skip camera
cam_skip_x = 519.4;					-- camera target x position
cam_skip_y = 463.5;					-- camera target y position
cam_skip_d = 10;					-- camera distance
cam_skip_b = 0;						-- camera heading
cam_skip_h = 10;					-- camera height

-- include the intro, prelude and quest chain scripts
cm:load_global_script(local_faction .. "_prelude");

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	This script sets up the default start camera (for a multiplayer game) and
--	the intro cutscene/objective for a playable faction. The filename for this
--	script must match the name of the faction.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

out("campaign script loaded for " .. local_faction);



-------------------------------------------------------
--	Faction Start declaration/config
--	This object decides what to do when the faction
--	is initialised - do we play the cutscene, do we
--	position the camera at the start, or do we do
--	nothing, stuff like that.
--
--	Comment out the line adding the intro cutscene
--	to not play it (not ready for playtesting etc.)
-------------------------------------------------------

fs_player = faction_start:new(local_faction, cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
-- singleplayer initialisation
fs_player:register_new_sp_game_callback(function() faction_new_sp_game_startup() end);
fs_player:register_each_sp_game_callback(function() faction_each_sp_game_startup() end);

-- multiplayer initialisation
fs_player:register_new_mp_game_callback(function() faction_new_mp_game_startup() end);
fs_player:register_each_mp_game_callback(function() faction_each_mp_game_startup() end);

if core:is_tweaker_set("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS") then
	out("Tweaker DISABLE_PRELUDE_CAMPAIGN_SCRIPTS is set so not running any prelude scripts");
else
	fs_player:register_intro_cutscene_callback(function() cutscene_intro_play() end);		-- comment out to not have intro cutscene
end;



-------------------------------------------------------
--	This gets called each time the script restarts,
--	this could be at the start of a new game or
--	loading from a save-game (including coming back
--	from a campaign battle). Don't tamper with it.
-------------------------------------------------------

function start_game_for_faction(should_show_cutscene)
	out("start_game_for_faction() called");
	
	-- starts the playable faction script
	fs_player:start(should_show_cutscene, true);
end;



-------------------------------------------------------
--	This gets called only once - at the start of a 
--	new game. Initialise new game stuff for this 
--	faction here
-------------------------------------------------------

function faction_new_sp_game_startup()
	out("faction_new_sp_game_startup() called");
	
	-- start the Lord of Change intervention
	in_lord_of_change_spawned:start();
end;


function faction_new_mp_game_startup()
	out("faction_new_mp_game_startup() called");
	core:add_listener(
		"set_camera_position_campaign_start",
		"ScriptEventStartGameAllFactionsCompleted",
		true,
		function()
			cm:set_camera_position(cam_start_x, cam_start_y, cam_start_d, cam_start_b, cam_start_h);
		end,
		true
	);
end;





-------------------------------------------------------
--	This gets called any time the game loads in,
--	singleplayer including from a save game and 
--	from a campaign battle. Put stuff that needs
--	re-initialising each campaign load in here
-------------------------------------------------------

function faction_each_sp_game_startup()
	out("faction_each_sp_game_startup() called");
	
	-- should we disable further advice
	if cm:get_saved_value("advice_is_disabled") then
		out.chaos("\tdisabling advice on startup");
		cm:set_advice_enabled(false);
	end;
	
	local event_triggered = cm:get_saved_value("lord_of_change_event_triggered");	
	if event_triggered == nil then cm:set_saved_value("lord_of_change_event_triggered", false) end;
	
	-- once player reaches the turn threshold, attempt to spawn the Lord of Change
	if not event_triggered then	
		core:add_listener(
			"lord_of_change_event",
			"ScriptEventPlayerFactionTurnStart",
			function(context) return cm:model():turn_number() >= lord_of_change_turn_number end,
			function() attempt_to_spawn_lord_of_change() end,
			true
		);
	else
		if cm:get_saved_value("lord_of_change_personality_changed") == nil then monitor_lord_of_change_personality() end;
		
		if cm:get_saved_value("lord_of_change_killed") then
			ci_setup_region_change_listeners("loc", "wh_main_bundle_faction_chaos_everchosen");
		else
			monitor_lord_of_change_defeat();
		end;
	end;
end;


-- try and spawn the Lord of Change with a 2% chance, which increases by 2% on each turn
function attempt_to_spawn_lord_of_change()
	local chance = cm:get_saved_value("lord_of_change_event_roll");
	if chance == nil then chance = 2 end;
	
	local roll = cm:random_number(100);
	
	if test_chaos_invasion_events then
		roll = cm:random_number(1);
	end;
	
	out.chaos("The player is controlling Chaos and has reached the end game event! Rolled a " .. roll .. " with a chance of " .. chance .. " to go to spawn the Lord of Change!");
	
	if roll <= chance then
		core:trigger_event("ScriptEventLordOfChangeSpawn");
	else
		chance = chance + 2;
		cm:set_saved_value("lord_of_change_event_roll", chance);
	end;
end;


in_lord_of_change_spawned = intervention:new(
	"lord_of_change_spawned",													-- string name
	0,																			-- cost
	function() dismiss_advice_before_lord_of_change_event() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);


in_lord_of_change_spawned:add_trigger_condition(
	"ScriptEventLordOfChangeSpawn",
	true
);

in_lord_of_change_spawned:set_suppress_pause_before_triggering(false);
in_lord_of_change_spawned:set_wait_for_event_dismissed(false);


function dismiss_advice_before_lord_of_change_event()
	-- ensure advice is gone
	cm:dismiss_advice();
	
	-- disable advice from this point forward
	ci_disable_further_advice();
		
	cm:callback(function() trigger_lord_of_change_event() end, 0.5);
end;


function trigger_lord_of_change_event()	
	-- show movie
	cm:register_movies("Warhammer/chs_invasion");
	
	local possible_spawn_positions = {
		{774, 612, "wh_main_chaos_wastes"},
		{668, 600, "wh_main_northern_oblast_fort_ostrosk"},
		{530, 653, "wh_main_trollheim_mountains_sarl_encampment"},
		{439, 620, "wh_main_ice_tooth_mountains_doomkeep"},
		{493, 505, "wh_main_middenland_weismund"},
		{645, 481, "wh_main_ostermark_essen"},
		{553, 408, "wh_main_averland_averheim"},
		{407, 401, "wh_main_bastonne_et_montfort_castle_bastonne"},
		{448, 334, "wh_main_carcassone_et_brionne_castle_carcassone"},
		{563, 316, "wh_main_western_border_princes_zvorak"},
		{690, 340, "wh_main_blood_river_valley_varenka_hills"},
		{655, 268, "wh_main_western_badlands_bitterstone_mine"},
		{564, 166, "wh_main_southern_badlands_gor_gazan"},
		{690, 193, "wh_main_blightwater_karak_azgal"},
		{225, 378, "wh2_main_avelorn_tor_saroir"},
		{258, 325, "wh2_main_saphery_port_elistor"},
		{142, 326, "wh2_main_tiranoc_whitepeak"},
		{110, 117, "wh2_main_northern_great_jungle_chaqua"},
		{41, 245, "wh2_main_northern_jungle_of_pahualaxa_shrine_of_sotek"},
		{67, 421, "wh2_main_the_black_coast_bleak_hold_fortress"},
		{126, 638, "wh2_main_the_chill_road_the_great_arena"},
		{496, 41, "wh2_main_great_desert_of_araby_el-kalabad"},
		{694, 57, "wh2_main_shifting_sands_ka-sabar"},
		{871, 54, "wh2_main_southlands_jungle_golden_tower_of_the_gods"}
	};
	
	local char_x = 774;
	local char_y = 612;
	
	-- get the highest ranked general's position
	local highest_ranked_general = cm:get_highest_ranked_general_for_faction(local_faction);

	if highest_ranked_general then
		char_x = highest_ranked_general:logical_position_x();
		char_y = highest_ranked_general:logical_position_y();	
	end;

	local min_distance = 50;
	local closest_distance = 500000;
	local desired_spawn_point = {774, 612};
	
	-- get the closest spawn point to the chosen general
	for i = 1, #possible_spawn_positions do
		local current_distance = distance_squared(char_x, char_y, possible_spawn_positions[i][1], possible_spawn_positions[i][2]);
		if current_distance < closest_distance and current_distance > min_distance then
			closest_distance = current_distance;
			desired_spawn_point = possible_spawn_positions[i];
		end;
	end;
	
	-- get the camera position of the Lord of Change's spawn point to scroll to
	local camera_pos_x, camera_pos_y = cm:log_to_dis(desired_spawn_point[1], desired_spawn_point[2]);
	
	cm:scroll_camera_with_cutscene(
		4,
		function()
			cm:take_shroud_snapshot();
			cm:make_region_visible_in_shroud(local_faction, desired_spawn_point[3]);
			
			spawn_lord_of_change(desired_spawn_point);
		end,
		{camera_pos_x, camera_pos_y, 16.7, 0, 14.0}
	);
end;


function spawn_lord_of_change(desired_spawn_point)	
	-- check that no other character is at the spawn point, otherwise keep offsetting it...
	local x = desired_spawn_point[1];
	local y = desired_spawn_point[2];
	local valid = false
	
	while not valid do
		if is_valid_spawn_point(x, y) then
			valid = true;
		else
			x = x + 1;
			y = y + 1;
		end;
	end;
	
	cm:create_force_with_general(
		chaos_separatists_faction_str,
		ci_get_army_string("chaos", 2),
		"wh_main_goromandy_mountains_baersonlings_camp",
		x,
		y,
		"general",
		"chs_lord_of_change",
		"names_name_2147357518",
		"",
		"names_name_2147357523",
		"",
		true,
		function(cqi)
			char_str = cm:char_lookup_str(cqi);
			
			cm:set_saved_value("lord_of_change_event_triggered", true);
			core:remove_listener("lord_of_change_event");
			
			cm:apply_effect_bundle_to_characters_force("wh_main_bundle_military_upkeep_free_force_special_character", cqi, 0, true);
			cm:set_character_immortality(char_str, true);
			cm:add_agent_experience(char_str, 40, true);
			cm:add_experience_to_units_commanded_by_character(char_str, 5);
			cm:force_add_trait(char_str, "wh_main_trait_name_dummy_the_ever-watcher", true);
			
			cm:force_declare_war(local_faction, chaos_separatists_faction_str, false, false);
			cm:force_diplomacy("faction:" .. local_faction, "faction:" .. chaos_separatists_faction_str, "peace", false, false, true);
		end
	);
	
	-- spawn additional hordes based on the number of armies the player has with more than 5 units
	local chs_faction = cm:get_faction(local_faction);
	local mf_list = chs_faction:military_force_list();
	local chs_armies = 0;
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		
		if current_mf:unit_list():num_items() > 5 then chs_armies = chs_armies + 1 end;
	end;
	
	if chs_armies > 1 then spawn_accompaniment_hordes(chs_armies - 1, x, y) end;
	
	cm:whitelist_event_feed_event_type("scripted_persistent_located_eventevent_feed_target_faction");
	
	cm:callback(
		function()
			cm:show_message_event_located(
				cm:get_local_faction_name(),
				"event_feed_strings_text_wh_event_feed_string_scripted_event_lord_of_change_spawn_primary_detail",
				"",
				"event_feed_strings_text_wh_event_feed_string_scripted_event_lord_of_change_spawn_secondary_detail",
				desired_spawn_point[1],
				desired_spawn_point[2],
				true,
				33
			);
			
			monitor_lord_of_change_personality();
			
			monitor_lord_of_change_defeat();
			
			cm:restore_shroud_from_snapshot();
			
			if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then
				out.chaos("Legendary difficulty - autosaving...");
				cm:autosave_at_next_opportunity();
			end;
			
			in_lord_of_change_spawned:complete();
		end,
		1
	);
end;

function spawn_accompaniment_hordes(num_hordes, loc_x, loc_y)
	if num_hordes > 4 then num_hordes = 4 end;
	
	for i = 1, num_hordes do
		local units = ci_get_army_string("chaos", 2);		
		local x = 0;
		local y = 0;
		
		if i == 1 then
			x = loc_x + 2;
			y = loc_y + 2;
		elseif i == 2 then
			x = loc_x + 2;
			y = loc_y - 2;
		elseif i == 3 then
			x = loc_x - 2;
			y = loc_y + 2;
		else
			x = loc_x - 2;
			y = loc_y - 2;
		end;
		
		if is_valid_spawn_point(x, y) then
			cm:create_force(
				chaos_separatists_faction_str,
				units,
				ci_chaos_home_region,
				x,
				y,
				true,
				function(cqi)
					char_str = cm:char_lookup_str(cqi);
					
					cm:apply_effect_bundle_to_characters_force("wh_main_bundle_military_upkeep_free_force", cqi, 0, true);
					cm:add_agent_experience(char_str, ci_character_xp[2][cm:random_number(3)], true);
				end
			);
		end;
	end;
end;

-- change the AI personality of the Chaos Separatists faction once their army count drops to 1
function monitor_lord_of_change_personality()
	core:add_listener(
		"lord_of_change_personality_switch",
		"FactionTurnStart",
		function(context) return context:faction():name() == chaos_separatists_faction_str end,
		function()
			local faction = cm:get_faction(chaos_separatists_faction_str);
			local mf_list = faction:military_force_list();
			
			if mf_list:num_items() == 1 then
				out.chaos("Chaos Separatists faction has dropped to one army, changing the AI personality");
			
				local difficulty = cm:model():difficulty_level();
				
				if difficulty == -2 or difficulty == -3 then
					cm:force_change_cai_faction_personality(chaos_separatists_faction_str, "wh_chaos_frenzied_hard");
				else
					cm:force_change_cai_faction_personality(chaos_separatists_faction_str, "wh_chaos_separatist_frenzied");
				end;
				
				cm:set_saved_value("lord_of_change_personality_changed", true);
			end;
		end,
		false
	);
end;

function monitor_lord_of_change_defeat()
	core:add_listener(
		"lord_of_change_defeated",
		"BattleCompleted",
		function()
			local loc_faction = cm:get_faction(chaos_separatists_faction_str);
			
			return (loc_faction:faction_leader():is_null_interface() or not loc_faction:faction_leader():has_military_force()) and cm:pending_battle_cache_faction_is_involved(chaos_separatists_faction_str);
		end,
		function(context)			
			local secondary_detail = "event_feed_strings_text_wh_event_feed_string_scripted_event_lord_of_change_defeat_secondary_detail_ai";
			
			if cm:pending_battle_cache_faction_is_involved(local_faction) then secondary_detail = "event_feed_strings_text_wh_event_feed_string_scripted_event_lord_of_change_defeat_secondary_detail" end;
			
			cm:show_message_event(
				cm:get_local_faction_name(),
				"event_feed_strings_text_wh_event_feed_string_scripted_event_lord_of_change_defeat_primary_detail",
				"",
				secondary_detail,
				true,
				34
			);
			
			-- apply a dummy effect bundle - this is just for the sake of player visibility
			cm:apply_effect_bundle("wh_main_bundle_faction_chaos_everchosen", "wh_main_chs_chaos", 0);
			
			-- apply effect bundles to all province capitals that actually give the Chaos corruption effect
			-- if this is done faction wide then provinces can get multiple corruption effects
			local region_list = cm:model():world():region_manager():region_list();

			for i = 0, region_list:num_items() - 1 do
				local current_region = region_list:item_at(i);
				
				if current_region:is_province_capital() then
					local current_region_name = current_region:name();
					
					cm:apply_effect_bundle_to_region("wh_main_bundle_region_chaos_rises", current_region_name, 0);
				end;
			end;
			
			ci_setup_region_change_listeners("loc", "wh_main_bundle_region_chaos_rises");
			
			cm:set_saved_value("lord_of_change_killed", true);
		end,
		false
	);
end;


function faction_each_mp_game_startup()
	out("faction_each_mp_game_startup() called");
end;


-------------------------------------------------------
--	This gets called after the intro cutscene ends,
--	Kick off any missions or similar scripts here
-------------------------------------------------------

function start_faction()
	out("start_faction() called");
	
	if core:is_tweaker_set("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS") then
		out("Tweaker DISABLE_PRELUDE_CAMPAIGN_SCRIPTS is set so not running any prelude scripts");
		return false;
	end;
	
	-- show advisor progress button
	cm:modify_advice(true);
	
	start_chaos_prelude();
	
	if cm:is_multiplayer() == false then
		show_how_to_play_event(local_faction);
	end;
end;


















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

function cutscene_intro_play()

	-- work out who the commander of the player's army is
	local char = cm:get_closest_general_to_position_from_faction(local_faction, 777, 600);

	if not char then
		script_error("WARNING: cutscene_intro_play() couldn't find starting Lord, defaulting to primary choice");
	end;

	local advice_to_play = {};
	
	out("Starting Lord's first name is " .. char:get_forename());
	
	-- Archaeon
	if not char or char:get_forename() == "names_name_2147343903" then
		-- You are the Everchosen - the Chaos Gods call you to action, mighty champion. Their lust for ruin must be sated.
		advice_to_play[1] = "war.camp.prelude.chs.intro.001";
		-- You shall go into the lands of the mortals to spread fear and destruction. The Norse tribes to the west shall fall easily before you: bind those willing to join your cause, and slay the rest.
		advice_to_play[2] = "war.camp.prelude.chs.intro.002";
		-- Further to the south lies the Empire. Their people will resist you, and for good reason. You will bring them their annihilation, mighty Lord.
		advice_to_play[3] = "war.camp.prelude.chs.intro.003";
		-- Devour the mortal souls to bring the favour of the Chaos Gods. March forth, and spread oblivion in their name!
		advice_to_play[4] = "war.camp.prelude.chs.intro.004";
	
	-- Kholek
	elseif char:get_forename() == "names_name_2147345931" then
		-- You have slumbered long, Shaggoth. Arise, mighty Kholek - it is time to bring ruin on the earthly realms!
		advice_to_play[1] = "war.camp.prelude.chs.intro.005";
		-- You shall go into the lands of the mortals to spread fear and destruction. The Norse tribes to the west shall fall easily before you: bind those willing to join your cause, and slay the rest.
		advice_to_play[2] = "war.camp.prelude.chs.intro.002";
		-- Further to the south lies the Empire. Their people will resist you, and for good reason. You will bring them their annihilation, mighty Lord.
		advice_to_play[3] = "war.camp.prelude.chs.intro.003";
		-- Devour the mortal souls to bring the favour of the Chaos Gods. March forth, and spread oblivion in their name!
		advice_to_play[4] = "war.camp.prelude.chs.intro.004";
	
	-- Sigvald
	else
		-- Your adopted father calls you, Sigvald. The Dark Prince desires destruction and perversion of the world. Let it begin!
		advice_to_play[1] = "war.camp.prelude.chs.intro.006";
		-- You shall go into the lands of the mortals to spread fear and destruction. The Norse tribes to the west shall fall easily before you: bind those willing to join your cause, and slay the rest.
		advice_to_play[2] = "war.camp.prelude.chs.intro.002";
		-- Further to the south lies the Empire. Their people will resist you, and for good reason. You will bring them their annihilation, mighty Lord.
		advice_to_play[3] = "war.camp.prelude.chs.intro.003";
		-- Devour the mortal souls to bring the favour of the Chaos Gods. March forth, and spread oblivion in their name!
		advice_to_play[4] = "war.camp.prelude.chs.intro.004";
	end;

	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",							-- string name for this cutscene
		55,													-- length of cutscene in seconds
		function() start_faction() end						-- end callback
	);

	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true, function() cutscene_intro_skipped(advice_to_play) end);
	cutscene_intro:set_skip_camera(cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h);
	cutscene_intro:set_disable_settlement_labels(false);

	cutscene_intro:action(
		function()
			cm:make_region_visible_in_shroud(local_faction, "wh_main_goromandy_mountains_frozen_landing");
			cm:make_region_visible_in_shroud(local_faction, "wh_main_eastern_oblast_volksgrad");
			cm:make_region_visible_in_shroud(local_faction, "wh_main_eastern_oblast_praag");
		
			cm:set_camera_position(519.4, 465.4, 5.6, 0.0, 4.0);
			cutscene_intro:cindy_playback("script/campaign/main_warhammer/factions/wh_main_chs_chaos/scenes/chaos_campaign_intro.CindyScene", 0, 5);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[1]);
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		10
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		11
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		26
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		27
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		41
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		42
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		53
	);
	
	cutscene_intro:start();
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	cm:show_advice(advice_to_play[1]);
	cm:show_advice(advice_to_play[2]);
	cm:show_advice(advice_to_play[3]);
	cm:show_advice(advice_to_play[4]);
	
	cm:callback(function() cm:override_ui("disable_advice_audio", false) end, 0.5);
end;
