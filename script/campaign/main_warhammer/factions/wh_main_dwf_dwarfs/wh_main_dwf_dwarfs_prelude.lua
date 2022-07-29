
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

prelude_public_order_region = karaz_a_karak_region_str;
prelude_public_order_advice_key = "war.camp.prelude.dwf.public_order.001";
prelude_public_order_province = "wh_main_the_silver_road";
prelude_public_order_mission_key = "war_prelude_solve_public_order_dwarfs_1";

chaos_rises_start_pos = {472.5, 277.6, 10, 0.0, 10};
chaos_rises_scene = "script/campaign/main_warhammer/chaos_rises/scenes/dwarf_chaos_rises.CindyScene";


function start_dwarfs_prelude(advice_already_played)
	
	-- trigger this before starting interventions to ensure that the attack enemy mission happens first
	if not disable_wh1_intro_missions then
		attack_enemy_mission:start(advice_already_played);
	end;
	
	-- start intervention managers
	start_dwarf_interventions();
	
	-- set Bloody Spearz personality
	cm:force_change_cai_faction_personality(bloody_spearz_faction_str, "wh_script_foolishly_brave");
end;








---------------------------------------------------------------
--
--	Initial attack enemy mission
--
---------------------------------------------------------------

ca_starting_area = convex_area:new({
	v(468.0, 261.0),		-- display co-ords
	v(462.0, 276.0),
	v(488.0, 283.0),
	v(493.0, 263.0)
});

attack_enemy_mission = first_attack_enemy_mission:new(
	-- More Greenskins muster in the mountain pass to the east. Attack now, while they remain vulnerable.
	"war.camp.prelude.dwf.attacking_enemy.001",						-- start advice
	"war_prelude_attack_enemy_dwarfs_1",							-- mission key
	local_faction, 													-- player faction key
	bloody_spearz_faction_str,										-- enemy faction key
	get_first_enemy_army_cqi(), 									-- enemy cqi
	ca_starting_area, 												-- convex starting area
	function()														-- end callback
		out("First attack enemy mission completed");
		cm:cai_force_personality_change(bloody_spearz_faction_str);
		capture_pillars_of_grungni_mission:start();
	end
);








---------------------------------------------------------------
--
--	Capture Pillars of Grungni mission
--
---------------------------------------------------------------


capture_pillars_of_grungni_mission = first_capture_settlement_mission:new(
	-- The enemy maintain one of their slum camps beneath the Pillars of Grungni. Move against it, my Lord. The pillars must be returned into Dwarfen hands.
	"war.camp.prelude.dwf.capture_settlement.001",				-- start advice
	"war_prelude_capture_pillars_of_grungni_dwarfs_1",			-- mission key
	pillars_of_grungni_region_str,								-- region key
	local_faction,												-- player faction
	bloody_spearz_faction_str,									-- enemy faction
	ca_starting_area,											-- player starting area
	function()													-- end callback
		out("First capture settlement mission completed - randomising enemy personality");
		cm:cai_force_personality_change(bloody_spearz_faction_str);
		thundering_falls_mission:start();
	end
);





---------------------------------------------------------------
--
--	thundering falls mission
--
---------------------------------------------------------------


thundering_falls_mission = first_quest_battle_mission:new(
	-- Reports are reaching us of an expeditionary force of humans close to your territory, my lord. Such a threat cannot be tolerated. Show them that you are master of these lands now!
	"war.camp.prelude.dwf.first_quest_battle.001",								-- start advice
	"wh_main_qb_dwf_thorgrim_grudgebearer_intro_subterranean",					-- mission key
	local_faction,																-- player faction key
	515.0,																		-- display x of qb location
	284.0,																		-- display y of qb location
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
		"wh_main_objective_dwarf_01", 
		"war.camp.prelude.dwf.chapter_one.001", 
		{
			"war.camp.advice.victory_conditions.info_001",
			"war.camp.advice.victory_conditions.info_002",
			"war.camp.advice.victory_conditions.info_003"
		}
	);
	chapter_two_mission = chapter_mission:new(2, local_faction, "wh_main_objective_dwarf_02", "war.camp.advice.chapter_two.001");
	chapter_three_mission = chapter_mission:new(3, local_faction, "wh_main_objective_dwarf_03", "war.camp.advice.chapter_three.001");
	chapter_four_mission = chapter_mission:new(4, local_faction, "wh_main_objective_dwarf_04", "war.camp.advice.chapter_four.001");
	chapter_five_mission = chapter_mission:new(5, local_faction, "wh_main_objective_dwarf_05", "war.camp.advice.chapter_five.001");
	chapter_six_mission = chapter_mission:new(6, local_faction, "wh_main_objective_dwarf_06", "war.camp.advice.chapter_six.001");

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

