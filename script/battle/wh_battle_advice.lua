

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	ADVICE SCRIPTS
--	Battle advice trigger declarations go here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------



bm:out("********************************************************************");
bm:out("*** loading advice scripts");
bm:out("********************************************************************");
bm:out("");
bm:out("Player alliance number: " .. tostring(bm:get_player_alliance_num()));
do
	local battle_type = core:svr_load_string("battle_type");
	if battle_type == "" then
		bm:out("Battle type: <unable to determine battle type>")
	else
		bm:out("Battle type: " .. tostring(battle_type));
	end;
end;
bm:out("Primary attacker faction is [" .. tostring(core:svr_load_string("primary_attacker_faction_name")) .. "], subculture is [" .. tostring(core:svr_load_string("primary_attacker_subculture")) .. "], is player: " .. tostring(core:svr_load_bool("primary_attacker_is_player")));
bm:out("Primary defender faction is [" .. tostring(core:svr_load_string("primary_defender_faction_name")) .. "], subculture is [" .. tostring(core:svr_load_string("primary_defender_subculture")) .. "], is player: " .. tostring(core:svr_load_bool("primary_defender_is_player")));
bm:out("");

-- create an advice manager
am = advice_manager:new(true);








--
--	standard deployment
--

advice_deployment = advice_monitor:new(
	"deployment",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"war.battle.advice.deployment.001",
	{
		"war.battle.advice.deployment.info_001",
		"war.battle.advice.deployment.info_002",
		"war.battle.advice.deployment.info_003",
		"war.battle.advice.deployment.info_004"
	}
);

advice_deployment:add_trigger_condition(
	true, 
	"ScriptEventDeploymentPhaseBegins"
);








--
--	siege attacker deployment
--

advice_siege_attacker_deployment = advice_monitor:new(
	"siege_attacker_deployment",
	60,
	-- The siege weapons are ready, my lord! Deploy them against the enemy so we can see them in action!
	"war.battle.advice.siege_weapons.001",
	{
		"war.battle.advice.siege_battles.info_001",
		"war.battle.advice.siege_battles.info_002",
		"war.battle.advice.siege_battles.info_003",
		"war.battle.advice.siege_battles.info_005"
	}
);

advice_siege_attacker_deployment:add_trigger_condition(
	function()
		return bm:is_siege_battle() and bm:player_is_attacker() and bm:assault_equipment():vehicle_count() > 0
	end, 
	"ScriptEventDeploymentPhaseBegins"
);

advice_siege_attacker_deployment:add_halt_on_advice_monitor_triggering("deployment");

advice_siege_attacker_deployment:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");







--
--	siege attacker start (siege weapons)
--

advice_siege_attacker_start = advice_monitor:new(
	"siege_attacker_start",
	60,
	-- The siege weapons are in position, my lord, and are ready to begin their assault. Begin your advance!
	"war.battle.advice.siege_weapons.002",
	{
		"war.battle.advice.siege_weapons.info_001",
		"war.battle.advice.siege_weapons.info_002",
		"war.battle.advice.siege_weapons.info_003"
	}
);

advice_siege_attacker_start:add_trigger_condition(
	function()
		return bm:is_siege_battle() and bm:player_is_attacker() and bm:assault_equipment():vehicle_count() > 0;
	end,
	"ScriptEventConflictPhaseBegins"
);











--
--	siege attack walls
--

advice_siege_attacker_walls = advice_monitor:new(
	"siege_attacker_walls",
	40,
	-- The defences must fall, my lord. Storm the city! Press your attack!
	"war.battle.prelude.intro.091",
	{
		"war.battle.advice.siege_battles.info_006",
		"war.battle.advice.siege_battles.info_007",
		"war.battle.advice.siege_battles.info_008"
	}
);

advice_siege_attacker_walls:add_start_condition(
	function () return bm:is_siege_battle() and bm:player_is_attacker() end,
	"ScriptEventConflictPhaseBegins"
);


advice_siege_attacker_walls:add_trigger_condition(
	function()
		return bm:get_distance_between_forces() < 350;
	end
);

advice_siege_attacker_walls:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");















--
--	siege defender start
--

advice_siege_defender_start = advice_monitor:new(
	"siege_defender_start",
	60,
	-- The enemy advance towards the city, Commander! Do all you can to stop them breaching the walls.
	"war.battle.advice.siege_defending.001",
	{
		"war.battle.advice.siege_battles.info_001",
		"war.battle.advice.siege_battles.info_002",
		"war.battle.advice.siege_battles.info_004",
		"war.battle.advice.siege_battles.info_005"
	}
);

advice_siege_defender_start:add_trigger_condition(
	function()
		return bm:is_siege_battle() and not bm:player_is_attacker()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_siege_defender_start:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");










--
--	enemy general dead
--

advice_enemy_general_dead = advice_monitor:new(
	"enemy_general_dead",
	60,
	-- The enemy general is slain, my lord, cursing your name with his dying breath! Send his army after him!
	"war.battle.advice.enemy_general.001",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_enemy_general_dead:set_can_interrupt_other_advice(true);

advice_enemy_general_dead:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_general_dead:add_trigger_condition(
	true,
	"ScriptEventEnemyGeneralDies"
);












--
--	enemy general wounded
--

advice_enemy_general_wounded = advice_monitor:new(
	"enemy_general_wounded",
	60,
	-- The enemy general has been wounded in battle, my lord, and can no longer lead his troops. Press home your advantage!
	"war.battle.advice.enemy_general.002",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_enemy_general_wounded:set_can_interrupt_other_advice(true);

advice_enemy_general_wounded:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_general_wounded:add_trigger_condition(
	true,
	"ScriptEventEnemyGeneralWounded"
);











--
--	enemy general routing
--

advice_enemy_general_routing = advice_monitor:new(
	"enemy_general_routing",
	60,
	-- The enemy commander runs from the field, my lord, and a sorry spectacle it is too! His army will surely follow!
	"war.battle.advice.enemy_general.003",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_enemy_general_routing:add_halt_on_advice_monitor_triggering("enemy_general_dead");
advice_enemy_general_routing:add_halt_on_advice_monitor_triggering("enemy_general_wounded");
advice_enemy_general_routing:set_can_interrupt_other_advice(true);

advice_enemy_general_routing:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_general_routing:add_trigger_condition(
	true,
	"ScriptEventMainEnemyGeneralRouts"
);
















--
--	player general dead
--

advice_player_general_dead = advice_monitor:new(
	"player_general_dead",
	60,
	-- Your commander has been killed in action, my lord! Word has already spread amongst your troops; they will surely lose heart.
	"war.battle.advice.general.001",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_player_general_dead:set_can_interrupt_other_advice(true);

advice_player_general_dead:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_player_general_dead:add_trigger_condition(
	true,
	"ScriptEventPlayerGeneralDies"
);












--
--	player general wounded
--

advice_player_general_wounded = advice_monitor:new(
	"player_general_wounded",
	60,
	-- Your general has been wounded in the fighting and carried from the field, Sire! His loss will be keenly felt by those left fighting.
	"war.battle.advice.general.002",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_player_general_wounded:set_can_interrupt_other_advice(true);

advice_player_general_wounded:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_player_general_wounded:add_trigger_condition(
	true,
	"ScriptEventPlayerGeneralWounded"
);











--
--	player general routing
--

advice_player_general_routing = advice_monitor:new(
	"player_general_routing",
	60,
	-- Your general flees the field, my lord! A shameful display!
	"war.battle.advice.general.003",
	{
		"war.battle.advice.the_general.info_001",
		"war.battle.advice.the_general.info_002",
		"war.battle.advice.the_general.info_003",
		"war.battle.advice.the_general.info_004"
	}
);

advice_player_general_routing:add_halt_on_advice_monitor_triggering("player_general_dead");
advice_player_general_routing:add_halt_on_advice_monitor_triggering("player_general_wounded");
advice_player_general_routing:set_can_interrupt_other_advice(true);

advice_player_general_routing:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_player_general_routing:add_trigger_condition(
	true,
	"ScriptEventPlayerGeneralRouts"
);













--
--	player unit routing
--

advice_player_unit_routing = advice_monitor:new(
	"player_unit_routing",
	40,
	-- Your craven warriors run from the battle, my Lord! Round them up, and send them back!
	"war.battle.advice.routing.002",
	{
		"war.battle.advice.leadership.info_001",
		"war.battle.advice.leadership.info_002",
		"war.battle.advice.leadership.info_003",
		"war.battle.advice.leadership.info_004"
	}
);

advice_player_unit_routing:add_halt_on_advice_monitor_triggering("enemy_unit_routing");
advice_player_unit_routing:set_can_interrupt_other_advice(true);

advice_player_unit_routing:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_player_unit_routing:add_trigger_condition(
	true,
	"ScriptEventPlayerUnitRouts"
);












--
--	player unit rallies
--

advice_player_unit_rallies = advice_monitor:new(
	"player_unit_rallies",
	40,
	-- Your warriors begin to rally, Sire! Steady their nerves, and they will be able to rejoin the fight.
	"war.battle.advice.rallying.001",
	{
		"war.battle.advice.rallying.info_001",
		"war.battle.advice.rallying.info_002",
		"war.battle.advice.rallying.info_003",
		"war.battle.advice.rallying.info_004"
	}
);

advice_player_unit_rallies:set_can_interrupt_other_advice(true);
advice_player_unit_rallies:set_advice_level(2);

advice_player_unit_rallies:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_player_unit_rallies:add_trigger_condition(
	true,
	"ScriptEventPlayerUnitRallies"
);














--
--	enemy unit routing
--

advice_enemy_unit_routing = advice_monitor:new(
	"enemy_unit_routing",
	40,
	-- The enemy waver, my lord, their troops begin to flee! Run the cowards down!
	"war.battle.advice.routing.001",
	{
		"war.battle.advice.leadership.info_001",
		"war.battle.advice.leadership.info_002",
		"war.battle.advice.leadership.info_003",
		"war.battle.advice.leadership.info_004"
	}
);

advice_enemy_unit_routing:add_halt_on_advice_monitor_triggering("player_unit_routing");
advice_enemy_unit_routing:set_can_interrupt_other_advice(true);

advice_enemy_unit_routing:add_start_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_unit_routing:add_trigger_condition(
	true,
	"ScriptEventEnemyUnitRouts"
);











--
--	player_visibility
--

advice_player_visbility = advice_monitor:new(
	"player_visibility",
	30,
	-- You may use the hills, valleys... and stranger formations of this place to your advantage, Commander. The terrain can conceal your forces.
	"war.battle.advice.visibility.002",
	{
		"war.battle.advice.visibility.info_001",
		"war.battle.advice.visibility.info_002",
		"war.battle.advice.visibility.info_003"
	}
);

advice_player_visbility:add_halt_on_advice_monitor_triggering("enemy_visibility");
advice_player_visbility:set_advice_level(2);

advice_player_visbility:add_start_condition(
	function()
		return not bm:is_siege_battle()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_visbility:add_trigger_condition(
	function()
		local player_army = advice_player_visbility.player_army;
		local enemy_alliance = advice_player_visbility.enemy_alliance;
		
		-- cache alliances if we don't have them
		if not player_army then
			player_army = bm:get_player_army();
			advice_player_visbility.player_army = player_army;
			enemy_alliance = bm:get_non_player_alliance();
			advice_player_visbility.enemy_alliance = enemy_alliance;
		end;
		
		local num_invisible_player_units, num_player_units = num_units_passing_test(
			player_army,
			function(unit)
				return not unit:is_visible_to_alliance(enemy_alliance);
			end
		);
		
		if num_player_units == 0 then
			return false;
		end;
		
		-- try and trigger if more than two units and more than 25% of the player's army is invisible
		return num_invisible_player_units > 2 and num_invisible_player_units / num_player_units > 0.25;
	end
);

advice_player_visbility:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");










--
--	enemy_visibility
--

advice_enemy_visbility = advice_monitor:new(
	"enemy_visibility",
	35,
	-- The terrain conceals the enemy's movements, Commander. We must be wary!
	"war.battle.advice.visibility.001",
	{
		"war.battle.advice.visibility.info_001",
		"war.battle.advice.visibility.info_002",
		"war.battle.advice.visibility.info_003"
	}
);

advice_enemy_visbility:add_halt_on_advice_monitor_triggering("player_visibility");

advice_enemy_visbility:add_start_condition(
	function()
		return not bm:is_siege_battle()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_visbility:add_trigger_condition(
	function()
		local player_alliance = advice_enemy_visbility.player_alliance;
		local enemy_army = advice_enemy_visbility.enemy_army;
		
		-- cache alliances if we don't have them
		if not player_alliance then
			player_alliance = bm:get_player_alliance();
			advice_enemy_visbility.player_alliance = player_alliance;
			enemy_army = bm:get_first_non_player_army();
			advice_enemy_visbility.enemy_army = enemy_army;
		end;
		
		local num_invisible_enemy_units, num_enemy_units = num_units_passing_test(
			enemy_army,
			function(unit)
				return not unit:is_visible_to_alliance(player_alliance);
			end
		);
		
		if num_enemy_units == 0 then
			return false;
		end;
		
		-- try and trigger if more than three units and more than 33% of the enemy army is invisible
		return num_invisible_enemy_units > 3 and num_invisible_enemy_units / num_enemy_units > 0.33;
	end
);

advice_enemy_visbility:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");













--
--	enemy_giant
--

advice_enemy_giant = advice_monitor:new(
	"enemy_giant",
	40,
	-- A Giant, Commander! Take it down from afar! Don't let it near your massed infantry!
	"war.battle.advice.giants.001",
	{
		"war.battle.advice.monsters.info_001",
		"war.battle.advice.monsters.info_002",
		"war.battle.advice.monsters.info_003"
	}
);

advice_enemy_giant:add_halt_on_advice_monitor_triggering("player_giant");

advice_enemy_giant:add_start_condition(
	function()
		return not bm:is_siege_battle()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_giant:add_trigger_condition(
	function()		
		local player_alliance = advice_enemy_giant.player_alliance;
		local enemy_giants = advice_enemy_giant.enemy_giants;
		
		if not enemy_giants then
			-- build a list of all giants in the enemy alliance
			enemy_giants = get_all_matching_units(
				bm:get_non_player_alliance(), 
				function(unit)
					return string.find(unit:type(), "mon_giant");
				end
			);
			
			advice_enemy_giant.enemy_giants = enemy_giants;
			
			if #enemy_giants == 0 then
				advice_enemy_giant:halt("enemy has no giants");
				return false;
			end;
			
			player_alliance = bm:get_player_alliance();
			advice_enemy_giant.player_alliance = player_alliance;
		end;
				
		local num_visible_enemy_giants = num_units_passing_test(
			enemy_giants,
			function(unit)
				return unit:is_visible_to_alliance(player_alliance);
			end
		);
		
		return num_visible_enemy_giants > 0;
	end
);

advice_enemy_giant:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");














--
--	player_giant
--

advice_player_giant = advice_monitor:new(
	"player_giant",
	30,
	-- Your Giant terrorises the enemy, great lord! Send it into the main body of the enemy, and watch the carnage unfold!
	"war.battle.advice.giants.002",
	{
		"war.battle.advice.monsters.info_001",
		"war.battle.advice.monsters.info_002",
		"war.battle.advice.monsters.info_003"
	}
);

advice_player_giant:add_halt_on_advice_monitor_triggering("enemy_giant");
advice_player_giant:set_advice_level(2);

advice_player_giant:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
		
		-- build a list of all giants in the player's army
		advice_player_giant.player_giants = get_all_matching_units(
			bm:get_player_army(), 
			function(unit)
				return string.find(unit:type(), "mon_giant");
			end
		);
		
		advice_player_giant.enemy_alliance = bm:get_non_player_alliance();
		
		return true;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_giant:add_trigger_condition(
	function()
		local enemy_alliance = advice_player_giant.enemy_alliance;
		local player_giants = advice_player_giant.player_giants;
						
		-- return true when any giants in the player's army become visible
		local num_visible_player_giants = num_units_passing_test(
			player_giants,
			function(unit)
				return unit:is_visible_to_alliance(enemy_alliance);
			end
		);
		
		return num_visible_player_giants > 0;
	end
);

advice_player_giant:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");














--
--	enemy flying units
--

advice_enemy_flying_units = advice_monitor:new(
	"enemy_flying_units",
	32,
	-- The enemy field flying troops, my lord. Bring them down if they approach your forces.
	"war.battle.advice.flying_units.001",
	{
		"war.battle.advice.flying_units.info_001",
		"war.battle.advice.flying_units.info_002",
		"war.battle.advice.flying_units.info_003"
	}
);

advice_enemy_flying_units:add_halt_on_advice_monitor_triggering("player_flying_units");

advice_enemy_flying_units:add_start_condition(
	function()
		return not bm:is_siege_battle()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_flying_units:add_trigger_condition(
	function()		
		local player_alliance = advice_enemy_flying_units.player_alliance;
		local enemy_flying_units = advice_enemy_flying_units.enemy_flying_units;
		
		if not enemy_flying_units then
			-- build a list of all flying in the enemy alliance
			enemy_flying_units = get_all_matching_units(
				bm:get_non_player_alliance(), 
				function(unit)
					return unit:can_fly()
				end
			);
			
			advice_enemy_flying_units.enemy_flying_units = enemy_flying_units;
			
			if #enemy_flying_units == 0 then
				advice_enemy_flying_units:halt("enemy has no flying units");
				return false;
			end;
			
			player_alliance = bm:get_player_alliance();
			advice_enemy_flying_units.player_alliance = player_alliance;
		end;
				
		local num_visible_enemy_flying_units = num_units_passing_test(
			enemy_flying_units,
			function(unit)
				return unit:is_visible_to_alliance(player_alliance);
			end
		);
		
		return num_visible_enemy_flying_units > 1;
	end
);

advice_enemy_flying_units:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");











--
--	player_flying_units
--

advice_player_flying_units = advice_monitor:new(
	"player_flying_units",
	30,
	-- Your flying units afford you great flexibility, Commander. Scout and harass the enemy as they manoeuvre.
	"war.battle.advice.flying_units.002",
	{
		"war.battle.advice.flying_units.info_001",
		"war.battle.advice.flying_units.info_002",
		"war.battle.advice.flying_units.info_003"
	}
);

advice_player_flying_units:add_halt_on_advice_monitor_triggering("enemy_flying_units");
advice_player_flying_units:set_advice_level(2);

advice_player_flying_units:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
	
		local player_flying_units = num_units_passing_test(
			bm:get_player_army(), 
			function(unit)
				return unit:can_fly()
			end
		);
				
		return player_flying_units > 0;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_flying_units:add_trigger_condition(
	function()
		return true;
	end
);

advice_player_flying_units:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");











--
--	enemy artillery
--

advice_enemy_artillery = advice_monitor:new(
	"enemy_artillery",
	42,
	-- The enemy bring mighty weapons of war to the battle! Have them destroyed, Commander, or they will decimate your troops from afar.
	"war.battle.advice.artillery.001",
	{
		"war.battle.advice.artillery.info_001",
		"war.battle.advice.artillery.info_002",
		"war.battle.advice.artillery.info_003"
	}
);

advice_enemy_artillery:add_halt_on_advice_monitor_triggering("player_artillery");

advice_enemy_artillery:add_start_condition(
	function()
		return not bm:is_siege_battle() and not bool_is_intro_battle;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_artillery:add_trigger_condition(
	function()		
		local player_alliance = advice_enemy_artillery.player_alliance;
		local enemy_artillery = advice_enemy_artillery.enemy_artillery;
		
		if not enemy_artillery then		
			-- build a list of all flying in the enemy alliance
			enemy_artillery = get_all_matching_units(
				bm:get_non_player_alliance(), 
				function(unit)
					return unit:unit_class() == "art_fld"
				end
			);
			
			advice_enemy_artillery.enemy_artillery = enemy_artillery;
			
			if #enemy_artillery == 0 then
				advice_enemy_artillery:halt("enemy has no artillery");
				return false;
			end;
			
			player_alliance = bm:get_player_alliance();
			advice_enemy_artillery.player_alliance = player_alliance;
		end;
				
		local num_visible_enemy_artillery = num_units_passing_test(
			enemy_artillery,
			function(unit)
				return unit:is_visible_to_alliance(player_alliance);
			end
		);
		
		return num_visible_enemy_artillery > 0;
	end
);

advice_enemy_artillery:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");












--
--	player_artillery
--

advice_player_artillery = advice_monitor:new(
	"player_artillery",
	34,
	-- Your ranged weapons may prove decisive in the coming battle, Commander. Bring them to bear against the enemy from afar, but be sure to protect them as well.
	"war.battle.advice.artillery.002",
	{
		"war.battle.advice.artillery.info_001",
		"war.battle.advice.artillery.info_002",
		"war.battle.advice.artillery.info_003"
	}
);

advice_player_artillery:add_halt_on_advice_monitor_triggering("enemy_artillery");
advice_player_artillery:set_advice_level(2);

advice_player_artillery:add_start_condition(
	function()	
		local player_artillery = num_units_passing_test(
			bm:get_player_army(), 
			function(unit)
				return unit:unit_class() == "art_fld";
			end
		);
		
		return player_artillery > 0;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_artillery:add_trigger_condition(
	function()
		return true;
	end
);

advice_player_artillery:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");













--
--	enemy_cavalry
--

advice_enemy_cavalry = advice_monitor:new(
	"enemy_cavalry",
	28,
	-- The enemy approach on mounts, Commander! Keep your vulnerable units close at hand.
	"war.battle.advice.cavalry.001",
	{
		"war.battle.advice.mounted_units.info_001",
		"war.battle.advice.mounted_units.info_002",
		"war.battle.advice.mounted_units.info_003"
	}
);

advice_enemy_cavalry:add_halt_on_advice_monitor_triggering("player_cavalry");

advice_enemy_cavalry:add_start_condition(
	function()
		return not bm:is_siege_battle()
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_enemy_cavalry:add_trigger_condition(
	function()		
		local player_alliance = advice_enemy_cavalry.player_alliance;
		local enemy_cavalry = advice_enemy_cavalry.enemy_cavalry;
		
		if not enemy_cavalry then
			-- build a list of all flying in the enemy alliance
			enemy_cavalry = get_all_matching_units(
				bm:get_non_player_alliance(), 
				function(unit)
					return unit:is_cavalry()
				end
			);
			
			advice_enemy_cavalry.enemy_cavalry = enemy_cavalry;
			
			if #enemy_cavalry == 0 then
				advice_enemy_cavalry:halt("enemy has no cavalry");
				return false;
			end;
			
			player_alliance = bm:get_player_alliance();
			advice_enemy_cavalry.player_alliance = player_alliance;
		end;
				
		local num_visible_enemy_cavalry = num_units_passing_test(
			enemy_cavalry,
			function(unit)
				return unit:is_visible_to_alliance(player_alliance) and distance_between_forces(player_alliance, enemy_cavalry) < 300;
			end
		);
		
		return num_visible_enemy_cavalry > 1;
	end
);

advice_enemy_cavalry:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");








--
--	player_cavalry
--

advice_player_cavalry = advice_monitor:new(
	"player_cavalry",
	26,
	-- Be sure to use your mounted soldiers to full effect, Commander. Harass the enemy formation and strike at their weakest points.
	"war.battle.advice.cavalry.002",
	{
		"war.battle.advice.mounted_units.info_001",
		"war.battle.advice.mounted_units.info_002",
		"war.battle.advice.mounted_units.info_003"
	}
);

advice_player_cavalry:add_halt_on_advice_monitor_triggering("enemy_cavalry");
advice_player_cavalry:set_advice_level(2);

advice_player_cavalry:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
		
		local num_player_cavalry, num_player_units = num_units_passing_test(
			bm:get_player_army(), 
			function(unit)
				return unit:is_cavalry()
			end
		);
		
		if num_player_units == 0 then
			return false;
		end;
		
		-- trigger if more than 10% of the player's army is cavalry
		return num_player_cavalry / num_player_units > 0.1;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_cavalry:add_trigger_condition(
	function()
		return true;
	end
);

advice_player_cavalry:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");















--
--	player_fatigue_during_battle
--

advice_player_fatigue_during_battle = advice_monitor:new(
	"player_fatigue_during_battle",
	32,
	-- Your warriors tire, mighty lord, their exertions dull their ability to fight. Give them time to rest, even amidst the thickest of battles.
	"war.battle.advice.fatigue.002",
	{
		"war.battle.advice.vigour.info_001",
		"war.battle.advice.vigour.info_002",
		"war.battle.advice.vigour.info_003"
	}
);

advice_player_fatigue_during_battle:add_halt_on_advice_monitor_triggering("player_fatigue_battle_start");

advice_player_fatigue_during_battle:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_player_fatigue_during_battle:add_trigger_condition(
	function()		
		local player_units = advice_player_fatigue_during_battle.player_units;
		
		if not player_units then
			-- cache the player's army
			player_units = bm:get_player_army():units();
			advice_player_fatigue_during_battle.player_units = player_units;
		end;
		
		local num_fatigued_units, total_units = num_units_passing_test(
			player_units,
			function(unit)
				local fatigue_state = unit:fatigue_state();
				return fatigue_state == "threshold_tired" or fatigue_state == "threshold_very_tired" or fatigue_state == "threshold_exhausted";
			end
		);
		
		if total_units == 0 then
			return false;
		end;
		
		return num_fatigued_units / total_units > 0.25;
	end
);














--
--	player_fatigue_battle_start
--

advice_player_fatigue_battle_start = advice_monitor:new(
	"player_fatigue_battle_start",
	55,
	-- Your army has marched long and hard, Commander. The troops have little strength left to fight - use it wisely!
	"war.battle.advice.fatigue.001",
	{
		"war.battle.advice.vigour.info_001",
		"war.battle.advice.vigour.info_002",
		"war.battle.advice.vigour.info_003"
	}
);

advice_player_fatigue_battle_start:add_trigger_condition(
	function()
		local player_units = bm:get_player_army():units();		
		local num_fatigued_units, total_units = num_units_passing_test(
			player_units,
			function(unit)
				local fatigue_state = unit:fatigue_state();
				return fatigue_state == "threshold_tired" or fatigue_state == "threshold_very_tired" or fatigue_state == "threshold_exhausted";
			end
		);
		
		if total_units == 0 then
			return false;
		end;
		
		return num_fatigued_units / total_units > 0.5;
	end,
	"ScriptEventConflictPhaseBegins" 
);















--
--	tactical_maps
--

advice_tactical_maps = advice_monitor:new(
	"tactical_maps",
	5,
	-- Be sure to use the maps available to assist your tactical planning, Commander.
	"war.battle.advice.maps.001",
	{
		"war.battle.advice.tactical_map.info_001",
		"war.battle.advice.tactical_map.info_002",
		"war.battle.advice.tactical_map.info_003"
	}
);

-- advice_tactical_maps:set_delay_before_triggering(5000);
advice_tactical_maps:set_advice_level(2);

advice_tactical_maps:add_start_condition(
	function()
		-- only trigger if this is not a siege battle and if the player difficulty is > legendary (where the tactical map isn't available)
		return not bm:is_siege_battle() and bm:get_player_army():army_handicap() >= -2;
	end,
	"ScriptEventConflictPhaseBegins"
);

advice_tactical_maps:add_trigger_condition(
	function()
		return bm:get_distance_between_forces() > 350;
	end
);

advice_tactical_maps:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");











--
--	formations
--

advice_formations = advice_monitor:new(
	"formations",
	0,
	-- Group your units for best effect, Commander. Formations may be useful when manoeuvring before the enemy.
	"war.battle.advice.formations.001",
	{
		"war.battle.advice.formations.info_001",
		"war.battle.advice.formations.info_002",
		"war.battle.advice.formations.info_003",
		"war.battle.advice.formations.info_004"
	}
);

advice_formations:set_delay_before_triggering(5000);
advice_formations:set_advice_level(2);

advice_formations:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
	
		-- only continue if the player has more than ten units
		local army = bm:get_player_army();
		return army:units():count() > 10;
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_formations:add_trigger_condition(
	function()
		return bm:get_distance_between_forces() < 400;
	end
);

advice_formations:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");











--
--	fire_at_will
--

advice_fire_at_will = advice_monitor:new(
	"fire_at_will",
	10,
	-- Your troops will fire-at-will without orders to the contrary, Commander. Have them conserve their ammunition if you so wish.
	"war.battle.advice.fire_at_will.001",
	{
		"war.battle.advice.fire_at_will.info_001",
		"war.battle.advice.fire_at_will.info_002",
		"war.battle.advice.fire_at_will.info_003",
		"war.battle.advice.fire_at_will.info_004"
	}
);

advice_fire_at_will:set_advice_level(2);

advice_fire_at_will:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
	
		-- only start if the player has more than two units with ammo
		local player_army = bm:get_player_army();
		
		local num_units_with_ammo = num_units_passing_test(
			player_army,
			function(unit)
				return unit:starting_ammo() > 5
			end
		);
				
		return num_units_with_ammo > 1;
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_fire_at_will:add_trigger_condition(
	function()
		return bm:get_distance_between_forces() < 400;
	end
);

advice_fire_at_will:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");















--
--	attacking_capture_points
--

advice_player_attacking_capture_points = advice_monitor:new(
	"player_attacking_capture_points",
	20,
	-- Send troops to capture the enemy defences, Commander. They can be turned to our service.
	"war.battle.advice.capture_points.002",
	{
		"war.battle.advice.capture_points.info_001",
		"war.battle.advice.capture_points.info_002",
		"war.battle.advice.capture_points.info_003"
	}
);

advice_player_attacking_capture_points:add_start_condition(
	function()				
		return bm:is_siege_battle() and bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_player_attacking_capture_points:add_trigger_condition(true, "ScriptEventBattleArmiesEngaging");
















--
--	receiving_missile_fire
--

advice_receiving_missile_fire = advice_monitor:new(
	"receiving_missile_fire",
	20,
	-- Your troops come under fire, Commander! Have them find cover, or eliminate the source!
	"war.battle.advice.missile_fire.001",
	{
		"war.battle.advice.missile_units.info_001",
		"war.battle.advice.missile_units.info_002",
		"war.battle.advice.missile_units.info_003"
	}
);

advice_receiving_missile_fire:set_delay_before_triggering(5000);

advice_receiving_missile_fire:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_receiving_missile_fire:add_trigger_condition(
	function()
		-- trigger if the player has two or more units under fire
		return bm:get_num_units_under_fire() > 1;
	end
);

advice_receiving_missile_fire:add_halt_condition(function() return bm:get_proportion_engaged() > 0.25 end);

















--
--	player receives reinforcements
--

advice_player_reinforcements = advice_monitor:new(
	"player_reinforcements",
	30,
	-- Allied reinforcements are arriving in support, Commander! Link up with them and surround the enemy.
	"war.battle.advice.reinforcements.001",
	{
		"war.battle.advice.reinforcements.info_001",
		"war.battle.advice.reinforcements.info_002",
		"war.battle.advice.reinforcements.info_003"
	}
);


advice_player_reinforcements:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_player_reinforcements:add_trigger_condition(
	function(context)
		return context.string == "adc_own_reinforcements"
	end,
	"BattleAideDeCampEvent"
);













--
--	enemy receives reinforcements
--

advice_enemy_reinforcements = advice_monitor:new(
	"enemy_reinforcements",
	32,
	-- Enemy reinforcements are approaching! Attack with caution, Commander.
	"war.battle.advice.reinforcements.002",
	{
		"war.battle.advice.reinforcements.info_001",
		"war.battle.advice.reinforcements.info_002",
		"war.battle.advice.reinforcements.info_003"
	}
);


advice_enemy_reinforcements:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_enemy_reinforcements:add_trigger_condition(
	function(context)
		return context.string == "adc_enemy_reinforcements"
	end,
	"BattleAideDeCampEvent"
);



























--
--	enemy capture victory point
--

advice_enemy_capture_victory_point = advice_monitor:new(
	"enemy_capture_victory_point",
	32,
	-- The enemy capture the city centre, Commander! Retake it quickly, before the city falls!
	"war.battle.advice.victory_points.001",
	{
		"war.battle.advice.victory_points.info_005",
		"war.battle.advice.victory_points.info_006",
		"war.battle.advice.victory_points.info_009",
		"war.battle.advice.victory_points.info_010",
		"war.battle.advice.victory_points.info_011"
	}
);

advice_enemy_capture_victory_point:set_can_interrupt_other_advice(true);


advice_enemy_capture_victory_point:add_start_condition(
	function()
		return bm:is_siege_battle() and not bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_enemy_capture_victory_point:add_trigger_condition(
	function(context)
		return context.string == "adc_own_fort_about_to_be_captured"
	end,
	"BattleAideDeCampEvent"
);















--
--	enemy capturing victory point
--

advice_enemy_capturing_victory_point = advice_monitor:new(
	"enemy_capturing_victory_point",
	50,
	-- The city is falling to the enemy, Commander! Intercept them before it is taken!
	"war.battle.advice.victory_points.002",
	{
		"war.battle.advice.victory_points.info_005",
		"war.battle.advice.victory_points.info_006",
		"war.battle.advice.victory_points.info_009",
		"war.battle.advice.victory_points.info_010",
		"war.battle.advice.victory_points.info_011"
	}
);

advice_enemy_capturing_victory_point:set_can_interrupt_other_advice(true);


advice_enemy_capturing_victory_point:add_start_condition(
	function()
		return bm:is_siege_battle() and not bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_enemy_capturing_victory_point:add_trigger_condition(
	function(context)
		return context.string == "adc_enemy_capturing_victory_point"
	end,
	"BattleAideDeCampEvent"
);


















--
--	enemy capturing gates
--

advice_enemy_capturing_gates = advice_monitor:new(
	"enemy_capturing_gates",
	20,
	-- The enemy are taking the walls, Commander! Drive them back!
	"war.battle.advice.capture_points.001",
	{
		"war.battle.advice.capture_points.info_001",
		"war.battle.advice.capture_points.info_002",
		"war.battle.advice.capture_points.info_003"
	}
);


advice_enemy_capturing_gates:add_start_condition(
	function()
		return bm:is_siege_battle() and not bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_enemy_capturing_gates:add_trigger_condition(
	function(context)
		return context.string == "adc_enemy_capturing_gates"
	end,
	"BattleAideDeCampEvent"
);


advice_enemy_capturing_gates:add_trigger_condition(
	function(context)
		return context.string == "adc_own_tower_captured"
	end,
	"BattleAideDeCampEvent"
);



















--
--	player captures victory point
--

advice_player_captures_victory_point = advice_monitor:new(
	"player_captures_victory_point",
	30,
	-- The centre is yours! Defend it against the enemy that remain, my lord. The city will surely fall soon.
	"war.battle.advice.victory_points.004",
	{
		"war.battle.advice.victory_points.info_005",
		"war.battle.advice.victory_points.info_006",
		"war.battle.advice.victory_points.info_009",
		"war.battle.advice.victory_points.info_010",
		"war.battle.advice.victory_points.info_011"
	}
);

advice_player_captures_victory_point:set_can_interrupt_other_advice(true);


advice_player_captures_victory_point:add_start_condition(
	function()
		return bm:is_siege_battle() and bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_player_captures_victory_point:add_trigger_condition(
	function(context)
		return context.string == "adc_enemy_point_captured"
	end,
	"BattleAideDeCampEvent"
);


















--
--	player approaches victory point
--

advice_player_approaches_victory_point = advice_monitor:new(
	"player_approaches_victory_point",
	20,
	-- The heart of the city is within sight, my lord! Press forward!
	"war.battle.advice.victory_points.003",
	{
		"war.battle.advice.victory_points.info_005",
		"war.battle.advice.victory_points.info_006",
		"war.battle.advice.victory_points.info_007",
		"war.battle.advice.victory_points.info_008"
	}
);

advice_player_approaches_victory_point:add_start_condition(
	function()
		return bm:is_siege_battle() and bm:player_is_attacker();
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_player_approaches_victory_point:add_trigger_condition(
	true,
	"ScriptEventPlayerApproachingVictoryPoint"
);















--
--	player has high ground
--

advice_player_has_high_ground = advice_monitor:new(
	"player_has_high_ground",
	10,
	-- The high ground is yours, Commander. Be sure to use it to best advantage.
	"war.battle.advice.high_ground.001",
	{
		"war.battle.advice.terrain.info_001",
		"war.battle.advice.terrain.info_002",
		"war.battle.advice.terrain.info_005",
		"war.battle.advice.terrain.info_004"
	}
);

advice_player_has_high_ground:add_halt_on_advice_monitor_triggering("enemy_has_high_ground");
advice_player_has_high_ground:set_advice_level(2);

advice_player_has_high_ground:add_start_condition(
	function()
		return not bm:is_siege_battle() and bm:get_player_alliance():armies():count() == 1 and bm:get_non_player_alliance():armies():count() == 1;
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_player_has_high_ground:add_trigger_condition(
	function()
		-- return true if the player <> enemy height difference is more than 10% of the distance between them
		return (bm:get_player_army_altitude() - bm:get_enemy_army_altitude()) * 10 > bm:get_distance_between_forces();
	end
);

advice_player_has_high_ground:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");








--
--	enemy has high ground
--

advice_enemy_has_high_ground = advice_monitor:new(
	"enemy_has_high_ground",
	15,
	-- The enemy command the high ground. Attack with caution, my Lord.
	"war.battle.advice.high_ground.002",
	{
		"war.battle.advice.terrain.info_001",
		"war.battle.advice.terrain.info_002",
		"war.battle.advice.terrain.info_005",
		"war.battle.advice.terrain.info_004"
	}
);

advice_enemy_has_high_ground:add_halt_on_advice_monitor_triggering("player_has_high_ground");

advice_enemy_has_high_ground:add_start_condition(
	function()
		return not bm:is_siege_battle() and bm:get_player_alliance():armies():count() == 1 and bm:get_non_player_alliance():armies():count() == 1;
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_enemy_has_high_ground:add_trigger_condition(
	function()
		-- return true if the enemy <> player height difference is more than 10% of the distance between them
		local enemy_altitude = bm:get_enemy_army_altitude();
		local player_altitude = bm:get_player_army_altitude();
		local distance_between_forces = bm:get_distance_between_forces();
		
		return (bm:get_enemy_army_altitude() - bm:get_player_army_altitude()) * 10 > bm:get_distance_between_forces();
	end
);

advice_enemy_has_high_ground:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");





















--
--	player_being_flanked
--

advice_player_being_flanked = advice_monitor:new(
	"player_being_flanked",
	20,
	-- The enemy attack your flank, Commander! Drive them off!
	"war.battle.advice.flanking.001",
	{
		"war.battle.advice.flanking.info_001",
		"war.battle.advice.flanking.info_002",
		"war.battle.advice.flanking.info_003"
	}
);

advice_player_being_flanked:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_player_being_flanked:add_trigger_condition(
	function()
		local player_army = advice_enemy_has_high_ground.player_army;
		
		-- cache player army if we don't have it
		if not player_army then
			player_army = bm:get_player_army();
			advice_enemy_has_high_ground.player_army = player_army;
		end;
		
		local num_player_units_flanked, num_player_units = num_units_passing_test(
			player_army,
			function(unit)
				return unit:is_left_flank_threatened() or unit:is_right_flank_threatened() or unit:is_rear_flank_threatened();
			end
		);
		
		-- try and trigger if more than one unit is being flanked
		return num_player_units_flanked > 2;
	end
);



















--
--	player_units_hidden
--

advice_player_units_hidden = advice_monitor:new(
	"player_units_hidden",
	20,
	-- The trees may be used to conceal your movements, Commander. Close with the enemy under cover of forest to retain the element of surprise.
	"war.battle.advice.forests.001",
	{
		"war.battle.advice.terrain.info_001",
		"war.battle.advice.terrain.info_002",
		"war.battle.advice.terrain.info_003",
		"war.battle.advice.terrain.info_004"
	}
);

advice_player_units_hidden:add_halt_on_advice_monitor_triggering("enemy_units_hidden");
advice_player_units_hidden:set_advice_level(2);

advice_player_units_hidden:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_player_units_hidden:add_trigger_condition(
	function()
		local player_army = advice_player_units_hidden.player_army;
		
		-- cache player army if we don't have it
		if not player_army then
			player_army = bm:get_player_army();
			advice_player_units_hidden.player_army = player_army;
		end;
		
		local num_player_units_hidden, num_player_units = num_units_passing_test(
			player_army,
			function(unit)
				return unit:is_hidden();
			end
		);
		
		-- try and trigger if more than one unit is being flanked
		return num_player_units_hidden > 1;
	end
);

advice_player_units_hidden:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");
















--
--	enemy_units_hidden
--

advice_enemy_units_hidden = advice_monitor:new(
	"enemy_units_hidden",
	24,
	-- The enemy use the forests to conceal their movements, my Lord! Approach with caution.
	"war.battle.advice.forests.002",
	{
		"war.battle.advice.terrain.info_001",
		"war.battle.advice.terrain.info_002",
		"war.battle.advice.terrain.info_003",
		"war.battle.advice.terrain.info_004"
	}
);

advice_enemy_units_hidden:add_halt_on_advice_monitor_triggering("player_units_hidden");

advice_enemy_units_hidden:add_start_condition(
	function()
		return not bm:is_siege_battle();
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_enemy_units_hidden:add_trigger_condition(
	function(context)
		return context.string == "adc_enemy_hidden_unit_spotted"
	end,
	"BattleAideDeCampEvent"
);

advice_enemy_units_hidden:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");

























--
--	winds_of_magic_blowing
--

advice_winds_of_magic_blowing = advice_monitor:new(
	"winds_of_magic_blowing",
	24,
	-- The Winds of Magic blow strongly in this place, Commander. Harness its power and channel it against your enemy.
	"war.battle.advice.winds_of_magic.001",
	{
		"war.battle.advice.winds_of_magic.info_001",
		"war.battle.advice.winds_of_magic.info_002",
		"war.battle.advice.winds_of_magic.info_003"
	}
);

-- advice_winds_of_magic_blowing:add_halt_on_advice_monitor_triggering("enemy_uses_magic");

advice_winds_of_magic_blowing:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
	
		local player_units = bm:get_player_army():units();
		
		for i = 1, player_units:count() do
			if player_units:item(i):can_use_magic() then
				return true;
			end;
		end;
		
		return false;
	end,
	"ScriptEventConflictPhaseBegins" 
);

advice_winds_of_magic_blowing:add_trigger_condition(
	function(context)
		local player_army = advice_winds_of_magic_blowing.player_army;
		
		-- cache player army if we don't have it
		if not player_army then
			player_army = bm:get_player_army();
			advice_winds_of_magic_blowing.player_army = player_army;
		end;
		
		local recharge_rate = player_army:wind_of_magic_remaining_recharge_rate();
		
		bm:out("advice_winds_of_magic_blowing :: recharge_rate is " .. tostring(recharge_rate));
			
		return player_army:wind_of_magic_remaining_recharge_rate() > 0.5;
	end
);

advice_winds_of_magic_blowing:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");


















--
--	magic_overcasting
--

advice_magic_overcasting = advice_monitor:new(
	"magic_overcasting",
	10,
	-- Spells may be overcast to increase their potency, my Lord. Yet I advise caution: channelling so much raw magic at once brings the risk of disaster.
	"war.battle.advice.spells.001",
	{
		"war.battle.advice.spells.info_001",
		"war.battle.advice.spells.info_002",
		"war.battle.advice.spells.info_003",
		"war.battle.advice.spells.info_004"
	}
);


advice_magic_overcasting:add_start_condition(
	function()
		if bm:is_siege_battle() then
			return false;
		end;
	
		local player_units = bm:get_player_army():units();
		
		for i = 1, player_units:count() do
			if player_units:item(i):can_use_magic() then
				return true;
			end;
		end;
		
		return false;
	end,
	"ScriptEventConflictPhaseBegins" 
);


advice_magic_overcasting:add_trigger_condition(
	function()
		return bm:get_distance_between_forces() < 350;
	end
);

advice_magic_overcasting:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");





















--
--	army_abilities
--

advice_army_abilities = advice_monitor:new(
	"army_abilities",
	25,
	-- You army marches into battle with great powers, my Lord. Be sure to make use of them.
	"wh2.battle.advice.army_abilities.001",
	{
		"wh2.battle.advice.army_abilities.info_001",
		"wh2.battle.advice.army_abilities.info_002",
		"wh2.battle.advice.army_abilities.info_003"
	}
);


advice_army_abilities:add_trigger_condition(
	function()
		-- trigger if the army abilities panel is visible
		local uic_army_abilities = find_uicomponent(core:get_ui_root(), "army_ability_parent");
		return uic_army_abilities and uic_army_abilities:Visible(true);
	end,
	"ScriptEventConflictPhaseBegins"
);



--
--	wardens_cage
--

advice_wardens_cage = advice_monitor:new(
	"wardens_cage",
	0,
	-- Your cage enables you to temporarily trap a foe in the midst of battle, Warden, holding them still and rendering them vulnerable. Should they be wounded while encaged, they will be taken prisoner and held captive in Athel Tamarha after the battle.
	"wh2_dlc15.battle.advice.hef.prisoners.001",
	nil
);


advice_wardens_cage:add_trigger_condition(
	function()	
		-- return true if the player is Yvresse
		return (core:svr_load_bool("primary_defender_is_player") and core:svr_load_string("primary_defender_faction_name") == "wh2_main_hef_yvresse") or 
			(core:svr_load_bool("primary_attacker_is_player") and core:svr_load_string("primary_attacker_faction_name") == "wh2_main_hef_yvresse")
	end,
	"ScriptEventConflictPhaseBegins"
);



--
--	unit_positioning
--

advice_unit_positioning = advice_monitor:new(
	"unit_positioning",
	90,
	-- Be sure to position your troops accurately in battle, my Lord. Drag out your formations for best effect.
	"wh2.battle.advice.positioning.001",
	{
		"wh2.battle.intro.info_050",
		"wh2.battle.intro.info_051",
		"wh2.battle.intro.info_052",
		"wh2.battle.intro.info_053"
	}
);


advice_unit_positioning:set_delay_before_triggering(5000);
advice_unit_positioning:set_advice_level(1);

advice_unit_positioning:add_trigger_condition(
	true,
	"ScriptEventConflictPhaseBegins"
);

advice_unit_positioning:add_halt_condition(true, "ScriptEventBattleArmiesEngaging");




















--
--	murderous_prowess
--

advice_murderous_prowess = advice_monitor:new(
	"murderous_prowess",
	50,
	-- Divine blessings may be earned by your kind through the act of killing, cunning Lord. Lead your fellow Druchii to slaughter in battle and they will gain great favour from Khaine, Lord of Murder.
	"wh2.battle.advice.murderous_prowess.001",
	{
		"wh2.battle.advice.murderous_prowess.info_001",
		"wh2.battle.advice.murderous_prowess.info_002",
		"wh2.battle.advice.murderous_prowess.info_003"
	}
);


advice_murderous_prowess:set_delay_before_triggering(5000);
advice_murderous_prowess:set_advice_level(1);

advice_murderous_prowess:add_trigger_condition(
	function()	
		-- return true if the player is dark elves
		return (core:svr_load_bool("primary_defender_is_player") and core:svr_load_string("primary_defender_subculture") == "wh2_main_sc_def_dark_elves") or 
			(core:svr_load_bool("primary_attacker_is_player") and core:svr_load_string("primary_attacker_subculture") == "wh2_main_sc_def_dark_elves")
	end,
	"ScriptEventConflictPhaseBegins"
);
















--
--	rampaging
--

advice_rampaging = advice_monitor:new(
	"rampaging",
	55,
	-- Your warriors rampage, mighty Lord! They no longer respond to orders!
	"wh2.battle.advice.rampaging.001",
	{
		"wh2.battle.advice.rampaging.info_001",
		"wh2.battle.advice.rampaging.info_002",
		"wh2.battle.advice.rampaging.info_003"
	}
);


advice_rampaging:set_advice_level(1);
advice_rampaging:set_can_interrupt_other_advice(true);

advice_rampaging:add_start_condition(
	function()	
		-- return true if the player is lizardmen
		return (core:svr_load_bool("primary_defender_is_player") and core:svr_load_string("primary_defender_subculture") == "wh2_main_sc_lzd_lizardmen") or 
			(core:svr_load_bool("primary_attacker_is_player") and core:svr_load_string("primary_attacker_subculture") == "wh2_main_sc_lzd_lizardmen")
	end,
	"ScriptEventConflictPhaseBegins"
);


advice_rampaging:add_trigger_condition(
	function()	
		-- trigger if any of the player's units are rampaging
		local player_units = bm:get_player_army():units();
		
		for i = 1, player_units:count() do
			if player_units:item(i):is_rampaging() then
				return true;
			end;
		end;
	end
);







--
--	realm_of_souls
--

advice_realm_of_souls = advice_monitor:new(
	"realm_of_souls",
	50,
	-- Your warriors may perish, yet their spirits are eternally bound to your service. From the Realm of Souls, the power of those that have fallen in battle continue to assist those that remain.
	"dlc09.battle.advice.realm_of_souls.001",
	{
		"dlc09.battle.advice.realm_of_souls.info_001",
		"dlc09.battle.advice.realm_of_souls.info_002",
		"dlc09.battle.advice.realm_of_souls.info_003"
	}
);


advice_realm_of_souls:set_delay_before_triggering(2000);
advice_realm_of_souls:set_advice_level(1);

advice_realm_of_souls:add_start_condition(
	function()	
		-- return true if the player is tomb kings
		return (core:svr_load_bool("primary_defender_is_player") and core:svr_load_string("primary_defender_subculture") == "wh2_dlc09_sc_tmb_tomb_kings") or 
			(core:svr_load_bool("primary_attacker_is_player") and core:svr_load_string("primary_attacker_subculture") == "wh2_dlc09_sc_tmb_tomb_kings")
	end,
	"ScriptEventConflictPhaseBegins"
);


advice_realm_of_souls:add_trigger_condition(
	function()	
		-- trigger if any of the player's units have taken casualties
		local player_units = bm:get_player_army():units();
		
		for i = 1, player_units:count() do
			local number_men_alive, initial_number_of_men = number_alive(player_units:item(i));
			
			if number_men_alive < initial_number_of_men then
				return true;
			end;
		end;
	end
);













--
--	vampire coast extra powder
--

advice_vampire_coast_extra_powder = advice_monitor:new(
	"vampire_coast_extra_powder",
	60,
	"wh2_dlc11.battle.advice.cst.extra_powder.001" --[[,
	{
		"war.battle.advice.siege_battles.info_001",
		"war.battle.advice.siege_battles.info_002",
		"war.battle.advice.siege_battles.info_004",
		"war.battle.advice.siege_battles.info_005"
	}]]
);

advice_vampire_coast_extra_powder:set_delay_before_triggering(2000);
advice_vampire_coast_extra_powder:set_advice_level(1);

advice_vampire_coast_extra_powder:add_trigger_condition(
	function()	
		-- return true if the player is tomb kings
		return (core:svr_load_bool("primary_defender_is_player") and core:svr_load_string("primary_defender_subculture") == "wh2_dlc11_sc_cst_vampire_coast") or 
			(core:svr_load_bool("primary_attacker_is_player") and core:svr_load_string("primary_attacker_subculture") == "wh2_dlc11_sc_cst_vampire_coast")
	end,
	"ScriptEventConflictPhaseBegins"
);