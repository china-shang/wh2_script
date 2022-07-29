
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	BRETONNIA PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

function start_wintertooth_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_global_interventions();
end;

---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_dlc08_objective_01_wh_dlc08_nor_wintertooth", "dlc08.camp.advice.nor.chapter_1.001");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_dlc08_objective_02_wh_dlc08_nor_wintertooth", "dlc08.camp.advice.nor.chapter_2.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_dlc08_objective_03_wh_dlc08_nor_wintertooth", "dlc08.camp.advice.nor.chapter_3.001");
end;