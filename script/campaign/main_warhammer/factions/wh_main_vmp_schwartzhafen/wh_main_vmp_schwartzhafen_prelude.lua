
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VLAD PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


--chaos_rises_start_pos = {472.5, 277.6, 10, 0.0, 10};
--chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/dwarf_chaos_rises.CindyScene";


function start_vlad_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_vampire_counts_interventions();
end;




---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_pro02_objective_isabella_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_pro02_objective_isabella_02");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_pro02_objective_isabella_03");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_pro02_objective_isabella_04");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_pro02_objective_isabella_05");
end;







---------------------------------------------------------------
--
--	Start all vampire counts interventions
--
---------------------------------------------------------------


function start_vampire_counts_interventions()

	out.interventions("* start_vampire_counts_interventions() called");
	out("* start_vampire_counts_interventions() called");
	
	in_vampires_racial_advice:start();
	in_vampires_raising_dead_advice:start();
	
	-- global
	start_global_interventions();
end;











---------------------------------------------------------------
--
--	Vampires racial advice
--
---------------------------------------------------------------


-- intervention declaration
in_vampires_racial_advice = intervention:new(
	"in_vampires_racial_advice", 												-- string name
	50, 																		-- cost
	function() trigger_in_vampires_racial_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_vampires_racial_advice:set_min_advice_level(1);
in_vampires_racial_advice:add_precondition_unvisited_page("vampires");
in_vampires_racial_advice:add_advice_key_precondition("war.camp.prelude.vmp.vampires.001");
in_vampires_racial_advice:set_min_turn(2);

in_vampires_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_vampires_racial_advice()
	in_vampires_racial_advice:play_advice_for_intervention(
		-- Your kind are a nightmare made flesh, Sire. Yoke the power of the dead and you shall be unstoppable.
		"war.camp.prelude.vmp.vampires.001", 
		{
			"war.camp.advice.vampires.info_001",
			"war.camp.advice.vampires.info_002",
			"war.camp.advice.vampires.info_003"
		}
	)
end;






---------------------------------------------------------------
--
--	Raising Dead advice
--
---------------------------------------------------------------


-- intervention declaration
in_vampires_raising_dead_advice = intervention:new(
	"in_vampires_raising_dead_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_vampires_raising_dead_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_vampires_raising_dead_advice:set_min_advice_level(1);
in_vampires_raising_dead_advice:add_advice_key_precondition("war.camp.prelude.vmp.raising_dead.001");
in_vampires_raising_dead_advice:add_precondition_unvisited_page("raising_dead");
in_vampires_raising_dead_advice:give_priority_to_intervention("in_vampires_racial_advice");
in_vampires_raising_dead_advice:set_min_turn(4);

in_vampires_raising_dead_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_vampires_raising_dead_advice()
	in_vampires_raising_dead_advice:play_advice_for_intervention(
		-- The dead may be summoned to your will, my Lord. Rapidly augment your forces by raising the slain to your banner.
		"war.camp.prelude.vmp.raising_dead.001", 
		{
			"war.camp.advice.raising_dead.info_001",
			"war.camp.advice.raising_dead.info_002",
			"war.camp.advice.raising_dead.info_003"
		}
	)
end;


