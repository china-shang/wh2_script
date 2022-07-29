
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	PRELUDE SCRIPT
--
--	This script controls the prelude, issuing missions and the like.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function start_beastmen_prelude()
	-- chapter missions
	chapter_one_mission:manual_start();
	
	cm:modify_advice(true);
		
	start_beastmen_interventions();
end;



---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_dlc17_objective_taurox_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc17_objective_taurox_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc17_objective_taurox_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc17_objective_taurox_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc17_objective_taurox_05", "war.camp.advice.chapter_five.001");
end;



---------------------------------------------------------------
--
--	Start all beastmen interventions
--
---------------------------------------------------------------

function start_beastmen_interventions()

	out.interventions("* start_beastmen_interventions() called");
	out("* start_beastmen_interventions() called");
		
	-- global
	start_global_interventions(true);
	core:trigger_event("ScriptEventBeastmenCampaignStart")
	in_beastmen_racial_advice:start();
	in_beastmen_horde_advice:start();
	in_beastmen_bestial_rage_advice:start();
	in_low_bestial_rage:start();
	in_player_brayherd:start();
	in_beastmen_beast_paths_advice:start();
	in_beastmen_hidden_encampment_stance_advice:start();
end;










---------------------------------------------------------------
--
--	beastmen racial advice
--
---------------------------------------------------------------


-- intervention declaration
in_beastmen_racial_advice = intervention:new(
	"in_beastmen_racial_advice", 												-- string name
	25, 																		-- cost
	function() trigger_in_beastmen_racial_advice() end,							-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_beastmen_racial_advice:set_min_advice_level(1);
in_beastmen_racial_advice:add_precondition_unvisited_page("beastmen");
in_beastmen_racial_advice:add_advice_key_precondition("dlc03.camp.advice.bst.beastmen.001");
in_beastmen_racial_advice:set_min_turn(2);

in_beastmen_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_in_beastmen_racial_advice()
	in_beastmen_racial_advice:play_advice_for_intervention(
		-- You are the Children of Chaos, as much a part of the Ruinous Powers as the horns that sprout from your head. Your kind yearns for destruction; to root out order and civilisation and despoil it! March forth, and spread the corrupting taint of the Dark Gods!
		"dlc03.camp.advice.bst.beastmen.001", 
		{
			"war.camp.advice.beastmen.info_001",
			"war.camp.advice.beastmen.info_002",
			"war.camp.advice.beastmen.info_003"
		}
	)
end;









---------------------------------------------------------------
--
--	beastmen horde advice
--
---------------------------------------------------------------


-- intervention declaration
in_beastmen_horde_advice = intervention:new(
	"in_beastmen_horde_advice", 													-- string name
	40, 																			-- cost
	function() trigger_in_beastmen_horde_advice() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 													-- show debug output
);

in_beastmen_horde_advice:set_min_advice_level(1);
in_beastmen_horde_advice:add_precondition_unvisited_page("hordes");
in_beastmen_horde_advice:add_advice_key_precondition("dlc03.camp.advice.bst.hordes.001");
in_beastmen_horde_advice:give_priority_to_intervention("in_beastmen_racial_advice");
in_beastmen_horde_advice:set_min_turn(3);

in_beastmen_horde_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_in_beastmen_horde_advice()
	in_beastmen_horde_advice:play_advice_for_intervention(	
		-- Your warriors live their lives on the march, mighty lord. The hordes have no need for towns or cities. Raze all that you find in the name of the Dark Gods!
		"dlc03.camp.advice.bst.hordes.001", 
		{
			"war.camp.advice.hordes.info_001",
			"war.camp.advice.hordes.info_002",
			"war.camp.advice.hordes.info_003"
		}
	)
end;





















---------------------------------------------------------------
--
--	Bestial Rage advice
--
---------------------------------------------------------------


-- intervention declaration
in_beastmen_bestial_rage_advice = intervention:new(
	"in_beastmen_bestial_rage_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_beastmen_bestial_rage_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_beastmen_bestial_rage_advice:set_min_advice_level(1);
in_beastmen_bestial_rage_advice:add_precondition_unvisited_page("bestial_rage");
in_beastmen_bestial_rage_advice:add_advice_key_precondition("dlc03.camp.advice.bst.bestial_rage.001");
in_beastmen_bestial_rage_advice:give_priority_to_intervention("in_beastmen_racial_advice");
in_beastmen_bestial_rage_advice:set_min_turn(3);

in_beastmen_bestial_rage_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_beastmen_bestial_rage_advice()
	in_beastmen_bestial_rage_advice:play_advice_for_intervention(
		-- There is rage inside you; I can feel it, just as there is in all true-horns! It is a gift from the Granter of Savage Hate - keep the fury contained within and then unleash it at the right moment!
		"dlc03.camp.advice.bst.bestial_rage.001", 
		{
			"war.camp.advice.bestial_rage.info_001",
			"war.camp.advice.bestial_rage.info_002",
			"war.camp.advice.bestial_rage.info_003",
			"war.camp.advice.bestial_rage.info_005"
		}
	);
end;















---------------------------------------------------------------
--
--	low bestial rage
--
---------------------------------------------------------------

-- intervention declaration
in_low_bestial_rage = intervention:new(
	"low_bestial_rage",	 												-- string name
	25, 																-- cost
	function() in_low_bestial_rage_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 										-- show debug output
);

in_low_bestial_rage:set_min_advice_level(1);
in_low_bestial_rage:add_advice_key_precondition("dlc03.camp.advice.bst.bestial_rage.002");

in_low_bestial_rage:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local mf_list = context:faction():military_force_list();
		
		for i = 0, mf_list:num_items() - 1 do
			local current_mf = mf_list:item_at(i);
			
			if not current_mf:is_armed_citizenry() and current_mf:morale() < 40 then
				in_low_bestial_rage.mf_cqi = current_mf:command_queue_index();
				return true;
			end;
		end;
		
		return false;
	end
);



function in_low_bestial_rage_advice_trigger()
	local mf_cqi = in_low_bestial_rage.mf_cqi;
	local char_cqi = false;
	
	if is_number(mf_cqi) then
		local mf = cm:model():military_force_for_command_queue_index(mf_cqi);
		
		if is_militaryforce(mf) and mf:has_general() then
			char_cqi = mf:general_character():cqi();
		end;
	end;
	
	in_low_bestial_rage:scroll_camera_to_character_for_intervention( 
		char_cqi,
		-- The Gors must fight and feast on flesh, my Lord. If they remain passive too long, their bestial instincts will see them turn on each other.
		"dlc03.camp.advice.bst.bestial_rage.002", 
		{
			"war.camp.advice.bestial_rage.info_001",
			"war.camp.advice.bestial_rage.info_002",
			"war.camp.advice.bestial_rage.info_004",
			"war.camp.advice.bestial_rage.info_005"
		}
	);
end;












---------------------------------------------------------------
--
--	player brayherd
--
---------------------------------------------------------------

-- intervention declaration
in_player_brayherd = intervention:new(
	"player_brayherd",					 													-- string name
	20, 																					-- cost
	function() in_player_brayherd_trigger() end,											-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 															-- show debug output
);

in_player_brayherd:set_min_advice_level(1);
in_player_brayherd:add_advice_key_precondition("dlc03.camp.advice.bst.brayherds.001");

in_player_brayherd:add_trigger_condition(
	"ScriptEventPlayerCharacterWaaaghOccurred",
	function(context)
		in_player_brayherd.char_cqi = context:character():cqi();
		return true;
	end
);


function in_player_brayherd_trigger()
	
	in_player_brayherd:scroll_camera_to_character_for_intervention(
		in_player_brayherd.char_cqi,
		-- Good, good! Unleash the rage within! The warherds have gathered and a brayherd has been formed. Harness its fury and crush your enemies!
		"dlc03.camp.advice.bst.brayherds.001", 
		{
			"war.camp.advice.brayherd.info_001",
			"war.camp.advice.brayherd.info_002", 
			"war.camp.advice.brayherd.info_003"
		}
	);
end;















---------------------------------------------------------------
--
--	Beast Paths advice
--
---------------------------------------------------------------


-- intervention declaration
in_beastmen_beast_paths_advice = intervention:new(
	"in_beastmen_beast_paths_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_beastmen_beast_paths_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_beastmen_beast_paths_advice:set_min_advice_level(1);
in_beastmen_beast_paths_advice:add_precondition_unvisited_page("beast_paths");
in_beastmen_beast_paths_advice:give_priority_to_intervention("in_beastmen_bestial_rage_advice");
in_beastmen_beast_paths_advice:set_min_turn(4);

in_beastmen_beast_paths_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);

function trigger_in_beastmen_beast_paths_advice()
	in_beastmen_beast_paths_advice:play_advice_for_intervention(
		-- The beast-paths are hidden ways known only to the Cloven Ones. Use them, my brutal Lord, to traverse the forests.
		"dlc03.camp.advice.bst.beast_paths.001", 
		{
			"war.camp.advice.beast_paths.info_001",
			"war.camp.advice.beast_paths.info_002",
			"war.camp.advice.beast_paths.info_003",
			"war.camp.advice.beast_paths.info_004"
		}
	);
end;












---------------------------------------------------------------
--
--	Hidden Encampment Stance advice
--
---------------------------------------------------------------


-- intervention declaration
in_beastmen_hidden_encampment_stance_advice = intervention:new(
	"in_beastmen_hidden_encampment_stance_advice", 										-- string name
	60, 																				-- cost
	function() trigger_in_beastmen_hidden_encampment_stance_advice() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 														-- show debug output
);

in_beastmen_hidden_encampment_stance_advice:set_min_advice_level(1);
in_beastmen_hidden_encampment_stance_advice:set_min_turn(3);

-- return true if the player starts a turn with an army in enemy territory with < 80% strength
in_beastmen_hidden_encampment_stance_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local player_faction = cm:get_faction(local_faction);
		local mf_list = player_faction:military_force_list();
		
		for i = 0, mf_list:num_items() - 1 do
			local current_mf = mf_list:item_at(i);
			
			if current_mf:has_general() then
				local current_char = current_mf:general_character(); 
				if current_char:has_region() and current_char:region():owning_faction():at_war_with(player_faction) and current_mf:active_stance() ~= "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE" and cm:military_force_average_strength(current_mf) < 80 then
					return true;
				end;
			end;
		end;
		
		return false;
	end
);


-- also returns true if the player finishes a battle with an army in enemy territory with < 80% strength
in_beastmen_hidden_encampment_stance_advice:add_trigger_condition(
	"ScriptEventPlayerBattleSequenceCompleted",
	function(context)
		local player_faction = cm:get_faction(local_faction);
		local mf_list = player_faction:military_force_list();
		
		for i = 0, mf_list:num_items() - 1 do
			local current_mf = mf_list:item_at(i);
			
			if current_mf:has_general() then
				local current_char = current_mf:general_character(); 
				if current_char:has_region() and current_char:region():owning_faction():at_war_with(player_faction) and current_mf:active_stance() ~= "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE" and cm:military_force_average_strength(current_mf) < 80 then
					return true;
				end;
			end;
		end;
		
		return false;
	end
);



function trigger_in_beastmen_hidden_encampment_stance_advice()
	in_beastmen_hidden_encampment_stance_advice:play_advice_for_intervention(
		-- Consider making camp, Beastlord. An encampment will draw more Gors to your cause, allowing your followers time to lick their wounds and give tribute to the Dark Gods.
		"dlc03.camp.advice.bst.encampment.001",
		{
			"war.camp.advice.stances.info_001",
			"war.camp.advice.stances.info_002",
			"war.camp.advice.stances.info_003",
			"war.camp.advice.stances.info_004"
		}
	);
end;