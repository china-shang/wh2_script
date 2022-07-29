
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CARCASSONNE PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

function start_carcassonne_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_carcassonne_interventions();
end;

---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_dlc07_objective_01_wh_main_brt_carcassonne", "dlc07.camp.advice.brt.errantry_war.001");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_dlc07_objective_02_wh_main_brt_carcassonne", "dlc07.camp.advice.brt.errantry_war.002");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_dlc07_objective_03_wh_main_brt_carcassonne", "dlc07.camp.advice.brt.errantry_war.004");
end;

---------------------------------------------------------------
--
--	Start all Bretonnia interventions
--
---------------------------------------------------------------

function start_carcassonne_interventions()

	out.interventions("* start_carcassonne_interventions() called");
	out("* start_carcassonne_interventions() called");
	
	-- global
	start_global_interventions();
end;