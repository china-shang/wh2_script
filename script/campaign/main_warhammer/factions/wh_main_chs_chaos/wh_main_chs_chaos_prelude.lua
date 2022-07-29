
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	PRELUDE SCRIPT
--
--	This script controls the prelude, issuing missions and the like.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

out("Prelude loaded for " .. local_faction);


function start_chaos_prelude()	
	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	cm:modify_advice(true);
		
	start_chaos_interventions();
end;



---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_main_objective_chaos_01", nil);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_main_objective_chaos_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_main_objective_chaos_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_main_objective_chaos_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_main_objective_chaos_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh_main_objective_chaos_06", "war.camp.advice.chapter_six.001");
end;









---------------------------------------------------------------
--
--	Start all chaos interventions
--
---------------------------------------------------------------

function start_chaos_interventions()

	out.interventions("* start_chaos_interventions() called");
	out("* start_chaos_interventions() called");
		
	-- global
	start_global_interventions();
	
	in_chaos_racial_advice:start();
	in_chaos_horde_advice:start();
end;










---------------------------------------------------------------
--
--	chaos racial advice
--
---------------------------------------------------------------


-- intervention declaration
in_chaos_racial_advice = intervention:new(
	"in_chaos_racial_advice", 													-- string name
	25, 																		-- cost
	function() trigger_in_chaos_racial_advice() end,							-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_chaos_racial_advice:set_min_advice_level(1);
in_chaos_racial_advice:add_precondition_unvisited_page("chaos");
in_chaos_racial_advice:add_advice_key_precondition("war.camp.prelude.chs.chaos.001");
in_chaos_racial_advice:set_min_turn(2);

in_chaos_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_in_chaos_racial_advice()
	in_chaos_racial_advice:play_advice_for_intervention(	
		-- Your kind are the will of the Dark Gods made manifest, mighty lord. Harness the gifts afforded to you by the Ruinous Powers and you shall be unstoppable.
		"war.camp.prelude.chs.chaos.001", 
		{
			"war.camp.advice.warriors_of_chaos.info_001",
			"war.camp.advice.warriors_of_chaos.info_002",
			"war.camp.advice.warriors_of_chaos.info_003"
		}
	)
end;









---------------------------------------------------------------
--
--	chaos horde advice
--
---------------------------------------------------------------


-- intervention declaration
in_chaos_horde_advice = intervention:new(
	"in_chaos_horde_advice", 													-- string name
	40, 																		-- cost
	function() trigger_in_chaos_horde_advice() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_chaos_horde_advice:set_min_advice_level(1);
in_chaos_horde_advice:add_precondition_unvisited_page("hordes");
in_chaos_horde_advice:add_advice_key_precondition("war.camp.prelude.chs.hordes.002");
in_chaos_horde_advice:give_priority_to_intervention("in_chaos_racial_advice");
in_chaos_horde_advice:set_min_turn(3);

in_chaos_horde_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_in_chaos_horde_advice()
	in_chaos_horde_advice:play_advice_for_intervention(
		-- Your warriors live their lives on the march, mighty lord. The hordes have no need for towns or cities. Raze all that you find in the name of the Dark Gods!
		"war.camp.prelude.chs.hordes.002", 
		{
			"war.camp.advice.hordes.info_001",
			"war.camp.advice.hordes.info_002",
			"war.camp.advice.hordes.info_003"
		}
	)
end;






