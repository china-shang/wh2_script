
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	DWARF PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

prelude_public_order_region = "wh_main_peak_pass_karak_kadrin";
prelude_public_order_advice_key = "war.camp.prelude.dwf.public_order.001";
prelude_public_order_province = "wh_main_peak_pass";
prelude_public_order_mission_key = "war_prelude_solve_public_order_dwarfs_1";

--chaos_rises_start_pos = {472.5, 277.6, 10, 0.0, 10};
--chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/dwarf_chaos_rises.CindyScene";


function start_dwarfs_prelude(advice_already_played)
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_dwarf_interventions();
end;

---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_main_objective_dwarf_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_main_objective_dwarf_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_main_objective_dwarf_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_main_objective_dwarf_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_main_objective_dwarf_05", "war.camp.advice.chapter_five.001");
end;

---------------------------------------------------------------
--
--	Start all dwarf interventions
--
---------------------------------------------------------------

function start_dwarf_interventions()

	out.interventions("* start_dwarf_interventions() called");
	out("* start_dwarf_interventions() called");
	
	in_dwarfs_racial_advice:start();
	in_dwarfs_underway_advice:start();
	in_grudges_advice:start();
	
	-- global
	start_global_interventions();
end;

---------------------------------------------------------------
--
--	Dwarfs racial advice
--
---------------------------------------------------------------
-- intervention declaration
in_dwarfs_racial_advice = intervention:new(
	"in_dwarfs_racial_advice", 													-- string name
	50, 																		-- cost
	function() trigger_in_dwarfs_racial_advice() end,							-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_dwarfs_racial_advice:set_min_advice_level(1);
in_dwarfs_racial_advice:add_precondition_unvisited_page("dwarfs");
in_dwarfs_racial_advice:add_advice_key_precondition("war.camp.prelude.dwf.dwarfs.001");
in_dwarfs_racial_advice:set_min_turn(2);

in_dwarfs_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);

function trigger_in_dwarfs_racial_advice()
	in_dwarfs_racial_advice:play_advice_for_intervention(
		-- As you know all too well, the power of the Dawi has reverberated through these mountains for millennia. Harness that strength, and you will have all you need to restore the Karaz Ankor to its former glory.
		"war.camp.prelude.dwf.dwarfs.001", 
		{
			"war.camp.advice.dwarfs.info_001",
			"war.camp.advice.dwarfs.info_002",
			"war.camp.advice.dwarfs.info_003"
		}
	)
end;

---------------------------------------------------------------
--
--	Underway advice
--
---------------------------------------------------------------

-- intervention declaration
in_dwarfs_underway_advice = intervention:new(
	"in_dwarfs_underway_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_dwarfs_underway_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_dwarfs_underway_advice:set_min_advice_level(1);
in_dwarfs_underway_advice:add_precondition_unvisited_page("underway");
in_dwarfs_underway_advice:add_advice_key_precondition("war.camp.prelude.grn.underways.001");
in_dwarfs_underway_advice:add_advice_key_precondition("war.camp.prelude.dwf.underways.001");
in_dwarfs_underway_advice:give_priority_to_intervention("in_dwarfs_racial_advice");
in_dwarfs_underway_advice:set_min_turn(4);

in_dwarfs_underway_advice:add_precondition(
	function()
		return not effect.get_advice_history_string_seen("use_underway_stance")
	end
);

in_dwarfs_underway_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_dwarfs_underway_advice()
	in_dwarfs_underway_advice:play_advice_for_intervention(
		-- Be sure to make use of the Underway when moving your folk around the mountains, Sire. Much time can be saved when travelling below ground.
		"war.camp.prelude.dwf.underways.001", 
		{
			"war.camp.advice.underway.info_001",
			"war.camp.advice.underway.info_002",
			"war.camp.advice.underway.info_003",
			"war.camp.advice.underway.info_004"
		}
	)
end;

---------------------------------------------------------------
--
--	Grudges advice
--
---------------------------------------------------------------

in_grudges_advice = intervention:new(
	"grudges_advice", 														-- string name
	20, 																	-- cost
	function() in_grudges_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_grudges_advice:add_advice_key_precondition("war.camp.prelude.dwf.grudges.001");
in_grudges_advice:set_min_advice_level(1);
in_grudges_advice:set_wait_for_event_dismissed(false);

in_grudges_advice:add_trigger_condition(
	"ScriptEventPlayerAcceptsMission",
	true
);

function in_grudges_advice_trigger()

	in_grudges_advice:play_advice_for_intervention(
		-- Misdeeds committed against your kind are recorded in the venerable Book of Grudges - the Dammaz Kron. Once documented, no transgression should remain unpunished, my King.
		"war.camp.prelude.dwf.grudges.001",
		{
			"war.camp.advice.grudges.info_001",
			"war.camp.advice.grudges.info_002",
			"war.camp.advice.grudges.info_003"
		}
	);
end;
