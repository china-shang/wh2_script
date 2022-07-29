
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VORTEX RITUAL INTERVENTIONS
--	This script manages the interventions/advice associated with the vortex rituals
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function vortex_start_interventions()
	in_vortex_ai_starts_first_ritual:start();
	--in_vortex_horned_rat_movie_finishes:start();
	in_vortex_final_battle_available:start();
	in_vortex_ai_final_battle_available:start();
end;



-- ai performs first ritual
in_vortex_ai_starts_first_ritual = intervention:new(
	"vortex_ai_starts_first_ritual",											-- string name
	0,																			-- cost
	function() vortex_ai_starts_first_ritual_cutscene() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_vortex_ai_starts_first_ritual:add_precondition(
	function(context) return not core:is_tweaker_set("SKIP_SCRIPTED_CONTENT_3") and not cm:get_saved_value("ai_starts_first_ritual_intervention_triggered") and cm:get_faction(cm:get_local_faction_name()):has_pooled_resource("wh2_main_ritual_currency") end
);

in_vortex_ai_starts_first_ritual:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context) return cm:get_saved_value("ai_starts_first_ritual") end
);

in_vortex_ai_starts_first_ritual:set_disregard_cost_when_triggering(true);
in_vortex_ai_starts_first_ritual:set_suppress_pause_before_triggering(true);

function vortex_ai_starts_first_ritual_cutscene()
	cm:set_saved_value("ai_starts_first_ritual_intervention_triggered", true);
	
	local home_x = false;
	local home_y = false;
	
	-- get the position of the player's capital or faction leader if they have no regions
	local player_faction = cm:get_faction(cm:get_local_faction_name());
	
	if player_faction:region_list():is_empty() then
		local character = player_faction:faction_leader();
		home_x = character:display_position_x();
		home_y = character:display_position_y();
	else
		local settlement = player_faction:home_region():settlement();
		home_x = settlement:display_position_x();
		home_y = settlement:display_position_y();
	end;
	
	if not home_x or not home_y then
		script_error("vortex_ai_starts_first_ritual_cutscene() called but could not find the player's capital's or faction leader's display position!");
		return;
	end;
	
	-- get the position of the ritual site
	local faction_list = cm:model():world():faction_list();
	local ritual_site = false;
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if not current_faction:is_human() and current_faction:has_rituals() then
			local active_rituals = current_faction:rituals():active_rituals()
			
			if active_rituals:num_items() > 0 then
				ritual_site = active_rituals:item_at(0):ritual_sites():item_at(0):settlement();
				-- found the first ritual site
				break;
			end;
		end;
	end;
	
	if not ritual_site then
		script_error("vortex_ai_starts_first_ritual_cutscene() called but could not find a suitable ritual site to pan camera to!");
		in_vortex_ai_starts_first_ritual:complete();
		return;
	end;
	
	local ritual_cam_pos = {
		["x"] = ritual_site:display_position_x(),
		["y"] = ritual_site:display_position_y(),
		["d"] = 10,
		["b"] = 0,
		["h"] = 10
	};
	
	local bearing_to_vortex = math.atan((vortex_cam_pos.x - ritual_cam_pos.x)/(vortex_cam_pos.y - ritual_cam_pos.y));
	
	local last_advice_given = false;
	
	local cutscene = campaign_cutscene:new(
		"ai_starts_first_ritual_cutscene",
		27,
		function()
			cm:fade_scene(0, 0.5);
			cm:callback(
				function()
					cm:set_camera_position(home_x, home_y, 10, 0, 10);
					cm:fade_scene(1, 0.5);
				end,
				0.5
			);
			cm:modify_advice(true, true);
			cm:progress_on_advice_dismissed(function() in_vortex_ai_starts_first_ritual:complete() end, 0.5);
		end
	);
	
	cutscene:set_dismiss_advice_on_end(false);
	
	cutscene:set_skippable(
		true,
		function()
			cm:set_camera_position(home_x, home_y, 10, 0, 10);
			cm:fade_scene(0, 0);
			
			if not last_advice_given then
				cm:show_advice("wh2.camp.advice.vortex_ritual.002", true);
				cm:callback(function() cm:fade_scene(1, 0.5) end, 0.5);
			end;
		end
	);
	
	cutscene:action(
		function()
			cm:show_advice("wh2.camp.advice.vortex_ritual.001")
			cm:scroll_camera_from_current(false, 4, {ritual_cam_pos.x, ritual_cam_pos.y, ritual_cam_pos.d, ritual_cam_pos.b + bearing_to_vortex, ritual_cam_pos.h});
		end,
		0
	);
	
	cutscene:action(
		function()
			cm:scroll_camera_from_current(false, 12, {vortex_cam_pos.x, vortex_cam_pos.y, vortex_cam_pos.d, vortex_cam_pos.b + bearing_to_vortex, vortex_cam_pos.h});
		end,
		7
	);
	
	cutscene:action(
		function()
			cutscene:wait_for_advisor()
		end,
		16
	);
	
	cutscene:action(
		function()
			cm:scroll_camera_from_current(false, 3, {vortex_cam_pos.x, vortex_cam_pos.y, vortex_cam_pos.d, vortex_cam_pos.b, vortex_cam_pos.h});
		end,
		19
	);
	
	cutscene:action(
		function()
			last_advice_given = true;
			cm:show_advice("wh2.camp.advice.vortex_ritual.002");
		end, 
		16.5
	);
	
	cutscene:start();
end;



--[[ horned rat movie finishes playing
in_vortex_horned_rat_movie_finishes = intervention:new(
	"vortex_horned_rat_movie_finishes",	 						-- string name
	0, 															-- cost
	function() vortex_horned_rat_movie_finishes() end,			-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 								-- show debug output
);

in_vortex_horned_rat_movie_finishes:set_disregard_cost_when_triggering(true);

in_vortex_horned_rat_movie_finishes:add_trigger_condition(
	"ScriptEventVortexRitual5Progress",
	function()
		return true;
	end
);

function vortex_horned_rat_movie_finishes()
	local advice = "wh2.camp.advice.horned_rat.001";
	
	if cm:get_faction(cm:get_local_faction_name()):culture() == "wh2_main_skv_skaven" then
		advice = "wh2.camp.advice.horned_rat.002";
	end;
	
	in_vortex_horned_rat_movie_finishes:play_advice_for_intervention(
		advice
	);
end;]]



-- final battle is available
in_vortex_final_battle_available = intervention:new(
	"vortex_final_battle_available",	 						-- string name
	0, 															-- cost
	function() vortex_final_battle_available() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 								-- show debug output
);

in_vortex_final_battle_available:set_disregard_cost_when_triggering(true);

in_vortex_final_battle_available:add_trigger_condition(
	"RitualCompletedEvent",
	function(context)
		return context:succeeded() and context:performing_faction():is_human() and context:ritual():ritual_key():find("wh2_main_ritual_vortex_5_");
	end
);

function vortex_final_battle_available()
	local advice = "wh2.camp.advice.final_battle.002";
	
	if cm:get_faction(cm:get_local_faction_name()):culture() == "wh2_main_skv_skaven" then
		advice = "wh2.camp.advice.final_battle.001";
	end;
	
	in_vortex_final_battle_available:scroll_camera_for_intervention(
		nil,
		vortex_cam_pos.x,
		vortex_cam_pos.y,
		advice
	);
end;



-- ai final battle is available
in_vortex_ai_final_battle_available = intervention:new(
	"vortex_ai_final_battle_available",	 						-- string name
	0, 															-- cost
	function() vortex_ai_final_battle_available() end,			-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 								-- show debug output
);

in_vortex_ai_final_battle_available:set_disregard_cost_when_triggering(true);

in_vortex_ai_final_battle_available:add_trigger_condition(
	"RitualCompletedEvent",
	function(context)
		return context:succeeded() and not context:performing_faction():is_human() and not cm:is_multiplayer() and context:ritual():ritual_key():find("wh2_main_ritual_vortex_5_");
	end
);

function vortex_ai_final_battle_available()
	in_vortex_ai_final_battle_available:scroll_camera_for_intervention(
		nil,
		vortex_cam_pos.x,
		vortex_cam_pos.y,
		"wh2.camp.advice.final_battle.003"
	);
end;