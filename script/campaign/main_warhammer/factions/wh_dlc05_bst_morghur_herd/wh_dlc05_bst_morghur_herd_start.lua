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
--	work out who starting general is
-------------------------------------------------------

starting_general_id = 0;		-- undefined

cam_mp_start_x = 266.6;
cam_mp_start_y = 204.8;
cam_mp_start_d = 10;
cam_mp_start_b = 0;
cam_mp_start_h = 10;

if cm:is_new_game() then
	cam_mp_start_x = 339.6;
	cam_mp_start_y = 424.5;
	cam_mp_start_d = 10;
	cam_mp_start_b = 0;
	cam_mp_start_h = 10;
	
	-- Morghur chapter missions
	if not cm:is_multiplayer() then
		chapter_one_mission = chapter_mission:new(1, local_faction, "wh_dlc05_objective_beastmen_main_morghur_01", nil);
		chapter_two_mission = chapter_mission:new(2, local_faction, "wh_dlc05_objective_beastmen_main_morghur_02", nil);
		chapter_three_mission = chapter_mission:new(3, local_faction, "wh_dlc05_objective_beastmen_main_morghur_03", nil);
		chapter_four_mission = chapter_mission:new(4, local_faction, "wh_dlc05_objective_beastmen_main_morghur_04", nil);
		chapter_five_mission = chapter_mission:new(5, local_faction, "wh_dlc05_objective_beastmen_main_morghur_05", nil);
	end;

else
	script_error("ERROR: couldn't determine who starting lord is in Beastmen campaign, starting_general_1 in savegame is " .. tostring(cm:get_saved_value("starting_general_1")) .. " and starting_general_2 is " .. tostring(cm:get_saved_value("starting_general_2")));
end;



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
fs_player = faction_start:new(local_faction, cam_mp_start_x, cam_mp_start_y, cam_mp_start_d, cam_mp_start_b, cam_mp_start_h);
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
			cm:set_camera_position(cam_mp_start_x, cam_mp_start_y, cam_mp_start_d, cam_mp_start_b, cam_mp_start_h);
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
	
	cutscene_intro_play_morghur();

end;	
	


function cutscene_intro_play_morghur()
	
	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro_morghur",					-- string name for this cutscene
		72.5,												-- length of cutscene in seconds
		function() start_faction() end						-- end callback
	);
	
	local advice_to_play = {
		"dlc05.mini.story.morghur.001",
		"dlc05.mini.story.morghur.002",
		"dlc05.mini.story.morghur.003",
		"dlc05.mini.story.morghur.004",
		"dlc05.mini.story.morghur.005"
	};

	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true, function() cutscene_intro_skipped(advice_to_play) end);
	cutscene_intro:set_skip_camera(cam_mp_start_x, cam_mp_start_y, cam_mp_start_d, cam_mp_start_b, cam_mp_start_h);
	cutscene_intro:set_disable_settlement_labels(false);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(false);
			cm:set_camera_position(cam_mp_start_x, cam_mp_start_y, cam_mp_start_d, cam_mp_start_b, cam_mp_start_h);
			cutscene_intro:cindy_playback("script/campaign/main_warhammer/factions/"..local_faction.."/scenes/beastmen_main_flyover_s03_morghur.CindyScene", 0, 5);
		end,
		0
	);
	
	-- "Tduigu-Uis" - a greeting in your tongue, my bestial Lord. I know you feel a yearning to kill me, for I am but a man, but you have received the vision, you know who has sent me… my desire is as yours - to see the Cloven Ones tear down all civilisation! So let us begin...
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
		14.5
	);
	
	-- To the north, past the mystic forest of Athel Loren, is Bretonnia. Arrogant and aloof, its glittering spires a sure sign of self-righteousness. You should bring ruin to this "pretty" realm.
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		15.0
	);
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		28.5
	);
	
	-- East of the Bretonnians lie the Empire, the very pinnacle of mankind's hubris. Its capital, Altdorf, is the centre of power and a symbol of its surety. Reduce it all to rubble - let pandemonium reign. The Empire is powerful, but divided. You must strike soon, for it may yet unify and seek to bring "civilisation" to the blood-grounds.
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		29
	);
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		45.5
	);
	
	-- To the south, the Border Princes hold a tentative grip on all that they call theirs, yet are isolated by the mountains and the Blackfire Pass - soft targets for a hungry herd such as ours.
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		46.0
	);
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		61
	);
	
	-- Destruction is in your blood, Nuis Ghurleth, and the world must know it. Sow as much as you can - the Cloven Ones shall destroy the world of man!
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[5]);
		end,
		61.5
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		72.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_shroud(true);
		end, 
		72.5
	);
	
	cutscene_intro:start();
end;











function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	for i = 1, #advice_to_play do
		cm:show_advice(advice_to_play[i]);
	end;
	
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
	
	start_beastmen_prelude();
	
	if cm:is_multiplayer() == false then
		show_how_to_play_event(local_faction);
	end;
end;