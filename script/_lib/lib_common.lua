

--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend





----------------------------------------------------------------------------
---	@section Volume Types
--- @desc A handful of sound-related functions in battle require a volume type to be specified when they are called. The values described below represent those volume types. They can be passed into functions such as @battle:set_volume and @battle:get_volume to specify a volume type.
----------------------------------------------------------------------------


VOLUME_TYPE_MUSIC = 0;			--- @variable VOLUME_TYPE_MUSIC @number Volume type representing music, that can be used with sound-related functions. Value is <code>0</code>.
VOLUME_TYPE_SFX = 1;			--- @variable VOLUME_TYPE_SFX @number Volume type representing sfx, that can be used with sound-related functions. Value is <code>1</code>.
VOLUME_TYPE_ADVISOR = 2;		--- @variable VOLUME_TYPE_ADVISOR @number Volume type representing advisor sounds, that can be used with sound-related functions. Value is <code>2</code>.
VOLUME_TYPE_VO = 3;				--- @variable VOLUME_TYPE_VO @number Volume type representing voiceover sounds, that can be used with sound-related functions. Value is <code>3</code>.
VOLUME_TYPE_INTERFACE = 1;		--- @variable VOLUME_TYPE_INTERFACE @number Volume type representing user interface sounds, that can be used with sound-related functions. Value is <code>4</code>.
VOLUME_TYPE_MOVIE = 5;			--- @variable VOLUME_TYPE_MOVIE @number Volume type representing movie sounds, that can be used with sound-related functions. Value is <code>5</code>.
VOLUME_TYPE_VOICE_CHAT = 6;		--- @variable VOLUME_TYPE_VOICE_CHAT @number Volume type representing voice chat audio, that can be used with sound-related functions. Value is <code>6</code>.
VOLUME_TYPE_MASTER = 7;			--- @variable VOLUME_TYPE_MASTER @number Volume type representing the master volume level, that can be used with sound-related functions. Value is <code>7</code>.





----------------------------------------------------------------------------
---	@section Angle Conversions
----------------------------------------------------------------------------


--- @function r_to_d
--- @desc Converts a supplied angle in radians to degrees.
--- @p number angle, Angle in radians
--- @return number angle in degrees
function r_to_d(value)
	if not is_number(value) then
		return false;
	else
		return value * 57.29578;
	end;
end;


--- @function d_to_r
--- @desc Converts a supplied angle in degrees to radians.
--- @p number angle, Angle in degrees
--- @return number angle in radians
function d_to_r(value)
	if not is_number(value) then
		return false;
	else
		return value * 0.017453;
	end;
end;








----------------------------------------------------------------------------
---	@section File and Folder Paths
--- @desc Functions to help get the filename and path of the calling script.
----------------------------------------------------------------------------


--- @function get_file_and_folder_path_as_table
--- @desc Returns the file and path of the calling script as a table of strings.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file and folder path of the script file calling the the script file calling this function, for example.
--- @return table table of strings
function get_file_and_folder_path_as_table(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_folder_name_and_shortform() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	-- path of the file that called this function
	local file_path = debug.getinfo(2 + stack_offset).source;
	
	local retval = {};
	
	if string.len(file_path) == 0 then
		-- don't know if this can happen
		return retval;
	end;
	
	local current_separator_pos = 1;
	local next_separator_pos = 1;
	
	-- list of separators - we have to try each of them each time
	local separators = {"\\/", "\\", "//", "/"};
	
	while true do
		local next_separator_pos = string.len(file_path);
		local separator_found = false;
		
		-- try each of our separators and, if we find any, pick the "earliest"
		for i = 1, #separators do
			-- apologies for variable names in here..
			local this_separator = separators[i];
			
			local this_next_separator_pos = string.find(file_path, this_separator, current_separator_pos);
			
			if this_next_separator_pos and this_next_separator_pos < next_separator_pos then
				next_separator_pos = this_next_separator_pos;
				separator_found = this_separator;
			end;			
		end;

		if separator_found then
			table.insert(retval, string.sub(file_path, current_separator_pos, next_separator_pos - 1));
		else
			-- if we didn't find a separator, we must be the end of the path (and it doesn't end with a separator)
			table.insert(retval, string.sub(file_path, current_separator_pos));
			return retval;
		end;
		
		current_separator_pos = next_separator_pos + string.len(separator_found);
		
		-- stop if we're at the end of our string
		if current_separator_pos >= string.len(file_path) then
			return retval;
		end;
	end;
end;


--- @function get_folder_name_and_shortform
--- @desc Returns the folder name of the calling file and the shortform of its filename as separate return parameters. The shortform of the filename is the portion of the filename before the first "_", if one is found. If no shortform is found the function returns only the folder name.
--- @desc A shortform used to be prepended on battle script files to allow them to be easily differentiated from one another in text editors e.g. "TF_battle_main.lua" vs "PY_battle_main.lua" rather than two "battle_main.lua"'s.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the folder name/shortform of the script file calling the the script file calling this function, for example.
--- @return string name of folder containing calling file
--- @return string shortform of calling filename, if any
function get_folder_name_and_shortform(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_folder_name_and_shortform() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	local path = get_file_and_folder_path_as_table(stack_offset + 1);
	
	-- folder name is the last-but-one element in the returned path
	if #path < 2 then
		script_error("ERROR: get_folder_name_and_shortform() called but couldn't determine a valid path to folder? Investigate");
		return false;
	end;
	
	folder_name = path[#path - 1];
	
	local shortform_end = string.find(folder_name, "_");
	
	-- if we didn't find a "_" character pass back the whole folder name as a single return value
	if not shortform_end then
		return folder_name;
	end;
	
	-- pass back the substring before the first "_" as the folder shortform
	local shortform = string.sub(folder_name, 1, shortform_end - 1);
	
	return folder_name, shortform;
end;


--- @function get_full_file_path
--- @desc Gets the full filepath and name of the calling file.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file path of the script file calling the the script file calling this function, for example.
--- @return string file path
function get_full_file_path(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_full_file_path() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	return debug.getinfo(2 + stack_offset).source;
end;


--- @function get_file_name_and_path
--- @desc Returns the filename and the filepath of the calling file as separate return parameters.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file name and path of the script file calling the the script file calling this function, for example.
--- @return string file name
--- @return string file path
function get_file_name_and_path(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_file_name_and_path() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	-- path of the file that called this function
	local file_path = debug.getinfo(2 + stack_offset).source;
	local current_pointer = 1;
	
	print("get_file_name_and_path() called, file_path is " .. file_path);
	
	-- logfile output
	if __write_output_to_logfile then
		local file = io.open(__logfile_path, "a");
		if file then
			file:write("get_file_name_and_path() called, file_path is " .. file_path);
			file:close();
		end;
	end;
	
	while true do
		local separator = "\\";
		local next_separator_pos = string.find(file_path, separator, current_pointer);
		
		if not next_separator_pos then
			separator = "/";
			next_separator_pos = string.find(file_path, separator, current_pointer);
			
			if not next_separator_pos then
				separator = "\\/";
				next_separator_pos = string.find(file_path, separator, current_pointer);
			end;
		end;
		
		if not next_separator_pos then
			-- there are no more separators in the file path
			
			if current_pointer == 1 then
				-- no file path was detected for some reason
				return file_path, "";
			end;
			-- otherwise return the file name and the file path as separate parameters
			return string.sub(file_path, current_pointer), string.sub(file_path, 1, current_pointer - 2);
		end;
		
		current_pointer = next_separator_pos + string.len(separator);
	end;
end;













----------------------------------------------------------------------------
---	@section Type Checking
----------------------------------------------------------------------------


--- @function is_nil
--- @desc Returns true if the supplied object is nil, false otherwise.
--- @p object object
--- @return boolean is nil
function is_nil(obj)
	if type(obj) == "nil" then
		return true;
	end;
	
	return false;
end;


--- @function is_number
--- @desc Returns true if the supplied object is a number, false otherwise.
--- @p object object
--- @return boolean is number
function is_number(obj)
	if type(obj) == "number" then
		return true;
	end;
	
	return false;
end;


--- @function is_function
--- @desc Returns true if the supplied object is a function, false otherwise.
--- @p object object
--- @return boolean is function
function is_function(obj)
	if type(obj) == "function" then
		return true;
	end;
	
	return false;
end;


--- @function is_string
--- @desc Returns true if the supplied object is a string, false otherwise.
--- @p object object
--- @return boolean is string
function is_string(obj)
	if type(obj) == "string" then
		return true;
	end;
	
	return false;
end;


--- @function is_boolean
--- @desc Returns true if the supplied object is a boolean, false otherwise.
--- @p object object
--- @return boolean is boolean
function is_boolean(obj)
	if type(obj) == "boolean" then
		return true;
	end;
	
	return false;
end;


--- @function is_table
--- @desc Returns true if the supplied object is a table, false otherwise.
--- @p object object
--- @return boolean is table
function is_table(obj)
	if type(obj) == "table" then
		return true;
	end;
	
	return false;
end;


--- @function is_eventcontext
--- @desc Returns true if the supplied object is an event context, false otherwise.
--- @p object object
--- @return boolean is event context
function is_eventcontext(obj)
	if string.sub(tostring(obj), 1, 14) == "Pointer<EVENT>" then
		return true;
	end;
	
	return false;
end;


--- @function is_battlesoundeffect
--- @desc Returns true if the supplied object is a battle sound effect, false otherwise.
--- @p object object
--- @return boolean is battle sound effect
function is_battlesoundeffect(obj)
	if string.sub(tostring(obj), 1, 20) == "battle_sound_effect " then
		return true;
	end;
	
	return false;
end;


--- @function is_battle
--- @desc Returns true if the supplied object is an empire battle object, false otherwise.
--- @p object object
--- @return boolean is battle
function is_battle(obj)
	if string.sub(tostring(obj), 1, 14) == "empire_battle " then
		return true;
	end;
	
	return false;
end;


--- @function is_alliances
--- @desc Returns true if the supplied object is an alliances object, false otherwise.
--- @p object object
--- @return boolean is alliances
function is_alliances(obj)
	if string.sub(tostring(obj), 1, 17) == "battle.alliances " then
		return true;
	end;
	
	return false;
end;


--- @function is_alliance
--- @desc Returns true if the supplied object is an alliance, false otherwise.
--- @p object object
--- @return boolean is alliance
function is_alliance(obj)
	if string.sub(tostring(obj), 1, 16) == "battle.alliance " then
		return true;
	end;
	
	return false;
end;


--- @function is_armies
--- @desc Returns true if the supplied object is an armies object, false otherwise.
--- @p object object
--- @return boolean is armies
function is_armies(obj)
	if string.sub(tostring(obj), 1, 14) == "battle.armies " then
		return true;
	end;
	
	return false;
end;


--- @function is_army
--- @desc Returns true if the supplied object is an army object, false otherwise.
--- @p object object
--- @return boolean is army
function is_army(obj)
	if string.sub(tostring(obj), 1, 12) == "battle.army " then
		return true;
	end;
	
	return false;
end;


--- @function is_units
--- @desc Returns true if the supplied object is a units object, false otherwise.
--- @p object object
--- @return boolean is units
function is_units(obj)
	if string.sub(tostring(obj), 1, 13) == "battle.units " then
		return true;
	end;
	
	return false;
end;

--- @function is_unit
--- @desc Returns true if the supplied object is a unit object, false otherwise.
--- @p object object
--- @return boolean is unit
function is_unit(obj)
	if string.sub(tostring(obj), 1, 12) == "battle.unit " or string.sub(tostring(obj), 1, 21) == "UNIT_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_unitcontroller
--- @desc Returns true if the supplied object is a unitcontroller, false otherwise.
--- @p object object
--- @return boolean is unitcontroller
function is_unitcontroller(obj)
	if string.sub(tostring(obj), 1, 23) == "battle.unit_controller " then
		return true;
	end;
	
	return false;
end;


--- @function is_core
--- @desc Returns true if the supplied object is a @core object, false otherwise.
--- @p object object
--- @return boolean is core
function is_core(obj)
	if tostring(obj) == TYPE_CORE then
		return true;
	end;
	
	return false;
end;


--- @function is_battlemanager
--- @desc Returns true if the supplied object is a @battle_manager, false otherwise.
--- @p object object
--- @return boolean is battle manager
function is_battlemanager(obj)
	if tostring(obj) == TYPE_BATTLE_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_campaignmanager
--- @desc Returns true if the supplied object is a campaign manager, false otherwise.
--- @p object object
--- @return boolean is campaign manager
function is_campaignmanager(obj)
	if tostring(obj) == TYPE_CAMPAIGN_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_factionstart
--- @desc Returns true if the supplied object is a faction start object, false otherwise.
--- @p object object
--- @return boolean is faction start
function is_factionstart(obj)
	if tostring(obj) == TYPE_FACTION_START then
		return true;
	end;
	
	return false;
end;


--- @function is_campaigncutscene
--- @desc Returns true if the supplied object is a campaign cutscene, false otherwise.
--- @p object object
--- @return boolean is campaign cutscene
function is_campaigncutscene(obj)
	if tostring(obj) == TYPE_CAMPAIGN_CUTSCENE then
		return true;
	end;
	
	return false;
end;


--- @function is_cutscene
--- @desc Returns true if the supplied object is a battle cutscene, false otherwise.
--- @p object object
--- @return boolean is cutscene
function is_cutscene(obj)
	if tostring(obj) == TYPE_CUTSCENE_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_vector
--- @desc Returns true if the supplied object is a vector object, false otherwise.
--- @p object object
--- @return boolean is vector
function is_vector(obj)
	local obj_str = tostring(obj);
	if obj_str == TYPE_CAMPAIGN_VECTOR or string.sub(obj_str, 1, 14) == "battle_vector " then
		return true;
	end;
	
	return false;
end;


--- @function is_building
--- @desc Returns true if the supplied object is a building object, false otherwise.
--- @p object object
--- @return boolean is building
function is_building(obj)
	local obj_str = tostring(obj);
	if string.sub(obj_str, 1, 16) == "battle.building " or string.sub(tostring(obj), 1, 25) == "BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_buildings
--- @desc Returns true if the supplied object is a buildings object, false otherwise.
--- @p object object
--- @return boolean is buildings
function is_buildings(obj)
	local obj_str = tostring(obj);
	if string.sub(obj_str, 1, 17) == "battle.buildings " then
		return true;
	end;
	
	return false;
end;


--- @function is_buildinglist
--- @desc Returns true if the supplied object is a building list object, false otherwise.
--- @p object object
--- @return boolean is building list
function is_buildinglist(obj)
	if string.sub(tostring(obj), 1, 30) == "BUILDING_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_convexarea
--- @desc Returns true if the supplied object is a @convex_area, false otherwise.
--- @p object object
--- @return boolean is convex area
function is_convexarea(obj)
	if tostring(obj) == TYPE_CONVEX_AREA then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptunit
--- @desc Returns true if the supplied object is a @script_unit, false otherwise.
--- @p object object
--- @return boolean is scriptunit
function is_scriptunit(obj)
	if tostring(obj) == TYPE_SCRIPT_UNIT then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptunits
--- @desc Returns true if the supplied object is a @script_units object, false otherwise.
--- @p object object
--- @return boolean is scriptunits
function is_scriptunits(obj)
	if tostring(obj) == TYPE_SCRIPT_UNITS then
		return true;
	end;
	
	return false;
end;


--- @function is_subtitles
--- @desc Returns true if the supplied object is a battle subtitles object, false otherwise.
--- @p object object
--- @return boolean is subtitles
function is_subtitles(obj)
	if string.sub(tostring(obj), 1, 17) == "battle.subtitles " then
		return true;
	end;
	
	return false;
end;


--- @function is_patrolmanager
--- @desc Returns true if the supplied object is a patrol manager, false otherwise.
--- @p object object
--- @return boolean is patrol manager
function is_patrolmanager(obj)
	if tostring(obj) == TYPE_PATROL_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_waypoint
--- @desc Returns true if the supplied object is a patrol manager waypoint, false otherwise.
--- @p object object
--- @return boolean is waypoint
function is_waypoint(obj)
	if tostring(obj) == TYPE_WAYPOINT then
		return true;
	end;
	
	return false;
end;


--- @function is_eventhandler
--- @desc Returns true if the supplied object is an event handler, false otherwise.
--- @p object object
--- @return boolean is event handler
function is_eventhandler(obj)
	if tostring(obj) == TYPE_EVENT_HANDLER then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptaiplanner
--- @desc Returns true if the supplied object is a script ai planner, false otherwise.
--- @p object object
--- @return boolean is script ai planner
function is_scriptaiplanner(obj)
	if tostring(obj) == TYPE_SCRIPT_AI_PLANNER then
		return true;
	end;
	
	return false;
end;


--- @function is_timermanager
--- @desc Returns true if the supplied object is a timer manager, false otherwise.
--- @p object object
--- @return boolean is timer manager
function is_timermanager(obj)
	if tostring(obj) == TYPE_TIMER_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_uioverride
--- @desc Returns true if the supplied object is a ui override, false otherwise.
--- @p object object
--- @return boolean is ui override
function is_uioverride(obj)
	if tostring(obj) == TYPE_UI_OVERRIDE then
		return true;
	end;
	
	return false;
end;


--- @function is_uicomponent
--- @desc Returns true if the supplied object is a uicomponent, false otherwise.
--- @p object object
--- @return boolean is uicomponent
function is_uicomponent(obj)
	if string.sub(tostring(obj), 1, 12) == "UIComponent " then
		return true;
	end;
	
	return false;
end;


--- @function is_component
--- @desc Returns true if the supplied object is a component, false otherwise.
--- @p object object
--- @return boolean is component
function is_component(obj)
	if string.sub(tostring(obj), 1, 19) == "Pointer<Component> " then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptmessager
--- @desc Returns true if the supplied object is a script messager, false otherwise.
--- @p object object
--- @return boolean is script messager
function is_scriptmessager(obj)
	if tostring(obj) == TYPE_SCRIPT_MESSAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedbattle
--- @desc Returns true if the supplied object is a generated battle, false otherwise.
--- @p object object
--- @return boolean is generated battle
function is_generatedbattle(obj)
	if tostring(obj) == TYPE_GENERATED_BATTLE then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedarmy
--- @desc Returns true if the supplied object is a generated army, false otherwise.
--- @p object object
--- @return boolean is generated army
function is_generatedarmy(obj)
	if tostring(obj) == TYPE_GENERATED_ARMY then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedcutscene
--- @desc Returns true if the supplied object is a generated cutscene, false otherwise.
--- @p object object
--- @return boolean is generated cutscene
function is_generatedcutscene(obj)
	if tostring(obj) == TYPE_GENERATED_CUTSCENE then
		return true;
	end;
	
	return false;
end;


--- @function is_null
--- @desc Returns true if the supplied object is a campaign null script interface, false otherwise.
--- @p object object
--- @return boolean is null
function is_null(obj)
	if string.sub(tostring(obj), 1, 21) == "NULL_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_model
--- @desc Returns true if the supplied object is a campaign model interface, false otherwise.
--- @p object object
--- @return boolean is model
function is_model(obj)
	if string.sub(tostring(obj), 1, 22) == "MODEL_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_world
--- @desc Returns true if the supplied object is a campaign world interface, false otherwise.
--- @p object object
--- @return boolean is world
function is_world(obj)
	if string.sub(tostring(obj), 1, 22) == "WORLD_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_faction
--- @desc Returns true if the supplied object is a campaign faction interface, false otherwise.
--- @p object object
--- @return boolean is faction
function is_faction(obj)
	if string.sub(tostring(obj), 1, 24) == "FACTION_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_factionlist
--- @desc Returns true if the supplied object is a campaign faction list interface, false otherwise.
--- @p object object
--- @return boolean is faction list
function is_factionlist(obj)
	if string.sub(tostring(obj), 1, 29) == "FACTION_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_character
--- @desc Returns true if the supplied object is a campaign character interface, false otherwise.
--- @p object object
--- @return boolean is character
function is_character(obj)
	if string.sub(tostring(obj), 1, 26) == "CHARACTER_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_characterlist
--- @desc Returns true if the supplied object is a campaign character list interface, false otherwise.
--- @p object object
--- @return boolean is character list
function is_characterlist(obj)
	if string.sub(tostring(obj), 1, 31) == "CHARACTER_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_regionmanager
--- @desc Returns true if the supplied object is a campaign region manager interface, false otherwise.
--- @p object object
--- @return boolean is region manager
function is_regionmanager(obj)
	if string.sub(tostring(obj), 1, 31) == "REGION_MANAGER_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_region
--- @desc Returns true if the supplied object is a campaign region interface, false otherwise.
--- @p object object
--- @return boolean is region
function is_region(obj)
	if string.sub(tostring(obj), 1, 23) == "REGION_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_regionlist
--- @desc Returns true if the supplied object is a campaign region list interface, false otherwise.
--- @p object object
--- @return boolean is region list
function is_regionlist(obj)
	if string.sub(tostring(obj), 1, 28) == "REGION_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_garrisonresidence
--- @desc Returns true if the supplied object is a campaign garrison residence interface, false otherwise.
--- @p object object
--- @return boolean is garrison residence
function is_garrisonresidence(obj)
	if string.sub(tostring(obj), 1, 35) == "GARRISON_RESIDENCE_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_settlement
--- @desc Returns true if the supplied object is a campaign settlement interface, false otherwise.
--- @p object object
--- @return boolean is settlement
function is_settlement(obj)
	if string.sub(tostring(obj), 1, 27) == "SETTLEMENT_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_slot
--- @desc Returns true if the supplied object is a campaign slot interface, false otherwise.
--- @p object object
--- @return boolean is slot
function is_slot(obj)
	if string.sub(tostring(obj), 1, 21) == "SLOT_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_slotlist
--- @desc Returns true if the supplied object is a campaign slot list interface, false otherwise.
--- @p object object
--- @return boolean is slot list
function is_slotlist(obj)
	if string.sub(tostring(obj), 1, 26) == "SLOT_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_militaryforce
--- @desc Returns true if the supplied object is a campaign military force interface, false otherwise.
--- @p object object
--- @return boolean is military force
function is_militaryforce(obj)
	if string.sub(tostring(obj), 1, 31) == "MILITARY_FORCE_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_militaryforcelist
--- @desc Returns true if the supplied object is a campaign military force list interface, false otherwise.
--- @p object object
--- @return boolean is military force list
function is_militaryforcelist(obj)
	if string.sub(tostring(obj), 1, 36) == "MILITARY_FORCE_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_unitlist
--- @desc Returns true if the supplied object is a campaign unit list interface, false otherwise.
--- @p object object
--- @return boolean is unit list
function is_unitlist(obj)
	if string.sub(tostring(obj), 1, 26) == "UNIT_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_pendingbattle
--- @desc Returns true if the supplied object is a campaign pending battle interface, false otherwise.
--- @p object object
--- @return boolean is pending battle
function is_pendingbattle(obj)
	if string.sub(tostring(obj), 1, 31) == "PENDING_BATTLE_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_campaignmission
--- @desc Returns true if the supplied object is a campaign mission interface, false otherwise.
--- @p object object
--- @return boolean is campaign mission
function is_campaignmission(obj)
	if string.sub(tostring(obj), 1, 33) == "CAMPAIGN_MISSION_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_campaignai
--- @desc Returns true if the supplied object is a campaign ai interface, false otherwise.
--- @p object object
--- @return boolean is campaign ai
function is_campaignai(obj)
	if string.sub(tostring(obj), 1, 28) == "CAMPAIGN_AI_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_campaignuimanager
--- @desc Returns true if the supplied object is a campaign ui manager, false otherwise.
--- @p object object
--- @return boolean is campaign ui manager
function is_campaignuimanager(obj)
	if tostring(obj) == TYPE_CAMPAIGN_UI_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_objectivesmanager
--- @desc Returns true if the supplied object is an @objectives_manager, false otherwise.
--- @p object object
--- @return boolean is objectives manager
function is_objectivesmanager(obj)
	if tostring(obj) == TYPE_OBJECTIVES_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_infotextmanager
--- @desc Returns true if the supplied object is an @infotext_manager, false otherwise.
--- @p object object
--- @return boolean is infotext manager
function is_infotextmanager(obj)
	if tostring(obj) == TYPE_INFOTEXT_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_missionmanager
--- @desc Returns true if the supplied object is a mission manager, false otherwise.
--- @p object object
--- @return boolean is text pointer
function is_missionmanager(obj)
	if tostring(obj) == TYPE_MISSION_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_intervention
--- @desc Returns true if the supplied object is an intervention, false otherwise.
--- @p object object
--- @return boolean is intervention
function is_intervention(obj)
	if tostring(obj) == TYPE_INTERVENTION then
		return true;
	end;
	
	return false;
end;


--- @function is_interventionmanager
--- @desc Returns true if the supplied object is an intervention manager, false otherwise.
--- @p object object
--- @return boolean is intervention manager
function is_interventionmanager(obj)
	if tostring(obj) == TYPE_INTERVENTION_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_linkparser
--- @desc Returns true if the supplied object is a link parser, false otherwise.
--- @p object object
--- @return boolean is link parser
function is_linkparser(obj)
	if tostring(obj) == TYPE_LINK_PARSER then
		return true;
	end;
	
	return false;
end;


--- @function is_advicemanager
--- @desc Returns true if the supplied object is an advice manager, false otherwise.
--- @p object object
--- @return boolean is advice manager
function is_advicemanager(obj)
	if tostring(obj) == TYPE_ADVICE_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_advicemonitor
--- @desc Returns true if the supplied object is an advice monitor, false otherwise.
--- @p object object
--- @return boolean is advice monitor
function is_advicemonitor(obj)
	if tostring(obj) == TYPE_ADVICE_MONITOR then
		return true;
	end;
	
	return false;
end;









----------------------------------------------------------------------------
---	@section Tables
----------------------------------------------------------------------------


--- @function table_contains
--- @desc Returns true if the supplied indexed table contains the supplied object.
--- @p table subject table
--- @p object object
--- @return boolean table contains object
function table_contains(t, obj)
	for i = 1, #t do
		if t[i] == obj then
			return true;
		end;
	end;
	return false;
end;









----------------------------------------------------------------------------
---	@section UIComponents
----------------------------------------------------------------------------


--- @function find_child_uicomponent
--- @desc Takes a uicomponent and a string name. Searches the direct children (and no further - not grandchildren etc) of the supplied uicomponent for another uicomponent with the supplied name. If a uicomponent with the matching name is found then it is returned, otherwise <code>false</code> is returned.
--- @p uicomponent parent ui component
--- @p string name
--- @return uicomponent child, or false if not found
function find_child_uicomponent(parent, name)
	for i = 0, parent:ChildCount() - 1 do
		local uic_child = UIComponent(parent:Find(i));
		if uic_child:Id() == name then
			return uic_child;
		end;
	end;
	
	return false;
end;


-- can be used externally, but find_uicomponent is better
function find_single_uicomponent(parent, component_name)
	if not is_uicomponent(parent) then
		script_error("ERROR: find_single_uicomponent() called but supplied parent [" .. tostring(parent) .."] is not a ui component");
		return false;
	end;
	
	if not is_string(component_name) and not is_number(component_name) then
		script_error("ERROR: find_single_uicomponent() called but supplied component name [" .. tostring(component_name) .. "] is not a string or a number");
		return false;
	end;

	local component = parent:Find(component_name, false);
	
	if not component then
		return false;
	end;
	
	return UIComponent(component);
end;


--- @function find_uicomponent
--- @desc Finds and returns a uicomponent based on a set of strings that define its path in the ui hierarchy. This parent uicomponent can be supplied as the first argument - if omitted, the root uicomponent is used. Starting from the parent or root, the function searches through all descendants for a uicomponent with the next supplied uicomponent name in the sequence. If a uicomponent is found, its descendants are then searched for a uicomponent with the next name in the list, and so on until the list is finished or no uicomponent with the supplied name is found. A fragmentary path may be supplied if it still unambiguously specifies the intended uicomponent.
--- @p [opt=nil] @uicomponent parent ui component
--- @p ... list of string names
--- @return uicomponent child, or false if not found.
function find_uicomponent(...)

	local current_parent = arg[1];
	local start_index = 2;

	if not is_uicomponent(current_parent) then
		current_parent = core:get_ui_root();
		start_index = 1;
	end;
	
	for i = start_index, arg.n do
		local current_child = find_single_uicomponent(current_parent, arg[i]);
		
		if not current_child then
			-- out("find_uicomponent() couldn't find component called " .. tostring(arg[i]));
			return false;
		end;
		
		current_parent = current_child;
	end;
	
	return current_parent;
end;


--- @function find_uicomponent_from_table
--- @desc Takes a start uicomponent and a numerically-indexed table of string uicomponent names. Starting from the supplied start uicomponent, the function searches through all descendants for a uicomponent with the next supplied uicomponent name in the table. If a uicomponent is found, its descendants are then searched for a uicomponent with the next name in the list, and so on until the list is finished or no uicomponent with the supplied name is found. This allows a uicomponent to be searched for by matching its name and part of or all of its path.
--- @p uicomponent parent ui component, Parent uicomponent.
--- @p table table of string names, Table of string names, indexed by number.
--- @p [opt=false] assert on failure, Fire a script error if the search fails.
--- @return uicomponent child, or false if not found.
function find_uicomponent_from_table(parent, t, assert_on_failure)
	if not is_table(t) then
		script_error("ERROR: find_uicomponent_from_table() called but supplied path list [" .. tostring(t) .. "] is not a table");
		return false;
	end;
	
	local current_uic = parent;
	
	for i = 1, #t do
		local current_id = t[i];
		
		if not is_string(current_id) and not is_number(current_id) then
			script_error("ERROR: find_uicomponent_from_table() called but element " .. tostring(i) .. " of supplied path list is not a string, it is [" .. tostring(current_id) .. "]");
			return false;
		end;
		
		current_uic = find_single_uicomponent(current_uic, current_id);
		
		if not current_uic then
			if assert_on_failure then
				local path = table.concat(t, ", ");
				script_error("ERROR: find_uicomponent_from_table() couldn't find uicomponent, path is [" .. path .. "] and the failure occurred trying to find element " .. i .. " [" .. current_id .. "]");
			end;
			
			return false;
		end;
	end;	
	
	return current_uic;
end;


--- @function uicomponent_descended_from
--- @desc Takes a uicomponent and a string name. Returns true if any parent ancestor component all the way up to the ui root has the supplied name (i.e. the supplied component is descended from it), false otherwise.
--- @p uicomponent subject uic
--- @p string parent name
--- @return boolean uic is descended from a component with the supplied name.
function uicomponent_descended_from(uic, parent_name)
	if not is_uicomponent(uic) then
		script_error("ERROR: uicomponent_descended_from() called but supplied uicomponent [" .. tostring(uic) .. "] is not a ui component");
		return false;
	end;
	
	if not is_string(parent_name) then
		script_error("ERROR: uicomponent_descended_from() called but supplied parent name [" .. tostring(parent_name) .. "] is not a string");
		return false;
	end;
	
	local uic_parent = uic;
	local name = uic_parent:Id();
	
	while name ~= "root" do
		if name == parent_name then
			return true;
		end;
		
		uic_parent = UIComponent(uic_parent:Parent());
		name = uic_parent:Id();
	end;
	
	return false;	
end;


--- @function uicomponent_to_str
--- @desc Converts a uicomponent to a string showing its path, for output purposes.
--- @p uicomponent subject uic
--- @return string output
function uicomponent_to_str(uic)
	if not is_uicomponent(uic) then
		return "";
	end;
	
	if uic:Id() == "root" then
		return "root";
	else
		local parent = uic:Parent();
		
		if parent then
			return uicomponent_to_str(UIComponent(parent)) .. " > " .. uic:Id();
		else
			-- this can happen if a click has resulted in some uicomponents being destroyed
			return uic:Id();
		end;
	end;	
end;


--- @function output_uicomponent
--- @desc Outputs extensive debug information about a supplied uicomponent to the <code>Lua - UI</code> console spool.
--- @p uicomponent subject uic, Subject uicomponent.
--- @p [opt=false] boolean omit children, Do not show information about the uicomponent's children.
function output_uicomponent(uic, omit_children)
	if not is_uicomponent(uic) then
		script_error("ERROR: output_uicomponent() called but supplied object [" .. tostring(uic) .. "] is not a ui component");
		return;
	end;
	
	-- not sure how this can happen, but it does ...
	if not pcall(function() out.ui("uicomponent " .. tostring(uic:Id()) .. ":") end) then
		out.ui("output_uicomponent() called but supplied component seems to not be valid, so aborting");
		return;
	end;
	
	out.ui("");
	out.ui("path from root:\t\t" .. uicomponent_to_str(uic));
	
	if __game_mode == __lib_type_campaign then
		out.inc_tab("ui");
	end;
	
	local pos_x, pos_y = uic:Position();
	local size_x, size_y = uic:Bounds();

	out.ui("position on screen:\t" .. tostring(pos_x) .. ", " .. tostring(pos_y));
	out.ui("size:\t\t\t" .. tostring(size_x) .. ", " .. tostring(size_y));
	out.ui("state:\t\t" .. tostring(uic:CurrentState()));
	out.ui("visible:\t\t" .. tostring(uic:Visible()));
	out.ui("priority:\t\t" .. tostring(uic:Priority()));
	
	if not omit_children then
		out.ui("children:");
		
		if __game_mode == __lib_type_campaign then
			out.inc_tab("ui");
		end;
		
		for i = 0, uic:ChildCount() - 1 do
			local child = UIComponent(uic:Find(i));
			
			out.ui(tostring(i) .. ": " .. child:Id());
		end;
	end;
	
	if __game_mode == __lib_type_campaign then
		out.dec_tab("ui");
		out.dec_tab("ui");
	end;

	out.ui("");
end;


--- @function output_uicomponent_on_click
--- @desc Starts a listener which outputs debug information to the <code>Lua - UI</code> console spool about every uicomponent that's clicked on.
function output_uicomponent_on_click()	
	out.ui("*** output_uicomponent_on_click() called ***");
	
	core:add_listener(
		"output_uicomponent_on_click",
		"ComponentLClickUp",
		true,
		function(context) output_uicomponent(UIComponent(context.component), true) end,
		true
	);
end;


--- @function print_all_uicomponent_children
--- @desc Prints the name and path of the supplied uicomponent and all its descendents. Very verbose, and can take a number of seconds to complete.
--- @p uicomponent subject uic, Subject uicomponent.
function print_all_uicomponent_children(uic)
	out.ui(uicomponent_to_str(uic));
	for i = 0, uic:ChildCount() - 1 do
		local uic_child = UIComponent(uic:Find(i));
		print_all_uicomponent_children(uic_child);
	end;
end;


--- @function pulse_uicomponent
--- @desc Activates or deactivates a pulsing highlight effect on the supplied uicomponent. This is primarily used for scripts which activate when the player moves the mouse cursor over certain words in the help pages, to indicate to the player what UI feature is being talked about on the page.
--- @p @uicomponent ui component, Subject ui component.
--- @p [opt=true] @boolean should pulse, Set to <code>true</code> to activate the pulsing effect, <code>false</code> to deactivate it.
--- @p [opt=0] @number brightness, Pulse brightness. Set a higher number for a more pronounced pulsing effect.
--- @p [opt=false] @boolean progagate, Propagate the effect through the component's children. Use this with care, as the visual effect can stack and often it's better to activate the effect on specific uicomponents instead of activating this.
--- @p [opt=nil] @string state name, Optional state name to affect. If a string name is supplied, the pulsing effect is only applied to the specified state instead of to all states on the component.
function pulse_uicomponent(uic, should_pulse, brightness_modifier, propagate, state_name)

	if not is_uicomponent(uic) then
		script_error("ERROR: pulse_uicomponent() called but supplied component [" .. tostring(uic) .. "] is not a uicomponent");
		return false;
	end;

	brightness_modifier = brightness_modifier or 0;
	silent = silent or false;

	if state_name and not is_string(state_name) then
		script_error("ERROR: pulse_uicomponent() called but supplied state name [" .. tostring(state_name) .. "] is not a string or nil");
		return false;
	end;

	if not is_uicomponent(uic) then
		script_error("ERROR: pulse_uicomponent() called but supplied uicomponent [" .. tostring(uic) .. "] is not a ui component");
		return false;
	end;
	
	if should_pulse == false then
		if state_name then
			uic:StopPulseHighlight(state_name);
		else
			uic:StopPulseHighlight();
		end;
	else
		if state_name then
			uic:StartPulseHighlight(brightness_modifier, state_name);
		else
			uic:StartPulseHighlight(brightness_modifier);
		end;
	end;
	
	if propagate then
		for i = 0, uic:ChildCount() - 1 do
			pulse_uicomponent(UIComponent(uic:Find(i)), should_pulse, brightness_modifier, propagate, state_name);
		end;
	end;
end;


--- @function is_fully_onscreen
--- @desc Returns true if the uicomponent is fully on-screen, false otherwise.
--- @p @uicomponent uicomponent
--- @return @boolean is onscreen
function is_fully_onscreen(uicomponent)
	local screen_x, screen_y = core:get_screen_resolution();
	
	local min_x, min_y = uicomponent:Position();
	local size_x, size_y = uicomponent:Bounds();
	local max_x = min_x + size_x;
	local max_y = min_y + size_y;
	
	return min_x >= 0 and max_x <= screen_x and min_y >= 0 and max_y <= screen_y;	
end;


--- @function is_partially_onscreen
--- @desc Returns true if the uicomponent is partially on-screen, false otherwise.
--- @p @uicomponent uicomponent
--- @return @boolean is onscreen
function is_partially_onscreen(uicomponent)
	local screen_x, screen_y = core:get_screen_resolution();
	
	local min_x, min_y = uicomponent:Position();
	local size_x, size_y = uicomponent:Bounds();
	local max_x = min_x + size_x;
	local max_y = min_y + size_y;
	
	return ((min_x >= 0 and min_x <= screen_x) or (max_x >= 0 and max_x <= screen_x)) and ((min_y >= 0 and min_y <= screen_y) or (max_y >= 0 and max_y <= screen_y));	
end;




--- @function set_component_visible
--- @desc Sets a uicomponent visible or invisible by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set visible
--- @p ... list of string names
function set_component_visible(visible, ...)
	local parent = core:get_ui_root();

	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		uic:SetVisible(not not visible);
	end;
end;


--- @function set_component_visible_with_parent
--- @desc Sets a uicomponent visible or invisible by its path. The path should be one or more strings which when sequentially searched for from a supplied uicomponent parent lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set visible
--- @p uicomponent parent uicomponent
--- @p ... list of string names
function set_component_visible_with_parent(visible, parent, ...)
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list)

	if is_uicomponent(uic) then
		uic:SetVisible(not not visible);
	end;
end;


--- @function set_component_active
--- @desc Sets a uicomponent to be active or inactive by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set active
--- @p ... list of string names
function set_component_active(is_active, ...)
	local parent = core:get_ui_root();
	
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		set_component_active_action(is_active, uic);
	end;
end;


--- @function set_component_active_with_parent
--- @desc Sets a uicomponent to be active or inactive by its path. The path should be one or more strings which when sequentially searched for from a supplied uicomponent parent lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set active
--- @p uicomponent parent uicomponent
--- @p ... list of string names
function set_component_active_with_parent(is_active, parent, ...)
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		set_component_active_action(is_active, uic);
	end;
end;


-- for internal use
function set_component_active_action(is_active, uic)
	local active_str = nil;
	
	if is_active then
		active_str = "active";
	else
		active_str = "inactive";
	end;

	uic:SetState(active_str);
end;


--- @function highlight_component
--- @desc Highlights or unhighlights a uicomponent by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean activate highlight, Set <code>true</code> to activate the highlight, <code>false</code> to deactivate.
--- @p boolean is square, Set to <code>true</code> if the target uicomponent is square, <code>false</code> if it's circular.
--- @p ... list of string names
function highlight_component(value, is_square, ...)
	return highlight_component_action(false, value, is_square, unpack(arg));
end;


--- @function highlight_visible_component
--- @desc Highlights or unhighlights a uicomponent by its path, but only if it's visible. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean activate highlight, Set <code>true</code> to activate the highlight, <code>false</code> to deactivate.
--- @p boolean is square, Set to <code>true</code> if the target uicomponent is square, <code>false</code> if it's circular.
--- @p ... list of string names
function highlight_visible_component(value, is_square, ...)
	return highlight_component_action(true, value, is_square, unpack(arg));
end;


function highlight_component_action(visible_only, value, is_square, ...)
	local uic = find_uicomponent_from_table(core:get_ui_root(), arg, true);
	
	if is_uicomponent(uic) then
		if not visible_only or uic:Visible() then
			uic:Highlight(value, is_square, 0);
		end;
		return true;
	end;
	
	return false;
end;


--- @function highlight_all_visible_children
--- @desc Draws a box highlight around all visible children of the supplied uicomponent. A padding value in pixels may also be supplied to increase the visual space between the highlight and the components being highlighted.
--- @p uicomponent parent
--- @p [opt=0] number visual padding
function highlight_all_visible_children(uic, padding)
	
	if not is_uicomponent(uic) then
		script_error("ERROR: highlight_all_visible_children() called but supplied uicomponent [" .. tostring(uic) .. "] is not a uicomponent");
		return false;
	end;
	
	padding = padding or 0;
	
	local components_to_highlight = {};
	
	for i = 0, uic:ChildCount() - 1 do
		local uic_child = UIComponent(uic:Find(i));
			
		if uic_child:Visible() then
			table.insert(components_to_highlight, uic_child);
		end;
	end;
	
	highlight_component_table(padding, unpack(components_to_highlight));
end;


--- @function unhighlight_all_visible_children
--- @desc Cancels any and all highlights created with @global:highlight_all_visible_children.
function unhighlight_all_visible_children()
	unhighlight_component_table();
end;


--- @function highlight_component_table
--- @desc Draws a box highlight stretching around the supplied list of components. A padding value in pixels may also be supplied to increase the visual space between the highlight and the components being highlighted.
--- @p number visual padding, Visual padding in pixels.
--- @p ... uicomponents, Variable number of uicomponents to draw highlight over.
function highlight_component_table(padding, ...)
	
	local component_list = arg;

	if not is_number(padding) or padding < 0 then
		-- if the first parameter is a uicomponent then insert it at the start of our component list
		if is_uicomponent(padding) then
			table.insert(component_list, 1, padding);
			padding = 0;
		else
			script_error("ERROR: highlight_component_table() called but supplied padding value [" .. tostring(padding) .. "] is not a positive number (or a uicomponent)");
			return false;
		end;
	end;
	
	local min_x = 10000000;
	local min_y = 10000000;
	local max_x = 0;
	local max_y = 0;
	
	for i = 1, #component_list do
		local current_component = component_list[i];
		
		if not is_uicomponent(current_component) then
			script_error("ERROR: highlight_component_table() called but parameter " .. i .. " in supplied list is a [" .. tostring(current_component) .. "] and not a uicomponent");
			return false;
		end;
		
		local current_min_x, current_min_y = current_component:Position();
		local size_x, size_y = current_component:Dimensions();
		
		local current_max_x = current_min_x + size_x;
		local current_max_y = current_min_y + size_y;
		
		if current_min_x < min_x then
			min_x = current_min_x;
		end;
		
		if current_min_y < min_y then
			min_y = current_min_y;
		end;
		
		if current_max_x > max_x then
			max_x = current_max_x;
		end;
		
		if current_max_y > max_y then
			max_y = current_max_y;
		end;
	end;
	
	-- apply padding
	min_x = min_x - padding;
	min_y = min_y - padding;
	max_x = max_x + padding;
	max_y = max_y + padding;
	
	-- create the dummy component if we don't already have one lurking around somewhere
	local ui_root = core:get_ui_root();
	
	local uic_dummy = find_uicomponent(ui_root, "highlight_dummy");
	
	if not uic_dummy then
		ui_root:CreateComponent("highlight_dummy", core.path_to_dummy_component);
		uic_dummy = find_uicomponent(ui_root, "highlight_dummy");
	end;
	
	if not uic_dummy then
		script_error("ERROR: highlight_component_table() cannot find uic_dummy, how can this be?");
		return false;
	end;
	
	-- resize and move the dummy
	local size_x = max_x - min_x;
	local size_y = max_y - min_y;
	
	-- uic_dummy:SetMoveable(true);
	uic_dummy:MoveTo(min_x, min_y);
	uic_dummy:Resize(size_x, size_y);
	
	local new_pos_x, new_pos_y = uic_dummy:Position();
	
	uic_dummy:Highlight(true, true, 0);
end;


--- @function unhighlight_component_table
--- @desc Cancels any and all highlights created with @global:highlight_component_table.
function unhighlight_component_table()
	highlight_component(false, true, "highlight_dummy");
end;


--- @function play_component_animation
--- @desc Plays a specified component animation on a uicomponent by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p string animation name
--- @p ... list of string names
function play_component_animation(animation, ...)
	
	local uic = find_uicomponent_from_table(core:get_ui_root(), arg, true);
	
	if is_uicomponent(uic) then
		uic:TriggerAnimation(animation);
	end;
end;
















----------------------------------------------------------------------------
---	@section Advisor Progress Button
----------------------------------------------------------------------------


--- @function get_advisor_progress_button
--- @desc Returns the advisor progress/close button uicomponent.
--- @return uicomponent
function get_advisor_progress_button()
	local uic_progress_button = false;
		
	if __game_mode == __lib_type_battle then
		uic_progress_button = find_uicomponent(core:get_ui_root(), "advice_interface", "button_close");
	elseif __game_mode == __lib_type_campaign then
		uic_progress_button = find_uicomponent(core:get_ui_root(), "advice_interface", "button_close");
	else
		script_error("ERROR: get_advisor_progress_button() called in frontend");
		return false;
	end;
	
	if not uic_progress_button then
		script_error("ERROR: get_advisor_progress_button() called but couldn't find advisor button");
		return false;
	end;
	
	return uic_progress_button;
end;


--- @function show_advisor_progress_button
--- @desc Shows or hides the advisor progress/close button.
--- @p [opt=true] boolean show button
function show_advisor_progress_button(value)
	if value ~= false then
		value = true;
	end;
		
	local uic_button = get_advisor_progress_button();
	
	if uic_button then
		uic_button:SetVisible(value);
	end;
	
	-- enable or disable the advisor button on the menu bar
	set_component_active(value, "menu_bar", "button_show_advice");
end;


--- @function highlight_advisor_progress_button
--- @desc Activates or deactivates a highlight on the advisor progress/close button.
--- @p [opt=true] boolean show button
function highlight_advisor_progress_button(value)
	if __game_mode == __lib_type_frontend then
		script_error("ERROR: highlight_advisor_progress_button() called when not in battle or campaign");
		return false;
	end;
	
	highlight_component(value, false, "advice_interface", "button_close");
	set_component_visible(value, "advice_interface", "tut_anim");
end;




