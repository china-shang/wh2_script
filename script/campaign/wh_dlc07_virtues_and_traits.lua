
BRET_LORDS_RECORDS = {};
LOUEN_FORENAME = "names_name_2147343915";

BAD_TRAITS = {"wh_dlc07_trait_brt_lord_bad_abducter","wh_dlc07_trait_brt_lord_bad_attacker","wh_dlc07_trait_brt_lord_bad_coward",
			"wh_dlc07_trait_brt_lord_bad_defeat","wh_dlc07_trait_brt_lord_bad_defender","wh_dlc07_trait_brt_lord_bad_lazy",
			"wh_dlc07_trait_brt_lord_bad_perverted","wh_dlc07_trait_brt_lord_bad_raider","wh_dlc07_trait_brt_lord_bad_renegade",
			"wh_dlc07_trait_brt_lord_bad_sacking","wh_dlc07_trait_brt_lord_bad_sieging","wh_dlc07_trait_brt_lord_bad_traitor",
			"wh_dlc07_trait_brt_lord_bad_villain"};

function Add_Virtues_and_Traits_Listeners()
	out("#### Adding Virtues and Traits Listeners ####");
	
	if BRET_LORDS_RECORDS ~= nil then
		for key,value in pairs(BRET_LORDS_RECORDS) do
			out("\t\t"..tostring(key).." = "..tostring(value));
		end
	else
		BRET_LORDS_RECORDS = {};
	end
end

function is_reinforcer(character)
	if cm:pending_battle_cache_num_attackers() > 1 then
		for i = 2, cm:pending_battle_cache_num_attackers() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
			if character:command_queue_index() == this_char_cqi then
				return true;
			end
		end
	end
	if cm:pending_battle_cache_num_defenders() > 1 then
		for i = 2, cm:pending_battle_cache_num_defenders() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
			if character:command_queue_index() == this_char_cqi then
				return true;
			end
		end
	end
	return false;
end

function is_attacker(character)
	for i = 1, cm:pending_battle_cache_num_attackers() do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
		
		if character:command_queue_index() == this_char_cqi then
			return true;
		end
	end
	return false;
end

function is_defender(character)
	for i = 1, cm:pending_battle_cache_num_defenders() do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
		
		if character:command_queue_index() == this_char_cqi then
			return true;
		end
	end
	return false;
end

function is_LL_in_enemy(character, forename)
	if is_attacker(character) then
		for i = 1, cm:pending_battle_cache_num_defenders() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
			
			if not cm:model():character_for_command_queue_index(this_char_cqi):is_null_interface() and cm:model():character_for_command_queue_index(this_char_cqi):get_forename() == forename then 
				out("test test test test")
				return true, "defender";
			end
		end
	elseif is_defender(character) then
		for i = 1, cm:pending_battle_cache_num_attackers() do
			local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
			
			if cm:model():character_for_command_queue_index(this_char_cqi):get_forename() == forename then
				return true, "attacker";
			end
		end
	end
	return false, "none";
end

function is_peasant_army(character)
	local force = character:military_force():unit_list();
	local counter = 0;

	for i = 0, force:num_items() - 1 do
		local unit = force:item_at(i);
		
		if Is_Peasant_Unit(unit:unit_key()) == true and unit:unit_class() ~= "com" then
			counter = counter + 1;
		end
	end
	return counter > 15;
end

function is_knightly_army(character)
	local force = character:military_force():unit_list();
	local counter = 0;
	
	for i = 0, force:num_items() - 1 do
		local unit = force:item_at(i);
		
		if Is_Peasant_Unit(unit:unit_key()) == false and unit:unit_class() ~= "com" then
			counter = counter + 1;
		end
	end
	return counter > 15;
end

function region_has_chain(region, chain)
	local slot_list = region:slot_list();
	
	for i = 0, slot_list:num_items() - 1 do
		local current_slot = slot_list:item_at(i);
		if current_slot:has_building() and current_slot:building():chain() == chain then
			return true;
		end
	end
	return false;
end

--Winrate Traits
core:add_listener(
	"character_completed_battle_winrate_traits",
	"CharacterCompletedBattle",
	true,
	function(context)
		if context:character():battles_fought()>10 and cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if (context:character():battles_won() / context:character():battles_fought()) >= 0.8 then
				cm:force_add_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_good_victory",true);
				if (context:character():has_trait("wh_dlc07_trait_brt_lord_bad_defeat")) then
					cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_bad_defeat");
				end
			elseif (context:character():battles_won() / context:character():battles_fought()) <= 0.5 then
				cm:force_add_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_bad_defeat",true);
				if (context:character():has_trait("wh_dlc07_trait_brt_lord_bad_defeat")) then
					cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_good_victory");
				end
			else
				cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_bad_defeat");
				cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(),"wh_dlc07_trait_brt_lord_good_victory");
			end
		end

		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if context:character():won_battle() and is_attacker(context:character()) then
				effect.trait("wh_dlc07_trait_brt_lord_good_attacker", "agent", 1, 100, context);
			elseif context:character():won_battle()==false and is_attacker(context:character()) then
				effect.trait("wh_dlc07_trait_brt_lord_bad_attacker", "agent", 2, 100, context);
			end
		end	
		
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if context:character():won_battle() and is_defender(context:character()) then
				effect.trait("wh_dlc07_trait_brt_lord_good_defender", "agent", 1, 100, context);
			elseif context:character():won_battle()==false and is_defender(context:character()) then
				effect.trait("wh_dlc07_trait_brt_lord_bad_defender", "agent", 2, 100, context);
			end
		end	
	end,
	true
);


-- Kingslayer
core:add_listener(
	"battle_completed_kingslayer_trait",
	"BattleCompleted",
	true,
	function(context)
		local faction = cm:model():world():faction_by_key("wh_main_brt_bretonnia");
		local Bret_are_there = false;
		local Bret_are_attacking = false; 

		if (faction:is_null_interface() == true or faction:is_dead()) then 
			if cm:pending_battle_cache_num_attackers() >= 1 then
				for i = 1, cm:pending_battle_cache_num_attackers() do
					local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
					if current_faction_name == "wh_main_brt_bretonnia" then
						Bret_are_there = true;
						Bret_are_attacking =  true;
					end
				end
			end
			
			if cm:pending_battle_cache_num_defenders() >= 1 then
				for i = 1, cm:pending_battle_cache_num_defenders() do
					local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
					if current_faction_name == "wh_main_brt_bretonnia" then
						Bret_are_there = true;
					end
				end
			end
			
			if Bret_are_there and Bret_are_attacking then
				local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(1);
				if (cm:model():character_for_command_queue_index(this_char_cqi):has_trait("wh_dlc07_trait_brt_lord_bad_kingslayer") == false and cm:model():character_for_command_queue_index(this_char_cqi):faction():culture()=="wh_main_brt_bretonnia") then
					cm:force_add_trait("character_cqi:"..this_char_cqi,"wh_dlc07_trait_brt_lord_bad_kingslayer",true);
				end
			elseif Bret_are_there and Bret_are_attacking == false then
				local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(1);
				if (cm:model():character_for_command_queue_index(this_char_cqi):has_trait("wh_dlc07_trait_brt_lord_bad_kingslayer") == false and cm:model():character_for_command_queue_index(this_char_cqi):faction():culture()=="wh_main_brt_bretonnia") then
					cm:force_add_trait("character_cqi:"..this_char_cqi,"wh_dlc07_trait_brt_lord_bad_kingslayer",true);
				end
			end
		end
	end,
	true
);


-- Villain
core:add_listener(
	"character_completed_battle_villain_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if (is_attacker(context:character()) and context:pending_battle():defender():faction():culture() == "wh_main_brt_bretonnia") or
			(is_defender(context:character()) and context:pending_battle():attacker():faction():culture() == "wh_main_brt_bretonnia") then
			
				effect.trait("wh_dlc07_trait_brt_lord_bad_villain", "agent", 1, 100, context);
			end
		end
	end,
	true
);


-- Renegade
core:add_listener(
	"character_completed_battle_renegade_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if (is_attacker(context:character()) and context:pending_battle():defender():faction():culture() == "wh_main_emp_empire" and (not context:pending_battle():defender():faction():name()=="wh_main_teb_estalia") and (not context:pending_battle():defender():faction():name()=="wh_main_teb_tilea")) or
			(is_defender(context:character()) and context:pending_battle():attacker():faction():culture() == "wh_main_emp_empire" and (not context:pending_battle():attacker():faction():name()=="wh_main_teb_estalia") and (not context:pending_battle():attacker():faction():name()=="wh_main_teb_tilea")) then
			
				effect.trait("wh_dlc07_trait_brt_lord_bad_renegade", "agent", 1, 100, context);
			end
		end
	end,
	true
);


-- Low-Born
core:add_listener(
	"character_completed_battle_low_born_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" and context:character():won_battle() and is_peasant_army(context:character()) and (not context:character():has_trait("wh_dlc07_trait_brt_lord_good_knightly")) then
			effect.trait("wh_dlc07_trait_brt_lord_good_peasants", "agent", 1, 100, context);
		end
	end,
	true
);


-- Nobleman
core:add_listener(
	"character_completed_battle_nobleman_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" and context:character():won_battle() and is_knightly_army(context:character()) and (not context:character():has_trait("wh_dlc07_trait_brt_lord_good_peasants")) then
			effect.trait("wh_dlc07_trait_brt_lord_good_knightly", "agent", 1, 100, context);
		end
	end,
	true
);


-- Saviour
core:add_listener(
	"character_completed_battle_saviour_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if cm:pending_battle_cache_num_attackers() > 1 then
				for i = 2, cm:pending_battle_cache_num_attackers() do
					local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
					local this_char = cm:model():character_for_command_queue_index(this_char_cqi);
					if cm:char_is_general_with_army(this_char) and this_char:faction():culture() == "wh_main_brt_bretonnia" then
						cm:force_add_trait("character_cqi:"..this_char:command_queue_index(), "wh_dlc07_trait_brt_lord_good_reinforcing", true);
					end
				end
			end
			if cm:pending_battle_cache_num_defenders() > 1 then
				for i = 2, cm:pending_battle_cache_num_defenders() do
					local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
					local this_char = cm:model():character_for_command_queue_index(this_char_cqi);
					if cm:char_is_general_with_army(this_char) and this_char:faction():culture() == "wh_main_brt_bretonnia" then
						cm:force_add_trait("character_cqi:"..this_char:command_queue_index(), "wh_dlc07_trait_brt_lord_good_reinforcing", true);
					end
				end
			end
		end
	end,
	true
);
	

-- Traitor
core:add_listener(
	"character_completed_battle_traitor_trait",
	"CharacterCompletedBattle",
	function(context)
		return cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia"
	end,
	function(context)
		local louen_present, LL_role = is_LL_in_enemy(context:character(), LOUEN_FORENAME);

		if  louen_present == true and LL_role == "defender" then
			effect.trait("wh_dlc07_trait_brt_lord_bad_traitor", "agent", 1, 100, context);
		end
	end,
	true
);


-- Crusader
core:add_listener(
	"character_completed_battle_crusader_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" and context:character():faction():has_home_region() then
			local home = context:character():faction():home_region():settlement();
			local distance = distance_squared(context:character():logical_position_x(), context:character():logical_position_y(), home:logical_position_x(), home:logical_position_y());
			out("Bretonnia battle distance: "..distance);
			
			if distance >= 100000 then 
				effect.trait("wh_dlc07_trait_brt_lord_good_far_from_capital", "agent", 1, 100, context);
			end
		end
	end,
	true
);


-- Coward
core:add_listener(
	"character_completed_battle_coward_trait",
	"CharacterCompletedBattle",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" and context:character():routed_in_battle() and context:character():won_battle() == false then
			effect.trait("wh_dlc07_trait_brt_lord_bad_coward", "agent", 1, 100, context);
		end
	end,
	true
);


-- Abducter
core:add_listener(
	"character_post_battle_release_abducter_trait",
	"CharacterPostBattleRelease",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			effect.trait("wh_dlc07_trait_brt_lord_bad_abducter", "agent", 1, 100, context);
		end
	end,
	true
);


-- Purifier
core:add_listener(
	"character_post_battle_slaughter_purifier_trait",
	"CharacterPostBattleSlaughter",
	true,
	function (context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			effect.trait("wh_dlc07_trait_brt_lord_good_executing", "agent", 1, 100, context);
		end
	end,
	true
);


-- Looter, Butcher, Destroyer
core:add_listener(
	"character_sacked_settlement_looter_butcher_destroyer_trait",
	"CharacterSackedSettlement",
	true,
	function (context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			effect.trait("wh_dlc07_trait_brt_lord_bad_sacking", "agent", 1, 100, context);
		end
	end,
	true
);


-- Bretonnian traits
core:add_listener(
	"character_turn_start_bretonnian_traits",
	"CharacterTurnStart",
	true,
	function (context)
		local character = context:character();

		if character:faction():culture() == "wh_main_brt_bretonnia" and character:has_region() and character:character_type("general") and character:has_military_force() and character:military_force():is_army() then
			-- character is a bretonnian general with an army on land

			-- Raider trait
			if character:military_force():active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_LAND_RAID" then
				effect.trait("wh_dlc07_trait_brt_lord_bad_raider", "agent", 1, 100, context);
			end;

			-- Perverted trait
			if character:in_settlement() and character:region():building_exists("wh_main_brt_tavern_4") then
				effect.trait("wh_dlc07_trait_brt_lord_bad_perverted", "agent", 1, 100, context);
			end;

			-- Authoritarian trait
			if character:region():public_order() <= -50 then
				effect.trait("wh_dlc07_trait_brt_lord_good_public_order", "agent", 1, 100, context);
			end;

			-- Independent, Lone Wolf trait
			if character:model():turn_number() > 1 then
				if character:turns_in_enemy_regions() >= 20 then
					effect.trait("wh_dlc07_trait_brt_lord_good_lone_wolf", "agent", 1, 100, context);
				elseif character:turns_in_enemy_regions() >= 10 and context:character():has_trait("wh_dlc07_trait_brt_lord_good_lone_wolf") == false then
					effect.trait("wh_dlc07_trait_brt_lord_good_lone_wolf", "agent", 1, 100, context);	
				end;
			end;
		end
	end,
	true
);


-- Agriculturalist
core:add_listener(
	"building_completed_agriculturalist_trait",
	"BuildingCompleted",
	true,
	function(context)
		if context:building():chain() == "wh_main_BRETONNIA_farm_basic" or context:building():chain() == "wh_main_BRETONNIA_farm_extra" then
			local builder_fac = context:building():faction();
			
			if builder_fac:is_null_interface() == false and context:building():faction():character_list():num_items() > 1 then
				for i = 0, builder_fac:character_list():num_items() - 1 do
					local builder = builder_fac:character_list():item_at(i)
					
					if builder:is_null_interface() == false and builder:has_region() and cm:char_is_general_with_army(builder) and builder:region():name() == context:building():region():name() then
						cm:force_add_trait("character_cqi:"..builder:command_queue_index(), "wh_dlc07_trait_brt_lord_good_farming", true);
					end
				end
			end
		end
	end,
	true
);


-- Industrialist
core:add_listener(
	"building_completed_industrialist_trait",
	"BuildingCompleted",
	true,
	function(context)
		if (context:building():chain() == "wh_main_BRETONNIA_industry_basic" or context:building():chain() == "wh_main_BRETONNIA_industry_extra") and context:building():faction():character_list():num_items() > 1 then
			for i = 0, context:building():faction():character_list():num_items() - 1 do
				local builder = context:building():faction():character_list():item_at(i);
				
				if builder:has_region() and cm:char_is_general_with_army(builder) and builder:region():name() == context:building():region():name() and builder:faction():culture() == "wh_main_brt_bretonnia" then
					cm:force_add_trait("character_cqi:"..builder:command_queue_index(), "wh_dlc07_trait_brt_lord_good_industry", true);
				end
			end
		end
	end,
	true
);


-- Devoted
core:add_listener(
	"character_turn_end_devoted_trait",
	"CharacterTurnEnd",
	true,
	function(context)
		if cm:char_is_general_with_army(context:character()) and context:character():faction():culture() == "wh_main_brt_bretonnia" then
			if context:character():has_region() and context:character():in_settlement() and region_has_chain(context:character():region(), "wh_main_BRETONNIA_worship") then
				local char_cqi = tostring(context:character():command_queue_index()).."_praying";
				local char_turns_praying = BRET_LORDS_RECORDS[char_cqi] or 0;
				char_turns_praying = char_turns_praying + 1;
				local char_bad_traits = {};

				for i = 1, #BAD_TRAITS do
					if context:character():has_trait(BAD_TRAITS[i]) and context:character():trait_points(BAD_TRAITS[i]) >= CHIVALRY_TRAITS[BAD_TRAITS[i]].levels[1].points then
						table.insert(char_bad_traits, BAD_TRAITS[i]);
					end
				end
				
				if #char_bad_traits > 0 then
					-- Displayed 30% - Actual 40%
					if context:character():region():building_exists("wh_main_brt_worship_3") and cm:model():random_percent(40) then
						cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(), char_bad_traits[cm:random_number(#char_bad_traits)]);
					-- Displayed 20% - Actual 30%
					elseif context:character():region():building_exists("wh_main_brt_worship_2") and cm:model():random_percent(30) then
						cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(), char_bad_traits[cm:random_number(#char_bad_traits)]);
					-- Displayed 10% - Actual 20%
					elseif context:character():region():building_exists("wh_main_brt_worship_1") and cm:model():random_percent(20) then
						cm:force_remove_trait("character_cqi:"..context:character():command_queue_index(), char_bad_traits[cm:random_number(#char_bad_traits)]);
					end
				end
				
				if char_turns_praying >= 5 and context:character():has_trait("wh_dlc07_trait_brt_lord_good_praying") == false then
					effect.trait("wh_dlc07_trait_brt_lord_good_praying", "agent", 1, 100, context);
					BRET_LORDS_RECORDS[char_cqi] = nil; -- Reset
				else
					BRET_LORDS_RECORDS[char_cqi] = char_turns_praying;
				end
			end
		end
	end,
	true
);

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("BRET_LORDS_RECORDS", BRET_LORDS_RECORDS, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		BRET_LORDS_RECORDS = cm:load_named_value("BRET_LORDS_RECORDS", {}, context);
	end
);