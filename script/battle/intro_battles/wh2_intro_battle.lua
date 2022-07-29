




out("wh2_intro_battle.lua loaded");


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- camera marker
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_CAMERA_MARKER = "intro_battle_camera_marker";


function is_introbattlecameramarker(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_CAMERA_MARKER then
		return true;
	end;
	
	return false;
end;


intro_battle_camera_marker = {
	name = "",
	full_name = "",
	position = false,
	advice_key = "",
	advisor_delay = 0,
	advisor_duration = 0,
	infotext = {},
	cutscene_actions = {},
	infotext_delay = 0,
	marker_is_visible = false,
	is_completed = false,
	advice_played = false,
	restore_cam_time = 1
};


function intro_battle_camera_marker:new(name, position, advice_key, distance_override)
	
	if not is_string(name) then
		script_error("ERROR: attempt was made to create an intro battle camera marker, but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(position) then
		script_error("ERROR: attempt was made to create an intro battle camera marker with name [" .. name .. "], but supplied position [" .. tostring(position) .. "] is not a vector");
		return false;
	end;
	
	if not is_string(advice_key) then
		script_error("ERROR: attempt was made to create an intro battle camera marker with name [" .. name .. "], but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if distance_override and not is_number(distance_override) then
		script_error("ERROR: attempt was made to create an intro battle camera marker with name [" .. name .. "], but supplied distance override [" .. tostring(distance_override) .. "] is not a number");
		return false;
	end;

	local cm = {};
	setmetatable(cm, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_CAMERA_MARKER end;
	
	cm.name = name;
	cm.full_name = "intro_battle_camera_marker_" .. name;
	cm.position = position;
	cm.advice_key = advice_key;
	cm.distance_override = distance_override;
	cm.infotext = {};
	cm.cutscene_actions = {};
	
	return cm;
end;


function intro_battle_camera_marker:add_infotext(delay, ...)
	if not is_number(delay) then
		script_error(self.full_name .. " ERROR: add_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error(self.full_name .. " ERROR: add_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.infotext, current_infotext);
		end;
	end;
end;


function intro_battle_camera_marker:set_advisor_delay(value)
	if not is_number(value) or value < 0 then
		script_error(self.full_name .. " ERROR: set_advisor_delay() called, but supplied delay [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.advisor_delay = value;
end;


function intro_battle_camera_marker:set_advisor_duration(value)
	if not is_number(value) or value < 0 then
		script_error(self.full_name .. " ERROR: set_advisor_duration() called, but supplied duration [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.advisor_duration = value;
end;


function intro_battle_camera_marker:action(callback, delay)
	if not is_function(callback) then
		script_error(self.full_name .. " ERROR: action() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if not is_number(delay) or delay < 0 then
		script_error(self.full_name .. " ERROR: action() called but supplied delay [" .. tostring(delay) .. "] is not a positive number");
		return false;
	end;
	
	local new_action = {
		callback = callback,
		delay = delay
	};
	
	table.insert(self.cutscene_actions, new_action);
end;


function intro_battle_camera_marker:set_restore_cam_time(value)
	if not is_number(value) or value < 0 then
		script_error(self.full_name .. " ERROR: set_restore_cam_time() called but supplied delay [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.restore_cam_time = value;
end;






----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- camera position advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_CAMERA_POSITIONS_ADVICE = "intro_battle_camera_positions_advice";

function is_introbattlecamerapositionsadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_CAMERA_POSITIONS_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_camera_positions_advice = {
	bm = false,
	starting_advice = "",
	player_sunits = false,
	objective_key = "",
	end_callback = false,
	markers = {},
	should_skip = false,
	trigger_threshold = 60,
	markers_completed = 0,
	camera_infotext_displayed = false,
	help_panel_camera_info_callback = function() show_battle_controls_cheat_sheet() end,
	show_advisor_close_button = false
};


function intro_battle_camera_positions_advice:new(starting_advice, player_sunits, objective_key, end_callback, markers)
	
	if not is_string(starting_advice) then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied starting advice key [" .. tostring(starting_advice) .. "] is not a string");
		return false;
	end;
	
	if not is_scriptunits(player_sunits) then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied player scriptunits key [" .. tostring(player_sunits) .. "] is not a string");
		return false;
	end;
	
	if player_sunits:count() == 0 then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied player scriptunits key [" .. tostring(player_sunits) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied end callback [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_table(markers) then
		script_error("ERROR: attempt was made to create intro battle camera positions advice, but supplied marker list [" .. tostring(markers) .. "] is not a table");
		return false;
	end;
	
	for i = 1, #markers do
		if not is_introbattlecameramarker(markers[i]) then
			script_error("ERROR: attempt was made to create intro battle camera positions advice, but marker [" .. i .. "] in supplied list is not an intro battle camera marker but a [" .. tostring(markers[i]) .. "]");
			return false;
		end;
	end;
	
	local pa = {};
	setmetatable(pa, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_CAMERA_POSITIONS_ADVICE end;
	
	pa.bm = get_bm();
	pa.starting_advice = starting_advice;
	pa.player_sunits = player_sunits;
	pa.objective_key = objective_key;
	pa.end_callback = end_callback;
	pa.markers = {};
	
	for i = 1, #markers do
		pa.markers[i] = markers[i];
	end;
		
	return pa;
end;


function intro_battle_camera_positions_advice:set_show_advisor_close_button(value)
	if value == false then
		self.show_advisor_close_button = false;
	else
		self.show_advisor_close_button = true;
	end;
end;


function intro_battle_camera_positions_advice:start()
	local bm = self.bm;
	
	-- play intro advice
	bm:stop_advisor_queue();
	bm:callback(
		function() 
			bm:queue_advisor(self.starting_advice);
			
			-- special-case camera infotext
			bm:add_infotext(
				1,
				"wh2.battle.intro.info_200",
				"wh2.battle.intro.info_201",
				"wh2.battle.intro.info_202",
				"wh2.battle.intro.info_203"
			);
			
			if self.show_advisor_close_button then
				bm:modify_advice(true);
			else
				bm:modify_advice(false);
			end;
			
			self.camera_infotext_displayed = true;
		end, 
		500
	);
	
	if self.should_skip then
		bm:out("camera positions advice :: skipping");
		
		if self.help_panel_camera_info_callback then 
			self.help_panel_camera_info_callback();
		end;
		bm:callback(function() self:complete() end, 1000);
		
		return;
	end;
	
	-- show objective
	bm:callback(
		function()
			bm:activate_objective_chain("camera_advice", self.objective_key, 0, #self.markers);
			
			-- set the objectives panel to the top-middle of the screen
			-- get_objectives_manager():set_debug();
			-- get_objectives_manager():move_panel_top_centre();
		end,
		5000
	);		
	
	bm:callback(function() self:start_position_monitors() end, 3000, "camera_positions_advice");
end;


function intro_battle_camera_positions_advice:start_position_monitors()
	local bm = self.bm;
	local markers = self.markers;
	
	for i = 1, #markers do
		local current_marker = markers[i];
		if not current_marker.is_completed then
			-- draw marker
			local pos = current_marker.position;
			bm:add_ping_icon(pos:get_x(), pos:get_y(), pos:get_z(), 12, false);
			current_marker.marker_is_visible = true;
			
			-- monitor the camera's position relative to the marker
			bm:watch(
				function() 
					return self:scan_marker(current_marker) 
				end, 
				0, 
				function()
					bm:remove_process("camera_positions_scan");
					self:trigger_marker_advice(current_marker); 
				end, 
				"camera_positions_scan"
			);
		end;
	end;
end;


-- should we trigger a given marker cutscene
function intro_battle_camera_positions_advice:scan_marker(marker)
	local bm = self.bm;
	local cam = bm:camera();
	
	local cam_pos = cam:position();
	local targ_pos = cam:target();
	local marker_pos = marker.position;

	local cam_distance = cam_pos:distance(marker_pos);
	local trigger_threshold = marker.distance_override or self.trigger_threshold;
	
	-- trigger if we're close enough to the marker position
	if cam_distance < trigger_threshold then		
		local v_cam_to_targ	= v_subtract(targ_pos, cam_pos);
		local v_cam_to_intel_pos = v_subtract(marker_pos, cam_pos);
					
		if dot3d(v_cam_to_targ, v_cam_to_intel_pos) > 0 then
			return true;
		end;
	end;
	
	return false;
end;


-- remove all currently-drawn ping markers
function intro_battle_camera_positions_advice:remove_all_markers()
	local bm = self.bm;
	local markers = self.markers;
	
	for i = 1, #markers do
		local current_marker = markers[i];
		if current_marker.marker_is_visible then
			-- remove marker
			local pos = current_marker.position;
			bm:remove_ping_icon(pos:get_x(), pos:get_y(), pos:get_z());
			current_marker.marker_is_visible = false;
		end;
	end;
end;


function intro_battle_camera_positions_advice:trigger_marker_advice(marker)
	local bm = self.bm;

	-- remove all existing ping markers
	self:remove_all_markers();
	
	-- work out a length for the cutscene
	local cutscene_actions = marker.cutscene_actions;
	local greatest_action_delay = 0;
	
	for i = 1, #cutscene_actions do
		local current_action = cutscene_actions[i];
		if current_action.delay > greatest_action_delay then
			greatest_action_delay = current_action.delay;
		end;
	end;
	
	if greatest_action_delay < marker.advisor_delay + marker.advisor_duration then
		greatest_action_delay = marker.advisor_delay + marker.advisor_duration;
	end;
	
	-- declare our cutscene
	local cutscene_marker = cutscene:new(
		marker.full_name,
		self.player_sunits,
		greatest_action_delay,
		function() self:marker_cutscene_ends(marker) end
	);
	
	cutscene_marker:set_restore_cam(marker.restore_cam_time);
	cutscene_marker:set_post_cutscene_fade_time(0);
	cutscene_marker:set_do_not_end(true);
	cutscene_marker:suppress_unit_voices(true);
	cutscene_marker:set_close_advisor_on_start(false);
	cutscene_marker:set_close_advisor_on_end(false);
	cutscene_marker:set_should_disable_unit_ids(false);
	
	-- pass through our list of actions
	for i = 1, #cutscene_actions do
		local current_action = cutscene_actions[i];
		
		cutscene_marker:action(current_action.callback, current_action.delay);
	end;
		
	-- play advice
	cutscene_marker:action(
		function()
			self:attempt_to_trigger_marker_advice(marker, cutscene_marker);
		end,
		marker.advisor_delay
	);
	
	-- if an advisor duration is set then establish an action for it (for if there is no audio file)
	if marker.advisor_duration > 0 then
		cutscene_marker:action(
			function()
				cutscene_marker:show_esc_prompt();
			end,
			marker.advisor_delay + marker.advisor_duration
		);
	end;
		
	-- start cutscene
	cutscene_marker:start();
end;


function intro_battle_camera_positions_advice:attempt_to_trigger_marker_advice(marker, cutscene)
	local bm = self.bm;

	if not marker.advice_played then
		bm:stop_advisor_queue();
		bm:queue_advisor(
			marker.advice_key,
			marker.advisor_duration,
			false,
			function()
				if #marker.infotext > 0 then					
					if self.camera_infotext_displayed then
						bm:clear_infotext();
					end;
					
					bm:add_infotext(marker.infotext_delay, unpack(marker.infotext));
				end;			
				
				if cutscene and cutscene.is_running then
					core:add_listener(
						marker.full_name .. "_advice_finished_trigger",
						"AdviceFinishedTrigger",
						true,
						function()
							cutscene_marker:show_esc_prompt();
						end,
						false
					);
				end;
			end
		);
		marker.advice_played = true;
	end;
end;



function intro_battle_camera_positions_advice:marker_cutscene_ends(marker)
	local bm = self.bm;
	
	bm:remove_process(marker.full_name .. "_advice_finished_trigger");
	
	-- if the camera controls infotext was displayed when this cutscene was started, display the corresponding help page now
	if self.camera_infotext_displayed then
		bm:callback(
			function()
				self.camera_infotext_displayed = false;
				if self.help_panel_camera_info_callback then
					self.help_panel_camera_info_callback();
				end;
			end,
			500
		);
	end;
	
	-- if the advice has not already been triggered, trigger it now
	self:attempt_to_trigger_marker_advice(marker);
	
	-- update marker
	marker.is_completed = true;
	
	-- update internal counter
	self.markers_completed = self.markers_completed + 1;
	
	-- update objective counter on ui
	bm:update_objective_chain("camera_advice", self.objective_key, self.markers_completed, #self.markers);
	
	-- take control of player's units again
	self.player_sunits:take_control();
	
	if self.markers_completed == #self.markers then
		self:complete();
	else
		self:start_position_monitors();
	end;
end;



function intro_battle_camera_positions_advice:complete()
	local bm = self.bm;
	
	bm:complete_objective(self.objective_key);
	bm:callback(function() bm:end_objective_chain("camera_advice") end, 2000);

	-- call end callback
	bm:callback(function() self:end_callback() end, 1000);
end;






















----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- selection advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_SELECTION_ADVICE = "intro_battle_selection_advice";

function is_introbattleselectionadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_SELECTION_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_selection_advice = {
	name = "",
	advice_key = "",
	advisor_delay = 500,
	cam_pos = false,
	cam_targ = false,
	camera_pan_duration = 3000,
	selection_sunits = false,
	num_selection_sunits = 0,
	all_sunits = false,
	infotext = {},
	infotext_delay = 0,
	objective_key = "",
	objective_shown = false,
	objective_counter_shown = false,
	units_selected = false,
	end_callback = false,
	should_enable_unit_cards = false,
	should_disable_camera = false,
	marker_position = false,
	marker_visible = false,
	enable_orders_on_end = true,
	show_advisor_close_button = false
};


function intro_battle_selection_advice:new(advice_key, cam_pos, cam_targ, selection_sunits, objective_key, end_callback)

	if not is_string(advice_key) and advice_key ~= false then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied advice key [" .. tostring(advice_key) .. "] is not a string or false");
		return false;
	end;
	
	if not is_vector(cam_pos) then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied camera position [" .. tostring(cam_pos) .. "] is not a vector");
		return false;
	end;
	
	if not is_vector(cam_targ) then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied camera target [" .. tostring(cam_targ) .. "] is not a vector");
		return false;
	end;
	
	if not is_scriptunits(selection_sunits) then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied selection scriptunits [" .. tostring(selection_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied advice key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle selection advice but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	local sa = {};
	setmetatable(sa, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_SELECTION_ADVICE end;
	
	sa.advice_key = advice_key;
	sa.cam_pos = cam_pos;
	sa.cam_targ = cam_targ;
	sa.selection_sunits = selection_sunits;
	sa.all_player_sunits = selection_sunits;
	sa.objective_key = objective_key;
	sa.end_callback = end_callback;
	sa.infotext = {};
	
	sa.name = "selection_advice_" .. core:get_unique_counter();

	return sa;
end;


function intro_battle_selection_advice:set_camera_pan_duration(duration)
	if not is_number(duration) then
		script_error("ERROR: set_camera_pan_duration() called but supplied duration [" .. tostring(duration) .. "] is not a number");
		return false;
	end;
	
	if duration < 100 then
		script_error("WARNING: set_camera_pan_duration() called but supplied duration [" .. duration .. "] is under 100 - period should be specified in milliseconds");
	end;
	
	self.camera_pan_duration = duration;
end;


function intro_battle_selection_advice:set_advisor_delay(delay)
	if not is_number(delay) then
		script_error("ERROR: set_advisor_delay() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.advisor_delay = delay;
end;


function intro_battle_selection_advice:add_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.infotext, current_infotext);
		end;
	end;
end;


function intro_battle_selection_advice:set_all_player_sunits(sunits)
	if is_scriptunits(sunits) then
		self.all_player_sunits = sunits;
	end;
end;


function intro_battle_selection_advice:set_should_enable_unit_cards(value)
	if value == false then
		self.should_enable_unit_cards = false;
	else
		self.should_enable_unit_cards = true;
	end;
end;


function intro_battle_selection_advice:set_should_disable_camera(value)
	if value == false then
		self.should_disable_camera = false;
	else
		self.should_disable_camera = true;
	end;
end;


function intro_battle_selection_advice:set_enable_orders_on_end(value)
	if value == false then
		self.enable_orders_on_end = false;
	else
		self.enable_orders_on_end = true;
	end;
end;


function intro_battle_selection_advice:set_show_advisor_close_button(value)
	if value == false then
		self.show_advisor_close_button = false;
	else
		self.show_advisor_close_button = true;
	end;
end;


function intro_battle_selection_advice:set_marker_position(pos)
	if not is_vector(pos) then
		script_error("ERROR: set_marker_position() called but supplied position [" .. tostring(pos) .. "] is not a vector");
		return false;
	end;

	self.marker_position = pos;
end;


function intro_battle_selection_advice:start()

	local bm = get_bm();
	local cam = bm:camera();
	
	-- prevent the player from issuing any orders at this time
	bm:disable_orders(true);
	
	self.num_selection_sunits = self.selection_sunits:count();
	
	-- assemble a cutscene 
	local cutscene_selection = cutscene:new(
		self.name,
		self.all_player_sunits,
		self.camera_pan_duration,
		function()
		
			-- if our selection_sunits and all_player_sunits collections are different, take control of the latter and then release the former
			if self.selection_sunits ~= self.all_player_sunits then
				self.all_player_sunits:take_control();
				self.selection_sunits:release_control();
			end;
			
			-- disable camera if we should
			if self.should_disable_camera then
				bm:enable_camera_movement(false);
			end;
			
			-- enable unit cards if we should
			if self.should_enable_unit_cards then
			bm:callback(function() bm:show_army_panel(true) end, 500);
			end;
			
			self:start_selection_monitor();
			self:show_infotext_and_objective();
		end
	);
	cutscene_selection:set_skip_camera(self.cam_pos, self.cam_targ);
	cutscene_selection:set_close_advisor_on_end(false);
	cutscene_selection:set_should_disable_unit_ids(false);
	cutscene_selection:action(function() cam:move_to(self.cam_pos, self.cam_targ, self.camera_pan_duration / 1000, false, 0) end, 0);
	cutscene_selection:start();
	
	-- play advice
	if self.advice_key then
		local play_advice_func = function()
			bm:stop_advisor_queue();
			bm:clear_infotext();
			bm:queue_advisor(self.advice_key);
			
			if self.show_advisor_close_button then
				bm:modify_advice(true);
			else
				bm:modify_advice(false);
			end;
		end;
		
		if self.advisor_delay == 0 then
			play_advice_func();
		else
			bm:callback(function() play_advice_func() end, self.advisor_delay);
		end;
	end;
end;


function intro_battle_selection_advice:show_infotext_and_objective()

	local bm = get_bm();
	
	local show_objective_func = function()
		-- don't do anything if the units have already been selected
		if self.units_selected then
			return;
		end;
		
		-- if the player has to select more than one sunit, activate objective with num_units_selected / total_units counters as well
		self.objective_shown = true;
		if self.num_selection_sunits > 1 then
			self.objective_counter_shown = true;
			bm:activate_objective_chain(self.name, self.objective_key, 0, self.num_selection_sunits);
		else
			bm:activate_objective_chain(self.name, self.objective_key);
		end;
	end;
	
	local show_marker_func = function()
		-- don't do anything if the units have already been selected
		if self.units_selected then
			return;
		end;
	
		if self.marker_position then
			self.marker_visible = true;
			bm:add_ping_icon(self.marker_position:get_x(), self.marker_position:get_y(), self.marker_position:get_z(), 14, false);
		end;
	end;

	-- show infotext
	if #self.infotext > 0 then
		-- add objective to infotext
		table.insert(
			self.infotext, 
			function()
				show_objective_func();
			end
		);
		
		bm:add_infotext(self.infotext_delay, unpack(self.infotext));
		show_marker_func();
	else
		show_objective_func();
		show_marker_func();
	end;
end;


function intro_battle_selection_advice:start_selection_monitor()
	local bm = get_bm();
	local selection_sunits = self.selection_sunits;
	
	for i = 1, selection_sunits:count() do
		local current_sunit = selection_sunits:item(i);
		bm:register_unit_selection_callback(
			current_sunit.unit, 
			function(unit, is_selected)
				if is_selected then
					current_sunit.is_selected = true;
					self:check_all_units_selected();
				else
					current_sunit.is_selected = false;
				end;
			end
		)
	end;
end;


function intro_battle_selection_advice:check_all_units_selected()
	local bm = get_bm();
	local selection_sunits = self.selection_sunits;

	-- count the number of selected units
	local count = 0;
	for i = 1, selection_sunits:count() do
		local current_sunit = selection_sunits:item(i);
		if current_sunit.is_selected then
			count = count + 1;
		end;
	end;
	
	-- update objective counter if we should
	if self.objective_counter_shown then
		bm:update_objective_chain(self.name, self.objective_key, count, self.num_selection_sunits);
	end;
	
	-- proceed if all units are selected
	if count == self.num_selection_sunits then
		self:all_units_selected();
	end;
end;



function intro_battle_selection_advice:all_units_selected()
	-- only end if all units are selected the objective has been shown
	local bm = get_bm();
	
	self.units_selected = true;
	bm:complete_objective(self.objective_key);
	
	if self.marker_visible then
		bm:remove_ping_icon(self.marker_position:get_x(), self.marker_position:get_y(), self.marker_position:get_z());
	end;
	
	-- enable camera if we disabled it
	if self.should_disable_camera then
		bm:enable_camera_movement(true);
	end;

	-- unregister all unit selection handlers
	local selection_sunits = self.selection_sunits;
	for i = 1, selection_sunits:count() do
		bm:unregister_unit_selection_callback(selection_sunits:item(i).unit);
	end;
	
	-- allow the player to issue orders again
	if self.enable_orders_on_end then
		bm:disable_orders(false);
	end;
	
	self.end_callback();
	
	if self.objective_shown then
		bm:callback(function() bm:end_objective_chain(self.name) end, 1000);
	end;
end;












----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- movement advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_MOVEMENT_ADVICE = "intro_battle_movement_advice";


function is_introbattlemovementadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_MOVEMENT_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_movement_advice = {
	name = "",
	advice_key = "",
	advisor_delay = 0,
	move_position = false,
	marker_is_visible = false,
	sunits = false,
	sunits_are_moving = false,
	infotext = {},
	infotext_delay = 0,
	objective_key = "",
	objective_shown = false,
	end_callback = false,
	end_on_marker_reached = false,
	marker_range = 50,
	enemy_sunits = false,
	enemy_sunits_range = 0,
	enemy_contacted = false,
	should_disable_camera = false,
	prevent_orders_after_movement = false,
	remove_marker_on_end = true,
	allow_orders_on_advice_delivery = false,
	show_advisor_close_button = false
};
	
	
function intro_battle_movement_advice:new(advice_key, move_position, sunits, objective_key, end_callback)
	
	if not is_string(advice_key) then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(move_position) then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied position [" .. tostring(move_position) .. "] is not a vector");
		return false;
	end;
	
	if not is_scriptunits(sunits) then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied scriptunits [" .. tostring(sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits:count() == 0 then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied scriptunits collection is empty");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied advice key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle movement advice but supplied end callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	local ma = {};
	setmetatable(ma, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_MOVEMENT_ADVICE end;
	
	ma.advice_key = advice_key;
	ma.move_position = move_position;
	ma.sunits = sunits;
	ma.objective_key = objective_key;
	ma.end_callback = end_callback;
	ma.infotext = {};
	
	ma.name = "movement_advice_" .. core:get_unique_counter();

	return ma;
end;


function intro_battle_movement_advice:set_end_on_marker_reached(value)
	if value == false then
		self.end_on_marker_reached = false;
	else
		self.end_on_marker_reached = true;
	end;
end;


function intro_battle_movement_advice:set_prevent_orders_after_movement(value)
	if value == false then
		self.prevent_orders_after_movement = false;
	else
		self.prevent_orders_after_movement = true;
	end;
end;


function intro_battle_movement_advice:set_allow_orders_on_advice_delivery(value)
	if value == false then
		self.allow_orders_on_advice_delivery = false;
	else
		self.allow_orders_on_advice_delivery = true;
	end;
end;


function intro_battle_movement_advice:set_show_advisor_close_button(value)
	if value == false then
		self.show_advisor_close_button = false;
	else
		self.show_advisor_close_button = true;
	end;
end;


function intro_battle_movement_advice:set_marker_range(value)
	if not is_number(value) then
		script_error("ERROR: set_marker_range() called but supplied range [" .. tostring(value) .. "] is not a number");
		return false;
	end;
	
	self.marker_range = value;
end;


function intro_battle_movement_advice:remove_objective_on_proximity_to_enemy(enemy_sunits, range)
	
	if not is_scriptunits(enemy_sunits) or enemy_sunits:count() == 0 then
		script_error("ERROR: remove_objective_on_proximity_to_enemy() called but supplied sunits [" .. tostring(enemy_sunits) .. "] is not a valid scriptunits collection (or is empty)");
		return false;
	end;
	
	if not is_number(range) or range <= 0 then
		script_error("ERROR: remove_objective_on_proximity_to_enemy() called but supplied range [" .. tostring(range) .. "] is not a number greater than zero");
		return false;
	end;
	
	self.enemy_sunits = enemy_sunits;
	self.enemy_sunits_range = range;
end;


function intro_battle_movement_advice:set_advisor_delay(delay)
	if not is_number(delay) then
		script_error("ERROR: set_advisor_delay() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.advisor_delay = delay;
end;


function intro_battle_movement_advice:set_remove_marker_on_end(value)
	if value == false then
		self.remove_marker_on_end = false;
	else
		self.remove_marker_on_end = true; 
	end;
end;


function intro_battle_movement_advice:set_should_disable_camera(value)
	if value == false then
		self.should_disable_camera = false;
	else
		self.should_disable_camera = true;
	end;
end;


function intro_battle_movement_advice:add_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.infotext, current_infotext);
		end;
	end;
end;


function intro_battle_movement_advice:start()
	local bm = get_bm();
	
	bm:clear_infotext();
	
	-- disable camera if we should
	if self.should_disable_camera then
		bm:enable_camera_movement(false);
	end;
	
	-- assemble a function to show the advisor
	local advisor_func = function()
		bm:queue_advisor(
			self.advice_key,
			0,
			false,
			function()
				if self.allow_orders_on_advice_delivery then
					bm:disable_orders(false);
				end;
				
				if self.show_advisor_close_button then
					bm:modify_advice(true);
				else
					bm:modify_advice(false);
				end;
			
				-- assemble a function to show the objective and ping marker
				local objective_func = function()
					if not self.sunits_are_moving then
						local pos = self.move_position;
						bm:add_ping_icon(pos:get_x(), pos:get_y(), pos:get_z(), 13, false);
						self.marker_is_visible = true;
					end;
					
					bm:activate_objective_chain(self.name, self.objective_key);
					self.objective_shown = true;
					self:attempt_to_complete();
				end;
			
				if #self.infotext == 0 then
					bm:callback(
						function() 
							objective_func();
						end, 
						1000
					);
				else
					table.insert(self.infotext, function() objective_func() end);
					bm:add_infotext(self.infotext_delay, unpack(self.infotext));
				end;
			end			
		);
	end;
	
	-- show advisor
	if self.advisor_delay == 0 then
		advisor_func();
	else
		bm:callback(
			function()
				advisor_func();
			end,
			self.advisor_delay
		);
	end;
	
	-- monitor unit movement
	self:start_movement_monitor();
end;



function intro_battle_movement_advice:start_movement_monitor()
	local bm = get_bm();

	local player_sunits = self.sunits;
	
	if self.end_on_marker_reached then
	
		-- watch for player's units arriving at the marker if we are to end when it is reached
		bm:watch(
			function()
				return is_close_to_position(player_sunits, self.move_position, self.marker_range, true);
			end,
			0,
			function()
				self.marker_reached = true;
				self:attempt_to_complete();
			end,
			self.name
		);
	end;
	
	-- cache player unit locations
	player_sunits:cache_location();

	-- watch for player moving units if we are not to end when the marker is reached
	bm:watch(
		function()
			return player_sunits:have_any_moved()
		end,
		0,
		function()
			-- enable camera if we disabled it
			if self.should_disable_camera then
				bm:enable_camera_movement(true);
			end;
			
			-- disable further orders if we should
			if self.prevent_orders_after_movement then
				bm:disable_orders(true);
			end;
		
			self.sunits_are_moving = true;
			if not self.end_on_marker_reached then
				self:attempt_to_complete();
			end;
		end,
		self.name
	);
	
	-- watch for contact with the enemy, if we are supposed to
	if self.enemy_sunits then
		local enemy_sunits = self.enemy_sunits;
		bm:watch(
			function()
				return distance_between_forces(player_sunits, enemy_sunits) < self.enemy_sunits_range;
			end,
			0,
			function()
				self.enemy_contacted = true;
				self:attempt_to_complete();
			end,
			self.name
		);
	end;
end;


function intro_battle_movement_advice:attempt_to_complete()
	if self.enemy_contacted or (self.objective_shown and (self.marker_reached or self.sunits_are_moving)) then
		self:complete();
	end;
end;


function intro_battle_movement_advice:complete()
		local bm = get_bm();
	
	if not self.enemy_contacted then
		bm:complete_objective(self.objective_key);
	end;
	
	bm:remove_process(self.name);
	
	-- remove position marker if it's drawn
	if self.marker_is_visible and self.remove_marker_on_end then
		local pos = self.move_position;
		bm:remove_ping_icon(pos:get_x(), pos:get_y(), pos:get_z());
		self.marker_is_visible = false;
	end;
	
	if self.end_callback then
		self.end_callback();
	end;
	
	bm:callback(function() bm:end_objective_chain(self.name) end, 2000);
end;













----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- maneouvring advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_MANEOUVRING_ADVICE = "intro_battle_maneouvring_advice";

function is_introbattlemaneouvringadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_MANEOUVRING_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_maneouvring_advice = {
	advice_key = "",
	sunits_player = false,
	sunits_enemy = false,
	infotext = {},
	infotext_delay = 0,
	objective_key = "",
	end_callback = false,
	show_advisor_close_button = true
};

	
	
function intro_battle_maneouvring_advice:new(advice_key, sunits_player, sunits_enemy, objective_key, end_callback)
	if not is_string(advice_key) then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
		
	if not is_scriptunits(sunits_player) then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied player scriptunits [" .. tostring(sunits_player) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_player:count() == 0 then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied player scriptunits collection is empty");
		return false;
	end;
	
	if not is_scriptunits(sunits_enemy) then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied enemy scriptunits [" .. tostring(sunits_enemy) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_enemy:count() == 0 then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied enemy scriptunits collection is empty");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: attempt made made to create intro battle maneouvring advice but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle maneouvring advice but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	local ma = {};
	setmetatable(ma, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_MANEOUVRING_ADVICE end;
	
	ma.advice_key = advice_key;
	ma.sunits_player = sunits_player;
	ma.sunits_enemy = sunits_enemy;
	ma.objective_key = objective_key;
	ma.end_callback = end_callback;
	ma.infotext = {};

	return ma;
end;


function intro_battle_maneouvring_advice:set_show_advisor_close_button(value)
	if value == false then
		self.show_advisor_close_button = false;
	else
		self.show_advisor_close_button = true;
	end;
end;


function intro_battle_maneouvring_advice:add_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.infotext, current_infotext);
		end;
	end;
end;


function intro_battle_maneouvring_advice:start()
	local bm = get_bm();
	
	-- show advice
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function()
			local objective_func = function()
				bm:activate_objective_chain("maneouvring_advice", self.objective_key);
				self:start_visibility_monitor();
			end;
			
			if self.show_advisor_close_button then
				bm:modify_advice(true);
			else
				bm:modify_advice(false);
			end;
			
			-- show infotext and objective
			if #self.infotext == 0 then
				bm:callback(function() objective_func() end, 1000);
			else
				table.insert(self.infotext, function() objective_func() end);
				bm:add_infotext(self.infotext_delay, unpack(self.infotext));
			end;
		end
	);
end;


function intro_battle_maneouvring_advice:start_visibility_monitor()
	local player_alliance = self.sunits_player:item(1).alliance;
	local enemy_sunits = self.sunits_enemy;
	
	bm:watch(
		function()
			for i = 1, enemy_sunits:count() do
				local current_sunit = enemy_sunits:item(i);
				if not current_sunit.unit:is_visible_to_alliance(player_alliance) then
					return false;
				end;
			end;
			return true;
		end,
		0,
		function()
			-- all enemy units are visible to the player
			self:enemy_units_visible();
		end
	);
end;


function intro_battle_maneouvring_advice:enemy_units_visible()
	local bm = get_bm();
	
	bm:complete_objective(self.objective_key);
	
	bm:callback(
		function()
			bm:end_objective_chain("maneouvring_advice");
			self.end_callback();
		end,
		2000
	);
end;




















----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- attacking advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_ATTACKING_ADVICE = "intro_battle_attacking_advice";

function is_introbattleattackingadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_ATTACKING_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_attacking_advice = {
	counter = 0,
	starting_advice_key = "",
	starting_objective_key = "",
	advance_position = false,
	advance_position_showing = false,
	advance_threshold = 150,
	countercharge_threshold = 50,
	countercharge_timeout = 30000,
	attacking_advice_key = "",
	min_attacking_advice_duration = 10000,
	follow_advice_key = false,
	min_follow_advice_duration = 10000,
	sunits_player = false,
	sunits_enemy = false,
	sai_enemy = false,
	enemy_are_attacking = false,
	player_approaching_enemy_triggered = false,
	starting_infotext = {},
	starting_infotext_delay = 0,
	attacking_infotext = {},
	attacking_infotext_delay = 0,
	attacking_areas = {},
	attacking_objective_key = "",
	attacking_timeout = 60000,
	end_callback = false
};

	
	
function intro_battle_attacking_advice:new(starting_advice_key, advance_position, starting_objective_key, attacking_advice_key, sunits_player, sunits_enemy, attacking_objective_key, end_callback)
	if not is_string(starting_advice_key) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied starting advice key [" .. tostring(starting_advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(advance_position) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied advance position [" .. tostring(advance_position) .. "] is not a vector");
		return false;
	end;
	
	if not is_string(starting_objective_key) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied starting objective key [" .. tostring(starting_objective_key) .. "] is not a string");
		return false;
	end;

	if not is_string(attacking_advice_key) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied attacking advice key [" .. tostring(attacking_advice_key) .. "] is not a string");
		return false;
	end;
		
	if not is_scriptunits(sunits_player) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied player scriptunits [" .. tostring(sunits_player) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_player:count() == 0 then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied player scriptunits collection is empty");
		return false;
	end;
	
	if not is_scriptunits(sunits_enemy) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied enemy scriptunits [" .. tostring(sunits_enemy) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_enemy:count() == 0 then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied enemy scriptunits collection is empty");
		return false;
	end;
		
	if not is_string(attacking_objective_key) then
		script_error("ERROR: attempt made made to create intro battle attacking advice but supplied attacking objective key [" .. tostring(attacking_objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle attacking advice but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	local aa = {};
	setmetatable(aa, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_ATTACKING_ADVICE end;
	
	aa.starting_advice_key = starting_advice_key;
	aa.advance_position = advance_position;
	aa.starting_objective_key = starting_objective_key;
	aa.attacking_advice_key = attacking_advice_key;
	aa.sunits_player = sunits_player;
	aa.sunits_enemy = sunits_enemy;
	aa.attacking_objective_key = attacking_objective_key;
	aa.end_callback = end_callback;
	aa.starting_infotext = {};
	aa.attacking_infotext = {};
	aa.attacking_areas = {};
	
	aa.counter = core:get_unique_counter();

	return aa;
end;


function intro_battle_attacking_advice:set_advance_threshold(value)
	if not is_number(value) then
		script_error("ERROR: set_advance_threshold() called, but supplied threshold [" .. tostring(value) .. "] is not a number");
		return false;
	end;
	
	self.advance_threshold = value;
end;


function intro_battle_attacking_advice:set_countercharge_threshold(value)
	if not is_number(value) then
		script_error("ERROR: set_countercharge_threshold() called, but supplied threshold [" .. tostring(value) .. "] is not a number");
		return false;
	end;
	
	self.countercharge_threshold = value;
end;


function intro_battle_attacking_advice:are_enemy_attacking()
	return self.enemy_are_attacking;
end;


function intro_battle_attacking_advice:add_starting_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_starting_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.starting_infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_starting_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.starting_infotext, current_infotext);
		end;
	end;
end;


function intro_battle_attacking_advice:add_attacking_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_attacking_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.attacking_infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_attacking_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.attacking_infotext, current_infotext);
		end;
	end;
end;


function intro_battle_attacking_advice:set_min_attacking_advice_duration(value)
	if not is_number(value) or value < 0 then
		script_error("ERROR: attempt was made to set minimum advice duration but supplied duration [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.min_attacking_advice_duration = value;
end;


function intro_battle_attacking_advice:set_follow_up_advice(key, duration)
	if not is_string(key) then
		script_error("ERROR: attempt was made to set follow up advice but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	if duration and not is_number(duration) then
		script_error("ERROR: attempt was made to set follow up advice but supplied duration [" .. tostring(duration) .. "] is not a number or nil");
		return false;
	else
		self.min_follow_advice_duration = duration;
	end;
	
	self.follow_advice_key = key;
end;


function intro_battle_attacking_advice:add_attacking_area(area)
	if not is_convexarea(area) then
		script_error("ERROR: attempting was made to add attacking area but supplied area [" .. tostring(area) .. "] is not a valid convex area");
		return false;
	end;
	
	table.insert(self.attacking_areas, area);
end;


function intro_battle_attacking_advice:start()
	local bm = get_bm();
	
	-- show advice
	bm:queue_advisor(
		self.starting_advice_key,
		0,
		false,
		function()
			local objective_func = function()
				
				local inner_objective_func = function()
					bm:activate_objective_chain("advancing_advice", self.starting_objective_key);
					
					self:show_advance_position(true);
					
					self:start_player_advance_monitors();
				end;
				
				-- activate the position marker immediately if no cutscene is running, else wait for the cutscene to complete
				if bm:is_any_cutscene_running() then
					core:add_listener(
						"intro_battle_advancing_advice",
						"ScriptEventBattleCutsceneEnded",
						true,
						function() 
							bm:callback(function() inner_objective_func() end, 1000);
						end,
						false
					);
				else
					inner_objective_func();
				end;
			end;
			
			-- show infotext and objective
			if #self.starting_infotext == 0 then
				bm:callback(function() objective_func() end, 1000);
			else
				table.insert(self.starting_infotext, function() objective_func() end);
				bm:add_infotext(self.starting_infotext_delay, unpack(self.starting_infotext));
			end;
		end
	);
end;



function intro_battle_attacking_advice:start_player_advance_monitors()
	local player_alliance = self.sunits_player:item(1).alliance;
	local enemy_sunits = self.sunits_enemy;
	
	-- get the enemy to attack on timeout
	bm:callback(function() self:player_enters_attacking_areas() end, self.attacking_timeout, "intro_battle_attacking_advice");
	
	
	-- watch for the player entering attacking areas - send the enemy to attack if this the case
	bm:watch(
		function()
			for i = 1, #self.attacking_areas do
				if self.attacking_areas[i]:is_in_area(self.sunits_player) then
					return true;
				end;
			end;
			return false;
		end,
		0,
		function()
			self:player_enters_attacking_areas();
		end,
		"intro_battle_attacking_advice"
	);
	
	
	-- watch for player closing on enemy
	bm:watch(
		function()
			return distance_between_forces(self.sunits_player, self.sunits_enemy) < self.advance_threshold;
		end,
		0,
		function()
			-- player is closing on the enemy
			self:player_is_approaching_enemy();
		end
	);
end;



function intro_battle_attacking_advice:player_enters_attacking_areas()
	
	-- send the enemy to attack if they aren't already
	self:attack_with_enemy();
	
	-- play attacking advice if it's not already
	self:player_is_approaching_enemy();
end;



function intro_battle_attacking_advice:attack_with_enemy()
	if self.enemy_are_attacking then
		return;
	end;
	
	self.enemy_are_attacking = true;
	self.sunits_enemy:attack_enemy_scriptunits(self.sunits_player, true);
end;




function intro_battle_attacking_advice:show_advance_position(value)
	if not self.advance_position then
		return;
	end;
	
	local pos = self.advance_position;
	
	if value then
		if not self.advance_position_showing then
			self.advance_position_showing = true;
			bm:add_ping_icon(pos:get_x(), pos:get_y(), pos:get_z(), 13, false);
		end;
	else
		if self.advance_position_showing then
			self.advance_position_showing = false;
			bm:remove_ping_icon(pos:get_x(), pos:get_y(), pos:get_z());
		end;
	end;
end;




function intro_battle_attacking_advice:player_is_approaching_enemy()

	if self.player_approaching_enemy_triggered then
		return;
	end;
	
	self.player_approaching_enemy_triggered = true;

	local bm = get_bm();
	
	bm:remove_process("intro_battle_attacking_advice");
	
	self:show_advance_position(false);
	
	-- show advice
	bm:queue_advisor(
		self.attacking_advice_key,
		self.min_attacking_advice_duration,
		false,
		function()
			local objective_func = function()
				bm:activate_objective_chain("attacking_advice_" .. self.counter, self.attacking_objective_key);
				
				-- don't start engagement monitor until our advice duration has elapsed
				bm:callback(
					function()
						self:start_engagement_monitor();
					end,
					self.min_attacking_advice_duration
				);
			end;
			
			-- show infotext and objective
			if #self.attacking_infotext == 0 then
				bm:callback(function() objective_func() end, 1000);
			else
				table.insert(self.attacking_infotext, function() objective_func() end);
				bm:clear_infotext();
				bm:add_infotext(self.attacking_infotext_delay, unpack(self.attacking_infotext));
			end;
		end
	);
	
	if self.follow_advice_key then
		bm:callback(
			function()
				bm:queue_advisor(
					self.follow_advice_key,
					self.min_follow_advice_duration
				);
			end,
			self.min_attacking_advice_duration + 3000
		);
	end;
end;


function intro_battle_attacking_advice:start_engagement_monitor()

	local bm = get_bm();
	
	bm:out("start_engagement_monitor() called");
	
	-- watch for the player getting very close
	bm:watch(
		function()
			return distance_between_forces(self.sunits_player, self.sunits_enemy) < self.countercharge_threshold;
		end,
		0,
		function()
			-- player is closing on the enemy, have the enemy countercharge
			self:countercharge_enemy();
		end,
		"intro_battle_attacking_advice"
	);
	
	-- have the enemy attack the player on timeout
	bm:callback(function() self:countercharge_enemy() end, self.countercharge_timeout, "intro_battle_attacking_advice");
end;


-- have the enemy countercharge at close range and watch for the two sides engaging in melee
function intro_battle_attacking_advice:countercharge_enemy()
	local bm = get_bm();
	
	bm:remove_process("intro_battle_attacking_advice");
	
	self:show_advance_position(false);
	
	-- instruct enemy to attack, if they're not already
	self:attack_with_enemy();
	
	-- watch for the two sides engaging, and then complete objectives/progress
	bm:watch(
		function()
			return distance_between_forces(self.sunits_player, self.sunits_enemy) < 10;
		end,
		0,
		function()
			bm:complete_objective(self.attacking_objective_key);
			
			bm:callback(
				function()
					bm:end_objective_chain("attacking_advice_" .. self.counter);
				end,
				2000
			);
			
			self.end_callback();
		end,
		"intro_battle_attacking_advice"	
	);
end;




































----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- make player's army vulnerable if separated
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


function make_army_vulnerable_if_separated(player_sunits, enemy_sunits, proximity_threshold, normal_max_casualties, kill_enemy_over_time_period)
	local num_separated_player_sunits = 0;
	
	for i = 1, player_sunits:count() do
		local current_sunit = player_sunits:item(i);
		if distance_between_forces(current_sunit, enemy_sunits) > proximity_threshold then
		
			num_separated_player_sunits = num_separated_player_sunits + 1;
		end;
	end;
	
	bm:out("make_army_vulnerable_if_separated() called, num_separated_player_sunits is " .. num_separated_player_sunits .. ", player_sunits.intro_battle_limiting_casualties is " .. tostring(player_sunits.intro_battle_limiting_casualties));
	
	if num_separated_player_sunits < player_sunits:count() / 3 then
		-- player has more than 2/3rds of their units in the fight, so limit the casualties they can take
		if player_sunits.intro_battle_limiting_casualties ~= true then
			player_sunits.intro_battle_limiting_casualties = true;
			get_bm():out("\tlimiting casualties the player's army can take");
			
			player_sunits:max_casualties(normal_max_casualties, true);
			
			if kill_enemy_over_time_period then
				get_bm():out("\tkilling enemy units over " .. kill_enemy_over_time_period .. "ms");
				enemy_sunits:kill_proportion_over_time(1, kill_enemy_over_time_period, true);
			end;
		end;
	else
		-- player has less than 2/3rds of their units in the fight, so allow them to take unlimited casualties
		if player_sunits.intro_battle_limiting_casualties ~= false then
			player_sunits.intro_battle_limiting_casualties = false;
			get_bm():out("\tallowing player's army to take unlimited casualties");
		
			player_sunits:max_casualties(0, true);
		
			if kill_enemy_over_time_period then
				get_bm():out("\tno longer killing enemy units over time");
				enemy_sunits:stop_kill_proportion_over_time();
			end;
		end;
	end;
	
	bm:callback(function() make_army_vulnerable_if_separated(player_sunits, enemy_sunits, proximity_threshold, normal_max_casualties, kill_enemy_over_time_period) end, 1000, "make_army_vulnerable_if_separated");
end;


function stop_make_army_vulnerable_if_separated()
	bm:remove_process("make_army_vulnerable_if_separated");
end;




























----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- routing advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_ROUTING_ADVICE = "intro_battle_routing_advice";

function is_introbattleroutingadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_ROUTING_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_routing_advice = {
	name = "",
	enemy_routs_advice_key = "",
	min_enemy_routs_advice_duration = 8000,
	player_routs_advice_key = "",
	sunits_player = false,
	sunits_enemy = false,
	enemy_routs_infotext = {},
	enemy_routs_infotext_delay = 0,
	player_routs_infotext = {},
	player_routs_infotext_delay = 0,
	end_callback = false,
	rout_player_army_callback = false
};


	
function intro_battle_routing_advice:new(sunits_player, sunits_enemy, enemy_routs_advice_key, player_routs_advice_key, end_callback, rout_player_army_callback)
	
	if not is_scriptunits(sunits_player) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player scriptunits [" .. tostring(sunits_player) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_player:count() == 0 then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player scriptunits collection is empty");
		return false;
	end;
	
	if not is_scriptunits(sunits_enemy) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied enemy scriptunits [" .. tostring(sunits_enemy) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_enemy:count() == 0 then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied enemy scriptunits collection is empty");
		return false;
	end;
	
	if not is_string(enemy_routs_advice_key) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied enemy-routs advice key [" .. tostring(enemy_routs_advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(player_routs_advice_key) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player-routs advice key [" .. tostring(player_routs_advice_key) .. "] is not a string");
		return false;
	end;
		
	if not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if not is_function(rout_player_army_callback) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied callback to rout the player's army [" .. tostring(rout_player_army_callback) .. "] is not a function");
		return false;
	end;
	
	local aa = {};
	setmetatable(aa, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_ROUTING_ADVICE end;
	
	aa.advice_key = advice_key;
	aa.sunits_player = sunits_player;
	aa.sunits_enemy = sunits_enemy;
	aa.enemy_routs_advice_key = enemy_routs_advice_key;
	aa.player_routs_advice_key = player_routs_advice_key;
	aa.end_callback = end_callback;
	aa.rout_player_army_callback = rout_player_army_callback;
	aa.enemy_routs_infotext = {};
	aa.player_routs_infotext = {};
	
	aa.name = "routing_advice_" .. core:get_unique_counter();

	return aa;
end;


function intro_battle_routing_advice:add_player_routs_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_player_routs_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.player_routs_infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_player_routs_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.player_routs_infotext, current_infotext);
		end;
	end;
end;


function intro_battle_routing_advice:add_enemy_routs_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_enemy_routs_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.enemy_routs_infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_enemy_routs_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.enemy_routs_infotext, current_infotext);
		end;
	end;
end;


function intro_battle_routing_advice:set_min_enemy_routs_advice_duration(value)
	if not is_number(value) or value < 0 then
		script_error("ERROR: attempt was made to set minimum enemy routs advice duration but supplied duration [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.min_enemy_routs_advice_duration = value;
end;


function intro_battle_routing_advice:start()
	local bm = get_bm();
	
	-- watch for any enemy units routing
	local sunits_enemy = self.sunits_enemy;
	bm:watch(
		function()
			return num_units_routing(sunits_enemy) > 0
		end,
		2000,
		function()
			bm:remove_process("intro_battle_routing_advice");
			self:enemy_sunits_routing()
		end,
		"intro_battle_routing_advice"
	);
	
	
	-- watch for any player units routing
	local sunits_player = self.sunits_player;
	bm:watch(
		function()
			return num_units_routing(sunits_player) > 0
		end,
		0,
		function()
			bm:remove_process("intro_battle_routing_advice");
			self:player_sunits_routing();
		end,
		"intro_battle_routing_advice"
	);
end;


function intro_battle_routing_advice:enemy_sunits_routing()
	local bm = get_bm();
	
	bm:stop_advisor_queue();
	
	-- make the player's army invincible and unroutable
	local sunits_player = self.sunits_player;
	sunits_player:morale_behavior_fearless();
	sunits_player:set_invincible(true);	
	
	-- find a routing enemy unit
	local sunits_enemy = self.sunits_enemy;
	local routing_sunit = false;
	
	for i = 1, sunits_enemy:count() do
		local current_sunit = sunits_enemy:item(i);
		if is_routing_or_dead(current_sunit) then
			routing_sunit = current_sunit;
			break;
		end;
	end;
	
	if not routing_sunit then
		script_error("WARNING: intro_battle_routing_advice could not find a routing enemy unit, choosing the first enemy unit instead!")
		routing_sunit = sunits_enemy:item(1);
	end;
	
	-- rout the enemy army over time
	sunits_enemy:rout_over_time(self.min_enemy_routs_advice_duration + 1000);
			
	-- unique name just in case this matches with any other listeners/processes we have going right now
	local cutscene_listener_name = "cutscene_router_" .. self.name;
	
	-- show cutscene illustrating routing unit
	local cutscene_router = cutscene:new(
		self.name,
		self.sunits_player,
		30000,
		function()
			core:remove_listener(cutscene_listener_name);		
			bm:remove_process(cutscene_listener_name);		
			sunits_player:morale_behavior_default();
			sunits_player:set_invincible(false);
			sunits_enemy:morale_behavior_rout();
			self.end_callback();
		end
	);
	
	-- work out initial camera positions
	local initial_cam_targ = v_offset(routing_sunit.unit:position(), 0, 1, 0);
	local initial_cam_pos = v_offset(initial_cam_targ, 9, 6, 15);
	local mid_cam_pos = v_offset(initial_cam_targ, 32, 25, 40);
	
	cutscene_router:set_should_disable_unit_ids(false);
	cutscene_router:set_post_cutscene_fade_time(0);
	-- cutscene_router:set_do_not_end(true);
	cutscene_router:action(function() cam:move_to(initial_cam_pos, initial_cam_targ, 0, false, 0) end, 0);
	
	cutscene_router:action(
		function() 
			-- show advice
			bm:queue_advisor(
				self.enemy_routs_advice_key,
				self.min_enemy_routs_advice_duration
			);
			
			-- show infotext
			if #self.enemy_routs_infotext > 0 then
				bm:add_infotext(self.enemy_routs_infotext_delay, unpack(self.enemy_routs_infotext));
			end;
						
			local advice_finished_func = function()				
				cutscene_router:show_esc_prompt();
			end;
			
			-- highlight the skip button when the advisor finishes talking
			core:add_listener(
				cutscene_listener_name,
				"AdviceFinishedTrigger",
				true,
				function()
					advice_finished_func();
				end,
				false
			);
			
			-- failsafe (remove this when VO goes in)
			bm:callback(function() advice_finished_func() end, self.min_enemy_routs_advice_duration, cutscene_listener_name);
		end, 
		1000
	);
	
	cutscene_router:action(function() cam:move_to(mid_cam_pos, initial_cam_targ, 15, false, 0) end, 1000);
	
	cutscene_router:action(
		function()
			-- work out direction of routing
			local v_direction_of_routing = v_subtract(routing_sunit.unit:position(), initial_cam_targ);
			local enemy_army_centre_point = sunits_enemy:centre_point();
			local enemy_army_destination = v_add(enemy_army_centre_point, v_direction_of_routing);
			
			local final_cam_targ = v_offset(centre_point_table({initial_cam_targ, routing_sunit.unit:position()}), -10, 0, -20);
			local final_cam_pos = v_offset(enemy_army_centre_point, -40, 20, -50);
			
			cam:move_to(final_cam_pos, enemy_army_centre_point, 0, false, 0);
			cam:move_to(final_cam_pos, enemy_army_destination, 30, false, 0);
		end, 
		8000
	);
		
	cutscene_router:start();
end;


function intro_battle_routing_advice:player_sunits_routing()
	local bm = get_bm();
	
	-- make the enemy army invincible and unroutable
	local sunits_enemy = self.sunits_enemy;
	sunits_enemy:morale_behavior_fearless();
	sunits_enemy:set_invincible(true);
	
	-- rout the rest of the player's army
	bm:callback(function() self.rout_player_army_callback() end, 5000);
	
	-- eventually show advice
	bm:callback(
		function()
			bm:queue_advisor(
				self.player_routs_advice_key,
				10000,
				false,
				function()			
					-- show infotext and objective
					if #self.player_routs_infotext > 0 then
						bm:add_infotext(self.player_routs_infotext_delay, unpack(self.player_routs_infotext));
					end;
				end
			);
		end,
		7000
	);
end;
























----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- abilities advice
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

TYPE_INTRO_BATTLE_ABILITIES_ADVICE = "intro_battle_abilities_advice";

function is_introbattleabilitiesadvice(obj)
	if tostring(obj) == TYPE_INTRO_BATTLE_ABILITIES_ADVICE then
		return true;
	end;
	
	return false;
end;


intro_battle_abilities_advice = {
	name = "",
	advice_key = "",
	sunit_player_acting = false,
	acting_sunit_highlight_position = false,
	sunits_player = false,
	sunits_enemy = false,
	objective_key_select_general = "",
	objective_key_use_ability = "",
	end_callback = false,
	infotext = {},
	infotext_delay = 0,
	time_modifier = 0.2,
	restore_cam_time = 2
};


	
function intro_battle_abilities_advice:new(advice_key, sunit_player_acting, sunits_player, sunits_enemy, objective_key_select_general, objective_key_use_ability, end_callback)
	
	if not is_string(advice_key) then
		script_error("ERROR: attempt made to create intro battle abilities advice but supplied player scriptunits [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
		
	if not is_scriptunit(sunit_player_acting) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player scriptunit [" .. tostring(sunit_player_acting) .. "] is not a valid scriptunit");
		return false;
	end;
	
	if not is_scriptunits(sunits_player) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player scriptunits [" .. tostring(sunits_player) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_player:count() == 0 then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied player scriptunits [" .. tostring(sunits_player) .. "] is empty");
		return false;
	end;
	
	if not is_scriptunits(sunits_enemy) then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied enemy scriptunits [" .. tostring(enemy_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if sunits_enemy:count() == 0 then
		script_error("ERROR: attempt made to create intro battle routing advice but supplied enemy scriptunits [" .. tostring(sunits_enemy) .. "] is empty");
		return false;
	end;
	
	if not is_string(objective_key_select_general) then
		script_error("ERROR: attempt made to create intro battle abilities advice but supplied select general objective key [" .. tostring(objective_key_select_general) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key_use_ability) then
		script_error("ERROR: attempt made to create intro battle abilities advice but supplied use ability objective key [" .. tostring(objective_key_use_ability) .. "] is not a string");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: attempt made to create intro battle abilities advice but supplied end callback [" .. tostring(end_callback) .. "] is not a valid function");
		return false;
	end;
	
	local aa = {};
	setmetatable(aa, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTRO_BATTLE_ABILITIES_ADVICE end;
	
	aa.advice_key = advice_key;
	aa.sunit_player_acting = sunit_player_acting;
	aa.sunits_player = sunits_player;
	aa.sunits_enemy = sunits_enemy;
	aa.objective_key_select_general = objective_key_select_general;
	aa.objective_key_use_ability = objective_key_use_ability;
	aa.end_callback = end_callback;
	aa.infotext = {};
	
	aa.name = "abilities_advice_" .. core:get_unique_counter();

	return aa;
end;


function intro_battle_abilities_advice:add_infotext(delay, ...)
	if not is_number(delay) then
		script_error("ERROR: add_infotext() called, but supplied delay [" .. tostring(delay) .. "] is not a number");
		return false;
	end;
	
	self.infotext_delay = delay;

	for i = 1, arg.n do
		local current_infotext = arg[i];
		if not is_string(current_infotext) then
			script_error("ERROR: add_infotext() called but supplied item [" .. i .. "] is not a string, it is a [" .. tostring(current_infotext) .. "]");
			return false;
		else
			table.insert(self.infotext, current_infotext);
		end;
	end;
end;


function intro_battle_abilities_advice:start()

	local bm = get_bm();
	
	-- prevent the player from being able to issue orders
	bm:disable_orders(true);
	
	bm:clear_infotext();
	bm:stop_advisor_queue(true, true);
	
	local pos_enemy_centre = self.sunits_enemy:centre_point();
	local sunit_player_acting = self.sunit_player_acting;
	local player_sunit_pos = sunit_player_acting.unit:position();
	
	local cam_pos = v_offset(distance_along_line(player_sunit_pos, pos_enemy_centre, -15), 0, 5, 0);
	local cam_targ = v_offset(player_sunit_pos, 0, 3, 0);
	
	
	
	--
	-- start cutscene
	--
	
	-- store camera position for restoring later
	bm:cache_camera()
	
	-- prevent camera movement
	bm:enable_camera_movement(false);
	
	-- hide army panel immediately and show portrait panel
	bm:show_army_panel(false, true);
	bm:show_portrait_panel(true);
	
	-- hide flags
	bm:enable_unit_ids(false);
	
	-- reposition camera
	cam:move_to(cam_pos, cam_targ, 1.5, false, 0);
	
	-- adjust rate at which infotext appears
	get_infotext_manager():set_time_speed(self.time_modifier);
	
	-- takes control of the player's army
	self.sunits_player:take_control();
	
	-- teleport the acting sunit to its current position, immediately halting movement, and then release control
	sunit_player_acting.uc:teleport_to_location(player_sunit_pos, sunit_player_acting.unit:bearing(), sunit_player_acting.unit:ordered_width());
	sunit_player_acting:release_control();
	
	-- modify time speed
	bm:modify_battle_speed(self.time_modifier);
	
	-- slow battle speed over time
	bm:slow_game_over_time(1, 0.2, 1000, 10);
	
	bm:callback(
		function()
			-- add objective to infotext
			table.insert(
				self.infotext, 
				function()
					bm:activate_objective_chain(self.name, self.objective_key_select_general);
					
					-- also highlight player general
					self:highlight_player_general(true);
				end
			);
			
			bm:queue_advisor(self.advice_key);
			
			-- show infotext and objective
			if #self.infotext > 0 then
				bm:add_infotext(self.infotext_delay, unpack(self.infotext));
			end;
		end,
		200,
		self.name
	);
	
	-- set up unit selection monitor
	bm:register_unit_selection_callback(
		sunit_player_acting.unit, 
		function(unit, is_selected)
			if is_selected then
				bm:update_objective_chain(self.name, self.objective_key_use_ability);
				
				-- highlight ability buttons
				self:highlight_general_abilities(true);
				
				-- unhighlight player general
				self:highlight_player_general(false);
			else
				bm:update_objective_chain(self.name, self.objective_key_select_general);
				
				--highlight player general
				self:highlight_player_general(true);
				
				-- unhighlight ability buttons
				self:highlight_general_abilities(false);
			end;
		end
	);
	
	-- set up monitor for player using ability
	core:add_listener(
		self.name,
		"ComponentLClickUp",
		function(context) return string.sub(context.string, 1, 14) == "button_ability" end,
		function()
			-- allow the player to issue orders again
			bm:disable_orders(false);
		
			bm:callback(
				function()
					-- unhighlight ability buttons
					self:highlight_general_abilities(false);
				
					bm:complete_objective(self.objective_key_use_ability);
					self:complete() 
				end, 
				100
			);
		end,
		false
	);
end;


function intro_battle_abilities_advice:highlight_player_general(value)
	local bm = get_bm();
	
	if value then
		local marker_pos = v_offset(self.sunit_player_acting.unit:position(), 0, 2, 0);
		self.acting_sunit_highlight_position = marker_pos;
		bm:add_ping_icon(marker_pos:get_x(), marker_pos:get_y(), marker_pos:get_z(), 11, false);
	else
		local marker_pos = self.acting_sunit_highlight_position;
		
		if marker_pos then
			self.acting_sunit_highlight_position = false;
			bm:remove_ping_icon(marker_pos:get_x(), marker_pos:get_y(), marker_pos:get_z());
		end;
	end;
end;


function intro_battle_abilities_advice:highlight_general_abilities(value)
	local uic_ability_parent = find_uicomponent(core:get_ui_root(), "porthole_parent", "ability_parent");
	
	if not uic_ability_parent then
		return false;
	end;
	
	for i = 0, uic_ability_parent:ChildCount() - 1 do
		local uic_slot = UIComponent(uic_ability_parent:Find(i));
		
		for j = 0, uic_slot:ChildCount() - 1 do
			local uic_child = UIComponent(uic_slot:Find(j));
			if string.sub(uic_child:Id(), 1, 14) == "button_ability" then
				uic_child:Highlight(value, false, 100);
			end;
		end;		
	end;
end;


function intro_battle_abilities_advice:complete()
	
	local bm = get_bm();
	
	bm:remove_process(self.name);
		
	-- unregister selection listener	
	bm:unregister_unit_selection_callback(self.sunit_player_acting.unit);
	
	-- prevent camera movement
	bm:enable_camera_movement(true);
	
	-- accelerate game time
	bm:slow_game_over_time(0.2, 1, 500, 5);
	
	bm:callback(
		function()
			-- restore camera position
			bm:camera():move_to(bm:get_cached_camera_pos(), bm:get_cached_camera_targ(), self.restore_cam_time, false, 0);
			
			-- show army panel
			bm:show_army_panel(true);
			
			-- show flags
			bm:enable_unit_ids(true);
			
			self.sunits_player:release_control();
		end,
		100
	);
	
	bm:callback(
		function()
			-- adjust rate at which infotext appears
			get_infotext_manager():set_time_speed(1);
			
			bm:end_objective_chain(self.name);
			
			self.end_callback();
		end,
		500
	);
end;





















----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- second battle helper scripts
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------


function second_battle_start_cutscene_deployment(end_pos, end_targ, cutscene_duration, advice_key, infotext, sunits_player, end_callback)
	
	local cutscene_deployment_length = 5500;
	local player_army = sunits_player:item(1).army;
	local advice_dismissed = false;	
	
	local bool_deployment_zone_highlighted = false;
	local function highlight_deployment_zone(value)
		if value == bool_deployment_zone_highlighted then
			return;
		end;
		
		if value then
			bool_deployment_zone_highlighted = true;
			player_army:highlight_deployment_areas(true);
		else
			bool_deployment_zone_highlighted = false;
			player_army:highlight_deployment_areas(false);
		end;		
	end;
	
	-- show advice outside of cutscene (so that it's still shown if the cutscene is skipped)
	bm:queue_advisor(advice_key);
	bm:add_infotext(unpack(infotext));
	
	local cutscene_deployment = false;
	
	-- listen for advice being dismissed
	bm:progress_on_advice_dismissed(
		function()			
			if cutscene_deployment:is_active() then
				cutscene_deployment:skip();
			end;
		
			highlight_deployment_zone(false);
			
			bm:callback(function() end_callback() end, 500);
		end,
		1000,
		true
	);
	
	cutscene_deployment = cutscene:new(
		"cutscene_deployment", 						-- unique string name for cutscene
		sunits_player, 								-- unitcontroller over player's army
		cutscene_duration,							-- duration of cutscene in ms
		function() 									-- what to call when cutscene is finished			
			highlight_deployment_zone(true);
		
			-- prevent camera movement
			bm:enable_camera_movement(false);
			bm:callback(function() bm:progress_on_advice_dismissed_immediate_highlight() end, 500);
			bm:show_start_battle_button(false);
		end
	);
	
	cutscene_deployment:set_close_advisor_on_start(false);
	cutscene_deployment:set_close_advisor_on_end(false);
	cutscene_deployment:set_post_cutscene_fade_time(0);
	cutscene_deployment:set_should_release_players_army(false);
	-- cutscene_deployment:set_debug(true);
	
	local subtitles = cutscene_deployment:subtitles();
	subtitles:set_alignment("bottom_centre");
	subtitles:clear();
	
	cutscene_deployment:set_skip_camera(end_pos, end_targ);
	
	cutscene_deployment:action(function() cam:fade(false, 0.5) end, 0);
	
	cutscene_deployment:action(function() cam:move_to(end_pos, end_targ, 3.5, false, 0) end, 2000);
	
	cutscene_deployment:action(function() highlight_deployment_zone(true) end, 2000);
	
	cutscene_deployment:start();
end;







function second_battle_start_cutscene_attacker(start_pos, start_targ, end_pos, end_targ, fov, sunits_player, advice_key, infotext, end_callback)

	fov = fov or 0;
	
	local bm = get_bm();
	
	local cutscene_attacking_advice_length = 60000;

	local cutscene_attacking_advice = cutscene:new(
		"cutscene_attacking_advice", 						-- unique string name for cutscene
		sunits_player, 										-- unitcontroller over player's army
		cutscene_attacking_advice_length,					-- duration of cutscene in ms
		function()											-- what to call when cutscene is finished
			bm:remove_process("tp_bop_show");
			core:hide_all_text_pointers();
			end_callback();
		end
	);
	
	cutscene_attacking_advice:set_close_advisor_on_end(false);
	cutscene_attacking_advice:set_post_cutscene_fade_time(0);
	cutscene_attacking_advice:set_skippable(false);			-- cutscene can only be ended by dismissing advice
	cutscene_attacking_advice:set_do_not_end(true);
	cutscene_attacking_advice:set_should_release_players_army(false);
	cutscene_attacking_advice:set_should_hide_ui(false);
	cutscene_attacking_advice:set_steal_input_focus(false);
		
	cutscene_attacking_advice:action(function() cam:move_to(start_pos, start_targ, 3, false, fov) end, 500);
	cutscene_attacking_advice:action(function() cam:move_to(end_pos, end_targ, 56.5, true, fov) end, 3500);
	
	cutscene_attacking_advice:action(
		function() 
			bm:queue_advisor(advice_key, true);
			bm:add_infotext(unpack(infotext));
			
			bm:modify_advice(true);
			
			bm:progress_on_advice_dismissed(
				function()
					bm:modify_advice(false);
					if cutscene_attacking_advice:is_active() then
						cutscene_attacking_advice:skip();
					end;
				end,
				1000,
				true
			);
		end, 
		1000
	);
	
	-- show top bar
	cutscene_attacking_advice:action(function() bm:show_top_bar(true) end, 3500);
	
	-- label top bar
	cutscene_attacking_advice:action(
		function() 
			-- get link to time limit component
			local uic_timer = find_uicomponent(core:get_ui_root(), "layout", "BOP_frame", "simple_timer");
			
			if not uic_timer then
				script_error("ERROR: play_battle_attacker_advice() can not find uic_timer, how can this be?");
				return;
			end;
			
			-- check that the timer is visible
			local timer_visible = false;
			if uic_timer:Visible() then
				timer_visible = true;
			end;
			
			local timer_pos_x, timer_pos_y = uic_timer:Position();
			local timer_size_x, timer_size_y = uic_timer:Dimensions();
				
			-- set up text pointer labelling it
			local tp_time_limit = text_pointer:new(
				"time_limit", 
				timer_pos_x + (timer_size_x / 2), 
				timer_pos_y + timer_size_y, 
				200, 
				"top"
			);
			tp_time_limit:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_time_limit");
			tp_time_limit:set_priority(1500);
			tp_time_limit:set_panel_width(250);
			tp_time_limit:set_topmost();
			tp_time_limit:set_label_offset(80, 0);
			
			-- get link to BOP component
			local uic_bop = find_uicomponent(core:get_ui_root(), "layout", "BOP_frame", "kill_ratio_PH");
			
			if not uic_bop then
				script_error("ERROR: play_battle_attacker_advice() can not find uic_bop, how can this be?");
				return;
			end;
			
			local bop_pos_x, bop_pos_y = uic_bop:Position();
			local bop_size_x, bop_size_y = uic_bop:Dimensions();
			
			-- set up text pointer labelling it
			local tp_bop = text_pointer:new(
				"balance_of_power", 
				bop_pos_x + (bop_size_x / 2), 
				bop_pos_y + bop_size_y, 
				80, 
				"top"
			);
			tp_bop:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_balance_of_power");
			tp_bop:set_priority(1500);
			tp_bop:set_panel_width(250);
			tp_bop:set_topmost();
			tp_bop:set_label_offset(80, 0);
			
			-- show text pointers
			if timer_visible then
				tp_time_limit:show();
			end;
			bm:callback(function() tp_bop:show() end, 500, "tp_bop_show");
		end, 
		5500
	);
	
	
	cutscene_attacking_advice:start();
end;





function second_battle_start_cutscene_forest(start_pos, start_targ, end_pos, end_targ, sunits_player_all, advice_key, infotext, end_callback)
	
	local cutscene_forest_deployment_length = 8000;

	local cutscene_forest_deployment = cutscene:new(
		"cutscene_forest_deployment", 				-- unique string name for cutscene
		sunits_player_all, 							-- unitcontroller over player's army
		cutscene_forest_deployment_length,			-- duration of cutscene in ms
		function() 									-- what to call when cutscene is finished
			bm:modify_advice(false);
			
			-- allow camera movement again
			bm:enable_camera_movement(true);
			
			end_callback();
		end
	);
	
	cutscene_forest_deployment:set_close_advisor_on_end(false);
	cutscene_forest_deployment:set_post_cutscene_fade_time(0);
	-- cutscene_forest_deployment:set_debug(true);
	
	cutscene_forest_deployment:set_skip_camera(end_pos, end_targ);
	
	cutscene_forest_deployment:action(function() cam:fade(false, 0.5) end, 0);
	
	cutscene_forest_deployment:action(function() cam:move_to(start_pos, start_targ, 2.5, false, 0) end, 500);
	
	cutscene_forest_deployment:action(function() cam:move_to(end_pos, end_targ, 2.5, false, 0) end, 5500);
	
	cutscene_forest_deployment:start();
	
	-- show advice outside of cutscene (so that it's still shown if the cutscene is skipped)
	bm:callback(
		function() 
			bm:queue_advisor(advice_key);
			bm:add_infotext(unpack(infotext));
			
			bm:progress_on_advice_dismissed(
				function() 
					if cutscene_forest_deployment:is_active() then
						cutscene_forest_deployment:skip();
					end;
				end
			);
		end,
		1000
	);
end;





function second_battle_monitor_for_player_deployment_in_forest(sunits_forest, sunits_non_forest, sunits_player_all, objective_key, advice_key, infotext, offset_vector, end_callback)
	
	-- disable all non-forest player units
	sunits_non_forest:take_control();

	-- highlight unit cards
	sunits_forest:highlight_unit_cards(true, nil, true);
	
	bm:watch(
		function()
			return sunits_forest:is_hidden(true);
		end,
		0,
		function()
			second_battle_player_has_deployed_in_forest(sunits_forest, sunits_non_forest, sunits_player_all, objective_key, advice_key, infotext, offset_vector, end_callback)
		end
	);
	
	-- show rest of ui
	bm:callback(
		function()
			bm:show_army_panel(true);
			
			second_battle_show_button_toggle_unit_cards(false);
		end, 
		1000
	);
	
	bm:set_objective(objective_key);
end;


function second_battle_show_button_toggle_unit_cards(value)
	local uic_toggle_army_panel = find_uicomponent(core:get_ui_root(), "battle_orders", "bottom_bar", "button_toggle_cards");
	if not uic_toggle_army_panel then
		script_error("ERROR: second_battle_show_button_toggle_unit_cards() could not find uic_toggle_army_panel, how can this be?");
		return false;
	end;
	
	if value == false then
		uic_toggle_army_panel:SetVisible(false);
	else
		uic_toggle_army_panel:SetVisible(true);
	end;
end;


function second_battle_player_has_deployed_in_forest(sunits_forest, sunits_non_forest, sunits_player_all, objective_key, advice_key, infotext, offset_vector, end_callback)

	bm:out("second_battle_player_has_deployed_in_forest() called");
	
	local advice_is_dismissed = false;
	local cutscene_is_finished = false;
	
	local function attempt_to_progress()
		if not (advice_is_dismissed and cutscene_is_finished) then
			return;
		end;
		
		-- hide text pointer for "hidden" units
		core:hide_all_text_pointers();
		
		bm:callback(function() end_callback() end, 500);
	end;
	
	-- take control of forest units
	sunits_forest:take_control();

	-- unhighlight unit cards - wait a little to allow the cutscene to take control away from the player 
	-- bm:callback(function() sunits_forest:highlight_unit_cards(false, nil, true) end, 500);
	bm:callback(function() bm:get_battle_ui_manager():unhighlight_all_for_tooltips(); end, 500);
	
	-- get the centre position of the units we've just placed
	local pos_centre = sunits_forest:centre_point();
	
	-- get a position for the camera to look at this target, with the same relative facing/distance as current
	local cam_pos = v_add(pos_centre, offset_vector);
	
	-- declare and run cutscene
	local cutscene_forest_deployment_completed_length = 3000;

	local cutscene_forest_deployment_completed = cutscene:new(
		"cutscene_forest_deployment_completed", 				-- unique string name for cutscene
		sunits_player_all,										-- unitcontroller over player's army
		cutscene_forest_deployment_completed_length,			-- duration of cutscene in ms
		function() 												-- what to call when cutscene is finished
			cutscene_is_finished = true;
		
			-- disable all player units after cutscene
			sunits_player_all:take_control();
			
			if advice_is_dismissed then
				attempt_to_progress();
			else
				bm:modify_advice(true);
				bm:callback(function() second_battle_indicate_unit_card_hidden_status() end, 600, "second_battle_indicate_unit_card_hidden_status");
			end;
		end
	);
	
	cutscene_forest_deployment_completed:set_close_advisor_on_end(false);
	cutscene_forest_deployment_completed:set_post_cutscene_fade_time(0);
	-- cutscene_forest_deployment_completed:set_debug(true);
	
	cutscene_forest_deployment_completed:set_skippable(true, function() bm:progress_on_advice_dismissed_immediate_highlight() end);
	
	cutscene_forest_deployment_completed:set_skip_camera(cam_pos, pos_centre);
	
	cutscene_forest_deployment_completed:action(function() cam:move_to(cam_pos, pos_centre, 3, false, 0) end, 500);
	
	cutscene_forest_deployment_completed:start();
	

	-- advice
	bm:queue_advisor(advice_key);
	bm:add_infotext(unpack(infotext));
	
	bm:complete_objective(objective_key);
	
	bm:callback(function() bm:remove_objective(objective_key) end, 2000);
	
	bm:progress_on_advice_dismissed(
		function()
			advice_is_dismissed = true;
			
			bm:remove_process("second_battle_indicate_unit_card_hidden_status");
		
			attempt_to_progress();
		end, 
		1000, 
		true
	);
end;


function second_battle_indicate_unit_card_hidden_status()
	
	-- find first unit card with "hidden" component visible
	local uic_unit_card_parent = find_uicomponent(core:get_ui_root(), "battle_orders", "cards_panel", "review_DY");
	
	if not uic_unit_card_parent then
		script_error("ERROR: indicate_unit_card_hidden_status() could not find uic_unit_card_parent, how can this be?");
		return false;
	end;
	
	local uic_icon_hidden = false;
	
	for i = 0, uic_unit_card_parent:ChildCount() - 1 do
		local uic_current_unit_card = UIComponent(uic_unit_card_parent:Find(i));
			
		uic_current_icon_hidden = find_uicomponent(uic_current_unit_card, "battle", "status_list", "hidden");
		
		if uic_current_icon_hidden and uic_current_icon_hidden:Visible() then
			uic_icon_hidden = uic_current_icon_hidden;
			break;
		end;
	end;
	
	if not uic_icon_hidden then
		script_error("ERROR: indicate_unit_card_hidden_status() could not find a unit card with an hidden sub-component, how can this be?");
		return false;
	end;
	
	local hidden_pos_x, hidden_pos_y = uic_icon_hidden:Position();
	local hidden_size_x, hidden_size_y = uic_icon_hidden:Dimensions();
	
	-- set up text pointer labelling it
	local tp_hidden = text_pointer:new(
		"hidden", 
		hidden_pos_x + (hidden_size_x / 2), 
		hidden_pos_y + (hidden_size_y / 2), 
		60, 
		"bottom"
	);
	tp_hidden:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_hidden");
	tp_hidden:set_style("semitransparent");
	
	tp_hidden:show()
end;




function second_battle_show_unit_card_features(advice_key, infotext, end_callback)

	core:cache_and_set_advisor_priority(1500, true);
	
	local uim = bm:get_battle_ui_manager();
	
	-- show fullscreen highlight
	local uic_unit_card_parent = find_uicomponent(core:get_ui_root(), "battle_orders", "cards_panel", "review_DY");
	core:show_fullscreen_highlight_around_components(15, nil, uic_unit_card_parent);
	
	-- set all unit cards to be active, so that they appear normally, but cache their previous state
	--[[
	local unit_card_states = {};
	for i = 0, uic_unit_card_parent:ChildCount() - 1 do
		local current_unit_card = UIComponent(uic_unit_card_parent:Find(i));
		unit_card_states[i] = current_unit_card:CurrentState();
		current_unit_card:SetState("active");
	end;
	]]
	
	-- lock battle camera
	bm:enable_camera_movement(false);
	
	-- set up text pointer indicating experience level of second unit
	local uic_player_general_xp = find_uicomponent(UIComponent(uic_unit_card_parent:Find(1)), "experience");
	
	local player_general_xp_pos_x, player_general_xp_pos_y = uic_player_general_xp:Position();
	local player_general_xp_size_x, player_general_xp_size_y = uic_player_general_xp:Dimensions();
	
	local tp_unit_xp = text_pointer:new(
		"unit_xp", 
		player_general_xp_pos_x + (player_general_xp_size_x / 2), 
		player_general_xp_pos_y + (player_general_xp_size_y / 2), 
		150, 
		"right"
	);
	tp_unit_xp:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_unit_experience");
	tp_unit_xp:set_style("semitransparent_2_sec_highlight");
	tp_unit_xp:set_panel_width(300);
	
	-- set up text pointer indicating health of second unit
	local uic_player_second_health = find_uicomponent(UIComponent(uic_unit_card_parent:Find(1)), "health_frame");
	
	local player_second_health_pos_x, player_second_health_pos_y = uic_player_second_health:Position();
	local player_second_health_size_x, player_second_health_size_y = uic_player_second_health:Dimensions();
	
	local tp_unit_health = text_pointer:new(
		"unit_health", 
		player_second_health_pos_x + (player_second_health_size_x * 3 / 4), 
		player_second_health_pos_y + (player_second_health_size_y / 2), 
		100, 
		"bottom"
	);
	tp_unit_health:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_unit_health");
	tp_unit_health:set_style("semitransparent_2_sec_highlight");
	tp_unit_health:set_label_offset(-100, 0);
	tp_unit_health:set_panel_width(300);
	
	-- find the first unit card with ammo, and set up text pointer
	local uic_player_ammo = false;
	for i = 0, uic_unit_card_parent:ChildCount() - 1 do
		local uic_current_player_ammo = find_uicomponent(UIComponent(uic_unit_card_parent:Find(i)), "AmmoBar");
		if uic_current_player_ammo:Visible(true) then
			uic_player_ammo = uic_current_player_ammo;
			break
		end;
	end;
	
	if not uic_player_ammo then
		script_error("ERROR: show_unit_card_features() couldn't find any unit card with visible ammunition bar, how can this be?");
		return false;
	end;
	
	local player_ammo_pos_x, player_ammo_pos_y = uic_player_ammo:Position();
	local player_ammo_size_x, player_ammo_size_y = uic_player_ammo:Dimensions();
	
	local tp_unit_ammo = text_pointer:new(
		"unit_ammo", 
		player_ammo_pos_x + (player_ammo_size_x * 3 / 4), 
		player_ammo_pos_y + (player_ammo_size_y / 2), 
		100, 
		"bottom"
	);
	tp_unit_ammo:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_unit_ammo");
	tp_unit_ammo:set_style("semitransparent_2_sec_highlight");
	tp_unit_ammo:set_label_offset(100, 0);
	tp_unit_ammo:set_panel_width(300);
	
	-- set up text pointer indicating wavering status of last unit
	local uic_player_wavering = UIComponent(uic_unit_card_parent:Find(uic_unit_card_parent:ChildCount() - 1));
	local uic_player_wavering_cached_state = false;
	
	local player_wavering_pos_x, player_wavering_pos_y = uic_player_wavering:Position();
	local player_wavering_size_x, player_wavering_size_y = uic_player_wavering:Dimensions();
	
	local tp_unit_wavering = text_pointer:new(
		"unit_wavering", 
		player_wavering_pos_x + (player_wavering_size_x / 2), 
		player_wavering_pos_y + (player_wavering_size_y / 2), 
		100, 
		"left"
	);
	tp_unit_wavering:add_component_text("text", "ui_text_replacements_localised_text_wh2_intro_battle_unit_wavering");
	tp_unit_wavering:set_style("semitransparent_2_sec_highlight");
	tp_unit_wavering:set_panel_width(250);
	
	-- show first tooltip pointer
	bm:callback(
		function() 
			uim:highlight_unit_cards(true, nil, true, false, false, true);		-- highlight chevrons
			tp_unit_xp:show() 
		end,
		1000
	);
	
	-- set up text pointer progression
	tp_unit_xp:set_close_button_callback(
		function()
			uim:unhighlight_all_for_tooltips();
			
			bm:callback(
				function()
					uim:highlight_unit_cards(true, nil, true, true, false, false);		-- highlight health bars
					tp_unit_health:show();
				end,
				200
			);
		end
	);
	
	tp_unit_health:set_close_button_callback(
		function()
			uim:unhighlight_all_for_tooltips();
			
			bm:callback(
				function()
					uim:highlight_unit_cards(true, nil, true, false, true, false);		-- highlight ammo bars
					tp_unit_ammo:show();
				end,
				200
			);
		end
	);
	
	tp_unit_ammo:set_close_button_callback(
		function()
			uim:unhighlight_all_for_tooltips();
			
			bm:callback(
				function()
					uic_player_wavering_cached_state = uic_player_wavering:CurrentState();
					uic_player_wavering:SetState("wavering");
					tp_unit_wavering:show();
				end,
				200
			);
		end
	);
	
	tp_unit_wavering:set_close_button_callback(
		function()
			-- deactivate panel highlight
			core:hide_fullscreen_highlight();
		
			-- hide text pointer for "hidden" units
			bm:callback(function() core:hide_all_text_pointers() end, 500);
			
			bm:callback(
				function() 
					core:restore_advisor_priority();
					
					uic_player_wavering:SetState(uic_player_wavering_cached_state);
					
					-- restore each unit card's previously cached state
					--[[
					for i = 0, uic_unit_card_parent:ChildCount() - 1 do	
						UIComponent(uic_unit_card_parent:Find(i)):SetState(unit_card_states[i]);
					end;
					]]
					
					-- unlock battle camera
					bm:enable_camera_movement(true);
					
					end_callback();
				end, 
				1000
			);
		end,
		500
	);
	
	-- Pay attention to your Unit cards, my Lord, for they indicate the status of your troops. Be mindful of your army: success on the battlefield depends upon it.
	bm:queue_advisor(advice_key);
	bm:add_infotext(unpack(infotext));
	
	bm:modify_advice(false);
end;








function second_battle_start_hill_deployment(start_pos, start_targ, end_pos, end_targ, start_advice_key, player_forest_sunits, player_non_forest_sunits, area, marker_pos, objective_key, end_camera_offset, end_advice_key, end_callback)
	
	local cutscene_hill_deployment_length = 8000;

	local cutscene_hill_deployment = cutscene:new(
		"cutscene_hill_deployment", 				-- unique string name for cutscene
		sunits_player_all, 							-- unitcontroller over player's army
		cutscene_hill_deployment_length,			-- duration of cutscene in ms
		function() 									-- what to call when cutscene is finished
			second_battle_monitor_for_hill_deployment(player_forest_sunits, player_non_forest_sunits, area, marker_pos, objective_key, end_camera_offset, end_advice_key, end_callback);
		end
	);
	
	cutscene_hill_deployment:set_close_advisor_on_end(false);
	cutscene_hill_deployment:set_post_cutscene_fade_time(0);
	-- cutscene_hill_deployment:set_debug(true);
	
	cutscene_hill_deployment:set_skip_camera(end_pos, end_targ);
		
	cutscene_hill_deployment:action(function() cam:move_to(start_pos, start_targ, 3.5, false, 0) end, 500);
	
	cutscene_hill_deployment:action(function() cam:move_to(end_pos, end_targ, 2.5, false, 0) end, 5500);
	
	cutscene_hill_deployment:start();
	
	-- show advice outside of cutscene (so that it's still shown if the cutscene is skipped)
	bm:callback(
		function() 
			bm:queue_advisor(start_advice_key);			
			bm:modify_advice(true);
		end,
		1000
	);

end;


function second_battle_monitor_for_hill_deployment(player_forest_sunits, player_non_forest_sunits, area, marker_pos, objective_key, end_camera_offset, end_advice_key, end_callback)

	bm:modify_advice(true);
	
	-- disable all units deployed in forest
	player_forest_sunits:take_control();

	-- highlight unit cards of units not deployed in forest
	player_non_forest_sunits:highlight_unit_cards(true);
	
	-- show marker
	bm:callback(
		function() 
			bm:add_ping_icon(marker_pos:get_x(), marker_pos:get_y(), marker_pos:get_z(), 13, false) 
		end,
		1000,
		"hill_deployment_marker"
	);
	
	local num_player_non_forest = player_non_forest_sunits:count();
	bm:watch(
		function()
			return area_hill_deployment:number_in_area(player_non_forest_sunits) == num_player_non_forest;
		end,
		0,
		function()
			second_battle_player_has_deployed_on_hill(player_forest_sunits, player_non_forest_sunits, area, marker_pos, objective_key, end_camera_offset, end_advice_key, end_callback)
		end
	);
		
	bm:set_objective(objective_key);
end;


function second_battle_player_has_deployed_on_hill(player_forest_sunits, player_non_forest_sunits, area, marker_pos, objective_key, end_camera_offset, end_advice_key, end_callback)

	bm:remove_process("hill_deployment_marker");

	-- unhighlight unit cards - wait a little to allow the cutscene to take control away from the player 
	bm:callback(function() player_non_forest_sunits:highlight_unit_cards(false) end, 500);
	
	-- remove marker
	bm:remove_ping_icon(marker_pos:get_x(), marker_pos:get_y(), marker_pos:get_z());
	
	-- get the centre position of the units we've just placed
	local pos_centre = v_offset(player_non_forest_sunits:centre_point(), 0, 30, 0);
	
	-- get a position for the camera to look at this target, with the same relative facing/distance as current
	local cam_pos = v_add(pos_centre, end_camera_offset);
	
	-- declare and run cutscene
	local cutscene_hill_deployment_completed_length = 2500;

	local cutscene_hill_deployment_completed = cutscene:new(
		"cutscene_hill_deployment_completed", 					-- unique string name for cutscene
		player_non_forest_sunits, 								-- unitcontroller over player's army
		cutscene_hill_deployment_completed_length,				-- duration of cutscene in ms
		function() 												-- what to call when cutscene is finished
			second_battle_show_button_toggle_unit_cards(true);
			end_callback()
		end
	);
	
	cutscene_hill_deployment_completed:set_close_advisor_on_end(false);
	cutscene_hill_deployment_completed:set_close_advisor_on_end(false);
	cutscene_hill_deployment_completed:set_post_cutscene_fade_time(0);
	-- cutscene_forest_deployment_completed:set_debug(true);
	
	cutscene_hill_deployment_completed:set_skip_camera(cam_pos, pos_centre);
		
	cutscene_hill_deployment_completed:action(function() cam:move_to(cam_pos, pos_centre, 2, false, 0) end, 500);
	
	cutscene_hill_deployment_completed:start();
	
	-- advice
	-- Good! Your troops are ready, my Lord. Just give the signal and the engagement shall begin!
	bm:callback(function() bm:queue_advisor(end_advice_key) end, 500);
	
	-- remove previous objective
	bm:complete_objective(objective_key);
	bm:callback(function() bm:remove_objective(objective_key) end, 1000);
end;


