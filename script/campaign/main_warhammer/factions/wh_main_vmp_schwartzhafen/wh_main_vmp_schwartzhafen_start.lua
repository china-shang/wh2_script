-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	Custom script for this faction starts here. The should_load_first_turn is
--	queried to determine whether to load the startup script for the full-prelude
--	first turn or just the standard startup script.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
VLAD_FORENAME = "names_name_2147345130";
ISABELLA_FORENAME = "names_name_2147345124"
SCHWARTZHAFEN_FACTION_NAME = "wh_main_vmp_schwartzhafen"


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

-- start position of the intro camera
cam_start_x = 435.2;					-- camera target x position
cam_start_y = 305.1;					-- camera target y position
cam_start_d = 5.5;						-- camera distance
cam_start_b = 0;						-- camera heading
cam_start_h = 4;						-- camera height

-- intro skip camera
cam_skip_x = 435.2;					-- camera target x position
cam_skip_y = 305.1;					-- camera target y position
cam_skip_d = 5.5;					-- camera distance
cam_skip_b = 0;						-- camera heading
cam_skip_h = 4;						-- camera height

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
	fs_player:register_intro_cutscene_callback(						-- comment out to not have intro cutscene
		function()
			show_benchmark_camera_pan_if_required(
				function()
					cutscene_intro_play();
				end
			);
		end
	);
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
	
	-- put stuff here to be initialised each time a singleplayer game loads
	
	
	-- should we disable further advice
	if cm:get_saved_value("advice_is_disabled") then
		cm:set_advice_enabled(false);
	end;
end;

function faction_each_mp_game_startup()
	out("faction_each_mp_game_startup() called");
	
	-- put stuff here to be initialised each time a multiplayer game loads	
	
	
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
	local char = cm:get_closest_general_to_position_from_faction(local_faction, 650, 399);

	if not char then
		script_error("WARNING: cutscene_intro_play() couldn't find starting Lord, defaulting to primary choice");
	end;

	local advice_to_play = {};
	
	out("Starting Lord's first name is " .. char:get_forename());
	
	-- Vlad von Carstein
	if not char or char:get_forename() == "names_name_2147345130" then
		advice_to_play[1] = "dlc04.camp.Vlad.intro.001";
		advice_to_play[2] = "dlc04.camp.Vlad.intro.002";
		advice_to_play[3] = "dlc04.camp.Vlad.intro.003";
		advice_to_play[4] = "dlc04.camp.Vlad.intro.004";
	
	-- Isabella von Carstein
	else
		advice_to_play[1] = "pro2.camp.Isabella.intro.001";
		advice_to_play[2] = "pro2.camp.Isabella.intro.002";
		advice_to_play[3] = "pro2.camp.Isabella.intro.003";
		advice_to_play[4] = "pro2.camp.Isabella.intro.005";
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
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(false);
			cm:set_camera_position(435.2, 305.1, 5.5, 0.0, 4.0);
			cutscene_intro:cindy_playback("script/campaign/main_warhammer/factions/wh_main_vmp_schwartzhafen/scenes/vlad_main_flyover_s01.CindyScene", 0, 5);
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
		10.5
	);
		
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		27.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		28
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		39.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		40
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		49.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(true);
		end, 
		55
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

-------------------------------------------------------
--	This gets called after the intro cutscene ends,
--	Kick off any missions or similar scripts here
-------------------------------------------------------
function start_faction()
	out("start_faction() called");
	
	-- show advisor progress button
	cm:modify_advice(true);
	
	--add_vlad_isabella_listeners();

	start_vlad_prelude();
	
	if cm:is_multiplayer() == false then
		show_how_to_play_event(local_faction);
	end
end;




