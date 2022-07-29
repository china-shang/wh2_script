
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	VAMPIRE COUNTS PRELUDE SCRIPT
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------



---------------------------------------------------------------
--
--	Start the open prelude
--
---------------------------------------------------------------

prelude_public_order_region = castle_drakenhof_region_str;
prelude_public_order_advice_key = "war.camp.prelude.vmp.public_order.001";
prelude_public_order_province = "wh_main_eastern_sylvania";
prelude_public_order_mission_key = "war_prelude_solve_public_order_vampire_counts_1";

chaos_rises_start_pos = {459.2, 326.1, 10, 0.0, 10};
chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/vampire_counts_chaos_rises.CindyScene";


function start_vampire_counts_prelude(advice_already_played)
	
	-- trigger this before starting interventions to ensure that the attack enemy mission happens first
	if not disable_wh1_intro_missions then
		attack_enemy_mission:start(advice_already_played);
	end;
	
	-- start intervention managers
	start_vampire_counts_interventions();
	
	-- set Templehof personality
	cm:force_change_cai_faction_personality(templehof_faction_str, "wh_script_foolishly_brave");
end;












---------------------------------------------------------------
--
--	Initial attack enemy mission
--
---------------------------------------------------------------

ca_starting_area = convex_area:new({
	v(450.0, 303.0),		-- display co-ords
	v(433.0, 324.0),
	v(471.0, 339.0),
	v(480.0, 312.0)
});

attack_enemy_mission = first_attack_enemy_mission:new(
	-- Van Kruger knows his position is weak, and has sent out an army to check our advance! Their strength can be added to our own - let us attack!
	"war.camp.prelude.vmp.attacking_enemy.001",						-- start advice
	"war_prelude_attack_enemy_vampire_counts_1",					-- mission key
	local_faction, 													-- player faction key
	templehof_faction_str,											-- enemy faction key
	get_first_enemy_army_cqi(), 									-- enemy cqi
	ca_starting_area, 												-- convex starting area
	function()														-- end callback
		out("First attack enemy mission completed");
		cm:cai_force_personality_change(templehof_faction_str);
		capture_eschen_mission:start();
	end
);










---------------------------------------------------------------
--
--	Capture Eschen mission
--
---------------------------------------------------------------



capture_eschen_mission = first_capture_settlement_mission:new(
	-- Eschen is vulnerable to attack, my Lord. Seize it from the enemy to open passage to the north.
	"war.camp.prelude.vmp.capture_settlement.001",				-- start advice
	"war_prelude_capture_eschen_vampire_counts_1",				-- mission key
	eschen_region_str,											-- region key
	local_faction,												-- player faction
	templehof_faction_str,										-- enemy faction
	ca_starting_area,											-- player starting area
	function()													-- end callback
		out("First capture settlement mission completed - randomising enemy personality");
		cm:cai_force_personality_change(templehof_faction_str);
		hel_fenn_mission:start();
	end
);





---------------------------------------------------------------
--
--	hel fenn mission
--
---------------------------------------------------------------


hel_fenn_mission = first_quest_battle_mission:new(
	-- Reports are reaching us of an expeditionary force of humans close to your territory, my lord. Such a threat cannot be tolerated. Show them that you are master of these lands now!
	"war.camp.prelude.vmp.first_quest_battle.001",								-- start advice
	"wh_main_qb_vmp_mannfred_von_carstein_intro_battle_of_hel_fenn",			-- mission key
	local_faction,																-- player faction key
	457.0,																		-- display x of qb location
	355.0,																		-- display y of qb location
	nil																			-- end callback
);









---------------------------------------------------------------
--
--	Chapter Missions
--
---------------------------------------------------------------

if not cm:is_multiplayer() then
	chapter_one_mission = chapter_mission:new(
		1, 
		local_faction, 
		"wh_main_objective_vampire_01", 
		"war.camp.prelude.vmp.chapter_one.001", 
		{
			"war.camp.advice.victory_conditions.info_001",
			"war.camp.advice.victory_conditions.info_002",
			"war.camp.advice.victory_conditions.info_003"
		}
	);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_main_objective_vampire_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_main_objective_vampire_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_main_objective_vampire_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_main_objective_vampire_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh_main_objective_vampire_06", "war.camp.advice.chapter_six.001");
	
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







