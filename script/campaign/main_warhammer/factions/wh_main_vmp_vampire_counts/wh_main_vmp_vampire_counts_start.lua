


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



-------------------------------------------------------
--	String / position setup
-------------------------------------------------------

castle_drakenhof_region_str = "wh_main_eastern_sylvania_castle_drakenhof";
castle_drakenhof_settlement_str = prepend_settlement_str .. castle_drakenhof_region_str;
castle_drakenhof_province_str = "wh_main_eastern_sylvania";

zhufbar_region_str = "wh_main_zhufbar_zhufbar";
zhufbar_settlement_str = prepend_settlement_str .. zhufbar_region_str;

eschen_region_str = "wh_main_eastern_sylvania_eschen";
eschen_settlement_str = prepend_settlement_str .. eschen_region_str;

schwartzhafen_region_str = "wh_main_western_sylvania_schwartzhafen";
schwartzhafen_settlement_str = prepend_settlement_str .. schwartzhafen_region_str;

castle_templehof_region_str = "wh_main_western_sylvania_castle_templehof";
castle_templehof_settlement_str = prepend_settlement_str .. castle_templehof_region_str;

vampire_counts_faction_str = "wh_main_vmp_vampire_counts";
templehof_faction_str = "wh_main_vmp_rival_sylvanian_vamps";

-- position of (players) vip army in startpos
vip_army_start_x = 682;
vip_army_start_y = 418;

function get_vip_cqi()
	local cqi = cm:get_saved_value("vip_cqi");

	if is_number(cqi) and cqi > 0 then
		return cqi;
	end;
	
	local character = cm:get_closest_general_to_position_from_faction(cm:get_faction(local_faction), vip_army_start_x, vip_army_start_y);
	
	if character then
		cqi = character:cqi();
	else
		cqi = -1;
	end;
	cm:set_saved_value("vip_cqi", cqi);
	
	return cqi;
end;

-- position vip army moves to in first turn
vip_army_move_to_x = 672;
vip_army_move_to_y = 419;

-- position to teleport vip army to if skipping prelude
vip_army_teleport_to_x = 682;
vip_army_teleport_to_y = 417;

-- position of enemy army in startpos
enemy_army_start_x = 664;
enemy_army_start_y = 445;

-- enemy army moves towards player start position at the start of the first turn
enemy_army_move_to_x = 668;
enemy_army_move_to_y = 428;

-- position to teleport enemy army to if skipping prelude
enemy_army_teleport_to_x = 668;
enemy_army_teleport_to_y = 428;


-- this function stores and returns the cqi of the military force
function get_first_enemy_army_cqi()
	local enemy_mf_cqi = cm:get_saved_value("first_enemy_army_cqi");
		
	if not enemy_mf_cqi then
		local character = cm:get_closest_general_to_position_from_faction(cm:get_faction(templehof_faction_str), enemy_army_start_x, enemy_army_start_y);
				
		if character then
			enemy_mf_cqi = character:military_force():command_queue_index();
			cm:set_saved_value("first_enemy_army_cqi", enemy_mf_cqi);
		else
			enemy_mf_cqi = -1;
		end;
	end;
	
	return enemy_mf_cqi;
end;




-------------------------------------------------------
--	Loading of faction scripts (single-player only)
-------------------------------------------------------

local should_load_first_turn = cm:get_saved_value("bool_prelude_should_load_first_turn");

-- load first turn script if required
if should_load_first_turn then
	cm:load_global_script(local_faction .. "_first_turn", true);
end;

-- include prelude missions
cm:load_global_script(local_faction .. "_prelude", true);


-------------------------------------------------------
--	Initial camera co-ords
--	Should ideally be used for the start/end points 
--	of the intro camera pan
-------------------------------------------------------

-- end position of the intro camera
if should_load_first_turn then
	cam_start_x = 460.4;			-- camera target x position
	cam_start_y = 325.9;			-- camera target y position
	cam_start_d = 5.6;				-- camera distance
	cam_start_b = 0;				-- camera heading
	cam_start_h = 4.0;				-- camera height	
else
	-- start position of the intro camera
	cam_start_x = 459.33;			-- camera target x position
	cam_start_y = 330.12;			-- camera target y position
	cam_start_d = 15.58;			-- camera distance
	cam_start_b = 0.0;				-- camera heading
	cam_start_h = 11.94;			-- camera height
end;

-- intro skip camera
cam_skip_x = 459.2;					-- camera target x position
cam_skip_y = 326.1;					-- camera target y position
cam_skip_d = 10;					-- camera distance
cam_skip_b = 0;						-- camera heading
cam_skip_h = 10;					-- camera height









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

out("campaign script loaded for " .. local_faction .. ", should_load_first_turn is " .. tostring(should_load_first_turn));

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
					if should_load_first_turn then
						ft_cutscene_intro_play();
					else
						cutscene_intro_play();
					end;
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
	
	-- first turn only
	if should_load_first_turn then
		set_first_turn_ui_allowed(false, local_faction);
		set_first_turn_resources_bar_allowed(false);
	end;


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
end;


function faction_each_mp_game_startup()
	out("faction_each_mp_game_startup() called");
end;










-------------------------------------------------------
--
--	Startup teleports
--	We have to do this upon the loading of this script
--	as teleporting armies has an adverse effect on the
--	camera and as such we cannot do it later
--
-------------------------------------------------------

-- get VIP character's cqi
vip_cqi = get_vip_cqi();

if cm:is_new_game() and not cm:is_multiplayer() then

	if should_load_first_turn then
		cm:apply_effect_bundle_to_characters_force("wh_main_reduced_movement_range_30", vip_cqi, 1, false);
	else
	
		-- teleport VIP army out to position it would have at the end of the first turn
		cm:teleport_to(cm:char_lookup_str(vip_cqi), vip_army_teleport_to_x, vip_army_teleport_to_y, true);
		
		-- get enemy general
		local enemy_cqi = get_first_enemy_army_cqi();
		local enemy_general = cm:get_character_by_mf_cqi(enemy_cqi);
		local enemy_general_cqi = enemy_general:cqi();
		
		-- teleport enemy army out to position it would have at the end of the first turn
		cm:teleport_to(cm:char_lookup_str(enemy_general_cqi), enemy_army_teleport_to_x, enemy_army_teleport_to_y, true);
	end;
end;





-------------------------------------------------------
--
--	INTRO CUTSCENE
--
--	This function declares and configures the cutscene,
--	loads it with actions and plays it.
--	Customise it to suit.
--
-------------------------------------------------------


function cutscene_intro_play()

	-- work out who the commander of the player's army is
	local char = cm:get_closest_general_to_position_from_faction(local_faction, 691, 419);

	if not char then
		script_error("WARNING: cutscene_intro_play() couldn't find starting Lord, defaulting to primary choice");
	end;

	local advice_to_play = {};
	
	out("Starting Lord's first name is " .. char:get_forename());
	
	-- Mannfred von Carstein
	if not char or char:get_forename() == "names_name_2147343886" then
		-- Castle Drakenhof is back in your hands, my Unliving Sire. Yet you have many enemies - both living and dead - who balk at the threat of a von Carstein reigning from his ancestral stronghold. Much needs to be done.
		advice_to_play[1] = "war.camp.prelude.vmp.intro.001";
		-- The Templehof brood control the lands to the north, as far as the river Stir. Conflict with them is inevitable but your will is indomitable: take their lands, burn their crypts, and deploy their own dead against them!
		advice_to_play[2] = "war.camp.prelude.vmp.intro.002";
		-- The high mountains to the south are infested with Dwarfs. Your homelands will never be safe with such an enemy so close. Make plans to drive their stunted kind out in time.
		advice_to_play[3] = "war.camp.prelude.vmp.intro.003";
		-- The world shall be in thrall to the Karaz Ankor once more, and no creature, Greenskin or otherwise, shall stand in your way!
		advice_to_play[4] = "war.camp.prelude.vmp.intro.004";
	
	-- Heinrich Kemmler
	elseif char:get_forename() == "names_name_2147345320" then
		-- The von Carsteins have risen once again, mighty Lichemaster, and you are to march into the world as their chosen champion. Let them believe you are their willing puppet… for now. There is much to be done.
		advice_to_play[1] = "war.camp.prelude.vmp.intro.005";
		-- The Templehof brood control the lands to the north, as far as the river Stir. Conflict with them is inevitable but your will is indomitable: take their lands, burn their crypts, and deploy their own dead against them!
		advice_to_play[2] = "war.camp.prelude.vmp.intro.002";
		-- The high mountains to the south are infested with Dwarfs. Your homelands will never be safe with such an enemy so close. Make plans to drive their stunted kind out in time.
		advice_to_play[3] = "war.camp.prelude.vmp.intro.003";
		-- A great destiny awaits you, Kemmler, it has been foreseen… Bring about an eternal night and you shall be rewarded!
		advice_to_play[4] = "war.camp.prelude.vmp.intro.006";
	
	-- Vlad von Carstein
	elseif char:get_forename() == "names_name_2147345130" then
		-- Castle Drakenhof is returned to you, Vlad, first of the von Carstein line. Yet despite your ancient and revered power, there are those who would see you undone, and your bloodline erased.
		advice_to_play[1] = "dlc04.camp.Vlad.intro.001";
		-- The Templehof brood control the lands to the north, as far as the River Stir. They defy your hegemony as the first and greatest of the Vampire Counts. Raise the Undead hosts, take their lands, and burn their crypts for this insolence.
		advice_to_play[2] = "dlc04.camp.Vlad.intro.002";
		-- The high mountains to the south are infested with Dwarfs. Your homelands will never be safe with such an enemy so close. Make plans to drive their stunted kind out!
		advice_to_play[3] = "dlc04.camp.Vlad.intro.003";
		-- Greatness runs throughout the von Carstein bloodline, my lord; YOUR greatness. You are the master of Sylvania, of all Unliving and, soon, the world!
		advice_to_play[4] = "dlc04.camp.Vlad.intro.004";
	
	-- Helman Ghorst
	else
		-- Castle Drakenhof is yours, my lord Necromancer - the ancestral home of the von Carsteins. You are the arbiter of their success, and at the vanguard of their conquests.
		advice_to_play[1] = "dlc04.camp.Helman.intro.001";
		-- The Templehof brood control the lands to the north, as far as the River Stir. They cannot be suffered to endure, lest they threaten your strength. Raise your forces, march on the foe, and show them true terror.
		advice_to_play[2] = "dlc04.camp.Helman.intro.002";
		-- The high mountains to the south are infested with Dwarfs. Your homelands will never be safe with such an enemy so close. Make plans to drive their stunted kind out!
		advice_to_play[3] = "dlc04.camp.Helman.intro.004";
		-- Greatness runs throughout the von Carstein bloodline, my lord; YOUR greatness. You are the master of Sylvania, of all Unliving and, soon, the world!
		advice_to_play[4] = "dlc04.camp.Helman.intro.005";
	
	end;

	local cutscene_intro = campaign_cutscene:new(
		local_faction .. "_intro",							-- string name for this cutscene
		61,													-- length of cutscene in seconds
		function() start_faction() end						-- end callback
	);

	--cutscene_intro:set_debug();
	cutscene_intro:set_skippable(true, function() cutscene_intro_skipped(advice_to_play) end);
	cutscene_intro:set_skip_camera(cam_skip_x, cam_skip_y, cam_skip_d, cam_skip_b, cam_skip_h);
	cutscene_intro:set_disable_settlement_labels(false);
	cutscene_intro:set_dismiss_advice_on_end(false);
	
	cutscene_intro:action(
		function()
			cm:make_region_visible_in_shroud(local_faction, eschen_region_str);
			cm:make_region_visible_in_shroud(local_faction, castle_templehof_region_str);
		end,
		0.5
	);
	
	cutscene_intro:action(
		function()
			cm:set_camera_position(458.9, 326.9, 5.59, 0, 4.0);
			cutscene_intro:cindy_playback("script/campaign/main_warhammer/factions/wh_main_vmp_vampire_counts/scenes/vampire_counts_campaign_intro.CindyScene", 0, 5);
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
		16
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[2]);
		end,
		17
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		33
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[3]);
		end,
		34
	);
	
	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		49
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice(advice_to_play[4]);
		end,
		49
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
	
	if cm:is_multiplayer() then
		script_error("ERROR: start_faction() called in multiplayer game, this is not allowed!");
		return false;
	else
		show_how_to_play_event(local_faction);
	end;
	
	-- show advisor progress button
	cm:modify_advice(true);
	
	-- make the campaign manager report that this is turn two
	cm:set_turn_number_modifier(1);
	
	if core:is_tweaker_set("DISABLE_PRELUDE_CAMPAIGN_SCRIPTS") then
		out("Tweaker DISABLE_PRELUDE_CAMPAIGN_SCRIPTS is set so not running any prelude scripts");
		return false;
	end;
	
	start_vampire_counts_prelude(true);
end;