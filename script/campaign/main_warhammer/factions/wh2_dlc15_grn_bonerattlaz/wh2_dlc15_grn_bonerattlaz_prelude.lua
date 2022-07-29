
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	GREENSKINS PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

function start_greenskins_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_greenskins_interventions();
end;




---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------


if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_dlc15_objective_azhag_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc15_objective_azhag_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc15_objective_azhag_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc15_objective_azhag_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc15_objective_azhag_05", "war.camp.advice.chapter_five.001");
end;




---------------------------------------------------------------
--
--	Start all greenskins interventions
--
---------------------------------------------------------------

function start_greenskins_interventions()

	out.interventions("* start_greenskins_interventions() called");
	out("* start_greenskins_interventions() called");
	
	-- global
	start_global_interventions();
end;




