
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- RAKARTH PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

function start_the_blessed_dread_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_dark_elves_interventions();
end;

---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_twa03_objective_rakarth_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_twa03_objective_rakarth_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_twa03_objective_rakarth_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_twa03_objective_rakarth_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_twa03_objective_rakarth_05", "war.camp.advice.chapter_five.001");
end;

---------------------------------------------------------------
--
--	Start all Dark Elf interventions
--
---------------------------------------------------------------

function start_dark_elves_interventions()

	out.interventions("* start_dark_elves_interventions() called");
	out("* start_dark_elves_interventions() called");
	
	-- global
	start_global_interventions();
end;