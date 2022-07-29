local All_Upgrades = {
	"wh2_dlc15_grn_upgrade_blinders_orc_cav",
	"wh2_dlc15_grn_upgrade_blinders_pump_wagon",
	"wh2_dlc15_grn_upgrade_blinders_squig",
	"wh2_dlc15_grn_upgrade_blinders_wolf_rider",
	"wh2_dlc15_grn_upgrade_chariot_armour_orc_cav",
	"wh2_dlc15_grn_upgrade_chariot_armour_pump_wagon",
	"wh2_dlc15_grn_upgrade_chariot_armour_wolf_rider",
	"wh2_dlc15_grn_upgrade_combat_ammobag_night_goblin",
	"wh2_dlc15_grn_upgrade_combat_ammobag_orc",
	"wh2_dlc15_grn_upgrade_combat_ammobag_salvage_orc",
	"wh2_dlc15_grn_upgrade_enlarged_ammobag_goblin",
	"wh2_dlc15_grn_upgrade_heavy_ammo_goblin",
	"wh2_dlc15_grn_upgrade_heavy_ammo_spider_rider",
	"wh2_dlc15_grn_upgrade_combat_ammobag_wolf_rider",
	"wh2_dlc15_grn_upgrade_jagged_weapon_black_orc",
	"wh2_dlc15_grn_upgrade_jagged_weapon_giant_idol",
	"wh2_dlc15_grn_upgrade_jagged_weapon_goblin",
	"wh2_dlc15_grn_upgrade_jagged_weapon_pump_wagon",
	"wh2_dlc15_grn_upgrade_jagged_weapon_spider_rider",
	"wh2_dlc15_grn_upgrade_jagged_weapon_squig",
	"wh2_dlc15_grn_upgrade_jagged_weapon_wolf_rider",
	"wh2_dlc15_grn_upgrade_liquor_flask_night_goblin",
	"wh2_dlc15_grn_upgrade_liquor_flask_salvage_orc",
	"wh2_dlc15_grn_upgrade_padded_shield_orc",
	"wh2_dlc15_grn_upgrade_piercing_weapon_black_orc",
	"wh2_dlc15_grn_upgrade_piercing_weapon_orc_cav",
	"wh2_dlc15_grn_upgrade_piercing_weapon_pump_wagon",
	"wh2_dlc15_grn_upgrade_piercing_weapon_salvage_orc",
	"wh2_dlc15_grn_upgrade_piercing_weapon_salvage_orc_cav",
	"wh2_dlc15_grn_upgrade_reinforced_weapon_orc",
	"wh2_dlc15_grn_upgrade_reinforced_weapon_orc_cav",
	"wh2_dlc15_grn_upgrade_reinforced_weapon_salvage_orc_cav",
	"wh2_dlc15_grn_upgrade_reinforced_weapon_troll",
	"wh2_dlc15_grn_upgrade_restraints_squig",
	"wh2_dlc15_grn_upgrade_scrap_armour_goblin",
	"wh2_dlc15_grn_upgrade_scrap_armour_orc",
	"wh2_dlc15_grn_upgrade_scrap_saddles_orc_cav",
	"wh2_dlc15_grn_upgrade_scrap_saddles_salvage_orc_cav",
	"wh2_dlc15_grn_upgrade_scrap_saddles_spider_rider",
	"wh2_dlc15_grn_upgrade_scrap_saddles_squig",
	"wh2_dlc15_grn_upgrade_scrap_saddles_wolf_rider",
	"wh2_dlc15_grn_upgrade_spiked_weapon_arachnarok",
	"wh2_dlc15_grn_upgrade_spiked_weapon_goblin",
	"wh2_dlc15_grn_upgrade_spiked_weapon_night_goblin",
	"wh2_dlc15_grn_upgrade_stone_armour_giant_idol",
	"wh2_dlc15_grn_upgrade_water_flask_goblin",
	"wh2_dlc15_grn_upgrade_water_flask_troll",
	"wh2_dlc15_grn_upgrade_winged_ammo_night_goblin",
	"wh2_dlc15_grn_upgrade_combat_ammobag_artillery",
	"wh2_dlc15_grn_upgrade_winged_ammo_artillery",
	"wh2_dlc15_grn_upgrade_piercing_weapon_arachnarok",
	"wh2_dlc15_grn_upgrade_restraints_arachnarok",
	"wh2_dlc15_grn_upgrade_combat_ammobag_spider_rider"
};

local Greenskin_subc = "wh_main_sc_grn_greenskins";

local faction_exclusive_available = {
	"wh2_dlc15_grn_bonerattlaz", "wh_main_grn_crooked_moon", "wh_main_grn_greenskins", "wh_main_grn_orcs_of_the_bloody_hand"
};

local faction_exclusive_upgrade_index = {
	["wh2_dlc15_grn_bonerattlaz"] = "wh2_dlc15_grn_upgrade_sorcery_weapon",
	["wh_main_grn_crooked_moon"] = "wh2_dlc15_grn_upgrade_fungus_flask",
	["wh_main_grn_greenskins"] = "wh2_dlc15_grn_upgrade_immortual_armour",
	["wh_main_grn_orcs_of_the_bloody_hand"] = "wh2_dlc15_grn_upgrade_idol_of_gork"
};

local Upgrade_tech_keys = {
	"tech_grn_end_1_1",
	"tech_grn_end_2_2",
	"tech_grn_end_3_3",
	"tech_grn_end_4_2",
	"tech_grn_end_5_1",
	"tech_grn_extra_1_1",
	"tech_grn_extra_1_2",
	"tech_grn_extra_1_3",
	"tech_grn_extra_1_4",
	"tech_grn_extra_3_1",
	"tech_grn_extra_3_2",
	"tech_grn_extra_3_3",
	"tech_grn_extra_3_4"
};

local Upgrade_locked_properly = {};

local Advice_fired = false;

local Upgrade_techs = {
	["tech_grn_end_1_1"] = {"wh2_dlc15_grn_upgrade_combat_ammobag_artillery","wh2_dlc15_grn_upgrade_winged_ammo_artillery"},
	["tech_grn_end_2_2"] = {"wh2_dlc15_grn_upgrade_reinforced_weapon_troll","wh2_dlc15_grn_upgrade_water_flask_troll"},
	["tech_grn_end_3_3"] = { "wh2_dlc15_grn_upgrade_piercing_weapon_arachnarok", "wh2_dlc15_grn_upgrade_restraints_arachnarok"},
	["tech_grn_end_4_2"] = {"wh2_dlc15_grn_upgrade_jagged_weapon_giant_idol","wh2_dlc15_grn_upgrade_stone_armour_giant_idol"},
	["tech_grn_end_5_1"] = {"wh2_dlc15_grn_upgrade_blinders_squig","wh2_dlc15_grn_upgrade_jagged_weapon_black_orc","wh2_dlc15_grn_upgrade_jagged_weapon_squig","wh2_dlc15_grn_upgrade_piercing_weapon_black_orc","wh2_dlc15_grn_upgrade_restraints_squig","wh2_dlc15_grn_upgrade_scrap_saddles_squig"},
	["tech_grn_extra_1_1"] = {"wh2_dlc15_grn_upgrade_blinders_pump_wagon","wh2_dlc15_grn_upgrade_chariot_armour_pump_wagon","wh2_dlc15_grn_upgrade_jagged_weapon_pump_wagon","wh2_dlc15_grn_upgrade_piercing_weapon_pump_wagon","wh2_dlc15_grn_upgrade_enlarged_ammobag_goblin","wh2_dlc15_grn_upgrade_heavy_ammo_goblin","wh2_dlc15_grn_upgrade_jagged_weapon_goblin","wh2_dlc15_grn_upgrade_scrap_armour_goblin","wh2_dlc15_grn_upgrade_spiked_weapon_goblin","wh2_dlc15_grn_upgrade_water_flask_goblin"},
	["tech_grn_extra_1_2"] = {"wh2_dlc15_grn_upgrade_blinders_wolf_rider","wh2_dlc15_grn_upgrade_chariot_armour_wolf_rider","wh2_dlc15_grn_upgrade_combat_ammobag_wolf_rider","wh2_dlc15_grn_upgrade_jagged_weapon_wolf_rider","wh2_dlc15_grn_upgrade_scrap_saddles_wolf_rider"},
	["tech_grn_extra_1_3"] = {"wh2_dlc15_grn_upgrade_combat_ammobag_spider_rider","wh2_dlc15_grn_upgrade_jagged_weapon_spider_rider","wh2_dlc15_grn_upgrade_scrap_saddles_spider_rider"},
	["tech_grn_extra_1_4"] = {"wh2_dlc15_grn_upgrade_combat_ammobag_night_goblin","wh2_dlc15_grn_upgrade_liquor_flask_night_goblin","wh2_dlc15_grn_upgrade_spiked_weapon_night_goblin","wh2_dlc15_grn_upgrade_winged_ammo_night_goblin"},
	["tech_grn_extra_3_1"] = {"wh2_dlc15_grn_upgrade_combat_ammobag_orc","wh2_dlc15_grn_upgrade_padded_shield_orc","wh2_dlc15_grn_upgrade_reinforced_weapon_orc","wh2_dlc15_grn_upgrade_scrap_armour_orc"},
	["tech_grn_extra_3_2"] = {"wh2_dlc15_grn_upgrade_blinders_orc_cav","wh2_dlc15_grn_upgrade_chariot_armour_orc_cav","wh2_dlc15_grn_upgrade_piercing_weapon_orc_cav","wh2_dlc15_grn_upgrade_reinforced_weapon_orc_cav","wh2_dlc15_grn_upgrade_scrap_saddles_orc_cav"},
	["tech_grn_extra_3_3"] = {"wh2_dlc15_grn_upgrade_combat_ammobag_salvage_orc","wh2_dlc15_grn_upgrade_liquor_flask_salvage_orc","wh2_dlc15_grn_upgrade_piercing_weapon_salvage_orc"},
	["tech_grn_extra_3_4"] = {"wh2_dlc15_grn_upgrade_piercing_weapon_salvage_orc_cav","wh2_dlc15_grn_upgrade_reinforced_weapon_salvage_orc_cav","wh2_dlc15_grn_upgrade_scrap_saddles_salvage_orc_cav"}
};

--this defines the interval we check and apply upgrade to AI
local cooldown = 10

function add_grn_unit_upgrade_listeners()
	out("#### Adding Unit Upgrade Listeners ####");
	--locks everything at beginning of campaign, this only applies to  player now, we are giving AI free scrap upgrades every now and then
	core:add_listener(
		"Unit_upgrade_lock_tech_grn",
		"ScriptEventHumanFactionTurnStart",
		function(context)
			return context:faction():subculture() == Greenskin_subc;
		end,
		function(context)
			local faction = context:faction();
			local faction_key = faction:name();

			if not check_element_in_table(faction_key, Upgrade_locked_properly) then
				for i = 1, #Upgrade_tech_keys do
					for j = 1, #Upgrade_techs[Upgrade_tech_keys[i]] do
						cm:faction_set_unit_purchasable_effect_lock_state(faction, Upgrade_techs[Upgrade_tech_keys[i]][j], Upgrade_techs[Upgrade_tech_keys[i]][j], true);
					end
				end
				table.insert(Upgrade_locked_properly, faction_key);
			end
			--lock faction specific upgrades
			for i = 1, #faction_exclusive_available do
				if faction_key ~= faction_exclusive_available[i] then
					cm:faction_set_unit_purchasable_effect_lock_state(faction, faction_exclusive_upgrade_index[faction_exclusive_available[i]], "", true);
				end
			end
			if faction:has_technology("tech_grn_final_1_1") then
				cm:faction_add_pooled_resource(faction_key, "grn_salvage", "wh2_dlc13_resource_factor_technology", 10);
			end
		end,
		true
	);
	
	--unlocks the upgrade based on faction
	core:add_listener(
		"Unit_upgrade_tech_grn",
		"ResearchCompleted",
		function(context)
			return context:faction():subculture() == Greenskin_subc and context:faction():is_human();
		end,
		function(context)
			local tech = context:technology();
			if Upgrade_techs[tech] then
				for i = 1 , #Upgrade_techs[tech] do
					cm:faction_set_unit_purchasable_effect_lock_state(context:faction(), Upgrade_techs[tech][i], Upgrade_techs[tech][i], false);
				end
			end
		end,
		true
	);
	
	--checks if we should fire advice
	core:add_listener(	
		"Unit_upgrade_available",
		"CharacterSelected",
		function(context)
			local character = context:character();
			local faction = context:character():faction();
			if faction:subculture() ~= Greenskin_subc then
				return false;
			end
			local resource = faction:pooled_resource("grn_salvage");
			local check_resu = false;

			--checks if the player has available upgrade unlocked that can be purchased for faction
			if character:has_military_force() == true and not faction:is_null_interface() and faction:is_human() then
				local force = character:military_force();
				local unit_list = force:unit_list();
				for i = 1, unit_list:num_items() do
					local unit = unit_list:item_at(i-1);
					local unit_effect_list = unit:get_unit_purchasable_effects();
					for j = 1, unit_effect_list:num_items() do
						if unit:can_purchase_effect(faction, unit_effect_list:item_at(j-1)) then
							check_resu = true;
						end
					end
				end
			end
			return check_resu;
		end,
		function(context)
			core:trigger_event("CharacterSelectedWithUnitUpgradeUnlockedAndAffordable");
			Advice_fired = true;
		end,
		false
	);
	-- Automatically Upgrade AI Units at set intervals
	cm:add_faction_turn_start_listener_by_subculture(
		"Spawning_mist_murderers",
		Greenskin_subc,
		function(context)
			if context:faction():is_human() == false then
				local turn = cm:model():turn_number();
				local grn_interface = context:faction();
				local grn_force_list = grn_interface:military_force_list();
				if turn % cooldown == 0 then 
					for l = 1, #faction_exclusive_available do
						if grn_interface ~= faction_exclusive_available[l] then
							cm:faction_set_unit_purchasable_effect_lock_state(context:faction(), faction_exclusive_upgrade_index[faction_exclusive_available[l]], "", true);
						end
					end
					for i = 0, grn_force_list:num_items() - 1 do
						local grn_force = grn_force_list:item_at(i);
						local unit_list = grn_force:unit_list();
						
						for j = 0, unit_list:num_items() - 1 do
							local unit_interface = unit_list:item_at(j);
							local unit_purchasable_effect_list = unit_interface:get_unit_purchasable_effects();
							if unit_purchasable_effect_list:num_items() ~=0 then
								local rand = cm:random_number(unit_purchasable_effect_list:num_items()) -1;
								effect_interface = unit_purchasable_effect_list:item_at(rand);
								-- Upgrade the unit
								if grn_force:is_armed_citizenry() == false then
								cm:faction_purchase_unit_effect(context:faction(), unit_interface, effect_interface);
								end	
							end	
						end
					end
				end
			end
		end,
		true
	);
end


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("Upgrade_locked_properly", Upgrade_locked_properly, context);
		cm:save_named_value("Advice_fired", Advice_fired, context);
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			Upgrade_locked_properly = cm:load_named_value("Upgrade_locked_properly", Upgrade_locked_properly, context);
			Advice_fired = cm:load_named_value("Advice_fired", Advice_fired, context);
		end
	end
);