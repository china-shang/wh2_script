
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VAMPIRE COUNTS PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------

function start_noctilus_prelude(advice_already_played)	
	-- chapter missions
	chapter_one_mission:manual_start();
	
	-- start intervention managers
	start_global_interventions();
end;

-----------------------------------------------------------------------------------
---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(
		1, 
		local_faction, 
		"wh2_dlc11_objective_noctilus_01"
	);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc11_objective_noctilus_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc11_objective_noctilus_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc11_objective_noctilus_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc11_objective_noctilus_05", "war.camp.advice.chapter_five.001");
	
	-- start the first chapter mission when the player captures a settlement (and it hasn't been started before)
	if not chapter_one_mission:has_been_issued() then
		core:add_listener(
			"chapter_one_trigger_listener",
			"ScriptEventPlayerCaptureSettlement", 
			true,
			function()
				chapter_one_mission:manual_start();
			end,
			false
		);
	end;
end;
