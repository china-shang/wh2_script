
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	Grom The Paunch (BROKEN AXE) PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

--chaos_rises_start_pos = {472.5, 277.6, 10, 0.0, 10};
--chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/dwarf_chaos_rises.CindyScene";


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
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh2_dlc15_objective_grom_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc15_objective_grom_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc15_objective_grom_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc15_objective_grom_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc15_objective_grom_05", "war.camp.advice.chapter_five.001");
end;









---------------------------------------------------------------
--
--	Start all Greenskins interventions
--
---------------------------------------------------------------

function start_greenskins_interventions()

	out.interventions("* start_greenskins_interventions() called");
	out("* start_greenskins_interventions() called");
	
	-- global
	start_global_interventions();
end;