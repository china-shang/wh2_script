



---	@loaded_in_campaign

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN INTERVENTION MANAGER
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------
-- declaration
----------------------------------------------------------------------------


intervention_manager = {
	uim = nil,
	intervention_system_debug = false,
	persistent_intervention_list = {},			-- list of persistent interventions saved into the savegame. Names of each must be unique.
	transient_intervention_list = {},			-- list of transient interventions that are not saved into the savegame. Names can be shared.
	intervention_listeners = {},
	current_eligible_interventions = {},
	intervention_currently_active = false,
	intervention_pending = false,
	event_feed_suppressed = false,
	current_max_session_cost = false,			-- will be overwritten on construction
	current_expenditure = 0,
	tab_level = 0,
	is_waiting_for_battle_completion = false,
	is_waiting_for_dilemma_completion = false,
	is_waiting_for_event_dismissed = false,
	is_waiting_for_fullscreen_panel_dismissed = false,
	interventions_to_trigger_on_next_player_faction_turn_start = {},
	num_interventions_in_current_sequence = 0,
	has_locked_ui = false,
	output_stamp = 0,
	intervention_system_last_advice_reset = 1,
	allow_ui_hiding_on_completion = true
};







----------------------------------------------------------------------------
-- creation
----------------------------------------------------------------------------

function intervention_manager:new()
	
	local uim = cm:get_campaign_ui_manager();
	
	local im = {};
	setmetatable(im, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTERVENTION_MANAGER end;
	
	im.current_max_session_cost = cm.campaign_intervention_max_cost_points_per_session;
	
	im:out("");
	im:out("");
	im:out("*********************************");
	im:out("intervention_manager:new() called");
	im:out("max session cost: " .. im.current_max_session_cost);
	im:out("*********************************");
	
	im.uim = uim;
	im.persistent_intervention_list = {};
	im.transient_intervention_list = {};
	im.intervention_listeners = {};
	im.current_eligible_interventions = {};
	im.interventions_to_trigger_on_next_player_faction_turn_start = {};
	
	cm:set_intervention_manager(im);
	
	core:add_listener(
		"intervention_manager_player_faction_turn_start",
		"ScriptEventPlayerFactionTurnStart",
		true,
		function() im:trigger_player_faction_turn_start_interventions() end,
		true
	);
	
	core:add_listener(
		"intervention_manager_advice_history_cleared_listener",
		"AdviceCleared",
		true,
		function() im:advice_history_cleared() end,
		true
	);
	
	-- load in the last turn the advice history was reset on
	core:add_listener(
		"intervention_manager_startup",
		"UICreated",
		true,
		function()
			local turn_number_last_reset = cm:get_saved_value("intervention_system_last_advice_reset");
	
			if turn_number_last_reset then
				self.intervention_system_last_advice_reset = turn_number_last_reset;
			end;
		end,
		false
	);
	
	return im;
end;








----------------------------------------------------------------------------
-- output
----------------------------------------------------------------------------

function intervention_manager:inc_tab()
	self.tab_level = self.tab_level + 1;
end;

function intervention_manager:dec_tab()
	if self.tab_level > 0 then
		self.tab_level = self.tab_level - 1;
	end;
end;

function intervention_manager:out(input)
	local output_str = "";
	
	for i = 1, self.tab_level do
		output_str = output_str .. "\t";
	end;
	
	output_str = output_str .. tostring(input);
	
	out.interventions(output_str);
end;


function intervention_manager:get_next_output_stamp()
	self.output_stamp = self.output_stamp + 1;
	return self.output_stamp;
end;






----------------------------------------------------------------------------
-- cached camera position
-- used by the im to work out whether it needs to restore the camera
-- position after completing an intervention
----------------------------------------------------------------------------

function intervention_manager:cache_camera_position()
	self.camera_cache_position_set = true;
	cm:cache_camera_position("intervention_manager");
end;


function intervention_manager:camera_has_moved_from_cached()
	return cm:camera_has_moved_from_cached("intervention_manager");
end;


function intervention_manager:reset_cached_camera_position()
	self.camera_cache_position_set = false;
	cm:delete_cached_camera_position("intervention_manager")
end;







----------------------------------------------------------------------------
-- intervention registration and querying
----------------------------------------------------------------------------

function intervention_manager:register_intervention(intervention, is_transient)
	if is_transient then
		table.insert(self.transient_intervention_list, intervention);
	else
		table.insert(self.persistent_intervention_list, intervention);
	end;
end;


function intervention_manager:get_persistent_intervention(name)
	local persistent_intervention_list = self.persistent_intervention_list;
	
	for i = 1, #persistent_intervention_list do
		local current_intervention = persistent_intervention_list[i];
		if current_intervention.name == name then
			return current_intervention;
		end;
	end;
end;


-- returns true if the currently playing intervention is the first in the current sequence (so the calling script can pad the intro a bit more),
-- false otherwise. If no intervention is currently playing this returns false.
function intervention_manager:first_intervention_in_sequence()
	return self.num_interventions_in_current_sequence == 1;
end;


-- returns whether any intervention is currently active
function intervention_manager:is_any_intervention_active()
	return self.intervention_currently_active;
end;







----------------------------------------------------------------------------
-- registering/unregistering standard intervention listeners
----------------------------------------------------------------------------

function intervention_manager:listen_for_event(event_name)
	-- if we have no listener table for this event, make one and start listening for it
	if not self.intervention_listeners[event_name] then
		self.intervention_listeners[event_name] = {};
		
		core:add_listener(
			"intervention_manager_" .. event_name,
			event_name,
			true,
			function(context)
				self:event_triggered(event_name, context);
			
				--[[
				core:monitor_performance(
					function()
						self:event_triggered(event_name, context)
					end,
					0.02, 
					"intervention_manager_listen_for_event_" .. event_name
				);
				]]
			end,
			true
		);
	end;
end;

function intervention_manager:register_intervention_listener(intervention, event_name, check)
	self:listen_for_event(event_name);

	-- build a listener record
	local listener_record = {};
	listener_record.intervention = intervention;
	listener_record.check = check;
	
	-- add this record to the listener table
	table.insert(self.intervention_listeners[event_name], listener_record);
end;


function intervention_manager:unregister_intervention_listener(intervention, event_name)
	local intervention_listeners = self.intervention_listeners[event_name];
	
	-- error if we can't find a table for this event
	if not intervention_listeners then
		script_error("WARNING: unregister_intervention_listener() called but no table was found for supplied event [" .. event_name .. "], intervention is [" .. intervention.name .. "]");
		return;
	end;
	
	for i = #intervention_listeners, 1, -1 do
		local current_intervention = intervention_listeners[i].intervention;
		
		if current_intervention == intervention then
			table.remove(intervention_listeners, i);
		end;
	end;
end;











----------------------------------------------------------------------------
-- event has been triggered
----------------------------------------------------------------------------

function intervention_manager:event_triggered(event_name, context)
	local separator_str = "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
	
	if self.intervention_system_debug then
		local output_stamp = self:get_next_output_stamp();
	
		self:out("");
		self:out(separator_str);
		--out("# intervention_manager:event_triggered() called, output_stamp is [" .. output_stamp .. "] and event is " .. event_name .. " - see interventions tab for more output");
		out.inc_tab();
		self:out("intervention_manager:event_triggered() called, output_stamp is [" .. output_stamp .. "] and event is " .. event_name);
		self:inc_tab();
		self:out("current advice level is " .. tostring(effect.get_advice_level()));
	end;
		
	-- find the intervention listener table associated with this event
	local intervention_listeners = self.intervention_listeners[event_name];
	
	-- if it doesn't exist then assert, as this shouldn't happen
	if not intervention_listeners then
		script_error("WARNING: intervention_manager:event_triggered() called for event [" .. event_name .. "] but supplied intervention listeners list doesn't exist, how can this be?");
		if self.intervention_system_debug then
			self:out("event not registered?!");
			self:dec_tab();
			out.dec_tab();
			self:out(separator_str);
		end;
		return false;
	end;
		
	-- determine a list of eligible interventions - those that pass their trigger condition check
	local eligible_interventions = {};
	local next_intervention_suppress_pause_before_triggering = false;
	
	if intervention_listeners then
		-- make a copy of the list of interventions we need to query - they can be removed from the original list which throws this loop out
		local copied_intervention_list = {};
		for i = 1, #intervention_listeners do
			copied_intervention_list[i] = intervention_listeners[i];
		end;
		
		if self.intervention_system_debug then
			self:out("number of interventions we have listening for this event: " .. #copied_intervention_list);
		end;
				
		for i = 1, #copied_intervention_list do
			local current_record = copied_intervention_list[i];
			local current_intervention = current_record.intervention;
			
			if self.intervention_system_debug then
				self:out("\tquerying intervention " .. current_intervention.name);
			end;
			
			--
			-- see if this intervention is eligible for triggering
			--
			
			-- if it's already enqueued for triggering then don't proceed, as it's going to trigger in a bit anyway
			if current_intervention.is_enqueued_for_triggering then
				if self.intervention_system_debug then
					self:out("\t\talready enqueued, skipping");
				end;
			
			-- if it's currently playing then don't proceed
			elseif current_intervention.is_active then
				if self.intervention_system_debug then
					self:out("\t\tcurrently playing, skipping");
				end;
			
			-- see if the advice level permits this intervention from happening
			elseif current_intervention.min_advice_level > effect.get_advice_level() then
				if self.intervention_system_debug then
					self:out("\t\tadvice minimum advice level [" .. current_intervention.min_advice_level .. "] is greater than current advice level setting [" .. effect.get_advice_level() .. "] (0 = no advice, 1 = low advice, 2 = high advice)");
				end;
			
			-- see if the minimum number of turns since the advice history was last reset have passed
			elseif current_intervention:get_min_turn() + self.intervention_system_last_advice_reset - 1 > cm:model():turn_number() then
				if self.intervention_system_debug then
					self:out("\t\tadvice was last reset on turn [" .. self.intervention_system_last_advice_reset .. "], this intervention can't play for [" .. current_intervention:get_min_turn() .. "] turns afterwards (inclusive of the turn it was reset), and it's only turn [" .. cm:model():turn_number() .. "], skipping");
				end;

			-- if we can't play advice then no interventions pass their precondition check
			elseif not cm:is_advice_enabled() and not current_intervention.allow_when_advice_disabled then
				if self.intervention_system_debug then
					self:out("\t\tadvice is disabled, stopping this intervention");
				end;
				
				current_intervention:stop();
			
			-- if it fails its precondition check then stop it outright
			elseif not current_intervention:passes_precondition_check() then
				if self.intervention_system_debug then
					self:out("\t\tintervention has failed its precondition check, stopping it");
				end;
			
				current_intervention:stop();
				
			-- check the intervention's triggering conditions
			elseif not (current_record.check == true or current_record.check(context)) then
				if self.intervention_system_debug then
					self:out("\t\tintervention check does not pass");
				end;
			else			
				-- the intervention has passed all tests, add it to the eligible list
				if self.intervention_system_debug then
					self:out("\t\tintervention check passes, adding to eligible list");
				end;
				
				-- prevent this intervention from triggering again while it is queued
				current_intervention.is_enqueued_for_triggering = true;
				
				-- If the suppress events before startup flag is set then we suppress the grace period that usually happens before triggering an event.
				-- This is useful for interventions that want to kick something big off like a fullscreen movie at the start of a turn.
				if current_intervention.suppress_pause_before_triggering then
					if self.intervention_system_debug then
						self:out("\t\twill suppress event wait period before starting this intervention");
					end;
				
					next_intervention_suppress_pause_before_triggering = true;
				end;
				
				table.insert(eligible_interventions, current_intervention);
			end;
		end;
	end;
	
	-- if we have no eligible interventions then don't bother continuing
	if #eligible_interventions == 0 then
		if self.intervention_system_debug then
			self:out("none of these are eligible");	
		end;
		if self.intervention_system_debug then
			self:dec_tab();
			out.dec_tab();
			self:out(separator_str);
		end;
		return;
	end;
	
	-- add our eligible interventions to the global queue (will be sorted later)
	local current_eligible_interventions = self.current_eligible_interventions;
	
	for i = 1, #eligible_interventions do
		table.insert(current_eligible_interventions, eligible_interventions[i]);
	end;
	
	if self.intervention_system_debug then
		self:dec_tab();
		out.dec_tab();
		self:out(separator_str);
	end;
	
	-- attempt to start next intervention
	self:attempt_to_start_next_intervention(next_intervention_suppress_pause_before_triggering);
end;










function intervention_manager:sort_interventions()
	
	local uim = cm:get_campaign_ui_manager();
	
	-- is there an event panel open, a fullscreen panel open or are we currently processing battle
	local dilemma_open =  CampaignUI.DoesEventTypeRequireResponse("faction_event_dilemmaevent_feed_target_dilemma_faction");
	local event_panel_open = uim:is_event_panel_open() and not dilemma_open;
	local fullscreen_panel_open = uim:get_open_fullscreen_panel();
	local is_processing_battle = cm:is_processing_battle();
	
	local separator_str = "==============================";
	
	if self.intervention_system_debug then
		self:out("");
		self:out(separator_str);
		self:out("intervention_manager:sort_interventions() called");
		self:inc_tab();
		if dilemma_open then
			self:out("a dilemma panel is open");
		end;
		if event_panel_open then
			self:out("an event panel is open");
		end;
		if fullscreen_panel_open then
			self:out("a fullscreen panel open");
		end;
		if is_processing_battle then
			self:out("a battle is being processed");
		end;
	end;
	
	local sorted_must_trigger_intervention_list = {};
	local sorted_standard_intervention_list = {};
	local sorted_ineligible_must_trigger_intervention_list = {};
	local sorted_ineligible_standard_intervention_list = {};
	
	local current_eligible_interventions = self.current_eligible_interventions;
	
	-- pass through our unsorted list
	for i = 1, #current_eligible_interventions do
		local current_intervention = current_eligible_interventions[i];
		
		-- there is either nothing to wait for, or there is something to wait for but this intervention doesn't need to wait for it
		local current_intervention_cost = current_intervention.cost;
		local current_intervention_inserted = false;
		local target_list = sorted_ineligible_standard_intervention_list;	-- by default, we add this intervention to the ineligible list, which goes at the end of the list we pass back
		
		-- see if this intervention is actually eligible to trigger based on the current UI context
		if (not dilemma_open or not current_intervention.wait_for_dilemma) and
			(not event_panel_open or not current_intervention.wait_for_event_dismissed) and
			(not fullscreen_panel_open or not current_intervention.wait_for_fullscreen_panel_dismissed) and
			(not is_processing_battle or not current_intervention.wait_for_battle_complete) then
			
			
			-- if this intervention is set to disregard its cost, insert this intervention into the must-trigger list, which goes at the beginning of the sorted list we pass back
			if current_intervention.disregard_cost_when_triggering then
				target_list = sorted_must_trigger_intervention_list;
			else
				-- otherwise insert this intervention into the standard sorted list, which goes in the middle of the sorted list we pass back
				target_list = sorted_standard_intervention_list;
			end;
			
		else
			-- this intervention is not eligible to trigger, but if it's set to disregard its cost then still add it to a special list that gets sorted ahead of the standard ineligible list
			if current_intervention.disregard_cost_when_triggering then
				target_list = sorted_ineligible_must_trigger_intervention_list;
			end;
			
			-- otherwise use the default, standard/ineligible list
		end;
		
		for j = 1, #target_list do
			if target_list[j].cost > current_intervention_cost then
				current_intervention_inserted = true;
				table.insert(target_list, j, current_intervention);
				break;
			end;
		end;
		
		-- if we didn't find a place to insert the intervention, put it at the end
		if not current_intervention_inserted then
			current_intervention_inserted = true;
			table.insert(target_list, current_intervention);
		end;
	end;
	
	
	-- rebuild our list of interventions based on our new sorted lists
	final_intervention_list = {};
	
	if self.intervention_system_debug then
		self:out("Printing sorted list:");
		self:out("---------------------");
	end;
	
	-- insert any must-trigger interventions first
	for i = 1, #sorted_must_trigger_intervention_list do
		local current_intervention = sorted_must_trigger_intervention_list[i];
		
		if self.intervention_system_debug then
			self:out(current_intervention.name .. " with cost [" .. current_intervention.cost .. "] is set to disregard cost (bringing it to the top of the list) and is eligible to trigger");
		end;
		
		table.insert(final_intervention_list, current_intervention);
	end;
	
	-- insert standard intervention (that can trigger) next
	for i = 1, #sorted_standard_intervention_list do
		local current_intervention = sorted_standard_intervention_list[i];
		
		if self.intervention_system_debug then
			self:out(current_intervention.name .. " with cost [" .. current_intervention.cost .. "] is eligible to trigger");
		end;
	
		table.insert(final_intervention_list, current_intervention);
	end;
	
	-- insert ineligible must-trigger interventions next
	for i = 1, #sorted_ineligible_must_trigger_intervention_list do
		local current_intervention = sorted_ineligible_must_trigger_intervention_list[i];
		
		if self.intervention_system_debug then
			self:out(current_intervention.name .. " with cost [" .. current_intervention.cost .. "] is set to disregard cost, but is not eligible to trigger");
		end;
	
		table.insert(final_intervention_list, current_intervention);
	end;
	
	-- insert ineligible/standard interventions last
	for i = 1, #sorted_ineligible_standard_intervention_list do
		local current_intervention = sorted_ineligible_standard_intervention_list[i];
		
		if self.intervention_system_debug then
			self:out(current_intervention.name .. " with cost [" .. current_intervention.cost .. "] is not eligible to trigger in the current context");
		end;
		
		table.insert(final_intervention_list, sorted_ineligible_standard_intervention_list[i]);
	end;
	
	self.current_eligible_interventions = final_intervention_list;
	
	if self.intervention_system_debug then
		self:out("---------------------");
		self:dec_tab();
		self:out(separator_str);
	end;
end;

	
	

-- attempts to start the next intervention - starts one if one is not currently active
function intervention_manager:attempt_to_start_next_intervention(force_no_wait)

	-- trigger the next intervention if one is not currently running or pending
	if not self.intervention_currently_active and not self.intervention_pending then
		
		-- no intervention is running or pending - if we're in a situation where it doesn't make sense to wait (processing a battle/not player's turn) then proceed immediately,
		-- else add a grace pause to the start so that turn-start etc. event messages can get through (this script typically triggers before they get a chance)
		local process_immediately = false;
		
		if force_no_wait or cm:is_processing_battle() or not cm:is_local_players_turn() then
			process_immediately = true;
		end;
	
		if self.intervention_system_debug then
			self:out("");
			self:out("------------------------------");
			self:out("\tintervention_manager:attempt_to_start_next_intervention() is starting next intervention as none are currently active or pending");
			if process_immediately then
				self:out("\t\tprocessing immediately");
				self:out("------------------------------");
			else
				self:out("\t\tprocessing after a grace pause to allow event messages to show");
			end;
		end;
		
		if process_immediately then
			self:start_next_intervention();
			return;
		end;
		
		-- suppress event feed messages and lock ui here, so we only have to wait for the events we've whitelisted			
		self:suppress_all_event_feed_messages(true);
		self:lock_ui(true);
		
		-- Proceed after a short pause. Ideally we should wait for an event
		self.intervention_pending = true;
		cm:callback(
			function()
				self.intervention_pending = false;
				self:start_next_intervention();
			end,
			1
		);
		
		if self.intervention_system_debug then
			self:out("------------------------------");
		end;
	else
		if self.intervention_system_debug then
			self:out("");
			self:out("------------------------------");
			self:out("\tintervention_manager:attempt_to_start_next_intervention() is not starting next intervention as one is currently active or pending");
			self:out("------------------------------");
		end;
	end;
end;



-- starts the next intervention in the current sequence
function intervention_manager:start_next_intervention(previous_intervention_is_waiting)
	local uim = self.uim;
	
	local separator_str = "********************************************************************************";
	
	if self.intervention_system_debug then
		local output_stamp = self:get_next_output_stamp();
		
		self:out("");
		self:out(separator_str);
		self:out(separator_str);
		out("# intervention_manager:start_next_intervention() called, output_stamp is [" .. output_stamp .. "] - see interventions tab for more output");
		out.inc_tab();
		self:out("intervention_manager:start_next_intervention() called, output_stamp is [" .. output_stamp .. "]");
		self:inc_tab();
		self:out("current expenditure is " .. self.current_expenditure .. " and max expenditure is " .. self.current_max_session_cost);
		if #self.current_eligible_interventions == 1 then
			self:out("\t1 eligible intervention in the list");
		else
			self:out("\t" .. #self.current_eligible_interventions .. " eligible interventions in the list");
		end;
	end;
		
	-- if we have no eligible interventions then we have reached the end of the queue
	if #self.current_eligible_interventions == 0 then
		if self.intervention_system_debug then
			self:out("there are no more interventions, returning");
			out.dec_tab();
			self:dec_tab();
			self:out(separator_str);
			self:out(separator_str);
		end;
		self:all_interventions_completed();
		return;
	end;
		
	-- have the intervention list sorted based on the current context
	self:inc_tab();
	self:sort_interventions();
	self:dec_tab();
	
	-- this reference cannot be taken before sorting, as sorting re-creates the list
	local eligible_interventions = self.current_eligible_interventions;
	
	-- get the first intervention in the list
	local next_intervention = eligible_interventions[1];
	local next_intervention_cost = next_intervention.cost;
	local total_cost_including_next_intervention = self.current_expenditure + next_intervention_cost;
	
	if self.intervention_system_debug then
		local intervention_str = "next intervention is [" .. next_intervention.name .. "], cost is [" .. next_intervention_cost .. "] and current expenditure is [" .. self.current_expenditure .. "]";
		
		if next_intervention.disregard_cost_when_triggering then
			intervention_str = intervention_str .. ". This intervention is set to trigger regardless of cost.";
		end;
		
		out(intervention_str);
		self:out(intervention_str);
	end;
	
	--
	-- see if we can afford this intervention
	--
	
	-- if this intervention is set to disregard cost, and we would ordinarily be unable to afford it, then increase the value of current_max_session_cost so that we can
	if next_intervention.disregard_cost_when_triggering and total_cost_including_next_intervention > self.current_max_session_cost then
		self.current_max_session_cost = total_cost_including_next_intervention;
	end;
	
	if total_cost_including_next_intervention > self.current_max_session_cost then
		
		-- we can't afford this intervention
		if self.intervention_system_debug then
			self:out("cannot afford this intervention, returning");
			out.dec_tab();
			self:dec_tab();
			self:out(separator_str);
			self:out(separator_str);
		end;
		
		-- mark all remaining enqueued-but-untriggered interventions as not queued, so that they may trigger again
		for i = 1, #eligible_interventions do
			eligible_interventions[i].is_enqueued_for_triggering = false;
		end;
		
		-- clear the eligible intervention list (it may still contain some interventions that weren't affordable)
		self.current_eligible_interventions = {};
		
		-- complete, as interventions are sorted by cost and if we can't afford the first then we cannot afford any subsequent
		self:all_interventions_completed();
		
		return;
	end;
	
	
	--
	-- if there is an unread dilemma pending then wait for that to complete first
	--
	if next_intervention.wait_for_dilemma and CampaignUI.DoesEventTypeRequireResponse("faction_event_dilemmaevent_feed_target_dilemma_faction") then
		if self.intervention_system_debug then
			self:out("a dilemma is pending - the next intervention [" .. next_intervention.name .. "] has to wait");
		end;
		
		-- only wait here if we're not already waiting
		if not self.is_waiting_for_dilemma_completion then
			if self.intervention_system_debug then
				self:out("\tstarting listener for dilemma completion and exiting");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
		
			self.is_waiting_for_dilemma_completion = true;
			
			-- lock ui
			self:lock_ui(true);
			
			core:add_listener(
				"start_next_intervention",
				"DilemmaChoiceMadeEvent",
				true,
				function() 
					self.is_waiting_for_dilemma_completion = false;
					
					if self.intervention_system_debug then
						self:out("\tdilemma choice made listener start_next_intervention() is triggering - calling attempt_to_start_next_intervention()");
					end;
					
					-- wait a little for the UI to be notified that the dilemma has completed
					cm:callback(function() self:attempt_to_start_next_intervention(true) end, 0.2);
				end,
				false
			);
		else
			if self.intervention_system_debug then
				self:out("\talready waiting for dilemma completion, returning");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
		end;
		self:all_interventions_completed(true);
		return;
	end;
	
	-- if we've got this far and the following flag is set then another intervention is waiting for dilemmas to be dismissed - 
	-- cancel that process as when this intervention runs through it will attempt to start it automatically
	if self.is_waiting_for_dilemma_completion then
		self.is_waiting_for_dilemma_completion = false;
		cm:cancel_progress_on_events_dismissed("start_next_intervention");
	end;
	
	
	--
	-- if there are any event messages being shown, then lock the ui (so that the player can only dismiss them) and wait for them to be dismissed - unless it's an event type we're whitelisting
	--
	if next_intervention.wait_for_event_dismissed and uim:is_event_panel_open() and not next_intervention:is_whitelisted_event_panel_open() then
		if self.intervention_system_debug then
			self:out("an event message is showing and the next intervention [" .. next_intervention.name .. "] has to wait");
		end;
		
		-- only wait here if we're not already waiting
		if not self.is_waiting_for_event_dismissed then
			if self.intervention_system_debug then
				self:out("\tstarting progress_on_events_dismissed() listener and returning");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
		
			self.is_waiting_for_event_dismissed = true;
			
			self:lock_ui(true);
			
			cm:progress_on_events_dismissed(
				"start_next_intervention",
				function() 
					self.is_waiting_for_event_dismissed = false;
					
					if self.intervention_system_debug then
						self:out("\tprogress_on_events_dismissed() listener started by start_next_intervention is triggering - calling attempt_to_start_next_intervention()");
					end;
					
					self:attempt_to_start_next_intervention(true);
				end
			);
		else
			if self.intervention_system_debug then
				self:out("\tprogress_on_events_dismissed() already started, returning");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
		end;
		self:all_interventions_completed(true);
		return;
	end;
	
	if self.intervention_system_debug then
		self:out("we don't have to wait for an event panel");
	end;
	
	-- if we've got this far and the following flag is set then another intervention is waiting for event messages to be dismissed - 
	-- cancel that process as when this intervention runs through it will attempt to start it automatically
	if self.is_waiting_for_event_dismissed then
		self.is_waiting_for_event_dismissed = false;
		cm:cancel_progress_on_events_dismissed("start_next_intervention");
	end;
	
	
	--
	-- if there are any fullscreen panels being shown, then lock the ui (so that the player can only dismiss them) and wait for them to be dismissed
	--
	if next_intervention.wait_for_fullscreen_panel_dismissed then
		local open_fullscreen_panel = uim:get_open_fullscreen_panel();
		
		if open_fullscreen_panel then
			if self.intervention_system_debug then
				self:out("a fullscreen panel [" .. open_fullscreen_panel .. "] is showing and the next intervention [" .. next_intervention.name .. "] has to wait");
			end;
		
			-- only wait here if we're not already waiting
			if not self.is_waiting_for_fullscreen_panel_dismissed then
				if self.intervention_system_debug then
					self:out("\tstarting progress_on_fullscreen_panel_dismissed() listener and returning");
					out.dec_tab();
					self:dec_tab();
					self:out(separator_str);
					self:out(separator_str);
				end;
			
				self.is_waiting_for_fullscreen_panel_dismissed = true;
				
				self:lock_ui(true);
				
				cm:progress_on_fullscreen_panel_dismissed(
					function() 
						self.is_waiting_for_fullscreen_panel_dismissed = false;
						
						if self.intervention_system_debug then
							self:out("\tprogress_on_fullscreen_panel_dismissed() listener started by start_next_intervention is triggering - calling attempt_to_start_next_intervention()");
						end;
						
						self:attempt_to_start_next_intervention(true);
					end
				);
			else
				if self.intervention_system_debug then
					self:out("\tprogress_on_fullscreen_panel_dismissed() already started, returning");
					out.dec_tab();
					self:dec_tab();
					self:out(separator_str);
					self:out(separator_str);
				end;
			end;
			self:all_interventions_completed(true);
			return;
		end;
	end;
	
	if self.intervention_system_debug then
		self:out("we don't have to wait for any fullscreen panel");
	end;
	
	-- if we've got this far and the following flag is set then another intervention is waiting for fullscreen panels to be dismissed - 
	-- cancel that process as when this intervention runs through it will attempt to start it automatically
	if self.is_waiting_for_fullscreen_panel_dismissed then
		self.is_waiting_for_fullscreen_panel_dismissed = false;
		cm:cancel_progress_on_fullscreen_panel_dismissed();
	end;
	
	
	--
	-- if the next intervention needs to wait for battle completion and we are currently processing a battle then wait for it to complete
	--
	if next_intervention.wait_for_battle_complete and cm:is_processing_battle() then
		if self.intervention_system_debug then
			self:out("a battle sequence is happening and the next intervention [" .. next_intervention.name .. "] has to wait");
		end;
		
		if not self.is_waiting_for_battle_completion then
			if self.intervention_system_debug then
				self:out("\tstarting progress_on_battle_completed() listener and returning");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
			
			self.is_waiting_for_battle_completion = true;
			cm:progress_on_battle_completed(
				"start_next_intervention",
				function()
					if self.intervention_system_debug then
						self:out("\tprogress_on_battle_completed() listener started by start_next_intervention is triggering - calling attempt_to_start_next_intervention()");
					end;
				
					self.is_waiting_for_battle_completion = false;
					self:attempt_to_start_next_intervention(true);
				end
			);
		else
			if self.intervention_system_debug then
				self:out("\tprogress_on_battle_completed() listener already running, returning");
				out.dec_tab();
				self:dec_tab();
				self:out(separator_str);
				self:out(separator_str);
			end;
		end;
		
		self:all_interventions_completed(true);	
		return;
	end;
	
	if self.intervention_system_debug then
		self:out("we don't have to wait for a battle sequence");
	end;
	
	-- if we've got this far and the following flag is set then another intervention is waiting for the battle to complete - 
	-- cancel that process as when this intervention runs through it will attempt to start the other automatically
	if self.is_waiting_for_battle_completion then
		self.is_waiting_for_battle_completion = false;
		cm:cancel_progress_on_battle_completed("start_next_intervention");
	end;
	
	--
	-- we can afford this intervention, and there's nothing to wait for, so trigger it
	--

	self.current_expenditure = total_cost_including_next_intervention;
	if self.intervention_system_debug then
		self:out("all checks have cleared, proceeding to trigger intervention [" .. next_intervention.name .. "] - current expenditure is now " .. self.current_expenditure);
	end;
	
	table.remove(eligible_interventions, 1);
	
	self:lock_ui(true);
	
	-- if there is no intervention currently active then take control of the event feed system
	if not self.intervention_currently_active then
		if not self.event_feed_suppressed and cm:is_local_players_turn() then
			if self.intervention_system_debug then
				self:out("suppressing event feed messages");
			end;
			
			self:suppress_all_event_feed_messages(true);
		end;
		
		-- prevent the game from being saved, so the player doesn't inadvertently save while an intervention is mid-state (e.g. one mission completed and the next yet to issue)
		cm:disable_saving_game(true);
	
		self.intervention_currently_active = true;	
	end;
	
	if self.intervention_system_debug then
		out.dec_tab();
		self:dec_tab();
		self:out(separator_str);
		self:out(separator_str);
	end;
	
	-- do this in case there is a progress_on_advice_finished listener still active from the previous intervention chain
	cm:cancel_progress_on_advice_finished();
	
	-- actually trigger the intervention
	next_intervention.is_enqueued_for_triggering = false;
	self.num_interventions_in_current_sequence = self.num_interventions_in_current_sequence + 1;
	next_intervention:trigger();
end;


function intervention_manager:suppress_all_event_feed_messages(value)
	if self.event_feed_suppressed ~= value then
		self.event_feed_suppressed = value;
		cm:suppress_all_event_feed_messages(value);
	end;
end;


function intervention_manager:lock_ui(value)
	local uim = cm:get_campaign_ui_manager();
	local local_faction = cm:get_local_faction_name();
	
	if not local_faction then
		script_error("lock_ui() called but could not determine local faction");
		return false;
	end;
	
	if value then
		if not self.has_locked_ui then
			if self.intervention_system_debug then
				self:out(" *** locking ui");
			end;
			
			cm:disable_movement_for_faction(local_faction);
			cm:get_campaign_ui_manager():lock_ui();
			
			-- prevent the player from hiding the ui - this can cause problems with the advisor
			if not cm:is_ui_hiding_enabled() then
				self.allow_ui_hiding_on_completion = false;
			end;
			cm:enable_ui_hiding(false);
			
			local uic_end_turn_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_end_turn");
			if uic_end_turn_button then
				core:cache_and_set_tooltip_for_component_state(uic_end_turn_button, "inactive", "ui_text_replacements_localised_text_end_turn_button_disabled_for_advice");
			end;
			
			local uic_end_turn_skip_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_skip");
			if uic_end_turn_skip_button then
				core:cache_and_set_tooltip_for_component_state(uic_end_turn_skip_button, "inactive", "ui_text_replacements_localised_text_end_turn_button_disabled_for_advice");
			end;
			
			self.has_locked_ui = true;
		end;
	else
		if self.has_locked_ui then
			if self.intervention_system_debug then
				self:out(" *** unlocking ui");
			end;
			
			local uic_end_turn_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_end_turn");
			if uic_end_turn_button then
				core:restore_tooltip_for_component_state(uic_end_turn_button, "inactive");
			end;
			
			local uic_end_turn_skip_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_skip");
			if uic_end_turn_skip_button then
				core:restore_tooltip_for_component_state(uic_end_turn_skip_button, "inactive");
			end;
			
			cm:enable_movement_for_faction(local_faction);
			cm:get_campaign_ui_manager():unlock_ui();
			
			-- allow the player to hide ui again, if we should
			if self.allow_ui_hiding_on_completion then
				cm:enable_ui_hiding(true);
			end;
			
			-- restore this value to default
			self.allow_ui_hiding_on_completion = true;
			
			self.has_locked_ui = false;
		end;
	end;
end;


function intervention_manager:intervention_completed(intervention)	
	if self.intervention_system_debug then
		self:out("");
		self:out("================");
		self:out("intervention_manager:intervention_completed() called");
		self:out("================");
	end;
	
	-- start the next intervention, but pass through a message determining whether the previous intervention is waiting for the player turn start
	self:start_next_intervention(intervention.should_trigger_on_next_player_faction_turn_start);
end;


function intervention_manager:all_interventions_completed(is_waiting)
	local separator_str = "================";
	
	-- don't do anything if the intervention system is not active
	if not self.intervention_currently_active then
		if self.intervention_system_debug then
			self:out(separator_str);
			self:out("intervention_manager:all_interventions_completed() called but no intervention currently active, returning");

			-- ensure ui is unlocked
			self:lock_ui(false);

			self:out(separator_str);
		end;
		return;
	end;
		
	if self.intervention_system_debug then
		local output_stamp = self:get_next_output_stamp();
	
		self:out("");
		self:out(separator_str);
		out("# intervention_manager:all_interventions_completed() called, output_stamp is [" .. output_stamp .. "] - see interventions tab for more output");
		out.inc_tab();
		self:out("intervention_manager:all_interventions_completed() called, output_stamp is [" .. output_stamp .. "]");
		self:inc_tab();
		if is_waiting then
			self:out("intervention_manager is waiting for external event before continuing - keeping event feed messages suppressed");
		elseif self.event_feed_suppressed then
			self:out("intervention_manager is not waiting for any external event - unsuppressing event feed messages");
		else
			self:out("intervention_manager is not waiting for any external event - not unsuppressing event feed messages as they weren't suppressed");
		end;		
	end;
	
	-- if we're waiting for something then an intervention wants to trigger, and it's just waiting for an event message to be dismissed or a battle to
	-- finish processing. Don't unsuppress the UI in this case as we don't want further things to interrupt.	
	if not is_waiting then
		if self.event_feed_suppressed then
			self:suppress_all_event_feed_messages(false);
		end;
		
		-- allow the game to be saved again
		cm:disable_saving_game(false);
		
		-- pan camera back up to altitude if it's not been moved by the player
		-- cm:progress_on_advice_finished(
		--	function()
				if self.camera_cache_position_set and not self:camera_has_moved_from_cached() then
					if self.intervention_system_debug then
						self:out("camera moved at some point during the intervention sequence, restoring");
					end;
					
					local x, y = cm:get_camera_position();
					
					cm:scroll_camera_with_cutscene(1.5, nil, {x, y, 16, 0, 14});
					
					self:reset_cached_camera_position();
				end;
				
				if self.intervention_system_debug then
					if not self.camera_cache_position_set then
						self:out("no cached camera position, not restoring camera");
					else
						self:out("camera has moved from cached position, not restoring");
					end;
				end;
		--	end
		--);
		
		-- unlock ui
		self:lock_ui(false);
		
		-- reset values
		if self.intervention_system_debug then
			self:out("resetting cost values - current expenditure is now [0], max expenditure is now [" .. cm.campaign_intervention_max_cost_points_per_session .. "]");
		end;
	
		self.num_interventions_in_current_sequence = 0;
		self.current_expenditure = 0;
		self.current_max_session_cost = cm.campaign_intervention_max_cost_points_per_session;
	end;
	
	self.intervention_currently_active = false;
	
	if self.intervention_system_debug then
		out.dec_tab();
		self:dec_tab();
		self:out(separator_str);
	end;
end;






----------------------------------------------------------------------------
-- start intervention on player faction turn start
-- whether each intervention should start on the player's next turn gets
-- saved into the savegame
----------------------------------------------------------------------------

function intervention_manager:trigger_intervention_on_next_player_faction_turn_start(intervention)	
	if not self.interventions_to_trigger_on_next_player_faction_turn_start[intervention.name] then
		self.interventions_to_trigger_on_next_player_faction_turn_start[intervention.name] = intervention;
	end;
end;


function intervention_manager:trigger_player_faction_turn_start_interventions()
	local separator_str = ". . . . . . . . . . . . .";

	if self.intervention_system_debug then
		self:out("");
		self:out(separator_str);
		self:out("intervention_manager:trigger_player_faction_turn_start_interventions() called");
		self:inc_tab();
	end;
	
	local injected_intervention = false;
	local next_event_suppress_pause_before_triggering = false;

	for intervention_name, intervention in pairs(self.interventions_to_trigger_on_next_player_faction_turn_start) do
		if self.intervention_system_debug then
			self:out("injecting intervention [" .. intervention_name .. "] to be triggered");
		end;
		
		injected_intervention = true;
		
		if intervention.suppress_pause_before_triggering then
			next_event_suppress_pause_before_triggering = true;
		end;
		
		intervention.should_trigger_on_next_player_faction_turn = false;
		table.insert(self.current_eligible_interventions, intervention);
		self.interventions_to_trigger_on_next_player_faction_turn_start[intervention_name] = nil;
	end;
	
	if self.intervention_system_debug then
		if not injected_intervention then
			self:out("no interventions injected so we won't attempt to start any");
		end;
		self:dec_tab();
		self:out(separator_str);
	end;
	
	-- try and start these interventions running (this won't do anything if an intervention is already playing)
	if injected_intervention then
		self:attempt_to_start_next_intervention(next_event_suppress_pause_before_triggering);
	end;
end;








----------------------------------------------------------------------------
-- method for interventions to determine if another intervention is queued
-- (or an unread dilemma)
----------------------------------------------------------------------------

function intervention_manager:is_another_intervention_queued()
	local separator_str = "....................................";
	
	if self.intervention_system_debug then
		self:out("");
		self:out(separator_str);
		self:out("intervention_manager:is_another_intervention_queued() called");
		self:inc_tab();
	end;
	
	if #self.current_eligible_interventions == 0 then
		if self.intervention_system_debug then
			self:out("returning false as #self.current_eligible_interventions == 0");
			self:dec_tab();
			self:out(separator_str);
		end;
		return false;
	end;
	
	-- sort interventions based on the current context (processing battle etc.)
	self:sort_interventions();
	
	-- get the next intervention
	local next_intervention = self.current_eligible_interventions[1];
	
	-- return true if an unread dilemma is active
	if CampaignUI.DoesEventTypeRequireResponse("faction_event_dilemmaevent_feed_target_dilemma_faction") then
		if self.intervention_system_debug then
			self:out("a dilemma is active, returning true");
			self:dec_tab();
			self:out(separator_str);
		end;

		return true;
	end;
	
	-- see if we can afford this intervention
	if self.current_expenditure + next_intervention.cost > self.current_max_session_cost and not next_intervention.disregard_cost_when_triggering then
		if self.intervention_system_debug then
			self:out("returning false as we cannot afford the next intervention, current expenditure [" .. self.current_expenditure .. "] + next intervention cost [" .. next_intervention.cost .. "] > maximum cost [" .. self.current_max_session_cost .. "]");
			self:dec_tab();
			self:out(separator_str);
		end;
		
		return false;
	end;
		
	if self.intervention_system_debug then
		self:out("can afford the next intervention, returning true");
		self:dec_tab();
		self:out(separator_str);
	end;
	
	return true;
end;











----------------------------------------------------------------------------
-- saving/loading
----------------------------------------------------------------------------

function intervention_manager:state_to_string()
	local persistent_intervention_list = self.persistent_intervention_list;
	local str = "";
	
	for i = 1, #persistent_intervention_list do
		local intervention = persistent_intervention_list[i];
		if not intervention.is_transient then
			str = str .. intervention:state_to_string();
		end;
	end;
	
	return str;
end;


function intervention_manager:intervention_state_from_string(str)
	local pointer = 1;
	
	-- name
	local next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
		return false;
	end;

	local intervention_name = string.sub(str, pointer, next_separator - 1);
	pointer = next_separator + 1;
	
	-- cost
	next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
		return false;
	end;
	
	local cost_str = string.sub(str, pointer, next_separator - 1);
	local cost = tonumber(cost_str);
	
	if not cost then
		script_error("ERROR: intervention_state_from_string() called but parsing failed, cost [" .. tostring(cost_str) .. "] couldn't be cast to a number, string is " .. str);
		return false;
	end;
	
	-- is_started
	pointer = next_separator + 1;
	
	next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
		return false;
	end;
	
	local is_started = string.sub(str, pointer, next_separator - 1);
	
	if is_started == "true" then
		is_started = true;
	elseif is_started == "false" then
		is_started = false;
	else
		script_error("ERROR: intervention_state_from_string() called but parsing failed, boolean flag [" .. tostring(is_started) .. "] couldn't be decyphered, string is " .. str);
		return false;
	end;
	
	-- is_awaiting_restart
	pointer = next_separator + 1;
	
	next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
		return false;
	end;
	
	local is_awaiting_restart = string.sub(str, pointer, next_separator - 1);
	
	if is_awaiting_restart == "true" then
		is_awaiting_restart = true;
	elseif is_awaiting_restart == "false" then
		is_awaiting_restart = false;
	else
		script_error("ERROR: intervention_state_from_string() called but parsing failed, boolean flag [" .. tostring(is_awaiting_restart) .. "] couldn't be decyphered, string is " .. str);
		return false;
	end;
	
	-- turn_last_triggered
	pointer = next_separator + 1;
	
	next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
		return false;
	end;
	
	local turn_last_triggered_str = string.sub(str, pointer, next_separator - 1);
	local turn_last_triggered = tonumber(turn_last_triggered_str);
	
	if not turn_last_triggered then
		script_error("ERROR: intervention_state_from_string() called but parsing failed, turn last triggered [" .. tostring(turn_last_triggered_str) .. "] couldn't be decyphered, string is " .. str);
		return false;
	end;
	
	-- should_trigger_on_next_player_faction_turn_start
	pointer = next_separator + 1;
	
	next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		-- support this intervention not having an is_eligible_this_campaign flag
		next_separator = string.find(str, ";", pointer);
		
		if not next_separator then
			script_error("ERROR: intervention_state_from_string() called but supplied string is malformed: " .. str);
			return false;
		end;
	end;
	
	local should_trigger_on_next_player_faction_turn_start = string.sub(str, pointer, next_separator - 1);
	
	if should_trigger_on_next_player_faction_turn_start == "true" then
		should_trigger_on_next_player_faction_turn_start = true;
	elseif should_trigger_on_next_player_faction_turn_start == "false" then
		should_trigger_on_next_player_faction_turn_start = false;
	else
		script_error("ERROR: intervention_state_from_string() called but parsing failed, boolean flag [" .. tostring(should_trigger_on_next_player_faction_turn_start) .. "] couldn't be decyphered, string is " .. str);
		return false;
	end;
	
	-- is_eligible_this_campaign
	pointer = next_separator + 1;
	
	next_separator = string.find(str, ";", pointer);
	
	local is_eligible_this_campaign = false;
	
	-- this flag might not be present in the savegame, so only attempt to read it if it is
	if next_separator then
		is_eligible_this_campaign = string.sub(str, pointer, next_separator - 1);
		
		if is_eligible_this_campaign == "true" then
			is_eligible_this_campaign = true;
		elseif is_eligible_this_campaign == "false" then
			is_eligible_this_campaign = false;
		else
			script_error("ERROR: intervention_state_from_string() called but parsing failed, boolean flag [" .. tostring(is_eligible_this_campaign) .. "] couldn't be decyphered, string is " .. str);
			return false;
		end;			
	end;
	
	-- find the intervention in the registered list and set it up
	local intervention = self:get_persistent_intervention(intervention_name);
			
	if not intervention then
		script_error("ERROR: intervention_state_from_string() is attempting to set up an intervention with name [" .. tostring(intervention_name) .. "] but it isn't registered. All persistent interventions should be registered before the first tick.");
		return false;
	end;
	
	intervention:start_from_savegame(cost, is_started, is_awaiting_restart, turn_last_triggered, should_trigger_on_next_player_faction_turn_start, is_eligible_this_campaign);
end;


function intervention_manager:state_from_string(str)
	local pointer = 1;
	
	out.savegame("* intervention_manager:state_from_string() called");
	self:out("");
	self:out("* intervention_manager:state_from_string() called");
	self:out("");
	
	while true do
		local next_separator = string.find(str, ";", pointer);
		
		if not next_separator then
			break;
		end;
	
		local intervention_str = string.sub(str, pointer, next_separator);
		
		self:intervention_state_from_string(intervention_str);
		
		pointer = next_separator + 1;
	end;
end;




----------------------------------------------------------------------------
-- advice history clearing
----------------------------------------------------------------------------

function intervention_manager:advice_history_cleared()
	local separator_str = "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::";
	
	if self.intervention_system_debug then
		self:out(separator_str);
		self:out("Clearing Advice History");
		self:inc_tab();
		self:out("stopping running interventions:");
		self:inc_tab();
	end;
	
	local persistent_intervention_list = self.persistent_intervention_list;
	
	-- stop all running persistent interventions
	for i = 1, #persistent_intervention_list do
		local current_intervention = persistent_intervention_list[i];
		
		if current_intervention.is_started then
			current_intervention:stop(false, true);
		end;
	end;

	-- stop running transient interventions and add them to an internal list
	local transient_intervention_list = self.transient_intervention_list;
	local transient_interventions_to_restart = {};

	for i = 1, #transient_intervention_list do
		local current_intervention = transient_intervention_list[i];
		
		if current_intervention.is_started then
			current_intervention:stop(false, true);
			table.insert(transient_interventions_to_restart, current_intervention);
		end;
	end;
	
	if self.intervention_system_debug then
		self:dec_tab();
		self:out("");
		self:out("starting eligible interventions:");
		self:inc_tab();
	end;
	
	-- start all persistent interventions that are eligible
	for i = 1, #persistent_intervention_list do
		local current_intervention = persistent_intervention_list[i];
		
		if current_intervention.is_eligible_this_campaign then
			current_intervention:start();
		end;
	end;

	-- start all transient interventions from our internal list (i.e. were previously running) that are eligible
	for i = 1, #transient_interventions_to_restart do
		local current_intervention = transient_interventions_to_restart[i];
		
		if current_intervention.is_eligible_this_campaign then
			current_intervention:start();
		end;
	end;
	
	local turn_number = cm:model():turn_number();
	self.intervention_system_last_advice_reset = turn_number;
	cm:set_saved_value("intervention_system_last_advice_reset", turn_number);
	
	if self.intervention_system_debug then
		self:dec_tab();
		self:dec_tab();
		self:out(separator_str);
	end;
end;








































----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN INTERVENTIONS
--
---	@class intervention intervention Interventions
--- @desc Campaign interventions offer a mechanism for script to lock the UI and the progression of the game while the player is shown or taken through a sequence of scripted events. This sequence can be as short as a few seconds to trigger some advice, or as long as a cinematic or a scripted tour of a feature. If one intervention has control of the game, no other intervention may gain control until that intervention completes.
--- @desc An intervention is constructed with a unique name, a trigger function (what it calls when triggered) and a priority cost. Once constructed, one or more conditions must be added to the intervention that tell it when to trigger. The intervention starts monitoring for these conditions when @intervention:start is called. Should one of these conditions be met, the intervention is enqueued for triggering, and its priority cost is considered alongside that of any other interventions that also wish to trigger at this time. The intervention that is highest priority gets to trigger first - its cost is added to a cumulative cost counter, and other interventions are queued up behind it. Once the first intervention has finished the second is started, and so on, until the list of interventions that wish to trigger is exhausted or the cumulative cost exceeds a certain value (100). The trigger monitors of any interventions that didn't get to trigger are restarted so they can trigger again in future.
--- @desc By default, the state of declared interventions is saved into the savegame. The system also supports transient interventions which are not saved in to the savegame - see @"intervention:Transient Interventions".
--- @desc Interventions are useful for delivering advice or other scripted events which demand focus, such as mid-game narrative cutscenes. Without the intervention system, there would be a risk that two such pieces of script would trigger at the same time and play simultaneously.
--
--- @section Usage
--- @desc An intervention may be created with @intervention:new, after which functions on it may be called in the form showed below.
--- @new_example Specification
--- @example <i>&lt;intervention_object&gt;</i>:<i>&lt;function_name&gt;</i>(<i>&lt;args&gt;</i>)
--- @new_example Creation and Usage
--- @example local intervention_example = intervention:new(
--- @example 	"example",
--- @example 	60,
--- @example 	function() trigger_example_intervention() end,
--- @example 	true
--- @example )
--- @example intervention_example:set_min_advice_level(2)


--- @section Configuration and Starting
--- @desc Once created, an intervention may optionally configured with a variety of settings (see @"intervention:Configuration"). One or more trigger conditions can be added with @intervention:add_trigger_condition. Preconditions, which are tests an intervention must pass before it's allowed to start may also be added to an intervention with @intervention:add_precondition. Preconditions are checked again prior to an intervention triggering.
--- @desc When set up, an intervention may be started with @intervention:start. This only needs to happen once during the life-cycle of a campaign game, for an intervention that was previously started will be restarted should the script save and load. This includes interventions that have triggered and shut down, so the preconditions of each intervention must be set up to ensure that it doesn't start back up on script load unless that is desired.
--- @desc Once an intervention triggers, it is <strong>imperative</strong> that it finishes, which happens when @intervention:complete or @intervention:cancel are called. Until one of these function is called an intervention will lock the UI and the progress of the game. However, some functions are made available that wrap common intervention templates - see the functions list in the @"intervention:Intervention Behaviour Wrappers" section. These will automatically end the intervention at the appropriate time.


--- @section Transient Interventions
--- @desc Interventions are persistent by default, which means that their details are saved into the savegame and that they are automatically re-established when the game is reloaded. Transient interventions are also supported, which are not saved into the savegame. These are intended for use for narrative events that have to pay heed to the intervention system but that are triggered in an inline fashion from other scripts.
--- @desc Transient interventions can be created by setting the transient flag on the constructor function @intervention:new. The @campaign_manager also provides a fire-and-forget wrapper for creating transient interventions - see @campaign_manager:trigger_transient_intervention.
--- @desc Transient interventions, unlike persistent interventions, can share the same name (although this should be avoided if possible). Some advanced intervention functionality is not available to transient interventions, such as @intervention:take_priority_over_intervention, @intervention:set_turn_countdown_restart and other related functions.


--- @section Output
--- @desc The intervention system outputs extensive amount of information to the <code>Lua - Interventions</code> tab.
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


intervention = {
	im = nil,
	name = "",
	restart_listener_name = "",
	cost = false,											-- will be overwritten on construction
	disregard_cost_when_triggering = false,					-- this intervention always triggers, regardless of cost concerns
	precondition_list = {},
	trigger_conditions = {},
	-- denotes whether the trigger conditions are actually registered with the intervention manager or not. When an intervention gets
	-- enqueued to be triggered the listeners are stopped before the intervention itself is.
	intervention_listeners_registered = false,
	shared_turn_countdown_interventions = {},
	have_shared_turn_countdown_interventions = false,
	give_priority_to_interventions_list = {},				-- won't attempt to start if any interventions from this list are running
	take_priority_over_interventions_list = {},				-- will start interventions from this list when completing
	in_priority_order = false,
	callback = nil,
	completion_callback = nil,
	is_started = false,
	is_active = false,										-- is actually running right now
	is_awaiting_restart = false,
	is_transient = false,									-- transient interventions don't save information into the savegame
	is_enqueued_for_triggering = false,
	is_eligible_this_campaign = false,						-- campaign script tried to start this intervention, so it can be started if advice history is reset
	started_from_other_intervention = false,
	is_stopped_by_higher_priority_intervention = false,
	turn_last_triggered = -1,
	restart_checks = {},
	turn_countdown_restart = -1,
	should_lock_ui = true,
	is_debug = false,
	min_advice_level = 0,
	is_player_turn_only = true,
	wait_for_battle_complete = true,
	wait_for_event_dismissed = true,
	wait_for_fullscreen_panel_dismissed = true,
	wait_for_dilemma = true,
	should_trigger_on_next_player_faction_turn_start = false,
	suppress_pause_before_triggering = false,
	event_tyes_to_whitelist = {},
	min_turns_since_advice_reset = 0,
	allow_when_advice_disabled = false
};









----------------------------------------------------------------------------
--- @section Creation
----------------------------------------------------------------------------


--- @function new
--- @desc Creates a intervention object. This should happen in the root of the script somewhere, so that the object is declared and set up by the time the first tick happens so that it can be properly restarted from a savegame.
--- @p @string name, Unique name for the intervention.
--- @p @number cost, Priority cost for the intervention. When an intervention triggers, all interventions that wish to trigger at the same time will be sorted by cost, and triggered in that order (with the cheapest first). Once the total cost of all interventions triggered in a sequence exceeds a certain value (100) no more interventions can trigger. This mechanism prevents the player from being overly spammed with advice.
--- @p @function callback, Callback to call when the intervention gets to trigger.
--- @p [opt=false] @boolean debug mode, Activates debug mode for this intervention, causing it to output more.
--- @p [opt=false] @boolean is transient, Sets this intervention to be transient. The details of transient interventions are not saved into the savegame.
function intervention:new(name, cost, callback, is_debug, is_transient)

	if not is_string(name) then
		script_error("ERROR: intervention:new() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	local im = cm:get_intervention_manager();
	
	if not is_transient and im:get_persistent_intervention(name) then
		script_error("ERROR: intervention:new() called but this intervention is set to be persistent and an intervention with supplied name [" .. tostring(name) .. "] already exists in the persistent interventions list");
		return false;
	end;
	
	if not is_number(cost) or cost < 0 then
		script_error("ERROR: intervention:new() called but supplied cost [" .. tostring(cost) .. "] is not a number greater than 0");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: intervention:new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local i = {};
	
	setmetatable(i, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INTERVENTION end;
	
	i.im = im;
	i.name = name;
	i.restart_listener_name = i.name .. "_restart_listener";
	i.cost = cost;
	i.callback = callback;
	i.is_debug = not not is_debug;
	
	if is_debug then
		i:set_intervention_system_debug(true);
	end;

	i.is_transient = is_transient;
	
	i.precondition_list = {};
	i.trigger_conditions = {};
	i.shared_turn_countdown_interventions = {};
	
	i.take_priority_over_interventions_list = {};
	i.give_priority_to_interventions_list = {};
	
	i.event_tyes_to_whitelist = {};
	
	im:register_intervention(i, is_transient);
	
	return i;
end;










----------------------------------------------------------------------------
--- @section Preconditions
--- @desc If preconditions are added to an intervention, it will check these when it attempts to either start or trigger. If any of its preconditions return false, the intervention shuts down and will not trigger.
----------------------------------------------------------------------------


--- @function add_precondition
--- @desc Adds a precondition function to the intervention. This function will be called by the intervention from time to time and should return <code>true</code> if the intervention is allowed to start or trigger, <code>false</code> otherwise. Should the precondition return <code>false</code> when the intervention calls it the intervention will shut down.
--- @desc Multiple preconditions may be added to an intervention.
--- @p function precondition
function intervention:add_precondition(precondition)
	if not is_function(precondition) then
		script_error(self.name .. " ERROR: add_precondition() called but supplied precondition [" .. tostring(precondition) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.precondition_list, precondition);
end;


--- @function add_advice_key_precondition
--- @desc Precondition wrapper function that adds a precondition to the intervention that a particular advice key must not have been triggered. The intervention won't be able to start or trigger if the advice history reveals that the advice key has been triggered before. This is useful for interventions that trigger advice - by using this function to specify a precondition, an advice intervention may prevent itself from starting or triggering if the advice it intends to deliver has been heard before.
--- @p string advice key
function intervention:add_advice_key_precondition(advice_key)
	if not is_string(advice_key) then
		script_error(self.name .. " ERROR: add_precondition_unvisited_page() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	local precondition = function()
		return effect.get_advice_thread_score(advice_key) == 0;
	end;
	
	table.insert(self.precondition_list, precondition);
end;


--- @function add_precondition_unvisited_page
--- @desc Precondition wrapper function that adds a precondition to the intervention that a particular help page must be unvisited. The intervention won't be able to start or trigger if the advice history reveals that the specified help page has been visited. This may be useful for low-priority advice scripts that don't wish to trigger if the help page on the advice topic has been seen.
--- @p string help page name
function intervention:add_precondition_unvisited_page(page_name)
	if not is_string(page_name) then
		script_error(self.name .. " ERROR: add_precondition_unvisited_page() called but supplied page name [" .. tostring(page_name) .. "] is not a string");
		return false;
	end;
	
	local precondition = function()
		return not cm:help_page_seen(page_name);
	end;
	
	table.insert(self.precondition_list, precondition);
end;











----------------------------------------------------------------------------
--- @section Trigger Conditions
--- @desc At least one trigger condition must have been added to an intervention with @intervention:add_trigger_condition before it's started, otherwise it will never be able to trigger.
----------------------------------------------------------------------------


--- @function add_trigger_condition
--- @desc Adds a trigger event and condition to the intervention. The supplied event is listened for and, when received, the supplied condition function is called, with the context of the received event as a single parameter. Should the condition function return true the trigger is satisfied and the intervention is enqueued for triggering.
--- @desc Alternatively the value <code>true</code> may be specified in place of a condition function - in this case, the intervention is enqueued for triggering as soon as the specified event is received.
--- @p string event name, Event name to listen for.
--- @p function condition check, Condition check to call when the event is received. Alternatively, <code>true</code> may be specified.
--- @new_example
--- @example in_mission_advice:add_trigger_condition(
--- @example 	"ScriptEventFirstAttackEnemyMissionIssued",
--- @example 	true
--- @example );
--- @new_example
--- @example in_money:add_trigger_condition(
--- @example 	"ScriptEventPlayerFactionTurnStart",
--- @example 	function(context)		
--- @example 		return context:faction():treasury() < 4000;
--- @example 	end
--- @example );
function intervention:add_trigger_condition(event_name, check)
	if not is_string(event_name) then
		script_error(self.name .. " ERROR: add_triggering_condition() called but supplied event name [" .. tostring(event_name) .. "] is not a string");
		return false;
	end;
	
	if check ~= true and not is_function(check) then
		script_error(self.name .. " ERROR: add_triggering_condition() called but supplied check [" .. tostring(check) .. "] is not a function");
		return false;
	end;
	
	local trigger_condition_entry = {};
	trigger_condition_entry.event_name = event_name;
	trigger_condition_entry.check = check;
	
	table.insert(self.trigger_conditions, trigger_condition_entry);
	
	if self.is_debug then
		self.im:out(self.name .. " added trigger condition for event " .. event_name);
	end;
end;















----------------------------------------------------------------------------
--- @section Configuration
----------------------------------------------------------------------------


-- For internal use, sets the intervention manager into debug mode
function intervention:set_intervention_system_debug(value)
	self.im.intervention_system_debug = not not value;
end;


--- @function set_disregard_cost_when_triggering
--- @desc Set this intervention to trigger regardless of cost. Interventions set to disregard cost will trigger ahead of interventions not set to disregard cost, even if the former's assigned cost is more than the latter's. Its cost is still counted towards the maximum cost per-session, however, so if an intervention that costs 80 points and is set to disregard cost triggers, and another that costs 30 point and is not set to disregard cost is queued up behind it, the second will not be able to fire as the maximum cost is exceeded.
--- @desc If triggered at the same time as another intervention which is also set to disregard cost then they will trigger in order of cost priority. Both will always trigger, though, even if their combined cost is more than the maximum session allowance.
--- @p [opt=true] boolean diregard cost
function intervention:set_disregard_cost_when_triggering(value)
	if value == false then
		self.disregard_cost_when_triggering = false;
	else
		self.disregard_cost_when_triggering = true;
	end;
end;


--- @function set_suppress_pause_before_triggering
--- @desc By default, interventions wait for a short period before triggering. Use this function to suppress this wait behaviour.
--- @p [opt=true] boolean suppress pause
function intervention:set_suppress_pause_before_triggering(value)
	if value == false then
		self.suppress_pause_before_triggering = false;
	else
		self.suppress_pause_before_triggering = true;
	end;
end;


--- @function set_allow_when_advice_disabled
--- @desc If advice has been disabled with @campaign_manager:set_advice_enabled then by default interventions won't attempt to play. Use this function to modify this behaviour for this intervention if required.
--- @p [opt=true] boolean allow intervention
function intervention:set_allow_when_advice_disabled(value)
	if value == false then
		self.allow_when_advice_disabled = false;
	else
		self.allow_when_advice_disabled = true;
	end;
end;


--- @function set_min_advice_level
--- @desc Sets the minimum player advice level setting at which this intervention will be allowed to trigger. By default this value is 0, so the intervention will trigger regardless of advice level. Valid minimum advice levels are:
--- @desc <table class="simple"><tr><td><strong>0</strong></td><td>Minimal advice - will trigger when advice level is set to minimal, low or high</td></tr><tr><td><strong>1</strong></td><td>Low advice - will trigger when advice level is set to low or high</td></tr><tr><td><strong>2</strong></td><td>High advice - will only trigger when the advice level is set to high</td></tr></table>
--- @p number min advice level
function intervention:set_min_advice_level(min_advice_level)
	if min_advice_level == 0 or min_advice_level == 1 or min_advice_level == 2 then
		self.min_advice_level = min_advice_level;
	else
		script_error(self.name .. " ERROR: set_min_advice_level() called on intervention but supplied minimum advice level value [" .. tostring(min_advice_level) .. "] is not recognised - valid values are 0 (will trigger when advice level is minimal), 1 (will trigger when advice level is low) or 2 (will trigger when advice level is high)");
	end;
end;


--- @function set_player_turn_only
--- @desc Sets whether or not this intervention can only happen on the player's turn. By default, interventions can only trigger if it's the player's turn. Use this function to allow interventions to trigger in the end-turn sequence, which is useful for advice triggering over diplomacy or battles.
--- @desc If an intervention is set to trigger on just the player's turn and it is trigger during the end-turn sequence, it will cancel itself and then trigger again when the player's turn starts.
--- @p [opt=true] boolean player turn only
function intervention:set_player_turn_only(value)
	if value == false then
		self.is_player_turn_only = false;
	else
		self.is_player_turn_only = true;
	end;
end;


--- @function set_min_turn
--- @desc Sets the minimum number of turns since either the start of the campaign or when the advice history was last reset before this intervention is eligible to trigger. This is useful for ensuring non-essential advice is spaced out at the start of the campaign.
--- @p number minimum turn
function intervention:set_min_turn(minimum_turn)
	if not is_number(minimum_turn) or minimum_turn < 0 then
		script_error(self.name .. " ERROR: set_min_turn() called but supplied minimum turn [" .. tostring(minimum_turn) .. "] is not a positive number");
		return false;
	end;
	
	self.min_turns_since_advice_reset = minimum_turn;
end;


--- @function get_min_turn
--- @desc Returns the set minimum turn value.
--- @return number minimum turn
function intervention:get_min_turn()
	return self.min_turns_since_advice_reset;
end;



--- @function set_wait_for_battle_complete
--- @desc By default, interventions will wait for a battle sequence to complete before triggering. A battle sequence is from when the pre-battle panel opens, to when the camera returns to its gameplay position after any battle panels have closed. Use this function to allow interventions to trigger during battle sequences if required. This is useful for delivering pre-battle or post-battle advice.
--- @p [opt=true] boolean wait for battle
function intervention:set_wait_for_battle_complete(value)
	if value == false then
		self.wait_for_battle_complete = false;
	else
		self.wait_for_battle_complete = true;
	end;
end;


--- @function set_wait_for_event_dismissed
--- @desc By default, interventions will wait for any open event panels to be dismissed before triggering. Use this function to suppress this behaviour, if necessary.
--- @p [opt=true] boolean wait for events
function intervention:set_wait_for_event_dismissed(value)
	if value == false then
		self.wait_for_event_dismissed = false;
	else
		self.wait_for_event_dismissed = true;
	end;
end;


--- @function set_wait_for_dilemma
--- @desc By default, interventions will wait for open dilemmas to be dismissed before triggering. Use this function to suppress this behaviour, if necessary. This should only be used in very specific circumstances.
--- @p [opt=true] boolean wait for dilemmas
function intervention:set_wait_for_dilemma(value)
	if value == false then
		self.wait_for_dilemma = false;
		self:add_whitelist_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
	else
		self.wait_for_dilemma = true;
	end;
end;


--- @function set_wait_for_fullscreen_panel_dismissed
--- @desc By default, interventions will wait for any open fullscreen panels (technology, diplomacy, recruitment etc) to be dismissed before triggering. Use this function to suppress this behaviour, if necessary.
--- @p [opt=true] boolean wait for panels
function intervention:set_wait_for_fullscreen_panel_dismissed(value)
	if value == false then
		self.wait_for_fullscreen_panel_dismissed = false;
	else
		self.wait_for_fullscreen_panel_dismissed = true;
	end;
end;


--- @function add_whitelist_event_type
--- @desc Adds an event type to be whitelisted if @intervention:whitelist_events is called.
--- @p string event type
function intervention:add_whitelist_event_type(event_type)
	if not is_string(event_type) then
		script_error("ERROR: add_whitelist_event() called but supplied event type [" .. tostring(event_type) .. "] is not a string");
		return false;
	end;

	table.insert(self.event_tyes_to_whitelist, event_type);
end;


--- @function set_completion_callback
--- @desc Adds a callback to call when the intervention has completed.
--- @p function callback
function intervention:set_completion_callback(callback)
	self.completion_callback = callback;
end;


--- @function get_turn_last_triggered
--- @desc Returns the turn number of which this intervention last triggered in this campaign. If this intervention has never triggered then <code>-1</code> is returned.
--- @return number turn last triggered
function intervention:get_turn_last_triggered()
	return self.turn_last_triggered;
end;


--- @function has_ever_triggered
--- @desc Returns whether this intervention has ever triggered in this campaign.
--- @return boolean has ever triggered
function intervention:has_ever_triggered()
	return self.turn_last_triggered > 0;
end;










----------------------------------------------------------------------------
--- @section Restart Callback
--- @desc Restart events and checks are listened for if the intervention isn't running, assuming it has previously been started. If a restart callback event is received and the check returns true, then the intervention is restarted. Multiple restart callbacks may be added to one intervention.
----------------------------------------------------------------------------


--- @function add_restart_callback
--- @desc Adds a restart event and conditional check. Should the event be received and the conditional check return true, then the intervention will restart. Transient interventions may not have restart callbacks added.
--- @p string event name, Event name to listen for.
--- @p function check, Conditional check to test when event is received. This should be a function that returns a boolean value, and it will be passed the context of the event listened for as a single parameter. Alternatively, <code>true</code> may be specified in place of a function, in which case the intervention is restarted as soon as the event is received.
function intervention:add_restart_callback(event_name, check)
	if self.is_transient then
		script_error(self.name .. " ERROR: add_restart_callback() called but this intervention is transient. Only persistent interventions support restart callbacks.");
		return false;
	end;

	if not is_string(event_name) then
		script_error(self.name .. " ERROR: add_restart_callback() called but supplied event name [" .. tostring(event_name) .. "] is not a string");
		return false;
	end;
	
	if not events[event_name] then
		script_error(self.name .. " ERROR: add_restart_callback() called but supplied event name [" .. event_name .. "] was not found in events table");
		return false;
	end;
	
	if check ~= true and not is_function(check) then
		script_error(self.name .. " ERROR: add_restart_callback() called but supplied check [" .. tostring(check) .. "] is not a function or true");
		return false;
	end;
	
	local restart_entry = {};
	restart_entry.event_name = event_name;
	restart_entry.check = check;
	
	table.insert(self.restart_checks, restart_entry);
	
	if self.is_debug then
		self.im:out(self.name .. " added restart callback for event " .. event_name);
	end;
end;








----------------------------------------------------------------------------
--- @section Restart on Turn Countdown
----------------------------------------------------------------------------


--- @function set_turn_countdown_restart
--- @desc If a turn countdown restart number is set, the intervention will attempt to restart the given number of turns after stopping. This countdown also applies if the intervention fails to start. Transient interventions do not support turn countdown restarts.
--- @p number turns
function intervention:set_turn_countdown_restart(number_of_turns)
	if self.is_transient then
		script_error(self.name .. " ERROR: set_turn_countdown_restart() called but this intervention is transient. Only persistent interventions support this mechanism.");
		return false;
	end;

	if not is_number(number_of_turns) then
		script_error("ERROR: set_turn_countdown_restart() called but supplied number of turns [" .. tostring(number_of_turns) .. "] is not a number");
		return false;
	end;
	
	self.turn_countdown_restart = number_of_turns;
	
	-- allow this intervention to start from a new game (if it's not, this value will get overwritten later)
	self.turn_last_triggered = 0 - number_of_turns;
	
	if self.is_debug then
		self.im:out(self.name .. " set turn countdown restart value to " .. number_of_turns);
	end;
end;


--- @function register_shared_turn_countdown_intervention
--- @desc Registers that this intervention shares a turn countdown with another. If this is set on an intervention then when it restarts its turn countdown it will instruct the other intervention to restart its turn countdown also. This can be useful for advice interventions that share a common purpose.
--- @desc Note that interventions that take or cede priority to another (see @"intervention:Taking and Ceding Priority") cannot share turn countdowns with other interventions.
--- @p string intervention name, Name of intervention that this intervention shares its turn countdown with. This only needs to be called on one of the two interventions.
function intervention:register_shared_turn_countdown_intervention(intervention_name)
	if self.is_transient then
		script_error(self.name .. " ERROR: register_shared_turn_countdown_intervention() called but this intervention is transient. Only persistent interventions support this mechanism.");
		return false;
	end;

	if not is_string(intervention_name) then
		script_error("ERROR: register_shared_turn_countdown_intervention() called but supplied intervention name [" .. tostring(intervention_name) .. "] is not a string");
		return false;
	end;
	
	if self.in_priority_order then
		script_error("ERROR: register_shared_turn_countdown_intervention() called but this intervention is in a priority order - interventions don't support sharing and priority ordering");
		return false;
	end;
	
	self.shared_turn_countdown_interventions[intervention_name] = true;
end;










----------------------------------------------------------------------------
--- @section Taking and Ceding Priority
--- @desc Interventions can set to explicitly take or cede priority to another. This allows client scripts to ensure that one intervention must stop or cannot run when another is started, and for the second to notify the first when it stops so that the first can eventually start.
----------------------------------------------------------------------------


--- @function take_priority_over_intervention
--- @desc Registers that this intervention takes priority over another intervention with the supplied name, so that they cannot run at the same time. If the supplied intervention attempts to start and this intervention is already started, the supplied intervention will fail to start. If this intervention starts and the supplied intervention has already started, the supplied intervention will be stopped.
--- @desc Furthermore, when this intervention stops it will notify the supplied intervention, which will then start.
--- @desc Only persistent interventions can take priority over another. Transient interventions do not support this mechanism.
--- @p string intervention name, Name of intervention to take priority over.
function intervention:take_priority_over_intervention(intervention_name)
	if self.is_transient then
		script_error(self.name .. " ERROR: take_priority_over_intervention() called but this intervention is transient. Only persistent interventions support this mechanism.");
		return false;
	end;

	if not is_string(intervention_name) then
		script_error(self.name .. " ERROR: take_priority_over_intervention() called but supplied intervention name [" .. tostring(intervention_name) .. "] is not a string");
		return false;
	end;
	
	if self.name == intervention_name then
		script_error(self.name .. " ERROR: take_priority_over_intervention() called but supplied intervention name [" .. intervention_name .. "] is this intervention's name");
		return false;
	end;
	
	if self.have_shared_turn_countdown_interventions then
		script_error(self.name .. " ERROR: take_priority_over_intervention() called but this intervention is shared - interventions don't support sharing and priority ordering");
		return false;
	end;
	
	self.take_priority_over_interventions_list[intervention_name] = true;
	self.in_priority_order = true;
end;


--- @function give_priority_to_intervention
--- @desc Registers that this intervention cedes priority to another intervention with the supplied name, so that they cannot run at the same time. This is the reverse of @intervention:take_priority_over_intervention. If the supplied intervention starts and this intervention is already started, this intervention will be stopped. If this intervention starts and the supplied intervention has already started, this intervention will not start.
--- @desc Furthermore, when the supplied intervention stops it will notify this intervention, which will then start.
--- @desc Only persistent interventions can take priority over another. Transient interventions do not support this mechanism.
--- @p string intervention name, Name of intervention to give priority to.
function intervention:give_priority_to_intervention(intervention_name, should_notify)
	if self.is_transient then
		script_error(self.name .. " ERROR: give_priority_to_intervention() called but this intervention is transient. Only persistent interventions support this mechanism.");
		return false;
	end;

	if not is_string(intervention_name) then
		script_error(self.name .. " ERROR: give_priority_to_intervention() called but supplied intervention name [" .. tostring(intervention_name) .. "] is not a string");
		return false;
	end;
	
	if self.have_shared_turn_countdown_interventions then
		script_error(self.name .. " ERROR: give_priority_to_intervention() called but this intervention is shared - interventions don't support sharing and priority ordering");
		return false;
	end;
		
	self.give_priority_to_interventions_list[intervention_name] = true;
	self.in_priority_order = true;
end;









----------------------------------------------------------------------------
--- @section Starting
----------------------------------------------------------------------------


--- @function start
--- @desc Starts the intervention. An intervention must be started in order to trigger. This only needs to be called once per-intervention through the lifetime of a campaign - if an intervention is started, and the campaign is saved and loaded, the intervention will automatically be restarted from the savegame, even if it's triggered and stopped.
function intervention:start(is_restarting, starting_from_other_intervention)
	
	local im = self.im;
	
	-- this flag determines that this intervention can be started if the advice history is reset
	self.is_eligible_this_campaign = true;
	
	if cm:is_multiplayer() then
		if self.is_debug then
			self.im:out(self.name .. " is not starting as this is a multiplayer game");
			return;
		end;
	end;
	
	if self.is_started then
		if starting_from_other_intervention then
			self.im:out(self.name .. " was started but has already been started by another intervention");
			return false;
		elseif self.started_from_other_intervention then
			self.im:out(self.name .. " has already been started by another intervention - attempt to start ignored");
			return false;
		else
			script_error(self.name .. " ERROR: an attempt was made to start an intervention that's already been started");
			return false;
		end;
	end;
	
	-- if we can't play advice then do not start
	if not cm:is_advice_enabled() and not self.allow_when_advice_disabled then
		if self.is_debug then
			self.im:out(self.name .. ": advice is disabled, not starting");
		end;
		
		return;
	end;
	
	-- check if we pass all our preconditions (if any)
	if not self:passes_precondition_check() then
		self.im:out(self.name .. " not starting as precondition check failed");
		
		-- start interventions that this took priority over, if any
		self:start_secondary_interventions();
		
		return;
	end;
	
	-- notify all of the interventions that take priority over this one of this fact (we couldn't do it earlier)
	-- if they're started already, don't start this one
	for intervention_name in pairs(self.give_priority_to_interventions_list) do
		local intervention = im:get_persistent_intervention(intervention_name);
		
		if intervention then
			intervention:take_priority_over_intervention(self.name, false);
			
			if intervention.is_started then
				-- don't start this intervention as a higher-priority intervention is running
				if self.is_debug then
					self.im:out(self.name .. " not starting as higher-priority intervention [" .. intervention_name .. "] is already started");
					return false;
				end;
			end;
		end;
	end;
	
	-- notify all of the interventions that must cede priority to this one of this fact (we couldn't do it earlier)
	-- if they're started already, stop them
	for intervention_name in pairs(self.take_priority_over_interventions_list) do
		local intervention = im:get_persistent_intervention(intervention_name);
		
		if not intervention then
			script_error(self.name .. " ERROR: start() called but couldn't find an intervention with name [" .. intervention_name .. "]");
			return false;
		end;
		
		intervention:give_priority_to_intervention(self.name, false);
		
		if intervention.is_started then
			-- don't start this intervention as a higher-priority intervention is running
			if self.is_debug then
				self.im:out(self.name .. " is stopping intervention [" .. intervention_name .. "] as this one is higher priority");
			end;
			
			intervention:stop(true);
		end;
	end;
	
	-- if the advice cost is higher than the max cost then don't bother to start this intervention
	if self.cost > cm.campaign_intervention_max_cost_points_per_session then
		if self.is_debug then
			self.im:out(self.name .. " not starting as cost [" .. tostring(self.cost) .. "] is too high");
			out.dec_tab();
		end;
		
		-- start secondary interventions, if any
		self:start_secondary_interventions();
		
		return;
	end;
	
	-- if we have any other interventions to query for a restart countdown then don't start if any of them have been triggered recently enough
	-- (this should never trigger if we have no other interventions to query)
	
	if self.turn_countdown_restart > 0 then
		local most_recent_intervention_trigger = self.turn_last_triggered;
		
		for intervention_name in pairs(self.shared_turn_countdown_interventions) do
			local intervention = im:get_persistent_intervention(intervention_name);
			
			-- ensure that the foreign intervention is also sharing its turn countdown with the local intervention
			if not intervention.shared_turn_countdown_interventions[self.name] then
				intervention:register_shared_turn_countdown_intervention(self.name);
			end;
			
			if intervention then
				local current_turn_last_triggered = intervention:get_turn_last_triggered();
				
				if current_turn_last_triggered > most_recent_intervention_trigger then
					most_recent_intervention_trigger = current_turn_last_triggered;
				end;
			end;
		end;
		
		if most_recent_intervention_trigger + self.turn_countdown_restart > cm:model():turn_number() then
			-- don't start this intervention as one of it's related interventions was triggered too recently
			if self.is_debug then
				self.im:out(self.name .. " not starting as related intervention triggered too recently");
				out.dec_tab();
			end;
			
			-- setup countdown and restart listeners (if there are any)
			self:start_turn_countdown(cm:model():turn_number() - most_recent_intervention_trigger);			-- compensate for how long ago the most recent trigger was
			self:start_restart_listeners();
			
			return;
		end;
	end;
	
	self.is_started = true;
	
	self.started_from_other_intervention = starting_from_other_intervention;
	
	if self.is_debug then
		if is_restarting then
			self.im:out(self.name .. " restarting");
		else
			self.im:out(self.name .. " starting");
		end;
		out.inc_tab();
	end;	
	
	-- register our trigger condition checks with the intervention manager
	self:register_trigger_conditions();
	
	if self.is_debug then
		out.dec_tab();
	end;
end;


--	called by the intervention manager to stop this intervention's running listeners
--	this calls back to the intervention manager to actually stop the listeners
function intervention:stop(order_comes_from_higher_priority_intervention, advice_history_clearing)
	if not self.is_started then
		script_error(self.name .. " ERROR: an attempt was made to stop an intervention that's not started");
		return false;
	end;
	
	self.is_started = false;
	
	if self.is_debug then
		self.im:out(self.name .. " stopping");
		out.inc_tab();
	end;

	self:unregister_trigger_conditions();
	
	core:remove_listener(self.restart_listener_name);
	
	if self.is_debug then
		out.dec_tab();
	end;

	if order_comes_from_higher_priority_intervention then
		-- don't start secondary interventions if this intervention is being terminated by another of higher-priority
		self.is_stopped_by_higher_priority_intervention = true;
		
	elseif not advice_history_clearing then
		-- start secondary interventions, if any, but only if advice history is not in the process of resetting
		self:start_secondary_interventions();
	end;
end;










----------------------------------------------------------------------------
--- @section Whitelisting Events
----------------------------------------------------------------------------


--- @function whitelist_events
--- @desc Perform the whitelisting of event types that have been registered with @intervention:add_whitelist_event_type. This is intended to be called while the intervention is actually running to make pending events display suddenly.
function intervention:whitelist_events()
	for i = 1, #self.event_tyes_to_whitelist do
		out.interventions("\twhitelisting event type " .. self.event_tyes_to_whitelist[i]);
		cm:whitelist_event_feed_event_type(self.event_tyes_to_whitelist[i]);
	end;
end;


-- internal function to determine whether any event type we have whitelisted is open (currently this returns whether it exists in the event feed at all, so it could have been read)
function intervention:is_whitelisted_event_panel_open()
	for i = 1, #self.event_tyes_to_whitelist do
		if CampaignUI.DoesEventTypeExist(self.event_tyes_to_whitelist[i]) then
			return true;
		end;
	end;
end;









----------------------------------------------------------------------------
-- registering and unregistering trigger conditions with the intervention manager
----------------------------------------------------------------------------

function intervention:register_trigger_conditions()
	if self.intervention_listeners_registered then
		return;
	end;

	local trigger_conditions = self.trigger_conditions;
	local im = self.im;
	
	for i = 1, #trigger_conditions do
		local current_record = trigger_conditions[i];
		
		im:register_intervention_listener(self, current_record.event_name, current_record.check);
	end;
	
	self.intervention_listeners_registered = true;
end;


function intervention:unregister_trigger_conditions()
	if not self.intervention_listeners_registered then
		return;
	end;

	local trigger_conditions = self.trigger_conditions;
	local im = self.im;
	
	for i = 1, #trigger_conditions do
		local current_record = trigger_conditions[i];
		
		im:unregister_intervention_listener(self, current_record.event_name);
	end;
	
	self.intervention_listeners_registered = false;
end;









----------------------------------------------------------------------------
-- precondition check
----------------------------------------------------------------------------

function intervention:passes_precondition_check()
	for i = 1, #self.precondition_list do
		if not self.precondition_list[i]() then
			return false;
		end;
	end;

	return true;
end;







----------------------------------------------------------------------------
-- starting secondary interventions (interventions that this one takes precendence over)
----------------------------------------------------------------------------

function intervention:start_secondary_interventions()
	local im = self.im;
	local interventions_to_start = {};
	
	for intervention_name in pairs(self.take_priority_over_interventions_list) do
		local intervention = im:get_persistent_intervention(intervention_name);
		
		if not intervention then
			script_error(self.name .. " ERROR: start_secondary_interventions() could not find an intervention with the name [" .. tostring(intervention_name) .. "]");
			return false;
		end;
		
		table.insert(interventions_to_start, intervention);
	end;
	
	for i = 1, #interventions_to_start do
		interventions_to_start[i]:start(false, true);
	end;
end;








----------------------------------------------------------------------------
-- triggering
-- called internally when this intervention triggers
----------------------------------------------------------------------------

function intervention:trigger()

	-- this intervention may have been queued up for triggering and then stopped by another related intervention, so don't do anything if started
	if not self.is_started then
		if self.is_debug then
			self.im:out(self.name .. " tried to trigger but this intervention is not started, completing");
		end;
		self.im:intervention_completed(self);
		return;
	end;
	
	-- if this intervention is set to be player turn only and it's not the player turn then set up a listener for the player starting the next
	-- turn which fires a unique event that re-triggers this intervention (the listener for which is set up when the intervention is declared),
	-- and don't proceed any further. This defers this intervention from triggering until it's actually the player's turn.
	if self.is_player_turn_only and not cm:is_local_players_turn() then
		if self.is_debug then
			self.im:out(self.name .. " tried to trigger but it's not the local players turn - waiting until it is");
		end;
	
		self.should_trigger_on_next_player_faction_turn_start = true;
		self.im:trigger_intervention_on_next_player_faction_turn_start(self);
		
		self.is_enqueued_for_triggering = false;		
		self.im:intervention_completed(self);		
		return;
	end;

	if self.is_active then
		script_error(self.name .. " ERROR: trigger() called but intervention is already running");
		return false;
	end;
	
	if self.is_debug then
		self.im:out(self.name .. " is triggering");
	end;
	
	local im = self.im;
	
	-- notify all related interventions that this one is triggering
	for intervention_name in pairs(self.shared_turn_countdown_interventions) do
		local intervention = im:get_persistent_intervention(intervention_name);
		
		if intervention then
			intervention:notify_shared_turn_countdown_intervention_triggering();
		end;
	end;
	
	self.is_active = true;
	self.turn_last_triggered = cm:model():turn_number();
	self.callback(self);
end;


-- returns whether the intervention playing functions should add a pause at the start - returns true if this is the first intervention in the sequence and this intervention normally waits for stuff
function intervention:should_add_grace_pause_at_start()
	-- don't add a grace pause if something that interventions normally wait for is happening - immediacy is better in these cases
	return self.im:first_intervention_in_sequence() and not (
		(uim:is_event_panel_open() and not self.wait_for_event_dismissed) or 				-- event panel is open and we don't have to wait for it
		(cm:is_processing_battle() and not self.wait_for_battle_complete) or				-- we are processing a battle and we don't have to wait for it
		(uim:get_open_fullscreen_panel() and not self.wait_for_fullscreen_panel_dismissed)	-- fullscreen panel is open and we don't have to wait for it
	);
end;






----------------------------------------------------------------------------
-- called by shared countdown interventions to inform this intervention
-- that they are starting
----------------------------------------------------------------------------

function intervention:notify_shared_turn_countdown_intervention_triggering()
	if self.started then
		self:stop();
		self:start_turn_countdown();
		self:start_restart_listeners();
	end;
end;





----------------------------------------------------------------------------
-- method for determining if another intervention is queued up behind this one
----------------------------------------------------------------------------

function intervention:is_another_intervention_queued()
	return self.im:is_another_intervention_queued();
end;









----------------------------------------------------------------------------
--- @section Completion
----------------------------------------------------------------------------


--- @function complete
--- @desc Completes the intervention when it's running. This function (or @intervention:cancel) <b>must</b> be called at some point after the intervention has been triggered, as they are the only way the intervention will end and relinquish control of the game. The wrapper functions @intervention:play_advice_for_intervention, @intervention:scroll_camera_to_character_for_intervention and @intervention:scroll_camera_to_settlement_for_intervention all call this function internally so if using one of those to control the behaviour of the intervention when triggered then this function does not need to be called.
function intervention:complete()
	if not self.is_active then
		script_error(self.name .. " ERROR: complete() called but intervention is not running");
		return false;
	end;
	
	if self.is_debug then
		self.im:out(self.name .. " is completed");
	end;
	
	self.is_enqueued_for_triggering = false;
	self.is_active = false;
	
	self:stop();
	
	self:start_turn_countdown();
	self:start_restart_listeners();
	
	if is_function(self.completion_callback) then
		self.completion_callback();
	end;
	
	self.im:intervention_completed(self);
end;


--- @function cancel
--- @desc Completes the intervention without stopping its listeners. This is useful if an intervention decides it doesn't want to trigger after all after @intervention:start has been called.
function intervention:cancel()
	if not self.is_active then
		script_error(self.name .. " ERROR: cancel() called but intervention is not running");
		return false;
	end;
	
	self.is_enqueued_for_triggering = false;
	self.is_active = false;
	
	self.im:intervention_completed(self);
end;









----------------------------------------------------------------------------
-- restarting
----------------------------------------------------------------------------


-- trigger turn countdown if we have one
function intervention:start_turn_countdown(modifier)
	if self.turn_countdown_restart >= 0 then
		modifier = modifier or 0;
		cm:add_turn_countdown_event(cm:get_local_faction_name(), self.turn_countdown_restart - modifier, "ScriptEventInterventionTurnCountdownCompleted", self.name);
	end;
end;


-- start restart listeners if we have any
function intervention:start_restart_listeners()
	local restart_checks = self.restart_checks;
	
	-- set up our restart listeners
	for i = 1, #restart_checks do
		local restart_record = restart_checks[i];
		
		core:add_listener(
			self.restart_listener_name,
			restart_record.event_name,
			function(context) return restart_entry.check == true or restart_entry.check(context) end,
			function() self:restart() end,
			false
		);
	end;
	
	-- if we have a positive turn countdown restart then establish a listener
	if self.turn_countdown_restart > 0 then
		core:add_listener(
			self.restart_listener_name,
			"ScriptEventInterventionTurnCountdownCompleted",
			function(context) return context.string == self.name end,
			function() self:restart() end,
			false
		);
	end;
	
	if #restart_checks > 0 or self.turn_countdown_restart >= 0 then
		self.is_awaiting_restart = true;
		if self.is_debug then
			self.im:out(self.name .. " restart listeners started");
		end;
	end;
end;


-- perform the restart
function intervention:restart()	
	self.is_awaiting_restart = false;
	
	-- remove any listeners that might still be running
	core:remove_listener(self.restart_listener_name);
	
	self:start(true);
end;


----------------------------------------------------------------------------
-- saving/loading
----------------------------------------------------------------------------

function intervention:state_to_string()
	
	-- if a) this intervention is not started but b) an intervention it cedes priority to is started, then record that this intervention
	-- is started in the savegame otherwise it won't re-establish itself properly when reloading
	local is_started = self.is_started or self.is_stopped_by_higher_priority_intervention;
		
	return self.name .. "%" .. self.cost .. "%" .. tostring(is_started) .. "%" .. tostring(self.is_awaiting_restart) .. "%" .. tostring(self.turn_last_triggered) .. "%" .. tostring(self.should_trigger_on_next_player_faction_turn_start) .. "%" .. tostring(self.is_eligible_this_campaign) .. ";";
end;


function intervention:start_from_savegame(cost, is_started, is_awaiting_restart, turn_last_triggered, should_trigger_on_next_player_faction_turn_start, is_eligible_this_campaign)
	self.cost = cost;
	self.turn_last_triggered = turn_last_triggered;
	self.is_eligible_this_campaign = is_eligible_this_campaign;
	
	if is_started and is_awaiting_restart then
		script_error(self.name .. " ERROR: start_from_savegame() called but intervention is both started and awaiting restart, how can this be?");
		return false;
	end;
	
	if is_started and not self.is_started then
		self:start(false);
		return;
	end;
	
	if is_awaiting_restart and not self.is_awaiting_restart then
		self.is_awaiting_restart = true;
		self:start_restart_listeners();
	end;
	
	if should_trigger_on_next_player_faction_turn_start then
		self.im:trigger_intervention_on_next_player_faction_turn_start(self);
	end;
end;












----------------------------------------------------------------------------
--- @section Intervention Behaviour Wrappers
--- @desc Call one of the functions in this section when an intervention is triggered to have it behave in a standardised manner, showing advice, infotext, a mission, optionally scrolling to a target and completing where appropriate.
----------------------------------------------------------------------------


--- @function scroll_camera_to_character_for_intervention
--- @desc Scrolls the camera to a character during an intervention, showing advice and optionally showing infotext and a mission. This should only be called while this intervention is actually running after having been triggered.
--- @p number cqi, Character cqi.
--- @p string advice key, Advice key.
--- @p [opt=nil] table infotext, Table of string infotext keys.
--- @p [opt=nil] mission_manager mission, Mission manager of mission to trigger, if any.
--- @p [opt=3] number duration, Duration of camera scroll in seconds.
--- @p [opt=nil] function scroll callback, Callback to call when the camera movement is complete.
--- @p [opt=nil] function continuation callback, If supplied, this callback will be called when the intervention would usually complete. It will be passed this intervention object as a single argument, and takes on the responsibility for calling @intervention:complete to relinquish control.
function intervention:scroll_camera_to_character_for_intervention(char_cqi, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
	-- other parameters are checked downstream
	if not is_number(char_cqi) then
		out.interventions("scroll_camera_to_character_for_intervention() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number, calling play_advice_for_intervention() instead");
		
		self:play_advice_for_intervention(advice_key, infotext, mm, nil, continuation_callback);
		return false;
	end;
	
	local character = cm:get_character_by_cqi(char_cqi);
	
	-- if we don't have a valid character, then play advice without scrolling the camera
	if not character then
		out.interventions("scroll_camera_to_character_for_intervention() called but couldn't find a valid character with cqi [" .. char_cqi .. "], calling play_advice_for_intervention() instead");
	
		self:play_advice_for_intervention(advice_key, infotext, mm, nil, continuation_callback);
		return;
	end;
	
	local targ_x = character:display_position_x();
	local targ_y = character:display_position_y();
	
	out.interventions("[" .. self.name .. "] scroll_camera_to_character_for_intervention() called, character cqi is " .. char_cqi .. " belonging to faction " .. character:faction():name());
	
	local region_key = false;
	
	if character:has_region() then
		region_key = character:region():name();
	end;	
	
	self:scroll_camera_for_intervention(region_key, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
end;


function intervention:cancel_scroll_camera_to_character_for_intervention()
	return self:cancel_scroll_camera_for_intervention();
end;


--- @function scroll_camera_to_settlement_for_intervention
--- @desc Scrolls the camera to a settlement during an intervention, showing advice and optionally showing infotext and a mission. This should only be called while this intervention is actually running after having been triggered.
--- @p string region key, Region key.
--- @p string advice key, Advice key.
--- @p [opt=nil] table infotext, Table of string infotext keys.
--- @p [opt=nil] mission_manager mission, Mission manager of mission to trigger, if any.
--- @p [opt=3] number duration, Duration of camera scroll in seconds.
--- @p [opt=nil] function scroll callback, Callback to call when the camera movement is complete.
--- @p [opt=nil] function continuation callback, If supplied, this callback will be called when the intervention would usually complete. It will be passed this intervention object as a single argument, and takes on the responsibility for calling @intervention:complete to relinquish control.
function intervention:scroll_camera_to_settlement_for_intervention(region_key, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
	-- other parameters are checked downstream
	if not is_string(region_key) then
		script_error("scroll_camera_to_settlement_for_intervention() called but supplied region key [" .. tostring(region_key) .. " is not a string");
		return false;
	end;
	
	local region = cm:get_region(region_key);
	
	if not region then
		out.interventions("scroll_camera_to_settlement_for_intervention() called but couldn't find a region with supplied key [" .. region_key .. "], calling play_advice_for_intervention() instead");
	
		self:play_advice_for_intervention(advice_key, infotext, mm, nil, continuation_callback);
		return;
	end;
	
	local settlement = region:settlement();
	local targ_x = settlement:display_position_x();
	local targ_y = settlement:display_position_y();
	
	self:scroll_camera_for_intervention(region_key, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
end;


function intervention:cancel_scroll_camera_to_settlement_for_intervention()
	return self:cancel_scroll_camera_for_intervention();
end;


--- @function scroll_camera_for_intervention
--- @desc Scrolls the camera to a supplied position on the campaign map during an intervention, showing advice and optionally showing infotext and a mission. This should only be called while this intervention is actually running after having been triggered.
--- @p string region key, Target region key. If a region is supplied here the shroud over it will be lifted while the intervention is playing.
--- @p number x, Display x co-ordinate of position to scroll to.
--- @p number y, Display y co-ordinate of position to scroll to.
--- @p string advice key, Advice key.
--- @p [opt=nil] table infotext, Table of string infotext keys.
--- @p [opt=nil] mission_manager mission, Mission manager of mission to trigger, if any.
--- @p [opt=3] number duration, Duration of camera scroll in seconds.
--- @p [opt=nil] function scroll callback, Callback to call when the camera movement is complete.
--- @p [opt=nil] function continuation callback, If supplied, this callback will be called when the intervention would usually complete. It will be passed this intervention object as a single argument, and takes on the responsibility for calling @intervention:complete to relinquish control.
function intervention:scroll_camera_for_intervention(targ_region, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
	
	if targ_region and not is_string(targ_region) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied target region key [" .. tostring(targ_region) .. "] is not a string");
		return false;
	end;
		
	if not is_number(targ_x) or targ_x < 0 then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied target x co-ordinate [" .. tostring(targ_x) .. " is not a positive number");
		return false;
	end;
	
	if not is_number(targ_y) or targ_y < 0 then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied target y co-ordinate [" .. tostring(targ_y) .. " is not a positive number");
		return false;
	end;
	
	if not is_string(advice_key) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied advice key [" .. tostring(advice_key) .. " is not a string");
		return false;
	end;
	
	if infotext and not is_table(infotext) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied infotext list [" .. tostring(infotext) .. " is not a table or nil");
		return false;
	end;
	
	if mm and not is_missionmanager(mm) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied mission manager [" .. tostring(mm) .. " is not a mission manager");
		return false;
	end;
	
	duration = duration or 3;
	
	if scroll_complete_callback and not is_function(scroll_complete_callback) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied scroll complete callback [" .. tostring(scroll_complete_callback) .. " is not a function or nil");
		return false;
	end;
	
	if continuation_callback and not is_function(continuation_callback) then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but supplied continuation callback [" .. tostring(continuation_callback) .. " is not a function or nil");
		return false;
	end;

	if not self.is_active then
		script_error(self.name .. " ERROR: scroll_camera_for_intervention() called but this intervention is not currently active");
		return false;
	end;
	
	local intervention_stamp = "[" .. self.name .. "] ";
	
	out.interventions("");
	out.interventions(intervention_stamp .. "scroll_camera_for_intervention() called");
	out.interventions(intervention_stamp .. "scroll target: [" .. targ_x .. ", " .. targ_y .. "]");
	out.interventions(intervention_stamp .. "advice key: " .. advice_key);
	if mm then
		out.interventions(intervention_stamp .. "mission key: " .. mm.mission_key);
	else
		out.interventions(intervention_stamp .. "no mission specified");
	end;
	if scroll_complete_callback then
		out.interventions(intervention_stamp .. "scroll-complete callback specified");
	else
		out.interventions(intervention_stamp .. "no scroll-complete callback specified");
	end;
	if continuation_callback then
		out.interventions(intervention_stamp .. "continuation callback specified");
	else
		out.interventions(intervention_stamp .. "no continuation callback specified");
	end;
	
	local wait_period = 0.5;
	
	if self:should_add_grace_pause_at_start() then
		out.interventions(intervention_stamp .. "waiting " .. wait_period .. "s as this is the first intervention in the sequence");
		cm:callback(function() self:scroll_camera_for_intervention_action(targ_region, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback) end, wait_period);
	else
		self:scroll_camera_for_intervention_action(targ_region, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback);
	end;	
end;


function intervention:scroll_camera_for_intervention_action(targ_region, targ_x, targ_y, advice_key, infotext, mm, duration, scroll_complete_callback, continuation_callback)
	local intervention_stamp = "[" .. self.name .. "] ";

	local advice_triggered = false;
	local advice_finished = false;
	local advice_dismissed = false;
	local advice_close_button_highlighted = false;
	local highlight_close_button_on_advice_finish = false;
	local complete_intervention_on_advice_dismiss = false;
	
	local intervention_completed = false;
	
	
	-- highlight the advisor close button, if we should
	local highlight_advice_close_button = function()
		if advice_close_button_highlighted then
			return;
		end;
		
		advice_close_button_highlighted = true;
		
		cm:modify_advice(true, true);
	end;
	
	
	-- assemble a completion callback
	local intervention_complete = function()
		if intervention_completed then
			return;
		end;
		
		intervention_completed = true;
	
		self:cancel_scroll_camera_for_intervention();
		
		-- if we have a continuation callback, call it, passing through this intervention, and then return
		if continuation_callback then
			out.interventions(intervention_stamp .. "calling completion callback");
			continuation_callback(self);
			return;
		end;
		
		local delay = 0;
		if self:is_another_intervention_queued() then
			delay = 1;
		end;
		
		cm:callback(function() self:complete() end, delay);
		
	end;
	
	
	-- play advice callback
	local play_advice_callback = function()
		if advice_triggered then
			return;
		end;
		
		cm:clear_infotext();
	
		-- play the actual advice
		advice_triggered = true;
		
		cm:show_advice(advice_key);
		
		cm:progress_on_advice_dismissed(
			function() 
				advice_finished = true;
				advice_dismissed = true;
				advisor_dismissed = true;
				
				if complete_intervention_on_advice_dismiss then
					out.interventions(intervention_stamp .. "advice is being dismissed and everything else is issued, completing");
					intervention_complete();
				end;
			end
		);
		cm:progress_on_advice_finished(
			function() 
				advice_finished = true; 
				if highlight_close_button_on_advice_finish then
					highlight_advice_close_button();
				end;
			end
		);
		
		out.interventions(intervention_stamp .. "playing advice");
		
		if infotext then
			cm:add_infotext(1, unpack(infotext));
		end;
	end;
	
	-- play the advice
	cm:callback(function() play_advice_callback() end, 0.5, "scroll_camera_for_intervention");
	
	out.interventions(intervention_stamp .. "scrolling camera");
	
	local cam_x, cam_y, cam_d, cam_b, cam_h = cm:get_camera_position();			-- we need this mainly for the camera bearing
	
	-- TODO: determine a better method of finding the distance and/or height
	local targ_d = 10.5;
	local targ_b = cam_b;
	local targ_h = 8.0;
	
	-- make a cutscene, add the camera pan as the action and play it
	local cutscene = campaign_cutscene:new(
		"scroll_camera_for_intervention", 
		duration, 
		function() 
			cm:callback(
				function()
					-- our cutcene has finished
					
					-- show advisor close button if it's not already highlighted
					if not advice_close_button_highlighted then
						cm:modify_advice(true);
					end;
					
					-- cache the camera position so the im can later work out if the player has moved the camera
					self.im:cache_camera_position();
					
					-- execute the scroll completion callback if we have one
					if scroll_complete_callback then
						scroll_complete_callback();
					end;

					out.interventions(intervention_stamp .. "cutscene finished");
				
					-- if we haven't triggered our advice yet, do so now
					play_advice_callback();
					
					-- if we have missions to trigger or events to whitelist then do it now
					if mm then
						out.interventions(intervention_stamp .. "triggering mission");
						mm:trigger();
					end;
					
					local event_tyes_to_whitelist = self.event_tyes_to_whitelist;
					for i = 1, #event_tyes_to_whitelist do
						cm:whitelist_event_feed_event_type(event_tyes_to_whitelist[i]);
					end;
					
					-- whitelist events in the intervention's whitelist
					self:whitelist_events();
					
					-- work out whether to complete
					cm:callback(
						function()
							if self:is_another_intervention_queued() then
								-- cutscene has finished, events issued, advice started and another intervention is enqueued
								-- don't complete until advice is dismissed
								
								-- if advice is dismissed, then complete, otherwise mark it 
								if advice_dismissed then
									out.interventions(intervention_stamp .. "cutscene has finished, events issued, another intervention is enqueued and advice is already dismissed - completing");
									intervention_complete();
								else
									if advice_finished then
										out.interventions(intervention_stamp .. "cutscene has finished, events issued, another intervention is enqueued and advice is showing but has finished playing - highlighting completion button");
										complete_intervention_on_advice_dismiss = true;										
										highlight_advice_close_button();
									else
										out.interventions(intervention_stamp .. "cutscene has finished, events issued, another intervention is enqueued and advice is showing but has not finished playing - marking that it should highlight upon completion");
										highlight_close_button_on_advice_finish = true;
										complete_intervention_on_advice_dismiss = true;
									end;
								end;
							else
								-- cutscene has finished, events issued, advice started and no other intervention is enqueued, so complete
								out.interventions(intervention_stamp .. "cutscene has finished, events issued, advice started and no other intervention is enqueued - completing");
								intervention_complete();
							end;
						end,
						1,
						"scroll_camera_for_intervention"
					);
				end,
				0.5
			);
		end
	);
	
	cutscene:set_skippable(true, {targ_x, targ_y, targ_d, targ_b, targ_h});
	cutscene:set_dismiss_advice_on_end(false);
	cutscene:set_use_cinematic_borders(false);
	cutscene:set_disable_settlement_labels(false);
	
	if targ_region then
		-- if we have a target region, don't restore the shroud when the camera has finished scrolling, but do it manually once the intervention completes
		cutscene:set_restore_shroud(false);
		cutscene:action(function() cm:make_region_visible_in_shroud(cm:get_local_faction_name(), targ_region) end, 0);
	end;
	
	cutscene:action(function() cm:scroll_camera_from_current(true, duration, {targ_x, targ_y, targ_d, targ_b, targ_h}) end, 0);
	
	cutscene:start();
end;


function intervention:cancel_scroll_camera_for_intervention()	
	cm:remove_callback("scroll_camera_for_intervention");
	cm:cancel_progress_on_advice_dismissed();
	cm:cancel_progress_on_advice_finished();
end;


--- @function play_advice_for_intervention
--- @desc Shows advice and optionally some infotext and a mission. This should only be called while this intervention is actually running after having been triggered.
--- @p @string advice key, Advice key.
--- @p [opt=nil] @table infotext, Table of string infotext keys.
--- @p [opt=nil] @mission_manager mission, Mission manager of mission to trigger, if any.
--- @p [opt=2] @number mission delay, Delay in seconds after triggering intervention before triggering mission.
--- @p [opt=nil] @function continuation callback, If supplied, this callback will be called when the intervention would usually complete. It will be passed this intervention object as a single argument, and takes on the responsibility for calling @intervention:complete to relinquish control.
function intervention:play_advice_for_intervention(advice_key, infotext, mm, mission_delay, continuation_callback)
	
	if not is_string(advice_key) then
		script_error(self.name .. " ERROR: play_advice_for_intervention() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if infotext and not is_table(infotext) then
		script_error(self.name .. " ERROR: play_advice_for_intervention() called but supplied infotext list [" .. tostring(infotext) .. "] is not a table or nil");
		return false;
	end;
	
	if mm and not is_missionmanager(mm) then
		script_error(self.name .. " ERROR: play_advice_for_intervention() called but supplied mission manager [" .. tostring(mm) .. "] is not a mission manager");
		return false;
	end;
	
	mission_delay = mission_delay or 2;		-- default 2 second wait before the mission appears after triggering
	
	if mission_delay and (not is_number(mission_delay) or mission_delay < 0) then
		script_error(self.name .. " ERROR: play_advice_for_intervention() called but supplied mission delay [" .. tostring(mission_delay) .. "] is not a positive number");
		return false;
	end;

	if continuation_callback and not is_function(continuation_callback) then
		script_error(self.name .. " ERROR: play_advice_for_intervention() called but supplied continuation callback [" .. tostring(continuation_callback) .. "] is not a function or nil");
		return false;
	end;
	
	local intervention_stamp = "[" .. self.name .. "] ";
	
	out.interventions(intervention_stamp .. "play_advice_for_intervention() called");
	out.interventions(intervention_stamp .. "advice key: " .. advice_key);
	if mm then
		out.interventions(intervention_stamp .. "mission key: " .. mm.mission_key);
		if mission_delay then
			out.interventions(intervention_stamp .. "mission delay: " .. mission_delay);
		end;
	else
		out.interventions(intervention_stamp .. "no mission specified");
	end;
	
	local wait_period = 0.5;
	
	-- wait before proceeding if this is the first intervention in the sequence
	if self:should_add_grace_pause_at_start() then
		out.interventions(intervention_stamp .. "waiting " .. wait_period .. "s as this is the first intervention in the sequence");
		cm:callback(function() self:play_advice_for_intervention_action(advice_key, infotext, mm, mission_delay, continuation_callback) end, wait_period);
	else
		self:play_advice_for_intervention_action(advice_key, infotext, mm, mission_delay, continuation_callback);
	end;
end;


function intervention:play_advice_for_intervention_action(advice_key, infotext, mm, mission_delay, continuation_callback)
	
	local intervention_stamp = "[" .. self.name .. "] ";
	
	local advice_dismissed = false;
	local advice_issued = false;
	local advice_close_button_highlighted = false;
	
	local missions_and_events_issued = false;
	
	-- highlight the advisor close button, if we should
	local highlight_advice_close_button = function()
		if advice_close_button_highlighted then
			return;
		end;
		
		advice_close_button_highlighted = true;
		
		cm:modify_advice(true, true);
	end;
	
	-- assemble a completion callback
	local intervention_complete = function()
		if not self.is_active then
			return;
		end;
		
		self:cancel_play_advice_for_intervention();
		
		-- if we have a mission and it's not yet been triggered, do so now
		if mm and not missions_and_events_issued then
			mm:trigger();
			self:whitelist_events();
		end;
		
		local delay = 0;
		if self:is_another_intervention_queued() then
			delay = 1;
		end;
		
		cm:callback(
			function()
				if continuation_callback then
					out.interventions(intervention_stamp .. "calling continuation callback");
					continuation_callback(self)
				elseif self.is_active then
					out.interventions(intervention_stamp .. "completing intervention");
					self:complete();
				end;
			end, 
			delay
		);
	end;
	
	-- called when we want to show advice
	local show_advice_func = function()
		
		out.interventions(intervention_stamp .. "showing advice");
	
		-- listen for advice being dismissed
		cm:progress_on_advice_dismissed(
			function()
				-- advice is dismissed
				advice_dismissed = true;
				
				out.interventions(intervention_stamp .. "advice dismissed");
				
				-- if the mission has already been accepted then progress
				if missions_and_events_issued then
					out.interventions(intervention_stamp .. "missions and events already issued (or no mission to issue)");
					
					intervention_complete();
				end;
			end
		);
		
		cm:progress_on_advice_finished(
			function()
				if self:is_another_intervention_queued() then
					out.interventions(intervention_stamp .. "infotext finished and another intervention is queued, highlighting advisor close button");
					highlight_advice_close_button();
				end;
			end
		);
		
		cm:clear_infotext();
	
		-- issue the advice
		cm:show_advice(advice_key, true);
		advice_issued = true;
		
		-- issue infotext, if we have any
		if infotext then
			cm:add_infotext(1, unpack(infotext));
		end;
		
		-- potentially allow user to progress after advice has been issued
		cm:callback(
			function()
				if not self:is_another_intervention_queued() and missions_and_events_issued then
					out.interventions(intervention_stamp .. "infotext triggered, no other intervention is queued so completing");
					intervention_complete();
				end;
			end,
			2,
			"play_advice_for_intervention"
		);
	end;
	
	-- show the advice
	show_advice_func();
	
	-- trigger mission if we have one
	if mm then
		cm:callback(
			function()
				out.interventions(intervention_stamp .. "triggering mission / whitelisting events");
				
				missions_and_events_issued = true;
				
				mm:trigger();
				self:whitelist_events();
				
				cm:callback(
					function()
						missions_and_events_issued = true;
						if not self:is_another_intervention_queued() then
							out.interventions(intervention_stamp .. "no intervention is queued after triggering missions and whitelisting events, completing");
							intervention_complete();
						elseif advice_dismissed then
							out.interventions(intervention_stamp .. "triggered missions/whitelisted events and advice is already dismissed, completing");
							intervention_complete();
						end;
					end,
					1,
					"play_advice_for_intervention"
				);
			end,
			mission_delay,
			"play_advice_for_intervention"
		);
	elseif #self.event_tyes_to_whitelist > 0 then
		cm:callback(
			function()
				out.interventions(intervention_stamp .. " whitelisting events");
				
				self:whitelist_events();
				
				cm:callback(
					function()
						missions_and_events_issued = true;
						if not self:is_another_intervention_queued() then
							out.interventions(intervention_stamp .. "no intervention is queued after whitelisting events, completing");
							intervention_complete();
						elseif advice_dismissed then
							out.interventions(intervention_stamp .. "whitelisted events and advice is already dismissed, completing");
							intervention_complete();
						end;
					end,
					1,
					"play_advice_for_intervention"
				);
			end,
			mission_delay,
			"play_advice_for_intervention"
		);
	else	
		-- we have no mission to give
		missions_and_events_issued = true;
	end;
end;


function intervention:cancel_play_advice_for_intervention()	
	cm:remove_callback("play_advice_for_intervention");
	cm:cancel_progress_on_advice_dismissed();
	cm:cancel_progress_on_advice_finished();
end;