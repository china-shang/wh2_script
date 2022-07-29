



----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN MISSION MANAGER
--
---	@loaded_in_campaign
---	@class mission_manager mission_manager Mission Managers
--- @desc Mission managers can be used to set up and manage scripted missions issued to the player. It isn't necessary to set up a mission manager in order to trigger a scripted mission, but they provide certain benefits:
--- @desc <ul><li>Success, failure, cancellation and nearing-expiry callbacks may be registered with the mission manager, which calls these when the mission reaches a certain state.</li>
--- @desc <li>Missions in the game may be triggered from a mission string - the mission manager offers easy methods to construct such a string.</li>
--- @desc <li>Missions may be set up with scripted objectives - success and/or fail conditions that are triggered by script, allowing mission completion conditions to be implemented of arbitrary complexity, or that aren't supported natively by the game. Mission managers provide a framework for allowing this to be set up relatively easily.</li>
--- @desc <li>Mission managers may be set up with first time and each time startup callbacks (see @mission_manager:set_first_time_startup_callback and @mission_manager:set_each_time_startup_callback for more details) allowing other scripts to be started while the mission is running.</li></ul>
--- @desc Mission managers can also be used to trigger incidents and dilemmas.
--
--- @section Different Methods of Specifying Objectives
--- @desc Most missions are only composed of one individual objective, but more than one is supported (chapter missions tend to have more). The objectives that make up a mission may be specified in one of three ways:
--- @desc <ul><li>A mission may be constructed from a mission string. Refer to the section on @"mission_manager:Constructing From Strings" to see how to do this.
--- @desc <ul><li>Mission objectives may be scripted, which means that it is the responsibility of script to monitor completion/failure conditions and notify the game. Scripted objectives may be set up using the functions in the @"mission_manager:Scripted Objectives" section. Scripted objectives are constructed internally from a mission string and as such can't be combined with mission records from the database or missions.txt file (see following points).</li></ul></li>
--- @desc <li>A mission may build its objectives from records in the database (see the <code>cdir_events_mission_option_junctions</code> table). To set a mission to build its objectives from the database set it to trigger from the database with @mission_manager:set_is_mission_in_db, @mission_manager:set_is_incident_in_db or @mission_manager:set_is_dilemma_in_db and do not add any text objectives (see @mission_manager:add_new_objective).</li>
--- @desc <li>Mission strings may also be baked into the missions.txt file that accompanies each campaign. This is the default option, but arguably the least desirable and flexible.</li></ul>
--
--- @section Persistence
--- @desc If a mission manager has been set up with a success, failure, cancellation or nearing-expiry callback with @mission_manager:new, or if it has been set up with one or more @"mission_manager:Scripted Objectives" with @mission_manager:add_new_scripted_objective, then it is classified as persistent. Persistent mission managers must have unique names, and must be declared and set up in the root of the script somewhere, as they are restarted when the script loads from a savegame.
--- @desc Additionally, a mission manager will need to be set up in the root of the script somewhere if an each-time-startup callback needs to be called - see @mission_manager:set_each_time_startup_callback.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


mission_manager = {
	faction_name = "",
	mission_key = "",
	started = false,
	completed = false,
	first_time_startup_callback = nil,
	each_time_startup_callback = nil,
	success_callback = nil,
	failure_callback = nil,
	cancellation_callback = nil,
	nearing_expiry_callback = nil,
	is_mission_when_triggering_from_db = true,
	is_incident_when_triggering_from_db = false,
	is_dilemma_when_triggering_from_db = false,
	is_dilemma_in_intervention = false,
	should_whitelist = true,
	
	-- for triggering from string
	should_trigger_from_string = false,
	should_trigger_from_db = false,
	mission_issuer = "CLAN_ELDERS",
	turn_limit = false,			-- set to a number to activate
	objectives = {},
	mission_string = "",
	is_registered = false,
	should_cancel_before_issuing_override = true,
	chapter_mission = false, 	-- set to number to activate
	
	-- for scripted mission types
	scripted_objectives = {}
};







----------------------------------------------------------------------------
--- @section Creation
----------------------------------------------------------------------------


--- @function new
--- @desc Creates a mission manager object. A faction name for the mission recipient and a mission key must be specified at the very least. The mission key must match a record in the <code>missions</code> table, which must be present in all cases.
--- @desc A mission success callback, a mission failure callback, a mission cancellation callback and a mission nearing-expiry callback may optionally also be specified. Setting any of these also sets the mission to be persistent, which creates extra requirements for how the mission manager is declared - see the section above on @mission_manager:Persistence.
--- @p string faction name, Name of faction that will be receiving this mission.
--- @p string mission key, Key corresponding to a record in the <code>missions</code> table.
--- @p [opt=nil] function success callback, Callback to call if the mission is successfully completed. Setting this makes the mission manager persistent.
--- @p [opt=nil] function failure callback, Callback to call if the mission is failed. Setting this makes the mission manager persistent.
--- @p [opt=nil] function cancellation callback, Callback to call if the mission is cancelled. Setting this makes the mission manager persistent.
--- @p [opt=nil] function nearing-expiry callback, Callback to call if the mission is nearing expiry. Setting this makes the mission manager persistent.
--- @return mission_manager Mission manager object
function mission_manager:new(faction_name, mission_key, success_callback, failure_callback, cancellation_callback, nearing_expiry_callback)
	if not is_string(faction_name) then
		script_error("ERROR: mission_manager:new() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	local faction = cm:get_faction(faction_name);
	
	if not faction then
		script_error("ERROR: mission_manager:new() called but couldn't find a faction with supplied name [" .. faction_name .. "]");
		return false;
	end;
	
	if not faction:is_human() then
		script_error("ERROR: mission_manager:new() called but faction with supplied name [" .. faction_name .. "] is not human");
		return false;
	end;

	if not is_string(mission_key) then
		script_error("ERROR: mission_manager:new() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: mission_manager:new() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(failure_callback) and not is_nil(failure_callback) then
		script_error("ERROR: mission_manager:new() called but supplied failure callback [" .. tostring(failure_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(cancellation_callback) and not is_nil(cancellation_callback) then
		script_error("ERROR: mission_manager:new() called but supplied cancellation callback [" .. tostring(cancellation_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(nearing_expiry_callback) and not is_nil(nearing_expiry_callback) then
		script_error("ERROR: mission_manager:new() called but supplied nearing-expiry callback [" .. tostring(nearing_expiry_callback) .. "] is not a function or nil");
		return false;
	end;
	
	local mm = {};
	
	setmetatable(mm, self);
	self.__tostring = function() return TYPE_MISSION_MANAGER end;
	self.__index = self;
	
	mm.faction_name = faction_name;
	mm.mission_key = mission_key;
	mm.objectives = {};
	mm.scripted_objectives = {};
	
	mm.success_callback = success_callback;
	mm.failure_callback = failure_callback;
	mm.cancellation_callback = cancellation_callback;
	mm.nearing_expiry_callback = nearing_expiry_callback;
	
	-- If any of the success/failure/etc callbacks are set then set this mission manager to be persistent and register it with the campaign manager.
	-- A not-persistent mission manager supports multiple missions of the same key being triggered, but doesn't support any
	-- success/failure callbacks as the script/code cannot tell the difference between two missions with the same key. Furthermore,
	-- the mission manager state doesn't get saved into the savegame (the mission itself does, however). In this case, the mission
	-- manager is still useful to allow the scripter easy set up of a mission string.
	-- If a mission manager is later set up with a scripted objective, this also sets the mission to be persistent/saved into the
	-- savegame, with the same restriction of not allowing multiple missions with the same key.
	if success_callback or failure_callback or cancellation_callback or nearing_expiry_callback then
		mm:register();
	end;
	
	return mm;
end;


-- Internal function to register this mission manager with the campaign manager so that its state gets saved.
-- This is called by mission managers which have completion callbacks or scripted objectives set.
function mission_manager:register()
	if not self.is_registered then
	
		if cm:get_mission_manager(self.mission_key) then
			script_error("ERROR: mission_manager:register() was called but a mission with supplied key [" .. tostring(mission_key) .. "] has already been registered. You cannot register more than one persistent mission with the same mission key. Persistent missions are missions with some manner of completion callback, or a mission with a scripted objective.");
		else
			cm:register_mission_manager(self);
			self.is_registered = true;
		end;
	end;
end;







----------------------------------------------------------------------------
---	@section Usage
--- @desc Once a <code>mission_manager</code> object has been created with @mission_manager:new, functions on it may be called in the form showed below.
--- @new_example Specification
--- @example <i>&lt;mission_manager_object&gt;</i>:<i>&lt;function_name&gt;</i>(<i>&lt;args&gt;</i>)
--- @new_example Creation and Usage
--- @example local mm_emp_05 = mission_manager:new("wh_main_emp_empire", "wh_empire_mission_05");
--- @example 
--- @example -- calling a function on the object once created
--- @example mm_emp_05:set_first_time_startup_callback(function() out("mm_emp_05 starting") end)
----------------------------------------------------------------------------






----------------------------------------------------------------------------
--- @section Global Configuration Options
--- @desc The functions in this section apply changes to the behaviour of the mission manager regardless of the type of mission being triggered.
----------------------------------------------------------------------------


--- @function set_should_cancel_before_issuing
--- @desc When it goes to trigger the mission manager will, if the mission is persistent (see @mission_manager:Persistence), issue a call to cancel any mission with the key specified in @mission_manager:new before issuing its mission. This behaviour can be disabled, or enabled for non-persistent missions, by calling this function.
--- @p [opt=true] boolean cancel before issuing
function mission_manager:set_should_cancel_before_issuing(value)
	if value == false then
		self.should_cancel_before_issuing_override = false;
	else
		self.should_cancel_before_issuing_override = true;
	end;
end;


--- @function set_should_whitelist
--- @desc When it goes to trigger the mission manager will, by default, add the relevant mission/dilemma/incident type to the event whitelist so that it triggers even if event messages are currently suppressed (see @campaign_manager:suppress_all_event_feed_messages). Use this function to disable this behaviour, if required.
--- @p [opt=true] boolean should whitelist
function mission_manager:set_should_whitelist(value)
	if value == false then
		self.should_whitelist = false;
	else
		self.should_whitelist = true;
	end;
end;










----------------------------------------------------------------------------
--- @section Startup Callbacks
----------------------------------------------------------------------------


--- @function set_first_time_startup_callback
--- @desc Specifies a callback to call, one time, when the mission is first triggered. This can be used to set up other scripts or game objects for this mission.
--- @p function callback
function mission_manager:set_first_time_startup_callback(first_time_startup_callback)
	if not is_function(first_time_startup_callback) then
		script_error("ERROR: set_first_time_startup_callback() called but supplied callback [" .. tostring(first_time_startup_callback) .. "] is not a function");
		return false;
	end;
	
	self.first_time_startup_callback = first_time_startup_callback;
end;


--- @function set_each_time_startup_callback
--- @desc Specifies a callback to call each time the script is started while this mission is active - after the mission is first triggered and before it's completed. This can be used to set up other scripts or game objects for this mission each time the script is loaded. If registered, this callback is also called when the mission is first triggered, albeit after any callback registered with @mission_manager:set_first_time_startup_callback.
--- @p function callback
function mission_manager:set_each_time_startup_callback(each_time_startup_callback)
	if not is_function(each_time_startup_callback) then
		script_error("ERROR: set_each_time_startup_callback() called but supplied callback [" .. tostring(each_time_startup_callback) .. "] is not a function");
		return false;
	end;
	
	self.each_time_startup_callback = each_time_startup_callback;
end;











----------------------------------------------------------------------------
--- @section Constructing From Strings
--- @desc Mission managers provide a mode where the mission being triggered is constructed from a @string. Example of such strings can be found in the <code>missions.txt</code> found in <code>data/campaigns/&lt;campaign_name&gt;/</code> for some campaigns. The main advantage of constructing missions from strings is that their initial setup may be dynamically constructed depending on game conditions at the time.
--- @desc If new objectives are added with @mission_manager:add_new_objective then the mission manager will be set to construct its mission with a string. It will subsequently attempt to construct the mission specification string when the mission is later triggered, with only the properties set in the <code>missions</code> table remaining immutable. The functions in this section are used to tell the mission manager what to put in the mission construction string.
--- @desc @mission_manager:add_new_objective is called to add a new objective to the mission. The first objective added is the primary objective; any further objectives added are treated as secondary/bonus objectives. Objective configuration functions such as @mission_manager:add_condition and @mission_manager:add_payload act on the most recently-added objective, so the ordering of these setup functions is important. At the very least at least one objective and one payload should be set using the functions below before the mission manager is triggered.
----------------------------------------------------------------------------


--- @function add_new_objective
--- @desc Adds a new objective type to the mission specification, and also sets the mission manager to construct its mission from a string.
--- @desc Multiple objectives may be added to a mission with this function. The first shall be the primary objective of the mission, while subsequent additions shall be set up as secondary objectives.
--- @p string objective type
--- @example mm:add_new_objective("CONSTRUCT_N_BUILDINGS_FROM")
function mission_manager:add_new_objective(objective_type)
	if not is_string(objective_type) then
		script_error("ERROR: add_new_objective() called on mission manager for mission key [" .. self.mission_key .. "] but supplied objective type [" .. tostring(objective_type) .. "] is not a string");
		return false;
	end;
	
	local objective_record = {};
	objective_record.objective_type = objective_type;
	objective_record.conditions = {};
	objective_record.payloads = {};
	objective_record.failure_payloads = {};
	
	table.insert(self.objectives, objective_record);
	
	self.should_trigger_from_string = true;
end;


--- @function add_condition
--- @desc Adds a condition to the objective last added with @mission_manager:add_new_objective. Multiple conditions are commonly added - each objective type has different mandatory and optional conditions.
--- @p string condition
--- @example mm:add_condition("total 1")
--- @example mm:add_condition("building_level wh_main_emp_port_2")
function mission_manager:add_condition(condition)
	if not is_string(condition) then
		script_error("ERROR: add_condition() called on mission manager for mission key [" .. self.mission_key .. "] but supplied objective condition [" .. tostring(condition) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_condition() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	table.insert(self.objectives[#self.objectives].conditions, condition);
end;


--- @function add_payload
--- @desc Adds a payload (reward) to the objective last added with @mission_manager:add_new_objective. Many different payload types exists - the following list is pulled from code: <code>faction_pooled_resource_transaction, add_mercenary_to_faction_pool, adjust_loyalty_for_faction, province_slaves_change, faction_slaves_change, money, influence, honour, grant_unit, grant_agent, effect_bundle, rebellion, demolish_chain, damage_buildings, damage_character, building_restriction, unit_restriction, issue_mission,</code> and <code>game_victory</code>. Each has a different parameter requirement - see existing examples or a programmer for more information.
--- @p string payload
--- @new_example Adding money as a mission reward
--- @example mm:add_payload("money 1000")
--- @new_example Adding a pooled resource as a mission reward
--- @example mm:add_payload("faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount 10;}")
--- @new_example Adding influence as a mission reward
--- @example mm:add_payload("influence 5")
--- @new_example Adding effect bundle as a mission reward
--- @example mm:add_payload("effect_bundle{bundle_key wh_dlc06_bundle_eight_peaks_recapture;turns 0;}")
function mission_manager:add_payload(payload)
	if not is_string(payload) then
		script_error("ERROR: add_payload() called on mission manager for mission key [" .. self.mission_key .. "] but supplied payload [" .. tostring(payload) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_payload() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	table.insert(self.objectives[#self.objectives].payloads, payload);
end;

--- @function add_failure_payload
--- @desc Adds a payload (on mission faiure) to the objective last added with @mission_manager:add_new_objective. Many different payload types exists - the following list is pulled from code: <code>faction_pooled_resource_transaction, add_mercenary_to_faction_pool, adjust_loyalty_for_faction, province_slaves_change, faction_slaves_change, money, influence, honour, grant_unit, grant_agent, effect_bundle, rebellion, demolish_chain, damage_buildings, damage_character, building_restriction, unit_restriction, issue_mission,</code> and <code>game_victory</code>. Each has a different parameter requirement - see existing examples or a programmer for more information.
--- @p string payload
--- @new_example Taking away money as a mission failure
--- @example mm:add_failure_payload("money -1000")
--- @new_example Taking away a pooled resource as a mission failure
--- @example mm:add_failure_payload("faction_pooled_resource_transaction{resource dwf_oathgold;factor wh2_main_resource_factor_missions;amount -10;}")
--- @new_example Decreasing influence as a mission failure
--- @example mm:add_failure_payload("influence -5")
--- @new_example Adding effect bundle as a mission failure
--- @example mm:add_failure_payload("effect_bundle{bundle_key wh_dlc06_bundle_eight_peaks_recapture;turns 0;}")
function mission_manager:add_failure_payload(payload)
	if not is_string(payload) then
		script_error("ERROR: add_failure_payload() called on mission manager for mission key [" .. self.mission_key .. "] but supplied payload [" .. tostring(payload) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_failure_payload() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;

	table.insert(self.objectives[#self.objectives].failure_payloads, payload);
end;

--- @function add_heading
--- @desc Adds a heading key override for the objective last added with @mission_manager:add_new_objective. This should be supplied as a string in the full localised text format <code>[table]_[field]_[record]</code>.
--- @p string heading key
function mission_manager:add_heading(heading)
	if not is_string(heading) then
		script_error("ERROR: add_heading() called on mission manager for mission key [" .. self.mission_key .. "] but supplied heading key [" .. tostring(heading) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_heading() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	self.objectives[#self.objectives].heading = heading;
end;


--- @function add_description
--- @desc Adds a description key override for the objective last added with @mission_manager:add_new_objective. This should be supplied as a string in the full localised text format <code>[table]_[field]_[record]</code>.
--- @p string description key
function mission_manager:add_description(description)
	if not is_string(description) then
		script_error("ERROR: add_description() called on mission manager for mission key [" .. self.mission_key .. "] but supplied description key [" .. tostring(description) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_description() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	self.objectives[#self.objectives].description = description;
end;


--- @function set_turn_limit
--- @desc Sets a turn limit for the entire mission. This is optional.
--- @p number turn limit
--- @new_example Mission expires in 5 turns
--- @example mm:set_turn_limit(5)
function mission_manager:set_turn_limit(turn_limit)
	if not is_number(turn_limit) then
		script_error("ERROR: set_turn_limit() called on mission manager for mission key [" .. self.mission_key .. "] but supplied turn limit [" .. tostring(turn_limit) .. "] is not a number");
		return false;
	end;
	
	self.turn_limit = turn_limit;
end;


--- @function set_chapter
--- @desc Sets this mission to be a particular chapter mission, which affects how it is displayed and categorised on the UI.
--- @p number chapter number
--- @new_example Mission is first chapter mission
--- @example mm:set_chapter(1)
function mission_manager:set_chapter(chapter)
	if not is_number(chapter) then
		script_error("ERROR: set_chapter() called on mission manager for mission key [" .. self.mission_key .. "] but supplied chapter [" .. tostring(chapter) .. "] is not a number");
		return false;
	end;
	
	self.chapter_mission = chapter;
end;


--- @function set_mission_issuer
--- @desc Sets an issuer for this mission, which determines some aspects of the mission's presentation. By default this is set to "CLAN_ELDERS", but use this function to change this. A list of valid mission issuers can be found in the <code>mission_issuers</code> table.
--- @p string mission issuer
function mission_manager:set_mission_issuer(issuer)
	if not is_string(issuer) then
		script_error("ERROR: set_mission_issuer() called on mission manager for mission key [" .. self.mission_key .. "] but supplied issuer [" .. tostring(issuer) .. "] is not a string");
		return false;
	end;
	
	self.mission_issuer = issuer;
end;










----------------------------------------------------------------------------
--- @section Scripted Objectives
--- @desc Missions may contain scripted objectives, where the script is responsible for their monitoring and completion. Scripted objectives are constructed from strings, and set the mission manager into a mode where it will construct all its objectives in this way. As such they cannot be used in combination with objectives from the database or from the missions.txt file.
--- @desc A scripted objective may be added to the mission manager with @mission_manager:add_new_scripted_objective, which sets some display text and an initial success monitor - some script which determines when the mission has been succeeded. Once a scripted objective has been added, additional success or failure monitors may be added with @mission_manager:add_scripted_objective_success_condition and @mission_manager:add_scripted_objective_failure_condition.
--- @desc Scripted objectives may also be forceably succeeded or failed by external scripts calling @mission_manager:force_scripted_objective_success or @mission_manager:force_scripted_objective_failure, and their displayed text may be updated with @mission_manager:update_scripted_objective_text.
--- @desc If multiple scripted objectives are to be added they may optionally be individually named by giving them a script key. This allows individual target objectives to be specified when calling @mission_manager:add_scripted_objective_success_condition, @mission_manager:add_scripted_objective_failure_condition, @mission_manager:force_scripted_objective_success or @mission_manager:force_scripted_objective_failure, which will otherwise just target the first scripted objective in the mission.
--- @desc As mentioned in the section on @mission_manager:Persistence, setting a scripted objective forces the mission manager to be persistent, which means it must have a unique key and must be set up somewhere in the root of the script so that it's declared by the time the first tick happens after loading.
----------------------------------------------------------------------------


--- @function add_new_scripted_objective
--- @desc Adds a new scripted objective, along with some text to display, a completion event and condition to monitor. An optional script name for this objective may also be specified, which can be useful if there is more than one objective.
--- @p string display text, Display text for this objective. This should be supplied as a full localisation key, i.e. <code>[table]_[field]_[key]</code>.
--- @p string event, Script event name of mission success condition.
--- @p function condition, A function that returns a boolean value when called. The function will be passed the context of the event specified in the second parameter. Alternatively, if no conditional test needs to be performed then <code>true</code> may be supplied in place of a function block.
--- @p_long_desc While the mission is active the mission manager listens for the event specified in the second parameter. When it is received, the condition specified here is called. If it returns <code>true</code>, or if <code>true</code> was specified in place of a condition function, the mission objective is marked as being successfully completed.
--- @p [opt=nil] string script name, Script name for this objective. If specified, this allows calls to @mission_manager:add_scripted_objective_success_condition, @mission_manager:add_scripted_objective_failure_condition, @mission_manager:force_scripted_objective_success or @mission_manager:force_scripted_objective_failure to target this objective (they target the first objective by default).
--- @new_example
--- @desc An example scripted objective that is completed when the player researches a technology.
--- @example mm:add_new_scripted_objective(
--- @example 	"mission_text_text_research_technology_mission_objective",
--- @example 	"ResearchCompleted",
--- @example 	function(context)
--- @example 		return context:faction():name() == cm:get_local_faction_name();
--- @example 	end;
--- @example );
function mission_manager:add_new_scripted_objective(override_text, event, condition, script_key)

	if not is_string(override_text) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied override text key [" .. tostring(override_text) .. "] is not a string");
		return false;
	end;
	
	if not is_string(event) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied event name (" .. tostring(event) .. ") is not a string");
		return false;
	end;
	
	if not is_function(condition) and not is_boolean(condition) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied condition (" .. tostring(condition) .. ") is not a string or a boolean");
		return false;
	end;
	
	script_key = script_key or (self.mission_key .. "_" .. tostring(cm:get_unique_counter_for_missions()));
		
	local objective_record = {
		["script_key"] = script_key,
		["is_completed"] = false,
		["success_conditions"] = {},
		["failure_conditions"] = {}
	};
	
	table.insert(self.scripted_objectives, objective_record);
	
	self:add_new_objective("SCRIPTED");
	self:add_condition("script_key " .. script_key);
	self:add_condition("override_text " .. override_text);
	
	self:add_scripted_objective_success_condition(event, condition, script_key);
	
	-- register this mission manager as persistent
	self:register();
end;


--- @function add_scripted_objective_success_condition
--- @desc Adds a new success condition to a scripted objective. scripted objective. If a script key is specified the success condition is added to the objective with this key (assuming it exists), otherwise the success condition is added to the first scripted objective.
--- @p string event, Script event name of mission success condition.
--- @p function condition, A function that returns a boolean value when called. The function will be passed the context of the event specified in the second parameter. Alternatively, if no conditional test needs to be performed then <code>true</code> may be supplied in place of a function block.
--- @p_long_desc While the mission is active the mission manager listens for the event specified in the second parameter. When it is received, the condition specified here is called. If it returns <code>true</code>, or if <code>true</code> was specified in place of a condition function, the mission objective is marked as being successfully completed.
--- @p [opt=nil] string script name, Script name of the scripted objective to append this success condition to.
function mission_manager:add_scripted_objective_success_condition(event, condition, script_key)
	return self:add_scripted_objective_completion_condition(true, event, condition, script_key);
end;


--- @function add_scripted_objective_failure_condition
--- @desc Adds a new failure condition to a scripted objective. scripted objective. If a script key is specified the failure condition is added to the objective with this key (assuming it exists), otherwise the failure condition is added to the first scripted objective.
--- @p string event, Script event name of mission failure condition.
--- @p function condition, A function that returns a boolean value when called. The function will be passed the context of the event specified in the second parameter. Alternatively, if no conditional test needs to be performed then <code>true</code> may be supplied in place of a function block.
--- @p_long_desc While the mission is active the mission manager listens for the event specified in the second parameter. When it is received, the condition specified here is called. If it returns <code>true</code>, or if <code>true</code> was specified in place of a condition function, the mission objective is marked as being failed.
--- @p [opt=nil] string script name, Script name of the scripted objective to append this failure condition to.
function mission_manager:add_scripted_objective_failure_condition(event, condition, script_key)
	return self:add_scripted_objective_completion_condition(false, event, condition, script_key);
end;


-- internal function
function mission_manager:add_scripted_objective_completion_condition(is_success, event, condition, script_key)

	if not is_boolean(is_success) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied is_success flag [" .. tostring(is_success) .. "] is not a boolean value. Has this function been called directly?");
		return false;
	end;		
	
	if not is_string(event) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied event name [" .. tostring(event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(condition) and condition ~= true then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied condition [" .. tostring(condition) .. "] is not a string or true");
		return false;
	end;
	
	if script_key and not is_string(script_key) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied script_key [" .. tostring(script_key) .. "] is not a string or nil");
		return false;
	end;
	
	local scripted_objectives = self.scripted_objectives;
	local scripted_objective_record = false;
	
	-- support the case that no script_key is supplied
	if not script_key then
	
		-- there must be exactly one scripted objective record registered in this case
		if #scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called with no script_key defined, and there is not exactly one scripted objective record (number of scripted objectives is [" .. #self.scripted_objectives .. "]");
			return false;
		end;
		
		-- take the script_key of the single existing scripted objective record 
		script_key = scripted_objectives[1].script_key;
		
		scripted_objective_record = scripted_objectives[1];
		
	else
		-- find the scripted objective record matching the script_key
		for i = 1, #scripted_objectives do
			if scripted_objectives[i].script_key == script_key then
				scripted_objective_record = scripted_objectives[i];
				break;
			end;
		end;
	
		if not scripted_objective_record then
			script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called with script_key [" .. script_key .. "] but no scripted objective record with this key could be found");
			return false;
		end;
	end;
	
	-- create/add this completion condition record
	local completion_condition_record = {
		["event"] = event,
		["condition"] = condition
	};
	
	if is_success then
		table.insert(scripted_objective_record.success_conditions, completion_condition_record);
	else
		table.insert(scripted_objective_record.failure_conditions, completion_condition_record);
	end;
end;


--- @function force_scripted_objective_success
--- @desc Immediately forces the success of a scripted objective. A particular scripted objective may be specified by supplying a script key, otherwise this function will target the first scripted objective in the mission manager.
--- @desc This should only be called after the mission manager has been triggered.
--- @p [opt=nil] string script name, Script name of the scripted objective to force the success of.
function mission_manager:force_scripted_objective_success(script_key)
	return self:force_scripted_objective_completion(true, script_key);
end;


--- @function force_scripted_objective_failure
--- @desc Immediately forces the failure of a scripted objective. A particular scripted objective may be specified by supplying a script key, otherwise this function will target the first scripted objective in the mission manager.
--- @desc This should only be called after the mission manager has been triggered.
--- @p [opt=nil] string script name, Script name of the scripted objective to force the failure of.
function mission_manager:force_scripted_objective_failure(script_key)
	return self:force_scripted_objective_completion(false, script_key);
end;


-- internal function
function mission_manager:force_scripted_objective_completion(is_success, script_key)
	
	-- support no script_key being supplied - we must have exactly one scripted_objectives record
	if not script_key then
	
		if #self.scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: force_scripted_objective_completion() called with no script_key but the number of registered scripted objectives is not one (it is [" .. #self.scripted_objectives .. "])");
			return false;
		end;
		
		script_key = self.scripted_objectives[1].script_key;
	end;
	
	if is_success then
		cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
		out("~~~ MissionManager :: " .. self.mission_key .. " is being externally forced to successfully complete scripted objective with script key [" .. script_key .. "]");
	else
		cm:complete_scripted_mission_objective(self.mission_key, script_key, false);
		out("~~~ MissionManager :: " .. self.mission_key .. " is being externally forced to fail scripted objective with script key [" .. script_key .. "]");
	end;
	
	core:remove_listener(self.mission_key .. script_key .. "_completion_listener");
end;


--- @function update_scripted_objective_text
--- @desc Updates the displayed objective text of a scripted objective. This can be useful if some counter needs to be updated as progress towards an objective is made. A particular scripted objective may be specified by supplying a script key, otherwise this function will target the first scripted objective in the mission manager.
--- @desc This should only be called after the mission manager has been triggered.
--- @p string display text, Display text for this objective. This should be supplied as a full localisation key, i.e. <code>[table]_[field]_[key]</code>.
--- @p [opt=nil] string script name, Script name of the scripted objective to update the key of.
function mission_manager:update_scripted_objective_text(override_text, script_key)

	if not is_string(override_text) then
		script_error(self.mission_key .. " ERROR: update_scripted_objective_text() called but supplied override text [" .. tostring(override_text) .. "] is not a string");
		return false;
	end;
	
	-- support not supplying a script key if we only have one scripted objective
	if not script_key then
		if #self.scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: update_scripted_objective_text() called with no script_key, but more or less than one scripted objective has been registered (number of registered scripted objectives is [" .. tostring(#self.scripted_objectives) .. "]");
			return false;
		end;
	
		script_key = self.scripted_objectives[1].script_key;
	end;
	
	cm:set_scripted_mission_text(self.mission_key, script_key, override_text);
end;










----------------------------------------------------------------------------
--- @section Sourcing Objectives from Database
--- @desc If the mission manager is not set to generate its objectives from strings then it will fall back to one of two sources - from the missions.txt file which accompanies the campaign data or from database records. By default, the missions.txt file is used as the source of the mission - use @mission_manager:set_is_mission_in_db, @mission_manager:set_is_incident_in_db or @mission_manager:set_is_dilemma_in_db to have the mission manager construct its mission objectives from the database instead. Doing this will require that records are present in various tables such as <code>cdir_events_mission_option_junctions</code> to allow the mission to fire (different but equivalent tables are used if the mission is actually an incident or a dilemma).
----------------------------------------------------------------------------


--- @function set_is_mission_in_db
--- @desc Sets that the mission objectives should be constructed from records in the game database.
function mission_manager:set_is_mission_in_db()
	self.should_trigger_from_db = true;

	self.is_mission_when_triggering_from_db = true;
	self.is_incident_when_triggering_from_db = false;
	self.is_dilemma_when_triggering_from_db = false;
end;


--- @function set_is_incident_in_db
--- @desc Sets that the mission objectives should be constructed from records in the game database, and that the mission is actually an incident.
function mission_manager:set_is_incident_in_db()
	self.should_trigger_from_db = true;

	self.is_mission_when_triggering_from_db = false;
	self.is_incident_when_triggering_from_db = true;
	self.is_dilemma_when_triggering_from_db = false;
end;


--- @function set_is_dilemma_in_db
--- @desc Sets that the mission objectives should be constructed from records in the game database, and that the mission is actually a dilemma.
--- @p [opt=false] @boolean is intervention, Is a dilemma in an intervention. If this is set to <code>true</code>, the dilemma will be triggered directly using @campaign_manager:trigger_dilemma_raw, which can cause softlocks when triggered from outside of an intervention. If set to <code>false</code> or left blank then the dilemma will be triggered in @campaign_manager:trigger_dilemma which attempts to package the dilemma in an intervention.
function mission_manager:set_is_dilemma_in_db(is_in_intervention)
	self.should_trigger_from_db = true;

	self.is_mission_when_triggering_from_db = false;
	self.is_incident_when_triggering_from_db = false;
	self.is_dilemma_when_triggering_from_db = true;

	if is_in_intervention then
		self.is_dilemma_in_intervention = true;
	else
		self.is_dilemma_in_intervention = false;
	end;
end;










----------------------------------------------------------------------------
--- @section Querying
----------------------------------------------------------------------------


--- @function has_been_triggered
--- @desc Returns <code>true</code> if the mission manager has been triggered in the past, <code>false</code> otherwise. If triggered it might not still be running, as the mission could have been completed.
--- @return boolean is started
function mission_manager:has_been_triggered()
	return self.started;
end;


--- @function is_completed
--- @desc Returns <code>true</code> if the mission has been completed, <code>false</code> otherwise. Success, failure or cancellation all count as completion.
--- @return boolean is completed
function mission_manager:is_completed()
	return self.completed;
end;


-- for internal use only
function mission_manager:should_cancel_before_issuing()
	if self.should_cancel_before_issuing_override ~= nil then
		return self.should_cancel_before_issuing_override;
	end;
	return self.is_registered;
end;






----------------------------------------------------------------------------
--- @section Triggering
----------------------------------------------------------------------------


--- @function trigger
--- @desc Triggers the mission, causing it to be issued.
--- @p [opt=nil] function dismiss callback, Dismiss callback. If specified, this is called when the event panel is dismissed.
--- @p [opt=nil] number callback delay, Dismiss callback delay, in seconds. If specified this introduces a delay between the event panel being dismissed and the dismiss callback being called.
function mission_manager:trigger(dismiss_callback, delay)
	if self.started then
		script_error("ERROR: an attempt was made to trigger a mission manager with key [" .. self.mission_key .. "] which has already been triggered");
		return false;
	end;
	
	if dismiss_callback and not is_function(dismiss_callback) then
		script_error("trigger() called on mission but supplied dismiss callback [" .. tostring(dismiss_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("trigger() called on mission but supplied dismiss callback delay [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	delay = delay or 0;
	
	-- perform construction if we're constructing from a string
	if self.should_trigger_from_string then
		local mission_string = self:construct_mission_string();
		
		if not mission_string then
			script_error("ERROR: trigger() called on mission manager with key [" .. self.mission_key .. "] but failed to construct a mission string");
			return false;
		else
			self.mission_string = mission_string;
		end;
	end;

	self.started = true;

	-- start startup callbacks
	if is_function(self.first_time_startup_callback) then
		self.first_time_startup_callback();
	end;
	
	if is_function(self.each_time_startup_callback) then
		self.each_time_startup_callback();
	end;
	
	-- start completion listeners
	self:start_listeners();
	
	if dismiss_callback then
		core:add_listener(
			self.mission_key,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				cm:progress_on_events_dismissed(
					self.mission_key,
					dismiss_callback,
					delay
				);
			end,
			false
		);
		
		-- listen also for the mission or incident generation to be failed
		if self.is_incident_when_triggering_from_db then
			core:add_listener(
				self.mission_key,
				"IncidentFailedEvent",
				function(context) return context:record_key() == self.mission_key end,
				function()
					script_error("ERROR: mission manager failed to generate incident with key " .. self.mission_key .. ". Calling dismiss callback, but no incident has been issued to the player - this is a serious error");
					core:remove_listener(self.mission_key);
					cm:callback(function() dismiss_callback() end, delay);
				end,
				false
			);
		else
			core:add_listener(
				self.mission_key,
				"MissionGenerationFailed",
				function(context) return context:mission() == self.mission_key end,
				function()
					script_error("ERROR: mission manager failed to generate mission with key " .. self.mission_key .. ". Calling dismiss callback, but no mission has been issued to the player - this is a serious error");
					core:remove_listener(self.mission_key);
					cm:callback(function() dismiss_callback() end, delay);
				end,
				false
			);
		end;
	end;
	
	-- 
	-- trigger the mission
	-- 

	--- do one of the following..
	if self.should_trigger_from_string then
		-- trigger from a constructed string
		self:trigger_from_string();
		
	elseif self.should_trigger_from_db then
		-- trigger from db records
		if self.is_mission_when_triggering_from_db then
			cm:trigger_mission(self.faction_name, self.mission_key, true, false, self.should_whitelist);
		elseif self.is_incident_when_triggering_from_db then
			cm:trigger_incident(self.faction_name, self.mission_key, true, self.should_whitelist);
		elseif self.is_dilemma_when_triggering_from_db then
			if self.is_dilemma_in_intervention then
				-- this is a dilemma in an intervention, apparently, so trigger it immediately without trying to package it in an intervention
				cm:trigger_dilemma_raw(self.faction_name, self.mission_key, true, self.should_whitelist);
			else
				-- attempt to package this dilemma in an intervention (it will get triggered directly in multiplayer)
				cm:trigger_dilemma(self.faction_name, self.mission_key);
			end;
		else
			script_error("ERROR: mission manager is attempting to trigger() mission with key [" .. self.mission_key .. "] but cannot identify mission type - it doesn't seem to be a mission, incident or dilemma?");
			return false;
		end;
	else
		-- trigger from missions.txt file
		cm:trigger_custom_mission(self.faction_name, self.mission_key, false, not self:should_cancel_before_issuing(), self.should_whitelist);
	end;
end;


--- @function cancel_dismiss_callback_listeners
--- @desc Cancels any listeners associated with the dismiss callback added with @mission_manager:trigger. Call this to prevent the mission manager responding to the event panel being closed (it will only do so if a dismiss callback was added).
function mission_manager:cancel_dismiss_callback_listeners()
	core:remove_listener(self.mission_key);
end;


-- internal function to construct the mission string we will be triggering with (if our mission is to be constructed this way)
function mission_manager:construct_mission_string()

	if #self.objectives == 0 then
		script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but we have no objectives to add");
		return false;
	end;
	
	local is_primary_objective = true;
	local have_opened_secondary_objective_block = false;
	
	local mission_string = false;
	
	if self.chapter_mission then
		mission_string = "mission{chapter " .. self.chapter_mission .. ";key " .. self.mission_key .. ";issuer " .. self.mission_issuer;
	else
		mission_string = "mission{key " .. self.mission_key .. ";issuer " .. self.mission_issuer;
	end
	
	if self.turn_limit then
		mission_string = mission_string .. ";turn_limit " .. self.turn_limit;
	end;
	
	for i = 1, #self.objectives do
		local current_objective = self.objectives[i];
		
		-- data checking
		if not current_objective.objective_type then
			script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but objective [" .. i .. "] has no type (how can this be?)");
			return false;
		end;
		
		if not is_table(current_objective.payloads) or #current_objective.payloads == 0 then
			script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but objective [" .. i .. "] has no payload");
			return false;
		end;
		
		-- open the objective/payload block
		if is_primary_objective then
			mission_string = mission_string .. ";primary_objectives_and_payload{";
			is_primary_objective = false;
			
		elseif have_opened_secondary_objective_block then
			mission_string = mission_string .. "objectives_and_payload{";
			
		else
			mission_string = mission_string .. "secondary_objectives_and_payloads{objectives_and_payload{";
			have_opened_secondary_objective_block = true;
		end;
		
		-- optional heading/decription key overrides
		if current_objective.heading then
			mission_string = mission_string .. "heading " .. current_objective.heading .. ";";
		end;
		
		if current_objective.description then
			mission_string = mission_string .. "description " .. current_objective.description .. ";";
		end;
		
		mission_string = mission_string .. "objective{type " .. current_objective.objective_type .. ";";
		
		for j = 1, #current_objective.conditions do
			mission_string = mission_string .. current_objective.conditions[j] .. ";";
		end;
		
		-- payloads
		mission_string = mission_string .. "}payload{";
		
		for j = 1, #current_objective.payloads do
			local payload_string = current_objective.payloads[j];
			
			-- don't add a semicolon if the last character of the payload string is "}"
			if string.sub(payload_string, string.len(payload_string)) == "}" then
				mission_string = mission_string .. payload_string;
			else
				mission_string = mission_string .. payload_string .. ";";
			end;
		end;
		
		if #current_objective.failure_payloads > 0 then
			mission_string = mission_string .. "}failure_payload{";

			for j = 1, #current_objective.failure_payloads do
				local payload_string = current_objective.failure_payloads[j];
				if string.sub(payload_string, string.len(payload_string)) == "}" then
					mission_string = mission_string .. payload_string;
				else
					mission_string = mission_string .. payload_string .. ";";
				end;
			end;
		end;

		mission_string = mission_string .. "}}";
	end;
	
	if have_opened_secondary_objective_block then
		mission_string = mission_string .. "}}";
	else
		mission_string = mission_string .. "}";
	end;
	
	return mission_string;
end;


-- internal function to trigger from a constructed string
function mission_manager:trigger_from_string()
	local mission_string = self.mission_string;
	
	out("++ mission manager triggering mission from string:");
	
	if self:should_cancel_before_issuing() then
		cm:cancel_custom_mission(self.faction_name, self.mission_key);
	end;
	cm:trigger_custom_mission_from_string(self.faction_name, mission_string, false, self.should_whitelist);
end;


-- internal function to start this mission manager from a savegame
function mission_manager:start_from_savegame(started, completed)
	self.started = started;
	self.completed = completed;

	if started and not completed then
		if is_function(self.each_time_startup_callback) then
			self.each_time_startup_callback();
		end;

		self:start_listeners();
	end;
end;


-- internal function to start any success/failure/cancellation/nearing-expiry/scripted objective listeners we may have
function mission_manager:start_listeners()
	local mission_key = self.mission_key;
	local faction_name = self.faction_name;
	
	-- success listener
	if is_function(self.success_callback) then
		core:add_listener(
			mission_key .. "_success_listener",
			"MissionSucceeded",
			function(context) return context:mission():mission_record_key() == mission_key and context:faction():name() == faction_name end,
			function()
				out("~~~ MissionManager for mission [" .. mission_key .. "] and faction [" .. faction_name .. "] has received a MissionSucceeded event - this mission has been completed successfully");
				self:complete();
				if is_function(self.success_callback) then
					if self.force_immediate_callback then
						self.success_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.success_callback();
							end
						);
					end;
				end;
			end,
			false
		);
	end;
	
	-- failure listener
	if is_function(self.failure_callback) then
		core:add_listener(
			mission_key .. "_failure_listener",
			"MissionFailed",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				out("~~~ MissionManager for mission [" .. mission_key .. "] and faction [" .. faction_name .. "] has received a MissionFailed event - this mission has been failed");
				self:complete();
				if is_function(self.failure_callback) then
					if self.force_immediate_callback then
						self.failure_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.failure_callback();
							end
						);
					end;
				end;
			end,
			false
		);	
	end;
	
	-- cancellation listener
	if is_function(self.cancellation_callback) then
		core:add_listener(
			mission_key .. "_cancellation_listener",
			"MissionCancelled",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				out("~~~ MissionManager for mission [" .. mission_key .. "] and faction [" .. faction_name .. "] has received a MissionCancelled event - this mission has been cancelled");
				self:complete();
				if is_function(self.cancellation_callback) then
					if self.force_immediate_callback then
						self.cancellation_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.cancellation_callback();
							end
						);
					end;
				end;
			end,
			false
		);	
	end;
	
	-- nearing expiry listener
	if is_function(self.nearing_expiry_callback) then
		core:add_listener(
			mission_key .. "_nearing_expiry_listener",
			"MissionNearingExpiry",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				out("~~~ MissionManager for mission [" .. mission_key .. "] and faction [" .. faction_name .. "] has received a MissionNearingExpiry event - this mission is nearing expiry");
				if is_function(self.nearing_expiry_callback) then
					self.nearing_expiry_callback();
				end;
			end,
			true
		);	
	end;
	
	-- scripted objective listeners
	for i = 1, #self.scripted_objectives do
		local current_scripted_objective_record = self.scripted_objectives[i];
		local script_key = current_scripted_objective_record.script_key;
		
		local num_success_conditions = #current_scripted_objective_record.success_conditions;
		for j = 1, num_success_conditions do
			local condition_record = current_scripted_objective_record.success_conditions[j];
			
			local listener_name = self.mission_key .. script_key .. "_completion_listener";
			
			core:add_listener(
				listener_name,
				condition_record.event,
				condition_record.condition,
				function(context)
					out("~~~ MissionMaager :: " .. mission_key .. " has successfully completed scripted objective " .. i .. " of " .. #self.scripted_objectives .. " with script key [" .. script_key .. "] upon receipt of event " .. condition_record.event);
					
					core:remove_listener(listener_name);
					
					if cm:is_processing_battle() then
						out("\twill complete objective after battle sequence completes");
						cm:progress_on_battle_completed(
							listener_name,
							function()
								out("~~~ MissionManager :: " .. mission_key .. " is completing scripted objective with script key [" .. script_key .. "] now that battle sequence has completed");
								cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
							end,
							0.5
						);
					else
						out("\tcompleting objective immediately");
						cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
					end;
				end,
				false
			);
		end;
		
		local num_failure_conditions = #current_scripted_objective_record.failure_conditions;
		for j = 1, #current_scripted_objective_record.failure_conditions do
			local condition_record = current_scripted_objective_record.failure_conditions[j];
			
			core:add_listener(
				self.mission_key .. script_key .. "_completion_listener",
				condition_record.event,
				condition_record.condition,
				function(context)
					out("~~~ MissionManager :: " .. mission_key .. " has failed scripted objective " .. i .. " of " .. #self.scripted_objectives .. " with script key [" .. script_key .. "] upon receipt of event " .. condition_record.event);
					cm:complete_scripted_mission_objective(self.mission_key, script_key, false);
					core:remove_listener(self.mission_key .. script_key .. "_completion_listener");
				end,
				false
			);
		end;
	end;
end;



----------------------------------------------------------------------------
--	Saving
----------------------------------------------------------------------------

-- called internally when the game saves
function mission_manager:state_to_string()
	return self.mission_key .. "%" .. tostring(self.started) .. "%" .. tostring(self.completed) .. "%";
end;



----------------------------------------------------------------------------
--	Completing
----------------------------------------------------------------------------

-- called internally when the mission is completed
function mission_manager:complete()
	local mission_key = self.mission_key;
	
	self.completed = true;

	core:remove_listener(mission_key .. "_success_listener");
	core:remove_listener(mission_key .. "_failure_listener");
	core:remove_listener(mission_key .. "_cancellation_listener");
	core:remove_listener(mission_key .. "_nearing_expiry_listener");
	
	-- clean up any remaining scripted objective listeners
	for i = 1, #self.scripted_objectives do
		core:remove_listener(self.mission_key .. self.scripted_objectives[i].script_key .. "_completion_listener");
	end;
end;


--- @end_class

















----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CHAPTER MISSIONS WRAPPER
--
---	@class chapter_mission chapter_mission Chapter Missions
--- @desc The chapter mission system is a simple wrapper for the traditional method of packaging chapter missions. It triggers the mission within an @intervention to better control the flow of events on-screen, and optionally plays advice and infotext that can add flavour.
--- @desc This system is due a rewrite to allow them to use @mission_manager's and also allow chapter missions to be constructed from strings at runtime.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


chapter_mission = {
	cm = false,
	chapter_number = 0,
	player_faction = false,
	mission_key = false,
	advice_key = false,
	intervention = false
};







----------------------------------------------------------------------------
--- @section Creation
----------------------------------------------------------------------------


--- @function new
--- @desc Creates a chapter mission object. This should happen in the root of the script somewhere, so that the object is declared and set up by the time the first tick happens so that it can be properly restarted from a savegame.
--- @p number chapter number, Chapter number. All numbers from 1 to n should be accounted for, where n is the last chapter in the sequence. When a chapter mission completes it automatically starts the next chapter mission in the sequence. 
--- @p string faction key, Faction key of the faction receiving the mission.
--- @p string mission key, Mission key of the chapter mission.
--- @p [opt=nil] string advice key, Key of advice to deliver alongside the mission.
--- @p [opt=nil] table infotext, table of string infotext keys to deliver alongside advice.
--- @return chapter_mission Chapter mission object
function chapter_mission:new(chapter_number, player_faction, mission_key, advice_key, infotext)

	if not is_number(chapter_number) then
		script_error("ERROR: chapter_mission:new() called but supplied chapter number [" .. tostring(chapter_number) .. "] is not a number");
		return false;
	end;

	if not is_string(player_faction) then
		script_error("ERROR: chapter_mission:new() called but supplied player faction key [" .. tostring(player_faction) .. "] is not a string");
		return false;
	end;
	
	if not cm:get_faction(player_faction) then
		script_error("ERROR: chapter_mission:new() called but no faction with supplied player faction key [" .. player_faction .. "] could be found");
		return false;
	end;
	
	if not is_string(mission_key) then
		script_error("ERROR: chapter_mission:new() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(advice_key) and not is_nil(advice_key) then
		script_error("ERROR: chapter_mission:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string or nil");
		return false;
	end;
	
	if not is_nil(infotext) and not is_table(infotext) then
		script_error("ERROR: chapter_mission:new() called but supplied infotext [" .. tostring(infotext) .. "] is not a table or nil");
		return false;
	end;
	
	local ch = {};
	setmetatable(ch, self);
	self.__index = self;
	
	ch.chapter_number = chapter_number;
	ch.player_faction = player_faction;
	ch.mission_key = mission_key;
	ch.advice_key = advice_key;
	ch.infotext = infotext;
	
	local chapter_mission_string = "chapter_mission_" .. tostring(chapter_number);
	local mission_issued = ch:has_been_issued();
	local mission_completed = ch:has_been_completed();
	
	local intervention = intervention:new(
		chapter_mission_string,														-- string name
		0,																			-- cost
		function() 																	-- trigger callback
			ch:issue_mission();
		end,
		BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
	);
	
	intervention:set_allow_when_advice_disabled(true);
	
	intervention:add_precondition(function() return not mission_issued and not mission_completed end);
	
	intervention:add_trigger_condition(
		"ScriptEventTriggerChapterMission", 
		function(context) return context.string == tostring(chapter_number) end
	);
	
	if cm:is_new_game() then
		intervention:start();
	end;
	
	ch.intervention = intervention;
	
	-- We register chapter missions with the cm now so that it can be asked when a chapter mission is completed whether a further chapter mission exists
	-- This means we can avoid locking the saving-game functionality in legendary mode when there is no further mission (which is responsible for unlocking it)
	cm:register_chapter_mission(ch);
	
	-- listen for this chapter mission being completed and fire an event that should set off the next
	if not mission_completed then
		core:add_listener(
			chapter_mission_string,
			"MissionSucceeded",
			function(context)
				return context:mission():mission_record_key() == ch.mission_key
			end,
			function()
				local next_chapter_number = chapter_number + 1;
				
				-- if this is a legendary game then disable saving, so the game doesn't save after one chapter objective has been completed but before the next has been issued
				-- only do this if another chapter mission exists!
				if cm:model():difficulty_level() == -3 and cm:chapter_mission_exists_with_number(next_chapter_number) then
					cm:disable_saving_game(true);
				end;
				
				cm:set_saved_value("chapter_mission_" .. chapter_number .. "_completed", true);
				core:trigger_event("ScriptEventTriggerChapterMission", tostring(next_chapter_number))
			end,
			false
		);
	end;
	
	return ch;
end;






----------------------------------------------------------------------------
---	@section Usage
--- @desc Once a <code>chapter_mission</code> object has been created with @chapter_mission:new, functions on it may be called in the form showed below.
--- @new_example Specification
--- @example <i>&lt;chapter_mission_object&gt;</i>:<i>&lt;function_name&gt;</i>(<i>&lt;args&gt;</i>)
--- @new_example Creation and Usage
--- @example local chapter_one_mission = chapter_mission:new(1, "wh_main_emp_empire", "wh_objective_empire_01")
--- @example chapter_one_mission:manual_start()
----------------------------------------------------------------------------







----------------------------------------------------------------------------
--- @section Querying
----------------------------------------------------------------------------


--- @function has_been_issued
--- @desc returns whether the chapter mission has been issued.
--- @return boolean has been issued
function chapter_mission:has_been_issued()
	return not not cm:get_saved_value("chapter_mission_" .. self.chapter_number .. "_issued");
end;


--- @function has_been_completed
--- @desc returns whether the chapter mission has been completed.
--- @return boolean has been completed
function chapter_mission:has_been_completed()
	return not not cm:get_saved_value("chapter_mission_" .. self.chapter_number .. "_completed");
end;








----------------------------------------------------------------------------
--- @section Starting
----------------------------------------------------------------------------


--- @function manual_start
--- @desc Manually starts the chapter mission. It should only be necessary to manually start the first chapter mission in the sequence - the second will start automatically when the first is completed, and so on.
function chapter_mission:manual_start()
	core:trigger_event("ScriptEventTriggerChapterMission", tostring(self.chapter_number));
end;


-- internal function, not to be called externally
function chapter_mission:issue_mission()
	local intervention = self.intervention;
	
	-- On legendary difficulty, establish a listener for when the new mission is issued and then save the game.
	-- This is because on legendary difficulty the game autosaves at the start of turn, which can happen after
	-- the previous chapter mission is completed but before the next one is issued.
	local should_autosave_after_mission_issued = false;
	
	if cm:model():difficulty_level() == -3 then
		should_autosave_after_mission_issued = true;
	end;
	
	-- allow the chapter mission complete to be shown
	cm:whitelist_event_feed_event_type("faction_campaign_chapter_objective_completeevent_feed_target_mission_faction")
	
	core:trigger_event("ScriptEventChapterMissionTriggered");
	
	cm:set_saved_value("chapter_mission_" .. self.chapter_number .. "_issued", true);
	
	if self.advice_key and cm:is_advice_enabled() then
		if self.infotext and not effect.get_advice_history_string_seen("prelude_victory_conditions_advice") then
		
			effect.set_advice_history_string_seen("prelude_victory_conditions_advice")
	
			-- show victory conditions infotext if it's not been seen by the player before
			intervention:play_advice_for_intervention(self.advice_key, self.infotext);
		else
			intervention:play_advice_for_intervention(self.advice_key);
		end;
		
		cm:callback(
			function()
				cm:trigger_custom_mission(self.player_faction, self.mission_key);
				
				if should_autosave_after_mission_issued then
					cm:disable_saving_game(false);
					cm:autosave_at_next_opportunity();
				end;
			end,
			1
		);
	else
		cm:trigger_custom_mission(self.player_faction, self.mission_key);
		
		if should_autosave_after_mission_issued then
			cm:disable_saving_game(false);
			cm:autosave_at_next_opportunity();
		end;
		
		cm:callback(function() intervention:complete() end, 1);
	end;
end;



