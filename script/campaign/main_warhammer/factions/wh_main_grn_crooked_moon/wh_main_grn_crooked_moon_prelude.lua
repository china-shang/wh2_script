
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CROOKED MOON (SKARSNIK) PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

prelude_public_order_region = "wh_main_southern_grey_mountains_karak_azgaraz";
prelude_public_order_advice_key = "war.camp.advice.public_order.001";
prelude_public_order_province = "wh_main_southern_grey_mountains";
prelude_public_order_mission_key = "war_prelude_solve_public_order_greenskins_1";

--chaos_rises_start_pos = {483.97, 226.93, 10, 0.0, 10};
--chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/greenskins_chaos_rises.CindyScene";


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
	chapter_one_mission = chapter_mission:new(1, local_faction, "wh_dlc06_objective_skarsnik_01");
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_dlc06_objective_skarsnik_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_dlc06_objective_skarsnik_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_dlc06_objective_skarsnik_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_dlc06_objective_skarsnik_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh_dlc06_objective_skarsnik_06", "war.camp.advice.chapter_six.001");
end;









---------------------------------------------------------------
--
--	Start all greenskins interventions
--
---------------------------------------------------------------

function start_greenskins_interventions()

	out.interventions("* start_greenskins_interventions() called");
	out("* start_greenskins_interventions() called");
	
	--in_greenskin_technology_requirements:start();
	--in_greenskins_technologies:start();
	in_greenskins_racial_advice:start();
	--in_greenskins_fightiness_advice:start();
	in_greenskins_underway_advice:start();
	--in_low_fightiness:start();
	--in_player_waaagh:start();
	in_raiding_camp_stance_possible:start();
	
	-- global
	start_global_interventions();
end;












---------------------------------------------------------------
--
--	Greenskin technology requirements
--
---------------------------------------------------------------

-- intervention declaration
in_greenskin_technology_requirements = intervention:new(
	"greenskin_technology_requirements",											-- string name
	30,																				-- cost
	function() trigger_greenskin_technology_requirements_advice() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 													-- show debug output
);

in_greenskin_technology_requirements:add_advice_key_precondition("war.camp.prelude.emp.technology.001");
in_greenskin_technology_requirements:add_advice_key_precondition("war.camp.prelude.grn.technology.002");
in_greenskin_technology_requirements:set_min_advice_level(1);
in_greenskin_technology_requirements:set_min_turn(2);

in_greenskin_technology_requirements:add_precondition(
	function()
		return not faction_can_research_technologies(local_faction)
	end
);


in_greenskin_technology_requirements:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		return true;
	end
);


function trigger_greenskin_technology_requirements_advice()	
	cm:set_saved_value("bool_should_issue_racial_technology_advice", true);
	
	-- build the mission
	local mm = mission_manager:new(local_faction, "war_prelude_construct_technology_building_greenskins_1");
	mm:add_new_objective("CONSTRUCT_N_BUILDINGS_INCLUDING");
	mm:add_condition("total 1");
	mm:add_condition("faction " .. local_faction);
	mm:add_condition("building_level wh_main_grn_workshop_1");
	mm:add_payload("money 1000");
	
	in_greenskin_technology_requirements:play_advice_for_intervention(
		-- The Goblins are getting lazy, you need to keep them busy or they will get up to mischief! Build them a place of work. Within suitable facilities the craftiest of their kind may be tasked with researching new methods of war.
		"war.camp.prelude.grn.technology.002", 
		{
			"war.camp.prelude.grn.technology.info_001",
			"war.camp.prelude.grn.technology.info_002",
			"war.camp.prelude.grn.technology.info_003"
		},
		mm
	);
end;













---------------------------------------------------------------
--
--	Greenskins technology
--
---------------------------------------------------------------


-- intervention declaration
in_greenskins_technologies = intervention:new(
	"greenskins_technologies", 													-- string name
	10, 																		-- cost
	function() trigger_greenskins_technologies_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_greenskins_technologies:give_priority_to_intervention("greenskin_technology_requirements");
in_greenskins_technologies:add_advice_key_precondition("war.camp.prelude.grn.technology.001");
in_greenskins_technologies:set_min_advice_level(1);

-- ensure that the player cannot reset advice history and get this mission again
in_greenskins_technologies:add_precondition(function() return not cm:get_saved_value("bool_tech_mission_issued") end);

in_greenskins_technologies:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local can_research, region_key = faction_can_research_technologies(local_faction);
		if can_research and not cm:get_faction(local_faction):has_technology("tech_grn_side_1_1_1") then
			in_greenskins_technologies.region_key = region_key;
			return true;
		end;
		return false;
	end
);


in_greenskins_technologies:add_trigger_condition(
	"ScriptEventPlayerCaptureSettlement",
	function(context)
		local can_research, region_key = faction_can_research_technologies(local_faction);
		if can_research and not cm:get_faction(local_faction):has_technology("tech_grn_side_1_1_1") then
			in_greenskins_technologies.region_key = region_key;
			return true;
		end;
		return false;
	end
);


function trigger_greenskins_technologies_advice()

	-- build the mission
	local mm = mission_manager:new(local_faction, "war_prelude_research_technology_greenskins_1");
	mm:add_new_objective("RESEARCH_TECHNOLOGY");
	mm:add_condition("technology tech_grn_side_1_1_1");
	mm:add_payload("money 2000");
	
	-- Our newly-acquired workshop opens the possibility of conducting research into better methods of war. Put their devious minds to good use, my Lord.
	local advice_key = "war.camp.prelude.grn.technology.001"
	local infotext = {
		"war.camp.prelude.grn.technology.info_001",
		"war.camp.prelude.grn.technology.info_002",
		"war.camp.prelude.grn.technology.info_003"
	};
	
	local region_key = in_greenskins_technologies.region_key;
	
	-- scroll camera to settlement if we have one
	in_greenskins_technologies:scroll_camera_to_settlement_for_intervention(
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
--	Greenskins racial advice
--
---------------------------------------------------------------


-- intervention declaration
in_greenskins_racial_advice = intervention:new(
	"in_greenskins_racial_advice", 												-- string name
	50, 																		-- cost
	function() trigger_in_greenskins_racial_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_greenskins_racial_advice:set_min_advice_level(1);
in_greenskins_racial_advice:add_precondition_unvisited_page("greenskins");
in_greenskins_racial_advice:add_advice_key_precondition("war.camp.prelude.grn.greenskins.001");
in_greenskins_racial_advice:set_min_turn(2);

in_greenskins_racial_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_greenskins_racial_advice()
	in_greenskins_racial_advice:play_advice_for_intervention(
		-- Knowledge of your own strengths is vital if any conquest is to succeed. Your kind are wild and barbarous, my Lord. Success will never be won around the table, but on the battlefield.
		"war.camp.prelude.grn.greenskins.001", 
		{
			"war.camp.advice.greenskins.info_001",
			"war.camp.advice.greenskins.info_002",
			"war.camp.advice.greenskins.info_003"
		}
	)
end;












---------------------------------------------------------------
--
--	Fightiness advice
--
---------------------------------------------------------------


-- intervention declaration
in_greenskins_fightiness_advice = intervention:new(
	"in_greenskins_fightiness_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_greenskins_fightiness_advice() end,					-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_greenskins_fightiness_advice:set_min_advice_level(1);
in_greenskins_fightiness_advice:add_precondition_unvisited_page("fightiness");
in_greenskins_fightiness_advice:add_advice_key_precondition("war.camp.prelude.grn.fightiness.001");
in_greenskins_fightiness_advice:give_priority_to_intervention("in_greenskins_racial_advice");
in_greenskins_fightiness_advice:set_min_turn(3);

in_greenskins_fightiness_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);


function trigger_in_greenskins_fightiness_advice()
	in_greenskins_fightiness_advice:play_advice_for_intervention(
		-- The boys clamour for battle grows with each victory. The fervour of your kind can be a powerful force if harnessed, but an Orc's lust for blood, if left unsated, can be his undoing.
		"war.camp.prelude.grn.fightiness.001", 
		{
			"war.camp.advice.waaagh.info_001",
			"war.camp.advice.waaagh.info_002",
			"war.camp.advice.waaagh.info_003"
		}
	);
end;








---------------------------------------------------------------
--
--	Underway advice
--
---------------------------------------------------------------


-- intervention declaration
in_greenskins_underway_advice = intervention:new(
	"in_greenskins_underway_advice", 											-- string name
	60, 																		-- cost
	function() trigger_in_greenskins_underway_advice() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_greenskins_underway_advice:set_min_advice_level(1);
in_greenskins_underway_advice:add_precondition_unvisited_page("underway");
in_greenskins_underway_advice:add_advice_key_precondition("war.camp.prelude.grn.underways.001");
in_greenskins_underway_advice:add_advice_key_precondition("war.camp.prelude.dwf.underways.001");
in_greenskins_underway_advice:give_priority_to_intervention("in_greenskins_fightiness_advice");
in_greenskins_underway_advice:set_min_turn(4);

in_greenskins_underway_advice:add_precondition(
	function()
		return not effect.get_advice_history_string_seen("use_underway_stance")
	end
);

in_greenskins_underway_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return true;
	end
);

function trigger_in_greenskins_underway_advice()
	in_greenskins_underway_advice:play_advice_for_intervention(
		-- Be sure to make use of the Underway when moving your boys through difficult terrain, mighty Lord. Much time can be saved when moving below ground.
		"war.camp.prelude.grn.underways.001", 
		{
			"war.camp.advice.underway.info_001",
			"war.camp.advice.underway.info_002",
			"war.camp.advice.underway.info_003",
			"war.camp.advice.underway.info_004"
		}
	);
end;








---------------------------------------------------------------
--
--	low fightiness
--
---------------------------------------------------------------

-- intervention declaration
in_low_fightiness = intervention:new(
	"low_fightiness",	 											-- string name
	25, 															-- cost
	function() in_low_fightiness_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 									-- show debug output
);

in_low_fightiness:set_min_advice_level(1);
in_low_fightiness:add_advice_key_precondition("war.camp.advice.fightiness.001");

in_low_fightiness:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local mf_list = context:faction():military_force_list();
		
		for i = 0, mf_list:num_items() - 1 do
			local current_mf = mf_list:item_at(i);
			
			if not current_mf:is_armed_citizenry() and current_mf:morale() < 40 then
				in_low_fightiness.mf_cqi = current_mf:command_queue_index();
				return true;
			end;
		end;
		
		return false;
	end
);



function in_low_fightiness_advice_trigger()
	local mf_cqi = in_low_fightiness.mf_cqi;
	local char_cqi = false;
	
	if is_number(mf_cqi) then
		local mf = cm:model():military_force_for_command_queue_index(mf_cqi);
		
		if is_militaryforce(mf) and mf:has_general() then
			char_cqi = mf:general_character():cqi();
		end;
	end;
	
	-- The grunts grow restless for battle, savage Lord. Their bloodlust is causing them to turn on each other! Find something for them to fight, please, before the whole army beats itself to a pulp!
	local advice_key = "war.camp.advice.fightiness.001";
	local infotext = {
		"war.camp.advice.fightiness.info_001",
		"war.camp.advice.fightiness.info_002",
		"war.camp.advice.fightiness.info_005",
		"war.camp.advice.fightiness.info_004"
	};
	
	in_low_fightiness:scroll_camera_to_character_for_intervention( 
		char_cqi,
		advice_key, 
		infotext
	);
end;








---------------------------------------------------------------
--
--	player waaaagh
--
---------------------------------------------------------------

-- intervention declaration
in_player_waaagh = intervention:new(
	"player_waaagh",					 														-- string name
	20, 																					-- cost
	function() in_player_waaagh_trigger() end,													-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 															-- show debug output
);

in_player_waaagh:set_min_advice_level(1);
in_player_waaagh:add_advice_key_precondition("war.camp.advice.waaagh.001");

in_player_waaagh:add_trigger_condition(
	"ScriptEventPlayerCharacterWaaaghOccurred",
	function(context)
		in_player_waaagh.char_cqi = context:character():cqi();
		return true;
	end
);


function in_player_waaagh_trigger()
	local char_cqi = in_player_waaagh.char_cqi;
		
	-- A Waaagh! mighty Lord! The bloodlust of your boys has attracted more of your kin to their banner. Your forces are unstoppable!
	local advice_key = "war.camp.advice.waaagh.001";
	local infotext = {
		"war.camp.advice.waaagh.info_001",
		"war.camp.advice.waaagh.info_002", 
		"war.camp.advice.waaagh.info_003"
	};
	
	in_player_waaagh:scroll_camera_to_character_for_intervention( 
		char_cqi,
		advice_key, 
		infotext
	);
end;













---------------------------------------------------------------
--
--	Raidin' Camp Stance Possible
--
---------------------------------------------------------------

-- intervention declaration
in_raiding_camp_stance_possible = intervention:new(
	"raiding_camp_stance_possible",	 										-- string name
	60, 																	-- cost
	function() in_raiding_camp_stance_possible_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_raiding_camp_stance_possible:set_min_advice_level(1);
in_raiding_camp_stance_possible:add_advice_key_precondition("war.camp.advice.raiding.003");
in_raiding_camp_stance_possible:add_precondition(function() return not uim:get_interaction_monitor_state("raidin_camp_stance") end);
in_raiding_camp_stance_possible:set_min_turn(6);

in_raiding_camp_stance_possible:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local player_faction = cm:get_faction(local_faction);
		return cm:faction_has_armies_in_enemy_territory(player_faction);
	end
);

function in_raiding_camp_stance_possible_trigger()
	in_raiding_camp_stance_possible:play_advice_for_intervention(
		-- Consider raising a camp in the lands of the enemy, savage Lord. It shall become a base from which your warriors may raid the countryside.
		"war.camp.advice.raiding.003", 
		{
			"war.camp.advice.raiding.info_001",
			"war.camp.advice.raiding.info_002", 
			"war.camp.advice.raiding.info_004",
			"war.camp.advice.raiding.info_005"
		}
	);
end;
