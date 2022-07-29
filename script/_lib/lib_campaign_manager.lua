

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN_MANAGER
--
---	@loaded_in_campaign
---	@class campaign_manager campaign_manager Campaign Manager
--- @alias cm
--- @index_pos 1
--- @desc The campaign manager is the main interface object in the campaign scripting environment. It wraps the primary @episodic_scripting game interface that the campaign model provides to script, as well as providing a myriad of features and quality-of-life improvements in its own right. Any calls made to the <code>campaign manager</code> that it doesn't provide itself are passed through to the @episodic_scripting interface. The is the intended route for calls to the @episodic_scripting interface to be made.
--- @desc Asides from the @episodic_scripting interface provided through the campaign manager, and the campaign manager interface itself (documented below), the main campaign interfaces provided by code are collectively called the model hierarchy. These allow scripts to query the state of the model at any time. See the @"campaign_index:Model Hierarchy" documentation for more information.
--- @desc A campaign manager object, called <code>cm</code> in script, is automatically created when the scripts load in campaign configuration.

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

settlement_prepend_str = "settlement:";

-- __save_counter, used to determine if this is a new game
__save_counter = 0;


function get_cm()
	if core:get_static_object("campaign_manager") then
		return core:get_static_object("campaign_manager");
	else
		script_error("get_cm() called but no campaign manager created as yet");
	end;
end;




campaign_manager = {				-- default values should not be nil, otherwise they'll fail if looked up
	name = "",
	name_is_set = false,
	game_interface = false,
	cinematic_interface = false,
	factions = {},
	game_is_running = false,
	game_destroyed_callbacks = {},
	pre_first_tick_callbacks = {},
	first_tick_callbacks = {},
	first_tick_callbacks_sp_new = {},
	first_tick_callbacks_sp_each = {},
	first_tick_callbacks_mp_new = {},
	first_tick_callbacks_mp_each = {},
	saving_game_callbacks = {},
	post_saving_game_callbacks = {},
	loading_game_callbacks = {},
	game_is_loaded = false,
	is_multiplayer_campaign = false,
	local_faction = "",
	human_factions = {},
	event_panel_auto_open_enabled = true,
	use_cinematic_borders_for_automated_cutscenes = true,
	ui_hiding_enabled = true,
	
	-- save counters
	save_counter = 0,
	
	-- saved value system
	saved_values = {},
	
	-- ui locking
	ui_locked_for_mission = false,
	
	-- advice
	pre_dismiss_advice_callbacks = {},
	PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME = 0.2,
	advice_enabled = true,
	progress_on_advice_dismissed_str = "progress_on_advice_dismissed",
	progress_on_advice_finished_str = "progress_on_advice_finished",
	modify_advice_str = "modify_advice",
	
	-- campaign ui
	campaign_ui_manager = false,
	
	-- timer wrapper
	script_timers = {},
	
	-- move_character data
	move_character_trigger_count = 0,
	move_character_active_list = {},
	
	-- objective and infotext managers
	objectives = false,
	infotext = false,
	
	-- help page manager
	hpm = false,
	
	-- mission managers
	mission_managers = {},
	
	-- turn countdown events
	turn_countdown_events = {},
	
	-- intervention manager
	intervention_manager = false,
	
	-- intervention max cost points per session constant
	campaign_intervention_max_cost_points_per_session = 100,
	
	-- turn number modifier
	turn_number_modifier = 0,
	
	-- records whether we're in a battle sequence - between the pre-battle screen appearing and the camera being returned to player control post-battle
	processing_battle = false,					-- saved into savegame
	processing_battle_completing = false,		-- only set to false when post-battle camera movements are completed
	
	-- diplomacy panel context listener
	diplomacy_panel_context_listener_started = false,
	
	-- faction region change monitor
	faction_region_change_list = {},
	
	-- event feed message suppression
	all_event_feed_messages_suppressed = false,
	
	-- pending battle cache
	pending_battle_cached_attackers = {},
	pending_battle_cached_defenders = {},
	pending_battle_cached_attacker_str = "",
	pending_battle_cached_defender_str = "",
	pending_battle_cached_attacker_value = 1,
	pending_battle_cached_defender_value = 1,
	
	-- cutscene list & debug mode
	cutscene_list = {},
	is_campaign_cutscene_debug = false,
	
	-- scripted subtitles
	subtitles_component_created = false,
	subtitles_visible = false,
	
	-- chapter mission list
	chapter_missions = {},
	
	-- settlement viewpoint bearing overrides
	settlement_viewpoint_bearings = {},
	
	-- cached camera records
	cached_camera_records = {},

	unique_counter_for_missions = 0
};


-- allow campaign_manager to inherit from the game_interface object. If a function is called on the campaign
-- manager which hasn't been explicitly set up, this is passed through to the game_interface object
function campaign_manager:__index(key)
 	local field = rawget(getmetatable(self), key);
	local retval = nil;
		
	if type(field) == "nil" then
		-- key doesn't exist in self, look for it in the prototype object
		local proto = rawget(self, "game_interface");
		
		-- if the prototype object (game_interface) hasn't been set up, then throw an error
		if not proto then
			script_error("ERROR: function called or value looked up [" .. key .. "] on the campaign manager which doesn't exist on the campaign manager object, but before the game_interface is created! This needs to happen after the OnNewSession event! See Steve for details")
			return nil;
		end;
		
		field = proto and proto[key];
		
		if type(field) == "function" then
			-- key exists as a function on the prototype object
			retval = function(obj, ...)
				return field(proto, ...);
			end;
		else
			-- return whatever this key refers to on the prototype object
			retval = field;
		end;
	else
		-- key exists in self
		if type(field) == "function" then
			-- key exists as a function on the self object
			retval = function(obj, ...)
				return field(self, ...);
			end;
		else
			-- return whatever this key refers to on the self object
			retval = field;
		end;
	end;
	
	return retval;
end;


-----------------------------------------------------------------------------
-- tostring and type functions
-----------------------------------------------------------------------------

function campaign_manager:__tostring()
	return TYPE_CAMPAIGN_MANAGER;
end;


function campaign_manager:__type()
	return TYPE_CAMPAIGN_MANAGER;
end;



----------------------------------------------------------------------------
--- @section Creation
--- @desc A campaign manager is automatically created when the script libraries are loaded - see the page on @campaign_script_structure - so there should be no need for client scripts to call @campaign_manager:new themselves. The campaign manager object created is called <code>cm</code>, which client scripts can make calls on.
----------------------------------------------------------------------------


--- @function new
--- @desc Creates and returns a campaign manager. If one has already been created it returns the existing campaign manager. Client scripts should not need to call this as it's already called, and a campaign manager set up, within the script libraries. However the script libraries cannot know the name of the campaign, so client scripts will need to set this using @campaign_manager:set_campaign_name.
--- @p [opt="<unnamed>"] string campaign name
--- @return campaign_manager campaign manager
function campaign_manager:new(name)

	-- see if a campaign manager has already been registered and return it if it has
	local cm = core:get_static_object("campaign_manager");
	if cm then
		return cm;
	end;
	
	-- set a temporary name for the campaign manager if one was not supplied
	local name_is_set = false;
	if name then
		name_is_set = true;
	else
		name = "<unnamed>";
	end;
	
	if not is_string(name) then
		script_error("ERROR: Attempted to create campaign manager but supplied name [" .. tostring(name) .. "] is not a string or nil");
		return false;
	end;
	
	-- set up campaign manager object
	local cm = {};
	
	setmetatable(cm, campaign_manager);
	
	cm.name = name;
	cm.name_is_set = name_is_set;
	cm.factions = {};
	cm.game_is_running = false;
	cm.game_destroyed_callbacks = {};
	cm.pre_first_tick_callbacks = {};
	cm.first_tick_callbacks = {};
	cm.first_tick_callbacks_sp_new = {};
	cm.first_tick_callbacks_sp_each = {};
	cm.first_tick_callbacks_mp_new = {};
	cm.first_tick_callbacks_mp_each = {};
	cm.saving_game_callbacks = {};
	cm.post_saving_game_callbacks = {};
	cm.loading_game_callbacks = {};
	cm.pre_dismiss_advice_callbacks = {};
	cm.script_timers = {};
	cm.move_character_active_list = {};
	cm.hyperlink_click_listeners = {};
	cm.mission_succeeded_callbacks = {};
	cm.saved_values = {};
	cm.mission_managers = {};
	cm.turn_countdown_events = {};
	
	-- tooltip mouseover listeners
	cm.tooltip_mouseover_listeners = {};
	cm.active_tooltip_mouseover_listeners = {};
	
	-- faction region change monitor
	cm.faction_region_change_list = {};
	
	-- cutscene list
	cm.cutscene_list = {};
	
	-- key stealing
	cm.stolen_keys = {};
	cm.user_input_stolen = false;
	cm.escape_key_stolen = false;
	
	-- initialise timer system
	core:add_listener(
		"script_timer_system",
		"CampaignTimeTrigger", 
		true,
		function(context) cm:check_callbacks(context) end, 
		true
	);
	
	-- starts infotext and objectives managers automatically
	cm.infotext = infotext_manager:new();
	cm.objectives = objectives_manager:new();
	-- cm.objectives:set_debug();
	cm.hpm = help_page_manager:new();
	
	-- stops infotext being added if advice is navigated	
	core:add_listener(
		"advice_navigation_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_previous" or context.string == "button_next" end,
		function(context) cm.infotext:cancel_add_infotext() end,
		true
	);
	
	-- start pending battle cache
	cm.pending_battle_cached_attackers = {};
	cm.pending_battle_cached_defenders = {};
	cm.pending_battle_cached_attacker_value = 1;
	cm.pending_battle_cached_defender_value = 1;
	cm:start_pending_battle_cache();
	
	-- list of chapter missions
	cm.chapter_missions = {};
	
	-- cached camera positions
	cm.cached_camera_records = {};
	
	-- overwrite out() with a custom output function for campaign
	getmetatable(out).__call = function(t, input) 		-- t is the 'this' object
		-- support for printing other types of objects
		if not is_string(input) then
			if is_number(input) or is_nil(input) or is_boolean(input) then
				input = tostring(input);
			elseif is_uicomponent(input) then
				out("%%%%% uicomponent (more output on ui tab):");
				out("%%%%% " .. uicomponent_to_str(input));
				output_uicomponent(input);
				return;
			else
				cm:output_campaign_obj(input);
				return;
			end;
		end;
		
		input = input or "";
		
		local timestamp = get_timestamp();
		local output_str = timestamp .. string.format("%" .. 11 - string.len(timestamp) .."s", " ");
		
		-- add in all required tab chars
		for i = 1, out.tab_levels["out"] do
			output_str = output_str .. "\t";
		end;

		output_str = output_str .. input;
		print(output_str);
		
		-- logfile output
		if __write_output_to_logfile then
			local file = io.open(__logfile_path, "a");
			if file then
				file:write("[out] " .. output_str .. "\n");
				file:close();
			end;
		end;
	end;
	
	-- output
	if name_is_set then
		out("Starting campaign manager for " .. name .. " campaign");
	else
		out("Starting campaign manager, name is not currently set");
	end;
	
	-- start listener for the NewSession event
	core:add_listener(
		"campaign_manager_new_session_listener",
		"NewSession",
		true,
		function(context)			
			-- set up proper link to game_interface object
			local game_interface = GAME(context);
			cm.game_interface = game_interface;
			cm.cinematic_interface = game_interface:cinematic();
			
			-- Create a link to the game interface object in the global registry. This is used by autotest scripts (which are also responsible for its deletion)
			_G.campaign_env = core:get_env();
		end,
		true
	);
	
	-- Listen for an event triggered by the core object prior to processing the ui destroyed callbacks.
	core:add_listener(
		"campaign_manager_game_destroyed_listener",
		"ScriptEventPreUIDestroyedCallbacksProcessed",
		true,
		function(context) cm:game_destroyed(context) end,
		false
	);
	
	-- start listener for the WorldCreated event: when it's received, start campaign listeners that must start before the first tick
	core:add_listener(
		"campaign_manager_world_created_listener",
		"WorldCreated",
		true,
		function(context)
			-- start listeners for tracking whether we're processing a battle (SP only).
			-- this has to be done now as some UI panels will open before the first tick
			if not cm.game_interface:model():is_multiplayer() then
				cm:start_processing_battle_listeners();
			end;
			
			-- prevent UI input if this is a new singleplayer game, to prevent players from being able to skip any intro cutscene before it gets a chance to play
			if cm:is_new_game() and not cm.game_interface:model():is_multiplayer() then
				cm:steal_user_input(true);
				
				-- if user input has been stolen then check whether any cutscenes have been registered on the first tick - if none have, then release user input (as no intro cutscene is loaded to do it for us)
				-- (this is a bit of a hack)
				cm:add_first_tick_callback_sp_new(
					function()
						if #self.cutscene_list == 0 then
							cm:steal_user_input(false);
						end
					end
				);
			end;
		end,
		true
	);
	
	
	-- start listener for the FirstTickAfterWorldCreated event: generally used
	-- by users to kick off startup scripts
	core:add_listener(
		"campaign_manager_first_tick_listener",
		"FirstTickAfterWorldCreated",
		true,
		function(context)
			cm:first_tick(context);
		end,
		true
	);
	
	
	-- start listeners for the SavingGame and LoadingGame events
	core:add_listener(
		"campaign_manager_saving_game_listener",
		"SavingGame",
		true,
		function(context)
			cm:saving_game(context);
		end,
		true
	);
	
	core:add_listener(
		"campaign_manager_loading_game_listener",
		"LoadingGame",
		true,
		function(context)
			cm:loading_game(context);
		end,
		true
	);


	-- declare some lookup listeners
	core:declare_lookup_listener(
		"faction_turn_start_listeners_by_name",
		"FactionTurnStart",
		function(context)
			return context:faction():name()
		end
	);

	core:declare_lookup_listener(
		"faction_turn_start_listeners_by_culture",
		"FactionTurnStart",
		function(context)
			return context:faction():culture()
		end
	);

	core:declare_lookup_listener(
		"faction_turn_start_listeners_by_subculture",
		"FactionTurnStart",
		function(context)
			return context:faction():subculture()
		end
	);


	-- register this object as a static object with the core (only one may exist at a time)
	core:add_static_object("campaign_manager", cm);
	
	return cm;
end;









----------------------------------------------------------------------------
--- @section Usage
--- @desc Once created, which happens automatically when the script libraries are loaded, functions on the campaign manager object may be called in the form showed below.
--- @new_example Specification
--- @example cm:<i>&lt;function_name&gt;</i>(<i>&lt;args&gt;</i>)
--- @new_example Creation and Usage
--- @example cm = campaign_manager:new()		-- object automatically set up by script libraries
--- @example 
--- @example -- within campaign script
--- @example cm:set_campaign_name("test_campaign")
----------------------------------------------------------------------------








----------------------------------------------------------------------------
--- @section Campaign Name
--- @desc Client scripts should set a name for the campaign using @campaign_manager:set_campaign_name before making other calls. This name is used for output and for loading campaign scripts.
----------------------------------------------------------------------------


--- @function set_campaign_name
--- @desc Sets the name of the campaign. This is used for some output, but is mostly used to determine the file path to the campaign script folder which is partially based on the campaign name. If the intention is to use @campaign_manager:require_path_to_campaign_folder or @campaign_manager:require_path_to_campaign_faction_folder to load in script files from a path based on the campaign name, then a name must be set first. The name may also be supplied to @campaign_manager:new when creating the campaign manager.
--- @p string campaign name
function campaign_manager:set_campaign_name(name)
	if not is_string(name) then
		script_error("ERROR: set_campaign_name() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	self.name = name;
	self.name_is_set = true;
	out("Campaign name has been set to " .. name);
end;


--- @function get_campaign_name
--- @desc Returns the name of the campaign.
--- @return string campaign name
function campaign_manager:get_campaign_name()
	return self.name;
end;









----------------------------------------------------------------------------
--- @section Loading Campaign Script Files
--- @desc One important role of the campaign manager is to assist in the loading of script files related to the campaign. By current convention, campaign scripts are laid out in the following structure:
--- @desc <table class="simple"><tr><td><code>script/campaign/</code></td><td>scripts related to all campaigns</td></tr><tr><td><code>script/campaign/%campaign_name%/</code></td><td>scripts related to the current campaign</td></tr><tr><td><code>script/campaign/%campaign_name%/factions/%faction_name%/</code></td><td>scripts related to a particular faction in the current campaign (when that faction is being played)</td></tr></table>
--- @desc The functions in this section allow the paths to these script files to be derived from the campaign/faction name, and for scripts to be loaded in. @campaign_manager:load_local_faction_script is the easiest method for loading in scripts related to the local faction. @campaign_manager:load_global_script is a more general-purpose function to load a script with access to the global environment.
----------------------------------------------------------------------------


--- @function get_campaign_folder
--- @desc Returns a static path to the campaign script folder (currently "data/script/campaign")
--- @return string campaign folder path
function campaign_manager:get_campaign_folder()
	return "data/script/campaign";
end;


--- @function require_path_to_campaign_folder
--- @desc Adds the current campaign's folder to the path, so that the lua files related to this campaign can be loaded with the <code>require</code> command. This function adds the root folder for this campaign based on the campaign name i.e. <code>script/campaign/%campaign_name%/</code>, and also the factions subfolder within this. A name for this campaign must have been set with @campaign_manager:new or @campaign_manager:set_campaign_name prior to calling this function.
function campaign_manager:require_path_to_campaign_folder()
	-- don't proceed if no campaign name has been set
	if not self.name_is_set then
		script_error("ERROR: require_path_to_campaign_folder() called but no campaign name set, call set_campaign_name() first");
		return false;
	end;

	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/factions/?.lua" .. ";"
	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/?.lua"
end;


--- @function require_path_to_campaign_faction_folder
--- @desc Adds the player faction's script folder for the current campaign to the lua path (<code>script/campaign/%campaign_name%/factions/%player_faction_name%/</code>), so that scripts related to the faction can be loaded with the <code>require</code> command. Unlike @campaign_manager:require_path_to_campaign_folder this can only be called after the game state has been created. A name for this campaign must have been set with @campaign_manager:new or @campaign_manager:set_campaign_name prior to calling this function.
function campaign_manager:require_path_to_campaign_faction_folder()
	-- don't proceed if no campaign name has been set
	if not self.name_is_set then
		script_error("ERROR: require_path_to_campaign_folder() called but no campaign name set, call set_campaign_name() first");
		return false;
	end;
	
	if not self.game_is_running then
		script_error("ERROR: require_path_to_campaign_folder() called but game has not yet been created - call this later in the load sequence");
		return false;
	end;

	local local_faction = self:get_local_faction_name(true);
	
	if not local_faction then
		script_error("ERROR: require_path_to_campaign_faction_folder() called but no local faction could be found - has it been called too early during the load sequence, or during an autotest?");
		return false;
	end;

	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/factions/" .. local_faction .. "/?.lua" .. ";"
end;


--- @function load_global_script
--- @desc This function attempts to load a lua script from all folders currently on the path, and, when loaded, sets the environment of the loaded file to match the global environment. This is used when loading scripts within a block (within if statement that is testing for the file's existence, for example) - loading the file with <code>require</code> would not give it access to the global environment.
--- @desc Call @campaign_manager:require_path_to_campaign_folder and/or @campaign_manager:require_path_to_campaign_faction_folder if required to include these folders on the path before loading files with this function, if required. Alternatively, use @campaign_manager:load_local_faction_script for a more automated method of loading local faction scripts.
--- @desc If the script file fails to load cleanly, a script error will be thrown.
--- @p string script name
--- @p [opt=false] boolean single player only

--- @new_example Loading faction script
--- @desc This script snippet requires the path to the campaign faction folder, then loads the "faction_script_loader" script file, when the game is created.
--- @example cm:add_pre_first_tick_callback(
--- @example 	function()	
--- @example 		if cm:get_local_faction_name(true) then
--- @example 			cm:require_path_to_campaign_faction_folder();
--- @example 
--- @example 			if cm:load_global_script("faction_script_loader") then
--- @example 				out("Faction scripts loaded");
--- @example 			end;
--- @example 		end;
--- @example 	end
--- @example );
--- @result Faction scripts loaded 
function campaign_manager:load_global_script(scriptname, single_player_only)

	if single_player_only and self:is_multiplayer() then
		return false;
	end;

	if package.loaded[scriptname] then
		return package.loaded[scriptname];
	end;
	
	local package_path = string.gsub(scriptname, "%.", "/");
	local file = loadfile(package_path);
	
	if file then
		-- the file has been loaded correctly - set its environment, record that it's been loaded, then execute it
		out("Loading script " .. scriptname .. ".lua");
		out.inc_tab();
		
		setfenv(file, core:get_env());
		local lua_module = file(scriptname);
		package.loaded[scriptname] = lua_module or true;
		
		out.dec_tab();
		out(scriptname .. ".lua script loaded");
		return package.loaded[scriptname];
	end;
	
	-- the file was not loaded correctly, however loadfile doesn't tell us why. Here we try and load it again with require which is more verbose
	local success, err_code = pcall(function() require(scriptname) end);

	script_error("ERROR: Tried to load script " .. scriptname .. " without success - either the script is not present or it is not valid. See error below");
	out("*************");
	out("Returned lua error is:");
	out(err_code);
	out("*************");

	return false;
end;


--- @function load_local_faction_script
--- @desc Loads a script file in the factions subfolder that corresponds to the name of the local player faction, with the supplied string appellation attached to the end of the script filename. This function is the preferred method for loading in local faction-specific script files. It calls @campaign_manager:require_path_to_campaign_faction_folder internally to set up the path, and uses @campaign_manager:load_global_script to perform the loading. It must not be called before the game is created.
--- @p string script name appellation
--- @new_example
--- @desc Assuming a faction named <code>fact_example</code> in a campaign named <code>main_test</code>, the following script would load in the script file <code>script/campaigns/main_test/factions/fact_example/fact_example_start.lua</code>.
--- @example cm:add_pre_first_tick_callback(
--- @example 	function()
--- @example 		cm:load_local_faction_script("_start");
--- @example 	end
--- @example );
function campaign_manager:load_local_faction_script(name_appellation, single_player_only)

	if name_appellation then
		if not is_string(name_appellation) then
			script_error("ERROR: load_local_faction_script() called but supplied name appellation [" .. tostring(name_appellation) .. "] is not a string");
			return false;
		end;
	else
		name_appellation = "";
	end;
	
	local local_faction = self:get_local_faction_name(true);
	
	if not local_faction then
		out("Not loading local faction scripts as no local faction could be determined");
		return false;
	end;
	
	-- include path to scripts in script/campaigns/<campaign_name>/factions/<faction_name>/* associated with this campaign/faction
	self:require_path_to_campaign_faction_folder();
	
	local script_name = local_faction .. name_appellation;
	
	out("Loading faction script " .. script_name .. " for faction " .. local_faction);
	
	out.inc_tab();
	
	-- faction scripts loaded here - function will return true if the load succeeded
	if self:load_global_script(script_name, single_player_only) then
		out.dec_tab();
		out("Faction scripts loaded");
	else
		out.dec_tab();
	end;
end;


--- @function load_exported_files
--- @desc Loads all lua script files with filenames that contain the supplied string from the target directory. This is used to load in exported files e.g. export_ancillaries.lua, as the asset graph system may create additional files with an extension of this name for each DLC, where needed (e.g. export_ancillaries_dlcxx.lua). The target directory is "script" by default.
--- @p string filename, Filename subset of script file(s) to load.
--- @p [opt="script"] string path, Path of directory to load script files from, from working data. This should be supplied without leading or trailing "/" separators.
--- @new_example
--- @desc Assuming a faction named <code>fact_example</code> in a campaign named <code>main_test</code>, the following script would load in the script file <code>script/campaigns/main_test/factions/fact_example/fact_example_start.lua</code>.
--- @new_example
--- @desc Loads all script files from the "script" folder which contain "export_triggers" as a subset of their name.
--- @example cm:load_exported_files("export_triggers")
function campaign_manager:load_exported_files(filename, path_str)

	if not is_string(filename) then
		script_error("ERROR: load_exported_files() called but no string filename supplied");
		return false;
	end;
	
	if path_str and not is_string(path_str) then
		script_error("ERROR: load_exported_files() called but supplied path [" .. tostring(path_str) .. "] is not a string");
		return false;
	end;
	
	path_str = path_str or "script";
	package.path = package.path .. ";" .. path_str .. "/?.lua;";
	
	local all_files_str = self.game_interface:filesystem_lookup("/" .. path_str .. "/", filename .. "*.lua");
	
	if not is_string(all_files_str) or string.len(all_files_str) == 0 then
		script_error("WARNING: load_exported_files() couldn't find any files with supplied name " .. filename);
		return;
	end;
	
	local files_to_load = {};
	local pointer = 1;
	
	while true do
		local next_separator = string.find(all_files_str, ",", pointer);
		
		if not next_separator then
			-- this is the last entry
			table.insert(files_to_load, string.sub(all_files_str, pointer));
			break;
		end;
		
		table.insert(files_to_load, string.sub(all_files_str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
		
	-- strip the path off the start and the .lua off the end
	for i = 1, #files_to_load do
		local current_str = files_to_load[i];
			
		-- find the last '\' or '/' character
		local pointer = 1;
		while true do
			local next_separator = string.find(current_str, "\\", pointer) or string.find(current_str, "/", pointer);
			
			if next_separator then
				pointer = next_separator + 1;
			else
				-- this is the last separator
				if pointer > 1 then
					current_str = string.sub(current_str, pointer);
				end;
				break;
			end;
		end;
			
		-- remove the .lua suffix, if any
		local suffix = string.sub(current_str, string.len(current_str) - 3);
		
		if string.lower(suffix) == ".lua" then
			current_str = string.sub(current_str, 1, string.len(current_str) - 4);
		end;
		
		files_to_load[i] = current_str;
		
		out.inc_tab();
		self:load_global_script(current_str);
		out.dec_tab();
	end;	
end;










----------------------------------------------------------------------------
--- @section Loading Game
--- @desc Early in the campaign loading sequence the <code>LoadingGame</code> event is triggered by the game code, even when starting a new game. At this time, scripts are able to load script values saved into the savegame using @campaign_manager:load_named_value. These values can then be used by client scripts to set themselves into the correct state.
--- @desc Functions that perform the calls to @campaign_manager:load_named_value may be registered with @campaign_manager:add_loading_game_callback, so that they get called when the <code>LoadingGame</code> event is triggered.
--- @desc The counterpart function to @campaign_manager:load_named_value is @campaign_manager:save_named_value, which is used when the game saves to save values to the save file.
--- @desc See also @campaign_manager:set_saved_value and @campaign_manager:get_saved_value, which can be used at any time by client scripts to read and write values that will automatically saved and loaded to the save game.
--- @desc In the game loading sequence, the <code>LoadingGame</code> event is received before the game is created and the first tick.

--- @example cm:add_loading_game_callback(
--- @example	function(context)
--- @example		player_progression = cm:load_named_value("player_progression", 0, context);
--- @example 	end
--- @example )
----------------------------------------------------------------------------

--- @function add_loading_game_callback
--- @desc Adds a callback to be called when the <code>LoadingGame</code> event is received from the game. This callback will be able to load information from the savegame with @campaign_manager:load_named_value. See also @campaign_manager:add_saving_game_callback and @campaign_manager:save_named_value to save the values that will be loaded here.
--- @desc Note that it is preferable for client scripts to use this function rather than listen for the <code>LoadingGame</code> event themselves as it preserves the ordering of certain setup procedures.
--- @p function callback, Callback to call. When calling this function the campaign manager passes it a single context argument, which can then be passed through in turn to @campaign_manager:load_named_value.
function campaign_manager:add_loading_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_loading_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.loading_game_callbacks, callback);
end;
	

-- called internally when the LoadingGame event is received
function campaign_manager:loading_game(context)
	local counter = core:get_unique_counter();

	out("");
	out("********************************************************************************");
	out(self.name .. " event has occurred:: LoadingGame");
	out("\toutput is shown on the savegame console spool - unique counter for this output is [" .. counter .. "]");

	out.cache_tab("savegame");
	out.savegame("");
	out.savegame("********************************************************************************");
	out.savegame(self.name .. " event has occurred:: LoadingGame");
	out.inc_tab("savegame");
	out.savegame("unique counter for this output is [" .. counter .. "]");
	
	self.game_is_loaded = true;
	
	-- loading library values
	self.save_counter = self:load_named_value("__save_counter", 0, context);
	
	-- only perform these actions if this is not a new game
	if not self:is_new_game() then
		self.processing_battle = self:load_named_value("is_processing_battle", false, context);
		
		self:load_values_from_string(self:load_named_value("saved_values", "", context));
		
		-- set up the help page manager even if the tweaker disabling scripts is set
		self.hpm:load_history_from_string(self:load_named_value("help_page_history", "", context));		
		
		local mission_managers_str = self:load_named_value("mission_managers", "", context);
		local intervention_manager_state_str = self:load_named_value("intervention_manager_state", "", context);
		
		-- load pending battle cache strings and then build the tables from them
		self.pending_battle_cached_attacker_str = self:load_named_value("pending_battle_cached_attacker_str", "", context);
		self.pending_battle_cached_defender_str = self:load_named_value("pending_battle_cached_defender_str", "", context);
	
		self:pending_battle_cache_from_string();
		
		self:turn_countdown_events_from_string(self:load_named_value("turn_countdown_events", "", context));
		self:faction_region_change_monitor_from_str(self:load_named_value("faction_region_change_monitor", "", context));
		
		self.pending_battle_cached_attacker_value = self:load_named_value("pending_battle_cached_attacker_value", 0, context);
		self.pending_battle_cached_defender_value = self:load_named_value("pending_battle_cached_defender_value", 0, context);
				
		self:add_first_tick_callback(
			function()
				self:mission_managers_from_string(mission_managers_str);
				self:get_intervention_manager():state_from_string(intervention_manager_state_str);
			end
		);
	end;
	
	-- invasion manager state
	load_invasion_manager(context);
	
	-- process loading game callbacks
	for i = 1, #self.loading_game_callbacks do
		self.loading_game_callbacks[i](context);
	end;
	
	out.dec_tab("savegame");
	out.savegame("********************************************************************************");
	out.savegame("");
	out.restore_tab("savegame");
	
	out("********************************************************************************");
	out("");
end;


--- @function load_named_value
--- @desc Loads a named value from the savegame. This may only be called as the game is being loaded, and must be passed the context object supplied by the <code>LoadingGame</code> event. Values are saved and loaded from the savegame with a string name, and the values themselves can be a boolean, a number, a string, or a table containing booleans, numbers or strings.
--- @p string value name, Value name. This must be unique within the savegame, and should match the name the value was saved with, with @campaign_manager:save_named_value.
--- @p object default value, Default value, in case the value could not be loaded from the savegame. The default value supplied here is used to determine/must match the type of the value being loaded.
--- @p userdata context, Context object supplied by the <code>LoadingGame</code> event.
function campaign_manager:load_named_value(name, default, context)
	if not is_string(name) then
		script_error("ERROR: load_named_value() called but supplied value name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if default == nil then
		script_error("ERROR: load_named_value() called but no default value supplied");
		return false;
	end;
	
	if not context then
		script_error("ERROR: load_named_value() called but no context supplied");
		return false;
	end;
	
	if type(default) == "table" then
		local tableSaveState = self.game_interface:load_named_value(name, "", context);
		
		-- check that we have a value to convert to a table
		if tableSaveState then
			local table_func = loadstring(tableSaveState);
			
			if is_function(table_func) then
				local retval = table_func();
				if is_table(retval) then
					out.savegame("Loading value " .. name .. " [" .. tostring(retval) .. "]");
					return retval;
				end;
			end;
		end;
		
		return default;
	else
		local retval = self.game_interface:load_named_value(name, default, context);
		out.savegame("Loading value " .. name .. " [" .. tostring(retval) .. "]");
		return retval;
	end
end;


--- @function get_saved_value
--- @desc Retrieves a value saved using the saved value system. Values saved using @campaign_manager:set_saved_value are added to an internal register within the campaign manager, and are automatically saved and loaded with the game, so there is no need to register callbacks with @campaign_manager:add_loading_game_callback or @campaign_manager:add_saving_game_callback. Once saved with @campaign_manager:set_saved_value, values can be accessed with this function.
--- @desc Values are stored and accessed by a string name. Values can be booleans, numbers or strings.
--- @p string value name
--- @return object value
function campaign_manager:get_saved_value(name)
	return self.saved_values[name];
end;


--- @function get_cached_value
--- @desc Retrieves or generates a value saved using the saved value system. When called, the function looks up a value by supplied name using @campaign_manager:get_saved_value. If it exists it is returned, but if it doesn't exist a supplied function is called which generates the cached value. This value is saved with the supplied name, and also returned. A value is generated the first time this function is called, therefore, and is retrieved from the savegame on subsequent calls with the same arguments. If the supplied function doesn't return a value, a script error is triggered.
--- @p string value name
--- @p function generator callback
--- @return object value
function campaign_manager:get_cached_value(saved_value_name, generator_callback)
	if not is_string(saved_value_name) then
		script_error("ERROR: get_cached_value() called but supplied saved value name [" .. tostring(saved_value_name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(generator_callback) then
		script_error("ERROR: get_cached_value() called but supplied generator callback [" .. tostring(generator_callback) .. "] is not a function");
		return false;
	end;
	
	local saved_value = self:get_saved_value(saved_value_name);

	if not is_nil(saved_value) then
		return saved_value;
	end;
	
	saved_value = generator_callback();
	
	if is_nil(saved_value) then
		script_error("ERROR: get_cached_value() generator callback did not return a valid value, returned value is [" .. tostring(saved_value) .. "]");
	else
		self:set_saved_value(saved_value_name, saved_value);
	end;
	
	return saved_value;
end;


-- called internally when the game loads, to load values saved with set_saved_value
function campaign_manager:load_values_from_string(str)
	if not is_string(str) then
		script_error("ERROR: load_values_from_string() called but supplied string [" .. tostring(str) .. "] is not a string");
		return false;
	end;

	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, ":", pointer);
		
		if not next_separator then
			break;
		end;
		
		local value_name = string.sub(str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(str, ":", pointer);
		
		if not next_separator then
			script_error("ERROR: load_values_from_string() called but supplied str is malformed: " .. str);
			return false;
		end;
		
		local value_type = string.sub(str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(str, ":", pointer);
		
		if not next_separator then
			script_error("ERROR: load_values_from_string() called but supplied str is malformed: " .. str);
			return false;
		end;
		
		local value_length = string.sub(str, pointer, next_separator - 1);
		local num_value_length = tonumber(value_length);
		
		if not num_value_length then
			script_error("ERROR: load_values_from_string() called, but retrieved value_length [" .. tostring(value_length) .. "] could not be converted to a number in string: " .. str);
			return false;
		end;
		
		pointer = next_separator + 1;
		
		local value = string.sub(str, pointer, pointer + num_value_length - 1);
		
		if value_type == "boolean" then
			if value == "true" then
				value = true;
			else
				value = false;
			end;
		elseif value_type == "number" then
			local value_number = tonumber(value);
			
			if not value_number then
				script_error("ERROR: load_values_from_string() called, but couldn't convert loaded numeric value [" .. value .. "] to a number in string: " .. str);
				return false;
			else
				value = value_number;
			end;
		elseif value_type ~= "string" then
			script_error("ERROR: load_values_from_string() called, but couldn't recognise supplied value type [" .. tostring(value_type) .. "] in string: " .. str);
			return false;
		end;
		
		pointer = pointer + num_value_length + 1;
		
		self:set_saved_value(value_name, value);
	end;
end;













-----------------------------------------------------------------------------
--- @section Saving Game
--- @desc These are the complementary functions to those in the @"campaign_manager:Loading Game" section. When the player saves the game, the <code>SavingGame</code> event is triggered by the game. At this time, variables may be saved to the savegame using @campaign_manager:save_named_value. Callbacks that make calls to this function may be registered with @campaign_manager:add_saving_game_callback, so that they get called at the correct time.
-----------------------------------------------------------------------------


--- @function add_saving_game_callback
--- @desc Registers a callback to be called when the game is being saved. The callback can then save individual values with @campaign_manager:save_named_value.
--- @p function callback, Callback to call. When calling this function the campaign manager passes it a single context argument, which can then be passed through in turn to @campaign_manager:save_named_value.
function campaign_manager:add_saving_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_saving_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.saving_game_callbacks, callback);
end;


--- @function add_post_saving_game_callback
--- @desc Add a callback to be called after the game has been saved. These callbacks are called last in the saving sequence, and only the first time the game is saved after they have been added.
--- @p function callback, Callback to call. When calling this function the campaign manager passes it a single context argument.
function campaign_manager:add_post_saving_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_post_saving_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.post_saving_game_callbacks, callback);
end;
	
	
-- called internally when the game saves
function campaign_manager:saving_game(context)
	local counter = core:get_unique_counter();

	out("");
	out("********************************************************************************");
	out(self.name .. " event has occurred:: SavingGame");
	out("\toutput is shown on the savegame console spool - unique counter for this output is [" .. counter .. "]");

	out.cache_tab("savegame");
	out.savegame("");
	out.savegame("********************************************************************************");
	out.savegame(self.name .. " event has occurred:: SavingGame");
	out.inc_tab("savegame");
	out.savegame("unique counter for this output is [" .. counter .. "]");
	
	-- increment the save_counter value
	self.save_counter = self.save_counter + 1;
	
	-- saving library values
	self:save_named_value("__save_counter", self.save_counter, context);
	self:save_named_value("saved_values", self:saved_values_to_string(), context);
	self:save_named_value("mission_managers", self:mission_managers_to_string(), context);
	self:save_named_value("intervention_manager_state", self:get_intervention_manager():state_to_string(), context);
	self:save_named_value("turn_countdown_events", self:turn_countdown_events_to_string(), context);
	self:save_named_value("faction_region_change_monitor", self:faction_region_change_monitor_to_str(), context);
	self:save_named_value("help_page_history", self.hpm:help_page_history_to_string(), context);	
	self:save_named_value("is_processing_battle", self.processing_battle, context);
	
	-- generate pending battle cache strings
	self:pending_battle_cache_to_string();
	self:save_named_value("pending_battle_cached_attacker_str", self.pending_battle_cached_attacker_str, context);
	self:save_named_value("pending_battle_cached_defender_str", self.pending_battle_cached_defender_str, context);
	self:save_named_value("pending_battle_cached_attacker_value", self.pending_battle_cached_attacker_value, context);
	self:save_named_value("pending_battle_cached_defender_value", self.pending_battle_cached_defender_value, context);
	
	-- invasion manager state
	save_invasion_manager(context);
	
	-- process saving game callbacks
	for i = 1, #self.saving_game_callbacks do
		self.saving_game_callbacks[i](context);
	end;
	
	out.dec_tab("savegame");
	out.savegame("********************************************************************************");
	out.savegame("");
	out.restore_tab("savegame");

	out("********************************************************************************");
	out("");
	
	-- process post-saving game callbacks
	for i = 1, #self.post_saving_game_callbacks do
		self.post_saving_game_callbacks[i](context);
	end;
	
	-- make sure post-saving-game callbacks only happen once
	self.post_saving_game_callbacks = {};
end;


--- @function save_named_value
--- @desc Saves a named value from the savegame. This may only be called as the game is being saved, and must be passed the context object supplied by the <code>SavingGame</code> event. Values are saved (and loaded) from the savegame with a string name, and the values themselves can be a boolean, a number, a string, or a table containing booleans, numbers or strings.
--- @p string value name, Value name. This must be unique within the savegame, and will be used by @campaign_manager:load_named_value later to load the value.
--- @p object value, Value to save.
--- @p userdata context, Context object supplied by the <code>SavingGame</code> event.
function campaign_manager:save_named_value(name, value, context)
	if not is_string(name) then
		script_error("ERROR: save_named_value() called but supplied value name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if value == nil then
		script_error("ERROR: save_named_value() called but no value supplied");
		return false;
	end;
	
	if not context then
		script_error("ERROR: save_named_value() called but no context supplied");
		return false;
	end;
	
	if type(value) == "table" then
		out.savegame("Saving table " .. name .. " [" .. tostring(value) .. "]");
		
		local tableSaveState = "return {" .. self:process_table_save(value) .. "}";
		self.game_interface:save_named_value(name, tableSaveState, context);
	else
		out.savegame("Saving value " .. name .. " [" .. tostring(value) .. "]");
		self.game_interface:save_named_value(name, value, context);
	end
end;


-- called internally when a table needs to be saved
function campaign_manager:process_table_save(tab, savestring)
	savestring = savestring or "";
	local key, val = next(tab, nil);

	while key do	
		if type(val) == "table" then
			if type(key) == "string" then
				savestring = savestring.."[\""..key.."\"]={";
			else
				savestring = savestring.."{";
			end

			savestring = self:process_table_save(val, savestring);
			savestring = savestring.."},";
		elseif type(val) ~= "function" then
			local pref = "";
			
			if type(key) == "string" then
				if tab[key] == nil then
					pref = key.."=";
				else
					pref = "[\""..key.."\"]=";
				end
			end
			
			if type(val) == "string" then
				savestring = savestring..pref.."\""..val.."\",";
			else
				savestring = savestring..pref..tostring(val)..",";
			end
		end

		key, val = next(tab, key);
	end
	return savestring;
end


--- @function set_saved_value
--- @desc Sets a value to be saved using the saved value system. Values saved using this function are added to an internal register within the campaign manager, and are automatically saved and loaded with the game, so there is no need to register callbacks with @campaign_manager:add_loading_game_callback or @campaign_manager:add_saving_game_callback. Once saved with this function, the value can be accessed at any time with @campaign_manager:get_saved_value.
--- @desc Values are stored and accessed by a string name. Values can be booleans, numbers or strings. Repeated calls to set_saved_value with the same name are legal, and will just overwrite the value of the value stored with the supplied name.
--- @p string value name, Value name.
--- @p object value, Value. Can be a boolean, number or string.
function campaign_manager:set_saved_value(name, value)
	if not is_string(name) then
		script_error("ERROR: set_saved_value() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if string.find(name, ":") then
		script_error("ERROR: set_saved_value() called but supplied name [" .. name .. "] contains a : character, this is illegal");
		return false;
	end;
	
	if not is_boolean(value) and not is_number(value) and not is_string(value) then
		script_error("ERROR: set_saved_value() called but supplied value [" .. tostring(name) .. "] is not a boolean, a number or a string");
		return false;
	end;
	
	self.saved_values[name] = value;
end;


-- internal function for creating string from all saved values when saving
function campaign_manager:saved_values_to_string()
	local str = "";
	local saved_values = self.saved_values;
	
	for value_name, value in pairs(saved_values) do
		str = str .. value_name .. ":" .. type(value) .. ":" .. string.len(tostring(value)) .. ":" .. tostring(value) .. ";"
	end;
	return str;
end;


--- @function save
--- @desc Instructs the campaign game to save at the next opportunity. An optional completion callback may be supplied.
--- @p [opt=nil] function callback, Completion callback. If supplied, this is called when the save procedure is completed.
--- @p [opt=false] boolean lock afterwards, Lock saving functionality after saving is completed.
function campaign_manager:save(callback, lock_afterwards)
	self:disable_saving_game(false);
	self:add_post_saving_game_callback(
		function()
			if lock_afterwards then
				self:disable_saving_game(true);
			end;
			if is_function(callback) then
				callback();
			end;
		end
	);
	self:autosave_at_next_opportunity();
end;


















----------------------------------------------------------------------------
--- @section Game Destroyed
----------------------------------------------------------------------------


--- @function add_game_destroyed_callback
--- @desc Registers a function to be called when the campaign is shut down or unloaded for any reason (including loading into battle). It is seldom necessary to do this.
--- @p function callback
function campaign_manager:add_game_destroyed_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_game_destroyed_callback called but supplied callback [" .. tostring(callback) .. "] is not a function");
	end;
	
	table.insert(self.game_destroyed_callbacks, callback);
end;


function campaign_manager:game_destroyed(context)
	out.cache_tab();
	out("");
	out("********************************************************************************");
	out(self.name .. " :: game is being destroyed");
	out.inc_tab();
	
	-- clean up link to self on _G
	_G.cm = nil;
	
	self:process_game_destroyed_callbacks(context);
	
	out.dec_tab();
	out("********************************************************************************");
	out("");
	out.restore_tab();
end;


function campaign_manager:process_game_destroyed_callbacks(context)
	for i = 1, #self.game_destroyed_callbacks do
		self.game_destroyed_callbacks[i](context);
	end;
end;













----------------------------------------------------------------------------
--- @section First Tick
--- @desc The <code>FirstTickAfterWorldCreated</code> event is triggered by the game model when loading is complete and it starts to run time forward. At this point, the game can be considered "running". The campaign manager offers a suite of functions, listed in this section, which allow registration of callbacks to get called when the first tick occurs in a variety of situations e.g. new versus loaded campaign, singleplayer versus multiplayer etc.
--- @desc Callbacks registered with @campaign_manager:add_pre_first_tick_callback are called before any other first-tick callbacks. Next to be called are callbacks registered for a new game with @campaign_manager:add_first_tick_callback_new, @campaign_manager:add_first_tick_callback_sp_new or @campaign_manager:add_first_tick_callback_mp_new, which are called before each-game callbacks registered with @campaign_manager:add_first_tick_callback_sp_each or @campaign_manager:add_first_tick_callback_mp_each. Last to be called are global first-tick callbacks registered with @campaign_manager:add_first_tick_callback.
--- @desc Note that when the first tick occurs the loading screen is likely to still be on-screen, so it may be prudent to stall scripts that wish to display things on-screen with @core:progress_on_loading_screen_dismissed.
----------------------------------------------------------------------------


--- @function add_pre_first_tick_callback
--- @desc Registers a function to be called before any other first tick callbacks. Callbacks registered with this function will be called regardless of what mode the campaign is being loaded in.
--- @p function callback
function campaign_manager:add_pre_first_tick_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_pre_first_tick_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.pre_first_tick_callbacks, callback);
end;


--- @function add_first_tick_callback
--- @desc Registers a function to be called when the first tick occurs. Callbacks registered with this function will be called regardless of what mode the campaign is being loaded in.
--- @p function callback
function campaign_manager:add_first_tick_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks, callback);
end;


--- @function add_first_tick_callback_sp_new
--- @desc Registers a function to be called when the first tick occurs in a new singleplayer game.
--- @p function callback
function campaign_manager:add_first_tick_callback_sp_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_sp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_new, callback);
end;


--- @function add_first_tick_callback_sp_each
--- @desc Registers a function to be called when the first tick occurs in a singleplayer game, whether new or loaded from a savegame.
--- @p function callback
function campaign_manager:add_first_tick_callback_sp_each(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_sp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_each, callback);
end;


--- @function add_first_tick_callback_mp_new
--- @desc Registers a function to be called when the first tick occurs in a new multiplayer game.
--- @p function callback
function campaign_manager:add_first_tick_callback_mp_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_mp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_mp_new, callback);
end;


--- @function add_first_tick_callback_mp_each
--- @desc Registers a function to be called when the first tick occurs in a multiplayer game, whether new or loaded from a savegame.
--- @p function callback
function campaign_manager:add_first_tick_callback_mp_each(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_mp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_mp_each, callback);
end;


--- @function add_first_tick_callback_new
--- @desc Registers a function to be called when the first tick occurs in a new game, whether singleplayer or multiplayer.
--- @p function callback
function campaign_manager:add_first_tick_callback_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_new, callback);
	table.insert(self.first_tick_callbacks_mp_new, callback);
end;
	

-- called internally when first tick occurs
function campaign_manager:first_tick(context)
	out.cache_tab();
	out("");
	out("********************************************************************************");
	out(self.name .. " event has occurred:: FirstTickAfterWorldCreated");
	out.inc_tab();
	
	-- store a link to the campaign manager on _G, as autotest scripts need it occasionally and they can't access it here
	_G.cm = self;
	
	local model = self.game_interface:model();
	
	self.is_multiplayer_campaign = model:is_multiplayer();
	
	local local_faction = false;
	local human_factions = {};

	-- build a list of human factions, and work out which faction is local
	do
		local faction_list = model:world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			local faction_name = faction:name();
			
			if faction:is_human() then
				if model:faction_is_local(faction_name) then
					local_faction = faction_name;
				end;
				table.insert(human_factions, faction_name);

				-- create a ScriptEventHumanFactionTurnStart listener for this faction
				self:add_faction_turn_start_listener_by_name(
					"human_faction_turn_start",
					faction_name,
					function(context)
						out("");
						out("********************************************************************************");
						out("* Human faction " .. faction_name .. " is starting turn " .. model:turn_number());
						out("* triggering event ScriptEventHumanFactionTurnStart");
						out("********************************************************************************");
						out.inc_tab();
						core:trigger_event("ScriptEventHumanFactionTurnStart", context:faction());
						out.dec_tab();
					end,
					true
				);
			end;
		end;
		
		if not local_faction then
			script_error("WARNING: campaign manager couldn't find a local faction - this should only happen in autoruns");
		end;
	end;
	
	self.local_faction = local_faction;
	self.human_factions = human_factions;
	
	-- start a listener for all faction turn starts so that client scripts can query whos turn it is
	-- also fire a custom event if it's the player's turn
	if local_faction then
		self:add_faction_turn_start_listener_by_name(
			"faction_currently_processing",
			local_faction,
			function(context)
				out("");
				out("********************************************************************************");
				out("* Local player faction " .. local_faction .. " is starting turn " .. model:turn_number());
				out("* triggering event ScriptEventPlayerFactionTurnStart");
				out("********************************************************************************");
				out.inc_tab();

				-- reset this flag here, as if there's a script failure it can get stuck
				self.processing_battle = false;
				
				core:trigger_event("ScriptEventPlayerFactionTurnStart", context:faction());
			end,
			true
		);
	end;
	
	-- start a listener for the local faction ending a turn which produces output and fires a custom scripted event
	core:add_listener(
		"ScriptEventPlayerFactionTurnEnd",
		"FactionTurnEnd",
		function(context) return context:faction():name() == local_faction end,
		function(context)
			out.dec_tab();
			out("********************************************************************************");
			out("********************************************************************************");
			core:trigger_event("ScriptEventPlayerFactionTurnEnd", context:faction());
		end,
		true
	);
	
	self.game_interface:suppress_all_event_feed_event_types(false);
	
	self.game_is_running = true;
	
	-- mainly for autotesting, but other scripts can listen for it too
	core:trigger_event("ScriptEventGlobalCampaignManagerCreated");
	
	-- mark in the advice history that the player has started a campaign
	effect.set_advice_history_string_seen("player_has_started_campaign");
	
	self:process_first_tick_callbacks(context);
	
	out.dec_tab();
	out("********************************************************************************");
	out("");
	out.restore_tab();
end;


function campaign_manager:process_first_tick_callbacks(context)

	-- process pre first-tick callbacks
	for i = 1, #self.pre_first_tick_callbacks do
		self.pre_first_tick_callbacks[i](context);
	end;
	
	if self:is_multiplayer() then
		if self:is_new_game() then
			-- process new mp callbacks
			for i = 1, #self.first_tick_callbacks_mp_new do
				self.first_tick_callbacks_mp_new[i](context);
			end;
		end;
	
		-- process each mp callbacks
		for i = 1, #self.first_tick_callbacks_mp_each do
			self.first_tick_callbacks_mp_each[i](context);
		end;
	else
		if self:is_new_game() then
			-- process new sp callbacks
			for i = 1, #self.first_tick_callbacks_sp_new do
				self.first_tick_callbacks_sp_new[i](context);
			end;
		end;
	
		-- process each sp callbacks
		for i = 1, #self.first_tick_callbacks_sp_each do
			self.first_tick_callbacks_sp_each[i](context);
		end;
	end;
	
	-- process shared callbacks
	for i = 1, #self.first_tick_callbacks do
		self.first_tick_callbacks[i](context);
	end;
end;









----------------------------------------------------------------------------
--- @section FactionTurnStart Lookup Listeners
--- @desc It's common for campaign scripts to want to execute some code when a faction starts its turn. Client scripts will typically use @core:add_listener to listen for the <code>FactionTurnStart</code> event and then query the event context to determine if it's the correct faction, usually by comparing the faction's name with a known string. This straightforward approach becomes more problematic as more listeners are added, and with a game full of content several dozen listeners can all be responding each time a faction starts its turn, all querying the faction name.
--- @desc To circumvent this problem, client scripts can instead register listeners with @campaign_manager:add_faction_turn_start_listener_by_name. The campaign manager stores these in a lookup table internally, which a lot more computationally efficient than having several dozen client scripts all query the faction name every time a faction starts a turn.
----------------------------------------------------------------------------


--- @function add_faction_turn_start_listener_by_name
--- @desc Adds a listener for the <code>FactionTurnStart</code> event which triggers if a faction with the supplied faction name starts a turn.
--- @p @string listener name, Name by which this listener can be later cancelled using @campaign_manager:remove_faction_turn_start_listener_by_name if necessary. It is valid to have multiple listeners with the same name.
--- @p @string faction name, Faction name to watch for, from the <code>factions</code> database table.
--- @p @function callback, Callback to call if a faction with the specified name starts a turn.
--- @p @boolean persistent, Is this a persistent listener. If this value is <code>false</code> the listener will stop the first time the callback is triggered. If <code>true</code>, the listener will continue until cancelled with @campaign_manager:remove_faction_turn_start_listener_by_name.
function campaign_manager:add_faction_turn_start_listener_by_name(listener_name, faction_name, callback, persistent)
	core:add_lookup_listener_callback("faction_turn_start_listeners_by_name", listener_name, faction_name, callback, persistent);
end;


--- @function remove_faction_turn_start_listener_by_name
--- @desc Removes a listener that was previously added with @campaign_manager:add_faction_turn_start_listener_by_name. Calling this won't affect other faction turn start listeners.
--- @p @string listener name
function campaign_manager:remove_faction_turn_start_listener_by_name(listener_name)
	core:remove_lookup_listener_callback("faction_turn_start_listeners_by_name", listener_name);
end;


--- @function add_faction_turn_start_listener_by_culture
--- @desc Adds a listener for the <code>FactionTurnStart</code> event which triggers if a faction with the supplied culture key starts a turn.
--- @p @string listener name, Name by which this listener can be later cancelled using @campaign_manager:remove_faction_turn_start_listener_by_culture if necessary. It is valid to have multiple listeners with the same name.
--- @p @string culture key, Culture key to watch for, from the <code>cultures</code> database table.
--- @p @function callback, Callback to call if a faction of the specified culture starts a turn.
--- @p @boolean persistent, Is this a persistent listener. If this value is <code>false</code> the listener will stop the first time the callback is triggered. If <code>true</code>, the listener will continue until cancelled with @campaign_manager:remove_faction_turn_start_listener_by_culture.
function campaign_manager:add_faction_turn_start_listener_by_culture(listener_name, culture_name, callback, persistent)
	core:add_lookup_listener_callback("faction_turn_start_listeners_by_culture", listener_name, culture_name, callback, persistent);
end;


--- @function remove_faction_turn_start_listener_by_culture
--- @desc Removes a listener that was previously added with @campaign_manager:add_faction_turn_start_listener_by_culture. Calling this won't affect other faction turn start listeners.
--- @p @string listener name
function campaign_manager:remove_faction_turn_start_listener_by_culture(listener_name)
	core:remove_lookup_listener_callback("faction_turn_start_listeners_by_culture", listener_name);
end;


--- @function add_faction_turn_start_listener_by_subculture
--- @desc Adds a listener for the <code>FactionTurnStart</code> event which triggers if a faction with the supplied subculture key starts a turn.
--- @p @string listener name, Name by which this listener can be later cancelled using @campaign_manager:remove_faction_turn_start_listener_by_subculture if necessary. It is valid to have multiple listeners with the same name.
--- @p @string subculture key, Subculture key to watch for, from the <code>subcultures</code> database table.
--- @p @function callback, Callback to call if a faction of the specified subculture starts a turn.
--- @p @boolean persistent, Is this a persistent listener. If this value is <code>false</code> the listener will stop the first time the callback is triggered. If <code>true</code>, the listener will continue until cancelled with @campaign_manager:remove_faction_turn_start_listener_by_culture.
function campaign_manager:add_faction_turn_start_listener_by_subculture(listener_name, subculture_name, callback, persistent)
	core:add_lookup_listener_callback("faction_turn_start_listeners_by_subculture", listener_name, subculture_name, callback, persistent);
end;


--- @function remove_faction_turn_start_listener_by_subculture
--- @desc Removes a listener that was previously added with @campaign_manager:add_faction_turn_start_listener_by_subculture. Calling this won't affect other faction turn start listeners.
--- @p @string listener name
function campaign_manager:remove_faction_turn_start_listener_by_subculture(listener_name)
	core:remove_lookup_listener_callback("faction_turn_start_listeners_by_subculture", listener_name);
end;









----------------------------------------------------------------------------
--- @section Output
----------------------------------------------------------------------------


--- @function output_campaign_obj
--- @desc Prints information about certain campaign objects (characters, regions, factions or military force) to the debug console spool. Preferably don't call this - just call <code>out(object)</code> insead.
--- @p object campaign object
function campaign_manager:output_campaign_obj(input, verbosity)
	-- possible values of verbosity: 0 = full version, 1 = abridged, 2 = one line summary
	verbosity = verbosity or 0;
	
	if verbosity == 2 then
		out(self:campaign_obj_to_string(input));
		return;
	end;
		
	-- CHARACTER
	if is_character(input) then
		if verbosity == 0 then
			out("");
			out("CHARACTER:");
			out("==============================================================");
		end;
		out.inc_tab();
		out("cqi:\t\t\t" .. tostring(input:cqi()));
		out("faction:\t\t\t" .. input:faction():name());
		out("forename:\t\t" .. input:get_forename());
		out("surname:\t\t" .. input:get_surname());
		out("type:\t\t\t" .. input:character_type_key());
		out("subtype:\t\t\t" .. input:character_subtype_key());
		if input:has_region() then
			if verbosity == 0 then
				out("region:");
				out.inc_tab();
				self:output_campaign_obj(input:region(), 1);
				out.dec_tab();
			else
				out("region:\t" .. self:campaign_obj_to_string(input:region()));
			end;
		else
			out("region:\t<no region>");
		end;
		out("logical position:\t[" .. tostring(input:logical_position_x()) .. ", " .. tostring(input:logical_position_y()) .."]");
		out("display position:\t[" .. tostring(input:display_position_x()) .. ", " .. tostring(input:display_position_y()) .."]");
		
		if input:has_military_force() then
			if verbosity == 0 then
				out("military force:");
				out.inc_tab();
				self:output_campaign_obj(input:military_force(), 1);
				out.dec_tab();
			else
				out("military force:\t<commanding> " .. self:campaign_obj_to_string(input:military_force()));
			end;
		else
			out("military force:\t<not commanding>");
		end;
		
		out("has residence:\t" .. tostring(input:has_garrison_residence()));
		
		if not verbosity == 0 then
			out("is male:\t" .. tostring(input:is_male()));
			out("age:\t" .. tostring(input:age()));
			out("loyalty:\t" .. tostring(input:loyalty()));
			out("gravitas:\t" .. tostring(input:gravitas()));
			out("is embedded:\t" .. tostring(input:is_embedded_in_military_force()));
		end;
		
		out.dec_tab();
		
		if verbosity == 0 then
			out("==============================================================");
			out("");
		end;
	
	
	-- REGION
	elseif is_region(input) then	
		if verbosity == 0 then
			out("");
			out("REGION:");
			out("==============================================================");
		end;
		out.inc_tab();
		out("name:\t\t\t" .. input:name());
		
		
		if verbosity == 0 then
			out("owning faction:");
			out.inc_tab();
			self:output_campaign_obj(input:owning_faction(), 1);
			out.dec_tab();
		else
			out("owning faction:\t" .. self:campaign_obj_to_string(input:owning_faction()));
		end;
		
		if input:has_governor() then
			if verbosity == 0 then
				out("governor:");
				out.inc_tab();
				self:output_campaign_obj(input:governor(), 1);
				out.dec_tab();
			else
				out("governor:\t\t " .. self:campaign_obj_to_string(input:governor()));
			end;
		else
			out("governor:\t\t<no governor>");
		end;
		
		if input:garrison_residence():has_army() then
			if verbosity == 0 then
				out("garrisoned army:");
				out.inc_tab();
				self:output_campaign_obj(input:garrison_residence():army(), 1);
				out.dec_tab();
			else
				out("garrisoned army: " .. self:campaign_obj_to_string(input:garrison_residence():army()));
			end;
		else
			out("garrisoned army:\t<no army>");
		end;
			
		if input:garrison_residence():has_navy() then
			if verbosity == 0 then
				out("garrisoned navy:");
				out.inc_tab();
				self:output_campaign_obj(input:garrison_residence():navy(), 1);
				out.dec_tab();
			else
				out("garrisoned navy: " .. self:campaign_obj_to_string(input:garrison_residence():navy()));
			end;
		else
			out("garrisoned navy:\t<no navy>");
		end;
		
		out("under siege:\t\t" .. tostring(input:garrison_residence():is_under_siege()));
		
		if verbosity == 0 then
			out("num buildings:\t" .. tostring(input:num_buildings()));
			out("public order:\t\t" .. tostring(input:public_order()));
			out("majority religion:\t" .. input:majority_religion());
		end;
		
		out.dec_tab();
		
		if verbosity == 0 then
			out("==============================================================");
			out("");
		end;
	
	
	-- FACTION
	elseif is_faction(input) then
		if verbosity == 0 then
			out("");
			out("FACTION:");
			out("==============================================================");
		end;
		out.inc_tab();
		out("name:\t\t" .. input:name());
		out("human:\t" .. tostring(input:is_human()));
		out("regions:\t" .. tostring(input:region_list():num_items()));
		
		if verbosity == 0 then
			local region_list = input:region_list();
			out.inc_tab();
			for i = 0, region_list:num_items() - 1 do
				out(i .. ":\t" .. self:campaign_obj_to_string(region_list:item_at(i)));
			end;
			out.dec_tab();
		end;
		
		if input:has_faction_leader() then
			if verbosity == 0 then
				out("faction leader:");
				out.inc_tab();
				self:output_campaign_obj(input:faction_leader(), 1);
				out.dec_tab();
			else
				out("faction leader: " .. self:campaign_obj_to_string(input:faction_leader()));
			end;
		else
			out("faction leader:\t<none>");
		end;
		
		out("characters:\t" .. tostring(input:character_list():num_items()));
		
		if verbosity == 0 then
			local character_list = input:character_list();
			out.inc_tab();
			for i = 0, character_list:num_items() - 1 do
				out(i .. ":\t" .. self:campaign_obj_to_string(character_list:item_at(i)));
			end;
			out.dec_tab();
		end;

		out("mil forces:\t" .. tostring(input:military_force_list():num_items()));
		
		if verbosity == 0 then
			local military_force_list = input:military_force_list();
			out.inc_tab();
			for i = 0, military_force_list:num_items() - 1 do
				out(i .. ":\t" .. self:campaign_obj_to_string(military_force_list:item_at(i)));
			end;
			out.dec_tab();
		end;
		
		if verbosity == 0 then
			out("state religion:\t" .. tostring(input:state_religion()));
			out("culture:\t" .. tostring(input:culture()));
			out("subculture:\t" .. tostring(input:subculture()));
			out("treasury:\t" .. tostring(input:treasury()));
			out("tax level:\t" .. tostring(input:tax_level()));
			out("losing money:\t" .. tostring(input:losing_money()));
			out("food short.:\t" .. tostring(input:has_food_shortage()));
			out("imperium:\t" .. tostring(input:imperium_level()));
		end;
		
		out.dec_tab();
		
		if verbosity == 0 then
			out("==============================================================");
			out("");
		end;
	
	
	-- MILITARY FORCE
	elseif is_militaryforce(input) then
		if verbosity == 0 then
			out("");
			out("MILITARY FORCE:");
			out("==============================================================");
		end;
		out.inc_tab();
		if input:has_general() then
			if verbosity == 0 then
				out("general:");
				out.inc_tab();
				self:output_campaign_obj(input:general_character(), 1);
				out.dec_tab();
			else
				out("general:\t" .. self:campaign_obj_to_string(input:general_character()));
			end;
		else
			out("general:\t<none>");
		end;
		
		out("is army:\t" .. tostring(input:is_army()));
		out("is navy:\t" .. tostring(input:is_navy()));
		out("faction:\t\t" .. self:campaign_obj_to_string(input:faction()));
		out("units:\t\t" .. tostring(input:unit_list():num_items()));
		
		if verbosity == 0 then
			local unit_list = input:unit_list();
			out.inc_tab();
			for i = 0, unit_list:num_items() - 1 do
				out(i .. ":\t" .. self:campaign_obj_to_string(unit_list:item_at(i)));
			end;
			out.dec_tab();
		end;
		
		out("characters:\t" .. tostring(input:character_list():num_items()));
		
		if verbosity == 0 then
			local char_list = input:character_list();
			out.inc_tab();
			for i = 1, char_list:num_items() - 1 do
				out(i .. ":\t" .. self:campaign_obj_to_string(char_list:item_at(i)));
			end;
			out.dec_tab();
		end;
		
		out("residence:\t" .. tostring(input:has_garrison_residence()));
		
		if verbosity == 0 then
			out("mercenaries:\t" .. tostring(input:contains_mercenaries()));
			out("upkeep:\t" .. tostring(input:upkeep()));
			out("is_armed_citizenry:\t" .. tostring(input:is_armed_citizenry()));
		end;
		
		out.dec_tab();
		
		if verbosity == 0 then
			out("==============================================================");
			out("");
		end;
	
	else
		script_error("WARNING: output_campaign_obj() did not recognise input " .. tostring(input));
	end;
end;


--- @function campaign_obj_to_string
--- @desc Returns a string summary description when passed certain campaign objects. Supported object types are character, region, faction, military force, and unit.
--- @p object campaign object
--- @return string summary of object
function campaign_manager:campaign_obj_to_string(input)
	if is_character(input) then
		return ("CHARACTER cqi[" .. tostring(input:cqi()) .. "], faction[" .. input:faction():name() .. "], forename[" .. effect.get_localised_string(input:get_forename()) .. "], logical pos[" .. input:logical_position_x() .. ", " .. input:logical_position_y() .. "], type/subtype[" .. input:character_type_key() .. "|" .. input:character_subtype_key() .. "]");
	
	elseif is_region(input) then
		return ("REGION name[" .. input:name() .. "], owning faction[" .. input:owning_faction():name() .. "]");
		
	elseif is_faction(input) then
		return ("FACTION name[" .. input:name() .. "], num regions[" .. tostring(input:region_list():num_items()) .. "]");
	
	elseif is_militaryforce(input) then
		local gen_details = "" 
				
		if input:has_general() then
			local char = input:general_character();
			gen_details = "general cqi[" .. tostring(char:cqi()) .. "], logical pos [" .. char:logical_position_x() .. ", " .. char:logical_position_y() .. "]";
		else
			gen_details = "general: [none], logical pos[unknown]";
		end;
			
		return ("MILITARY_FORCE faction[" .. input:faction():name() .. "] units[" .. tostring(input:unit_list():num_items()) .. "], " .. gen_details .. "], upkeep[" .. tostring(input:upkeep()) .. "]");
	
	elseif is_unit(input) then
		return ("UNIT key[" .. input:unit_key() .. "], strength[" .. tostring(input:percentage_proportion_of_full_strength()) .. "]");
	
	else
		return "<campaign object [" .. tostring(input) .. "] not recognised>";
	end;
end;











----------------------------------------------------------------------------
--- @section Timer Callbacks
--- @desc The functions in this section provide the ability to register callbacks to call after a supplied duration. The interface provided is similar to that provided by a @timer_manager in battle, but the underlying campaign timer architecture is different enough to preclude the use of a @timer_manager.
----------------------------------------------------------------------------


--- @function callback
--- @desc Calls the supplied function after the supplied period in seconds. A string name for the callback may optionally be provided to allow the callback to be cancelled later.
--- @desc If part or all of the interval is likely to elapse during the end turn sequence, consider using @campaign_manager:os_clock_callback as time does not behave as expected during the end turn sequence.
--- @p function callback to call
--- @p number time, Time in seconds after to which to call the callback. The model ticks ten times a second so it doesn't have an effective resolution greater than this.
--- @p [opt=nil] string name, Callback name. If supplied, this callback can be cancelled at a later time (before it triggers) with @campaign_manager:remove_callback.
function campaign_manager:callback(new_callback, new_t, new_name)
	self:impl_callback(new_callback, new_t, new_name, false);
end;


--- @function repeat_callback
--- @desc Calls the supplied function repeatedly after the supplied period in seconds. A string name for the callback may optionally be provided to allow the callback to be cancelled. Cancelling the callback is the only method to stop a repeat callback, once started.
--- @p function callback to call
--- @p number time, Time in seconds after to which to call the callback, repeatedly. The callback will be called each time this interval elapses. The model ticks ten times a second so it doesn't have an effective resolution greater than this.
--- @p [opt=nil] string name, Callback name. If supplied, this callback can be cancelled at a later time with @campaign_manager:remove_callback.
function campaign_manager:repeat_callback(new_callback, new_t, new_name)
	self:impl_callback(new_callback, new_t, new_name, true);
end;


-- for internal use
function campaign_manager:impl_callback(new_callback, new_t, new_name, is_repeating)
	if type(new_callback) ~= "function" then
		script_error("callback() called but callback " .. tostring(new_callback) .. " is not a function !!");
		return false;
	end;
	if type(new_t) ~= "number" then
		script_error("callback() called but time value " .. tostring(new_t) .. " is not a number !!");
		return false;
	end;
	
	is_repeating = not not is_repeating
	
	local script_timers = self.script_timers;
	
	-- generate unique id for this call
	local new_id = 0;	
	while script_timers[new_id] do
		new_id = new_id + 1;
	end;
	
	local new_timer = {callback = new_callback, name = new_name, callstack = debug.traceback(), is_repeating = is_repeating};
	
	-- if the callback is repeated the garbage collector seems to get confused, so force a pass here
	-- collectgarbage();			-- disabling for performance
	
	self.game_interface:add_time_trigger(new_id, new_t, not not is_repeating);
	
	script_timers[new_id] = new_timer;
end;


--- @function os_clock_callback
--- @desc Time in campaign behaves strangely during the end-turn sequence, and callbacks registered with @campaign_manager:callback will tend to be called immediately rather than after the desired interval. This function works around the problem by polling the operating system clock to check that the desired duration has indeed elapsed before calling the supplied callback. It is less accurate and more expensive than @campaign_manager:callback, but will produce somewhat sensible results during the end-turn sequence.
--- @p function callback to call
--- @p number time, Time in seconds after to which to call the callback.
--- @p [opt=nil] string name, Callback name. If supplied, this callback can be cancelled at a later time with @campaign_manager:remove_callback.
function campaign_manager:os_clock_callback(callback, delay, name)
	self:process_os_clock_callback(callback, os.clock() + delay, name)
end;


--	process os-clock callbacks, for internal use only
function campaign_manager:process_os_clock_callback(callback, end_time, name)
	if os.clock() >= end_time then
		callback();
	else
		self:callback(function() self:process_os_clock_callback(callback, end_time, name) end, 0.2, name)
	end;
end;


--- @function remove_callback
--- @desc Removes all pending callbacks that matches the supplied name.
--- @p [opt=nil] string name, Callback name to remove.
function campaign_manager:remove_callback(name)
	local script_timers = self.script_timers;
	
	for id, timer_entry in pairs(script_timers) do
		if timer_entry.name == name then
			self.game_interface:remove_time_trigger(id);
			script_timers[id] = nil;
		end;
	end;
end;


--	called by the event system when a timer has triggered. For internal use only
function campaign_manager:check_callbacks(context)
	local str = context.string;
	local script_timers = self.script_timers;
	
	for id, timer_entry in pairs(script_timers) do
		if tostring(id) == str then
			local callback = timer_entry.callback;
			local callstack = timer_entry.callstack;
			-- remove the timer if it's not set to repeat
			if not timer_entry.is_repeating then
				script_timers[id] = nil;
			end;
			core:monitor_performance(callback, 0.1, callstack);
			return;
		end;
	end;
end;


--- @function dump_timers
--- @desc Prints information about all timers to the console debug spool.
function campaign_manager:dump_timers()
	out.inc_tab();
	out("Dumping timers, os.clock is " .. tostring(os.clock()));
	out.inc_tab();
	
	local script_timers = self.script_timers;
	for id, timer_entry in pairs(script_timers) do
		out("id: " .. tostring(id) .. ", name: " .. tostring(timer_entry.name) .. ", callback: " .. tostring(timer_entry.callback));
	end;
	
	out.dec_tab();
	out.dec_tab();
end;










----------------------------------------------------------------------------
--- @section Local Player Faction
--- @desc The functions in this section report information about the local player faction. Beware of using them in in multiplayer, for making changes to the model based on the identity of the local faction is likely to cause a desync because changes will happen on one machine and not the other. Each function listed here, if called in multiplayer, will throw a script error and fail, unless <code>true</code> is passed in as an argument to force the result. In doing so, the calling script acknowledges the risks described here.
--- @desc Each function here can only be called on or after the first model tick.
----------------------------------------------------------------------------


--- @function get_local_faction_name
--- @desc Returns the local player faction name.
--- @p [opt=false] boolean force result, Force the result to be returned instead of erroring in multiplayer.
--- @return @string local faction name
function campaign_manager:get_local_faction_name(force)
	if not self.game_is_running then
		script_error(self.name .. " ERROR: get_local_faction_name() called before game has been created");
		return false;
	end;
	
	if self:is_multiplayer() and not force then
		script_error(self.name .. " ERROR: get_local_faction_name() called but this is a multiplayer game, reconsider or force this usage. Please bug this.");
		return false;
	end;
	
	return self.local_faction;
end;


--- @function get_local_faction
--- @desc Returns the local player faction object.
--- @p [opt=false] @boolean force result, Force the result to be returned instead of erroring in multiplayer.
--- @return FACTION_SCRIPT_INTERFACE faction
function campaign_manager:get_local_faction(force)
	if not self.game_is_running then
		script_error(self.name .. " ERROR: get_local_faction() called before game has been created");
		return false;
	end;
	
	if self:is_multiplayer() and not force then
		script_error(self.name .. " ERROR: get_local_faction() called but this is a multiplayer game, reconsider or force this usage. Please bug this.");
		return false;
	end;
	
	return self:get_faction(self.local_faction);
end;


--- @function is_local_players_turn
--- @desc Returns <code>true</code> if it's the local player's turn.
--- @return @boolean is local player's turn
function campaign_manager:is_local_players_turn()
	return self:whose_turn_is_it() == self:get_local_faction_name(true);
end;











----------------------------------------------------------------------------
--- @section General Querying
----------------------------------------------------------------------------


--- @function is_multiplayer
--- @desc Returns true if the campaign is multiplayer.
--- @return boolean is multiplayer campaign
function campaign_manager:is_multiplayer()
	if not self.game_is_running then
		script_error(self.name .. " ERROR: is_multiplayer() called before game has been created!");
		return false;
	end;
	
	return self.is_multiplayer_campaign;
end;


--- @function is_new_game
--- @desc Returns true if the campaign is new. A campaign is "new" if it has been saved only once before - this save occurs during startpos processing.
--- @desc Note that if the script fails during startpos processing, the counter will not have been saved and it's value will be 0 - in this case, the game may report that it's not new when it is. If you experience a campaign that behaves as if it's loading into a savegame when starting from fresh, it's probably because the script failed during startpos processing.
--- @return boolean is new game
function campaign_manager:is_new_game()
	if not self.game_is_loaded then
		script_error(self.name .. " WARNING: is_new_game() called before the game has loaded, this call should happen later in the loading process. Returning false.");
		return false;
	end;
	
	return (self.save_counter == 1);	-- save_counter is 0 before the startpos is reprocessed and saved, 1 after the startpos is reprocessed, > 1 after the player first saves
end;


--- @function is_game_running
--- @desc Returns whether or not the game is loaded and time is ticking.
--- @return boolean is game started
function campaign_manager:is_game_running()
	return self.game_is_running;
end;


--- @function model
--- @desc Returns a handle to the game model at any time (after the game has been created). See the @"campaign_index:Model Hierarchy" pages for more information about the game model interface.
--- @return object model
function campaign_manager:model()
	if core:is_ui_created() then
		return self.game_interface:model();
	else
		script_error("ERROR: an attempt was made to call model() before the ui was created. The model is not yet created - this call needs to happen later in the loading sequence");
		return false;
	end;
end;


--- @function get_game_interface
--- @desc Returns a handle to the raw episodic scripting interface. Generally it's not necessary to call this function, as calls made on the campaign manager which the campaign manager doesn't itself provide are passed through to the episodic scripting interface, but a direct handle to the episodic scripting interface may be sought with this function if speed of repeated access.
--- @return object game_interface
function campaign_manager:get_game_interface()
	if not self.game_interface then
		script_error("ERROR: get_game_interface() called but game_interface object has not been created - call this later in the load sequence");
		return false;
	end;
	
	return self.game_interface;
end;


--- @function get_difficulty
--- @desc Returns the current combined campaign difficulty. This is returned as an integer value by default, or a string if a single <code>true</code> argument is passed in.
--- @desc <table class="simple"><tr><td><strong>string</strong></td><td><strong>number</strong></td></tr><tr><td>easy</td><td>1</td></tr><tr><td>normal</td><td>2</td></tr><tr><td>hard</td><td>3</td></tr><tr><td>very hard</td><td>4</td></tr><tr><td>legendary</td><td>5</td></tr></table>
--- @desc Note that the numbers returned above are different from those returned by the <code>combined_difficulty_level()</code> function on the campaign model.
--- @p [opt=false] boolean return as string
--- @return object difficulty integer or string
function campaign_manager:get_difficulty(return_as_string)
	local difficulty = self:model():combined_difficulty_level();
	
	if self:get_local_faction_name(true) then
		if difficulty == 0 then
			difficulty = 2;				-- normal
		elseif difficulty == -1 then
			difficulty = 3;				-- hard
		elseif difficulty == -2 then
			difficulty = 4;				-- very hard
		elseif difficulty == -3 then
			difficulty = 5;				-- legendary
		else
			difficulty = 1;				-- easy
		end;
	else
	-- autorun
		if difficulty == 0 then
			difficulty = 2;				-- normal
		elseif difficulty == 1 then
			difficulty = 3;				-- hard
		elseif difficulty == 2 then
			difficulty = 4;				-- very hard
		elseif difficulty == 3 then
			difficulty = 5;				-- legendary
		else
			difficulty = 1;				-- easy
		end;
	end;
	
	if return_as_string then
		local difficulty_string = "easy";
		
		if difficulty == 2 then
			difficulty_string = "normal";
		elseif difficulty == 3 then
			difficulty_string = "hard";
		elseif difficulty == 4 then
			difficulty_string = "very hard";
		elseif difficulty == 5 then
			difficulty_string = "legendary";
		end;
		
		return difficulty_string;
	end;
	
	return difficulty;
end;


--- @function get_human_factions
--- @desc Returns a numerically-indexed table containing the string keys of all human factions within the game.
--- @return table human factions
function campaign_manager:get_human_factions()
	if not self.game_is_running then
		script_error(self.name .. " ERROR: get_human_factions() called before game has been created");
		return false;
	end;
	
	-- make a copy so that our version is not modified by calling scripts
	local retval = {};
	for i = 1, #self.human_factions do
		retval[i] = self.human_factions[i];
	end;
	
	return retval;
end;


--- @function are_any_factions_human
--- @desc Returns whether any factions in the supplied list are human. The faction list should be supplied as a numerically-indexed table of either faction keys or faction script objects.
--- @p @table faction list, Numerically-indexed table of @string faction keys or faction script objects.
--- @p @boolean tolerate errors, Sets the function to tolerate errors, where it won't throw a script error and return if any of the supplied data is incorrectly formatted.
function campaign_manager:are_any_factions_human(faction_list, tolerate_errors)
	if not is_table(faction_list) then
		if not tolerate_errors then
			script_error("ERROR: are_any_factions_human() called but supplied faction list [" .. tostring(faction_list) .. "] is not a table");
		end;
		return false;
	end;

	for i = 1, #faction_list do
		local current_faction_obj = faction_list[i];

		if is_string(current_faction_obj) then
			local faction = self:get_faction(current_faction_obj);
			if faction then
				if faction:is_human() then
					return true;
				end;
			elseif not tolerate_errors then
				script_error("WARNING: are_any_factions_human() called but item [" .. i .. "] in supplied faction list is a string [" .. current_faction_obj .. "] but no faction with this key could be found");
			end;
		elseif is_faction(current_faction_obj) then
			if current_faction_obj:is_human() then
				return true;
			end;
		elseif not tolerate_errors then
			script_error("WARNING: are_any_factions_human() called but item [" .. i .. "] in supplied faction list is not a faction or faction key, its value is [" .. tostring(current_faction_obj) .. "]");
		end;
	end;

	return false;
end;


--- @function whose_turn_is_it
--- @desc Returns the faction key of the faction whose turn it is currently.
--- @return string faction key
function campaign_manager:whose_turn_is_it()
	return self:model():world():whose_turn_is_it():name();
end;


--- @function is_processing_battle
--- @desc Returns true if a battle is currently happening on-screen. This is set to true when the pre-battle panel opens, and is set to false when the battle sequence is over and any related camera animations have finished playing.
--- @return boolean battle is happening
function campaign_manager:is_processing_battle()
	return self.processing_battle or self.processing_battle_completing;
end;


--- @function turn_number
--- @desc Returns the turn number, including any modifier set with @campaign_manager:set_turn_number_modifier
--- @return number turn number
function campaign_manager:turn_number()
	return self.game_interface:model():turn_number() + self.turn_number_modifier;
end;


--- @function set_turn_number_modifier
--- @desc Sets a turn number modifier. This offsets the result returned by @campaign_manager:turn_number by the supplied modifier. This is useful for campaign setups which include optional additional turns (e.g. one or two turns at the start of a campaign to teach players how to play the game), but still wish to trigger events on certain absolute turns. For example, some script may wish to trigger an event on turn five of a standard campaign, but this would be turn six if a one-turn optional tutorial at the start of the campaign was played through - in this case a turn number modifier of 1 could be set if not playing through the tutorial.
--- @p number modifier
function campaign_manager:set_turn_number_modifier(modifier)
	if not is_number(modifier) or math.floor(modifier) ~= modifier then
		script_error("ERROR: set_turn_number_modifier() called but supplied modifier [" .. tostring(modifier) .. "] is not an integer");
		return false;
	end;
	
	self.turn_number_modifier = modifier;
end;


--- @function null_interface
--- @desc Returns a scripted-generated object that emulates a campaign null interface.
--- @return null_interface
function campaign_manager:null_interface()
	local null_interface = {};
	
	null_interface.is_null_interface = function() return true end;
	
	return null_interface;
end;


--- @function help_page_seen
--- @desc Returns whether the advice history indicates that a specific help page has been viewed by the player.
--- @p string help page name
--- @return boolean help page viewed 
function campaign_manager:help_page_seen(page_name)
	return effect.get_advice_history_string_seen(page_name) or effect.get_advice_history_string_seen("script_link_campaign_" .. page_name);
end;










----------------------------------------------------------------------------
--- @section Building Queries & Modification
----------------------------------------------------------------------------


--- @function building_exists_in_province
--- @desc Returns whether the supplied building exists in the supplied province.
--- @p string building key
--- @p string province key
--- @return boolean building exist
function campaign_manager:building_exists_in_province(building_key, province_key)
	if not is_string(building_key) then
		script_error("ERROR: building_exists_in_province() called but supplied building key [" .. tostring(building_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(province_key) then
		script_error("ERROR: building_exists_in_province() called but supplied province key [" .. tostring(province_key) .. "] is not a string");
		return false;
	end;

	local region_list = self:model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		if current_region:province_name() == province_key and current_region:building_exists(building_key) then
			return true;
		end;
	end;
	
	return false;
end;











----------------------------------------------------------------------------
--- @section Character Queries & Modification
----------------------------------------------------------------------------


--- @function get_garrison_commander_of_region
--- @desc Returns the garrison commander character of the settlement in the supplied region.
--- @p region region object
--- @return character garrison commander
function campaign_manager:get_garrison_commander_of_region(region)
	if not is_region(region) then
		script_error("ERROR: get_garrison_commander_of_region() called but supplied object [" .. tostring(region) .. "] is not a valid region");
		return false;
	end
	
	if region:is_abandoned() then
		return false;
	end;
	
	local faction = region:owning_faction();
	
	if not is_faction(faction) then
		return false;
	end;
	
	local character_list = faction:character_list();
	
	out.inc_tab();
	for i = 0, character_list:num_items() - 1 do
		local character = character_list:item_at(i);
		
		if character:has_military_force() and character:military_force():is_armed_citizenry() and character:has_region() and character:region() == region then		
			out.dec_tab();
			return character;
		end;
	end;
	out.dec_tab();
end;


--- @function get_closest_general_to_position_from_faction
--- @desc Returns the general within the supplied faction that's closest to the supplied logical co-ordinates.
--- @p object faction, Faction specifier. This can be a faction object or a string faction name.
--- @p number x, Logical x co-ordinate.
--- @p number y, Logical y co-ordinate.
--- @p [opt=false] boolean include garrison commanders, Includes garrison commanders in the search results if set to <code>true</code>.
--- @return character closest character
function campaign_manager:get_closest_general_to_position_from_faction(faction, x, y, consider_garrison_commanders)
	return self:get_closest_character_to_position_from_faction(faction, x, y, true, consider_garrison_commanders);
end;


--- @function get_closest_character_to_position_from_faction
--- @desc Returns the character within the supplied faction that's closest to the supplied logical co-ordinates.
--- @p object faction, Faction specifier. This can be a faction object or a string faction name.
--- @p number x, Logical x co-ordinate.
--- @p number y, Logical y co-ordinate.
--- @p [opt=false] boolean general characters only, Restrict search results to generals.
--- @p [opt=false] boolean include garrison commanders, Includes garrison commanders in the search results if set to <code>true</code>.
--- @return character closest character
function campaign_manager:get_closest_character_to_position_from_faction(faction, x, y, generals_only, consider_garrison_commanders)
	generals_only = not not generals_only;
	consider_garrison_commanders = not not consider_garrison_commanders;
	
	if not generals_only then
		consider_garrison_commanders = true;
	end;

	if not is_faction(faction) then
		local faction_found = false;
		
		if is_string(faction) then
			faction = cm:get_faction(faction);
			if faction then
				faction_found = true;
			end;
		end;
		
		if not faction_found then
			script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied faction [" .. tostring(faction) .. "] is not a valid faction, or a string name of a faction");
			return false;
		end;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return false;
	end;
	
	local char_list = faction:character_list();
	local closest_char = false;
	local closest_distance_squared = 100000000;
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		-- if we aren't only looking for generals OR if we are and this is a general AND if we are considering garrison commanders OR if we aren't and it is a general proceed
		if not generals_only or (self:char_is_general(current_char) and current_char:has_military_force() and (consider_garrison_commanders or not current_char:military_force():is_armed_citizenry())) then			
			local current_char_x, current_char_y = self:char_logical_pos(current_char);
			local current_distance_squared = distance_squared(x, y, current_char_x, current_char_y);
			if current_distance_squared < closest_distance_squared then
				closest_char = current_char;
				closest_distance_squared = current_distance_squared;
			end;
		end;
	end;
	
	return closest_char, closest_distance_squared ^ 0.5;
end;


--- @function get_general_at_position_all_factions
--- @desc Returns the general character stood at the supplied position, regardless of faction. Garrison commanders are not returned.
--- @p number x, Logical x co-ordinate.
--- @p number y, Logical y co-ordinate.
--- @return character general character
function campaign_manager:get_general_at_position_all_factions(x, y)
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
			
		local military_force_list = faction:military_force_list();
		
		for j = 0, military_force_list:num_items() - 1 do
			local mf = military_force_list:item_at(j);
			
			if mf:has_general() and not mf:is_armed_citizenry() then
				local character = mf:general_character();
				
				if character:logical_position_x() == x and character:logical_position_y() == y then
					return character;
				end;
			end;
		end;
	end;
	
	return false;
end;


--- @function get_character_by_cqi
--- @desc Returns a character by it's command queue index. If no character with the supplied cqi is found then <code>false</code> is returned.
--- @p number cqi
--- @return character character
function campaign_manager:get_character_by_cqi(cqi)
	if is_string(cqi) then
		cqi = tonumber(cqi);
	end;
	
	if not is_number(cqi) then
		script_error("get_character_by_cqi() called but supplied cqi [" .. tostring(cqi) .. "] is not a number or a string that converts to a number");
		return false;
	end;
	
	local model = self:model();
	if model:has_character_command_queue_index(cqi) then
		return model:character_for_command_queue_index(cqi);
	end;

	return false;
end;


--- @function get_military_force_by_cqi
--- @desc Returns a military force by it's command queue index. If no military force with the supplied cqi is found then <code>false</code> is returned.
--- @p number cqi
--- @return military_force military force
function campaign_manager:get_military_force_by_cqi(cqi)
	if is_string(cqi) then
		cqi = tonumber(cqi);
	end;
	
	if not is_number(cqi) then
		script_error("get_military_force_by_cqi() called but supplied cqi [" .. tostring(cqi) .. "] is not a number or a string that converts to a number");
		return false;
	end;
	
	local model = self:model();
	if model:has_military_force_command_queue_index(cqi) then
		return model:military_force_for_command_queue_index(cqi);
	end;

	return false;
end;


--- @function get_character_by_mf_cqi
--- @desc Returns the commander of a military force by the military force's command queue index. If no military force with the supplied cqi is found or it has no commander then <code>false</code> is returned.
--- @p number military force cqi
--- @return character general character
function campaign_manager:get_character_by_mf_cqi(cqi)
	local mf = self:get_military_force_by_cqi(cqi);
	
	if mf and mf:has_general() then
		return mf:general_character();
	end;
	
	return false;
end;


--- @function char_display_pos
--- @desc Returns the x/y display position of the supplied character.
--- @p character character
--- @return number x display co-ordinate
--- @return number y display co-ordinate
function campaign_manager:char_display_pos(character)
	if not is_character(character) then
		script_error("ERROR: char_display_pos() called but supplied object [" .. tostring(character) .. "] is not a character");
		return 0, 0;
	end;
	
	return character:display_position_x(), character:display_position_y();
end;


--- @function char_logical_pos
--- @desc Returns the x/y logical position of the supplied character.
--- @p character character
--- @return number x logical co-ordinate
--- @return number y logical co-ordinate
function campaign_manager:char_logical_pos(character)
	if not is_character(character) then
		script_error("ERROR: char_logical_pos() called but supplied object [" .. tostring(character) .. "] is not a character");
		return 0, 0;
	end;

	return character:logical_position_x(), character:logical_position_y();
end;


--- @function character_is_army_commander
--- @desc Returns <code>true</code> if the character is a general at the head of a moveable army (not a garrison), <code>false</code> otherwise.
--- @p character character
--- @return boolean is army commander
function campaign_manager:character_is_army_commander(character)
	if not is_character(character) then
		script_error("ERROR: char_is_army_commander() called but supplied object [" .. tostring(character) .. "] is not a character");
		return false;
	end;
	
	if not character:has_military_force() then
		return false;
	end;
	
	local military_force = character:military_force();
	
	return military_force:has_general() and military_force:general_character() == character and not military_force:is_armed_citizenry();
end;


--- @function char_lookup_str
--- @desc Various game interface functions lookup characters using a lookup string. This function converts a character into a lookup string that can be used by code functions to find that same character. It may also be supplied a character cqi in place of a character object.
--- @p object character or character cqi
--- @return string lookup string
function campaign_manager:char_lookup_str(obj)
	if is_nil(obj) then
		script_error("ERROR: char_lookup_str() called but supplied object is nil");
		return false;
	end

	if is_number(obj) or is_string(obj) then
		return "character_cqi:" .. obj;
	end;
	
	return "character_cqi:" .. obj:cqi();
end;


--- @function char_in_owned_region
--- @desc Returns <code>true</code> if the supplied character is in a region their faction controls, <code>false</code> otherwise.
--- @p character character
--- @return boolean stood in owned region
function campaign_manager:char_in_owned_region(character)
	return character:has_region() and (character:region():owning_faction() == character:faction());
end;


--- @function char_has_army
--- @desc Returns <code>true</code> if the supplied character has a land army military force, <code>false</code> otherwise.
--- @p character character
--- @return boolean has army
function campaign_manager:char_has_army(character)
	return character:has_military_force() and character:military_force():is_army();
end;


--- @function char_has_navy
--- @desc Returns <code>true</code> if the supplied character has a navy military force, <code>false</code> otherwise.
--- @p character character
--- @return boolean has navy
function campaign_manager:char_has_navy(character)
	return character:has_military_force() and character:military_force():is_navy();
end;


--- @function char_is_agent
--- @desc Returns <code>true</code> if the supplied character is not a general, a colonel or a minister, <code>false</code> otherwise.
--- @p character character
--- @return boolean is agent
function campaign_manager:char_is_agent(character)
	return not (character:character_type("general") or character:character_type("colonel") or character:character_type("minister"));
end;


--- @function char_is_general
--- @desc Returns <code>true</code> if the supplied character is of type 'general', <code>false</code> otherwise.
--- @p character character
--- @return boolean is general
function campaign_manager:char_is_general(character)
	return character:character_type("general");
end;


--- @function char_is_victorious_general
--- @desc Returns <code>true</code> if the supplied character is a general that has been victorious (when?), <code>false</code> otherwise.
--- @p character character
--- @return boolean is victorious general
function campaign_manager:char_is_victorious_general(character)
	return character:character_type("general") and character:won_battle();
end;


--- @function char_is_defeated_general
--- @desc Returns <code>true</code> if the supplied character is a general that has been defeated (when?), <code>false</code> otherwise.
--- @p character character
--- @return boolean is defeated general
function campaign_manager:char_is_defeated_general(character)
	return character:character_type("general") and not character:won_battle();
end;


--- @function char_is_general_with_army
--- @desc Returns <code>true</code> if the supplied character is a general and has an army, <code>false</code> otherwise. This includes garrison commanders - to only return true if the army is mobile use @campaign_manager:char_is_mobile_general_with_army.
--- @p character character
--- @return boolean is general with army
function campaign_manager:char_is_general_with_army(character)
	return self:char_is_general(character) and self:char_has_army(character);
end;


--- @function char_is_mobile_general_with_army
--- @desc Returns <code>true</code> if the supplied character is a general, has an army, and can move around the campaign map, <code>false</code> otherwise.
--- @p character character
--- @return boolean is general with army
function campaign_manager:char_is_mobile_general_with_army(character)
	return self:char_is_general_with_army(character) and not character:military_force():is_armed_citizenry();
end;


--- @function char_is_general_with_navy
--- @desc Returns <code>true</code> if the supplied character is a general with a military force that is a navy, <code>false</code> otherwise.
--- @p character character
--- @return boolean is general with navy
function campaign_manager:char_is_general_with_navy(character)
	return cm:char_is_general(character) and self:char_has_navy(character);
end;


--- @function char_is_governor
--- @desc Returns <code>true</code> if the supplied character is the governor of a region, <code>false</code> otherwise.
--- @p character character
--- @return boolean is governor
function campaign_manager:char_is_governor(character)
	return character:has_region() and character:region():has_governor() and character:region():governor() == character;
end


--- @function char_is_in_region_list
--- @desc Returns <code>true</code> if the supplied character is currently in any region from a supplied list, <code>false</code> otherwise.
--- @p character character
--- @p table table of region keys
--- @return boolean is in region list
function campaign_manager:char_is_in_region_list(character, region_list)
	return table_contains(region_list, character:region():name());
end;


--- @function get_closest_visible_character_of_subculture
--- @desc Returns the closest character of the supplied subculture to the supplied faction. The subculture and faction are both specified by string key.
--- @desc Use this function sparingly, as it is quite expensive.
--- @p string faction key
--- @p string subculture key
--- @return character closest visible character
function campaign_manager:get_closest_visible_character_of_subculture(faction_key, subculture_key)
	local faction = cm:get_faction(faction_key);
	
	if not faction then
		script_error("ERROR: get_closest_visible_character_of_culture() called but couldn't find faction with supplied key [" .. tostring(faction_key) .. "]");
		return false;
	end;
	
	if not is_string(subculture_key) then
		script_error("ERROR: get_closest_visible_character_of_culture() called but supplied subculture key [" .. tostring(subculture_key) .. "] is not a string");
		return false;
	end;
		
	local closest_char = false;
	local closest_char_dist = 1000000000;
	
	-- get a list of chars of the supplied culture
	local faction_list = faction:factions_met();
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if current_faction:subculture() == subculture_key then		
			local char_list = current_faction:character_list();
			
			for j = 0, char_list:num_items() - 1 do
				local current_char = char_list:item_at(j);
				
				if current_char:is_visible_to_faction(faction_key) and (self:char_is_agent(current_char) or self:char_is_general(current_char)) then
					local closest_player_char, closest_player_char_dist = self:get_closest_character_from_faction(faction, current_char:logical_position_x(), current_char:logical_position_y());
					
					if closest_player_char_dist < closest_char_dist then
						closest_char_dist = closest_player_char_dist;
						closest_char = current_char;
					end;
				end;
			end;
		end;
	end;
	
	local closest_char_dist = closest_char_dist ^ 0.5;
	
	return closest_char, closest_char_dist;
end;


--- @function get_closest_character_from_faction
--- @desc Returns the closest character from the supplied faction to the supplied position. This includes characters such as politicians and garrison commanders that are not extant on the map.
--- @p faction faction
--- @p number x
--- @p number y
--- @return character closest character
function campaign_manager:get_closest_character_from_faction(faction, x, y)
	local closest_distance = 1000000000;
	local closest_character = false;
	
	local char_list = faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		local current_distance = distance_squared(x, y, current_char:logical_position_x(), current_char:logical_position_y());
		if current_distance < closest_distance then
			closest_distance = current_distance;
			closest_character = current_character;
		end;
	end;
	
	return closest_character, closest_distance;	
end;


--- @function character_can_reach_character
--- @desc Returns <code>true</code> if the supplied source character can reach the supplied target character this turn, <code>false</code> otherwise. The underlying test on the model interface returns false-positives if the source character has no action points - this wrapper function works around this problem by testing the source character's action points too.
--- @p character source character
--- @p character target character
--- @return boolean can reach
function campaign_manager:character_can_reach_character(source_char, target_char)
	if not is_character(source_char) then
		script_error("ERROR: character_can_reach_character() called but supplied source character [" .. tostring(source_char) .. "] is not a character");
		return false;
	end;
	
	if not is_character(target_char) then
		script_error("ERROR: character_can_reach_character() called but supplied target character [" .. tostring(target_char) .. "] is not a character");
		return false;
	end;
	
	return source_char:action_points_remaining_percent() > 0 and self:model():character_can_reach_character(source_char, target_char);
end;


--- @function character_can_reach_settlement
--- @desc Returns <code>true</code> if the supplied source character can reach the supplied target settlement this turn, <code>false</code> otherwise. The underlying test on the model interface returns false-positives if the source character has no action points - this wrapper function works around this problem by testing the source character's action points too.
--- @p character source character
--- @p settlement target settlement
--- @return boolean can reach
function campaign_manager:character_can_reach_settlement(source_char, target_settlement)
	if not is_character(source_char) then
		script_error("ERROR: character_can_reach_settlement() called but supplied source character [" .. tostring(source_char) .. "] is not a character");
		return false;
	end;
	
	if not is_settlement(target_settlement) then
		script_error("ERROR: character_can_reach_settlement() called but supplied target settlement [" .. tostring(target_settlement) .. "] is not a settlement");
		return false;
	end;
	
	return source_char:action_points_remaining_percent() > 0 and self:model():character_can_reach_settlement(source_char, target_settlement);
end;


--- @function general_with_forename_exists_in_faction_with_force
--- @desc Returns <code>true</code> if a general with a mobile military force exists in the supplied faction with the supplied forename. Faction and forename are specified by string key.
--- @p string faction key, Faction key.
--- @p string forename key, Forename key in the full localisation lookup format i.e. <code>[table]_[column]_[record_key]</code>.
--- @return boolean general exists
function campaign_manager:general_with_forename_exists_in_faction_with_force(faction_name, char_forename)
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		return false;
	end;
	
	local char_list = faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		if current_char:get_forename() == char_forename and cm:char_is_general(current_char) and current_char:has_military_force() and not current_char:military_force():is_armed_citizenry() then
			return true;
		end;
	end;
	
	return false;
end;


--- @function get_highest_ranked_general_for_faction
--- @desc Returns the general character in the supplied faction of the highest rank. The faction may be supplied as a faction object or may be specified by key.
--- @p object faction, Faction, either by faction object or by string key.
--- @return character highest ranked character
function campaign_manager:get_highest_ranked_general_for_faction(faction)
	if is_string(faction) then
		faction = cm:get_faction(faction)
	end;
	
	if not is_faction(faction) then
		script_error("ERROR: get_highest_ranked_general_for_faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;
	
	local char_list = faction:character_list();
	
	local current_rank = 0;
	local chosen_char = nil;
	local char_x = 0;
	local char_y = 0;
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		if self:char_is_general_with_army(current_char) then
			local rank = current_char:rank();
			
			if rank > current_rank then
				chosen_char = current_char;
				current_rank = rank;
			end;
		end;
	end;

	if chosen_char then
		return chosen_char;
	else
		return false;
	end;
end;


--- @function remove_all_units_from_general
--- @desc Removes all units from the military force the supplied general character commands.
--- @p character general character
--- @return number number of units removed
function campaign_manager:remove_all_units_from_general(character)
	
	if not is_character(character) then
		script_error("ERROR: remove_all_units_from_general() called but supplied character [" .. tostring(character) .. "] is not a character");
		return false;
	end;
	
	if not character:has_military_force() then
		return 0;
	end;
	
	local count = 0;
	local char_str = self:char_lookup_str(character);
	
	local unit_list = character:military_force():unit_list();
	
	for i = 1, unit_list:num_items() - 1 do
		self:remove_unit_from_character(char_str, unit_list:item_at(i):unit_key());
		count = count + 1;
	end;
	
	return count;
end;


--- @function get_regions_within_distance_of_character
--- @desc Returns a table of regions within the specified distance of a character
--- @p character character interface
--- @p number distance
--- @p boolean not razed
--- @p [opt=false] boolean return_unique_list
--- @return table Table of regions
function campaign_manager:get_regions_within_distance_of_character(character, distance, not_razed, return_unique_list)
	local nearby_regions = unique_table:new();
	local regions = cm:model():world():region_manager():region_list();
	local char_x = character:logical_position_x();
	local char_y = character:logical_position_y();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local settlement = region:settlement();
		local region_x = settlement:logical_position_x();
		local region_y = settlement:logical_position_y();
		local real_distance = distance_squared(char_x, char_y, region_x, region_y);

		if distance >= real_distance then
			if not_razed == false then
				nearby_regions:insert(region);
			elseif region:is_abandoned() == false then
				nearby_regions:insert(region);
			end
		end
	end
	if return_unique_list == true then
		return nearby_regions;
	end
	return nearby_regions:to_table();
end










-----------------------------------------------------------------------------
--- @section Faction Queries & Modification
-----------------------------------------------------------------------------


--- @function get_faction
--- @desc Gets a faction object by its string key. If no faction with the supplied key could be found then <code>false</code> is returned.
--- @p string faction key
--- @return faction faction
function campaign_manager:get_faction(key)
	if not is_string(key) then
		script_error("ERROR: get_faction() called but supplied faction name [" .. tostring(key) .. "] is not a string");
		return false;
	end;

	local world = self:model():world();
	
	if world:faction_exists(key) then
		return world:faction_by_key(key);
	end;
	
	return false;
end;


--- @function faction_contains_building
--- @desc Returns <code>true</code> if territories controlled by the supplied faction contain the supplied building. This won't work for horde buildings.
--- @p faction faction object
--- @p string building key
--- @return faction contains building
function campaign_manager:faction_contains_building(faction, building_key)
	if not is_faction(faction) then
		script_error("ERROR: faction_contains_building() called but supplied faction [" .. tostring(faction) .. "] is not a faction object");
		return false;
	end;

	local region_list = faction:region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local region = region_list:item_at(i);
		
		if region:building_exists(building_key) then
			return true;
		end;
	end;
	
	return false;
end;


--- @function num_characters_of_type_in_faction
--- @desc Returns the number of characters of the supplied type in the supplied faction.
--- @p faction faction object
--- @p string character type
--- @return number number of characters
function campaign_manager:num_characters_of_type_in_faction(faction, agent_type)
	if not is_faction(faction) then
		script_error("ERROR: num_characters_of_type_in_faction() called but supplied faction [" .. tostring(faction) .. "] is not a faction object");
		return false;
	end;
	
	local character_list = faction:character_list();
	
	if character_list:num_items() == 0 then
		return 0;
	end;
	
	local num_found = 0;
	for i = 0, character_list:num_items() - 1 do
		if character_list:item_at(i):character_type(agent_type) then
			num_found = num_found + 1;
		end;
	end;

	return num_found;
end;


--- @function kill_all_armies_for_faction
--- @desc Kills all armies in the supplied faction.
--- @p faction faction object
--- @return number number of armies killed
function campaign_manager:kill_all_armies_for_faction(faction)
	if not is_faction(faction) then
		script_error("ERROR: kill_all_armies_for_faction() called but supplied faction [" .. tostring(faction) .. "] is not a faction object");
		return false;
	end;

	local military_force_list = faction:military_force_list();
	local count = 0;
	
	for i = 0, military_force_list:num_items() - 1 do
		local mf = military_force_list:item_at(i);
		
		if mf:has_general() then
			self:kill_character(mf:general_character():cqi(), true, true);
			count = count + 1;
		end;
	end;
	
	if count == 0 then
		return 0;
	elseif count == 1 then
		out("### kill_all_armies_for_faction() just killed 1 force for faction " .. faction:name() .. " ###");
	else
		out("### kill_all_armies_for_faction() just killed " .. tostring(count) .. " forces for faction " .. faction:name() .. " ###");
	end;
	return count;
end;


--- @function get_trespasser_list_for_faction
--- @desc Returns a table of cqis of characters that are both at war with the specified faction and also trespassing on its territory.
--- @p faction faction object
--- @return table of character command queue indexes
function campaign_manager:get_trespasser_list_for_faction(faction)
	if not is_faction(faction) then
		script_error("ERROR: get_trespasser_list_for_faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;

	local retval = {};
	local faction_name = faction:name();
	
	-- go through all factions. If the current faction is at war with the specified faction, go through the
	-- current faction's military force leaders. If the character is in the subject faction's territory, note
	-- that character's cqi and faction in the table to return.
	local faction_list = faction:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if faction:at_war_with(current_faction) then
			local military_force_list = current_faction:military_force_list();

			for j = 0, military_force_list:num_items() - 1 do
				local military_force = military_force_list:item_at(j);
				
				if military_force:has_general() then
					local character = military_force:general_character();
					
					if character:has_region() and character:region():owning_faction():name() == faction_name then
						table.insert(retval, character:cqi());
					end;
				end;
			end;		
		end;
	end;

	return retval;
end;


--- @function number_of_units_in_faction
--- @desc Returns the number of units in all military forces in the supplied faction. The optional second parameter, if <code>true</code>, specifies that units in armed citizenry armies should not be considered in the calculation.
--- @p faction faction object
--- @p [opt=false] boolean exclude armed citizenry
--- @return number number of units
function campaign_manager:number_of_units_in_faction(faction, exclude_armed_citizenry)
	if not is_faction(faction) then
		script_error("ERROR: number_of_units_in_faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;
	
	local military_force_list = faction:military_force_list();
	local num_units = 0;
	
	for i = 0, military_force_list:num_items() - 1 do
		local mf = military_force_list:item_at(i);
		
		if not exclude_armed_citizenry or not mf:is_armed_citizenry() then
			num_units = num_units + mf:unit_list():num_items();
		end;
	end;
	
	return num_units;
end;


--- @function faction_is_alive
--- @desc Returns true if the supplied faction has a home region or any military forces. Note that what constitutes as "alive" for a faction changes between different projects so use with care.
--- @p faction faction object
--- @return boolean faction is alive
function campaign_manager:faction_is_alive(faction)
	if not is_faction(faction) then
		script_error("ERROR: faction_is_alive() called but supplied faction [" .. tostring(faction) .. "] is not a faction object");
		return false;
	end;

	return faction:has_home_region() or faction:military_force_list():num_items() > 0;
end;


--- @function faction_of_culture_is_alive
--- @desc Returns true if any faction with a culture corresponding to the supplied key is alive (uses @campaign_manager:faction_is_alive).
--- @p string culture key
--- @return boolean any faction is alive
function campaign_manager:faction_of_culture_is_alive(culture_key)
	if not is_string(culture_key) then
		script_error("ERROR: faction_of_culture_is_alive() called but supplied culture key [" .. tostring(culture_key) .. "] is not a string");
		return false;
	end;

	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:culture() == culture_key then
			if self:faction_is_alive(faction) then
				return true;
			end;
		end;
	end;
	
	return false;
end;


--- @function faction_of_subculture_is_alive
--- @desc Returns true if any faction with a subculture corresponding to the supplied key is alive (uses @campaign_manager:faction_is_alive).
--- @p string subculture key
--- @return boolean any faction is alive
function campaign_manager:faction_of_subculture_is_alive(subculture_key)
	if not is_string(subculture_key) then
		script_error("ERROR: faction_of_subculture_is_alive() called but supplied subculture key [" .. tostring(subculture_key) .. "] is not a string");
		return false;
	end;

	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:subculture() == subculture_key then
			if self:faction_is_alive(faction) then
				return true;
			end;
		end;
	end;
	
	return false;
end;


--- @function faction_has_armies_in_enemy_territory
--- @desc Returns <code>true</code> if the supplied faction has any armies in the territory of factions it's at war with, <code>false</code> otherwise.
--- @p faction faction
--- @return boolean has armies in enemy territory
function campaign_manager:faction_has_armies_in_enemy_territory(faction)
	if not is_faction(faction) then
		script_error("ERROR: faction_has_armies_in_enemy_territory() called but supplied faction [" .. tostring(faction) .. "] is not a faction object");
		return false;
	end;

	local mf_list = faction:military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		if current_mf:has_general() and not current_mf:is_armed_citizenry() then
			local character = current_mf:general_character();
			if character:has_region() then			
				local region = character:region();
				if not region:is_abandoned() then
					local owning_faction = region:owning_faction();
					if not owning_faction:is_null_interface() and owning_faction:at_war_with(faction) then
						return character;
					end;
				end;
			end;
		end;
	end;
	
	return false;
end;


--- @function faction_has_armies_in_region
--- @desc Returns <code>true</code> if the supplied faction has any armies in the supplied region, <code>false</code> otherwise.
--- @p faction faction
--- @p region region
--- @return boolean armies in region
function campaign_manager:faction_has_armies_in_region(faction, region)
	local mf_list = faction:military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		if current_mf:has_general() and not current_mf:is_armed_citizenry() then
			local character = current_mf:general_character();
			if character:has_region() and character:region() == region then
				return character;
			end;
		end;
	end;
	
	return false;
end;


--- @function faction_has_nap_with_faction
--- @desc Returns <code>true</code> if the supplied faction has any armies in the supplied region, <code>false</code> otherwise.
--- @p faction faction
--- @p region region
--- @return boolean armies in region
function campaign_manager:faction_has_nap_with_faction(faction_a, faction_b)
	if not is_faction(faction_a) then
		script_error("ERROR: faction_has_nap_with_faction() called but first supplied faction [" .. tostring(faction_a) .. "] is not a faction object");
		return false;
	end;
	
	if not is_faction(faction_b) then
		script_error("ERROR: faction_has_nap_with_faction() called but second supplied faction [" .. tostring(faction_b) .. "] is not a faction object");
		return false;
	end;

	local nap_list = faction_a:factions_non_aggression_pact_with();
	for i = 0, nap_list:num_items() - 1 do
		if nap_list:item_at(i) == faction_b then
			return true;
		end;
	end;
	return false;
end;


--- @function faction_has_trade_agreement_with_faction
--- @desc Returns <code>true</code> if the supplied faction has any armies in the supplied region, <code>false</code> otherwise.
--- @p faction faction
--- @p region region
--- @return boolean armies in region
function campaign_manager:faction_has_trade_agreement_with_faction(faction_a, faction_b)
	if not is_faction(faction_a) then
		script_error("ERROR: faction_has_trade_agreement_with_faction() called but first supplied faction [" .. tostring(faction_a) .. "] is not a faction object");
		return false;
	end;
	
	if not is_faction(faction_b) then
		script_error("ERROR: faction_has_trade_agreement_with_faction() called but second supplied faction [" .. tostring(faction_b) .. "] is not a faction object");
		return false;
	end;

	local trade_list = faction_a:factions_trading_with();
	for i = 0, trade_list:num_items() - 1 do
		if trade_list:item_at(i) == faction_b then
			return true;
		end;
	end;
	return false;
end;


--- @function get_border_regions_of_faction
--- @desc Returns a table of regions at the border of the supplied faction
--- @p faction faction
--- @p boolean outside_border True returns regions bordering the faction that do not belong to the faction, False returns a list of the factions regions at their border
--- @p [opt=false] boolean return_unique_list
--- @return table Table of regions
function campaign_manager:get_border_regions_of_faction(faction, outside_border, return_unique_list)
	local border_regions = unique_table:new();
	local regions = faction:region_list();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local adj_regions = region:adjacent_region_list();
		
		for j = 0, adj_regions:num_items() - 1 do
			local adj_region = adj_regions:item_at(j);
			local owner = adj_region:owning_faction();

			if owner:is_null_interface() == false and owner:is_faction(faction) == false then
				if outside_border == true then
					border_regions:insert(adj_region);
				elseif outside_border == false then
					border_regions:insert(adj_region);
					break;
				end
			end
		end
	end
	if return_unique_list == true then
		return border_regions;
	end
	return border_regions:to_table();
end


--- @function get_factions_that_border_faction
--- @desc Returns a table of factions that border the supplied faction
--- @p faction faction
--- @p [opt=false] boolean return_unique_list
--- @return table Table of factions
function campaign_manager:get_factions_that_border_faction(faction, return_unique_list)
	local border_factions = unique_table:new();
	local regions = faction:region_list();

	for i = 0, regions:num_items() - 1 do
		local region = regions:item_at(i);
		local adj_regions = region:adjacent_region_list();
		
		for j = 0, adj_regions:num_items() - 1 do
			local adj_region = adj_regions:item_at(j);
			local owner = adj_region:owning_faction();

			if owner:is_null_interface() == false and owner:is_faction(faction) == false then
				border_factions:insert(owner);
			end
		end
	end
	if return_unique_list == true then
		return border_factions;
	end
	return border_factions:to_table();
end


--- @function heal_all_units_for_faction
--- @desc Heals all units in military forces owned by the supplied faction to the specified health. The health may be supplied as a unary value i.e. <code>0 - 1</code>.
--- @p faction faction
--- @p [opt=1] @number unary health
function campaign_manager:heal_all_units_for_faction(faction, unary_value)
	unary_value = unary_value or 1;
	
	local mf_list = faction:military_force_list();

	for i = 0, mf_list:num_items() - 1 do
		local unit_list = mf_list:item_at(i):unit_list();

		for j = 0, unit_list:num_items() - 1 do
			local unit = unit_list:item_at(j);

			cm:set_unit_hp_to_unary_of_maximum(unit, unary_value);
		end
	end
end;










-----------------------------------------------------------------------------
--- @section Garrison Residence Queries
-----------------------------------------------------------------------------


--- @function garrison_contains_building
--- @desc Returns <code>true</code> if the supplied garrison residence contains a building with the supplied key, <code>false</code> otherwise.
--- @p garrison_residence garrison residence
--- @p string building key
--- @return boolean garrison contains building
function campaign_manager:garrison_contains_building(garrison, building_key)
	if not is_garrisonresidence(garrison) then
		script_error("ERROR: garrison_contains_building() called but supplied garrison residence [" .. tostring(garrison) .. "] is not a garrison residence object");
		return false;
	end;
	
	if not is_string(building_key) then
		script_error("ERROR: garrison_contains_building() called but supplied building key [" .. tostring(building_key) .. "] is not a string");
		return false;
	end;

	for i = 0, garrison:region():slot_list():num_items() - 1 do
		local slot = garrison:region():slot_list():item_at(i);

		if slot:has_building() and slot:building():name() == building_key then
			return true;
		end;
	end;

	return false;
end;


--- @function garrison_contains_building_chain
--- @desc Returns <code>true</code> if the supplied garrison residence contains a building with the supplied chain key, <code>false</code> otherwise.
--- @p garrison_residence garrison residence
--- @p string building chain key
--- @return boolean garrison contains building
function campaign_manager:garrison_contains_building_chain(garrison, chain_key)
	if not is_garrisonresidence(garrison) then
		script_error("ERROR: garrison_contains_building_chain() called but supplied garrison residence [" .. tostring(garrison) .. "] is not a garrison residence object");
		return false;
	end;
	
	if not is_string(chain_key) then
		script_error("ERROR: garrison_contains_building_chain() called but supplied building chain key [" .. tostring(chain_key) .. "] is not a string");
		return false;
	end;

	for i = 0, garrison:region():slot_list():num_items() - 1 do
		local slot = garrison:region():slot_list():item_at(i);
	
		if slot:has_building() and slot:building():chain() == chain_key then
			return true;
		end;	
	end;
	
	return false;
end;


--- @function garrison_contains_building_superchain
--- @desc Returns <code>true</code> if the supplied garrison residence contains a building with the supplied superchain key, <code>false</code> otherwise.
--- @p garrison_residence garrison residence
--- @p string building superchain key
--- @return boolean garrison contains building
function campaign_manager:garrison_contains_building_superchain(garrison, superchain_key)
	if not is_garrisonresidence(garrison) then
		script_error("ERROR: garrison_contains_building_superchain() called but supplied garrison residence [" .. tostring(garrison) .. "] is not a garrison residence object");
		return false;
	end;
	
	if not is_string(superchain_key) then
		script_error("ERROR: garrison_contains_building_superchain() called but supplied building superchain key [" .. tostring(superchain_key) .. "] is not a string");
		return false;
	end;

	for i = 0, garrison:region():slot_list():num_items() - 1 do
		local slot = garrison:region():slot_list():item_at(i);
	
		if slot:has_building() and slot:building():superchain() == superchain_key then
			return true;
		end;	
	end;
	
	return false;
end;


--- @function get_armed_citizenry_from_garrison
--- @desc Returns the garrison army from a garrison residence. By default this returns the land army armed citizenry - an optional flag instructs the function to return the naval armed citizenry instead.
--- @p garrison_residence garrison residence, Garrison residence.
--- @p [opt=false] boolean get naval, Returns the naval armed citizenry army, if set to <code>true</code>.
--- @return boolean armed citizenry army
function campaign_manager:get_armed_citizenry_from_garrison(garrison, naval_force_only)
	if not is_garrisonresidence(garrison) then
		script_error("ERROR: get_armed_citizenry_from_garrison() called but supplied garrison residence [" .. tostring(garrison) .. "] is not a garrison residence object");
		return false;
	end;

	-- return land force or naval force, depending on what the value of this flag is
	naval_force_only = not not naval_force_only;
	
	local mf_list = garrison:faction():military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		
		if current_mf:is_armed_citizenry() and current_mf:garrison_residence() == garrison then
			if naval_force_only then
				if current_mf:is_navy() then
					return current_mf;
				end;
			else
				if current_mf:is_army() then
					return current_mf;
				end;
			end;
		end;
	end;
	
	return false;
end;


-----------------------------------------------------------------------------
--- @section Military Force Queries
-----------------------------------------------------------------------------


--- @function military_force_average_strength
--- @desc Returns the average strength of all units in the military force. This is expressed as a percentage (0-100), so a returned value of 75 would indicate that the military force had lost 25% of its strength through casualties.
--- @p military_force military force
--- @return number average strength percentage
function campaign_manager:military_force_average_strength(military_force)
	if not is_militaryforce(military_force) then
		script_error("ERROR: military_force_average_strength() called but supplied military force [" .. tostring(military_force) .. "] is not a military force object");
		return false;
	end;

	local unit_list = military_force:unit_list();
	local num_units = unit_list:num_items();
	
	if num_units == 0 then
		return 0;
	end;
	
	local cumulative_health = 0;
	
	for i = 0, num_units - 1 do	
		cumulative_health = cumulative_health + unit_list:item_at(i):percentage_proportion_of_full_strength();
	end;
	
	return (cumulative_health / num_units);
end;


--- @function num_mobile_forces_in_force_list
--- @desc Returns the number of military forces that are not armed-citizenry in the supplied military force list. 
--- @p military_force_list military force list
--- @return number number of mobile forces
function campaign_manager:num_mobile_forces_in_force_list(military_force_list)
	if not is_militaryforcelist(military_force_list) then
		script_error("ERROR: num_mobile_forces_in_force_list() called but supplied military force list [" .. tostring(military_force_list) .. "] is not a military_force_list object");
		return false;
	end;

	local count = 0;
	
	for i = 0, military_force_list:num_items() - 1 do
		if not military_force_list:item_at(i):is_armed_citizenry() then
			count = count + 1;
		end;
	end;
	
	return count;
end;


--- @function proportion_of_unit_class_in_military_force
--- @desc Returns the unary proportion (0-1) of units in the supplied military force which are of the supplied unit class.
--- @p military_force military force
--- @p string unit class
--- @return proportion units of unit class
function campaign_manager:proportion_of_unit_class_in_military_force(military_force, unit_class)
	if not is_militaryforce(military_force) then
		script_error("ERROR: proportion_of_unit_class_in_military_force() called but supplied military force [" .. tostring(military_force) .. "] is not a military force object");
		return false;
	end;
	
	if not is_string(unit_class) then
		script_error("ERROR: proportion_of_unit_class_in_military_force() called but supplied unit class [" .. tostring(unit_class) .. "] is not a string");
		return false;
	end;

	local unit_list = military_force:unit_list();
	
	local num_items = unit_list:num_items();
	
	if num_items == 0 then
		return 0;
	end;
	
	local num_found = 0;
	for i = 0, num_items - 1 do
		if unit_list:item_at(i):unit_class() == unit_class then
			num_found = num_found + 1;
		end;
	end;
	
	return (num_found / num_items);
end;


--- @function military_force_contains_unit_type_from_list
--- @desc Returns <code>true</code> if the supplied military force contains any units of a type contained in the supplied unit type list, <code>false</code> otherwise.
--- @p military_force military force, Military force.
--- @p table unit type list, Unit type list. This must be supplied as a numerically indexed table of strings.
--- @return force contains unit from type list
function campaign_manager:military_force_contains_unit_type_from_list(military_force, unit_type_list)
	if not is_militaryforce(military_force) then
		script_error("ERROR: military_force_contains_unit_type_from_list() called but supplied military force [" .. tostring(military_force) .. "] is not a military force object");
		return false;
	end;
	
	if not is_table(unit_type_list) then
		script_error("ERROR: military_force_contains_unit_type_from_list() called but supplied  [" .. tostring(unit_type_list) .. "] is not a string");
		return false;
	end;

	for i = 0, military_force:unit_list():num_items() - 1 do
		local unit = military_force:unit_list():item_at(i);
		if table_contains(unit_type_list, unit:unit_key()) then
			return true;
		end;
	end;
	return false;
end;


--- @function military_force_contains_unit_class_from_list
--- @desc Returns <code>true</code> if the supplied military force contains any units of a class contained in the supplied unit class list, <code>false</code> otherwise.
--- @p military_force military force, Military force.
--- @p table unit class list, Unit class list. This must be supplied as a numerically indexed table of strings.
--- @return force contains unit from class list
function campaign_manager:military_force_contains_unit_class_from_list(military_force, unit_class_list)
	if not is_militaryforce(military_force) then
		script_error("ERROR: military_force_contains_unit_type_from_list() called but supplied military force [" .. tostring(military_force) .. "] is not a military force object");
		return false;
	end;
	
	if not is_table(unit_class_list) then
		script_error("ERROR: military_force_contains_unit_type_from_list() called but supplied  [" .. tostring(unit_class_list) .. "] is not a string");
		return false;
	end;
	
	for i = 0, military_force:unit_list():num_items() - 1 do
		if table_contains(unit_class_list, military_force:unit_list():item_at(i):unit_class()) then
			return true;
		end;
	end;
	return false;
end;


--- @function force_from_general_cqi
--- @desc Returns the force whose commanding general has the passed cqi. If no force is found then <code>false</code> is returned.
--- @p number general cqi
--- @return military force force
function campaign_manager:force_from_general_cqi(general_cqi)
	local general_obj = cm:model():character_for_command_queue_index(general_cqi);
	
	if general_obj:is_null_interface() == false then
		if general_obj:has_military_force() then
			return general_obj:military_force();
		end
	end
	return false;
end;


--- @function force_gold_value
--- @desc Returns the gold value of all of the units in the force.
--- @p number force cqi
--- @return number value
function campaign_manager:force_gold_value(force_cqi)
	local force_obj = cm:model():military_force_for_command_queue_index(force_cqi);
	local force_value = 0;
	
	if force_obj:is_null_interface() == false then
		local unit_list = force_obj:unit_list();
		
		for i = 0, unit_list:num_items() - 1 do
			local unit = unit_list:item_at(i);
			
			if unit:is_null_interface() == false then
				force_value = force_value + (unit:get_unit_custom_battle_cost() * unit:percentage_proportion_of_full_strength() * 0.01);
			end
		end
	end
	return force_value;
end










-----------------------------------------------------------------------------
--- @section Region Queries & Modification
-----------------------------------------------------------------------------


--- @function get_region
--- @desc Returns a region object with the supplied region name. If no such region is found then <code>false</code> is returned.
--- @p string region name
--- @return region region
function campaign_manager:get_region(region_name)
	if not is_string(region_name) then
		script_error("ERROR: get_region() called but supplied region name [" .. tostring(region_name) .. "] is not a string");
		return false;
	end;
	
	local region = self:model():world():region_manager():region_by_key(region_name);
	
	if is_region(region) then
		return region;
	end;
	
	return false;
end;


--- @function is_region_owned_by_faction
--- @desc Returns true if the specified region is owned by the specified faction.
--- @p @string region name
--- @p @string faction name
--- @return @boolean region is owned by faction
function campaign_manager:is_region_owned_by_faction(region_name, faction_name)
	if not is_string(region_name) then
		script_error("ERROR: is_region_owned_by_faction() called but supplied region name [" .. tostring(region_name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_name) then
		script_error("ERROR: is_region_owned_by_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	local region = self:model():world():region_manager():region_by_key(region_name);
	
	if not is_region(region) then
		script_error("ERROR: is_region_owned_by_faction() called but couldn't find a region with supplied name [" .. tostring(region_name) .. "]");
		return false;
	end;
	
	return (region:owning_faction():name() == faction_name);
end;


--- @function region_has_neighbours_of_other_religion
--- @desc Returns <code>true</code> if a specified region has any neighbouring regions with a different religion, <code>false</code> otherwise.
--- @p region subject region
--- @return boolean region has neighbour of different religion
function campaign_manager:region_has_neighbours_of_other_religion(region)
	if not is_region(region) then
		script_error("ERROR: region_has_neighbours_of_other_religion() called but supplied region [" .. tostring(region) .. "] is not a region object");
		return false;
	end;

	local majority_religion = region:majority_religion();

	for i = 0, region:adjacent_region_list():num_items() - 1 do
		if majority_religion ~= region:adjacent_region_list():item_at(i):majority_religion() then
			return true;
		end;
	end;
	
	return false;
end;


--- @function instantly_upgrade_building_in_region
--- @desc Instantly upgrades the building in the supplied slot to the supplied building key.
--- @p SLOT_SCRIPT_INTERFACE slot
--- @p string target building key
function campaign_manager:instantly_upgrade_building_in_region(slot, target_building_key)
	if not is_string(target_building_key) then
		script_error("ERROR: instantly_upgrade_building_in_region() called but supplied target building key [" .. tostring(target_building_key) .. "] is not a string");
		return false;
	end;
	
	self.game_interface:region_slot_instantly_upgrade_building(slot, target_building_key);
end;


--- @function instantly_dismantle_building_in_region
--- @desc Instantly dismantles the building in the supplied slot number of the supplied region.
--- @p SLOT_SCRIPT_INTERFACE slot
function campaign_manager:instantly_dismantle_building_in_region(slot)
	self.game_interface:instantly_dismantle_building(slot);
end;


--- @function get_most_pious_region_for_faction_for_religion
--- @desc Returns the region held by a specified faction that has the highest proportion of a specified religion. The numeric religion proportion is also returned.
--- @p faction subject faction
--- @p string religion key
--- @return region most pious region
--- @return number religion proportion
function campaign_manager:get_most_pious_region_for_faction_for_religion(faction, religion_key)
	local region_list = faction:region_list();
	
	local highest_religion_region = false;
	local highest_religion_amount = 0;
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		local current_region_religion_amount = current_region:religion_proportion(religion_key);
		
		if current_region_religion_amount > highest_religion_amount then
			highest_religion_region = current_region;
			highest_religion_amount = current_region_religion_amount;
		end;
	end;

	return highest_religion_region, highest_religion_amount;
end;


--- @function create_storm_for_region
--- @desc Creates a storm of a given type in a given region. This calls the @episodic_scripting:create_storm_for_region function of the same name on the underlying episodic scripting interface, but adds validation and output.
--- @p string region key
--- @p number storm strength
--- @p number duration
--- @p string storm type
function campaign_manager:create_storm_for_region(region_key, strength, duration, storm_type)
	if not is_string(region_key) then
		script_error("ERROR: create_storm_for_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(strength) or strength < 1 then
		script_error("ERROR: create_storm_for_region() called but supplied strength value [" .. tostring(strength) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(duration) or duration < 0 then
		script_error("ERROR: create_storm_for_region() called but supplied duration value [" .. tostring(duration) .. "] is not a positive number");
		return false;
	end;
	
	if not is_string(storm_type) then
		script_error("ERROR: create_storm_for_region() called but supplied storm_type string [" .. tostring(storm_type) .. "] is not a string");
		return false;
	end;
	
	out("* create_storm_for_region() called, creating storm type [" .. storm_type .. "] in region [" .. region_key .. "]");

	self.game_interface:create_storm_for_region(region_key, strength, duration, storm_type);
end;












-----------------------------------------------------------------------------
--- @section Settlement Queries
-----------------------------------------------------------------------------


--	returns display or logical position of a settlement - for internal use, call
--	settlement_display_pos() or settlement_logical_pos() externally
function settlement_pos(settlement_name, display)
	if not is_string(settlement_name) then
		script_error("ERROR: settlement_pos() called but supplied name [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	local settlement = self:model():world():region_manager():settlement_by_key(settlement_name);
	
	if not settlement then
		script_error("ERROR: settlement_pos() called but no settlement found with supplied name [" .. settlement_name .. "]");
		return false;
	end;
	
	if display then
		return settlement:display_position_x(), settlement:display_position_y();
	else
		return settlement:logical_position_x(), settlement:logical_position_y();
	end;
end;


--- @function settlement_display_pos
--- @desc Returns the display position of a supplied settlement by string name.
--- @p string settlement name
--- @return number x display position
--- @return number y display position
function campaign_manager:settlement_display_pos(settlement_name)
	return self:settlement_pos(settlement_name, true);
end;


--- @function settlement_logical_pos
--- @desc Returns the logical position of a supplied settlement by string name.
--- @p string settlement name
--- @return number x logical position
--- @return number y logical position
function campaign_manager:settlement_logical_pos(settlement_name)
	return self:settlement_pos(settlement_name, false);
end;











-----------------------------------------------------------------------------
--- @section Pending Battle Cache
--- @desc Using the standard @"campaign_index:Model Hierarchy" interfaces it can be difficult to get information about a battle after it has been fought. The only method of querying the forces that fought in a battle is through the character interface (of the respective army commanders), and if they died in battle this will no longer be available.
--- @desc The pending battle cache system stores information about a battle prior to it being fought, which can be queried after the battle. This allows the factions, characters, and military forces involved to be queried even if they died in the battle. The information will remain available for querying until the next battle occurs.
--- @desc The data in the cache may also be queried prior to battle. The script triggers a <code>ScriptEventPendingBattle</code> event after a <code>PendingBattle</code> event is received and the pending battle cache has been populated. Scripts that want to query the pending battle cache prior to battle can listen for this.
-----------------------------------------------------------------------------


-- called internally
function campaign_manager:start_pending_battle_cache()
	core:add_listener(
		"pending_battle_cache",
		"PendingBattle",
		true,
		function(context) self:cache_pending_battle(context) end,
		true
	);
	
	-- removed this, as removing the characters from the pending battle cache when they withdraw can cause issues, such
	-- as the progress_on_battle_completed listener never progressing
	--[[
	core:add_listener(
		"character_withdraw_cache",
		"CharacterWithdrewFromBattle",
		true,
		function(context) self:pending_battle_cache_remove_character(context) end,
		true
	);
	]]
end;


-- removes a character from the pending battle cache (no longer called any more)
function campaign_manager:pending_battle_cache_remove_character(context)
	local char = context:character();
	
	-- attempt to remove from attacker list
	for i = 1, #self.pending_battle_cached_attackers do
		local current_cached_attacker = self.pending_battle_cached_attackers[i];
		
		if current_cached_attacker.cqi == char:cqi() then
			table.remove(self.pending_battle_cached_attackers, i);
			
			-- if we have no attackers left, then clear the defender list as well
			if #self.pending_battle_cached_attackers == 0 then
				self.pending_battle_cached_defenders = {};
			end;
			
			return;
		end;
	end;
	
	-- attempt to remove from defender list
	for i = 1, #self.pending_battle_cached_defenders do
		local current_cached_defender = self.pending_battle_cached_defenders[i];
		
		if current_cached_defender.cqi == char:cqi() then
			table.remove(self.pending_battle_cached_defenders, i);
			
			-- if we have no defenders left, then clear the attacker list as well
			if #self.pending_battle_cached_defenders == 0 then
				self.pending_battle_cached_attackers = {};
			end;
			
			return;
		end;
	end;
end;


-- caches a pending battle character within a pending battle
function campaign_manager:cache_pending_battle_character(list, character)
	local record = {};
	
	record.cqi = character:cqi();
	record.faction_name = character:faction():name();
	record.subtype = character:character_subtype_key();
	
	if character:has_military_force() then
		record.mf_cqi = character:military_force():command_queue_index();
	else
		script_error("WARNING: cache_pending_battle_character() called but supplied character (cqi: [" .. character:cqi() .. "], faction name: [" .. character:faction():name() .. "]) has no military force, how can this be? Not going to add CQI.");
		return;
	end;
	
	table.insert(list, record);
end;


-- caches a pending battle
function campaign_manager:cache_pending_battle(context)
	local pb = context:pending_battle();

	local attackers = {};
	local defenders = {};
	local attacker_value = 0;
	local defender_value = 0;
	
	-- cache attackers
	
	-- primary
	if pb:has_attacker() then
		self:cache_pending_battle_character(attackers, pb:attacker());
		attacker_value = attacker_value + self:force_gold_value(pb:attacker():military_force():command_queue_index());
	end;
	
	-- secondary
	local secondary_attacker_list = pb:secondary_attackers();
	for i = 0, secondary_attacker_list:num_items() - 1 do
		local attacker = secondary_attacker_list:item_at(i);
		self:cache_pending_battle_character(attackers, attacker);
		
		if pb:night_battle() == false and pb:ambush_battle() == false then
			attacker_value = attacker_value + self:force_gold_value(attacker:military_force():command_queue_index());
		end
	end;
	
	-- cache defenders
	
	-- defenders
	if pb:has_defender() then
		self:cache_pending_battle_character(defenders, pb:defender());
		defender_value = defender_value + self:force_gold_value(pb:defender():military_force():command_queue_index());
	end;
	
	-- defenders
	local secondary_defenders_list = pb:secondary_defenders();
	for i = 0, secondary_defenders_list:num_items() - 1 do
		local defender = secondary_defenders_list:item_at(i);
		self:cache_pending_battle_character(defenders, secondary_defenders_list:item_at(i));
		
		if pb:night_battle() == false and pb:ambush_battle() == false then
			defender_value = defender_value + self:force_gold_value(defender:military_force():command_queue_index());
		end
	end;
	
	if attacker_value < 1 then
		attacker_value = 1;
	end
	if defender_value < 1 then
		defender_value = 1;
	end
	
	self.pending_battle_cached_attackers = attackers;
	self.pending_battle_cached_defenders = defenders;
	self.pending_battle_cached_attacker_value = attacker_value;
	self.pending_battle_cached_defender_value = defender_value;
	
	self:set_pending_battle_svr_state(context);
	
	if not self:is_multiplayer() and self:is_local_players_turn() then
		self:print_pending_battle_cache();
	end;
	
	core:trigger_event("ScriptEventPendingBattle", pb);
end;


-- output for pending battle cache system - can be used for debugging, and it happens automatically when a PendingBattle event occurs
function campaign_manager:print_pending_battle_cache()
	local attackers = self.pending_battle_cached_attackers;
	local defenders = self.pending_battle_cached_defenders;

	out("*****");
	out("printing pending battle cache");
	out("\tattackers:");
	for i = 1, #attackers do
		local current_record = attackers[i];
		out("\t\t" .. i .. " faction: [" .. current_record.faction_name .. "], char cqi: [" .. current_record.cqi .. "], mf cqi: [" .. current_record.mf_cqi .. "]");
	end;
	out("\tdefenders:");
	for i = 1, #defenders do
		local current_record = defenders[i];
		out("\t\t" .. i .. " faction: [" .. current_record.faction_name .. "], char cqi: [" .. current_record.cqi .. "], mf cqi: [" .. current_record.mf_cqi .. "]");
	end;
	out("*****");
end;


-- called when the game is saving
function campaign_manager:pending_battle_cache_to_string()
	local attackers = self.pending_battle_cached_attackers;
	local defenders = self.pending_battle_cached_defenders;

	-- pack data into strings for saving
	local attacker_str = "";
	for i = 1, #attackers do
		local current_record = attackers[i];
		if current_record.subtype then
			attacker_str = attacker_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. "," .. current_record.subtype .. ";";
		elseif current_record.mf_cqi then
			-- support for old savegames with no char subtype embedded
			attacker_str = attacker_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. ";";
		else
			-- support for old savegames with no military force cqi embedded
			attacker_str = attacker_str .. current_record.cqi .. "," .. current_record.faction_name .. ";";
		end;
	end;
	
	local defender_str = "";
	for i = 1, #defenders do
		local current_record = defenders[i];
		if current_record.subtype then
			defender_str = defender_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. "," .. current_record.subtype .. ";";
		elseif current_record.mf_cqi then
			-- support for old savegames with no char subtype embedded
			defender_str = defender_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. ";";
		else
			-- support for old savegames with no military force cqi embedded
			defender_str = defender_str .. current_record.cqi .. "," .. current_record.faction_name .. ";";
		end;
	end;

	self.pending_battle_cached_attacker_str = attacker_str;
	self.pending_battle_cached_defender_str = defender_str;
end;


-- called when the game is loading
function campaign_manager:pending_battle_cache_from_string()
	self.pending_battle_cached_attackers = self:pending_battle_cache_table_from_string(self.pending_battle_cached_attacker_str);
	self.pending_battle_cached_defenders = self:pending_battle_cache_table_from_string(self.pending_battle_cached_defender_str);
end;


function campaign_manager:pending_battle_cache_table_from_string(str)
	local list = {};
	
	local pointer = 1;
	while true do
		local next_record_terminator = string.find(str, ";", pointer);

		local next_separator = string.find(str, ",", pointer);
		
		if not next_separator then
			break;
		end;
		
		local record = {};
		
		local cqi_str = string.sub(str, pointer, next_separator - 1);
		local cqi = tonumber(cqi_str);
		
		if not cqi then
			script_error("ERROR: pending_battle_cache_table_from_string() could not convert character cqi string [" .. tostring(cqi_str) .. "] into a number, inserting -1");
			cqi = -1;
		end;
		
		record.cqi = cqi;
		
		pointer = next_separator + 1;
		next_separator = string.find(str, ",", pointer);
		
		-- temp support for savegames that have no military force cqis embedded
		if next_separator and next_separator < next_record_terminator then
			local mf_cqi_str = string.sub(str, pointer, next_separator - 1);
			local mf_cqi = tonumber(mf_cqi_str);
			
			if not mf_cqi then
				script_error("ERROR: pending_battle_cache_table_from_string() could not convert military force cqi string [" .. tostring(mf_cqi_str) .. "] into a number, inserting -1");
				cqi = -1;
			end;
			
			record.mf_cqi = mf_cqi;
			
			pointer = next_separator + 1;
		end;
		
		next_separator = string.find(str, ",", pointer);

		-- temp support for savegames that have no subtype embedded
		if not next_separator or next_separator > next_record_terminator then
			next_separator = next_record_terminator;

			local faction_name = string.sub(str, pointer, next_separator - 1);
			record.faction_name = faction_name;

			pointer = next_separator + 1;
		else
			local faction_name = string.sub(str, pointer, next_separator - 1);
			record.faction_name = faction_name;

			pointer = next_separator + 1;

			next_separator = string.find(str, ";", pointer);

			local subtype = string.sub(str, pointer, next_separator - 1);
			record.subtype = subtype;
			
			pointer = next_separator + 1;
		end;
		
		table.insert(list, record);
	end;
	
	return list;
end;


--- @function pending_battle_cache_num_attackers
--- @desc Returns the number of attacking armies in the cached pending battle.
--- @return @number number of attacking armies
function campaign_manager:pending_battle_cache_num_attackers()
	return #self.pending_battle_cached_attackers;
end;


--- @function pending_battle_cache_get_attacker
--- @desc Returns records relating to a particular attacker in the cached pending battle. The attacker is specified by numerical index, with the first being accessible at record 1. This function returns the cqi of the commanding character, the cqi of the military force, and the faction name.
--- @p @number index of attacker
--- @return @number character cqi
--- @return @number military force cqi
--- @return @string faction name
--- @new_example print attacker details
--- @example for i = 1, cm:pending_battle_cache_num_attackers() do
--- @example 	local char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_attacker(i);
--- @example 	out("Attacker " .. i .. " of faction " .. faction_name .. ":");
--- @example 	out("\tcharacter cqi: " .. char_cqi);
--- @example	out("\tmilitary force cqi: " .. mf_cqi);
--- @example end
function campaign_manager:pending_battle_cache_get_attacker(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_attackers then
		script_error("ERROR: pending_battle_cache_get_attacker() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_attackers[index].cqi, self.pending_battle_cached_attackers[index].mf_cqi, self.pending_battle_cached_attackers[index].faction_name;
end;


--- @function pending_battle_cache_get_attacker_faction_name
--- @desc Returns just the faction name of a particular attacker in the cached pending battle. The attacker is specified by numerical index, with the first being accessible at record 1.
--- @p @number index of attacker
--- @return @string faction name
function campaign_manager:pending_battle_cache_get_attacker_faction_name(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_attackers then
		script_error("ERROR: pending_battle_cache_get_attacker_faction_name() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_attackers[index].faction_name;
end;


--- @function pending_battle_cache_get_attacker_subtype
--- @desc Returns just the subtype of a particular attacker in the cached pending battle. The attacker is specified by numerical index, with the first being accessible at record 1.
--- @p @number index of attacker
--- @return @string subtype
function campaign_manager:pending_battle_cache_get_attacker_subtype(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_attackers then
		script_error("ERROR: pending_battle_cache_get_attacker_subtype() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_attackers[index].subtype;
end;


--- @function pending_battle_cache_num_defenders
--- @desc Returns the number of defending armies in the cached pending battle.
--- @return @number number of defending armies
function campaign_manager:pending_battle_cache_num_defenders()
	return #self.pending_battle_cached_defenders;
end;


--- @function pending_battle_cache_get_defender
--- @desc Returns records relating to a particular defender in the cached pending battle. The defender is specified by numerical index, with the first being accessible at record 1. This function returns the cqi of the commanding character, the cqi of the military force, and the faction name.
--- @p @number index of defender
--- @return @number character cqi
--- @return @number military force cqi
--- @return @string faction name
--- @new_example print defender details
--- @example for i = 1, cm:pending_battle_cache_num_defenders() do
--- @example 	local char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_defender(i);
--- @example 	out("Defender " .. i .. " of faction " .. faction_name .. ":");
--- @example 	out("\tcharacter cqi: " .. char_cqi);
--- @example	out("\tmilitary force cqi: " .. mf_cqi);
--- @example end
function campaign_manager:pending_battle_cache_get_defender(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_defenders then
		script_error("ERROR: pending_battle_cache_get_defender() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_defenders[index].cqi, self.pending_battle_cached_defenders[index].mf_cqi, self.pending_battle_cached_defenders[index].faction_name;
end;


--- @function pending_battle_cache_get_defender_faction_name
--- @desc Returns just the faction name of a particular defender in the cached pending battle. The defender is specified by numerical index, with the first being accessible at record 1.
--- @p @number index of defender
--- @return @string faction name
function campaign_manager:pending_battle_cache_get_defender_faction_name(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_defenders then
		script_error("ERROR: pending_battle_cache_get_defender_faction_name() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_defenders[index].faction_name;
end;


--- @function pending_battle_cache_get_defender_subtype
--- @desc Returns just the subtype of a particular defender in the cached pending battle. The defender is specified by numerical index, with the first being accessible at record 1.
--- @p @number index of defender
--- @return @string subtype
function campaign_manager:pending_battle_cache_get_defender_subtype(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_defenders then
		script_error("ERROR: pending_battle_cache_get_defender_subtype() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	return self.pending_battle_cached_defenders[index].subtype;
end;


--- @function pending_battle_cache_faction_is_attacker
--- @desc Returns <code>true</code> if the faction was an attacker (primary or reinforcing) in the cached pending battle.
--- @p @string faction key
--- @return @boolean faction was attacker
function campaign_manager:pending_battle_cache_faction_is_attacker(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: pending_battle_cache_faction_is_attacker() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_faction_name == faction_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_faction_is_defender
--- @desc Returns <code>true</code> if the faction was a defender (primary or reinforcing) in the cached pending battle.
--- @p @string faction key
--- @return @boolean faction was defender
function campaign_manager:pending_battle_cache_faction_is_defender(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: pending_battle_cache_faction_is_defender() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_faction_name == faction_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_faction_is_involved
--- @desc Returns <code>true</code> if the faction was involved in the cached pending battle as either attacker or defender.
--- @p @string faction key
--- @return @boolean faction was involved
function campaign_manager:pending_battle_cache_faction_is_involved(faction_name)
	return self:pending_battle_cache_faction_is_attacker(faction_name) or self:pending_battle_cache_faction_is_defender(faction_name);
end;


--- @function pending_battle_cache_human_is_attacker
--- @desc Returns <code>true</code> if any of the attacking factions involved in the cached pending battle were human controlled (whether local or not).
--- @return @boolean human was attacking
function campaign_manager:pending_battle_cache_human_is_attacker()
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		local faction = cm:get_faction(current_faction_name);
		
		if faction and faction:is_human() then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_human_is_defender
--- @desc Returns <code>true</code> if any of the defending factions involved in the cached pending battle were human controlled (whether local or not).
--- @return @boolean human was defending
function campaign_manager:pending_battle_cache_human_is_defender()
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		local faction = cm:get_faction(current_faction_name);
		
		if faction and faction:is_human() then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_human_is_involved
--- @desc Returns <code>true</code> if any of the factions involved in the cached pending battle on either side were human controlled (whether local or not).
--- @return @boolean human was involved
function campaign_manager:pending_battle_cache_human_is_involved()
	return self:pending_battle_cache_human_is_attacker() or self:pending_battle_cache_human_is_defender();
end;


--- @function pending_battle_cache_culture_is_attacker
--- @desc Returns <code>true</code> if any of the attacking factions in the cached pending battle are of the supplied culture.
--- @p @string culture key
--- @return @boolean any attacker was culture
function campaign_manager:pending_battle_cache_culture_is_attacker(culture_name)
	if not is_string(culture_name) then
		script_error("ERROR: pending_battle_cache_culture_is_attacker() called but supplied culture name [" .. tostring(culture_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		local faction = self:get_faction(current_faction_name);

		if faction and faction:culture() == culture_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_culture_is_defender
--- @desc Returns <code>true</code> if any of the defending factions in the cached pending battle are of the supplied culture.
--- @p @string culture key
--- @return @boolean any defender was culture
function campaign_manager:pending_battle_cache_culture_is_defender(culture_name)
	if not is_string(culture_name) then
		script_error("ERROR: pending_battle_cache_culture_is_defender() called but supplied culture name [" .. tostring(culture_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		local faction = self:get_faction(current_faction_name);

		if faction and faction:culture() == culture_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_culture_is_involved
--- @desc Returns <code>true</code> if any of the factions involved in the cached pending battle on either side match the supplied culture.
--- @p @string culture key
--- @return @boolean culture was involved
function campaign_manager:pending_battle_cache_culture_is_involved(culture_name)
	return self:pending_battle_cache_culture_is_attacker(culture_name) or self:pending_battle_cache_culture_is_defender(culture_name);
end;


--- @function pending_battle_cache_subculture_is_attacker
--- @desc Returns <code>true</code> if any of the attacking factions in the cached pending battle are of the supplied subculture.
--- @p @string subculture key
--- @return @boolean any attacker was subculture
function campaign_manager:pending_battle_cache_subculture_is_attacker(subculture_name)
	if not is_string(subculture_name) then
		script_error("ERROR: pending_battle_cache_subculture_is_attacker() called but supplied subculture name [" .. tostring(subculture_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		local faction = self:get_faction(current_faction_name);

		if faction and faction:subculture() == subculture_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_subculture_is_defender
--- @desc Returns <code>true</code> if any of the defending factions in the cached pending battle are of the supplied subculture.
--- @p @string subculture key
--- @return @boolean any defender was subculture
function campaign_manager:pending_battle_cache_subculture_is_defender(subculture_name)
	if not is_string(subculture_name) then
		script_error("ERROR: pending_battle_cache_subculture_is_defender() called but supplied subculture name [" .. tostring(subculture_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		local faction = self:get_faction(current_faction_name);

		if faction and faction:subculture() == subculture_name then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_subculture_is_involved
--- @desc Returns <code>true</code> if any of the factions involved in the cached pending battle on either side match the supplied subculture.
--- @p @string subculture key
--- @return @boolean subculture was involved
function campaign_manager:pending_battle_cache_subculture_is_involved(subculture_name)
	return self:pending_battle_cache_subculture_is_attacker(subculture_name) or self:pending_battle_cache_subculture_is_defender(subculture_name);
end;


--- @function pending_battle_cache_char_is_attacker
--- @desc Returns <code>true</code> if the supplied character was an attacker in the cached pending battle.
--- @p object character, Character to query. May be supplied as a character object or as a cqi number.
--- @return boolean character was attacker
function campaign_manager:pending_battle_cache_char_is_attacker(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_char_cqi == char_cqi then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_char_is_defender
--- @desc Returns <code>true</code> if the supplied character was a defender in the cached pending battle.
--- @p object character, Character to query. May be supplied as a character object or as a cqi number.
--- @return boolean character was defender
function campaign_manager:pending_battle_cache_char_is_defender(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_char_cqi == char_cqi then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_char_is_involved
--- @desc Returns <code>true</code> if the supplied character was an attacker or defender in the cached pending battle.
--- @p object character, Character to query. May be supplied as a character object or as a cqi number.
--- @return boolean character was involved
function campaign_manager:pending_battle_cache_char_is_involved(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	return self:pending_battle_cache_char_is_attacker(char_cqi) or self:pending_battle_cache_char_is_defender(char_cqi);
end;


--- @function pending_battle_cache_mf_is_attacker
--- @desc Returns <code>true</code> if the supplied military force was an attacker in the cached pending battle.
--- @p number cqi, Command-queue-index of the military force to query.
--- @return boolean force was attacker
function campaign_manager:pending_battle_cache_mf_is_attacker(obj)
	local mf_cqi;
	
	if is_militaryforce(obj) then
		mf_cqi = obj:command_queue_index();
	else
		mf_cqi = obj;
	end;
	
	-- cast it to string
	mf_cqi = tostring(mf_cqi);
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_mf_cqi == mf_cqi then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_mf_is_defender
--- @desc Returns <code>true</code> if the supplied military force was a defender in the cached pending battle.
--- @p number cqi, Command-queue-index of the military force to query.
--- @return boolean force was defender
function campaign_manager:pending_battle_cache_mf_is_defender(obj)
	local mf_cqi;
	
	if is_militaryforce(obj) then
		mf_cqi = obj:command_queue_index();
	else
		mf_cqi = obj;
	end;
	
	-- cast it to string
	mf_cqi = tostring(mf_cqi);
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_mf_cqi == mf_cqi then
			return true;
		end;
	end;
	
	return false;
end;


--- @function pending_battle_cache_mf_is_involved
--- @desc Returns <code>true</code> if the supplied military force was an attacker or defender in the cached pending battle.
--- @p number cqi, Command-queue-index of the military force to query.
--- @return boolean force was involved
function campaign_manager:pending_battle_cache_mf_is_involved(obj)
	local mf_cqi;

	-- support passing in the actual character
	if is_militaryforce(obj) then
		mf_cqi = obj:cqi();
	else
		mf_cqi = obj;
	end;
	
	return self:pending_battle_cache_mf_is_attacker(mf_cqi) or self:pending_battle_cache_mf_is_defender(mf_cqi);
end;


--- @function pending_battle_cache_get_enemies_of_char
--- @desc Returns a numerically indexed table of character objects, each representing an enemy character of the supplied character in the cached pending battle. If the supplied character was not present in the pending battle then the returned table will be empty.
--- @p character character to query
--- @return table table of enemy characters
function campaign_manager:pending_battle_cache_get_enemies_of_char(character)
	if not is_character(character) then
		script_error("ERROR: pending_battle_cache_get_enemies_of_character() called but supplied character [" .. tostring(character) .. "] is not a character");
		return false;
	end;
	
	local retval = {};

	if self:pending_battle_cache_char_is_attacker(character) then
		for i = 1, self:pending_battle_cache_num_defenders() do
			table.insert(retval, self:get_character_by_cqi(self:pending_battle_cache_get_defender(i)));
		end;
	
	elseif self:pending_battle_cache_char_is_defender(character) then
		for i = 1, self:pending_battle_cache_num_attackers() do
			table.insert(retval, self:get_character_by_cqi(self:pending_battle_cache_get_attacker(i)));
		end;
	end;
	
	return retval;
end;


--- @function pending_battle_cache_is_quest_battle
--- @desc Returns <code>true</code> if any of the participating factions in the pending battle are quest battle factions, <code>false</code> otherwise.
--- @return boolean is quest battle
function campaign_manager:pending_battle_cache_is_quest_battle()
	for i = 1, self:pending_battle_cache_num_defenders() do
		local faction = self:get_faction(self:pending_battle_cache_get_defender_faction_name(i));
		
		if faction and faction:is_quest_battle_faction() then
			return true;
		end;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local faction = self:get_faction(self:pending_battle_cache_get_attacker_faction_name(i));
		
		if faction and faction:is_quest_battle_faction() then
			return true;
		end;
	end;
end;


--- @function pending_battle_cache_attacker_victory
--- @desc Returns <code>true</code> if the pending battle has been won by the attacker, <code>false</code> otherwise.
--- @return boolean attacker has won
function campaign_manager:pending_battle_cache_attacker_victory()
	return not not string.find(self:model():pending_battle():attacker_battle_result(), "victory");
end;


--- @function pending_battle_cache_defender_victory
--- @desc Returns <code>true</code> if the pending battle has been won by the defender, <code>false</code> otherwise.
--- @return boolean defender has won
function campaign_manager:pending_battle_cache_defender_victory()
	return not not string.find(self:model():pending_battle():defender_battle_result(), "victory");
end;


--- @function pending_battle_cache_attacker_value
--- @desc Returns the gold value of attacking forces in the cached pending battle.
--- @return number gold value of attacking forces
function campaign_manager:pending_battle_cache_attacker_value()
	if self.pending_battle_cached_attacker_value < 1 then
		return 1;
	end
	return self.pending_battle_cached_attacker_value;
end;


--- @function pending_battle_cache_defender_value
--- @desc Returns the gold value of defending forces in the cached pending battle.
--- @return number gold value of defending forces
function campaign_manager:pending_battle_cache_defender_value()
	if self.pending_battle_cached_defender_value < 1 then
		return 1;
	end
	return self.pending_battle_cached_defender_value;
end;








-----------------------------------------------------------------------------
--- @section Random Numbers
-----------------------------------------------------------------------------


--- @function random_number
--- @desc Assembles and returns a random integer between 1 and 100, or other supplied values. The result returned is inclusive of the supplied max/min. This is safe to use in multiplayer scripts.
--- @p [opt=100] integer max, Maximum value of returned random number.
--- @p [opt=1] integer min, Minimum value of returned random number.
--- @return number random number
function campaign_manager:random_number(max_num, min_num)
	if is_nil(max_num) then
		max_num = 100;
	end;
	
	if is_nil(min_num) then
		min_num = 1;
	end;
	
	if not is_number(max_num) or math.floor(max_num) < max_num then
		script_error("random_number ERROR: supplied max number [" .. tostring(max_num) .. "] is not a valid integer");
		return 0;
	end;
	
	if max_num == min_num then
		return max_num;
	end;
	
	if min_num == 1 and max_num < min_num then
		script_error("random_number ERROR: supplied max number [" .. tostring(max_num) .. "] can only be negative if a min number is also supplied");
		return 0;
	end;
	
	if not is_number(min_num) or min_num >= max_num or math.floor(min_num) < min_num then
		script_error("random_number ERROR: supplied min number [" .. tostring(min_num) .. "] is not an integer less than the max num");
		return 0;
	end;
	
	-- internal_max_num is the number we'll be proceeding with internally, it's the max_num if min_num was 1.
	-- So if the user wants a random number between 11 and 20, we'll proceed as if they want a random number between 1 and
	-- 10 and then adjust the result afterwards.
	local internal_max_num = max_num + 1 - min_num;

	-- work out the bit depth of internal_max_num
	local count = 2;
	local depth = 1;
	
	while count < internal_max_num do
		count = count * 2;
		depth = depth + 1;
	end;
	
	-- assemble a random number of the specified bit-depth
	local random_number = 0;
	
	for i = 0, depth - 1 do
		if self:model():random_percent(50) then
			random_number = random_number + (2 ^ i);
		end;
	end;
	
	-- if the number we've got is bigger than the maximum, try again
	if random_number >= internal_max_num then
		return self:random_number(max_num, min_num);
	end;
	
	local retval = random_number + min_num;
	
	if self:is_multiplayer() then
		--out("random_number() called, max_num [" .. tostring(max_num) .. "], min_num [" .. tostring(min_num) .. "], returning value [" .. tostring(retval) .. "]");
	end;
	
	return retval;
end;


--- @function random_sort
--- @desc Randomly sorts a numerically-indexed table. This is safe to use in multiplayer, but will destroy the supplied table. It is faster than @campaign_manager:random_sort_copy.
--- @desc Note that records in this table that are not arranged in an ascending numerical index will be lost.
--- @desc Note also that the supplied table is overwritten with the randomly-sorted table, which is also returned as a return value.
--- @p @table numerically-indexed table, Numerically-indexed table. This will be overwritten by the returned, randomly-sorted table.
--- @return @table randomly-sorted table
function campaign_manager:random_sort(t)
	if not is_table(t) then
		script_error("ERROR: random_sort() called but supplied object [" .. tostring(t) .. "] is not a table");
		return false;
	end;

	local new_t = {};
	local table_size = #t;
	local n = 0;
	
	for i = 1, table_size do
		
		-- pick an entry from t, add it to new_t, then remove it from t
		n = self:random_number(#t);
		
		table.insert(new_t, t[n]);
		table.remove(t, n);
	end;
	
	return new_t;
end;


--- @function random_sort_copy
--- @desc Randomly sorts a numerically-indexed table. This is safe to use in multiplayer, and will preserve the original table, but it is slower than @campaign_manager:random_sort as it copies the table first.
--- @desc Note that records in the source table that are not arranged in an ascending numerical index will not be copied (they will not be deleted, however).
--- @p @table numerically-indexed table, Numerically-indexed table.
--- @return @table randomly-sorted table
function campaign_manager:random_sort_copy(t)
	if not is_table(t) then
		script_error("ERROR: random_sort_copy() called but supplied object [" .. tostring(t) .. "] is not a table");
		return false;
	end;

	local table_size = #t;
	local new_t = {};

	-- copy this table
	for i = 1, table_size do
		new_t[i] = t[i];
	end;

	return self:random_sort(new_t);
end;


--- @function shuffle_table
--- @desc Randomly shuffles a table with an implementation of the Fisher-Yates shuffle.
--- @desc Note that unlike the random_sort function this modifies the existing table and doesn't create a new one.
--- @p @table table
function campaign_manager:shuffle_table(tab)
	for i = #tab, 2, -1 do
		local j = self:random_number(i)
		tab[i], tab[j] = tab[j], tab[i];
	end
end













----------------------------------------------------------------------------
--- @section Campaign UI
----------------------------------------------------------------------------


--- @function get_campaign_ui_manager
--- @desc Gets a handle to the @campaign_ui_manager (or creates it).
--- @return campaign_ui_manager
function campaign_manager:get_campaign_ui_manager()
	if self.campaign_ui_manager then
		return self.campaign_ui_manager;
	end;
	return campaign_ui_manager:new();
end;


--- @function highlight_event_dismiss_button
--- @desc Activates or deactivates a highlight on the event panel dismiss button. This may not work in all circumstances.
--- @p [opt=true] boolean should highlight
function campaign_manager:highlight_event_dismiss_button(should_highlight)

	if should_highlight ~= false then
		should_highlight = true;
	end;
	
	local uic_button = find_uicomponent(core:get_ui_root(), "panel_manager", "events", "button_set", "accept_decline", "button_accept");
	local button_highlighted = false;
	
	-- if should_highlight is false, then both potential buttons get unhighlighted
	-- if it's true, then only the first that is found to be visible is highlighted
		
	if uic_button and (uic_button:Visible(true) or not should_highlight) then
		uic_button:Highlight(should_highlight, false, 0);
		button_highlighted = true;
	end;
	
	if button_highlighted and should_highlight then
		return;
	end;
	
	uic_button = find_uicomponent(core:get_ui_root(), "panel_manager", "events", "button_set", "accept_holder", "button_accept");
	
	if uic_button and (uic_button:Visible(true) or not should_highlight) then
		uic_button:Highlight(should_highlight, false, 0);
	end;
end;


--- @function quit
--- @desc Immediately exits to the frontend. Mainly used in benchmark scripts.
function campaign_manager:quit()
	out("campaign_manager:quit() called");
	
	self:dismiss_advice();

	self:callback(
		function()
			self:steal_user_input(true);
			core:get_ui_root():InterfaceFunction("QuitForScript");
		end,
		1
	);
end;


--- @function enable_ui_hiding
--- @desc Enables or disables the ability of the player to hide the UI.
--- @p [opt=true] boolean enable hiding
function campaign_manager:enable_ui_hiding(value)
	if value ~= false then
		value = true;
	end;

	self.ui_hiding_enabled = value;

	self.game_interface:disable_shortcut("root", "toggle_ui", not value);
	self.game_interface:disable_shortcut("root", "toggle_ui_with_borders", not value);
end;


--- @function is_ui_hiding_enabled
--- @desc Returns <code>false</code> if ui hiding has been disabled with @campaign_manager:enable_ui_hiding, <code>true</code> otherwise.
--- @return boolean is ui hiding enabled
function campaign_manager:is_ui_hiding_enabled()
	return self.ui_hiding_enabled;
end;









-----------------------------------------------------------------------------
--- @section Camera Movement
--- @desc The functions in this section allow or automate camera scrolling to some degree. Where camera positions are supplied as arguments, these are given as a table of numbers. The numbers in a camera position table are given in the following order:
--- @desc <ol><li>x co-ordinate of camera target.</li>
--- @desc <li>y co-ordinate of camera target.</li>
--- @desc <li>horizontal distance from camera to target.</li>
--- @desc <li>bearing from camera to target, in radians.</li>
--- @desc <li>vertical distance from camera to target.</li></ol>
-----------------------------------------------------------------------------


-- called internally by various camera functions
function campaign_manager:check_valid_camera_waypoint(waypoint)
	if not is_table(waypoint) then
		script_error("ERROR: check_valid_camera_waypoint() called but supplied waypoint [" .. tostring(waypoint) .. "] is not a table");
		return false;
	end;
	
	for i = 1, 5 do
		if not is_number(waypoint[i]) then
			script_error("ERROR: check_valid_camera_waypoint() called but index [" .. i .. "] of supplied waypoint is not a number but is [" .. tostring(waypoint[i]) .. "]");
			return false;
		end;
	end;
	
	-- for waypoints that include a timestamp
	if #waypoint == 6 then
		if not is_number(waypoint[6]) then
			script_error("ERROR: check_valid_camera_waypoint() called but index [" .. 6 .. "] of supplied waypoint is not a number but is [" .. tostring(waypoint[6]) .. "]");
			return false;
		end;
	end;
	
	return true;
end;


-- returns true if the supplied positions are the same
function campaign_manager:scroll_camera_position_check(source, dest)
	return source[1] == dest[1] and source[2] == dest[2] and source[3] == dest[3] and source[4] == dest[4] and source[5] == dest[5];
end;


-- internal function to convert a camera position to a string
function campaign_manager:camera_position_to_string(x, y, d, b, h)
	if is_table(x) then
		y = x[2];
		d = x[3];
		b = x[4];
		h = x[5];
		x = x[1];
	end;
	
	return "[x: " .. tostring(x) .. ", y: " .. tostring(y) .. ", d: " .. tostring(d) .. ", b: " .. tostring(b) .. ", h: " .. tostring(h) .. "]";
end;


--- @function scroll_camera_with_direction
--- @desc Override function for scroll_camera_wiht_direction that provides output.
--- @p boolean correct endpoint, Correct endpoint. If true, the game will adjust the final position of the camera so that it's a valid camera position for the game. Set to true if control is being released back to the player after this camera movement finishes.
--- @p number time, Time in seconds over which to scroll.
--- @p ... positions, Two or more camera positions must be supplied. Each position should be a table with five number components, as described in the description of the @"campaign_manager:Camera Movement" section.
--- @new_example
--- @desc Pull the camera out from a close-up to a wider view.
--- @example cm:scroll_camera_with_direction(
--- @example 	true,
--- @example 	5,
--- @example 	{132.9, 504.8, 8, 0, 6},
--- @example 	{132.9, 504.8, 16, 0, 12}
--- @example )
function campaign_manager:scroll_camera_with_direction(correct_endpoint, t, ...)

	local x, y, d, b, h = self:get_camera_position();
	
	out("scroll_camera_with_direction() called, correct endpoint is " .. tostring(correct_endpoint) .. ", time is " .. tostring(t) .. "s, current camera position is " .. self:camera_position_to_string(x, y, d, b, h));
	
	out.inc_tab();
	for i = 1, arg.n do
		local current_pos = arg[i];
		out("position " .. i .. ": " .. self:camera_position_to_string(current_pos[1], current_pos[2], current_pos[3], current_pos[4], current_pos[5]));
	end;
	out.dec_tab();
	
	self.game_interface:scroll_camera_with_direction(correct_endpoint, t, unpack(arg));
end;


--- @function scroll_camera_from_current
--- @desc Scrolls the camera from the current camera position. This is the same as callling @campaign_manager:scroll_camera_with_direction with the current camera position as the first set of co-ordinates.
--- @p boolean correct endpoint, Correct endpoint. If true, the game will adjust the final position of the camera so that it's a valid camera position for the game. Set to true if control is being released back to the player after this camera movement finishes.
--- @p number time, Time in seconds over which to scroll.
--- @p ... positions, One or more camera positions must be supplied. Each position should be a table with five number components, as described in the description of the @"campaign_manager:Camera Movement" section.
--- @example cm:scroll_camera_from_current(
--- @example 	true,
--- @example 	5,
--- @example 	{251.3, 312.0, 12, 0, 8}
--- @example )
function campaign_manager:scroll_camera_from_current(correct_endpoint, t, ...)
	-- check our parameters
	if not is_number(t) or t <= 0 then
		script_error("ERROR: scroll_camera_from_current() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
	
	-- insert the current camera position as the first position in the sequence
	local x, y, d, b, h = self:get_camera_position();
	
	table.insert(arg, 1, {x, y, d, b, h});
	
	-- output
	out("scroll_camera_from_current() called");
	out.inc_tab();	
	self:scroll_camera_with_direction(correct_endpoint, t, unpack(arg))
	out.dec_tab();
end;


--- @function scroll_camera_with_cutscene
--- @desc Scrolls the camera from the current camera position in a cutscene. Cinematic borders will be shown (unless disabled with @campaign_manager:set_use_cinematic_borders_for_automated_cutscenes), the UI hidden, and interaction with the game disabled while the camera is scrolling. The player will be able to skip the cutscene with the ESC key, in which case the camera will jump to the end position.
--- @p number time, Time in seconds over which to scroll.
--- @p [opt=nil] function callback, Optional callback to call when the cutscene ends.
--- @p ... positions, One or more camera positions must be supplied. Each position should be a table with five number components, as described in the description of the @"campaign_manager:Camera Movement" section.
function campaign_manager:scroll_camera_with_cutscene(t, end_callback, ...)

	-- check our parameters
	if not is_number(t) or t <= 0 then
		script_error("ERROR: scroll_camera_with_cutscene() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	if not is_function(end_callback) and not is_nil(end_callback) then
		script_error("ERROR: scroll_camera_with_cutscene() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
	
	-- get the last position now before we start mucking around with the argument list
	local last_pos = arg[arg.n];
	
	-- insert the current camera position as the first position in the sequence
	local x, y, d, b, h = self:get_camera_position();
	
	table.insert(arg, 1, {x, y, d, b, h});
	
	self:cut_and_scroll_camera_with_cutscene(t, end_callback, unpack(arg));
end;


--- @function cut_and_scroll_camera_with_cutscene
--- @desc Scrolls the camera through the supplied list of camera points in a cutscene. Cinematic borders will be shown (unless disabled with @campaign_manager:set_use_cinematic_borders_for_automated_cutscenes), the UI hidden, and interaction with the game disabled while the camera is scrolling. The player will be able to skip the cutscene with the ESC key, in which case the camera will jump to the end position.
--- @p number time, Time in seconds over which to scroll.
--- @p [opt=nil] function callback, Optional callback to call when the cutscene ends.
--- @p ... positions. One or more camera positions must be supplied. Each position should be a table with five number components, as described in the description of the @"campaign_manager:Camera Movement" section.
function campaign_manager:cut_and_scroll_camera_with_cutscene(t, end_callback, ...)

	-- check our parameters
	if not is_number(t) or t <=0 then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	if not is_function(end_callback) and not is_nil(end_callback) then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if arg.n < 2 then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but less than two camera positions given");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
		
	-- make a cutscene, add the camera pan as the action and play it
	local cutscene = campaign_cutscene:new(
		"scroll_camera_with_cutscene", 
		t, 
		function() 
			out.dec_tab();
			if end_callback then
				end_callback();
			end;
		end
	);
	
	cutscene:set_skippable(true, arg[arg.n]);	-- set the last position in the supplied list to be the skip position
	cutscene:set_dismiss_advice_on_end(false);
	
	cutscene:set_use_cinematic_borders(self.use_cinematic_borders_for_automated_cutscenes);
	cutscene:set_disable_settlement_labels(false);
	
	local start_position = arg[1];
	
	cutscene:action(function() self:set_camera_position(unpack(start_position)) end, 0);
	cutscene:action(
		function()
			out.inc_tab();
			self:scroll_camera_with_direction(true, t, unpack(arg));
			out.dec_tab();
		end, 
		0
	);
	cutscene:start();
end;


--- @function scroll_camera_with_cutscene_to_settlement
--- @desc Scrolls the camera in a cutscene to the specified settlement in a cutscene. The settlement is specified by region key. Cinematic borders will be shown (unless disabled with @campaign_manager:set_use_cinematic_borders_for_automated_cutscenes), the UI hidden, and interaction with the game disabled while the camera is scrolling. The player will be able to skip the cutscene with the ESC key, in which case the camera will jump to the target.
--- @p number time, Time in seconds over which to scroll.
--- @p [opt=nil] function callback, Optional callback to call when the cutscene ends.
--- @p string region key, Key of region containing target settlement.
function campaign_manager:scroll_camera_with_cutscene_to_settlement(t, end_callback, region_key)
	if not is_string(region_key) then
		script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;

	local region = cm:get_region(region_key);
	
	if not region then
		script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but region with supplied key [" .. region_key .. "] could not be found");
		return false;
	end;
	
	local settlement = region:settlement();
	
	local targ_x = settlement:display_position_x();
	local targ_y = settlement:display_position_y();
	
	local x, y, d, b, h = self:get_camera_position();
	
	-- pan camera to calculated target
	self:scroll_camera_with_cutscene(
		t, 
		end_callback,
		{targ_x, targ_y, 7.6, b, 4.0}
	);
end;


--- @function scroll_camera_with_cutscene_to_character
--- @desc Scrolls the camera in a cutscene to the specified character in a cutscene. The character is specified by its command queue index (cqi). Cinematic borders will be shown (unless disabled with @campaign_manager:set_use_cinematic_borders_for_automated_cutscenes), the UI hidden, and interaction with the game disabled while the camera is scrolling. The player will be able to skip the cutscene with the ESC key, in which case the camera will jump to the target.
--- @p number time, Time in seconds over which to scroll.
--- @p [opt=nil] function callback, Optional callback to call when the cutscene ends.
--- @p number cqi, CQI of target character.
function campaign_manager:scroll_camera_with_cutscene_to_character(t, end_callback, char_cqi)
	if not is_number(char_cqi) then
		script_error("ERROR: scroll_camera_with_cutscene_to_character() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
		
	local character = self:get_character_by_cqi(char_cqi);
	
	if not character then
		script_error("ERROR: scroll_camera_with_cutscene_to_character() called but no character with cqi [" .. char_cqi .. "] could be found");
		return false;
	end;
	
	local targ_x = character:display_position_x();
	local targ_y = character:display_position_y();
	
	local x, y, d, b, h = self:get_camera_position();
	
	-- pan camera to calculated target
	self:scroll_camera_with_cutscene(
		t, 
		end_callback,
		{targ_x, targ_y, 7.6, b, 4.0}
	);
end;


--- @function set_use_cinematic_borders_for_automated_cutscenes
--- @desc Sets whether or not to show cinematic borders when scrolling the camera in an automated cutscene (for example with @campaign_manager:scroll_camera_with_cutscene). By default, cinematic borders are displayed.
--- @p [opt=true] boolean show borders
function campaign_manager:set_use_cinematic_borders_for_automated_cutscenes(value)
	if value == false then
		self.use_cinematic_borders_for_automated_cutscenes = false;
	else
		self.use_cinematic_borders_for_automated_cutscenes = true;
	end;
end;


-- use with care
function campaign_manager:scroll_camera_from_current_with_smoothing(correct_endpoint, ...)

	if not is_boolean(correct_endpoint) then
		script_error("ERROR: scroll_camera_from_current_with_smoothing() called but supplied correct_endpoint flag [" .. tostring(correct_endpoint) .. "] is not a boolean value");
		return false;
	end;

	if arg.n == 0 then
		script_error("ERROR: scroll_camera_from_current_with_smoothing() called but no waypoints supplied");
		return false;
	end;
	
	local max_time = 0;
	local camera_waypoints = {};				-- internal list of waypoints
	
	local processed_waypoints = {};				-- internal list of processed waypoints i.e. one per second
	
	-- insert current camera position at start
	local x, y, d, b, h = self:get_camera_position();
	table.insert(camera_waypoints, 1, {x, y, d, b, h, 0});
	table.insert(processed_waypoints, {x, y, d, b, h});
	
	-- check supplied waypoints are valid
	for i = 1, arg.n do
		local current_waypoint = arg[i];
	
		if not self:check_valid_camera_waypoint(current_waypoint) then
			-- error will be returned by the function above
			return false;
		end;
		
		local current_time = current_waypoint[6];
		
		if math.floor(current_time) < current_time then
			script_error("WARNING: scroll_camera_from_current_with_smoothing() called but supplied camera waypoint [" .. i .. "] has a specified time of [" .. tostring(current_time) .. "] - only integer values are supported, rounding it down");
			current_time = math.floor(current_time);
		end;
		
		out("attempting to insert waypoint with time " .. current_time);
		
		-- insert supplied waypoint into internal list
		local waypoint_inserted = false;
		for j = 1, #camera_waypoints do
			out("\tcomparing against pre-inserted waypoint with time " .. camera_waypoints[j][6]);
			if camera_waypoints[j][6] > current_time then
				out("\tinserting waypoint");
				waypoint_inserted = true;
				table.insert(camera_waypoints, j, {current_waypoint[1], current_waypoint[2], current_waypoint[3], current_waypoint[4], current_waypoint[5], current_time});
			end;
		end;
		
		if not waypoint_inserted then
			out("inserting waypoint at end");
			table.insert(camera_waypoints, {current_waypoint[1], current_waypoint[2], current_waypoint[3], current_waypoint[4], current_waypoint[5], current_time});
		end;
		
		if current_time > max_time then
			max_time = current_time;
		end;
	end;
	
	local current_camera_waypoint_pointer = 1;
		
	for i = 1, max_time do
		-- check we're not going to overrun the end of our camera_waypoints list
		if current_camera_waypoint_pointer >= #camera_waypoints then
			script_error("ERROR: scroll_camera_from_current_with_smoothing() is going to overrun the end of its camera_waypoints list, how can this be? current camera waypoint pointer is [" .. tostring(current_camera_waypoint_pointer) .. "], number of unprocessed waypoints is [" .. #camera_waypoints .. "], current time is [" .. tostring(i) .. "], and max time is [" .. tostring(max_time) .. "]");
			return false;
		end;
		
		local current_camera_waypoint = camera_waypoints[current_camera_waypoint_pointer];
		local next_camera_waypoint = camera_waypoints[current_camera_waypoint_pointer + 1];
		
		local current_camera_waypoint_time = current_camera_waypoint[6];
		local next_camera_waypoint_time = next_camera_waypoint[6];
		
		-- if we're reached the next waypoint, add it directly
		if i == next_camera_waypoint_time then
			table.insert(processed_waypoints, {next_camera_waypoint[1], next_camera_waypoint[2], next_camera_waypoint[3], next_camera_waypoint[4], next_camera_waypoint[5]});
			current_camera_waypoint_pointer = current_camera_waypoint_pointer + 1;
			
		else
			-- we're midway between two waypoints - calculate the position
			local waypoint_to_add = {};
			
			for j = 1, 5 do
				waypoint_to_add[j] = current_camera_waypoint[j] + ((next_camera_waypoint[j] - current_camera_waypoint[j]) * (i - current_camera_waypoint_time)) / (next_camera_waypoint_time - current_camera_waypoint_time)
			end;
			
			table.insert(processed_waypoints, waypoint_to_add);
		end;
	end;
	
	out("scroll_camera_from_current_with_smoothing() called");
	out.inc_tab();	
	self:scroll_camera_with_direction(correct_endpoint, max_time, unpack(processed_waypoints))
	out.dec_tab();
end;


--- @function position_camera_at_primary_military_force
--- @desc Immediately positions the camera at a position looking at the primary military force for the supplied faction. The faction is specified by key.
--- @p string faction key
function campaign_manager:position_camera_at_primary_military_force(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: position_camera_at_primary_military_force() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		script_error("ERROR: position_camera_at_primary_military_force() called but no faction with name [" .. faction_name .. "] could be found");
		return false;
	end;
	
	if not faction:has_faction_leader() then
		script_error("ERROR: position_camera_at_primary_military_force() called but no faction leader could be found for faction [" .. faction_name .. "]");
		return false;
	end;
	
	local faction_leader = faction:faction_leader();
	local x = nil;
	local y = nil;
	
	if faction_leader:has_military_force() then
		x = faction_leader:display_position_x();
		y = faction_leader:display_position_y();
	else
		local mf_list_item_0 = faction:military_force_list():item_at(0);
		
		if mf_list_item_0:has_general() then
			local general = mf_list_item_0:general_character();
			
			x = general:display_position_x();
			y = general:display_position_y();
		else
			script_error("ERROR: position_camera_at_primary_military_force() called but no military force for faction [" .. faction_name .. "] could be found on the map");
		end;
	end
	
	cm:set_camera_position(x, y, 7.6, 0.0, 4.0);
end;


--- @function cindy_playback
--- @desc Starts playback of a cindy scene. This is a wrapper for the @cinematics:cindy_playback function, adding debug output.
--- @p @string filepath, File path to cindy scene, from the working data folder.
--- @p [opt=nil] @number blend in duration, Time in seconds over which the camera will blend into the cindy scene when started.
--- @p [opt=nil] @number blend out duration, Time in seconds over which the camera will blend out of the cindy scene when it ends.
function campaign_manager:cindy_playback(filepath, blend_in_duration, blend_out_duration)
	
	if not is_string(filepath) then
		script_error("ERROR: cindy_playback() called but supplied file path [" .. tostring(filepath) .. "] is not a string");
		return false;
	end;

	if blend_in_duration and not is_number(blend_in_duration) then
		script_error("ERROR: cindy_playback() called but supplied blend in duration [" .. tostring(blend_in_duration) .. "] is not a number or nil");
		return false;
	end;

	if blend_out_duration and not is_number(blend_out_duration) then
		script_error("ERROR: cindy_playback() called but supplied blend out duration [" .. tostring(blend_out_duration) .. "] is not a number or nil");
		return false;
	end;

	if (blend_in_duration and not blend_out_duration) or (blend_out_duration and not blend_in_duration) then
		script_error("WARNING: cindy_playback() called with blend in duration [" .. tostring(blend_in_duration) .. "] and blend out duration [" .. tostring(blend_out_duration) .. "] specified - both need to be supplied for either to work");
		return false;
	end;

	out("Starting cinematic playback of file: " .. filepath .. ".");
	self.cinematic_interface:cindy_playback(filepath, blend_in_duration, blend_out_duration);
end;


--- @function stop_cindy_playback
--- @desc Stops playback of any currently-playing cindy scene. This is a wrapper for the function of the same name on the <code>cinematic</code> interface, but adds debug output.
--- @p boolean clear animation scenes
function campaign_manager:stop_cindy_playback(clear_anim_scenes)
	out("Stopping cinematic playback");	
	self.cinematic_interface:stop_cindy_playback(clear_anim_scenes);
end;











-----------------------------------------------------------------------------
--- @section Camera Position Caching
--- @desc The functions in this section allow the current position of the camera to be cached, and then for a test to be performed later to determine if the camera has moved. This is useful for determining if the player has moved the camera, which would indicate whether it's appropriate or not to scroll the camera via script in certain circumstances.
-----------------------------------------------------------------------------


--- @function cache_camera_position
--- @desc Caches the current camera position, so that the camera position may be compared to it later to determine if it has moved. An optional name may be specified for this cache entry so that multiple cache entries may be created. If the camera position was previously cached with the supplied cache name then that cache will be overwritten.
--- @p [opt="default"] string cache name
function campaign_manager:cache_camera_position(cache_name)
	if cache_name then
		if not is_string(cache_name) then
			script_error("ERROR: cache_camera_position() called but supplied cache name [" .. tostring(cache_name) .. "] is not a string or nil");
			return false;
		end;
	else
		cache_name = "default";
	end;

	local cached_camera_record = {};
	cached_camera_record.x, cached_camera_record.y, cached_camera_record.d, cached_camera_record.b, cached_camera_record.h = self:get_camera_position();
	
	self.cached_camera_records[cache_name] = cached_camera_record;
end;


--- @function cached_camera_position_exists
--- @desc Returns whether a camera position is currently cached for the (optional) supplied cache name.
--- @p [opt="default"] string cache name
--- @return @boolean camera position is cached
function campaign_manager:cached_camera_position_exists(cache_name)
	if cache_name then
		if not is_string(cache_name) then
			script_error("ERROR: cached_camera_position_exists() called but supplied cache name [" .. tostring(cache_name) .. "] is not a string or nil");
			return false;
		end;
	else
		cache_name = "default";
	end;

	return not not self.cached_camera_records[cache_name];
end;


--- @function get_cached_camera_position
--- @desc Returns the camera position which was last cached with the optional cache name (the default cache name is <code>"default"</code>). If no camera cache has been set with the specified name then a script error is generated.
--- @p [opt="default"] string cache name
--- @return @number x
--- @return @number y
--- @return @number d
--- @return @number b
--- @return @number h
function campaign_manager:get_cached_camera_position(cache_name)
	if cache_name then
		if not is_string(cache_name) then
			script_error("ERROR: get_cached_camera_position() called but supplied cache name [" .. tostring(cache_name) .. "] is not a string or nil");
			return false;
		end;
	else
		cache_name = "default";
	end;
		
	local cached_camera_record = self.cached_camera_records[cache_name];
	
	if cached_camera_record then
		return cached_camera_record.x, cached_camera_record.y, cached_camera_record.d, cached_camera_record.b, cached_camera_record.h;
	end;
end;


--- @function camera_has_moved_from_cached
--- @desc Compares the current position of the camera to that last cached with the (optional) specified cache name, and returns <code>true</code> if any of the camera co-ordinates have changed by the (optional) supplied distance, or <code>false</code> otherwise. If no camera cache has been set with the specified name then a script error is generated.
--- @p [opt="default"] string cache name
function campaign_manager:camera_has_moved_from_cached(cache_name, distance)
	if cache_name then
		if not is_string(cache_name) then
			script_error("ERROR: camera_has_moved_from_cached() called but supplied cache name [" .. tostring(cache_name) .. "] is not a string or nil");
			return false;
		end;
	else
		cache_name = "default";
	end;
	
	if not distance then
		distance = 1;
	else
		if not is_number(distance) then
			script_error("ERROR: camera_has_moved_from_cached() called but supplied distance [" .. distance .. "] is not a positive number or nil");
			return false;
		end;
	end;
	
	local cached_camera_record = self.cached_camera_records[cache_name];
	
	if not cached_camera_record then
		script_error("ERROR: camera_has_moved_from_cached() called but no cache with supplied name [" .. cache_name .. "] is currently set");
		return false;
	end;
	
	local x, y, d, b, h = cm:get_camera_position();
	
	return math.abs(cached_camera_record.x - x) > 1 or 
		math.abs(cached_camera_record.y - y) > 1 or
		math.abs(cached_camera_record.d - d) > 1 or
		math.abs(cached_camera_record.b - b) > 1 or
		math.abs(cached_camera_record.h - h) > 1;
end;


--- @function delete_cached_camera_position
--- @desc Removes the cache for the supplied cache name. If no cache name is specified the default cache (cache name <code>"default"</code>) is deleted.
--- @p [opt="default"] string cache name
function campaign_manager:delete_cached_camera_position(cache_name)
	if cache_name then
		if not is_string(cache_name) then
			script_error("ERROR: reset_cached_camera_position() called but supplied cache name [" .. tostring(cache_name) .. "] is not a string or nil");
			return false;
		end;
	else
		cache_name = "default";
	end;
	
	self.cached_camera_records[cache_name] = nil;
end;











----------------------------------------------------------------------------
---	@section Cutscenes and Key Stealing
----------------------------------------------------------------------------


--- @function show_subtitle
--- @desc Shows subtitled text during a cutscene. The text is displayed until @campaign_manager:hide_subtitles is called.
--- @p string text key, Text key. By default, this is supplied as a record key from the <code>scripted_subtitles</code> table. Text from anywhere in the database may be shown, however, by supplying the full localisation key and <code>true</code> for the second argument.
--- @p [opt=false] boolean full text key supplied, Set to true if the fll localised text key was supplied for the first argument in the form [table]_[field]_[key].
--- @p [opt=false] boolean force diplay, Forces subtitle display. Setting this to <code>true</code> overrides the player's preferences on subtitle display.
function campaign_manager:show_subtitle(key, full_key_supplied, should_force)

	if not is_string(key) then
		script_error("ERROR: show_subtitle() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	-- only proceed if we're forcing the subtitle to play, or if the subtitle preferences setting is on
	if not should_force and not effect.subtitles_enabled() then
		return;
	end;
	
	local full_key;
	
	if not full_key_supplied then
		full_key = "scripted_subtitles_localised_text_" .. key;
	else
		full_key = key;
	end;
	
	local localised_text = effect.get_localised_string(full_key);
	
	if not is_string(localised_text) then
		script_error("ERROR: show_subtitle() called but could not find any localised text corresponding with supplied key [" .. tostring(key) .. "] in scripted_subtitles table");
		return false;
	end;

	local ui_root = core:get_ui_root();
	
	out("show_subtitle() called, supplied key is [" .. key .. "] and localised text is [" .. localised_text .. "]");

	-- create the subtitles component if it doesn't already exist
	if not self.subtitles_component_created then
		ui_root:CreateComponent("scripted_subtitles", "UI/Campaign UI/scripted_subtitles");
		self.subtitles_component_created = true;
	end;
	
	-- find the subtitles component
	local uic_subtitles = find_uicomponent(ui_root, "scripted_subtitles", "text_child");
	
	if not uic_subtitles then
		script_error("ERROR: show_subtitles() could not find the scripted_subtitles uicomponent");
		return false;
	end;
	
	-- set the text on it
	uic_subtitles:SetStateText(localised_text, full_key);
	
	-- make the subtitles component visible if it's not already
	if not self.subtitles_visible then
		uic_subtitles:SetVisible(true);
		uic_subtitles:RegisterTopMost();
		self.subtitles_visible = true;
	end;
	
	output_uicomponent(uic_subtitles);
end;


--- @function hide_subtitles
--- @desc Hides any subtitles currently displayed with @campaign_manager:show_subtitle.
function campaign_manager:hide_subtitles()
	if self.subtitles_visible then
		-- find the subtitles component
		local uic_subtitles = find_uicomponent(core:get_ui_root(), "scripted_subtitles", "text_child");
	
		uic_subtitles:RemoveTopMost();
		uic_subtitles:SetVisible(false);
		self.subtitles_visible = false;
	end;
end;


-- internal function for a campaign cutscene to register itself with the campaign manager
function campaign_manager:register_cutscene(cutscene)
	if not is_campaigncutscene(cutscene) then
		script_error("ERROR: register_cutscene() called but supplied object [" .. tostring(cutscene) .. "] is not a campaign cutscene");
		return false;
	end;
	
	table.insert(self.cutscene_list, cutscene);
end;


-- internal function that campaign cutscenes call to set global cutscene debug mode
function campaign_manager:set_campaign_cutscene_debug(value)
	if value == false then
		self.is_campaign_cutscene_debug = false;
	else
		self.is_campaign_cutscene_debug = true;
	end;
end;


-- internal function that campaign cutscenes call to query global cutscene debug mode
function campaign_manager:get_campaign_cutscene_debug()
	return self.is_campaign_cutscene_debug;
end;


--- @function is_any_cutscene_running
--- @desc Returns <code>true</code> if any @campaign_cutscene is running, <code>false</code> otherwise.
--- @return boolean is any cutscene running
function campaign_manager:is_any_cutscene_running()

	if #self.cutscene_list == 0 then
		return false;
	end;
	
	for i = 1, #self.cutscene_list do
		if self.cutscene_list[i]:is_active() then
			return true;
		end;
	end;
	
	return false;
end;


--- @function skip_all_campaign_cutscenes
--- @desc Skips any campaign cutscene currently running. 
function campaign_manager:skip_all_campaign_cutscenes()
	for i = 1, #self.cutscene_list do
		self.cutscene_list[i]:skip();
	end;
end;


--- @function steal_escape_key
--- @desc Steals or releases the escape key. This wraps the function @episodic_scripting:steal_escape_key function of the same name on the underlying episodic scripting interface. While the ESC key is stolen by script, presses of the key will cause <code>OnKeyPressed()</code> to be called which goes on to call @campaign_manager:on_key_press_up.
--- @desc To register a function to call when the escape key is pressed use @campaign_manager:steal_escape_key_with_callback or @campaign_manager:steal_escape_key_and_space_bar_with_callback instead of this function.
--- @p boolean steal
function campaign_manager:steal_escape_key(value)
	if value then
		if not self.escape_key_stolen then
			out(" * Stealing ESC key");
			self.escape_key_stolen = true;
			self.game_interface:steal_escape_key(true);
		end
	else
		if self.escape_key_stolen then
			out(" * Releasing ESC key");
			self.escape_key_stolen = false;
			self.game_interface:steal_escape_key(false);
		end;
	end;
end;


--- @function steal_user_input
--- @desc Steals or releases user input. This wraps the @episodic_scripting:steal_user_input function of the same name on the underlying episodic scripting interface. Stealing user input prevents any player interaction with the game (asides from pressing the ESC key).
--- @p boolean steal
function campaign_manager:steal_user_input(value)
	if value and not self.user_input_stolen then
		out(" * Stealing user input");
		self.user_input_stolen = true;
		self.game_interface:steal_user_input(true);
	elseif not value and self.user_input_stolen then
		out(" * Releasing user input");
		self.user_input_stolen = false;
		self.game_interface:steal_user_input(false);
	end;
end;


-- called by the code whenever a key is pressed when input has been stolen
-- input is stolen when steal_user_input() (all keys) or steal_escape_key() (just esc key) are called
function OnKeyPressed(key, is_key_up)
	if is_key_up == true then
		cm:on_key_press_up(key);
	end;
end;


--- @function on_key_press_up
--- @desc Called by the campaign model when a key stolen by steal_user_input or steal_escape_key is pressed. Client scripts should not call this!
--- @p string key pressed
function campaign_manager:on_key_press_up(key)	
	-- if anything has stolen this key, then execute the callback on the top of the relevant stack, then remove it
	local key_table = self.stolen_keys[key];
	if is_table(key_table) and #key_table > 0 then
		local callback = key_table[#key_table].callback;
		table.remove(key_table, #key_table);
		callback();
	end;
end;


--- @function print_key_steal_entries
--- @desc Debug output of all current stolen key records.
function campaign_manager:print_key_steal_entries()
	out.inc_tab();
	out("*****");
	out("printing key_steal_entries");
	for key, entries in pairs(self.stolen_keys) do
		out("\tkey " .. key);
		for i = 1, #entries do
			local entry = entries[i];
			out("\t\tentry " .. i .. " name is " .. entry.name .. " and callback is " .. tostring(entry.callback));
		end;
	end;
	out("*****");
	out.dec_tab();
end;


--- @function steal_key_with_callback
--- @desc Steal a key, and register a callback to be called when it's pressed. It will be un-stolen when this occurs. @campaign_manager:steal_user_input will need to be called separately for this mechanism to work, unless it's the escape key that being stolen, where @campaign_manager:steal_escape_key should be used instead. In this latter case @campaign_manager:steal_escape_key_with_callback can be used instead.
--- @p string name, Unique name for this key-steal entry. This can be used later to release the key with @campaign_manager:release_key_with_callback.
--- @p string key, Key name.
--- @p function callback, Function to call when the key is pressed.
function campaign_manager:steal_key_with_callback(name, key, callback)
	if not is_string(name) then
		script_error("ERROR: steal_key_with_callback() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_string(key) then
		script_error("ERROR: steal_key_with_callback() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	-- create a table for this key if one doesn't already exist
	if not is_table(self.stolen_keys[key]) then
		self.stolen_keys[key] = {};
	end;

	local key_steal_entries_for_key = self.stolen_keys[key];
	
	-- don't proceed if a keysteal entry with this name already exists
	for i = 1, #key_steal_entries_for_key do
		if key_steal_entries_for_key[i].name == name then
			script_error("ERROR: steal_key_with_callback() called but a steal entry with supplied name [" .. name .. "] already exists for supplied key [" .. tostring(key) .. "]");
			return false;
		end;
	end;
	
	-- create a key steal entry
	local key_steal_entry = {
		["name"] = name,
		["callback"] = callback
	};
	
	-- add this key steal entry at the end of the list
	table.insert(key_steal_entries_for_key, key_steal_entry);
	
	return true;
end;


--- @function release_key_with_callback
--- @desc Releases a key stolen with @campaign_manager:steal_key_with_callback.
--- @p string name, Unique name for this key-steal entry.
--- @p string key, Key name.
function campaign_manager:release_key_with_callback(name, key)
	if not is_string(name) then
		script_error("ERROR: release_key_with_callback() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_string(key) then
		script_error("ERROR: release_key_with_callback() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	local key_steal_entries_for_key = self.stolen_keys[key];
	
	for i = 1, #key_steal_entries_for_key do
		if key_steal_entries_for_key[i].name == name then
			table.remove(key_steal_entries_for_key, i);
			break;
		end;
	end;
	
	return true;
end;


--- @function steal_escape_key_with_callback
--- @desc Steals the escape key and registers a function to call when it is pressed. Unlike @campaign_manager:steal_key_with_callback this automatically calls @campaign_manager:steal_escape_key if the key is not already stolen.
--- @p string name, Unique name for this key-steal entry.
--- @p function callback, Function to call when the key is pressed.
function campaign_manager:steal_escape_key_with_callback(name, callback)	
	-- attempt to steal the escape key if our attempt to register a callback succeeds
	if self:steal_key_with_callback(name, "ESCAPE", callback) then
		self:steal_escape_key(true);
	end;
end;


--- @function release_escape_key_with_callback
--- @desc Releases the escape key after it's been stolen with @campaign_manager:steal_escape_key_with_callback.
--- @p string name, Unique name for this key-steal entry.
function campaign_manager:release_escape_key_with_callback(name)
	-- attempt to release the escape key if our attempt to unregister a callback succeeds, and if the list of things now listening for the escape key is empty	
	if self:release_key_with_callback(name, "ESCAPE") then
		local esc_key_stealers = self.stolen_keys["ESCAPE"];
		if is_table(esc_key_stealers) and #esc_key_stealers == 0 then
			self:steal_escape_key(false);
		end;
	end;
end;


--- @function steal_escape_key_and_space_bar_with_callback
--- @desc Steals the escape key and spacebar and registers a function to call when they are pressed.
--- @p string name, Unique name for this key-steal entry.
--- @p function callback, Function to call when one of the keys are pressed.
function campaign_manager:steal_escape_key_and_space_bar_with_callback(name, callback)
	if self:steal_key_with_callback(name, "SPACE", callback) then
		self:steal_escape_key_with_callback(name, callback);
	end;
end;


--- @function release_escape_key_and_space_bar_with_callback
--- @desc Releases the escape key and spacebar after they've been stolen with @campaign_manager:steal_escape_key_and_space_bar_with_callback.
--- @p string name, Unique name for this key-steal entry
--- @p function callback, Function to call when one of the keys are pressed.
function campaign_manager:release_escape_key_and_space_bar_with_callback(name)
	if self:release_key_with_callback(name, "SPACE", callback) then
		self:release_escape_key_with_callback(name, callback);
	end;
end;











-----------------------------------------------------------------------------
--- @section Advice
-----------------------------------------------------------------------------


--- @function show_advice
--- @desc Displays some advice. The advice to display is specified by <code>advice_thread</code> key.
--- @p string advice key, Advice thread key.
--- @p [opt=false] boolean show progress button, Show progress/close button on the advisor panel.
--- @p [opt=false] boolean highlight progress button, Highlight the progress/close button on the advisor panel.
--- @p [opt=nil] function callback, End callback to call once the advice VO has finished playing.
--- @p [opt=0] number playtime, Minimum playtime for the advice VO in seconds. If this is longer than the length of the VO audio, the end callback is not called until after this duration has elapsed. If an end callback is set this has no effect. This is useful during development before recorded VO is ready for simulating the advice being played for a certain duration - with no audio, the advice would complete immediately, or not complete at all.
--- @p [opt=0] number delay, Delay in seconds to wait after the advice has finished before calling the supplied end callback. If no end callback is supplied this has no effect.
function campaign_manager:show_advice(key, progress_button, highlight, callback, playtime, delay)
	if not self.advice_enabled then
		return;
	end;
	
	if not is_string(key) then
		script_error("ERROR: show_advice() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;

	out("show_advice() called, key is " .. tostring(key));
	
	local show_advice_progress_str = "show_advice_progress_on_advice_finished";
	
	self:remove_callback(show_advice_progress_str);
	self:remove_callback(self.modify_advice_str);
	
	-- actually show the advice
	effect.advance_scripted_advice_thread(key, 1);
	
	self:modify_advice(progress_button, highlight);

	if not callback then
		return;
	end;
	
	if not is_function(callback) then
		script_error("show_advice() called but supplied callback [" .. tostring(callback) .. "] is not a function. Key is " .. tostring(key));
		return;
	end;
		
	if not is_number(playtime) or playtime < 0 then
		playtime = 0;
	end;
	
	-- delay this by a second in case it returns back straight away
	self:os_clock_callback(function() self:progress_on_advice_finished(callback, delay, playtime, true) end, 1, show_advice_progress_str);
end;


--- @function set_advice_enabled
--- @desc Enables or disables the advice system.
--- @p [opt=true] boolean enable advice
function campaign_manager:set_advice_enabled(value)
	if value == false then
		--
		-- delaying this call as a workaround for a floating-point error that seems to occur when it's made in the same tick as the LoadingScreenDismissed event
		self:callback(function() self.game_interface:override_ui("disable_advisor_button", true) end, 0.2);
		-- self.game_interface:override_ui("disable_advisor_button", true);
		
		set_component_active(false, "menu_bar", "button_show_advice");
		self.advice_enabled = false;
	else
		self.game_interface:override_ui("disable_advisor_button", false);
		set_component_active(true, "menu_bar", "button_show_advice");
		self.advice_enabled = true;
	end;
end;


--- @function is_advice_enabled
--- @desc Returns <code>true</code> if the advice system is enabled, or <code>false</code> if it's been disabled with @campaign_manager:set_advice_enabled.
--- @return boolean advice is enabled
function campaign_manager:is_advice_enabled()
	return self.advice_enabled;
end;


--- @function modify_advice
--- @desc Immediately enables or disables the close button that appears on the advisor panel, or causes it to be highlighted.
--- @p [opt=false] boolean show progress button
--- @p [opt=false] boolean highlight progress button
function campaign_manager:modify_advice(progress_button, highlight)
	-- if the component doesn't exist yet, wait a little bit as it's probably in the process of being created
	if not find_uicomponent(core:get_ui_root(), "advice_interface") then
		self:os_clock_callback(function() self:modify_advice(progress_button, highlight) end, 0.2, self.modify_advice_str);
		return;
	end;

	self:remove_callback(self.modify_advice_str);

	if progress_button then
		show_advisor_progress_button();	
		
		core:remove_listener("dismiss_advice_listener");
		core:add_listener(
			"dismiss_advice_listener",
			"ComponentLClickUp", 
			function(context) return context.string == __advisor_progress_button_name end,
			function(context) self:dismiss_advice() end, 
			false
		);
	else
		show_advisor_progress_button(false);
	end;
	
	if highlight then
		highlight_advisor_progress_button(true);
	else
		highlight_advisor_progress_button(false);
	end;
end;


--- @function add_pre_dismiss_advice_callback
--- @desc Registers a callback to be called when/immediately before the advice gets dismissed.
--- @p function callback
function campaign_manager:add_pre_dismiss_advice_callback(callback)
	if not is_function(callback) then
		script_error("ERROR: add_pre_dismiss_advice_callback() called but supplied callback [" .. tostring(callback) .."] is not a function");
		return false;
	end;
	
	table.insert(self.pre_dismiss_advice_callbacks, callback);
end;


--- @function dismiss_advice
--- @desc Dismisses the advice. Prior to performing the dismissal, this function calls any pre-dismiss callbacks registered with @campaign_manager:add_pre_dismiss_advice_callback. This function gets called internally when the player clicks the script-controlled advice progression button that appears on the advisor panel.
function campaign_manager:dismiss_advice()
	if not core:is_ui_created() then
		script_error("ERROR: dismiss_advice() called but ui not created");
		return false;
	end;
	
	-- call all pre_dismiss_advice_callbacks	
	for i = 1, #self.pre_dismiss_advice_callbacks do
		self.pre_dismiss_advice_callbacks[i]();
	end;
	
	self.pre_dismiss_advice_callbacks = {};
	
	-- perform the advice dismissal
	self.game_interface:dismiss_advice();
	self.infotext:clear_infotext();
	
	-- unhighlight advisor progress button	
	highlight_advisor_progress_button(false);
end;


--- @function progress_on_advice_dismissed
--- @desc Registers a function to be called when the advisor is dismissed. Only one such function can be registered at a time.
--- @p function callback, Callback to call.
--- @p [opt=0] number delay, Delay in seconds after the advisor is dismissed before calling the callback.
--- @p [opt=false] boolean highlight on finish, Highlight on advice finish. If set to <code>true</code>, this also establishes a listener for the advice VO finishing. When it does finish, this function then highlights the advisor close button.
function campaign_manager:progress_on_advice_dismissed(callback, delay, highlight_on_finish)
	if not is_function(callback) then
		script_error("ERROR: progress_on_advice_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if not is_number(delay) or delay < 0 then
		delay = 0;
	end;
	
	-- a test to see if the advisor is visible on-screen at this moment
	local advisor_open_test = function()
		local uic_advisor = find_uicomponent(core:get_ui_root(), "advice_interface");
		return self.advice_enabled and uic_advisor and uic_advisor:Visible(true) and uic_advisor:CurrentAnimationId() == "";
	end;
	
	-- a function to set up listeners for the advisor closing
	local progress_func = function()
		local is_dismissed = false;
		local is_highlighted = false;
	
		core:add_listener(
			self.progress_on_advice_dismissed_str,
			"AdviceDismissed",
			true,
			function()
				is_dismissed = true;
				
				if highlight_on_finish then
					self:cancel_progress_on_advice_finished();
				end;
			
				-- remove the highlight if it's applied
				if is_highlighted then
					self:modify_advice(true, false);
				end;
			
				if delay > 0 then
					self:callback(function() callback() end, delay);
				else
					callback();
				end;
			end,
			false
		);
		
		-- if the highlight_on_finish flag is set, we highlight the advisor close button when the 
		if highlight_on_finish then
			self:progress_on_advice_finished(
				function()
					if not is_dismissed then
						is_highlighted = true;
						self:modify_advice(true, true) 
					end;
				end
			);
		end;
	end;
	
	-- If the advisor open test passes then set up the progress listener, otherwise wait 0.5 seconds and try it again.
	-- If the advisor fails this test three times (i.e over the course of a second) then automatically progress
	if advisor_open_test() then
		progress_func();
	else
		self:os_clock_callback(
			function()
				if advisor_open_test() then
					progress_func();
				else
					self:os_clock_callback(
						function()
							if advisor_open_test() then
								progress_func();
							else
								if delay > 0 then
									self:callback(function() callback() end, delay);
								else
									callback();
								end;
							end;
						end,
						0.5,
						self.progress_on_advice_dismissed_str
					);
				end;
			end,
			0.5,
			self.progress_on_advice_dismissed_str
		);
	end;
end;


--- @function cancel_progress_on_advice_dismissed
--- @desc Cancels any running @campaign_manager:progress_on_advice_dismissed process.
function campaign_manager:cancel_progress_on_advice_dismissed()
	core:remove_listener(self.progress_on_advice_dismissed_str);
	self:remove_callback(self.progress_on_advice_dismissed_str);
end;


--- @function progress_on_advice_finished
--- @desc Registers a function to be called when the advisor VO has finished playing and the <code>AdviceFinishedTrigger</code> event is sent from the game to script. If this event is not received after a duration (default 5 seconds) the function starts actively polling whether the advice audio is still playing, and calls the callback when it finds that it isn't.
--- @desc Only one process invoked by this function may be active at a time.
--- @p function callback, Callback to call.
--- @p [opt=0] number delay, Delay in seconds after the advisor finishes before calling the callback. By default, the function does not delay.
--- @p [opt=nil] number playtime, Time in seconds to wait before actively polling whether the advice is still playing. The default value is 5 seconds unless overridden with this parameter. This is useful during development as if no audio has yet been recorded, or if no advice is playing for whatever reason, the function would otherwise continue to monitor until the next time advice is triggered, which is probably not desired.
--- @p [opt=false] boolean use os clock, Use OS clock. Set this to true if the process is going to be running during the end-turn sequence, where the normal flow of model time completely breaks down.
function campaign_manager:progress_on_advice_finished(callback, delay, playtime, use_os_clock)
	if not is_function(callback) then
		script_error("ERROR: progress_on_advice_finished() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;

	if delay and not is_number(delay) then
		script_error("ERROR: progress_on_advice_finished() called but supplied delay [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;

	if playtime and not is_number(playtime) then
		script_error("ERROR: progress_on_advice_finished() called but supplied playtime [" .. tostring(playtime) .. "] is not a number or nil");
		return false;
	end;
	
	local call_callback_with_delay = function()
		self:cancel_progress_on_advice_finished();
		
		-- do the given callback
		if is_number(delay) and delay > 0 then
			if use_os_clock then
				self:os_clock_callback(
					function() 
						callback() 
					end, 
					delay, 
					self.progress_on_advice_finished_str
				);
			else
				self:callback(
					function() 
						callback() 
					end, 
					delay, 
					self.progress_on_advice_finished_str
				);
			end;
		else
			callback();
		end;
	end;
	
	-- if advice is disabled then just finish
	if not self.advice_enabled then
		call_callback_with_delay();
		return;
	end;
	
	if effect.is_advice_audio_playing() then
		-- advice is currently playing
		core:add_listener(
			self.progress_on_advice_finished_str,
			"AdviceFinishedTrigger",
			true,
			function()
				call_callback_with_delay();
			end,
			false
		);
	end;
	
	playtime = playtime or 5;
	
	if use_os_clock then
		self:os_clock_callback(
			function() 
				self:progress_on_advice_finished_poll(call_callback_with_delay, playtime, use_os_clock, 0) 
			end, 
			playtime, 
			self.progress_on_advice_finished_str
		);
	else
		self:callback(
			function() 
				self:progress_on_advice_finished_poll(call_callback_with_delay, playtime, use_os_clock, 0) 
			end, 
			playtime, 
			self.progress_on_advice_finished_str
		);
	end;
end;


-- used internally by progress_on_advice_finished
function campaign_manager:progress_on_advice_finished_poll(callback, playtime, use_os_clock, count)
	count = count or 0;
	
	if not effect.is_advice_audio_playing() then
		self:cancel_progress_on_advice_finished();
		
		out("progress_on_advice_finished is progressing as no advice sound is playing after playtime of " .. playtime + (count * self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME) .. "s");
		
		callback();
		return;
	end;
	
	count = count + 1;
	
	-- sound is still playing, check again in a bit
	if use_os_clock then
		self:os_clock_callback(
			function() 
				self:progress_on_advice_finished_poll(callback, playtime, use_os_clock, count) 
			end, 
			self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME, 
			self.progress_on_advice_finished_str
		);
	else
		self:callback(
			function() 
				self:progress_on_advice_finished_poll(callback, playtime, use_os_clock, count) 
			end, 
			self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME, 
			self.progress_on_advice_finished_str
		);
	end;
end;


--- @function cancel_progress_on_advice_finished
--- @desc Cancels any running @campaign_manager:progress_on_advice_finished process.
function campaign_manager:cancel_progress_on_advice_finished()
	core:remove_listener(self.progress_on_advice_finished_str);
	self:remove_callback(self.progress_on_advice_finished_str);
end;












-----------------------------------------------------------------------------
--- @section Progress on UI Event
-----------------------------------------------------------------------------


--- @function progress_on_panel_dismissed
--- @desc Calls a supplied callback when a panel with the supplied name is closed.
--- @p string unique name, Unique descriptive string name for this process. Multiple <code>progress_on_panel_dismissed</code> monitors may be active at any one time.
--- @p string panel name, Name of the panel.
--- @p function callback, Callback to call.
--- @p [opt=0] number callback delay, Time in seconds to wait after the panel dismissal before calling the supplied callback.
function campaign_manager:progress_on_panel_dismissed(name, panel_name, callback, delay)
	
	if not is_string(name) then
		script_error("ERROR: progress_on_panel_dismissed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(panel_name) then
		script_error("ERROR: progress_on_panel_dismissed() called but supplied panel name [" .. tostring(panel_name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: progress_on_panel_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;

	delay = delay or 0;
	
	if not is_number(delay) or delay < 0 then
		script_error("ERROR: progress_on_panel_dismissed() called but supplied delay [" .. tostring(delay) .. "] is not a positive number or nil");
		return false;
	end;
	
	local listener_name = name .. "_progress_on_panel_dismissed";
	
	if self:get_campaign_ui_manager():is_panel_open(panel_name) then
		core:add_listener(
			listener_name,
			"PanelClosedCampaign",
			function(context) return context.string == panel_name end,
			function()
				if delay == 0 then
					callback();
				else
					self:callback(callback, delay);
				end;
			end,
			false
		);
	else
		if delay == 0 then
			callback();
		else
			self:callback(callback, delay, listener_name);
		end;
	end;
end;


--- @function cancel_progress_on_panel_dismissed
--- @desc Cancels a monitor started with @campaign_manager:progress_on_panel_dismissed by name.
--- @p string unique name, Unique descriptive string name for this process.
function campaign_manager:cancel_progress_on_panel_dismissed(name)
	local listener_name = name .. "_progress_on_panel_dismissed";
	
	core:remove_listener(listener_name);
	self:remove_callback(listener_name);
end;


--- @function progress_on_events_dismissed
--- @desc Calls a supplied callback when all events panels are closed. Analagous to calling @campaign_manager:progress_on_panel_dismissed with the panel name "events".
--- @p string unique name, Unique descriptive string name for this process. Multiple <code>progress_on_panel_dismissed</code> monitors may be active at any one time.
--- @p function callback, Callback to call.
--- @p [opt=0] number callback delay, Time in seconds to wait after the panel dismissal before calling the supplied callback.
function campaign_manager:progress_on_events_dismissed(name, callback, delay)
	return self:progress_on_panel_dismissed(name, "events", callback, delay);
end;


--- @function cancel_progress_on_events_dismissed
--- @desc Cancels a monitor started with @campaign_manager:progress_on_events_dismissed (or @campaign_manager:progress_on_panel_dismissed) by name.
--- @p string unique name, Unique descriptive string name for this process.
function campaign_manager:cancel_progress_on_events_dismissed(name)
	return self:cancel_progress_on_panel_dismissed(name);
end;


--- @function progress_on_fullscreen_panel_dismissed
--- @desc Calls the supplied callback when all fullscreen campaign panels are dismissed. Only one such monitor may be active at once - starting a second will cancel the first.
--- @p function callback, Callback to call.
--- @p [opt=0] number callback delay, Time in seconds to wait after the panel dismissal before calling the supplied callback.
function campaign_manager:progress_on_fullscreen_panel_dismissed(callback, delay)
	delay = delay or 0;
	
	self:cancel_progress_on_fullscreen_panel_dismissed();
	
	local open_fullscreen_panel = self:get_campaign_ui_manager():get_open_fullscreen_panel();
		
	if open_fullscreen_panel then
		core:add_listener(
			"progress_on_fullscreen_panel_dismissed",
			"ScriptEventPanelClosedCampaign",
			function(context) return context.string == open_fullscreen_panel end,
			function() self:progress_on_fullscreen_panel_dismissed(callback, delay) end,
			false
		);
	else
		self:callback(callback, delay, "progress_on_fullscreen_panel_dismissed");
	end;
end;


--- @function cancel_progress_on_fullscreen_panel_dismissed
--- @desc Cancels any running monitor started with @campaign_manager:progress_on_fullscreen_panel_dismissed.
--- @p function callback, Callback to call.
--- @p [opt=0] number callback delay, Time in seconds to wait after the panel dismissal before calling the supplied callback.
function campaign_manager:cancel_progress_on_fullscreen_panel_dismissed()
	self:remove_callback("progress_on_fullscreen_panel_dismissed");
end;


--- @function start_intro_cutscene_on_loading_screen_dismissed
--- @desc This function provides an easy one-shot method of starting an intro flyby cutscene from a loading screen with a fade effect. Call this function on the first tick (or before), and pass to it a function which starts an intro cutscene.
--- @p function callback, Callback to call.
--- @p [opt=0] number fade in time, Time in seconds over which to fade in the camera from black.
function campaign_manager:start_intro_cutscene_on_loading_screen_dismissed(callback, fade_in_duration)
	if not is_function(callback) then
		script_error("ERROR: start_intro_cutscene_on_loading_screen_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	fade_in_duration = fade_in_duration or 1;
	
	if not is_number(fade_in_duration) or fade_in_duration < 0 then
		script_error("ERROR: start_intro_cutscene_on_loading_screen_dismissed() called but supplied fade in duration [" .. tostring(fade_in_duration) .. "] is not a positive number or nil");
		return false;
	end;
	
	CampaignUI.ToggleCinematicBorders(true);
	self:fade_scene(0, 0);

	core:progress_on_loading_screen_dismissed(
		function()
			self:fade_scene(1, fade_in_duration);
			callback();
		end
	);
end;


-- progress on mission accepted
-- Old-style mission progression listener, with ui locking. Ideally use progress_on_events_dismissed instead.
function campaign_manager:progress_on_mission_accepted(callback, delay, should_lock)
	if not is_function(callback) then
		script_error("ERROR: progress_on_mission_accepted() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local uim = self:get_campaign_ui_manager();
	
	should_lock = not not should_lock;	
	self.ui_locked_for_mission = should_lock;
	
	-- we should lock out elements of the ui so that the player is compelled to accept the mission
	if should_lock then
		uim:lock_ui();
	end;
	
	local callback_func = function()
		if should_lock then
			uim:unlock_ui();
		end;
		callback();
	end;

	core:add_listener(
		"progress_on_mission_accepted",
		"ScriptEventPanelClosedCampaign", 
		function(context) return context.string == "events" or context.string == "quest_details" end,
		function()
			core:remove_listener("progress_on_mission_accepted");
			
			self.ui_locked_for_mission = false;
			
			if is_number(delay) and delay > 0 then
				self:callback(callback_func, delay);
			else
				callback_func();
			end;
		end,
		false
	);
end;


function campaign_manager:cancel_progress_on_mission_accepted()
	if self.ui_locked_for_mission then
		self:get_campaign_ui_manager():unlock_ui();
	end;
	
	core:remove_listener("progress_on_mission_accepted");
end;


--- @function progress_on_battle_completed
--- @desc Calls the supplied callback when a battle sequence is fully completed. A battle sequence is completed once the pre or post-battle panel has been dismissed and any subsequent camera animations have finished.
--- @p string name, Unique name for this monitor. Multiple such monitors may be active at once.
--- @p function callback, Callback to call.
--- @p [opt=0] number delay, Delay in ms after the battle sequence is completed before calling the callback.
function campaign_manager:progress_on_battle_completed(name, callback, delay)
	delay = delay or 0;
	
	if not is_string(name) then
		script_error("ERROR: progress_on_battle_completed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_function(callback) then
		script_error("ERROR: progress_on_battle_completed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if self:is_processing_battle() then
		core:add_listener(
			"progress_on_battle_completed_" .. name,
			"ScriptEventPlayerBattleSequenceCompleted",
			true,
			function(context)
				self:callback(function() callback() end, delay, "progress_on_battle_completed_" .. name);
			end,
			false		
		);
	else
		if delay > 0 then
			self:callback(function() callback() end, delay, "progress_on_battle_completed_" .. name);
		else
			callback();
		end;			
	end;
end;


--- @function cancel_progress_on_battle_completed
--- @desc Cancels a running monitor started with @campaign_manager:progress_on_battle_completed by name.
--- @p string name, Name of monitor to cancel.
function campaign_manager:cancel_progress_on_battle_completed(name)
	if not is_string(name) then
		script_error("ERROR: cancel_progress_on_battle_completed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	core:remove_listener("progress_on_battle_completed_" .. name);
	self:remove_callback("progress_on_battle_completed_" .. name);
end;


--- @function progress_on_camera_movement_finished
--- @desc Calls the supplied callback when the campaign camera is seen to have finished moving. The function has to poll the camera position repeatedly, so the supplied callback will not be called the moment the camera comes to rest due to the model tick resolution.
--- @desc Only one such monitor may be active at once.
--- @p function callback, Callback to call.
--- @p [opt=0] number delay, Delay in ms after the camera finishes moving before calling the callback.
function campaign_manager:progress_on_camera_movement_finished(callback, delay)
	delay = delay or 0;

	if not is_function(callback) then
		script_error("ERROR: progress_on_camera_movement_finished() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	out("progress_on_camera_movement_finished() called");
	
	local x, y, b, d, h = self:get_camera_position();
		
	self:repeat_callback(
		function()
			local new_x, new_y, new_b, new_d, new_h = self:get_camera_position();
			
			-- out("\tcurrent camera pos is [" .. new_x .. ", " .. new_y .. ", " .. new_b .. ", " .. new_d .. ", " .. new_h .. "], cached is [" .. x .. ", " .. y .. ", " .. b .. ", " .. d .. ", " .. h .."]");
			
			if math.abs(x - new_x) < 0.1 and
						math.abs(y - new_y) < 0.1 and
						math.abs(b - new_b) < 0.1 and
						math.abs(d - new_d) < 0.1 and
						math.abs(h - new_h) < 0.1  then
				
				-- camera pos matches, the camera movement is finished
				if delay then
					self:remove_callback("progress_on_camera_movement_finished");
					self:callback(function() callback() end, delay, "progress_on_camera_movement_finished");
				else
					self:remove_callback("progress_on_camera_movement_finished");
					callback();
				end;
			else
				-- camera pos doesn't match
				x = new_x;
				y = new_y;
				b = new_b;
				d = new_d;
				h = new_h;
			end
		end,
		0.2,
		"progress_on_camera_movement_finished"
	);
end;


--- @function cancel_progress_on_camera_movement_finished
--- @desc Cancels a running monitor started with @campaign_manager:progress_on_camera_movement_finished.
function campaign_manager:cancel_progress_on_camera_movement_finished()
	self:remove_callback("progress_on_camera_movement_finished");
end;


--- @function progress_on_post_battle_panel_visible
--- @desc Calls the supplied callback when the post-battle panel has finished animating on-screen. The function has to poll the panel state repeatedly, so the supplied callback will not be called the exact moment the panel comes to rest. Don't call this unless you know that the panel is about to animate on, otherwise it will be repeatedly polling in the background!
--- @desc Only one such monitor may be active at once.
--- @p function callback, Callback to call.
--- @p [opt=0] number delay, Delay in ms after the panel finishes moving before calling the callback.
function campaign_manager:progress_on_post_battle_panel_visible(callback, delay)

	local uic_panel = find_uicomponent(core:get_ui_root(), "popup_battle_results", "mid");

	if uic_panel and uic_panel:Visible(true) and is_fully_onscreen(uic_panel) and uic_panel:CurrentAnimationId() == "" then		
		
		if delay and is_number(delay) and delay > 0 then
			self:callback(callback, delay, "progress_on_post_battle_panel_visible");
		else
			callback();
		end;
	else
		self:callback(
			function()
				self:progress_on_post_battle_panel_visible(callback, delay)
			end,
			0.2, 
			"progress_on_post_battle_panel_visible"
		);
	end;
end;


--- @function cancel_progress_on_post_battle_panel_visible
--- @desc Cancels a running monitor started with @campaign_manager:progress_on_post_battle_panel_visible.
function campaign_manager:cancel_progress_on_post_battle_panel_visible()
	self:remove_callback("progress_on_post_battle_panel_visible");
end;















-----------------------------------------------------------------------------
--- @section Character Creation and Manipulation
-----------------------------------------------------------------------------


--- @function create_force
--- @desc Instantly spawn an army with a general on the campaign map. This function is a wrapper for the @episodic_scripting:create_force function provided by the episodic scripting interface, adding debug output and success callback functionality.
--- @p @string faction key, Faction key of the faction to which the force is to belong.
--- @p @string unit list, Comma-separated list of keys from the <code>land_units</code> table. The force will be created with these units.
--- @p @string region key, Region key of home region for this force.
--- @p @number x, x logical co-ordinate of force.
--- @p @number y, y logical co-ordinate of force.
--- @p @boolean exclude named characters, Don't spawn a named character at the head of this force.
--- @p [opt=nil] @function success callback, Callback to call once the force is created. The callback will be passed the created military force leader's cqi as a single argument.
--- @p [opt=false] @boolean command queue, Use command queue.
--- @example cm:create_force(
--- @example 	"wh_main_dwf_dwarfs",
--- @example 	"wh_main_dwf_inf_hammerers,wh_main_dwf_inf_longbeards_1,wh_main_dwf_inf_quarrellers_0,wh_main_dwf_inf_quarrellers_0",
--- @example 	"wh_main_the_silver_road_karaz_a_karak",
--- @example 	714,
--- @example 	353,
--- @example 	"scripted_force_1",
--- @example 	true,
--- @example 	function(cqi)
--- @example 		out("Force created with char cqi: " .. cqi);
--- @example 	end
--- @example );
function campaign_manager:create_force(faction_key, unit_list, region_key, x, y, exclude_named_characters, success_callback, command_queue)
	if not is_string(faction_key) then
		script_error("ERROR: create_force() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(unit_list) then
		script_error("ERROR: create_force() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: create_force() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_boolean(exclude_named_characters) then
		script_error("ERROR: create_force() called but supplied exclude named characters switch [" .. tostring(exclude_named_characters) .. "] is not a boolean value");	
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;

	if command_queue == nil then
		command_queue = true;
	end
	
	-- this is now generated internally, rather than being passed in from the calling function
	local id = tostring(core:get_unique_counter());
	
	local listener_name = "campaign_manager_create_force_" .. id;
	
	-- establish a listener for the force being created
	core:add_listener(
		listener_name,
		"ScriptedForceCreated",
		function(context)
			return context.string == id;
		end,
		function() self:force_created(id, listener_name, faction_key, x, y, success_callback) end,
		false
	);
	
	out("create_force() called:");
	out.inc_tab();
	
	out("faction_key: " .. faction_key);
	out("unit_list: " .. unit_list);
	out("region_key: " .. region_key);
	out("x: " .. tostring(x));
	out("y: " .. tostring(y));
	out("id: " .. id);
	out("exclude_named_characters: " .. tostring(exclude_named_characters));
	
	out.dec_tab();
	
	-- make the call to create the force
	self.game_interface:create_force(faction_key, unit_list, region_key, x, y, id, exclude_named_characters, command_queue);
end;


--- @function create_force_with_general
--- @desc Instantly spawns an army with a specific general on the campaign map. This function is a wrapper for the @episodic_scripting:create_force_with_general function provided by the underlying episodic scripting interface, adding debug output and success callback functionality.
--- @p string faction key, Faction key of the faction to which the force is to belong.
--- @p string unit list, Comma-separated list of keys from the <code>land_units</code> table. The force will be created with these units. This can be a blank string, or nil, if an empty force is desired.
--- @p string region key, Region key of home region for this force.
--- @p number x, x logical co-ordinate of force.
--- @p number y, y logical co-ordinate of force.
--- @p string agent type, Character type of character at the head of the army (should always be "general"?).
--- @p string agent subtype, Character subtype of character at the head of the army.
--- @p string forename, Localised string key of the created character's forename. This should be given in the localised text lookup format i.e. a key from the <code>names</code> table with "names_name_" prepended.
--- @p string clan name, Localised string key of the created character's clan name. This should be given in the localised text lookup format i.e. a key from the <code>names</code> table with "names_name_" prepended.
--- @p string family name, Localised string key of the created character's family name. This should be given in the localised text lookup format i.e. a key from the <code>names</code> table with "names_name_" prepended.
--- @p string other name, Localised string key of the created character's other name. This should be given in the localised text lookup format i.e. a key from the <code>names</code> table with "names_name_" prepended.
--- @p boolean make faction leader, Make the spawned character the faction leader.
--- @p [opt=nil] function success callback, Callback to call once the force is created. The callback will be passed the created military force leader's cqi as a single argument.
--- @example cm:create_force_with_general(
--- @example 	"wh_main_dwf_dwarfs",
--- @example 	"wh_main_dwf_inf_hammerers,wh_main_dwf_inf_longbeards_1,wh_main_dwf_inf_quarrellers_0,wh_main_dwf_inf_quarrellers_0",
--- @example 	"wh_main_the_silver_road_karaz_a_karak",
--- @example 	714,
--- @example 	353,
--- @example 	"general",
--- @example 	"dwf_lord",
--- @example 	"names_name_2147344345",
--- @example 	"",
--- @example 	"names_name_2147345842",
--- @example 	"",
--- @example 	"scripted_force_1",
--- @example 	false,
--- @example 	function(cqi)
--- @example 		out("Force created with char cqi: " .. cqi);
--- @example 	end
--- @example );
function campaign_manager:create_force_with_general(faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, make_faction_leader, success_callback)
	if not is_string(faction_key) then
		script_error("ERROR: create_force_with_general() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;

	if not unit_list then
		unit_list = "";
	elseif not is_string(unit_list) then
		script_error("ERROR: create_force_with_general() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
		
	if not is_string(region_key) then
		script_error("ERROR: create_force_with_general() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force_with_general() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force_with_general() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_string(agent_type) then
		script_error("ERROR: create_force_with_general() called but supplied agent_type [" .. tostring(agent_type) .. "] is not a string");
		return;
	end;
	
	if not is_string(agent_subtype) then
		script_error("ERROR: create_force_with_general() called but supplied agent_subtype [" .. tostring(agent_subtype) .. "] is not a string");
		return;
	end;
	
	if not is_string(forename) then
		script_error("ERROR: create_force_with_general() called but supplied forename [" .. tostring(forename) .. "] is not a string");
		return;
	end;
	
	if not is_string(clan_name) then
		script_error("ERROR: create_force_with_general() called but supplied clan_name [" .. tostring(clan_name) .. "] is not a string");
		return;
	end;
	
	if not is_string(family_name) then
		script_error("ERROR: create_force_with_general() called but supplied family_name [" .. tostring(family_name) .. "] is not a string");
		return;
	end;
	
	if not is_string(other_name) then
		script_error("ERROR: create_force_with_general() called but supplied other_name [" .. tostring(other_name) .. "] is not a string");
		return;
	end;
	
	if not is_boolean(make_faction_leader) then
		script_error("ERROR: create_force() called but supplied make faction leader switch [" .. tostring(make_faction_leader) .. "] is not a boolean value");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force_with_general() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
		
	local faction = cm:get_faction(faction_key);
	
	if not is_faction(faction) then
		script_error("ERROR: create_force_with_general() called but supplied faction [" .. tostring(faction_key) .. "] could not be found");
		return;
	end;
	
	local region = cm:get_region(region_key);
	if not is_region(region) then
		script_error("ERROR: create_force_with_general() called but supplied region key [" .. tostring(region_key) .. "] is not a valid region");
	end;
	
	-- this is now generated internally, rather than being passed in from the calling function
	local id = tostring(core:get_unique_counter());
	
	local listener_name = "campaign_manager_create_force_" .. id;
	local num_forces = faction:military_force_list():num_items();
	
	core:add_listener(
		listener_name,
		"ScriptedForceCreated",
		function(context) return context.string == id end,
		function() self:force_created(id, listener_name, faction_key, x, y, success_callback) end,
		false
	);
	
	out("create_force_with_general() called:");
	out.inc_tab();
	
	out("faction_key: " .. faction_key);
	out("unit_list: " .. unit_list);
	out("region_key: " .. region_key);
	out("x: " .. tostring(x));
	out("y: " .. tostring(y));
	out("agent_type: " .. agent_type);
	out("agent_subtype: " .. agent_subtype);
	out("forename: " .. forename);
	out("clan_name: " .. clan_name);
	out("family_name: " .. family_name);
	out("other_name: " .. other_name);
	out("id: " .. id);
	out("make_faction_leader: " .. tostring(make_faction_leader));
	
	out.dec_tab();
	
	-- make the call to create the force
	self.game_interface:create_force_with_general(faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, forename, clan_name, family_name, other_name, id, make_faction_leader);
end;


--- @function create_force_with_existing_general
--- @desc Instantly spawn an army with a specific existing general on the campaign map. This function is a wrapper for the @episodic_scripting:create_force_with_existing_general function provided by the underlying episodic scripting interface, adding debug output and success callback functionality. The general character is specified by character string lookup.
--- @p string character lookup, Character lookup string for the general character.
--- @p string faction key, Faction key of the faction to which the force is to belong.
--- @p string unit list, Comma-separated list of keys from the <code>land_units</code> table. The force will be created with these units.
--- @p string region key, Region key of home region for this force.
--- @p number x, x logical co-ordinate of force.
--- @p number y, y logical co-ordinate of force.
--- @p [opt=nil] function success callback, Callback to call once the force is created. The callback will be passed the created military force leader's cqi as a single argument.
--- @example cm:create_force_with_existing_general(
--- @example 	cm:char_lookup_str(char_dwf_faction_leader),
--- @example 	"wh_main_dwf_dwarfs",
--- @example 	"wh_main_dwf_inf_hammerers,wh_main_dwf_inf_longbeards_1,wh_main_dwf_inf_quarrellers_0,wh_main_dwf_inf_quarrellers_0",
--- @example 	"wh_main_the_silver_road_karaz_a_karak",
--- @example 	714,
--- @example 	353,
--- @example 	function(cqi)
--- @example 		out("Force created with char cqi: " .. cqi);
--- @example 	end
--- @example );
function campaign_manager:create_force_with_existing_general(char_str, faction_key, unit_list, region_key, x, y, success_callback)
	if not is_string(char_str) then
		script_error("ERROR: create_force_with_existing_general() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return;
	end;
	
	if not is_string(faction_key) then
		script_error("ERROR: create_force_with_existing_general() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(unit_list) then
		script_error("ERROR: create_force_with_existing_general() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: create_force_with_existing_general() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force_with_existing_general() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force_with_existing_general() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force_with_existing_general() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
		
	local faction = cm:get_faction(faction_key);
	
	if not is_faction(faction) then
		script_error("ERROR: create_force_with_existing_general() called but supplied faction [" .. tostring(faction_key) .. "] could not be found");
		return;
	end;
	
	local region = cm:get_region(region_key);
	if not is_region(region) then
		script_error("ERROR: create_force_with_existing_general() called but supplied region key [" .. tostring(region_key) .. "] is not a valid region");
	end;
	
	-- this is now generated internally, rather than being passed in from the calling function
	local id = tostring(core:get_unique_counter());
	
	local listener_name = "campaign_manager_create_force_" .. id;
	local num_forces = faction:military_force_list():num_items();
	
	core:add_listener(
		listener_name,
		"ScriptedForceCreated",
		function(context) return context.string == id end,
		function() self:force_created(id, listener_name, faction_key, x, y, success_callback) end,
		false
	);
	
	out("create_force_with_existing_general() called:");
	out.inc_tab();
	
	out("char_str: " .. char_str);
	out("faction_key: " .. faction_key);
	out("unit_list: " .. unit_list);
	out("region_key: " .. region_key);
	out("x: " .. tostring(x));
	out("y: " .. tostring(y));
	out("id: " .. id);
	
	out.dec_tab();
	
	-- make the call to create the force
	self.game_interface:create_force_with_existing_general(char_str, faction_key, unit_list, region_key, x, y, id);
end;


-- called by create_force() commands above when a force has been created, either directly (if the force was not created via the command
-- queue) or via the ScriptedForceCreated event (if the force was created via the command queue). This attempts to find the newly-created 
-- character and returns its cqi to the calling code.
function campaign_manager:force_created(id, listener_name, faction_key, x, y, success_callback)
	if not is_function(success_callback) then
		return;
	end;
	
	-- find the cqi of the force just created
	local character_list = cm:get_faction(faction_key):character_list();
	for i = 0, character_list:num_items() - 1 do
		local char = character_list:item_at(i);
		if char:logical_position_x() == x and char:logical_position_y() == y then
			
			if char:has_military_force() and char:military_force():has_general() then
				-- we have found it, remove this listener, call the success callback with the character cqi as parameter and exit
				core:remove_listener(listener_name);
				local cqi = char:cqi();
				local force_cqi = char:military_force():command_queue_index();
				success_callback(cqi, force_cqi);
				return cqi, force_cqi;
			end;
		end;
	end;
	
	return false;
end;


--- @function kill_character
--- @desc Kills the specified character, with the ability to also destroy their whole force if they are commanding one.
--- @p string character lookup string, Character string of character to kill. This uses the standard character string lookup system.
--- @p [opt=false] boolean destroy force, Will also destroy the characters whole force if true.
--- @p [opt=true] boolean use command queue, Send the create command through the command queue.
function campaign_manager:kill_character(character_cqi, destroy_force, command_queue)
	if not is_number(character_cqi) then
		script_error("ERROR: kill_character() called but supplied character_cqi [" .. tostring(character_cqi) .. "] is not a number");
		return false;
	end;
	
	destroy_force = destroy_force or false;
	
	if command_queue ~= false then
		command_queue = true;
	end
	
	if self:model():has_character_command_queue_index(character_cqi) == true then
		local character_obj = self:model():character_for_command_queue_index(character_cqi);
		
		if character_obj:is_null_interface() == false then
			local lookup = "character_cqi:"..character_cqi;
			
			-- If this character has a force then they also currently have a unit so to kill the character AND the unit too we need to use a bespoke function
			if character_obj:has_military_force() == true then
				self.game_interface:kill_character_and_commanded_unit(lookup, destroy_force, command_queue);
			else
				self.game_interface:kill_character(lookup, destroy_force, command_queue);
			end
			return true;
		end
	end
	return false;
end


--- @function add_building_to_force
--- @desc Adds one or more buildings to a horde army. The army is specified by the command queue index of the military force. A single building may be specified by a string key, or multiple buildings in a table.
--- @p number military force cqi, Command queue index of the military force to add the building(s) to.
--- @p object building(s), Building key or keys to add to the military force. This can be a single string or a numerically-indexed table.
function campaign_manager:add_building_to_force(cqi, building_level)
	if not is_number(cqi) then
		script_error("ERROR: add_building_to_force() called but supplied cqi [" .. tostring(cqi) .. "] is not a number");
		return false;
	end;
	
	if is_string(building_level) then
		out("add_building_to_force() called, adding building level [" .. building_level .. "] to military force cqi [" .. cqi .. "]");
		
		self.game_interface:add_building_to_force(cqi, building_level);
	elseif is_table(building_level) then
		out("add_building_to_force() called, adding buildings military force cqi [" .. cqi .. "]");
		
		for i = 1, #building_level do
			local current_building_level = building_level[i];
			
			if is_string(current_building_level) then
				out("\tAdding building level [" .. current_building_level .. "]");
				
				self.game_interface:add_building_to_force(cqi, current_building_level);
			else
				script_error("ERROR: add_building_to_force() called but supplied building_level table element [" .. tostring(current_building_level) .. "] is not a string");
				return false;
			end;
		end;
		
		out("add_building_to_force() finished adding buildings");
	else
		script_error("ERROR: add_building_to_force() called but supplied building_level [" .. tostring(building_level) .. "] is not a string or table");
		return false;
	end;
end;


--- @function create_agent
--- @desc Creates an agent of a specified type on the campaign map. This function is a wrapper for the @episodic_scripting:create_agent function provided by the underlying episodic scripting interface. This wrapper function adds validation and success callback functionality.
--- @p string faction key, Faction key of the faction to which the agent is to belong.
--- @p string character type, Character type of the agent.
--- @p string character subtype, Character subtype of the agent.
--- @p number x, x logical co-ordinate of agent.
--- @p number y, y logical co-ordinate of agent.
--- @p string id, Unique string for agent.
--- @p boolean use command queue, Send the create command through the command queue.
--- @p [opt=nil] function success callback, Callback to call once the character is created. The callback will be passed the created character's cqi as a single argument.
--- @example cm:create_agent(
--- @example 	"wh_main_dwf_dwarfs",
--- @example 	"wh_main_the_silver_road_karaz_a_karak",
--- @example 	714,
--- @example 	353,
--- @example 	function(cqi)
--- @example 		out("Force created with char cqi: " .. cqi);
--- @example 	end
--- @example );
function campaign_manager:create_agent(faction_key, agent_key, subtype_key, x, y, command_queue, success_callback)
	if not is_string(faction_key) then
		script_error("ERROR: create_agent() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(agent_key) then
		script_error("ERROR: create_agent() called but supplied agent key [" .. tostring(agent_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(subtype_key) then
		script_error("ERROR: create_agent() called but supplied agent subtype key [" .. tostring(subtype_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_agent() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_agent() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_boolean(command_queue) then
		script_error("ERROR: create_agent() called but supplied command queue switch [" .. tostring(command_queue) .. "] is not a boolean value");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_agent() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
		
	local faction = cm:get_faction(faction_key);
	
	if not is_faction(faction) then
		script_error("ERROR: create_agent() called but supplied faction [" .. tostring(faction_key) .. "] could not be found");
		return;
	end;
	
	-- this is now generated internally, rather than being passed in from the calling function
	local id = tostring(core:get_unique_counter());
	
	local listener_name = "campaign_manager_create_agent_" .. id;
	
	-- if this command is going via the command queue then we won't be able to tell if the agent was created immediately
	if command_queue then
		core:add_listener(
			listener_name,
			"ScriptedAgentCreated",
			true,
			function() self:agent_created(id, listener_name, faction_key, x, y, success_callback) end,
			true
		);
	end;
	
	out("create_agent() called:");
	out.inc_tab();
	
	out("faction_key: " .. faction_key);
	out("agent_key: " .. agent_key);
	out("subtype_key: " .. subtype_key);
	out("x: " .. tostring(x));
	out("y: " .. tostring(y));
	out("id: " .. id);
	out("command_queue: " .. tostring(command_queue));
	
	out.dec_tab();
	
	-- make the call to create the agent
	self.game_interface:create_agent(faction_key, agent_key, subtype_key, x, y, id, command_queue);
	
	-- if we're not using the command queue then verify that the force was created immediately, return false if it somehow wasn't
	if not command_queue then
		return self:agent_created(id, listener_name, faction_key, x, y, success_callback);
	end;
end;


-- called by create_agent() when an agent has been created, either directly (if the agent was not created via the command queue) or
-- via the ScriptedAgentCreated event (if the agent was created via the command queue). This attempts to find the newly-created character
-- and returns its cqi to the calling code. Multiple instances of this listener could be running at the time a ScriptedAgentCreated event
-- has occurred, so if this function can't find the agent it's looking for chances are there are a load being spawned at once and that
-- the relevant one will be along in a bit.
function campaign_manager:agent_created(id, listener_name, faction_key, x, y, success_callback)	
	if not is_function(success_callback) then
		return;
	end;
	
	-- find the cqi of the agent just created
	local character_list = cm:get_faction(faction_key):character_list();
	
	for i = 0, character_list:num_items() - 1 do
		local char = character_list:item_at(i);
		
		if char:logical_position_x() == x and char:logical_position_y() == y then
			
			if char:character_type("champion") or char:character_type("dignitary") or char:character_type("spy") or char:character_type("engineer") or char:character_type("wizard") or char:character_type("runesmith") then
				-- we have found it, remove this listener, call the success callback with the character cqi as parameter and exit
				core:remove_listener(listener_name);
				
				local cqi = char:cqi();
				success_callback(cqi);
				return cqi;
			end;
		end;
	end;
	
	return false;
end;


--- @function reposition_starting_character_for_faction
--- @desc Repositions a specified character (the <i>target</i>) for a faction at start of a campaign, but only if another character (the <i>subject</i>) exists in that faction and is in command of an army. Like @campaign_manager:teleport_to which underpins this function it is for use at the start of a campaign in a game-created callback (see @campaign_manager:add_pre_first_tick_callback). It is intended for use in very specific circumstances.
--- @desc The characters involved are specified by forename key.
--- @p string faction key, Faction key of the subject and target characters.
--- @p string forename key, Forename key of the subject character from the names table using the full localisation format i.e. <code>names_name_[key]</code>.
--- @p string forename key, Forename key of the target character from the names table using the full localisation format i.e. <code>names_name_[key]</code>.
--- @p number x, x logical target co-ordinate.
--- @p number y, y logical target co-ordinate.
--- @return boolean Subject character exists.
--- @example cm:add_pre_first_tick_callback(
--- @example 	function()
--- @example 		cm:reposition_starting_character_for_faction(
--- @example 			"wh_dlc03_bst_beastmen", 
--- @example 			"names_name_2147357619", 
--- @example 			"names_name_2147357619", 
--- @example 			643, 
--- @example 			191
--- @example 		)
--- @example 	end
--- @example )
function campaign_manager:reposition_starting_character_for_faction(faction_name, subject_lord_forename, target_lord_forename, new_pos_x, new_pos_y)
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		script_error("ERROR: reposition_starting_character_for_faction() called but couldn't find faction with supplied name [" .. tostring(faction_name) .. "]");
		return false;
	end;
	
	if not is_string(subject_lord_forename) then
		script_error("ERROR: reposition_starting_character_for_faction() called but supplied lord name [" .. tostring(subject_lord_forename) .. "] is not a string");
		return false;
	end;
	
	if not is_string(target_lord_forename) then
		script_error("ERROR: reposition_starting_character_for_faction() called but supplied lord name [" .. tostring(target_lord_forename) .. "] is not a string");
		return false;
	end;
	
	if not is_number(new_pos_x) or new_pos_x < 0 then
		script_error("ERROR: reposition_starting_character_for_faction() called but supplied x co-ordinate [" .. tostring(new_pos_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(new_pos_y) or new_pos_y < 0 then
		script_error("ERROR: reposition_starting_character_for_faction() called but supplied y co-ordinate [" .. tostring(new_pos_y) .. "] is not a positive number");
		return false;
	end;
	
	-- get character and see if it has an army
	local char_list = faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_subject_char = char_list:item_at(i);
		
		if current_subject_char:get_forename() == subject_lord_forename then
			if self:char_is_general_with_army(current_subject_char) then
				
				-- try and find the target char
				local target_char = false;
				if subject_lord_forename == target_lord_forename then
					target_char = current_subject_char;
				else
					-- the subject char and target char are different, go searching for the latter
					for j = 0, char_list:num_items() - 1 do
						local current_target_char = char_list:item_at(j);
						if current_target_char:get_forename() == target_lord_forename then
							target_char = current_target_char;
							break;
						end;
					end;
				end;
				
				if target_char then			
					out("Teleporting starting Lord with name " .. target_lord_forename .. " for faction " .. faction_name .. " to [" .. new_pos_x .. ", " .. new_pos_y .. "]");
					self:teleport_to(self:char_lookup_str(target_char), new_pos_x, new_pos_y, true);
				else
					script_error("WARNING: reposition_starting_character_for_faction() wanted to perform teleport but could find no character in faction " .. faction_name .. " with name " .. target_lord_forename);
				end;
			end;
			return true;
		end;
	end;
end;


--- @function spawn_army_starting_character_for_faction
--- @desc Spawns a specified force if a character (the <i>subject</i>) exists within a faction with an army. It is intended for use at the start of a campaign in a game-created callback (see @campaign_manager:add_pre_first_tick_callback), in very specific circumstances.
--- @p string faction key, Faction key of the subject character.
--- @p string forename key, Forename key of the subject character from the names table using the full localisation format i.e. <code>names_name_[key]</code>.
--- @p string faction key, Faction key of the force to create.
--- @p string units, list of units to create force with (see documentation for @campaign_manager:create_force for more information).
--- @p string region key, Home region key for the created force.
--- @p number x, x logical target co-ordinate.
--- @p number y, y logical target co-ordinate.
--- @p boolean make_immortal, Set to <code>true</code> to make the created character immortal.
--- @example cm:add_pre_first_tick_callback(
--- @example 	function()
--- @example 		cm:spawn_army_starting_character_for_faction(
--- @example 			"wh_dlc03_bst_beastmen",
--- @example 			"names_name_2147352487",
--- @example 			"wh_dlc03_bst_jagged_horn",
--- @example 			"wh_dlc03_bst_inf_ungor_herd_1,wh_dlc03_bst_inf_ungor_herd_1,wh_dlc03_bst_inf_ungor_raiders_0",
--- @example 			"wh_main_estalia_magritta",
--- @example 			643,
--- @example 			188,
--- @example 			true
--- @example 		)
--- @example 	end
--- @example )
function campaign_manager:spawn_army_starting_character_for_faction(source_faction_name, subject_lord_forename, army_faction_name, army_units, army_home_region, pos_x, pos_y, make_immortal)
	local source_faction = cm:get_faction(source_faction_name);
	local army_faction = cm:get_faction(army_faction_name);
	
	if not source_faction then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but couldn't find source faction with supplied name [" .. tostring(source_faction_name) .. "]");
		return false;
	end;
	
	if not army_faction then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but couldn't find faction with supplied name [" .. tostring(army_faction_name) .. "]");
		return false;
	end;
	
	if not is_string(subject_lord_forename) then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but supplied lord name [" .. tostring(subject_lord_forename) .. "] is not a string");
		return false;
	end;
	
	if not is_string(army_units) then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but supplied army units [" .. tostring(army_units) .. "] is not a string");
		return false;
	end;
	
	if not is_string(army_home_region) then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but supplied army home region [" .. tostring(army_home_region) .. "] is not a string");
		return false;
	end;
	
	if not is_number(pos_x) or pos_x < 0 then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but supplied x co-ordinate [" .. tostring(pos_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(pos_y) or pos_y < 0 then
		script_error("ERROR: spawn_army_starting_character_for_faction() called but supplied y co-ordinate [" .. tostring(pos_y) .. "] is not a positive number");
		return false;
	end;
	
	-- get character and see if it has an army
	local char_list = source_faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_subject_char = char_list:item_at(i);
		
		if current_subject_char:get_forename() == subject_lord_forename then
			if self:char_is_general_with_army(current_subject_char) then	
				out("Found character " .. subject_lord_forename .. " in faction " .. source_faction_name);
				
				self:create_force(
					army_faction_name,
					army_units,
					army_home_region,
					pos_x,
					pos_y,
					true,
					function(cqi)
						if make_immortal then
							local char_str = self:char_lookup_str(cqi);
							self:set_character_immortality(char_str, true);
						end;
					end
				);
			else
				return;	-- we found the general, but he does not command an army
			end;
			
			return;
		end;
	end;
end;



--- @function move_character
--- @desc Helper function to move a character.
--- @p number cqi, Command-queue-index of the character to move.
--- @p number x, x co-ordinate of the intended destination.
--- @p number y, y co-ordinate of the intended destination.
--- @p [opt=false] boolean should replenish, Automatically replenish the character's action points in script should they run out whilst moving. This ensures the character will reach their intended destination in one turn (unless they fail for another reason).
--- @p [opt=true] boolean allow post movement, Allow the army to move after the order is successfully completed. Setting this to <code>false</code> disables character movement with @campaign_manager:disable_movement_for_character should the character successfully reach their destination.
--- @p [opt=nil] function success callback, Callback to call if the character successfully reaches the intended destination this turn.
--- @p [opt=nil] function fail callback, Callback to call if the character fails to reach the intended destination this turn.
function campaign_manager:move_character(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback)
	
	if not is_number(char_cqi) and not is_string(char_cqi) then
		script_error("move_character ERROR: cqi provided [" .. tostring(char_cqi) .. "] is not a number or string");
		return false;
	end;
		
	if not is_number(log_x) or log_x < 0 then
		script_error("move_character ERROR: supplied logical x co-ordinate [" .. tostring(log_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(log_y) or log_y < 0 then
		script_error("move_character ERROR: supplied logical y co-ordinate [" .. tostring(log_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("move_character ERROR: supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(fail_callback) and not is_nil(fail_callback) then
		script_error("move_character ERROR: supplied failure callback [" .. tostring(fail_callback) .. "] is not a function or nil");
		return false;
	end;
	
	should_replenish = not not should_replenish;
	
	if allow_movement_afterwards ~= false then
		allow_movement_afterwards = true;
	end;
	
	out.inc_tab();
	
	local char_str = self:char_lookup_str(char_cqi);
	local trigger_name = "move_character_" .. char_str .. "_" .. tostring(self.move_character_trigger_count);
	self.move_character_trigger_count = self.move_character_trigger_count + 1;
	
	if should_replenish then
		self:replenish_action_points(char_str);
		
		-- listen for the army running out of movement points
		core:add_listener(
			trigger_name,
			"MovementPointsExhausted",
			true,
			function()
				out("move_character() :: MovementPointsExhausted event has occurred, replenishing character action points and moving it to destination");
				self:replenish_action_points(char_str);
				self:move_to(char_str, log_x, log_y, true);
			end,
			true
		);
	end;
	
	out("move_character() moving character (" .. char_str .. ") to [" .. log_x .. ", " .. log_y .. "]");
	
	self:enable_movement_for_character(char_str);
	self:move_to(char_str, log_x, log_y, true);
	
	-- add this trigger to the active list, for if we wish to cancel it
	table.insert(self.move_character_active_list, trigger_name);
	
	-- set up this notification to catch the character halting without reaching the destination
	self:notify_on_character_halt(
		char_cqi, 
		function()
			self:move_character_halted(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name) 
		end
	);
	
	local dis_x, dis_y = self:log_to_dis(log_x, log_y)
	
	-- detection trigger
	-- we do this as the AI can take the army and continue marching with it, which evades the other detection method
	self:add_circle_area_trigger(dis_x, dis_y, 1.5, trigger_name, "character_cqi:" .. char_cqi, true, false, true);
	
	core:add_listener(
		trigger_name,
		"AreaEntered", 
		function(context) return conditions.IsMessageType(trigger_name, context) end,
		function(context) self:move_character_arrived(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name) end, 
		false
	);
	
	out.dec_tab();
end;


--	a character moved by move_character has finished moving for some reason
function campaign_manager:move_character_halted(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name)
	
	self:stop_notify_on_character_halt(char_cqi);
	core:remove_listener(trigger_name);
	
	local character = self:get_character_by_cqi(char_cqi);
	
	if not character then
		script_error("ERROR: move_character_halted() called but couldn't find a character with cqi [" .. tostring(char_cqi) .."]");
		return false;
	end;
	
	-- if we're not within 3 hexes of our intended destination, then call the failure callback
	if distance_squared(log_x, log_y, character:logical_position_x(), character:logical_position_y()) > 9 then
		if is_function(fail_callback) then
			fail_callback();		
		end;
	else
		if is_function(success_callback) then
			success_callback();
		end;
	end;
end;


--	a character moved by move_character has arrived at its destination
function campaign_manager:move_character_arrived(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name)
	
	self:stop_notify_on_character_halt(char_cqi);
	core:remove_listener(trigger_name);
	
	out.inc_tab();

	local char_str = self:char_lookup_str(char_cqi);
	
	core:remove_listener(trigger_name);
	
	-- remove this trigger from the active list
	for i = 1, #self.move_character_active_list do
		if self.move_character_active_list[i] == trigger_name then
			table.remove(self.move_character_active_list, i);
			break;
		end;
	end;
	
	out("Character (" .. char_str .. ") has arrived");
	
	if not allow_movement_afterwards then
		self:disable_movement_for_character(char_str);
	end;
	
	out.dec_tab();
	
	if is_function(success_callback) then
		success_callback();
	end;
end;


--- @function cancel_all_move_character
--- @desc Cancels any running monitors started by @campaign_manager:move_character. This won't actually stop any characters currently moving.
function campaign_manager:cancel_all_move_character()
	for i = 1, #self.move_character_active_list do
		core:remove_listener(self.move_character_active_list[i]);
	end;
	
	self.move_character_active_list = {};
end;


--- @function is_character_moving
--- @desc Calls one callback if a specified character is currently moving, and another if it's not. It does this by recording the character's position, waiting half a second and then comparing the current position with that just recorded.
--- @p number cqi, Command-queue-index of the subject character.
--- @p function moving callback, Function to call if the character is determined to be moving.
--- @p function not moving callback, Function to call if the character is determined to be stationary.
function campaign_manager:is_character_moving(char_cqi, is_moving_callback, is_not_moving_callback)
		
	if not is_number(char_cqi) then
		script_error("ERROR: is_character_moving() called but supplied cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
	
	local cached_char = self:get_character_by_cqi(char_cqi);

	if not is_character(cached_char) then
		script_error("ERROR: is_character_moving() called but couldn't find char with cqi of [" .. char_cqi .. "]");
		return false;
	end;
	
	local cached_pos_x = cached_char:logical_position_x();
	local cached_pos_y = cached_char:logical_position_y();
	
	local callback_name = "is_character_moving_" .. self:char_lookup_str(char_cqi);
	
	self:os_clock_callback(
		function()
			local current_char = self:get_character_by_cqi(char_cqi);
			
			if not is_character(current_char) then
				-- script_error("WARNING: is_character_moving_action() called but couldn't find char with cqi of [" .. char_cqi .. "] after movement - did it die?");
				return false;
			end;
			
			local current_pos_x = current_char:logical_position_x();
			local current_pos_y = current_char:logical_position_y();
			
			if cached_pos_x == current_pos_x and cached_pos_y == current_pos_y then
				-- character hasn't moved
				if is_function(is_not_moving_callback) then
					is_not_moving_callback();
				end;
			else
				-- character has moved
				if is_function(is_moving_callback) then
					is_moving_callback();
				end;
			end;
		end,
		0.5,
		callback_name
	);
end;


--- @function stop_is_character_moving
--- @desc Stops any running monitor started with @campaign_manager:is_character_moving, by character. Note that once the monitor completes (half a second after it was started) it will automatically shut itself down.
--- @p number cqi, Command-queue-index of the subject character.
function campaign_manager:stop_is_character_moving(char_cqi)
	local callback_name = "is_character_moving_" .. self:char_lookup_str(char_cqi);
	
	self:remove_callback(callback_name);
end;


--- @function notify_on_character_halt
--- @desc Calls the supplied callback as soon as a character is determined to be stationary. This uses @campaign_manager:is_character_moving to determine if the character moving so the callback will not be called the instant the character halts.
--- @p number cqi, Command-queue-index of the subject character.
--- @p function callback, Callback to call.
--- @p [opt=false] boolean must move first, If true, the character must be seen to be moving before this monitor will begin. In this case, it will only call the callback once the character has stopped again.
function campaign_manager:notify_on_character_halt(char_cqi, callback, must_move_first)
	if not is_function(callback) then
		script_error("ERROR: notify_on_character_halt() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	must_move_first = not not must_move_first;
	
	if must_move_first then
		-- character must be seen to have moved
		self:is_character_moving(
			char_cqi,
			function()
				-- character is now moving, notify when they stop
				self:is_character_moving(
					char_cqi, 
					function()
						self:notify_on_character_halt(char_cqi, callback, false);
					end,
					function()
						callback(char_cqi);
					end
				);
			end,
			function()
				self:notify_on_character_halt(char_cqi, callback, must_move_first);
			end
		);
	else
		-- can return immediately if the character's stationary
		self:is_character_moving(
			char_cqi, 
			function()
				self:notify_on_character_halt(char_cqi, callback);
			end,
			function()
				callback(char_cqi);
			end
		);
	end;
end;


--- @function stop_notify_on_character_halt
--- @desc Stops any monitor started by @campaign_manager:notify_on_character_halt, by character cqi.
--- @p number cqi, Command-queue-index of the subject character.
function campaign_manager:stop_notify_on_character_halt(char_cqi)
	self:stop_is_character_moving(char_cqi);
end;


--- @function notify_on_character_movement
--- @desc Calls the supplied callback as soon as a character is determined to be moving.
--- @p number cqi, Command-queue-index of the subject character.
--- @p function callback, Callback to call.
--- @p [opt=false] boolean land only, Only movement over land should be considered.
function campaign_manager:notify_on_character_movement(char_cqi, callback, land_only)
	if not is_number(char_cqi) then
		script_error("ERROR: notify_on_character_movement() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
	
	local character = self:get_character_by_cqi(char_cqi);
	
	if not self:get_character_by_cqi(character) then
		script_error("ERROR: notify_on_character_movement() called but no character with the supplied cqi [" .. tostring(char_cqi) .. "] could be found");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: notify_on_character_movement() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local char_str = "";

	if character:character_type("general") then	-- matches any character of the whole faction, thus copes with the target general dying
		char_str = "faction:" .. character:faction():name() .. ",type:general";
	end;
	
	local char_x = character:display_position_x();
	local char_y = character:display_position_y();
	local monitor_name = "notify_on_character_movement_" .. tostring(char_cqi);
	
	-- adding multiple areas as this method is unreliable - this may not trigger if the character leaves a port
	-- or settlement as they jump over the edge of the circle. This should be rewritten to poll character position, maybe
	self:remove_area_trigger(monitor_name);
	self:add_circle_area_trigger(char_x, char_y, 3, monitor_name, char_str, false, true, true);
	self:add_circle_area_trigger(char_x, char_y, 6, monitor_name, char_str, false, true, true);
	
	core:add_listener(
		monitor_name,
		"AreaExited",
		function(context) return context:area_key() == monitor_name end,
		function()
			if land_only then
				-- re-fetch the character and see if it is in a region
				local character = self:get_character_by_cqi(char_cqi);
				
				if not (character and character:has_region()) then
					out("restarting notify_on_character_movement() listener as character may be at sea");
					self:callback(function() notify_on_character_movement(character, callback, land_only) end, 0.2);
					return;
				end;
			end;
			
			self:notify_on_character_halt(char_cqi, callback, char_x, char_y);
		end,
		false
	);
end;


--- @function stop_notify_on_character_movement
--- @desc Stops any monitor started by @campaign_manager:notify_on_character_movement, by character cqi.
--- @p number cqi, Command-queue-index of the subject character.
function campaign_manager:stop_notify_on_character_movement(char_cqi)
	core:remove_listener("notify_on_character_movement_" .. tostring(char_cqi));
end;


--- @function attack
--- @desc Instruct a character at the head of a military force to attack another. This function is a wrapper for the @episodic_scripting:attack function on the underlying episodic scripting interface. The wrapper also enables movement for the character and prints debug output.
--- @p @string attacker, Attacker character string, uses standard character lookup string system.
--- @p @string defender, Defender character string, uses standard character lookup string system.
--- @p @boolean command queue, Order goes via command queue.
function campaign_manager:attack(attacker, defender, command_queue)
	self:enable_movement_for_character(attacker);
	out("Sending [" .. tostring(attacker) .. "] to attack [" .. tostring(defender) .. "]");	
	self.game_interface:attack(attacker, defender, command_queue);
end;


--- @function teleport_to
--- @desc Teleports a character to a logical position on the campaign map. This function is a wrapper for the @episodic_scripting:teleport_to function on the underlying episodic scripting interface. This wrapper adds debug output and argument validation.
--- @desc This function can also reposition the camera, so it's best used on game creation to move characters around at the start of the campaign, rather than on the first tick or later.
--- @p string character string, Character string of character to teleport. This uses the standard character string lookup system.
--- @p number x, Logical x co-ordinate to teleport to.
--- @p number y, Logical y co-ordinate to teleport to.
--- @p [opt=false] boolean command queue, Order goes via command queue.
function campaign_manager:teleport_to(char_str, x, y, use_command_queue)
	if not is_string(char_str) then
		script_error("ERROR: teleport_to() called but supplied character lookup [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;
	
	if not is_number(x) or x <= 0 then
		script_error("ERROR: teleport_to() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(y) or y <= 0 then
		script_error("ERROR: teleport_to() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return false;
	end;
	
	use_command_queue = not not use_command_queue;
	
	out("Teleporting [" .. tostring(char_str) .. "] to [" .. x .. ", " .. y .. "]");	
	
	return self.game_interface:teleport_to(char_str, x, y, use_command_queue);
end;


--- @function enable_movement_for_character
--- @desc Enables movement for the supplied character. Characters are specified by lookup string. This wraps the @episodic_scripting:enable_movement_for_character function on the underlying episodic scripting interface, but adds validation and output.
--- @p string char lookup string
function campaign_manager:enable_movement_for_character(char_str)
	if not is_string(char_str) then
		script_error("ERROR: enable_movement_for_character() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;

	out("** enabling movement for character " .. char_str);
	
	self.game_interface:enable_movement_for_character(char_str);
end;


--- @function disable_movement_for_character
--- @desc Disables movement for the supplied character. Characters are specified by lookup string. This wraps the @episodic_scripting:disable_movement_for_character function on the underlying episodic scripting interface, but adds validation and output.
--- @p string char lookup string
function campaign_manager:disable_movement_for_character(char_str)
	if not is_string(char_str) then
		script_error("ERROR: disable_movement_for_character() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;
	
	out("** disabling movement for character " .. char_str);
	
	self.game_interface:disable_movement_for_character(char_str);
end;


--- @function enable_movement_for_faction
--- @desc Enables movement for the supplied faction. This wraps the @episodic_scripting:enable_movement_for_faction function on the underlying episodic scripting interface, but adds validation and output.
--- @p string faction key
function campaign_manager:enable_movement_for_faction(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: enable_movement_for_faction() called but supplied faction string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;

	out("** enabling movement for faction " .. faction_name);
	
	self.game_interface:enable_movement_for_faction(faction_name);
end;


--- @function disable_movement_for_faction
--- @desc Disables movement for the supplied faction. This wraps the @episodic_scripting:disable_movement_for_faction function on the underlying episodic scripting interface, but adds validation and output.
--- @p string faction key
function campaign_manager:disable_movement_for_faction(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: disable_movement_for_faction() called but supplied faction string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;

	out("** disabling movement for faction " .. faction_name);
	
	self.game_interface:disable_movement_for_faction(faction_name);
end;


--- @function force_add_trait
--- @desc Forceably adds an trait to a character. This wraps the @episodic_scripting:force_add_trait function on the underlying episodic scripting interface, but adds validation and output. This output will be shown in the <code>Lua - Traits</code> debug console spool.
--- @p string character string, Character string of the target character, using the standard character string lookup system.
--- @p string trait key, Trait key to add.
--- @p [opt=false] boolean show message, Show message.
--- @p [opt=1] number points, Trait points to add. The underlying <code>force_add_trait</code> function is called for each point added.
--- @p [opt=true] command_queue, if this command goes to the queue
function campaign_manager:force_add_trait(char_str, trait_str, show_msg, points, command_queue)
	if not is_string(char_str) then
		script_error("ERROR: force_add_trait() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;
	
	if not is_string(trait_str) then
		script_error("ERROR: force_add_trait() called but supplied trait string [" .. tostring(trait_str) .. "] is not a string");
		return false;
	end;
	
	show_msg = not not show_msg;
	points = points or 1;
	if command_queue == nil or command_queue == true then
		command_queue = true;
	elseif command_queue == false then
		--command_queue = false;
	else
		script_error("ERROR: force_add_trait() called but supplied command_queue is not nil nor boolean");
		return false;
	end
	
	out.traits("* force_add_trait() is adding trait [" .. tostring(trait_str) .. "] to character [" .. tostring(char_str) .. "], showing message: " .. tostring(show_msg) .. ", points: " .. tostring(points));
	
	self.game_interface:force_add_trait(char_str, trait_str, show_msg, points, command_queue);
end;


--- @function force_add_skill
--- @desc Forceably adds a skill to a character. This wraps the @episodic_scripting:force_add_skill function on the underlying episodic scripting interface, but adds validation and output. This output will be shown in the <code>Lua - Traits</code> debug console spool.
--- @p string character string, Character string of the target character, using the standard character string lookup system.
--- @p string skill key, Skill key to add.
function campaign_manager:force_add_skill(char_str, skill_str)
	if not is_string(char_str) then
		script_error("ERROR: force_add_skill() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return false;
	end;
	
	if not is_string(skill_str) then
		script_error("ERROR: force_add_skill() called but supplied skill string [" .. tostring(skill_str) .. "] is not a string");
		return false;
	end;

	out.traits("* force_add_skill() is adding skill [" .. tostring(skill_str) .. "] to character [" .. tostring(char_str) .. "]");
	self.game_interface:force_add_skill(char_str, skill_str);
end;


--- @function add_agent_experience
--- @desc Forceably adds experience to a character. This wraps the @episodic_scripting:add_agent_experience function on the underlying episodic scripting interface, but adds validation and output.
--- @p string character string, Character string of the target character, using the standard character string lookup system.
--- @p number experience, Experience to add.
--- @p [opt=false] boolean by_level, If set to true, the level/rank can be supplied instead of an exact amount of experience which is looked up from a table in the campaign manager
function campaign_manager:add_agent_experience(char_str, exp_to_give, by_level)
	if by_level then
		exp_to_give = self.character_xp_per_level[exp_to_give];
	end;
	
	out("add_agent_experience() called, char_str is " .. tostring(char_str) .. " and experience to give is " .. tostring(exp_to_give));
	return self.game_interface:add_agent_experience(char_str, exp_to_give);
end;



-- The amount of xp required for a character to attain each level
-- Ensure this matches the character_experience_skill_tiers table
campaign_manager.character_xp_per_level = {
	0,900,1900,3000,4200,5500,6890,8370,9940,11510,					-- 1 - 10
	13080,14660,16240,17820,19400,20990,22580,24170,25770,27370,	-- 11 - 20
	28980,30590,32210,33830,35460,37100,38740,40390,42050,43710,	-- 21 - 30
	45380,47060,48740,50430,52130,53830,55540,57260,58990,60730		-- 31 - 40
};












-----------------------------------------------------------------------------
--- @section Co-ordinates
-----------------------------------------------------------------------------


--- @function log_to_dis
--- @desc Converts a set of logical co-ordinates into display co-ordinates.
--- @p number x, Logical x co-ordinate.
--- @p number y, Logical y co-ordinate.
--- @return number Display x co-ordinate.
--- @return number Display y co-ordinate.
function campaign_manager:log_to_dis(x, y)
	if not is_number(x) or x < 0 then
		script_error("ERROR: log_to_dis() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: log_to_dis() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	local display_x = x * 678.5 / 1016;
	local display_y = y * 555.37 / 720;
	
	return display_x, display_y;
end;


--- @function distance_squared
--- @desc Returns the distance squared between two positions. The positions can be logical or display, as long as they are both in the same co-ordinate space. The squared distance is returned as it's faster to compare squared distances rather than taking the square-root.
--- @p number first x, x co-ordinate of the first position.
--- @p number first y, y co-ordinate of the first position.
--- @p number second x, x co-ordinate of the second position.
--- @p number second y, y co-ordinate of the second position.
--- @return number distance between positions squared.
function distance_squared(a_x, a_y, b_x, b_y)
	return (b_x - a_x) ^ 2 + (b_y - a_y) ^ 2;
end;










-----------------------------------------------------------------------------
--- @section Restricting Units, Buildings, and Technologies
--- @desc The game allows the script to place or lift restrictions on factions recruiting certain units, constructing certain buildings and researching certain technologies. Note that lifting a restriction with one of the following commands does not grant the faction access to that unit/building/technology, as standard requirements will still apply (e.g. building requirements to recruit a unit).
-----------------------------------------------------------------------------


--- @function restrict_units_for_faction
--- @desc Applies a restriction to or removes a restriction from a faction recruiting one or more unit types.
--- @p string faction name, Faction name.
--- @p table unit list, Numerically-indexed table of string unit keys.
--- @p [opt=true] boolean should restrict, Set this to <code>true</code> to apply the restriction, <code>false</code> to remove it.
function campaign_manager:restrict_units_for_faction(faction_name, unit_list, value)	
	if not is_string(faction_name) then
		script_error("ERROR: restrict_units_for_faction() called but supplied faction_name [" .. tostring(faction_name) .. "] is not a string");
		return;
	end;
	
	if not is_table(unit_list) then
		script_error("ERROR: restrict_units_for_faction() called but supplied unit_list [" .. tostring(unit_list) .. "] is not a table");
		return;
	end;
	
	local game_interface = self.game_interface;
	
	if value ~= false then
		value = true;
	end;
	
	if value then
		for i = 1, #unit_list do
			local current_rec = unit_list[i];
			game_interface:add_event_restricted_unit_record_for_faction(current_rec, faction_name);
		end;
		out("restricted " .. tostring(#unit_list) .. " unit records for faction " .. faction_name);
	else
		for i = 1, #unit_list do
			local current_rec = unit_list[i];
			game_interface:remove_event_restricted_unit_record_for_faction(current_rec, faction_name);
		end;
		out("unrestricted " .. tostring(#unit_list) .. " unit records for faction " .. faction_name);
	end;	
end;


--- @function restrict_buildings_for_faction
--- @desc Restricts or unrestricts a faction from constructing one or more building types. 
--- @p string faction name, Faction name.
--- @p table building list, Numerically-indexed table of string building keys.
--- @p [opt=true] boolean should restrict, Set this to <code>true</code> to apply the restriction, <code>false</code> to remove it.
function campaign_manager:restrict_buildings_for_faction(faction_name, building_list, value)
	if not is_string(faction_name) then
		script_error("ERROR: restrict_buildings_for_faction() called but supplied faction_name [" .. tostring(faction_name) .. "] is not a string");
		return;
	end;
	
	if not is_table(building_list) then
		script_error("ERROR: restrict_buildings_for_faction() called but supplied building_list [" .. tostring(building_list) .. "] is not a table");
		return;
	end;

	local game_interface = self.game_interface;
	
	if value ~= false then
		value = true;
	end;
	
	if value then
		for i = 1, #building_list do
			local current_rec = building_list[i];
		
			game_interface:add_event_restricted_building_record_for_faction(current_rec, faction_name);
		end;
		out("restricted " .. tostring(#building_list) .. " building records for faction " .. faction_name);
	else
		for i = 1, #building_list do
			local current_rec = building_list[i];
		
			game_interface:remove_event_restricted_building_record_for_faction(current_rec, faction_name);
		end;
		out("unrestricted " .. tostring(#building_list) .. " building records for faction " .. faction_name);
	end;
end;


--- @function restrict_technologies_for_faction
--- @desc Restricts or unrestricts a faction from researching one or more technologies. 
--- @p string faction name, Faction name.
--- @p table building list, Numerically-indexed table of string technology keys.
--- @p [opt=true] boolean should restrict, Set this to <code>true</code> to apply the restriction, <code>false</code> to remove it.
function campaign_manager:restrict_technologies_for_faction(faction_name, tech_list, value)
	if not is_string(faction_name) then
		script_error("ERROR: restrict_technologies_for_faction() called but supplied faction_name [" .. tostring(faction_name) .. "] is not a string");
		return;
	end;
	
	if not is_table(tech_list) then
		script_error("ERROR: restrict_technologies_for_faction() called but supplied tech_list [" .. tostring(tech_list) .. "] is not a table");
		return;
	end;
	
	local game_interface = self.game_interface;
	
	if value ~= false then
		value = true;
	end;
	
	if value then
		for i = 1, #tech_list do
			local current_rec = tech_list[i];
		
			game_interface:lock_technology(faction_name, current_rec);
		end;
		out("restricted " .. tostring(#tech_list) .. " tech records for faction " .. faction_name);
	else
		for i = 1, #tech_list do
			local current_rec = tech_list[i];
			
			game_interface:unlock_technology(faction_name, current_rec);
		end;
		out("unrestricted " .. tostring(#tech_list) .. " tech records for faction " .. faction_name);
	end;
end;











-----------------------------------------------------------------------------
--- @section Effect Bundles
--- @desc These this section contains functions that add and remove effect bundles from factions, military forces and regions. In each case they wrap a function of the same name on the underlying @episodic_scripting interface, providing input validation and debug output.
-----------------------------------------------------------------------------


--- @function apply_effect_bundle
--- @desc Applies an effect bundle to a faction for a number of turns (can be infinite).
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string faction key, Faction key of the faction to apply the effect to.
--- @p number turns, Number of turns to apply the effect bundle for. Supply 0 here to apply the effect bundle indefinitely (it can be removed later with @campaign_manager:remove_effect_bundle if required).
function campaign_manager:apply_effect_bundle(bundle_key, faction_name, turns)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_name) then
		script_error("ERROR: apply_effect_bundle() called but supplied faction key [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	-- Prevent underflow - We assume -1 being passed is intended to be infinite
	if turns < 0 then
		turns = 0;
	end
	
	out(" & Applying effect bundle [" .. bundle_key .. "] to faction [" .. faction_name .. "] for [" .. turns .. "] turns");
	
	return self.game_interface:apply_effect_bundle(bundle_key, faction_name, turns);
end;


--- @function remove_effect_bundle
--- @desc Removes an effect bundle from a faction.
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string faction key, Faction key of the faction to remove the effect from.
function campaign_manager:remove_effect_bundle(bundle_key, faction_name)
	if not is_string(bundle_key) then
		script_error("ERROR: remove_effect_bundle() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_name) then
		script_error("ERROR: remove_effect_bundle() called but supplied faction key [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	out(" & Removing effect bundle [" .. bundle_key .. "] from faction [" .. faction_name .. "]");
	
	return self.game_interface:remove_effect_bundle(bundle_key, faction_name);
end;


--- @function apply_effect_bundle_to_force
--- @desc Applies an effect bundle to a military force by cqi for a number of turns (can be infinite).
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string number cqi, Command queue index of the military force to apply the effect bundle to.
--- @p number turns, Number of turns to apply the effect bundle for. Supply 0 here to apply the effect bundle indefinitely (it can be removed later with @campaign_manager:remove_effect_bundle_from_force if required).
function campaign_manager:apply_effect_bundle_to_force(bundle_key, mf_cqi, turns)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle_to_force() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(mf_cqi) then
		script_error("ERROR: apply_effect_bundle_to_force() called but supplied mf cqi [" .. tostring(mf_cqi) .. "] is not a number");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle_to_force() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	-- Prevent underflow - We assume -1 being passed is intended to be infinite
	if turns < 0 then
		turns = 0;
	end
	
	out(" & Applying effect bundle [" .. bundle_key .. "] to military force with cqi [" .. mf_cqi .. "] for [" .. turns .. "] turns");
	
	return self.game_interface:apply_effect_bundle_to_force(bundle_key, mf_cqi, turns);
end;


--- @function remove_effect_bundle_from_force
--- @desc Removes an effect bundle from a military force by cqi.
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string number cqi, Command queue index of the military force to remove the effect from.
function campaign_manager:remove_effect_bundle_from_force(bundle_key, mf_cqi)
	if not is_string(bundle_key) then
		script_error("ERROR: remove_effect_bundle_from_force() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(mf_cqi) then
		script_error("ERROR: remove_effect_bundle_from_force() called but supplied mf cqi [" .. tostring(mf_cqi) .. "] is not a number");
		return false;
	end;
	
	out(" & Removing effect bundle [" .. bundle_key .. "] from military force with cqi [" .. mf_cqi .. "]");
	
	return self.game_interface:remove_effect_bundle_from_force(bundle_key, mf_cqi);
end;


--- @function apply_effect_bundle_to_characters_force
--- @desc This function applies an effect bundle to a military force for a number of turns (can be infinite). It differs from @campaign_manager:apply_effect_bundle_to_force by referring to the force by its commanding character's cqi.
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string number cqi, Command queue index of the military force's commanding character to apply the effect bundle to.
--- @p number turns, Number of turns to apply the effect bundle for. Supply 0 here to apply the effect bundle indefinitely (it can be removed later with @campaign_manager:remove_effect_bundle_from_characters_force if required).
function campaign_manager:apply_effect_bundle_to_characters_force(bundle_key, char_cqi, turns, command_queue)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle_to_characters_force() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(char_cqi) then
		script_error("ERROR: apply_effect_bundle_to_characters_force() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle_to_characters_force() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	-- Prevent underflow - We assume -1 being passed is intended to be infinite
	if turns < 0 then
		turns = 0;
	end
	
	command_queue = not not command_queue;
	
	out("& Applying effect bundle [" .. bundle_key .. "] to the force of character with cqi [" .. char_cqi .. "] for [" .. turns .. "] turns");
	
	return self.game_interface:apply_effect_bundle_to_characters_force(bundle_key, char_cqi, turns, command_queue);
end;


--- @function remove_effect_bundle_from_characters_force
--- @desc Removes an effect bundle from a military force by its commanding character's cqi.
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string number cqi, Command queue index of the character commander of the military force to remove the effect from.
function campaign_manager:remove_effect_bundle_from_characters_force(bundle_key, char_cqi)
	if not is_string(bundle_key) then
		script_error("ERROR: remove_effect_bundle_from_characters_force() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(char_cqi) then
		script_error("ERROR: remove_effect_bundle_from_characters_force() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
		
	out(" & Removing effect bundle [" .. bundle_key .. "] from the force of character with cqi [" .. char_cqi .. "]");
	
	return self.game_interface:remove_effect_bundle_from_characters_force(bundle_key, char_cqi);
end;


--- @function apply_effect_bundle_to_region
--- @desc Applies an effect bundle to a region for a number of turns (can be infinite).
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string region key, Key of the region to add the effect bundle to.
--- @p number turns, Number of turns to apply the effect bundle for. Supply 0 here to apply the effect bundle indefinitely (it can be removed later with @campaign_manager:remove_effect_bundle_from_region if required).
function campaign_manager:apply_effect_bundle_to_region(bundle_key, region_key, turns)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	-- Prevent underflow - We assume -1 being passed is intended to be infinite
	if turns < 0 then
		turns = 0;
	end
	
	out(" & Applying effect bundle [" .. bundle_key .. "] to region with key [" .. region_key .. "] for [" .. turns .. "] turns");
	
	return self.game_interface:apply_effect_bundle_to_region(bundle_key, region_key, turns);
end;


--- @function remove_effect_bundle_from_region
--- @desc Removes an effect bundle from a region.
--- @p string effect bundle key, Effect bundle key from the effect bundles table.
--- @p string number cqi, Command queue index of the character commander of the military force to remove the effect from.
function campaign_manager:remove_effect_bundle_from_region(bundle_key, region_key)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	out(" & Removing effect bundle [" .. bundle_key .. "] from region with key [" .. region_key .. "]");
	
	return self.game_interface:remove_effect_bundle_from_region(bundle_key, region_key);
end;









-----------------------------------------------------------------------------
--- @section Shroud Manipulation
-----------------------------------------------------------------------------


--- @function lift_all_shroud
--- @desc Lifts the shroud on all regions. This may be useful for cutscenes in general and benchmarks in-particular.
function campaign_manager:lift_all_shroud()
	local region_list = self:model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local curr_region = region_list:item_at(i);
		
		self.game_interface:make_region_visible_in_shroud(local_faction, curr_region:name());
	end;
end;










-----------------------------------------------------------------------------
--- @section Diplomacy
--- @desc The @campaign_manager:force_diplomacy function can be used to restrict or unrestrict diplomacy between factions. The following types of diplomacy are available to restrict - not all of them may be supported by each project:
-----------------------------------------------------------------------------


-- campaign diplomacy types
campaign_manager.diplomacy_types = {
	["trade agreement"] = 2^0,						--- @desc <ul><li>"trade agreement"</li>
	["hard military access"] = 2^1,					--- @desc <li>"hard military access"</li>
	["cancel hard military access"] = 2^2,			--- @desc <li>"cancel hard military access"</li>
	["military alliance"] = 2^3,					--- @desc <li>"military alliance"</li>
	["regions"] = 2^4,								--- @desc <li>"regions"</li>
	["technology"] = 2^5,							--- @desc <li>"technology"</li>
	["state gift"] = 2^6,							--- @desc <li>"state gift"</li>
	["payments"] = 2^7,								--- @desc <li>"payments"</li>
	["vassal"] = 2^8,								--- @desc <li>"vassal"</li>
	["peace"] = 2^9,								--- @desc <li>"peace"</li>
	["war"] = 2^10,									--- @desc <li>"war"</li>
	["join war"] = 2^11,							--- @desc <li>"join war"</li>
	["break trade"] = 2^12,							--- @desc <li>"break trade"</li>
	["break alliance"] = 2^13,						--- @desc <li>"break alliance"</li>
	["hostages"] = 2^14,							--- @desc <li>"hostages"</li>
	["marriage"] = 2^15,							--- @desc <li>"marriage"</li>
	["non aggression pact"] = 2^16,					--- @desc <li>"non aggression pact"</li>
	["soft military access"] = 2^17,				--- @desc <li>"soft military access"</li>
	["cancel soft military access"] = 2^18,			--- @desc <li>"cancel soft military access"</li>
	["defensive alliance"] = 2^19,					--- @desc <li>"defensive alliance"</li>
	["client state"] = 2^20,						--- @desc <li>"client state"</li>
	["form confederation"] = 2^21,					--- @desc <li>"form confederation"</li>
	["break non aggression pact"] = 2^22,			--- @desc <li>"break non aggression pact"</li>
	["break soft military access"] = 2^23,			--- @desc <li>"break soft military access"</li>
	["break defensive alliance"] = 2^24,			--- @desc <li>"break defensive alliance"</li>
	["break vassal"] = 2^25,						--- @desc <li>"break vassal"</li>
	["break client state"] = 2^26,					--- @desc <li>"break client state"</li>
	["state gift unilateral"] = 2^27--[[,			--- @desc <li>"state gift unilateral"</li>
	["all"] = (2^28 - 1)							--- @desc <li>"all"</li></ul>
]]
};


--- @function force_diplomacy
--- @desc Restricts or unrestricts certain types of diplomacy between factions or groups of factions. Groups of factions may be specified with the strings <code>"all"</code>, <code>"faction:faction_key"</code>, <code>"subculture:subculture_key"</code> or <code>"culture:culture_key"</code>. A source and target faction/group of factions must be specified.
--- @desc Note that this wraps the function @episodic_scripting:force_diplomacy_new on the underlying episodic scripting interface.
--- @p string source, Source faction/factions identifier.
--- @p string target, Target faction/factions identifier.
--- @p string type, Type of diplomacy to restrict. See the documentation for the @campaign_manager:Diplomacy section for available diplomacy types.
--- @p boolean can offer, Can offer - set to <code>false</code> to prevent the source faction(s) from being able to offer this diplomacy type to the target faction(s).
--- @p boolean can accept, Can accept - set to <code>false</code> to prevent the target faction(s) from being able to accept this diplomacy type from the source faction(s).
--- @p [opt=false] both directions, Causes this function to apply the same restriction from target to source as from source to target.
--- @p [opt=false] do not enable payments, The AI code assumes that the "payments" diplomatic option is always available, and by default this function keeps payments available, even if told to restrict it. Set this flag to <code>true</code> to forceably restrict payments, but this may cause crashes.
function campaign_manager:force_diplomacy(source, target, diplomacy_types, offer, accept, add_both_directions, do_not_enable_payments)
	add_both_directions = not not add_both_directions;
	do_not_enable_payments = not not do_not_enable_payments;
	
	-- workaround - lua's default number type doesn't have the precision to support the bitmask required for "all"
	if diplomacy_types == "all" then
		out.design("force_diplomacy_new() called, source: " .. tostring(source) .. ", target: " .. tostring(target) .. ", diplomacy_types: " .. tostring(diplomacy_types) .. ", offer: " .. tostring(offer) .. ", accept: " .. tostring(accept) .. ", add both directions: " .. tostring(add_both_directions) .. ", do not enable payments: " .. tostring(do_not_enable_payments));
		for diplomacy_type, bitmask in pairs(campaign_manager.diplomacy_types) do
			self.game_interface:force_diplomacy_new(source, target, bitmask, offer, accept);
			if add_both_directions then
				self.game_interface:force_diplomacy_new(target, source, bitmask, offer, accept);
			end;
		end;
		return;
	end;
	
	local bitmask = self:generated_diplomacy_bitmask(diplomacy_types);
	
	out.design("force_diplomacy_new() called, source: " .. tostring(source) .. ", target: " .. tostring(target) .. ", diplomacy_types: " .. tostring(diplomacy_types) .. " (generating bitmask: " .. bitmask .. "), offer: " .. tostring(offer) .. ", accept: " .. tostring(accept) .. ", add both directions: " .. tostring(add_both_directions) .. ", do not enable payments: " .. tostring(do_not_enable_payments));

	self.game_interface:force_diplomacy_new(source, target, bitmask, offer, accept);
	
	if add_both_directions then
		self.game_interface:force_diplomacy_new(target, source, bitmask, offer, accept);
	end;
	
	-- the ai assumes that 'payments' will always be available, so if we are enabling a diplomatic relationship then always enable payments as well	
	if offer and not do_not_enable_payments then
		self.game_interface:force_diplomacy_new(source, target, self:generated_diplomacy_bitmask("payments"), true, false);
	end;
end;


function campaign_manager:generated_diplomacy_bitmask(str)
	if not is_string(str) then
		script_error("ERROR: generate_diplomacy_bitmask() called but supplied diplomacy string [" .. tostring(str) .. "] is not a string");
		return 0;
	end;
	
	if string.len(str) == 0 then
		return 0;
	end;
	
	-- specifically allow a token of "all"
	if str == "all" then
		return self.diplomacy_types["all"];
	end;
	
	local tokens = {};
	
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, ",", pointer);
		
		if not next_separator then
			-- this is the last token, so exit the loop after storing it
			table.insert(tokens, string.sub(str, pointer));
			break;
		end;
		
		table.insert(tokens, string.sub(str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
	
	local bitmask = 0;
	
	for i = 1, #tokens do
		local current_token = tokens[i];
		
		if current_token == "all" then
			-- combining "all" with other token types is not allowed
			script_error("WARNING: generate_diplomacy_bitmask() was given a string [" .. str .. "] containing token [" .. current_token .. "] with other tokens - this token can only be used on its own, ignoring");
		else		
			local current_token_value = self.diplomacy_types[current_token];		
			if not current_token_value then
				script_error("WARNING: generate_diplomacy_bitmask() was given a string [" .. str .. "] containing unrecognised token [" .. current_token .. "], ignoring");
			else
				bitmask = bitmask + current_token_value;
			end;
		end;
	end;
	
	return bitmask;
end;


--- @function enable_all_diplomacy
--- @desc Enables or disables all diplomatic options between all factions.
--- @p boolean enable diplomacy
function campaign_manager:enable_all_diplomacy(value)
	
	self:force_diplomacy("all", "all", "all", value, value);
	
	-- apply default diplomatic records afterwards if required
	if value then
		core:trigger_event("ScriptEventAllDiplomacyEnabled");
	end;
end;


--- @function force_declare_war
--- @desc Forces war between two factions. This wraps the @episodic_scripting:force_declare_war function of the same name on the underlying episodic scripting interface, but adds validation and output. This output will be shown in the <code>Lua - Design</code> console spool.
--- @p string faction key, Faction A key
--- @p string faction key, Faction B key
--- @p boolean invite faction a allies, Invite faction A's allies to the war
--- @p boolean invite faction b allies, Invite faction B's allies to the war
--- @p boolean command queue or not
function campaign_manager:force_declare_war(faction_a_name, faction_b_name, invite_faction_a_allies, invite_faction_b_allies, command_queue)
	if not is_string(faction_a_name) then
		script_error("ERROR: force_declare_war() called but supplied faction_a_name string [" .. tostring(faction_a_name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_b_name) then
		script_error("ERROR: force_declare_war() called but supplied faction_b_name string [" .. tostring(faction_b_name) .. "] is not a string");
		return false;
	end;
	
	if not is_boolean(invite_faction_a_allies) then
		script_error("ERROR: force_declare_war() called but supplied invite_faction_a_allies flag [" .. tostring(invite_faction_a_allies) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_boolean(invite_faction_b_allies) then
		script_error("ERROR: force_declare_war() called but supplied invite_faction_b_allies flag [" .. tostring(invite_faction_b_allies) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_boolean(command_queue) and command_queue ~= nil then
		script_error("ERROR: force_declare_war() called but supplied command_queue flag [" .. tostring(command_queue) .. "] is not a boolean value");
		return false;
	end;
	
	local faction_a = cm:get_faction(faction_a_name);
	local faction_b = cm:get_faction(faction_b_name);
	
	if not faction_a then
		script_error("ERROR: force_declare_war() called but supplied faction_a_name string [" .. tostring(faction_a_name) .. "] could not be used to find a valid faction");
		return false;
	end;
	
	if not faction_b then
		script_error("ERROR: force_declare_war() called but supplied faction_b_name string [" .. tostring(faction_b_name) .. "] could not be used to find a valid faction");
		return false;
	end;
	
	out.design("* force_declare_war() called");
	out.design("\tforcing war between:");
	
	if faction_a:is_human() then
		out.design("\t\t[" .. tostring(faction_a_name) .. "] (human)");
	else
		out.design("\t\t[" .. tostring(faction_a_name) .. "] (ai)");
	end;
	
	if faction_b:is_human() then
		out.design("\t\t[" .. tostring(faction_b_name) .. "] (human)");
	else
		out.design("\t\t[" .. tostring(faction_b_name) .. "] (ai)");
	end;
	
	if invite_faction_a_allies then
		out.design("\tinviting [" .. tostring(faction_a_name) .. "] allies");
	end;
	
	if invite_faction_b_allies then
		out.design("\tinviting [" .. tostring(faction_b_name) .. "] allies");
	end;
	
	if command_queue == nil or command_queue == true then
		self.game_interface:force_declare_war(faction_a_name, faction_b_name, invite_faction_a_allies, invite_faction_b_allies);
	else
		self.game_interface:force_declare_war(faction_a_name, faction_b_name, invite_faction_a_allies, invite_faction_b_allies, false);
	end
end;



----------------------------------------------------------------------------
-- get diplomacy panel context
----------------------------------------------------------------------------

-- list of all diplomatic options, which the diplomacy panel displays
-- option is the name of the uicomponent
-- result is a string signifying its meaning to the interventions listening to it
-- priority is the priority of the meaning (so the context of a compound offer like an alliance with a payment is always of the more-significant component)
campaign_manager.diplomatic_options = {
	{["option"] = "diplomatic_option_trade_agreement", 				["result"] = "trade",						["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_trade_agreement", 		["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_hard_access", 					["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_hard_access", 			["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_military_alliance", 			["result"] = "alliance",					["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_military_alliance",		["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_trade_regions",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_trade_technology",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_state_gift",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_payment",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_vassal",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_vassal",				["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_peace",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "war_declared",									["result"] = "war",							["priority"] = 2},
	{["option"] = "diplomatic_option_join_war",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_trade_agreement",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_military_alliance",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_hostage",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_mariiage",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_nonaggression_pact",			["result"] = "nap",							["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_nonaggression_pact",	["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_soft_access",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_soft_access",			["result"] = "noninteractive",				["priority"] = 1},	
	{["option"] = "diplomatic_option_defensive_alliance",			["result"] = "alliance",					["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_defensive_alliance",	["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_client_state",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_client_state",			["result"] = "noninteractive",				["priority"] = 1},	
	{["option"] = "diplomatic_option_confederation",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_nonaggression_pact",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_soft_access",			["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_defensive_alliance",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_vassal",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_client_state",			["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_state_gift_unilateral",		["result"] = "interactive",					["priority"] = 1}
};



function campaign_manager:start_diplomacy_panel_context_listener()
	if self.diplomacy_panel_context_listener_started then
		return false;
	end;
	
	self.diplomacy_panel_context_listener_started = true;

	self:callback(function() self:poll_diplomacy_panel_context() end, 0.2);
end;


function campaign_manager:poll_diplomacy_panel_context()
	local diplomacy_panel_context = self:get_diplomacy_panel_context();
	
	if diplomacy_panel_context ~= "" then
		self.diplomacy_panel_context_listener_started = false;
		core:trigger_event("ScriptEventDiplomacyPanelContext", diplomacy_panel_context);
	else
		self:callback(function() self:poll_diplomacy_panel_context() end, 0.2);
	end;
end;




function campaign_manager:get_diplomacy_panel_context()
	local uic_diplomacy = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown");
	
	local diplomatic_options = self.diplomatic_options;
	local result = "";
	local result_priority = 0;	
	
	-- If we couldn't find the panel or it doesn't seem to be open then return a state so that the polling completes.
	-- Not really sure how this happens but it does.
	if not uic_diplomacy or not self:get_campaign_ui_manager():is_panel_open("diplomacy_dropdown") then
		return "invalid";
	end;
	
	for i = 1, #diplomatic_options do
		local current_option = diplomatic_options[i].option;
		
		local uic_option = find_uicomponent(uic_diplomacy, current_option);
		
		if uic_option and uic_option:Visible() then
			if diplomatic_options[i].priority > result_priority then
				result_priority = diplomatic_options[i].priority;
				result = diplomatic_options[i].result;
				
				-- return immediately if the result is important enough
				if result_priority == 2 then
					break;
				end;
			end;
		end;
	end;
		
	return result;
end;


































-----------------------------------------------------------------------------
--- @section Objectives and Infotext
--- @desc Upon creation, the campaign manager automatically creates objectives manager and infotext manager objects which it stores internally. These functions provide a passthrough interface to the most commonly-used functions on these objects. See the documentation on the @objectives_manager and @infotext_manager pages for more details.
-----------------------------------------------------------------------------


--- @function set_objective
--- @desc Pass-through function for @objectives_manager:set_objective on the objectives manager. Sets up a scripted objective for the player, which appears in the scripted objectives panel. This objective can then be updated, removed, or marked as completed or failed by the script at a later time.
--- @desc A key to the scripted_objectives table must be supplied with set_objective, and optionally one or two numeric parameters to show some running count related to the objective. To update these parameter values later, <code>set_objective</code> may be re-called with the same objective key and updated values.
--- @p string objective key, Objective key, from the scripted_objectives table.
--- @p [opt=nil] number param a, First numeric objective parameter. If set, the objective will be presented to the player in the form [objective text]: [param a]. Useful for showing a running count of something related to the objective.
--- @p [opt=nil] number param b, Second numeric objective parameter. A value for the first must be set if this is used. If set, the objective will be presented to the player in the form [objective text]: [param a] / [param b]. Useful for showing a running count of something related to the objective.
function campaign_manager:set_objective(...)
	return self.objectives:set_objective(...);
end;


--- @function complete_objective
--- @desc Pass-through function for @objectives_manager:complete_objective on the objectives manager. Marks a scripted objective as completed for the player to see. Note that it will remain on the scripted objectives panel until removed with @campaign_manager:remove_objective.
--- @desc Note also that is possible to mark an objective as complete before it has been registered with @campaign_manager:set_objective - in this case, it is marked as complete as soon as @campaign_manager:set_objective is called.
--- @p string objective key, Objective key, from the scripted_objectives table.
function campaign_manager:complete_objective(...)
	return self.objectives:complete_objective(...);
end;


--- @function fail_objective
--- @desc Pass-through function for @objectives_manager:fail_objective on the objectives manager. Marks a scripted objective as failed for the player to see. Note that it will remain on the scripted objectives panel until removed with @campaign_manager:remove_objective.
--- @p string objective key, Objective key, from the scripted_objectives table.
function campaign_manager:fail_objective(...)
	return self.objectives:fail_objective(...);
end;


--- @function remove_objective
--- @desc Pass-through function for @objectives_manager:remove_objective on the objectives manager. Removes a scripted objective from the scripted objectives panel.
--- @p string objective key, Objective key, from the scripted_objectives table.
function campaign_manager:remove_objective(...)
	return self.objectives:remove_objective(...);
end;


--- @function activate_objective_chain
--- @desc Pass-through function for @objectives_manager:activate_objective_chain. Starts a new objective chain - see the documentation on the @objectives_manager page for more details.
--- @p string chain name, Objective chain name.
--- @p string objective key, Key of initial objective, from the scripted_objectives table.
--- @p [opt=nil] number number param a, First numeric parameter - see the documentation for @campaign_manager:set_objective for more details
--- @p [opt=nil] number number param b, Second numeric parameter - see the documentation for @campaign_manager:set_objective for more details
function campaign_manager:activate_objective_chain(...)
	return self.objectives:activate_objective_chain(...);
end;


--- @function update_objective_chain
--- @desc Pass-through function for @objectives_manager:update_objective_chain. Updates an existing objective chain - see the documentation on the @objectives_manager page for more details.
--- @p string chain name, Objective chain name.
--- @p string objective key, Key of initial objective, from the scripted_objectives table.
--- @p [opt=nil] number number param a, First numeric parameter - see the documentation for @campaign_manager:set_objective for more details
--- @p [opt=nil] number number param b, Second numeric parameter - see the documentation for @campaign_manager:set_objective for more details
function campaign_manager:update_objective_chain(...)
	return self.objectives:update_objective_chain(...);
end;


--- @function end_objective_chain
--- @desc Pass-through function for @objectives_manager:end_objective_chain. Ends an existing objective chain - see the documentation on the @objectives_manager page for more details.
--- @p string chain name, Objective chain name.
function campaign_manager:end_objective_chain(...)
	return self.objectives:end_objective_chain(...);
end;


--- @function reset_objective_chain
--- @desc Pass-through function for @objectives_manager:reset_objective_chain. Resets an objective chain so that it may be called again - see the documentation on the @objectives_manager page for more details.
--- @p string chain name, Objective chain name.
function campaign_manager:reset_objective_chain(...)
	return self.objectives:reset_objective_chain(...);
end;


--- @function add_infotext
--- @desc Pass-through function for @infotext_manager:add_infotext. Adds one or more lines of infotext to the infotext panel - see the documentation on the @infotext_manager page for more details.
--- @p object first param, Can be a string key from the advice_info_texts table, or a number specifying an initial delay in ms after the panel animates onscreen and the first infotext item is shown.
--- @p ... additional infotext strings, Additional infotext strings to be shown. <code>add_infotext</code> fades each of them on to the infotext panel in a visually-pleasing sequence.
function campaign_manager:remove_infotext(...)
	return self.infotext:remove_infotext(...);
end;


--- @function remove_infotext
--- @desc Pass-through function for @infotext_manager:remove_infotext. Removes a line of infotext from the infotext panel.
--- @p string infotext key
function campaign_manager:clear_infotext(...)
	return self.infotext:clear_infotext(...);
end;


--- @function clear_infotext
--- @desc Pass-through function for @infotext_manager:clear_infotext. Clears the infotext panel.
function campaign_manager:add_infotext(...)
	return self.infotext:add_infotext(...);
end;










-----------------------------------------------------------------------------
--- @section Missions and Events
-----------------------------------------------------------------------------


--- @function trigger_custom_mission
--- @desc Triggers a specific custom mission from its database record key. This mission must be defined in the missions.txt file that accompanies each campaign. This function wraps the @episodic_scripting:trigger_custom_mission function on the game interface, adding debug output and event type whitelisting.
--- @p string faction key, Faction key.
--- @p string mission key, Mission key, from missions.txt file.
--- @p [opt=false] @boolean use command queue, Trigger the mission via the command queue or not.
--- @p [opt=false] boolean do not cancel, By default this function cancels this custom mission before issuing it, to avoid multiple copies of the mission existing at once. Supply <code>true</code> here to prevent this behaviour.
--- @p [opt=false] boolean whitelist, Supply <code>true</code> here to also whitelist the mission event type, so that it displays even if event feed restrictions are in place (see @campaign_manager:suppress_all_event_feed_messages and @campaign_manager:whitelist_event_feed_event_type).
function campaign_manager:trigger_custom_mission(faction, mission, use_command_queue, do_not_cancel, whitelist)
	if not is_string(faction) then
		script_error("ERROR: trigger_custom_mission() called but supplied faction name [" .. tostring(faction) .. "] is not a string");
		return false;
	end;

	if not do_not_cancel then
		self.game_interface:cancel_custom_mission(faction, mission);
	end;
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	out("++ triggering mission " .. tostring(mission) .. " for faction " .. tostring(faction));
	
	if use_command_queue then
		self.game_interface:trigger_custom_mission(faction, mission, true);
	else
		self.game_interface:trigger_custom_mission(faction, mission, false);
	end;
end;


--- @function trigger_custom_mission_from_string
--- @desc Triggers a custom mission from a string passed into the function. The mission string must be supplied in a custom format - see the missions.txt that commonly accompanies a campaign for examples. Alternatively, use a @mission_manager which is able to construct such strings internally.
--- @desc This wraps the @episodic_scripting:trigger_custom_mission_from_string function on the underlying episodic scripting interface, adding output and the optional whitelisting functionality.
--- @p string faction key
--- @p string mission, Mission definition string.
--- @p [opt=false] @boolean use command queue, Trigger the mission via the command queue or not.
--- @p [opt=false] boolean whitelist, Supply <code>true</code> here to also whitelist the mission event type, so that it displays even if event feed restrictions are in place (see @campaign_manager:suppress_all_event_feed_messages and @campaign_manager:whitelist_event_feed_event_type).
function campaign_manager:trigger_custom_mission_from_string(faction_name, mission_string, use_command_queue, whitelist)
	out("++ triggering mission from string for faction " .. tostring(faction_name) .. " mission string is " .. tostring(mission_string));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	if use_command_queue then
		self.game_interface:trigger_custom_mission_from_string(faction_name, mission_string, true);
	else
		self.game_interface:trigger_custom_mission_from_string(faction_name, mission_string, false);
	end;
end;


--- @function trigger_mission
--- @desc Instructs the campaign director to attempt to trigger a mission of a particular type, based on a mission record from the database. The mission will be triggered if its conditions, defined in the <code>cdir_events_mission_option_junctions</code>, pass successfully. The function returns whether the mission was successfully triggered or not. Note that if the command is sent via the command queue then <code>true</code> will always be returned, regardless of whether the mission successfully triggers.
--- @desc This function wraps the @episodic_scripting:trigger_mission function on the game interface, adding debug output and event type whitelisting.
--- @p string faction key, Faction key.
--- @p string mission key, Mission key, from the missions table.
--- @p [opt=false] @boolean fire immediately, Fire immediately - if this is set, then any turn delay for the mission set in the <code>cdir_event_mission_option_junctions</code> table will be disregarded.
--- @p [opt=false] @boolean use command queue, Trigger the mission via the command queue or not.
--- @p [opt=false] boolean whitelist, Supply <code>true</code> here to also whitelist the mission event type, so that it displays even if event feed restrictions are in place (see @campaign_manager:suppress_all_event_feed_messages and @campaign_manager:whitelist_event_feed_event_type).
--- @return @boolean mission triggered successfully
function campaign_manager:trigger_mission(faction, mission, fire_immediately, use_command_queue, whitelist)
	fire_immediately = not not fire_immediately;

	out("++ triggering mission from db " .. tostring(mission) .. " for faction " .. tostring(faction) .. ", fire_immediately: " .. tostring(fire_immediately));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	if use_command_queue then
		return self.game_interface:trigger_mission(faction, mission, fire_immediately, true);
	else
		return self.game_interface:trigger_mission(faction, mission, fire_immediately, false);
	end;
end;


--- @function trigger_dilemma
--- @desc Triggers dilemma with a specified key, based on a record from the database, preferentially wrapped in an intervention. The delivery of the dilemma will be wrapped in an intervention in singleplayer mode, whereas in multiplayer mode the dilemma is triggered directly. It is preferred to use this function to trigger a dilemma, unless the calling script is running from within an intervention in which case @campaign_manager:trigger_dilemma_raw should be used.
--- @p @string faction key, Faction key, from the <code>factions</code> table.
--- @p @string dilemma key, Dilemma key, from the <code>dilemmas</code> table.
--- @p [opt=nil] @function trigger callback, Callback to call when the intervention actually gets triggered.
--- @return @boolean Dilemma triggered successfully. <code>true</code> is always returned if an intervention is generated.
function campaign_manager:trigger_dilemma(faction_key, dilemma_key, on_trigger_callback)

	if not is_string(faction_key) then
		script_error("ERROR: trigger_dilemma() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;

	if not is_string(dilemma_key) then
		script_error("ERROR: trigger_dilemma() called but supplied dilemma key [" .. tostring(dilemma_key) .. "] is not a string");
		return false;
	end;

	if on_trigger_callback and not is_function(on_trigger_callback) then
		script_error("ERROR: trigger_dilemma() called but supplied trigger callback [" .. tostring(on_trigger_callback) .. "] is not a function");
		return false;
	end;

	-- trigger the dilemma immediately in mp
	if self:is_multiplayer() then
		return self:trigger_dilemma_raw(faction_key, dilemma_key, true, true);
	end;

	local process_name = "dilemma_" .. faction_key .. "_" .. dilemma_key;

	-- in singleplayer, wrap the delivery of the dilemma in an intervention
	self:trigger_transient_intervention(
		"dilemma_" .. faction_key .. "_" .. dilemma_key,
		function(intervention)
			local process_name = "dilemma_" .. faction_key .. "_" .. dilemma_key .. "_listeners";

			-- start a one second countdown - if no dilemma has appeared in this time assume that something has gone wrong, error and abort
			self:callback(
				function()
					script_error("WARNING: trigger_dilemma() called but no dilemma was issued, is there a problem with the data? Faction key is [" .. faction_key .. "] and dilemma key is [" .. dilemma_key .. "]. Completing the associated intervention, but no dilemma was triggered.");
					core:remove_listener(process_name);
					intervention:complete();
					return;
				end,
				1,
				process_name
			);

			-- listen for the dilemma being issued
			core:add_listener(
				process_name,
				"DilemmaIssuedEvent",
				function(context) return context:dilemma() == dilemma_key end,
				function()
					cm:remove_callback(process_name);

					-- dilemma has been issued, complete intervention
					intervention:complete();
				end,
				false
			);

			-- call the on-trigger callback
			if on_trigger_callback then
				on_trigger_callback();
			end;

			-- trigger the actual dilemma
			self:trigger_dilemma_raw(faction_key, dilemma_key, true, true);
		end,
		true,
		function(intervention)
			-- Configure intervention here

			-- This intervention will trigger regardless of advice level and whether advice is disabled
			intervention:set_allow_when_advice_disabled(true);
			intervention:set_min_advice_level(0);
		end
	);

	return true;
end;


--- @function trigger_dilemma_raw
--- @desc Compels the campaign director to trigger a dilemma of a particular type, based on a record from the database. This function is a raw wrapper for the @episodic_scripting:trigger_dilemma function on the game interface, adding debug output and event type whitelisting, but not featuring the intervention-wrapping behaviour of @campaign_manager:trigger_dilemma. Use this function if triggering the dilemma from within an intervention, but @campaign_manager:trigger_dilemma for all other instances.
--- @p @string faction key, Faction key, from the <code>factions</code> table.
--- @p @string dilemma key, Dilemma key, from the <code>dilemmas</code> table.
--- @p [opt=false] @boolean fire immediately, Fire immediately. If set, the dilemma will fire immediately, otherwise the dilemma will obey any wait period set in the <code>cdir_events_dilemma_options</code> table.
--- @p [opt=false] @boolean whitelist, Supply <code>true</code> here to also whitelist the dilemma event type, so that it displays even if event feed restrictions are in place (see @campaign_manager:suppress_all_event_feed_messages and @campaign_manager:whitelist_event_feed_event_type).
--- @return @boolean Dilemma triggered successfully.
function campaign_manager:trigger_dilemma_raw(faction_key, dilemma_key, fire_immediately, whitelist)

	if not is_string(faction_key) then
		script_error("ERROR: trigger_dilemma_raw() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;

	if not is_string(dilemma_key) then
		script_error("ERROR: trigger_dilemma_raw() called but supplied dilemma key [" .. tostring(dilemma_key) .. "] is not a string");
		return false;
	end;

	fire_immediately = not not fire_immediately;

	out("++ triggering dilemma from db " .. tostring(dilemma_key) .. " for faction " .. tostring(faction_key) .. ", fire_immediately: " .. tostring(fire_immediately));
	
	if whitelist then
		self:whitelist_event_feed_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
	end;
	
	return self.game_interface:trigger_dilemma(faction_key, dilemma_key, fire_immediately);
end;


--- @function trigger_dilemma_with_targets
--- @desc Triggers a dilemma with a specified key and one or more target game objects, preferentially wrapped in an intervention. The delivery of the dilemma will be wrapped in an intervention in singleplayer mode, whereas in multiplayer mode the dilemma is triggered directly. It is preferred to use this function to trigger a dilemma with targets, unless the calling script is running from within an intervention in which case @campaign_manager:trigger_dilemma_with_targets_raw should be used.
--- @desc The game object or objects to associate the dilemma with are specified by command-queue index. The dilemma will need to pass any conditions set up in the <code>cdir_events_dilemma_option_junctions</code> table in order to trigger.
--- @p @number faction cqi, Command-queue index of the faction to which the dilemma is issued. This must be supplied.
--- @p @string dilemma key, Dilemma key, from the <code>dilemmas</code> table.
--- @p [opt=0] @number target faction cqi, Command-queue index of a target faction.
--- @p [opt=0] @number secondary faction cqi, Command-queue index of a second target faction.
--- @p [opt=0] @number character cqi, Command-queue index of a target character.
--- @p [opt=0] @number military force cqi, Command-queue index of a target military force.
--- @p [opt=0] @number region cqi, Command-queue index of a target region.
--- @p [opt=0] @number settlement cqi, Command-queue index of a target settlement.
--- @p @function trigger callback, Callback to call when the intervention actually gets triggered.
--- @return @boolean Dilemma triggered successfully. <code>true</code> is always returned if an intervention is generated.
function campaign_manager:trigger_dilemma_with_targets(faction_cqi, dilemma_key, target_faction_cqi, secondary_faction_cqi, character_cqi, mf_cqi, region_cqi, settlement_cqi, on_trigger_callback)

	--other args are checked in triger_dilemma_with_targets_raw

	if on_trigger_callback and not is_function(on_trigger_callback) then
		script_error("ERROR: trigger_dilemma_with_targets() called but supplied trigger callback [" .. tostring(on_trigger_callback) .. "] is not a function");
		return false;
	end;

	-- trigger the dilemma immediately in mp
	if self:is_multiplayer() then
		return self:trigger_dilemma_with_targets_raw(faction_cqi, dilemma_key, target_faction_cqi, secondary_faction_cqi, character_cqi, mf_cqi, region_cqi, settlement_cqi);
	end;

	-- in singleplayer, wrap the delivery of the dilemma in an intervention
	self:trigger_transient_intervention(
		"dilemma_" .. faction_cqi .. "_" .. dilemma_key,
		function(intervention)
			local process_name = "dilemma_" .. faction_cqi .. "_" .. dilemma_key .. "_listeners";

			-- start a one second countdown - if no dilemma has appeared in this time assume that something has gone wrong, error and abort
			self:callback(
				function()
					script_error("WARNING: trigger_dilemma() called but no dilemma was issued, is there a problem with the data? Faction cqi is [" .. faction_cqi .. "] and dilemma key is [" .. dilemma_key .. "]. Completing the associated intervention, but no dilemma was triggered.");
					core:remove_listener(process_name);
					intervention:complete();
					return;
				end,
				1,
				process_name
			);

			-- listen for the dilemma being issued
			core:add_listener(
				process_name,
				"DilemmaIssuedEvent",
				function(context) return context:dilemma() == dilemma_key end,
				function()
					cm:remove_callback(process_name);

					-- dilemma has been issued, complete intervention
					intervention:complete();
				end,
				false
			);

			-- call the on-trigger callback
			if on_trigger_callback then
				on_trigger_callback();
			end;

			-- trigger the actual dilemma
			self:trigger_dilemma_with_targets_raw(faction_cqi, dilemma_key, target_faction_cqi, secondary_faction_cqi, character_cqi, mf_cqi, region_cqi, settlement_cqi, true);
		end,
		true,
		function(intervention)
			-- configure intervention here
		end
	);

	return true;
end;


--- @function trigger_dilemma_with_targets_raw
--- @desc Directly triggers a dilemma with a specified key and one or more target game objects. This function is a raw wrapper for the @episodic_scripting:trigger_dilemma_with_targets function on the game interface, adding debug output and event type whitelisting, but not featuring the intervention-wrapping behaviour of @campaign_manager:trigger_dilemma_with_targets. Use this function if triggering the dilemma from within an intervention, but @campaign_manager:trigger_dilemma_with_targets (or @campaign_manager:trigger_dilemma) in all other instances.
--- @desc The game object or objects to associate the dilemma with are specified by command-queue index. The dilemma will need to pass any conditions set up in the <code>cdir_events_dilemma_option_junctions</code> table in order to trigger.
--- @p @number faction cqi, Command-queue index of the faction to which the dilemma is issued. This must be supplied.
--- @p @string dilemma key, Dilemma key, from the <code>dilemmas</code> table.
--- @p [opt=0] @number target faction cqi, Command-queue index of a target faction.
--- @p [opt=0] @number secondary faction cqi, Command-queue index of a second target faction.
--- @p [opt=0] @number character cqi, Command-queue index of a target character.
--- @p [opt=0] @number military force cqi, Command-queue index of a target military force.
--- @p [opt=0] @number region cqi, Command-queue index of a target region.
--- @p [opt=0] @number settlement cqi, Command-queue index of a target settlement.
--- @p @function trigger callback, Callback to call when the intervention actually gets triggered.
--- @return @boolean Dilemma triggered successfully.
function campaign_manager:trigger_dilemma_with_targets_raw(faction_cqi, dilemma_key, target_faction_cqi, secondary_faction_cqi, character_cqi, mf_cqi, region_cqi, settlement_cqi, whitelist)
	if not is_number(faction_cqi) then
		script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied faction cqi [" .. tostring(faction_cqi) .. "] is not a number");
		return false;
	end;

	local faction = cm:model():faction_for_command_queue_index(faction_cqi);

	if faction:is_null_interface() then
		script_error("ERROR: trigger_dilemma_with_targets_raw() called but no faction with supplied cqi [" .. faction_cqi .. "] could be found");
		return false;
	end;

	if not is_string(dilemma_key) then
		script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied dilemma key [" .. tostring(dilemma_key) .. "] is not a string");
		return false;
	end;

	local target_faction = false;

	if target_faction_cqi then
		if not is_number(target_faction_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied target faction cqi [" .. tostring(target_faction_cqi) .. "] is not a number or nil");
			return false;
		end;

		if target_faction_cqi ~= 0 then
			target_faction = cm:model():faction_for_command_queue_index(target_faction_cqi);

			if target_faction:is_null_interface() then
				script_error("ERROR: trigger_dilemma_with_targets_raw() called but no target faction with supplied cqi [" .. target_faction_cqi .. "] could be found");
				return false;
			end;
		end;
	else
		target_faction_cqi = 0;
	end;

	local secondary_faction = false;

	if secondary_faction_cqi then
		if not is_number(secondary_faction_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied secondary faction cqi [" .. tostring(secondary_faction_cqi) .. "] is not a number or nil");
			return false;
		end;

		if secondary_faction_cqi ~= 0 then
			secondary_faction = cm:model():faction_for_command_queue_index(secondary_faction_cqi);

			if secondary_faction:is_null_interface() then
				script_error("ERROR: trigger_dilemma_with_targets_raw() called but no secondary faction with supplied cqi [" .. secondary_faction_cqi .. "] could be found");
				return false;
			end;
		end;
	else
		secondary_faction_cqi = 0;
	end;

	local character = false;

	if character_cqi then
		if not is_number(character_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied character cqi [" .. tostring(character_cqi) .. "] is not a number or nil");
			return false;
		end;

		if character_cqi ~= 0 then
			character = cm:get_character_by_cqi(character_cqi);

			if not character then
				script_error("ERROR: trigger_dilemma_with_targets_raw() called but no character with supplied cqi [" .. character_cqi .. "] could be found");
				return false;
			end;
		end;
	else
		character_cqi = 0;
	end;

	local mf = false;

	if mf_cqi then
		if not is_number(mf_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied military force cqi [" .. tostring(mf_cqi) .. "] is not a number or nil");
			return false;
		end;

		if mf_cqi ~= 0 then
			mf = cm:model():military_force_for_command_queue_index(mf_cqi);

			if mf:is_null_interface() then
				script_error("ERROR: trigger_dilemma_with_targets_raw() called but no military force with supplied mf cqi [" .. mf_cqi .. "] could be found");
				return false;
			end;
		end;
	else
		mf_cqi = 0;
	end;

	if region_cqi then
		if not is_number(region_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied region cqi [" .. tostring(region_cqi) .. "] is not a number or nil");
			return false;
		end;
	else
		region_cqi = 0;
	end;

	if settlement_cqi then
		if not is_number(settlement_cqi) then
			script_error("ERROR: trigger_dilemma_with_targets_raw() called but supplied region cqi [" .. tostring(settlement_cqi) .. "] is not a number or nil");
			return false;
		end;
	else
		settlement_cqi = 0;
	end;

	-- debug output
	out("++ triggering dilemma [" .. tostring(dilemma_key) .. "] with targets from db for faction with cqi [" .. tostring(faction_cqi) .. "] (key: " .. faction:name() .. "), whitelisting event type: " .. tostring(whitelist));
	if target_faction then
		out("\ttarget faction [" .. target_faction:name() .. "] with cqi [" .. target_faction_cqi .. "] specified");
	end;
	if secondary_faction then
		out("\tsecondary faction [" .. secondary_faction:name() .. "] with cqi [" .. secondary_faction_cqi .. "] specified");
	end;
	if character then
		out("\tcharacter with cqi [" .. character_cqi .. "] specified (faction [" .. character:faction():name() .. ", position [" .. character:logical_position_x() .. ", " .. character:logical_position_y() .. "])");
	end;
	if mf then
		out("\tmilitary force with cqi [" .. character_cqi .. "] specified (faction [" .. mf:general_character():faction():name() .. ", position [" .. mf:general_character():logical_position_x() .. ", " .. mf:general_character():logical_position_y() .. "])");
	end;
	if region_cqi ~= 0 then
		out("\tregion with cqi [" .. region_cqi .. "] specified");
	end;
	if settlement_cqi ~= 0 then
		out("\tsettlement with cqi [" .. settlement_cqi .. "] specified");
	end;

	if whitelist then
		self:whitelist_event_feed_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
	end;
	
	return self.game_interface:trigger_dilemma_with_targets(faction_cqi, dilemma_key, target_faction_cqi, secondary_faction_cqi, character_cqi, mf_cqi, region_cqi, settlement_cqi);
end;





--- @function trigger_incident
--- @desc Instructs the campaign director to attempt to trigger a specified incident, based on record from the database. The incident will be triggered if its conditions, defined in the <code>cdir_events_incident_option_junctions</code>, pass successfully. The function returns whether the incident was successfully triggered or not.
--- @desc This function wraps the @episodic_scripting:trigger_incident function on the game interface, adding debug output and event type whitelisting.
--- @p @string faction key, Faction key.
--- @p @string incident key, Incident key, from the incidents table.
--- @p [opt=false] @boolean fire immediately, Fire immediately - if this is set, then any turn delay for the incident set in the <code>cdir_event_incident_option_junctions</code> table will be disregarded.
--- @p [opt=false] @boolean whitelist, Supply <code>true</code> here to also whitelist the dilemma event type, so that it displays even if event feed restrictions are in place (see @campaign_manager:suppress_all_event_feed_messages and @campaign_manager:whitelist_event_feed_event_type).
--- @return @boolean incident was triggered
function campaign_manager:trigger_incident(faction, incident, fire_immediately, whitelist)
	fire_immediately = not not fire_immediately;

	out("++ triggering incident from db " .. tostring(incident) .. " for faction " .. tostring(faction) .. ", fire_immediately: " .. tostring(fire_immediately));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_character_incidentevent_feed_target_incident_faction");
		self:whitelist_event_feed_event_type("faction_event_region_incidentevent_feed_target_incident_faction");
		self:whitelist_event_feed_event_type("faction_event_incidentevent_feed_target_incident_faction");
	end;
	
	return self.game_interface:trigger_incident(faction, incident, fire_immediately);
end;


-- get mission manager by mission key
-- for internal usage, hence not being documented
function campaign_manager:get_mission_manager(mission_key)
	return self.mission_managers[mission_key];
end;


-- internal function that a mission manager calls to register itself
function campaign_manager:register_mission_manager(mission_manager)
	if not is_missionmanager(mission_manager) then
		script_error("ERROR: register_mission_manager() called but supplied mission manager [" .. tostring(mission_manager) .. "] is not a mission manager");
		return false;
	end;

	if self:get_mission_manager(mission_manager.mission_key) then
		script_error("ERROR: register_mission_manager() called but supplied mission manager with key [" .. mission_manager.mission_key .. "] is already registered");
		return false;
	end;
	
	self.mission_managers[mission_manager.mission_key] = mission_manager;
end;


--	handles the saving of mission managers to the savegame
function campaign_manager:mission_managers_to_string()
	local str = "";
	for mission_key, mission_manager in pairs(self.mission_managers) do
		str = str .. mission_manager:state_to_string();
	end;
	
	return str;
end;


--	handles the loading of mission managers from the savegame
function campaign_manager:mission_managers_from_string(str)
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			break;
		end;
	
		local mission_key = string.sub(str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: mission_managers_from_string() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local started = string.sub(str, pointer, next_separator - 1);
		
		if started == "true" then
			started = true;
		elseif started == "false" then
			started = false;
		else
			script_error("ERROR: mission_managers_from_string() called but parsing failed, boolean flag [" .. tostring(started) .. "] couldn't be decyphered, string is " .. str);
		end;
		
		pointer = next_separator + 1;
		
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: mission_managers_from_string() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local completed = string.sub(str, pointer, next_separator - 1);
		
		if completed == "true" then
			completed = true;
		elseif completed == "false" then
			completed = false;
		else
			script_error("ERROR: mission_managers_from_string() called but parsing failed, boolean flag [" .. tostring(completed) .. "] couldn't be decyphered, string is " .. str);
			return false;
		end;
		
		-- find the mission manager in the registered list and set it up
		local mission_manager = self:get_mission_manager(mission_key);
		
		if not mission_manager then
			script_error("ERROR:  mission_managers_from_string() is attempting to set up a mission with key [" .. tostring(mission_key) .. "] but it isn't registered. All missions should be registered before the first tick.");
			return false;
		end;
		
		mission_manager:start_from_savegame(started, completed);
		
		pointer = next_separator + 1;
	end;
end;


--- @function suppress_all_event_feed_messages
--- @desc Suppresses or unsuppresses all event feed message from being displayed. With this suppression in place, event panels won't be shown on the UI at all but will be queued and then shown when the suppression is removed. The suppression must not be kept on during the end-turn sequence.
--- @desc When suppressing, we whitelist dilemmas as they lock the model, and also mission succeeded event types as the game tends to flow better this way.
--- @p [opt=true] boolean activate suppression
function campaign_manager:suppress_all_event_feed_messages(value)
	if value ~= false then
		value = true;
	end;

	if self.all_event_feed_messages_suppressed == value then
		return;
	end;
	
	self.all_event_feed_messages_suppressed = value;
	
	-- cancel any previous advice suppressions requests that might still be waiting for advice to be complete
	self:cancel_progress_on_advice_finished();
	
	out(">> suppress_all_event_feed_messages(" .. tostring(value) .. ") called");
	
	CampaignUI.SuppressAllEventTypesInUI(value);
	
	-- if we are suppressing, then whitelist certain event types so that they still get through
	if value then		
		-- whitelist dilemma messages in the UI, in case there's one already pending
		self:whitelist_event_feed_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
		
		-- also whitelist mission succeeded events, the flow just works better if the player gets immediate feedback about these things
		self:whitelist_event_feed_event_type("faction_event_mission_successevent_feed_target_mission_faction");
	end;
end;


--- @function whitelist_event_feed_event_type
--- @desc While suppression has been activated with @campaign_manager:suppress_all_event_feed_messages an event type may be whitelisted and allowed to be shown with this function. This allows scripts to hold all event messages from being displayed except those of a certain type. This is useful for advice scripts which may want to talk about those messages, for example.
--- @desc If event feed suppression is not active then calling this function will have no effect.
--- @p string event type, Event type to whitelist. This is compound key from the <code>event_feed_targeted_events</code> table, which is the event field and the target field of a record from this table, concatenated together.
--- @new_example Whitelisting the "enemy general dies" event type
--- @example cm:whitelist_event_feed_event_type("character_dies_battleevent_feed_target_opponent")
function campaign_manager:whitelist_event_feed_event_type(event_type)
	out(">> whitelist_event_feed_event_type() called, event_type is " .. tostring(event_type));
	
	CampaignUI.WhiteListEventTypeInUI(event_type);
end;


--- @function disable_event_feed_events
--- @desc Disables event feed events by category, subcategory or individual event type. Unlike @campaign_manager:suppress_all_event_feed_messages the events this call blocks are discarded. Use this function to prevent certain events from appearing.
--- @desc The function wraps the @episodic_scripting:disable_event_feed_events function on the underlying episodic scripting interface.
--- @p boolean should disable, Should disable event type(s).
--- @p [opt=""] string event categories, Event categories to disable. Supply "" or false/nil to not disable/enable events by categories in this function call. Supply "all" to disable all event types.
--- @p [opt=""] string event subcategories, Event subcategories to disable. Supply "" or false/nil to not disable/enable events by subcategories in this function call.
--- @p [opt=""] string event, Event to disable. Supply "" or false/nil to not disable/enable an individual event in this function call.
function campaign_manager:disable_event_feed_events(disable, categories, subcategories, events)
	categories = categories or "";
	subcategories = subcategories or "";
	events = events or "";
	--out("disable_event_feed_events() called: ["..tostring(disable).."], ["..categories.."], ["..subcategories.."], ["..events.."]");
	
	local all_categories = "wh_event_category_agent;wh_event_category_character;wh_event_category_conquest;wh_event_category_diplomacy;wh_event_category_faction;wh_event_category_military;wh_event_category_provinces;wh_event_category_traits_ancillaries;wh_event_category_world";
	
	if categories == "all" then
		self.game_interface:disable_event_feed_events(disable, all_categories, subcategories, events);
	else
		self.game_interface:disable_event_feed_events(disable, categories, subcategories, events);
	end
end


--- @function show_message_event
--- @desc Constructs and displays an event. This wraps a the @episodic_scripting:show_message_event function of the same name on the underlying @episodic_scripting, although it provides input validation, output, whitelisting and a progression callback.
--- @p string faction key, Faction key to who the event is targeted.
--- @p string title loc key, Localisation key for the event title. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p string primary loc key, Localisation key for the primary detail of the event. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p string secondary loc key, Localisation key for the secondary detail of the event. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p boolean persistent, Sets this event to be persistent instead of transient.
--- @p number index, Index indicating the type of event.
--- @p [opt=false] function end callback, Specifies a callback to call when this event is dismissed. Note that if another event message shows first for some reason, this callback will be called early.
--- @p [opt=0] number callback delay, Delay in seconds before calling the end callback, if supplied.
--- @p [opt=false] boolean dont whitelist, By default this function will whitelist the scripted event message type with @campaign_manager:whitelist_event_feed_event_type. Set this flag to <code>true</code> to prevent this.
function campaign_manager:show_message_event(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, is_persistent, index_num, end_callback, delay, suppress_whitelist)
	if not cm:get_faction(faction_key) then
		script_error("ERROR: show_message_event() called but no faction with supplied name [" .. tostring(faction_key) .. "] could be found");
		return false;
	end;
	
	if not is_string(title_loc_key) then
		script_error("ERROR: show_message_event() called but supplied title localisation key [" .. tostring(title_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(primary_detail_loc_key) then
		script_error("ERROR: show_message_event() called but supplied primary detail localisation key [" .. tostring(primary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(secondary_detail_loc_key) then
		script_error("ERROR: show_message_event() called but supplied secondary detail localisation key [" .. tostring(secondary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_boolean(is_persistent) then
		script_error("ERROR: show_message_event() called but supplied is_persistent flag [" .. tostring(is_persistent) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_number(index_num) then
		script_error("ERROR: show_message_event() called but supplied index number [" .. tostring(index_num) .. "] is not a number");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: show_message_event() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("ERROR: show_message_event() called but supplied end_callback [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	out("show_message_event() called, showing event for faction [" .. faction_key .. "] with title [" .. title_loc_key .. "], primary detail [" .. primary_detail_loc_key .. "] and secondary detail [" .. secondary_detail_loc_key .. "]");
	
	if end_callback then
		out("\tsetting up progress listener");
		local progress_name = "show_message_event_" .. title_loc_key;
	
		core:add_listener(
			progress_name,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				self:progress_on_events_dismissed(
					progress_name,
					end_callback,
					delay
				);
			end,
			false
		);
	end;
	
	if not suppress_whitelist then
		if is_persistent then
			cm:whitelist_event_feed_event_type("scripted_persistent_eventevent_feed_target_faction");
		else
			cm:whitelist_event_feed_event_type("scripted_transient_eventevent_feed_target_faction");
		end;
	end;
	
	self.game_interface:show_message_event(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, is_persistent, index_num);
end;


--- @function show_message_event_located
--- @desc Constructs and displays a located event. This wraps the @episodic_scripting:show_message_event_located function of the same name on the underlying episodic scripting interface, although it also provides input validation, output, whitelisting and a progression callback.
--- @p string faction key, Faction key to who the event is targeted.
--- @p string title loc key, Localisation key for the event title. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p string primary loc key, Localisation key for the primary detail of the event. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p string secondary loc key, Localisation key for the secondary detail of the event. This should be supplied in the full [table]_[field]_[key] localisation format, or can be a blank string.
--- @p number x, Logical x co-ordinate of event target.
--- @p number y, Logical y co-ordinate of event target.
--- @p boolean persistent, Sets this event to be persistent instead of transient.
--- @p number index, Index indicating the type of event.
--- @p [opt=false] function end callback, Specifies a callback to call when this event is dismissed. Note that if another event message shows first for some reason, this callback will be called early.
--- @p [opt=0] number callback delay, Delay in seconds before calling the end callback, if supplied.
function campaign_manager:show_message_event_located(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, x, y, is_persistent, index_num, end_callback, delay)
	if not cm:get_faction(faction_key) then
		script_error("ERROR: show_message_event_located() called but no faction with supplied name [" .. tostring(faction_key) .. "] could be found");
		return false;
	end;
	
	if not is_string(title_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied title localisation key [" .. tostring(title_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(primary_detail_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied primary detail localisation key [" .. tostring(primary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(secondary_detail_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied secondary detail localisation key [" .. tostring(secondary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(x) then
		script_error("ERROR: show_message_event_located() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a number");
		return false;
	end;
	
	if not is_number(y) then
		script_error("ERROR: show_message_event_located() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a number");
		return false;
	end;
	
	if not is_boolean(is_persistent) then
		script_error("ERROR: show_message_event_located() called but supplied is_persistent flag [" .. tostring(is_persistent) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_number(index_num) then
		script_error("ERROR: show_message_event_located() called but supplied index_num [" .. tostring(index_num) .. "] is not a number");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: show_message_event_located() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("ERROR: show_message_event_located() called but supplied end_callback [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	out("show_message_event_located() called, showing event for faction [" .. faction_key .. "] with title [" .. title_loc_key .. "], primary detail [" .. primary_detail_loc_key .. "] and secondary detail [" .. secondary_detail_loc_key .. "] at co-ordinates [" .. x .. ", " .. y .. "]");
	
	if end_callback then
		local progress_name = "show_message_event_located_" .. title_loc_key;
	
		core:add_listener(
			progress_name,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				self:progress_on_events_dismissed(
					progress_name,
					end_callback,
					delay
				);
			end,
			false
		);
	end;
	
	self.game_interface:show_message_event_located(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, x, y, is_persistent, index_num);
end;









-----------------------------------------------------------------------------
--- @section Transient Interventions
--- @desc @intervention offer a script method for locking the campaign UI and progression until the sequence of scripted events has finished. The main intervention interface should primarily be used when creating interventions, but this section lists functions that can be used to quickly create transient throwaway interventions, whose state is not saved into the savegame. See @"intervention:Transient Interventions" for more information.
-----------------------------------------------------------------------------

--- @function trigger_transient_intervention
--- @desc Creates, starts, and immediately triggers a transient intervention with the supplied paramters. This should trigger immediately unless another intervention is running, in which case it should trigger afterwards.
--- @desc The trigger callback that is supplied to this function will be passed the intervention object when it is called. This callback <strong>must</strong> call @intervention:complete on this object, or cause it to be called, as the UI will be softlocked until the intervention is completed. See @intervention documentation for more information.
--- @p @string name, Name for intervention. This should be unique amongst interventions.
--- @p @function callback, Trigger callback to call.
--- @p [opt=true] @boolean debug, Sets the intervention into debug mode, in which it will produce more output. Supply <code>false</code> to suppress this behaviour.
--- @p [opt=nil] @function configuration callback, If supplied, this function will be called with the created intervention supplied as a single argument before the intervention is started. This allows calling script to configure the intervention before being started.
function campaign_manager:trigger_transient_intervention(name, callback, is_debug, config_callback)
	if is_debug ~= false then
		is_debug = true;
	end;

	-- ti = transient intervention
	local ti = intervention:new(
		name,
		0,
		callback,			-- intervention object will be passed to supplied callback as an argument
		is_debug,
		true
	);

	if not ti then
		return false;
	end;

	ti:set_disregard_cost_when_triggering(true);
	ti:set_allow_when_advice_disabled(true);

	ti:add_trigger_condition(
		"ScriptEventStartTransientIntervention",
		function(context)
			return context.string == name;
		end
	);

	if is_function(config_callback) then
		config_callback(ti);
	end;

	ti:start();

	core:trigger_event("ScriptEventStartTransientIntervention", name);
end;











-----------------------------------------------------------------------------
--- @section Turn Countdown Events
--- @desc The turn countdown event system allows client scripts to register a string event with the campaign manager. The campaign manager will then trigger the event at the start of turn, a set number of turns later. This works even if the game is saved and reloaded. It is intended to be a secure mechanism for causing a scripted event to occur a number of turns in the future.
-----------------------------------------------------------------------------


--- @function add_turn_countdown_event
--- @desc Registers a turn countdown event.
--- @p string faction key, Key of the faction on whose turn start the event will be triggered.
--- @p integer turns, Number of turns from now to trigger the event.
--- @p string event, Event to trigger. By convention, script event names begin with <code>"ScriptEvent"</code>
--- @p [opt=""] string context string, Optional context string to trigger with the event.
function campaign_manager:add_turn_countdown_event(faction_name, turn_offset, event_name, context_str)
	if not is_string(faction_name) then
		script_error("ERROR: add_turn_countdown_event() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	-- if it's not the current faction's turn, then increase the turn_offset by 1, as when the faction starts their turn that will count
	if self:whose_turn_is_it() ~= faction_name then
		turn_offset = turn_offset + 1;
	end;

	return self:add_absolute_turn_countdown_event(faction_name, turn_offset + self.game_interface:model():turn_number(), event_name, context_str)
end;


-- internal function, although it can be used externally if required
function campaign_manager:add_absolute_turn_countdown_event(faction_name, turn_to_trigger, event_name, context_str)
	if not is_string(faction_name) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	-- can only check that faction exists after the model is created
	if core:is_ui_created() then
		local faction = cm:get_faction(faction_name);
		
		if not faction then
			script_error("ERROR: add_absolute_turn_countdown_event() called but faction with supplied name [" .. faction_name .. "] could not be found");
			return false;
		end;
	end;
	
	if not is_number(turn_to_trigger) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied trigger turn [" .. tostring(turn_to_trigger) .. "] is not a number");
		return false;
	end;
	
	if not is_string(event_name) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied event name [" .. tostring(event_name) .. "] is not a string");
		return false;
	end;
	
	if not context_str then
		context_str = "";
	end;
	
	if not is_string(context_str) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied context string [" .. tostring(context_str) .. "] is not a string or nil");
		return false;
	end;
	
	local record = {};
	record.turn_to_trigger = turn_to_trigger;
	record.event_name = event_name;
	record.context_str = context_str;
	
	-- if we have no sub-table for this faction then create it
	if not self.turn_countdown_events[faction_name] then
		self.turn_countdown_events[faction_name] = {};
	end;
	
	-- if we have no elements then start the listener
	if #self.turn_countdown_events[faction_name] == 0 then
		self:add_faction_turn_start_listener_by_name(
			"turn_start_countdown_" .. faction_name,
			faction_name,
			function(context)
				self:check_turn_countdown_events(context.string)
			end,
			true
		);
	end;
	
	table.insert(self.turn_countdown_events[faction_name], record);
end;


-- internal function to check turn countdown events this turn
function campaign_manager:check_turn_countdown_events(faction_name)
	local turn_countdown_events = self.turn_countdown_events[faction_name];

	if not is_table(turn_countdown_events) then
		script_error("WARNING: check_turn_countdown_events() called but could not find a table corresponding to given faction name [" .. faction_name .. "], how can this be?");
		return false;
	end;
	
	for i = 1, #turn_countdown_events do
		local current_record = turn_countdown_events[i];
		
		if current_record.turn_to_trigger <= self.game_interface:model():turn_number() then
			local event_name = current_record.event_name;
			local context_str = current_record.context_str;
			table.remove(turn_countdown_events, i);
			
			-- trigger the event itself
			core:trigger_event(event_name, context_str);
			
			self:check_turn_countdown_events(faction_name);
			return;
		end;
	end;
	
	if #turn_countdown_events == 0 then
		core:remove_listener("turn_start_countdown_" .. faction_name);
	end;
end;


-- saving state of turn countdown events
function campaign_manager:turn_countdown_events_to_string()
	local state_str = "";
	
	out.savegame("turn_countdown_events_to_string() called");
	for faction_name, record_list in pairs(self.turn_countdown_events) do
		for i = 1, #record_list do
			local record = record_list[i];
	
			out.savegame("\tprocessing faction " .. faction_name);
			out.savegame("\t\trecord is " .. tostring(record));
			out.savegame("\t\trecord.turn_to_trigger is " .. tostring(record.turn_to_trigger));
			out.savegame("\t\trecord.event_name is " .. tostring(record.event_name));
			out.savegame("\t\trecord.context_str is " .. tostring(record.context_str));
		
			state_str = state_str .. faction_name .. "%" .. record.turn_to_trigger .. "%" .. record.event_name .. "%" .. record.context_str .. "%";
		end;
	end;
		
	return state_str;
end;


-- loading state of turn countdown events
function campaign_manager:turn_countdown_events_from_string(state_str)
	local pointer = 1;
	
	while true do
		local next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			break;
		end;
	
		local faction_name = string.sub(state_str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local turn_to_trigger_str = string.sub(state_str, pointer, next_separator - 1);
		local turn_to_trigger = tonumber(turn_to_trigger_str);
		
		if not turn_to_trigger then
			script_error("ERROR: turn_countdowns_from_string() called but parsing failed, turns remaining number [" .. tostring(turn_to_trigger_str) .. "] couldn't be decyphered, string is " .. state_str);
			return false;
		end;
		
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local event_name = string.sub(state_str, pointer, next_separator - 1);
		
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local context_str = string.sub(state_str, pointer, next_separator - 1);
		
		pointer = next_separator + 1;
		
		self:add_absolute_turn_countdown_event(faction_name, turn_to_trigger, event_name, context_str);
	end;
end;













-----------------------------------------------------------------------------
--	intervention manager
--	these functions are for intervention scripts and not for use by client scripts
-----------------------------------------------------------------------------

-- registering an intervention manager with the campaign manager
function campaign_manager:set_intervention_manager(im)
	self.intervention_manager = im;
end;

-- getting a registered intervention manager
function campaign_manager:get_intervention_manager()
	if self.intervention_manager then
		return self.intervention_manager;
	else
		return intervention_manager:new();
	end;
end;










-----------------------------------------------------------------------------
--	chapter mission registration
--	internal functions for chapter missions
-----------------------------------------------------------------------------

function campaign_manager:register_chapter_mission(ch)
	self.chapter_missions[ch.chapter_number] = ch;
end;


function campaign_manager:chapter_mission_exists_with_number(value)
	return not not self.chapter_missions[value];
end;











-----------------------------------------------------------------------------
--- @section Pre and Post-Battle Events
--- @desc In single-player mode the campaign manager automatically monitors battles involving the player starting and finishing, and fires events at certain key times during a battle sequence that client scripts can listen for.
--- @desc The campaign manager fires the following pre-battle events:
--- @desc <table class="simple"><tr><td><strong>Event</strong></td><td><strong>Trigger Condition</strong></td></tr><tr><td><code>ScriptEventPreBattlePanelOpened</code></td><td>The pre-battle panel has opened.</td></tr><tr><td><code>ScriptEventPreBattlePanelOpenedAmbushPlayerDefender</code></td><td>The pre-battle panel has opened and the player is the defender in an ambush.</td></tr><tr><td><code>ScriptEventPreBattlePanelOpenedAmbushPlayerAttacker</code></td><td>The pre-battle panel has opened and the player is the attacker in an ambush.</td></tr><tr><td><code>ScriptEventPreBattlePanelOpenedMinorSettlement</code></td><td>The pre-battle panel has opened and the battle is at a minor settlement.</td></tr><tr><td><code>ScriptEventPreBattlePanelOpenedProvinceCapital</code></td><td>The pre-battle panel has opened and the battle is at a province capital.</td></tr><tr><td><code>ScriptEventPreBattlePanelOpenedField</code></td><td>The pre-battle panel has opened and the battle is a field battle.</td></tr><tr><td><code>ScriptEventPlayerBattleStarted</code></td><td>Triggered when player initiates a battle from the pre-battle screen, either by clicking the attack or autoresolve buttons.</td></tr></table>
--- @desc 	
--- @desc It also fires the following events post-battle:
--- @desc <table class="simple"><tr><th>Event</td><th>Trigger Condition</th></tr>
--- @desc <tr><td><code>ScriptEventPlayerWinsBattle</code></td><td>The post-battle panel has opened and the player has won.</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerWinsFieldBattle</code></td><td>The post-battle panel has opened and the player won a field battle (including a battle where a settlement defender sallied against them).</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerWinsSettlementDefenceBattle</code></td><td>The post-battle panel has opened and the player won a settlement defence battle as the defender (including a battle where the player sallied).</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerLosesSettlementDefenceBattle</code></td><td>The post-battle panel has opened and the player lost a settlement defence battle as the defender.</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerWinsSettlementAttackBattle</code></td><td>The post-battle panel has opened and the player won a settlement defence battle as the attacker.</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerLosesFieldBattle</code></td><td>The post-battle panel has opened and the player has lost a field battle.</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerFoughtBattleSequenceCompleted</code></td><td>This event is triggered after a battle sequence in which the player fought a battle has been completed, and the camera has returned to its normal completion.</td></tr>
--- @desc <tr><td><code>ScriptEventPlayerBattleSequenceCompleted</code></td><td>This event is triggered after a battle sequence has been completed and the camera has returned to its normal completion, whether an actual battle was fought or not. This would get triggered and not <code>ScriptEventPlayerFoughtBattleSequenceCompleted</code> if the player were maintaining siege or retreating, for example.</td></tr>
-----------------------------------------------------------------------------

-- only called in singleplayer mode
function campaign_manager:start_processing_battle_listeners()
	core:add_listener(
		"processing_battle_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_attack" or context.string == "button_autoresolve" end,
		function()
			core:trigger_event("ScriptEventPlayerBattleStarted");
		end,
		true
	);
	
	-- Sets up a listener for the BattleCompletedCameraMove event, which is sent when the camera starts to scroll back up to normal altitude after a battle sequence has been completed.
	-- The listener goes on to listen for the BattleCompleted event if a battle was actually fought (if maintaining a siege/retreating/etc no battle will have been fought).
	-- The ScriptEventPlayerBattleSequenceCompleted is triggered in all circumstances when everything is finished.
	core:add_listener(
		"processing_battle_listener",
		"BattleCompletedCameraMove",
		true,
		function()
		
			out("**** BattleCompletedCameraMove event received ****");
			
			-- only proceed if the player was involved
			if not self:pending_battle_cache_faction_is_involved(self:get_local_faction_name()) then
				out("\tplayer faction was not involved, returning");
				self.processing_battle = false;
				return;
			end;
			
			local num_monitors_active = 1;
			local pb = self:model():pending_battle();
			local battle_fought = pb:has_been_fought();
			
			-- Set up a callback to be called when the full battle sequence is completed. This should happen when the
			-- camera has returned back to normal altitude/player control. It is triggered regardless of whether a battle
			-- was actually fought or not (e.g. maintain siege/retreat)
			local full_battle_sequence_completed = function()			
				self:remove_callback("processing_battle_sequence_listener");
				core:remove_listener("processing_battle_sequence_listener");
				self.processing_battle = false;
				self.processing_battle_completing = false;
				
				if battle_fought then
					out("**** full battle sequence completed - triggering ScriptEventPlayerFoughtBattleSequenceCompleted (as the player fought in the battle) and ScriptEventPlayerBattleSequenceCompleted");
					core:trigger_event("ScriptEventPlayerFoughtBattleSequenceCompleted");
				else
					out("**** full battle sequence completed - triggering ScriptEventPlayerBattleSequenceCompleted");
				end;
				
				core:trigger_event("ScriptEventPlayerBattleSequenceCompleted");
			end;
			
			-- Set up a callback that gets called after a battle has been fought, or would have been fought, by the player
			local battle_completed_callback = function()
				num_monitors_active = num_monitors_active - 1;
				if num_monitors_active <= 0 then
					full_battle_sequence_completed();
				end;
			end;
			
			
			-- If it's the players turn then also impose a wait for a little for any post-battle movements and for the camera to scroll up to the normal gameplay altitude
			-- (this is a bit of a hack - we wait for two seconds but in many cases the time we should wait is longer)
			if self:is_local_players_turn() then
				out("\tthis is the player's turn, waiting two seconds for camera movement to finish");
				
				-- We set the processing_battle flag to false at this point because the model will shortly force a save on legendary 
				-- difficulty, which will save this flag into the savegame. We set processing_battle_completing to true until the 
				-- sequence is completed, which is also queried by campaign_manager:is_processing_battle()
				self.processing_battle = false;
				self.processing_battle_completing = true;
				
				num_monitors_active = num_monitors_active + 1;
				self:callback(
					function()
						num_monitors_active = num_monitors_active - 1;
						if num_monitors_active <= 0 then
							full_battle_sequence_completed();
						end;
					end,
					2,
					"processing_battle_sequence_listener"
				);
			else
				out("\tthis is not the player's turn, not waiting two seconds");
			end;
			
			
			-- listen for the BattleCompleted event if an actual battle has been fought
			-- (this is when dead characters are all cleaned up)
			if battle_fought then
				out("\tbattle has been fought, establishing BattleCompleted listener");
			
				core:add_listener(
					"processing_battle_sequence_listener",
					"BattleCompleted",
					true,
					function()
						out("**** BattleCompleted event received ****");
						battle_completed_callback();
					end,
					false
				);
			else
				out("\tbattle has not been fought");
				battle_completed_callback();
			end;
		end,
		true
	);
	
	--
	--	work out what's happening pre-battle so we can send a custom event
	--
	core:add_listener(
		"processing_battle_listener",
		"PanelOpenedCampaign",
		function(context) return context.string == "popup_pre_battle" end,
		function(context)			
			self.processing_battle = true;
		
			local pb = self:model():pending_battle();
			local battle_type = pb:battle_type();
			
			core:trigger_event("ScriptEventPreBattlePanelOpened", pb);
			
			-- check if this is an ambush
			out("popup_pre_battle panel has opened, battle type is " .. battle_type);
			
			if battle_type == "land_ambush" then
				local local_faction = self:get_local_faction_name(true);
				if self:pending_battle_cache_faction_is_defender(local_faction) then
					-- this is an ambush battle in which the player is the defender
					core:trigger_event("ScriptEventPreBattlePanelOpenedAmbushPlayerDefender", pb);
				else
					-- this is an ambush 
					core:trigger_event("ScriptEventPreBattlePanelOpenedAmbushPlayerAttacker", pb);
				end;
				
				return;
			end;			
			
			-- if siege buttons are visible then this must be a siege battle
			local uic_button_set_siege = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "button_set_siege");
			
			if uic_button_set_siege and uic_button_set_siege:Visible() then
				-- this is a battle at a settlement, if the encircle button is visible then it's a minor settlement
				local uic_encircle_button = find_uicomponent(core:get_ui_root(), "popup_pre_battle", "button_surround");
			
				if uic_encircle_button and uic_encircle_button:Visible() then
					-- this is a battle at a minor settlement
					core:trigger_event("ScriptEventPreBattlePanelOpenedMinorSettlement", pb);
				else
					-- this is a battle at a province capital
					core:trigger_event("ScriptEventPreBattlePanelOpenedProvinceCapital", pb);
				end;
			else
				-- this is a regular field battle
				core:trigger_event("ScriptEventPreBattlePanelOpenedField", pb);
			end;
		end,
		true
	);
	
	
	
	--
	--	work out what happened post-battle so we can send a custom event
	--
	core:add_listener(
		"processing_battle_listener",
		"PanelOpenedCampaign",
		function(context) return context.string == "popup_battle_results" end,
		function()		
			local pb = self:model():pending_battle();
			local local_faction = self:get_local_faction_name(true);
			
			local player_was_primary_attacker = (pb:has_attacker() and pb:attacker():faction():name() == local_faction);
			local player_was_primary_defender = (pb:has_defender() and pb:defender():faction():name() == local_faction);
			
			local player_was_attacker = player_was_primary_attacker;
			local player_was_defender = player_was_primary_defender;
			
			if not (player_was_primary_attacker or player_was_primary_defender) then
				player_was_attacker = self:pending_battle_cache_faction_is_attacker(local_faction);
				player_was_defender = self:pending_battle_cache_faction_is_defender(local_faction);
			end;
			
			local is_settlement_battle = pb:has_contested_garrison();
			
			out("***");
			out("*** Battle involving the player has completed");
			
			core:trigger_event("ScriptEventPlayerCompletesBattle", pb);
			
			if player_was_defender then			
				if pb:defender():won_battle() then
					-- player was defender and the defender won the battle					
					if is_settlement_battle then
						-- it was a settlement battle
						if pb:battle_type() == "settlement_sally" then
							-- the player was defending a sally battle (i.e. besieging the settlement and the enemy sallied) and won
							out("*** player won a sally battle as the besieger, triggering event ScriptEventPlayerWinsFieldBattle");
							core:trigger_event("ScriptEventPlayerWinsBattle", pb);
							core:trigger_event("ScriptEventPlayerWinsFieldBattle", pb);
						else
							-- it was a siege defence that the player won
							out("*** player won siege defence, triggering event ScriptEventPlayerDefendsSettlement");
							core:trigger_event("ScriptEventPlayerWinsBattle", pb);
							core:trigger_event("ScriptEventPlayerWinsSettlementDefenceBattle", pb);
						end;
					else
						-- it was a field battle defense that the player won
						out("*** player won field battle defence, triggering event ScriptEventPlayerWinsFieldBattle");
						core:trigger_event("ScriptEventPlayerWinsBattle", pb);
						core:trigger_event("ScriptEventPlayerWinsFieldBattle", pb);
					end;
				elseif pb:attacker():won_battle() then
					-- player was defender and the defender didn't win the battle					
					if is_settlement_battle then
						if pb:battle_type() == "settlement_sally" then
							-- the player lost a sally battle as the defender (i.e. was besieger)
							out("*** player lost a sally battle as the defender, triggering event ScriptEventPlayerLosesFieldBattle");
							core:trigger_event("ScriptEventPlayerLosesBattle", pb);
							core:trigger_event("ScriptEventPlayerLosesFieldBattle", pb);
						elseif player_was_primary_defender then
							-- the player has lost a settlement
							out("*** player has lost a settlement, triggering event ScriptEventPlayerLosesSettlementDefenceBattle");
							core:trigger_event("ScriptEventPlayerLosesBattle", pb);
							core:trigger_event("ScriptEventPlayerLosesSettlementDefenceBattle", pb);
						else
							-- the player has lost a battle over a settlement that wasn't theirs
							out("*** player has lost a battle over a settlement but wasn't the primary defender, triggering event ScriptEventPlayerLosesFieldBattle");
							core:trigger_event("ScriptEventPlayerLosesBattle", pb);
							core:trigger_event("ScriptEventPlayerLosesFieldBattle", pb);
						end;
					else
						-- the player has lost a field battle
						out("*** player has lost a field battle, triggering event ScriptEventPlayerLosesFieldBattle");
						core:trigger_event("ScriptEventPlayerLosesBattle", pb);
						core:trigger_event("ScriptEventPlayerLosesFieldBattle", pb);
					end;					
				end;					
			else
				if pb:attacker():won_battle() then
					-- player was attacker and the attacker won the battle
					is_player_victory = true;
					
					if is_settlement_battle then
						-- it was a battle at a settlement the player won
						
						if pb:battle_type() == "settlement_sally" then
							-- the player has won a sally battle as the attacker - i.e. the player attacked out of the settlement
							out("*** player has won a sally battle as the attacker, triggering event ScriptEventPlayerWinsSettlementDefenceBattle");
							core:trigger_event("ScriptEventPlayerWinsBattle", pb);
							core:trigger_event("ScriptEventPlayerWinsSettlementDefenceBattle", pb);
							
						elseif player_was_primary_attacker then
							-- the player has won a battle at a settlement
							out("*** player has won a settlement battle as the primary attacker, triggering event ScriptEventPlayerWinsSettlementAttackBattle");
							core:trigger_event("ScriptEventPlayerWinsBattle", pb);
							core:trigger_event("ScriptEventPlayerWinsSettlementAttackBattle", pb);
						else
							-- the player was not the primary attacker in a battle victory at a settlement
							out("*** player has won a battle at a settlement but not as the primary attacker, triggering event ScriptEventPlayerWinsFieldBattle");
							core:trigger_event("ScriptEventPlayerWinsBattle", pb);
							core:trigger_event("ScriptEventPlayerWinsFieldBattle", pb);
						end;
					else
						-- the player wins a field battle
						out("*** player has won a field battle as an attacker, triggering event ScriptEventPlayerWinsFieldBattle");
						core:trigger_event("ScriptEventPlayerWinsBattle", pb);
						core:trigger_event("ScriptEventPlayerWinsFieldBattle", pb);
					end;
				elseif pb:defender():won_battle() then
					-- player was attacker and the defender won
					out("*** player has lost a field battle as an attacker, triggering event ScriptEventPlayerLosesFieldBattle");
					core:trigger_event("ScriptEventPlayerLosesBattle", pb);
					core:trigger_event("ScriptEventPlayerLosesFieldBattle", pb);
				end;
			end;
			
			out("***")
		end,
		true
	);
end;










-----------------------------------------------------------------------------
--- @section Values Passed to Battle
--- @desc Prior to battle, the campaign manager saves certain data into the @"core:Scripted Value Registry" which can be accessed by battle scripts:
--- @desc <table class="simple"><tr><td><strong>Variable Name</strong></td><td><strong>Data Type</strong></td><td><strong>Description</strong></td></tr><tr><td><code>battle_type</code></td><td><code>string</code></td><td>The string battle type.</td></tr><tr><td><code>primary_attacker_faction_name</code></td><td><code>string</code></td><td>The faction key of the primary attacking army.</td></tr><tr><td><code>primary_attacker_subculture</code></td><td><code>string</code></td><td>The subculture key of the primary attacking army.</td></tr><tr><td><code>primary_defender_faction_name</code></td><td><code>string</code></td><td>The faction key of the primary defending army.</td></tr><tr><td><code>primary_defender_subculture</code></td><td><code>string</code></td><td>The subculture key of the primary defending army.</td></tr><tr><td><code>primary_attacker_is_player</code></td><td><code>boolean</code></td><td>Whether the local player is the primary attacker.</td></tr><tr><td><code>primary_defender_is_player</code></td><td><code>boolean</code></td><td>Whether the local player is the primary defender.</td></tr></table>
--- @desc These values can be accessed in battle scripts using @core:svr_load_string and @core:svr_load_bool.
-----------------------------------------------------------------------------


-- called by the pending battle cache system when the pending battle event occurs
function campaign_manager:set_pending_battle_svr_state(context)

	local pb = context:pending_battle();
	
	local primary_attacker_faction_name = "";
	local primary_attacker_subculture = "";
	local primary_defender_faction_name = "";
	local primary_defender_subculture = "";
	
	if pb:has_attacker() then
		primary_attacker_faction_name = pb:attacker():faction():name();
		primary_attacker_subculture = pb:attacker():faction():subculture();
	end;
	
	if pb:has_defender() then
		primary_defender_faction_name = pb:defender():faction():name();
		primary_defender_subculture = pb:defender():faction():subculture();
	end;
	
	core:svr_save_string("battle_type", pb:battle_type());
	core:svr_save_string("primary_attacker_faction_name", primary_attacker_faction_name);
	core:svr_save_string("primary_attacker_subculture", primary_attacker_subculture);
	core:svr_save_string("primary_defender_faction_name", primary_defender_faction_name);
	core:svr_save_string("primary_defender_subculture", primary_defender_subculture);
	
	-- only in sp
	if not self:is_multiplayer() then
		local local_faction = cm:get_local_faction_name();
		
		if primary_attacker_faction_name == local_faction then
			core:svr_save_bool("primary_attacker_is_player", true);
			core:svr_save_bool("primary_defender_is_player", false);
		elseif primary_defender_faction_name == local_faction then
			core:svr_save_bool("primary_attacker_is_player", false);
			core:svr_save_bool("primary_defender_is_player", true);
		else
			core:svr_save_bool("primary_attacker_is_player", false);
			core:svr_save_bool("primary_defender_is_player", false);
		end;
	end;
end;












-----------------------------------------------------------------------------
--- @section Region Change Monitor
--- @desc When started, a region change monitor stores a record of what regions a faction holds when their turn ends and compares it to the regions the same faction holds when their next turn starts. If the two don't match, then the faction has gained or lost a region and this system fires some custom script events accordingly to notify other script.
--- @desc If the monitored faction has lost a region, the event <code>ScriptEventFactionLostRegion</code> will be triggered at the start of that faction's turn, with the region lost attached to the context. Should the faction have gained a region during the end-turn sequence, the event <code>ScriptEventFactionGainedRegion</code> will be triggered, with the region gained attached to the context.
--- @desc Region change monitors are disabled by default, and have to be opted-into by client scripts with @campaign_manager:start_faction_region_change_monitor each time the scripts load.
-----------------------------------------------------------------------------


--- @function start_faction_region_change_monitor
--- @desc Starts a region change monitor for a faction.
--- @p string faction key
function campaign_manager:start_faction_region_change_monitor(faction_name)
	
	if not is_string(faction_name) then
		script_error("ERROR: start_faction_region_change_monitor() called but supplied name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	-- see if we already have listeners started for this faction (the data may be reinstated from the savegame)
	if not self.faction_region_change_list[faction_name] then
		self.faction_region_change_list[faction_name] = {};
	end;
	
	core:remove_listener("faction_region_change_monitor_" .. faction_name);
	
	self:add_faction_turn_start_listener_by_name(
		"faction_region_change_monitor_" .. faction_name,
		faction_name,
		function(context)
			self:faction_region_change_monitor_process_turn_start(context:faction())
		end,
		true
	);
	
	core:add_listener(
		"faction_region_change_monitor_" .. faction_name,
		"FactionTurnEnd",
		function(context) return context:faction():name() == faction_name end,
		function(context)
			self:faction_region_change_monitor_process_turn_end(context:faction())
		end,
		true
	);
	
	self:add_first_tick_callback(
		function() 
			self:faction_region_change_monitor_validate_on_load(faction_name);
		end
	);
end;


--- @function stop_faction_region_change_monitor
--- @desc Stops a running region change monitor for a faction.
--- @p string faction key
function campaign_manager:stop_faction_region_change_monitor(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: stop_faction_region_change_monitor() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	core:remove_listener("faction_region_change_monitor_" .. faction_name);
	self:remove_faction_turn_start_listener_by_name("faction_region_change_monitor_" .. faction_name);
	
	self.faction_region_change_list[faction_name] = nil;
end;


-- validates region change monitor saved data
function campaign_manager:faction_region_change_monitor_validate_on_load(faction_name)
	-- if it's currently this faction's turn then process the turn end - this means that the data will be current if loading from a savegame (or from a new game)
	if self:whose_turn_is_it() == faction_name then
		 self:faction_region_change_monitor_process_turn_end(cm:get_faction(faction_name));
	else
		-- validate that the cached region list contains valid data
		local cached_region_list = self.faction_region_change_list[faction_name];
		
		-- compare cached list to current list, to see if the subject faction has lost a region
		for i = 1, #cached_region_list do
			local current_cached_region = cached_region_list[i];
			
			if not cm:get_region(current_cached_region) then		
				script_error("WARNING: faction_region_change_monitor_validate_on_load() called but couldn't find region corresponding to key [" .. current_cached_region .. "] stored in cached region list - regenerating cached list");
				self:faction_region_change_monitor_process_turn_end(cm:get_faction(faction_name));
				return;
			end;
		end;
	end;
end;


-- called on turn end
function campaign_manager:faction_region_change_monitor_process_turn_end(faction)
	local faction_name = faction:name();
	local region_list = faction:region_list();
	
	-- rebuild the cached list of regions owned by this faction
	self.faction_region_change_list[faction_name] = {};

	for i = 0, region_list:num_items(i) - 1 do		
		table.insert(self.faction_region_change_list[faction_name], region_list:item_at(i):name());
	end;
end;


-- called on turn start
function campaign_manager:faction_region_change_monitor_process_turn_start(faction)
	local should_issue_grudge_messages = true;

	-- don't do anything on turn one or two
	if self:model():turn_number() <= 2 then
		should_issue_grudge_messages = false;
	end;

	local faction_name = faction:name();
	local region_list = faction:region_list();
		
	-- create a list of the regions the faction currently has
	local current_region_list = {};
	
	for i = 0, region_list:num_items(i) - 1 do
		table.insert(current_region_list, region_list:item_at(i):name());
	end;
	
	local cached_region_list = self.faction_region_change_list[faction_name];
	
	local regions_gained = {};
	local regions_lost = {};
	
	-- compare cached list to current list, to see if the subject faction has lost a region
	for i = 1, #cached_region_list do
		local current_cached_region = cached_region_list[i];
		local current_cached_region_found = false;
		
		if cm:get_region(current_cached_region) then		
			for j = 1, #current_region_list do
				if current_cached_region == current_region_list[j] then
					current_cached_region_found = true;
					break;
				end;
			end;
		
			if not current_cached_region_found then
				table.insert(regions_lost, current_cached_region);
			end;
		else
			script_error("WARNING: faction_region_change_monitor_process_turn_start() called but couldn't find region corresponding to key [" .. current_cached_region .. "] stored in cached region list - discarding cached list and using current");
			cached_region_list = current_region_list;
			regions_lost = {};
		end;
	end;
	
	-- compare current list to cached list, to see if the subject faction has gained a region
	for i = 1, #current_region_list do
		local current_region = current_region_list[i];
		local current_region_found = false;
		
		for j = 1, #cached_region_list do
			if current_region == cached_region_list[j] then
				current_region_found = true;
				break;
			end;
		end;
		
		if not current_region_found then
			table.insert(regions_gained, current_region);
		end;
	end;
	
	-- trigger script events for each region this faction has lost or gained
	if should_issue_grudge_messages then
		for i = 1, #regions_lost do
			core:trigger_event("ScriptEventFactionLostRegion", faction, cm:get_region(regions_lost[i]));
		end;
		
		for i = 1, #regions_gained do
			core:trigger_event("ScriptEventFactionGainedRegion", faction, cm:get_region(regions_gained[i]));
		end;
	end;
end;


-- saving game
function campaign_manager:faction_region_change_monitor_to_str()
	local savestr = "";
	
	for faction_name, region_table in pairs(self.faction_region_change_list) do
		savestr = savestr .. faction_name;
		
		for i = 1, #region_table do
			savestr = savestr .. "%" .. region_table[i];
		end;
		
		savestr = savestr .. ";";
	end;
	
	return savestr;
end;


-- loading game
function campaign_manager:faction_region_change_monitor_from_str(str)
	if str == "" then
		return;
	end;
	
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, ";", pointer);
		
		if not next_separator then	
			script_error("ERROR: faction_region_change_monitor_from_str() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local faction_str = string.sub(str, pointer, next_separator - 1);
		
		if string.len(faction_str) == 0 then
			script_error("ERROR: faction_region_change_monitor_from_str() called but supplied string contains a zero-length faction record: " .. str);
			return false;
		end;
		
		self:single_faction_region_change_monitor_from_str(faction_str);
		
		pointer = next_separator + 1;
		
		if pointer > string.len(str) then
			-- we have reached the end of the string
			return;
		end;
	end;
end;


function campaign_manager:single_faction_region_change_monitor_from_str(str)
	local pointer = 1;
	local next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		-- we have a faction with no regions, so just start the monitor
		self:start_faction_region_change_monitor(str);
		return;
	end;
	
	local faction_name = string.sub(str, pointer, next_separator - 1);
	
	-- create a record in the faction_region_change_list for this faction
	self.faction_region_change_list[faction_name] = {};
	
	local pointer = next_separator + 1;
	
	while true do
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			-- this is the last region in the string, so add it, start the monitor and then return
			table.insert(self.faction_region_change_list[faction_name], string.sub(str, pointer));
			self:start_faction_region_change_monitor(faction_name);
			return;
		end;
		
		table.insert(self.faction_region_change_list[faction_name], string.sub(str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
end;









-----------------------------------------------------------------------------
--- @section Miscellaneous Monitors
-----------------------------------------------------------------------------


--- @function find_lowest_public_order_region_on_turn_start
--- @desc Starts a monitor for a faction which, on turn start for that faction, triggers a event with the faction and the region they control with the lowest public order attached. This is useful for advice scripts that may wish to know where the biggest public order problems for a faction are. This function will need to be called by client scripts each time the script starts.
--- @desc The event triggered is <code>ScriptEventFactionTurnStartLowestPublicOrder</code>, and the faction and region may be returned by calling <code>faction()</code> and <code>region()</code> on the context object supplied with it.
--- @p string faction key
function campaign_manager:find_lowest_public_order_region_on_turn_start(faction_name)
	
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		script_error("ERROR: find_lowest_public_order_region_on_turn_start() called but no faction with supplied name [" .. tostring(faction_name) .. "] could be found");
		return false;
	end;

	core:add_listener(
		"find_lowest_public_order_region_on_turn_start",
		"ScriptEventFactionTurnStart",
		function(context)
			return context:faction():name() == faction_name;
		end,
		function(context)
			local lowest_public_order = 200;
			local lowest_public_order_region = false;
			local faction = cm:get_faction(faction_name);
			local region_list = faction:region_list();
			
			-- find lowest public order
			for i = 0, region_list:num_items() - 1 do
				local current_region = region_list:item_at(i);
				local current_public_order = current_region:public_order();
				
				if current_public_order < lowest_public_order then
					lowest_public_order = current_public_order;
					lowest_public_order_region = current_region;
				end;
			end;
			
			if lowest_public_order_region then
				out("*** triggering ScriptEventFactionTurnStartLowestPublicOrder for " .. faction_name .. ", lowest_public_order_region is " .. lowest_public_order_region:name());
				core:trigger_event("ScriptEventFactionTurnStartLowestPublicOrder", faction, lowest_public_order_region);
			end;
		end,
		true	
	);
end;


--- @function generate_region_rebels_event_for_faction
--- @desc <code>RegionRebels</code> events are sent as a faction ends their turn but before the <code>FactionTurnEnd</code> event is received. If called, this function listens for <code>RegionRebels</code> events for the specified faction, then waits for the <code>FactionTurnEnd</code> event to be received and sends a separate event. This flow of events works better for advice scripts.
--- @desc The event triggered is <code>ScriptEventRegionRebels</code>, and the faction and region may be returned by calling <code>faction()</code> and <code>region()</code> on the context object supplied with it.
--- @p string faction key
function campaign_manager:generate_region_rebels_event_for_faction(faction_name)
	if not cm:get_faction(faction_name) then
		script_error("ERROR: generate_region_rebels_event_for_faction() called but couldn't find a faction with supplied name [" .. tostring(faction_name) .. "]");
		return false;
	end;
	
	core:add_listener(
		"region_rebels_event_for_faction",
		"RegionRebels",
		function(context) return context:region():owning_faction():name() == faction_name end,
		function(context)
		
			local region_name = context:region():name();
		
			-- a region has rebelled, listen for the FactionTurnEnd event and send the message then
			core:add_listener(
				"region_rebels_event_for_faction",
				"FactionTurnEnd",
				function(context) return context:faction():name() == faction_name end,
				function(context)
					core:trigger_event("ScriptEventRegionRebels", cm:get_faction(faction_name), cm:get_region(region_name));
				end,
				false
			);
		end,
		true
	)
end;


--- @function start_hero_action_listener
--- @desc This fuction starts a listener for hero actions committed against a specified faction and sends out further events based on the outcome of those actions. It is of most use for listening for hero actions committed against a player faction.
--- @desc This function called each time the script starts for the monitors to continue running. Once started, the function triggers the following events:
--- @desc <table class="simple"><tr><td><strong>Event Name</strong></td><td><strong>Context Functions</strong></td><td><strong>Description</strong></td></tr><tr><td><code>ScriptEventAgentActionSuccessAgainstCharacter</code></td><td><code>character</br>target_character</code></td><td>A foreign agent (<code>character</code>) committed a successful action against a character (<code>target_character</code>) of the subject faction.</td></tr><tr><td><code>ScriptEventAgentActionFailureAgainstCharacter</code></td><td><code>character</br>target_character</code></td><td>A foreign agent (<code>character</code>) failed when attempting an action against a character (<code>target_character</code>) of the subject faction.</td></tr><tr><td><code>ScriptEventAgentActionSuccessAgainstCharacter</code></td><td><code>character</br>garrison_residence</code></td><td>A foreign agent (<code>character</code>) committed a successful action against a garrison residence (<code>garrison_residence</code>) of the subject faction.</td></tr><tr><td><code>ScriptEventAgentActionFailureAgainstCharacter</code></td><td><code>character</br>garrison_residence</code></td><td>A foreign agent (<code>character</code>) failed when attempting an action against a garrison residence (<code>garrison_residence</code>) of the subject faction.</td></tr></table>
--- @p string faction key
function campaign_manager:start_hero_action_listener(faction_name)
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		script_error("ERROR: start_hero_action_listener() called but couldn't find faction with specified name [" .. tostring(faction_name) .. "]");
		return false;
	end;

	-- listen for hero actions committed against characters in specified faction
	core:add_listener(
		"character_character_target_action_" .. faction_name,
		"CharacterCharacterTargetAction",
		function(context)
			return context:target_character():faction():name() == local_faction and context:character():faction():name() ~= local_faction;
		end,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				core:trigger_event("ScriptEventAgentActionSuccessAgainstCharacter", context:character(), context:target_character());		-- first character is accessible at character() on context, second at target_character()
			else
				core:trigger_event("ScriptEventAgentActionFailureAgainstCharacter", context:character(), context:target_character());		-- first character is accessible at character() on context, second at target_character()
			end;
		end,
		true
	);
	
	-- listen for hero actions committed against characters in specified faction
	core:add_listener(
		"character_character_target_action_" .. faction_name,
		"CharacterGarrisonTargetAction",
		function(context)
			return context:garrison_residence():faction():name() == local_faction and context:character():faction():name() ~= local_faction;
		end,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				core:trigger_event("ScriptEventAgentActionSuccessAgainstGarrison", context:character(), context:garrison_residence());
			else
				core:trigger_event("ScriptEventAgentActionFailureAgainstGarrison", context:character(), context:garrison_residence());
			end;
		end,
		true
	);
end;


-----------------------------------------------------------------------------
--- @section Campaign Audio Triggers
-----------------------------------------------------------------------------

--- @function trigger_campaign_vo
--- @desc This fuction attempts to trigger campaign vo for the given character, the event name to play is passed as a string
--- @desc which is then given to the sound engine, along with the character, to trigger and call the correct dialogue path.
--- @p string vo event name, looked up in code against wwise IDs
--- @p character character
--- @p delay delay in seconds (as float i.e. 0.0)
function campaign_manager:trigger_campaign_vo(vo_event_name, character, delay)
	self.game_interface:trigger_campaign_vo(vo_event_name, character, delay);
end;



-----------------------------------------------------------------------------
--- @section Benchmark Scripts
-----------------------------------------------------------------------------


--- @function show_benchmark_if_required
--- @desc Shows a benchmark constructed from supplied parameters if the campaign loaded in benchmark mode, otherwise calls a supplied callback. The intention is for this to be called on or around the first tick of the script that's loaded when playing as the benchmark faction (the benchmark loads with the player as a certain faction). If benchmark mode is set, this function plays the supplied cindy scene for the supplied duration, then quits the campaign.
--- @p function non-benchmark callback, Function to call if this campaign has not been loaded in benchmarking mode.
--- @p string cindy file, Cindy file to show for the benchmark.
--- @p number benchmark duration, Benchmark duration in seconds.
--- @p number cam x, Start x position of camera.
--- @p number cam y, Start y position of camera.
--- @p number cam d, Start distance of camera.
--- @p number cam b, Start bearing of camera (in radians).
--- @p number cam h, Start height of camera.
--- @example cm:add_first_tick_callback_sp_new(
--- @example 	function() 
--- @example 		cm:start_intro_cutscene_on_loading_screen_dismissed(
--- @example 			function()
--- @example 				cm:show_benchmark_if_required(
--- @example 					function() cutscene_intro_play() end,
--- @example 					"script/benchmarks/scenes/campaign_benchmark.CindyScene",
--- @example 					92.83,
--- @example 					348.7,
--- @example 					330.9,
--- @example 					10,
--- @example 					0,
--- @example 					10
--- @example 				);
--- @example 			end
--- @example 		);
--- @example 	end
--- @example );
function campaign_manager:show_benchmark_if_required(non_benchmark_callback, cindy_str, duration, start_x, start_y, start_d, start_b, start_h)

	if not is_function(non_benchmark_callback) then
		script_error("ERROR: show_benchmark_if_required() called but supplied callback [" .. tostring(non_benchmark_callback) .. "] is not a function");
		return false;
	end;
	
	if not is_string(cindy_str) then
		script_error("ERROR: show_benchmark_if_required() called but supplied cindy path [" .. tostring(cindy_str) .. "] is not a string");
		return false;
	end;
	
	if not is_number(duration) or duration <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied duration [" .. tostring(duration) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_x) or start_x <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start x co-ordinate [" .. tostring(start_x) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_y) or start_y <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start y co-ordinate [" .. tostring(start_y) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_d) or start_d <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start d co-ordinate [" .. tostring(start_d) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_b) then
		script_error("ERROR: show_benchmark_if_required() called but supplied start b co-ordinate [" .. tostring(start_b) .. "] is not a number");
		return false;
	end;
	
	if not is_number(start_h) or start_h <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start h co-ordinate [" .. tostring(start_h) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not self:is_benchmark_mode() then
		-- don't do benchmark camera pan
		non_benchmark_callback();
		return;
	end;
	
	out("*******************************************************************************");
	out("show_benchmark_if_required() is showing benchmark");
	out("showing cindy scene: " .. cindy_str .. " with duration " .. tostring(duration));
	out("*******************************************************************************");
	
	
	local ui_root = core:get_ui_root();
	
	self:set_camera_position(start_x, start_y, start_d, start_b, start_h);
	self:show_shroud(false);
	CampaignUI.ToggleCinematicBorders(true);
	ui_root:LockPriority(50)
	self:override_ui("disable_settlement_labels", true);
	self:cindy_playback(cindy_str, 0, 5);
	
	self:callback(
		function()
			ui_root:UnLockPriority();
			ui_root:InterfaceFunction("QuitForScript");
		end,
		duration
	);
end;








-- DEPRECATED
-- This function mirrors the behaviour of core:get_unique_counter() but should only be used by mission managers.
-- We have provided this because mission managers previously used core:get_unique_counter(), but this counter would change depending on other 
-- scripts which called this function, meaning that the id's could/would change. This would mean that scripted objectives couldn't be completed in
-- certain circumstances. We cannot change this script, however, as everyone's savegames would break :0(
-- Instead, we provide this function and change all mission managers to use it instead of the function on core. Not ideal.
function campaign_manager:get_unique_counter_for_missions()
	self.unique_counter_for_missions = self.unique_counter_for_missions + 1;
	return self.unique_counter_for_missions;
end;

