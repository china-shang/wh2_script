
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VOLKMAR PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

function start_volkmar_prelude(advice_already_played)	
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
	chapter_one_mission = chapter_mission:new(
		1, 
		local_faction, 
		"wh2_dlc13_objective_gelt_01", 
		"war.camp.prelude.emp.chapter_one.001", 
		{
			"war.camp.advice.victory_conditions.info_001",
			"war.camp.advice.victory_conditions.info_002",
			"war.camp.advice.victory_conditions.info_003"
		}
	);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh2_dlc13_objective_gelt_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh2_dlc13_objective_gelt_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh2_dlc13_objective_gelt_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh2_dlc13_objective_gelt_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh2_dlc13_objective_gelt_06", "war.camp.advice.chapter_six.001");
	
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

---------------------------------------------------------------
--
--	Start all empire interventions
--
---------------------------------------------------------------

function start_empire_interventions()

	out.interventions("* start_empire_interventions() called");
	out("* start_empire_interventions() called");
	
	in_empire_technology_requirements:start();
	in_empire_technologies:start();
	in_empire_racial_advice:start();
	in_offices_advice:start();
			
	-- global
	start_global_interventions();
end;

---------------------------------------------------------------
--
--	Empire technology requirements
--
---------------------------------------------------------------

-- intervention declaration
in_empire_technology_requirements = intervention:new(
	"empire_technology_requirements",											-- string name
	50,																			-- cost
	function() trigger_empire_technology_requirements_advice() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_empire_technology_requirements:add_advice_key_precondition("war.camp.prelude.emp.technology.001");
in_empire_technology_requirements:add_advice_key_precondition("war.camp.prelude.grn.technology.002");
in_empire_technology_requirements:set_min_advice_level(1);
in_empire_technology_requirements:set_min_turn(2);

in_empire_technology_requirements:add_precondition(
	function()
		-- don't play this advice if the first turn was played, as the player got tasked there to build a technology-enabling building
		return not cm:get_saved_value("bool_prelude_first_turn_was_loaded");
	end
);

in_empire_technology_requirements:add_precondition(
	function()
		-- don't play this advice if the player can already research technologies
		return not faction_can_research_technologies(local_faction)
	end
);


in_empire_technology_requirements:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);

function trigger_empire_technology_requirements_advice()
	out("trigger_empire_technology_requirements_advice() called");
	
	-- build the mission
	local mm = mission_manager:new(local_faction, "war_prelude_construct_technology_building_empire_1");
	
	mm:add_new_objective("CONSTRUCT_N_BUILDINGS_FROM");
	mm:add_condition("total 1");
	mm:add_condition("building_level wh_main_emp_port_2");
	mm:add_condition("building_level wh_main_emp_barracks_2");
	mm:add_condition("building_level wh_main_emp_stables_2");
	mm:add_condition("building_level wh_main_emp_forges_2");
	mm:add_condition("building_level wh_main_emp_smiths_1");
	mm:add_condition("building_level wh_main_emp_worship_2");
	mm:add_condition("faction wh_main_emp_empire");
	mm:add_payload("money 2000");
	
	in_empire_technology_requirements:scroll_camera_to_settlement_for_intervention( 
		altdorf_region_str,
		-- Altdorf is home to the greatest minds in all the Empire. Put them to work on improving your methods of warfare, my Emperor. For this task they will need even grander edifices - construct these, and unleash their creativity.
		"war.camp.prelude.emp.technology.001", 
		{
			"war.camp.prelude.emp.technology.info_001",
			"war.camp.prelude.emp.technology.info_002",
			"war.camp.prelude.emp.technology.info_003"
		},
		mm
	);
end;

---------------------------------------------------------------
--
--	Empire technology
--
---------------------------------------------------------------

-- intervention declaration
in_empire_technologies = intervention:new(
	"empire_technologies", 														-- string name
	10, 																		-- cost
	function() trigger_empire_technologies_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_empire_technologies:give_priority_to_intervention("empire_technology_requirements");
in_empire_technologies:add_advice_key_precondition("war.camp.prelude.emp.technology.002");
in_empire_technologies:set_min_advice_level(1);

-- ensure that the player cannot reset advice history and get this mission again
in_empire_technologies:add_precondition(function() return not cm:get_saved_value("bool_tech_mission_issued") end);

in_empire_technologies:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local can_research, region_key = faction_can_research_technologies(local_faction);
		if can_research then
			in_empire_technologies.region_key = region_key;
			return true;
		end;
		return false;
	end
);

in_empire_technologies:add_trigger_condition(
	"ScriptEventPlayerCaptureSettlement",
	function(context)
		local can_research, region_key = faction_can_research_technologies(local_faction);
		if can_research then
			in_empire_technologies.region_key = region_key;
			return true;
		end;
		return false;
	end
);


function trigger_empire_technologies_advice()

	-- build the mission
	local mm = mission_manager:new(local_faction, "war_prelude_research_technology_empire_1");
	mm:add_new_objective("RESEARCH_N_TECHS_INCLUDING");
	mm:add_condition("total 1");
	mm:add_payload("money 2000");
	
	-- Altdorf is home to the greatest minds in all the Empire. Put them to work on improving your methods of warfare, my Emperor. For this task they will need even grander edifices - construct these, and unleash their creativity.
	local advice_key = "war.camp.prelude.emp.technology.002"
	local infotext = {
		"war.camp.prelude.emp.technology.info_001",
		"war.camp.prelude.emp.technology.info_002",
		"war.camp.prelude.emp.technology.info_003"
	};
	
	local region_key = in_empire_technologies.region_key;
	
	-- scroll camera to settlement if we have one
	in_empire_technologies:scroll_camera_to_settlement_for_intervention( 
		region_key, 
		advice_key, 
		infotext, 
		mm
	);
	
	-- ensure that the player cannot reset advice history and get this mission again
	cm:set_saved_value("bool_tech_mission_issued", true);
end;

---------------------------------------------------------------
--
--	Empire racial advice
--
---------------------------------------------------------------


-- intervention declaration
in_empire_racial_advice = intervention:new(
	"in_empire_racial_advice", 													-- string name
	25, 																		-- cost
	function() trigger_in_empire_racial_advice() end,							-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_empire_racial_advice:set_min_advice_level(1);
in_empire_racial_advice:add_precondition_unvisited_page("empire");
in_empire_racial_advice:add_advice_key_precondition("war.camp.prelude.emp.empire.001");
in_empire_racial_advice:set_min_turn(2);

in_empire_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_in_empire_racial_advice()
	in_empire_racial_advice:play_advice_for_intervention(
		-- Your Empire is a beacon of civility in a savage world, my Emperor. It is your task - nay, your privilege, to see that it does not fall to the countless evils that threaten its borders. Study your own strengths, and that of your enemy, carefully.
		"war.camp.prelude.emp.empire.001", 
		{
			"war.camp.advice.empire.info_001",
			"war.camp.advice.empire.info_002",
			"war.camp.advice.empire.info_003"
		}
	)
end;