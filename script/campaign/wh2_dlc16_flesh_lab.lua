Throt_faction_name = "wh2_main_skv_clan_moulder";

--list of all available mutations, categorised by infantry and monster sections
local flesh_lab_mutation_list = {	
	["inf"] = {	["wh2_dlc16_throt_flesh_lab_inf_aug_0"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_1"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_2"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_3"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_4"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_5"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_6"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_7"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_8"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_9"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_10"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_11"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_12"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_13"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_14"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_15"] = true,
				["wh2_dlc16_throt_flesh_lab_inf_aug_16"] = true}, 
	["mon"] = {	["wh2_dlc16_throt_flesh_lab_mon_aug_0"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_1"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_2"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_3"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_4"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_5"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_6"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_7"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_8"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_9"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_10"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_11"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_12"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_13"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_14"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_15"] = true,
				["wh2_dlc16_throt_flesh_lab_mon_aug_16"] = true}
};
local flesh_lab_instability_mutation_key = "wh2_dlc16_throt_flesh_lab_instability";
local flesh_lab_instability_protection_key = "wh2_dlc16_throt_flesh_lab_hidden_augment_instability_protection";
local flesh_lab_negative_mutation_list = {"wh2_dlc16_throt_flesh_lab_instability_1", "wh2_dlc16_throt_flesh_lab_instability_2","wh2_dlc16_throt_flesh_lab_instability_3"};

local flesh_lab_growth_monster_key = "wh2_dlc16_throt_flesh_lab_monster";
local flesh_lab_upgrade_counter = 0;
local flesh_lab_growth_max = 1000;
local flesh_lab_growth_vat_natural_growth = 60;
local flesh_lab_mutagen_degeneration = -20;
local flesh_lab_mutagen_capacity = 100;
local flesh_lab_monster_pack_events = 	{	
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_1a", 	--2 Wolf Rats, 2 Skavenslaves, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_1b", 	--2 Wolf Rats, 1 Wolf Rats (Poison), 2 Skavenslaves
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_1c", 	--2 Wolf Rats, 1 Wolf Rats (Poison), 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_2a", 	--2 Rat Ogres, 1 Wolf Rats, 2 Skavenslaves, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_2b", 	--3 Rat Ogres, 1 Wolf Rats, 2 Skavenslaves, 1 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_2c",	--3 Rat Ogres, 1 Wolf Rats, 2 Skavenslaves, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_3a", 	--1 Brood Horror, 2 Wolf Rats, 2 Wolf Rats (Poison), 3 Skavenslaves
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_3b", 	--2 Brood Horror, 2 Wolf Rats, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_3c", 	--2 Brood Horror, 2 Wolf Rats, 2 Skavenslaves, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_4a", 	--1 Mutant Rat Ogre, 2 Rat Ogres, 1 Wolf Rats, 4 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_4b", 	--2 Mutant Rat Ogre, 2 Rat Ogres
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_4c", 	--2 Mutant Rat Ogre, 2 Rat Ogres, 2 Skavenslaves, 2 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_5a", 	--1 Hell Pit Abomination, 1 Brood Horror, 2 Rat Ogres, 4 Skavenslave Spears
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_5b", 	--1 Hell Pit Abomination, 1 Brood Horror, 3 Rat Ogres
	"wh2_dlc16_skv_throt_flesh_lab_monster_supply_5c"	--2 Hell Pit Abomination, 2 Rat Ogres, 4 Skavenslave Spears
};

local flesh_lab_monster_pack_event_index = { {}, {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {10, 11, 12}, {13, 14, 15} };
local flesh_lab_monster_pack_threshold = {0.5, 0.65, 0.8, 0.9, 1, 1.2};
local flesh_lab_batch_notifier = false
local flesh_lab_mutagen_notifier = false

--This is used for bespoke Flesh Lab upgrades
local flesh_lab_upgrade_ritual_keys = {	
	"wh2_dlc16_throt_flesh_lab_upgrade_0",
	"wh2_dlc16_throt_flesh_lab_upgrade_1",
	"wh2_dlc16_throt_flesh_lab_upgrade_2",
	"wh2_dlc16_throt_flesh_lab_upgrade_3",
	"wh2_dlc16_throt_flesh_lab_upgrade_4",
	"wh2_dlc16_throt_flesh_lab_upgrade_5",
	"wh2_dlc16_throt_flesh_lab_upgrade_6",
	"wh2_dlc16_throt_flesh_lab_upgrade_7",
	"wh2_dlc16_throt_flesh_lab_upgrade_8",
	"wh2_dlc16_throt_flesh_lab_upgrade_9"
};
local flesh_lab_upgrade_ritual_keys_tier1 = {	
	"wh2_dlc16_throt_flesh_lab_upgrade_0",
	"wh2_dlc16_throt_flesh_lab_upgrade_1",
	"wh2_dlc16_throt_flesh_lab_upgrade_2",
};
local flesh_lab_upgrade_ritual_keys_tier2 = {	
	"wh2_dlc16_throt_flesh_lab_upgrade_3",
	"wh2_dlc16_throt_flesh_lab_upgrade_4",
	"wh2_dlc16_throt_flesh_lab_upgrade_5",
};
local flesh_lab_upgrade_ritual_keys_tier3 = {	
	"wh2_dlc16_throt_flesh_lab_upgrade_6",
	"wh2_dlc16_throt_flesh_lab_upgrade_7",
	"wh2_dlc16_throt_flesh_lab_upgrade_8",
};

local flesh_lab_upgrade_purchased = {	
	["wh2_dlc16_throt_flesh_lab_upgrade_0"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_1"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_2"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_3"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_4"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_5"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_6"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_7"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_8"] = false,
	["wh2_dlc16_throt_flesh_lab_upgrade_9"] = false
};

--this is to define the mutation template for AI based on units
--notice you can add multiple combo for each unit record
local flesh_lab_AI_mutation_unit_index = {
	--infantry
	["wh2_main_skv_inf_clanrat_spearmen_0"] = {1,2,3},
	["wh2_main_skv_inf_clanrat_spearmen_1"] = {1,2,3},
	["wh2_main_skv_inf_clanrats_0"] = {1,2,3},
	["wh2_main_skv_inf_clanrats_1"] = {1,2,3},
	["wh2_main_skv_inf_death_runners_0"] = {1,2,3},
	["wh2_main_skv_inf_gutter_runners_0"] = {1,2,3},
	["wh2_main_skv_inf_gutter_runners_1"] = {1,2,3},
	["wh2_main_skv_inf_night_runners_0"] = {1,2,3},
	["wh2_main_skv_inf_night_runners_1"] = {1,2,3},
	--monsters
	["wh2_dlc16_skv_mon_brood_horror_0"] = {4,5,6},
	["wh2_dlc16_skv_mon_rat_ogre_mutant"] = {4,5,6},
	["wh2_dlc16_skv_mon_wolf_rats_0"] = {4,5,6},
	["wh2_dlc16_skv_mon_wolf_rats_1"] = {4,5,6},
	["wh2_main_skv_mon_hell_pit_abomination"] = {4,5,6},
	["wh2_main_skv_mon_rat_ogres"] = {4,5,6}
};
local flesh_lab_AI_mutation_combo = {
	--infantry combos
	{["wh2_dlc16_throt_flesh_lab_inf_aug_0"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_2"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_4"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_8"] = true},
	{["wh2_dlc16_throt_flesh_lab_inf_aug_6"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_10"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_15"] = true},
	{["wh2_dlc16_throt_flesh_lab_inf_aug_9"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_14"] = true, ["wh2_dlc16_throt_flesh_lab_inf_aug_16"] = true},
	--monster combos
	{["wh2_dlc16_throt_flesh_lab_mon_aug_6"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_8"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_11"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_14"] = true},
	{["wh2_dlc16_throt_flesh_lab_mon_aug_9"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_12"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_13"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_15"] = true},
	{["wh2_dlc16_throt_flesh_lab_mon_aug_7"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_14"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_15"] = true,["wh2_dlc16_throt_flesh_lab_mon_aug_16"] = true}
};
local flesh_lab_AI_check_cooldown = 20;


function add_flesh_lab_listeners()
	out("#### Adding Flesh Lab Listeners ####");
	-- set the current counter for the UI
	effect.set_context_value("flesh_lab_upgrade_counter", flesh_lab_upgrade_counter);

	add_per_turn_listener();
	growth_vat_unit_recruited_listener();
	add_instability_listener();
	add_growth_vat_listener();	
	add_lab_upgrade_listeners();
	
end


--this adds anything that needs to happen on turn x
--mutate ur starting units on turn 1
function add_per_turn_listener()
	core:add_listener(
	"start_unit_mutator",
	"FactionTurnStart", 
	function(context)
		return context:faction():name() == Throt_faction_name and cm:model():turn_number() == 1;
	end,
	function(context)
		local faction = context:faction();
		--get thrott's starting military forces
		local military_forces = faction:military_force_list();
		for i = 0, military_forces:num_items() - 1 do
			local military_force = military_forces:item_at(i);
			if military_force:has_general() and military_force:general_character():character_subtype_key() == "wh2_dlc16_skv_throt_the_unclean" then
				--apply the mutations to a certain monster unit
				--apply to  wolf rat
				local unit_list = military_force:unit_list();
				for j = 0, unit_list:num_items() - 1 do
					local unit = unit_list:item_at(j);
					local all_effects = unit:get_unit_purchasable_effects();
					if unit:unit_key() == "wh2_dlc16_skv_mon_wolf_rats_0" then
						--Apply the Instability protection hidden augment then the random augments then remove instability protection
						for i = 0, all_effects:num_items() - 1 do
							local effect_interface = all_effects:item_at(i);
							local effect = all_effects:item_at(i):record_key();
							if effect == flesh_lab_instability_protection_key then				
								cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
								random_mutation_application(unit, 2, {"wh2_dlc16_throt_flesh_lab_mon_aug_0", "wh2_dlc16_throt_flesh_lab_mon_aug_2"});
								random_mutation_application(unit, 1, {flesh_lab_instability_mutation_key});
								cm:faction_unpurchase_unit_effect(unit, effect_interface);
								break;
							end
						end	
						break;
					end
				end
			end
		end
	end,
	true
	);
	--unlock repeatable rituals
	core:add_listener(
		"start_unlock_repeatable",
		"FactionTurnStart", 
		function(context)
			return context:faction():name() == Throt_faction_name and cm:model():turn_number() == 2;
		end,
		function(context)
			-- Unlock rituals based on tier
			local faction = context:faction()
			local list_of_repeatable_upgrades = {
				"wh2_dlc16_throt_flesh_lab_conversion",
				"wh2_dlc16_throt_flesh_lab_replenish",
				"wh2_dlc16_throt_flesh_lab_thrott"
			}
			for i = 1, #list_of_repeatable_upgrades do
				cm:unlock_ritual(faction, list_of_repeatable_upgrades[i]);
			end
		end,
		true
	);
end

--Add 1 augment to each fresh unit coming from the mercenary pool
function growth_vat_unit_recruited_listener()
	local list_of_monster_augments = {
		"wh2_dlc16_throt_flesh_lab_mon_aug_0",
		"wh2_dlc16_throt_flesh_lab_mon_aug_1",
		"wh2_dlc16_throt_flesh_lab_mon_aug_2",
		"wh2_dlc16_throt_flesh_lab_mon_aug_3",
		"wh2_dlc16_throt_flesh_lab_mon_aug_5",
		"wh2_dlc16_throt_flesh_lab_mon_aug_6",
		"wh2_dlc16_throt_flesh_lab_mon_aug_7",
		"wh2_dlc16_throt_flesh_lab_mon_aug_8",
		"wh2_dlc16_throt_flesh_lab_mon_aug_9",
		"wh2_dlc16_throt_flesh_lab_mon_aug_10",
		"wh2_dlc16_throt_flesh_lab_mon_aug_11",
		"wh2_dlc16_throt_flesh_lab_mon_aug_12",
		"wh2_dlc16_throt_flesh_lab_mon_aug_13",
		"wh2_dlc16_throt_flesh_lab_mon_aug_14"
	};

	local list_of_infantry_augments = {
		"wh2_dlc16_throt_flesh_lab_inf_aug_0",
		"wh2_dlc16_throt_flesh_lab_inf_aug_1",
		"wh2_dlc16_throt_flesh_lab_inf_aug_2",
		"wh2_dlc16_throt_flesh_lab_inf_aug_3",
		"wh2_dlc16_throt_flesh_lab_inf_aug_6",
		"wh2_dlc16_throt_flesh_lab_inf_aug_7",
		"wh2_dlc16_throt_flesh_lab_inf_aug_8",
		"wh2_dlc16_throt_flesh_lab_inf_aug_9",
		"wh2_dlc16_throt_flesh_lab_inf_aug_10",
		"wh2_dlc16_throt_flesh_lab_inf_aug_11",
		"wh2_dlc16_throt_flesh_lab_inf_aug_12",
		"wh2_dlc16_throt_flesh_lab_inf_aug_13",
		"wh2_dlc16_throt_flesh_lab_inf_aug_14"
	};

	core:add_listener(
	"FleshLab_UnitTrained",
	"UnitTrained", 
	function(context)
		local unit = context:unit();
		local unit_key = unit:unit_key();		
		if not unit:is_null_interface() and context:unit():faction():name() == Throt_faction_name and unit:faction():is_human() then
			return unit_key:find("_flesh_lab");
		end
	end,
	function(context)
		local upgrades = 1;
		if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_4"] then
			upgrades = 2;
		end
		local list_of_possible_augments = {};

		local unit = context:unit();
		local unit_key = unit:unit_key();
		if unit_key:find("skavenslave") then
			list_of_possible_augments = list_of_infantry_augments;
		else
			list_of_possible_augments = list_of_monster_augments;
		end

		local all_effects = unit:get_unit_purchasable_effects();

		--Apply the Instability protection hidden augment then the random augments then remove instability protection
		for i = 0, all_effects:num_items() - 1 do
			local effect_interface = all_effects:item_at(i);
			local effect = all_effects:item_at(i):record_key();
			if effect == flesh_lab_instability_protection_key then				
				cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
				random_mutation_application(context:unit(), upgrades, list_of_possible_augments);
				cm:faction_unpurchase_unit_effect(unit, effect_interface);
				break;
			end
		end	

	end,
	true
	);
end

--listens to battles and upgrade purchases
--adds instability and negative mutations when condition is met
function add_instability_listener()
	core:add_listener(
		"Instability_CheckingAndApplying",
		"UnitEffectPurchased", 
		function(context)
			local unit = context:unit();
			local effect = context:effect():record_key();
			local effect_list = unit:get_unit_purchased_effects();

			if unit:faction():name() == Throt_faction_name then
				--Check if the purchased upgrade is the unit gaining Instability, or the script applying any hidden upgrades if so skip
				if effect:find("wh2_dlc16_throt_flesh_lab_instability") or effect:find("wh2_dlc16_throt_flesh_lab_hidden_augment_") then
					return false;
				end
				--If the unit has the Instability Protection hidden augment then return false
				for i = 0, effect_list:num_items() - 1 do
					local effect = effect_list:item_at(i):record_key();
					if effect == flesh_lab_instability_protection_key then
						return false;
					end
				end
				
				return true;
			end
		end,
		function(context)
			local unit = context:unit();
			local effect = context:effect():record_key();
			local effect_list = unit:get_unit_purchased_effects();
			local all_effects = unit:get_unit_purchasable_effects();
			local instability_effect_interface = false;
			local counter = 0; --this is to check how many mutations has already been purchased on the unit
			local can_instable = false;
			local already_instable = false;
			
			local num_augments = 0;
			local list_of_augments = {};
			--If one of the following 4 Augments has been purchased then apply the associated Random Augment reward
			if effect == "wh2_dlc16_throt_flesh_lab_mon_aug_4" then
				num_augments = 2; 
				list_of_augments = {"wh2_dlc16_throt_flesh_lab_mon_aug_0","wh2_dlc16_throt_flesh_lab_mon_aug_1","wh2_dlc16_throt_flesh_lab_mon_aug_2","wh2_dlc16_throt_flesh_lab_mon_aug_3","wh2_dlc16_throt_flesh_lab_mon_aug_5","wh2_dlc16_throt_flesh_lab_mon_aug_6","wh2_dlc16_throt_flesh_lab_mon_aug_7"};
			elseif effect == "wh2_dlc16_throt_flesh_lab_mon_aug_16" then
				num_augments = 3; 
				list_of_augments = {"wh2_dlc16_throt_flesh_lab_mon_aug_8","wh2_dlc16_throt_flesh_lab_mon_aug_9","wh2_dlc16_throt_flesh_lab_mon_aug_10","wh2_dlc16_throt_flesh_lab_mon_aug_11","wh2_dlc16_throt_flesh_lab_mon_aug_12","wh2_dlc16_throt_flesh_lab_mon_aug_13","wh2_dlc16_throt_flesh_lab_mon_aug_14"};
			elseif effect == "wh2_dlc16_throt_flesh_lab_inf_aug_5" then
				num_augments = 2; 
				list_of_augments = {"wh2_dlc16_throt_flesh_lab_inf_aug_0","wh2_dlc16_throt_flesh_lab_inf_aug_1","wh2_dlc16_throt_flesh_lab_inf_aug_2","wh2_dlc16_throt_flesh_lab_inf_aug_3","wh2_dlc16_throt_flesh_lab_inf_aug_6","wh2_dlc16_throt_flesh_lab_inf_aug_7"};
			elseif effect == "wh2_dlc16_throt_flesh_lab_inf_aug_17" then
				num_augments = 3; 
				list_of_augments = {"wh2_dlc16_throt_flesh_lab_inf_aug_8","wh2_dlc16_throt_flesh_lab_inf_aug_9","wh2_dlc16_throt_flesh_lab_inf_aug_10","wh2_dlc16_throt_flesh_lab_inf_aug_11","wh2_dlc16_throt_flesh_lab_inf_aug_12","wh2_dlc16_throt_flesh_lab_inf_aug_13","wh2_dlc16_throt_flesh_lab_inf_aug_14"};
			end
			
			--check num_augments, if it is greater than 0 then one of the 4 above augments must have been selected
			--if it is one of the above 4 augments we protect the unit from instability rolls on the free random augments
			--we do this because we only want the players unit to roll instability on the random augment itself, not the free augments that come with it
			if num_augments > 0 then
				--Apply the Instability protection hidden augment then the random augments then remove instability protection
				for x = 0, all_effects:num_items() - 1 do
					local effect_interface = all_effects:item_at(x);
					local effect = all_effects:item_at(x):record_key();
					if effect == flesh_lab_instability_protection_key then				
						cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
						random_mutation_application(unit, num_augments, list_of_augments);
						cm:faction_unpurchase_unit_effect(unit, effect_interface);
						break;
					end
				end	
			end


			
			--If the following Augment has been purchased rank up the selected unit (if possible)
			if effect == "wh2_dlc16_throt_flesh_lab_inf_aug_4" then
				cm:add_experience_to_unit(unit, 5);
			end

			--Count the number of Mutations
			for i = 0, effect_list:num_items() - 1 do
				local effect = effect_list:item_at(i):record_key();
				if effect == flesh_lab_instability_mutation_key then
					already_instable = true;
					break;
				end
				if flesh_lab_mutation_list["inf"][effect] or flesh_lab_mutation_list["mon"][effect] then
					counter = counter + 1;
				end
			end
		
			if counter >= 4 then
				--Lab Upgrade Steroid Infusions = wh2_dlc16_throt_flesh_lab_upgrade_7, this gives units a ward save buff if they have 4+ Augments
				if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_7"] then
					ward_save_upgrade_augment_application(unit);
				end	
			end

			--also check if the unit can have instability
			--and get the efffect interrface if the unit can
			if already_instable then
				--Roll a 50/50 chance whether to make the unit more unstable
				local random_chance = cm:model():random_percent(50);
				--Apply next stage of instability
				if random_chance then
					--Find out what the current highest level of Instability applied to the unit is
					local instability_level = get_instability_level(unit);

					--Apply Instability if not already at tier 4
					if instability_level < 4 then
						for y = 0, all_effects:num_items() - 1 do
							local effect = all_effects:item_at(y):record_key();
							local next_instability = flesh_lab_negative_mutation_list[instability_level];
							
							if effect == next_instability then
								instability_effect_interface = all_effects:item_at(y);
								break;
							end

						end
						--the instability level was calculated before the next instability level was added so we add 1 more to the instability level if we were less than tier 4 already
						instability_level = instability_level + 1;
						cm:faction_purchase_unit_effect(unit:faction(), unit, instability_effect_interface);
					end

					--Lab Upgrade Mutagen Distillation = wh2_dlc16_throt_flesh_lab_upgrade_6, this reduces instable units upkeep
					if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_6"] then
						--Apply the augment to make the units upkeep reduced if it is instable, pass the instability level so we can apply the correct upkeep reduction amount
						upkeep_upgrade_augment_application(unit, instability_level);
					end
				end
			else

				for j = 0, all_effects:num_items() - 1 do
					local effect = all_effects:item_at(j):record_key();
					if effect == flesh_lab_instability_mutation_key then
						instability_effect_interface = all_effects:item_at(j);
						can_instable = true;
						break;
					end	
				end
				--get instable chance based on counter
				if can_instable then
				
					--Instability chance is X0%, where X is the number of Augments so first Augment has 10% chance; seventh has 70% chance
					local chance = counter * 10;
					
					--This is where we fudge the numbers in the players favour so they are VERY unlikely to be unstable for the first couple of Augments 
					--Instead of 10% for first its now 5% and 10% for second, goes back to the X0% chance after that though
					if counter <= 2 then
						chance = chance / 2;
					end

					local random_chance = cm:model():random_percent(chance);
					if random_chance then
						--Adding Instability to unit
						cm:faction_purchase_unit_effect(unit:faction(), unit, instability_effect_interface);

						--Lab Upgrade Mutagen Distillation = wh2_dlc16_throt_flesh_lab_upgrade_6, this reduces instable units upkeep
						if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_6"] then
							--Apply the augment to make the units upkeep reduced if it is instable, since it has only just become unstable its instability level must be 1
							upkeep_upgrade_augment_application(unit, 1);
						end
					end
				end
			end
			

			
			
		end,
		true
	);
	
end

--listens to everything that gives/takes grwoth vat
--add/deplete growth vat charge
--distribute monster pack rewards 
--checks and stores the turn income and handles booster
function add_growth_vat_listener()
	--this handles the natrual growth per turn
	core:add_listener(
		"growth_vat_record",
		"FactionTurnStart", 
		function(context)
			return context:faction():name() == Throt_faction_name;
		end,
		function(context)
			-- Passive gain
			cm:faction_add_pooled_resource(context:faction():name(), "skv_growth_vat", "wh2_dlc16_throt_flesh_lab_growth_vat_gain_passive_gain", flesh_lab_growth_vat_natural_growth);

			-- Notification for available growth Vat
			local faction = context:faction();
			local current_value_growth = faction:pooled_resource("skv_growth_vat"):value();
			local current_threshold = flesh_lab_growth_max * flesh_lab_monster_pack_threshold[1];
			--Loop to give notification for when Growth Vat can be released
			if flesh_lab_batch_notifier == false then
				if current_value_growth > current_threshold then
					--Trigger incident to gift units to merc pool based on the random event choice from above
					cm:trigger_incident(faction:name(), "wh2_dlc16_skv_throt_flesh_lab_batch_available", true);
					flesh_lab_batch_notifier = true
				end
			end

			-- set the current capacity for the UI
			effect.set_context_value("mutagen_capacity", flesh_lab_mutagen_capacity);

			local current_value_mutagen = faction:pooled_resource("skv_mutagen"):value();
			-- Mutagen capacity calculation bring it down to 100 (200 if upgraded)
			if current_value_mutagen > flesh_lab_mutagen_capacity then
				local flesh_lab_mutagen_degeneration_applied = (current_value_mutagen - flesh_lab_mutagen_capacity) * -1
				if flesh_lab_mutagen_degeneration_applied > flesh_lab_mutagen_degeneration then 
					cm:faction_add_pooled_resource(faction:name(), "skv_mutagen", "wh2_dlc16_throt_flesh_lab_mutagen_used_degeneration", flesh_lab_mutagen_degeneration_applied);
				else
					cm:faction_add_pooled_resource(faction:name(), "skv_mutagen", "wh2_dlc16_throt_flesh_lab_mutagen_used_degeneration", flesh_lab_mutagen_degeneration);
				end

				if flesh_lab_mutagen_notifier == false then
					--Trigger incident to gift units to merc pool based on the random event choice from above
					cm:trigger_incident(faction:name(), "wh2_dlc16_skv_throt_flesh_lab_capacity_reached", true);
					flesh_lab_mutagen_notifier = true
				end
			end

			-- automatically release batch if growth vat hits 1000
			if current_value_growth > 999 then
				cm:perform_ritual(Throt_faction_name, "", flesh_lab_growth_monster_key);
			end
		end,
		true
	);
	
	--this handles the mosnter distribution
	--by triggering the proper incident, the unit will be distributed to merc pool
	--note there's redundant events for each threshold and we randomly pick one of it
	core:add_listener(
	"growth_vat_monster",
	"RitualCompletedEvent", 
	function(context)
		return context:performing_faction():name() == Throt_faction_name and context:ritual():ritual_key() == flesh_lab_growth_monster_key;
	end,
	function(context)
		local faction = context:performing_faction();
		local current_value = faction:pooled_resource("skv_growth_vat"):value();
			
		--Safety check that the current_value isnt somehow lower than the first threshold, this should never happen!! (if UI works correctly then the Ritual button wont be available)
		if current_value >= flesh_lab_monster_pack_threshold[1] * flesh_lab_growth_max then
			
			--Loop for as many times as there are thresholds, we start from 2 since we have already check i=1 in the if-statement above
			for i = 2, #flesh_lab_monster_pack_threshold do
				--Set the current threshold by multiplying the maximum growth value by the threshold list entries (these are increments of 20% up to 120%)
				--The 120% is used as the next check confirms your Growth Juice isnt above the the current threshold (it would be impossible to be above 120% of the limit)
				local current_threshold = flesh_lab_monster_pack_threshold[i] * flesh_lab_growth_max;
				--If Growth Juice total is less than next threshold go into if-statement
				if current_value < current_threshold then
					--Random number between 1 number of events in group (currently all 3)
					local random_index = cm:random_number(#flesh_lab_monster_pack_event_index[i]);
						--Trigger incident to gift units to merc pool based on the random event choice from above
						cm:trigger_incident(faction:name(), flesh_lab_monster_pack_events[flesh_lab_monster_pack_event_index[i][random_index]], true);
						--Reset Growth Juice in pooled resource
						cm:faction_add_pooled_resource(faction:name(), "skv_growth_vat", "wh2_dlc16_throt_flesh_lab_growth_vat_lose_spawn_monster", -current_value);
						
						-- Add additional extra unit to merc pool if upgrade has been unlocked
						if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_8"] then
							local additional_units = {
								"wh2_dlc16_skv_mon_brood_horror_0_flesh_lab",
								"wh2_dlc16_skv_mon_hell_pit_abomination_flesh_lab",
								"wh2_dlc16_skv_mon_rat_ogre_mutant_flesh_lab",
								"wh2_dlc16_skv_mon_rat_ogres_flesh_lab",
								"wh2_dlc16_skv_mon_wolf_rats_0_flesh_lab",
								"wh2_dlc16_skv_mon_wolf_rats_1_flesh_lab"
							}
							rand = cm:random_number(#additional_units)
							cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), additional_units[rand], 1)
						end
						flesh_lab_batch_notifier = false
						flesh_lab_mutagen_notifier = false
						break;
				end
			end

			-- Count how many batches have been released
			flesh_lab_upgrade_counter = flesh_lab_upgrade_counter + 1;

			-- set the current counter for the UI
			effect.set_context_value("flesh_lab_upgrade_counter", flesh_lab_upgrade_counter);

			-- Unlock rituals based on tier
			if flesh_lab_upgrade_counter == 1 then
				for j = 1, #flesh_lab_upgrade_ritual_keys_tier1 do
					cm:unlock_ritual(faction, flesh_lab_upgrade_ritual_keys_tier1[j]);
				end
			elseif flesh_lab_upgrade_counter == 4 then
				for k = 1, #flesh_lab_upgrade_ritual_keys_tier2 do
					cm:unlock_ritual(faction, flesh_lab_upgrade_ritual_keys_tier2[k]);
				end
			elseif flesh_lab_upgrade_counter == 8 then
				for l = 1, #flesh_lab_upgrade_ritual_keys_tier3 do
					cm:unlock_ritual(faction, flesh_lab_upgrade_ritual_keys_tier3[l]);
				end
			end	

		else
			script_error("ERROR: Growth Vat Ritual completed but Growth Juice amount is less than the minimum to open VAT! How is this possible?");

		end
	end,
	true
	);	
end

function add_lab_upgrade_listeners()
	--handles bespoke lab upgarde effects
	
	--checks if a unit being recycled, 
	--apply any bespoke event based on unit recycling,
	--also finish the corresponding scripted mission if active
	core:add_listener(
		"flesh_lab_recycle_listerner",
		"UnitDisbanded",
		function(context)
			if not context:unit():is_null_interface() and context:unit():faction():name() == Throt_faction_name and context:unit():faction():is_human() then
				return true;
			end
		end,
		function(context)
			---------------------------------------------------------------------------------------
			--Check if Lab Upgrades have been completed that have additional effects to recycling--
			---------------------------------------------------------------------------------------
			local unit = context:unit();

			--Lab Upgrade Growth Catalysers = wh2_dlc16_throt_flesh_lab_upgrade_4, this adds a chance of generating food when recycling a unit
			if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_4"] then
				local unit_purchased_effect_list = unit:get_unit_purchased_effects(); 
				for i = 0, unit_purchased_effect_list:num_items() - 1 do
					local effect = unit_purchased_effect_list:item_at(i):record_key();
					--Check if the unit has Instability 
					if effect == flesh_lab_instability_mutation_key then
						--Grant 5 Food
						cm:faction_add_pooled_resource(Throt_faction_name, "skaven_food", "wh2_dlc16_resource_factor_food_throt_flesh_lab_positive", 5);
					end
				end
			end
				
		end,
		true
	);

	--Check if a skavenslave is being recruited, also checks if Lab Upgrade is Purchased for the Random Augment application to Skavenslaves
	core:add_listener(
		"flesh_lab_recruitment listener",
		"UnitTrained",
		function(context)
			if not context:unit():is_null_interface() and context:unit():faction():name() == Throt_faction_name and context:unit():faction():is_human() then
				return true;
			end
		end,
		function(context)
			if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_2"] then
				--Check if unit is a Skavenslaves or skavenslave spears unit
				if context:unit():unit_key():find("skavenslaves_0") or context:unit():unit_key():find("skavenslave_spearmen") then
					skavenslave_augment_application(context);
				end
			end				
		end,
		true
	);

	--apply effect bundle for feed thrott repeatable action
	core:add_listener(
		"flesh_lab_monster_pack_listerner",
		"RitualCompletedEvent",
		function(context)
			if context:performing_faction():name() == Throt_faction_name and context:performing_faction():is_human() and context:ritual():ritual_key() == "wh2_dlc16_throt_flesh_lab_thrott" then
				return true;
			end
		end,
		function(context)
			local faction_leader = context:performing_faction():faction_leader()
			local faction_leader_military_force = faction_leader:military_force():command_queue_index()

			if faction_leader:has_military_force() then
				cm:apply_effect_bundle_to_character("wh2_dlc16_bundle_throt_flesh_lab_thrott_payload", faction_leader, 3)
			end
		end,
		true
	);
		
	--checks if a lab upgrade is purchased
	--apply any bespoke event based on lab upgrades
	--also finish the corresponding scripted mission if active
	core:add_listener(
		"FleshLab_RitualCompletedEvent",
		"RitualCompletedEvent",
		function(context)
			if context:performing_faction():name() == Throt_faction_name and context:performing_faction():is_human() and flesh_lab_upgrade_purchased[context:ritual():ritual_key()] ~= nil then
				return true;
			end
		end,
		function(context)
			--set Upgrade completed to true
			flesh_lab_upgrade_purchased[context:ritual():ritual_key()] = true;

			--Get military force list for next 2 checks
			local military_force_list = context:performing_faction():military_force_list();

			--Switch growth vat release ritual (increased skaven food)
			if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_3"] then
				flesh_lab_growth_monster_key = "wh2_dlc16_throt_flesh_lab_monster_2";
			end

			--Increase Mutagen capacity
			if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_5"] then
				flesh_lab_mutagen_capacity = 200
				effect.set_context_value("mutagen_capacity", flesh_lab_mutagen_capacity);
			end

			--Loop through all owned military forces				
			for i = 0, military_force_list:num_items() - 1 do
				local military_force = military_force_list:item_at(i);
				local unit_list = military_force:unit_list();
				for j = 0, unit_list:num_items() - 1 do
					local unit = unit_list:item_at(j);
					local effect_list = unit:get_unit_purchased_effects();
					local all_effects = unit:get_unit_purchasable_effects();
					local instability_effect_interface = false;
					local counter = 0; 

					--Check if unit has Instability and count total number of Augments
					for k = 0, effect_list:num_items() - 1 do
						local effect = effect_list:item_at(k):record_key();
						--unit has level one instability, no loop to see what the max level of instability the unit has
						if effect == flesh_lab_instability_mutation_key then
							local instability_level = get_instability_level(unit);
							--Lab Upgrade Mutagen Distillation = wh2_dlc16_throt_flesh_lab_upgrade_6, this reduces instable units upkeep
							if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_6"] then
								--Apply the augment to make the units upkeep reduced if it is instable
								upkeep_upgrade_augment_application(unit, instability_level);
							end

						end
						if flesh_lab_mutation_list["inf"][effect] or flesh_lab_mutation_list["mon"][effect] then
							counter = counter + 1;
						end
					end
					--Check if 4 or more Augment on units
					if counter >= 4 then
						--Lab Upgrade Steroid Infusions = wh2_dlc16_throt_flesh_lab_upgrade_7, this gives units a ward save buff if they have 2+ Augments
						if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_7"] then
							ward_save_upgrade_augment_application(unit);
						end		
					end

					if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_2"] then
						--Check if unit is a Skavenslaves or skavenslave spears unit
						if unit:unit_key():find("skavenslaves_0") or unit:unit_key():find("skavenslave_spearmen") then
							--Apply the augment to make the units no longer provide Growth Juice when Recycled
							local all_possible_augments = unit:get_unit_purchasable_effects();
							for l = 0, all_possible_augments:num_items() - 1  do
								local effect_interface = all_possible_augments:item_at(l);
								local effect = effect_interface:record_key();
								if effect == "wh2_dlc16_throt_flesh_lab_hidden_augment_refund_cancel" then				
									cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
									break;
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

function setup_flesh_lab_listener_for_AI()
	cm:add_faction_turn_start_listener_by_name(
	"AI_flesh_lab_listener",
	Throt_faction_name,
	function(context)
		if context:faction():is_human() == false then
			local turn = cm:model():turn_number();
			local throt_force_list = context:faction():military_force_list();
			if turn % flesh_lab_AI_check_cooldown == 0 then 
				for i = 0, throt_force_list:num_items() - 1 do
					local throt_force = throt_force_list:item_at(i);
					local unit_list = throt_force:unit_list();
					for j = 0, unit_list:num_items() - 1 do
						local unit_interface = unit_list:item_at(j);
						local unit_key = unit_interface:unit_key();
						local unit_purchasable_effect_list = unit_interface:get_unit_purchasable_effects();
						local unit_purchased_effect_list = unit_interface:get_unit_purchased_effects(); 
						local combo = {};
						--pick up a random mutation combo based on unit
						if flesh_lab_AI_mutation_unit_index[unit_key] ~= nil then
							local rand = cm:random_number(#flesh_lab_AI_mutation_unit_index[unit_key]);
							combo = flesh_lab_AI_mutation_combo[rand];
						end
						-- only happens if the unit doesn't have any mutations currently
						-- only happens if the unit has a combo defined in flesh_lab_AI_mutation_unit_index table
						if unit_purchasable_effect_list:num_items() ~=0 and #combo > 0 and  unit_purchased_effect_list:num_items() ==0 then
							-- Upgrade the unit with mutations from the mutation combo
							for k = 0, all_effects:num_items() - 1 do
								local effect_interface = all_effects:item_at(k);
								local effect = effect_interface:record_key();
								if combo[effect] then
									cm:faction_purchase_unit_effect(unit_interface:faction(), unit_interface, effect_interface);
								end	
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

function skavenslave_augment_application(context)

	local unit = context:unit();

	local list_of_possible_augments = {
		"wh2_dlc16_throt_flesh_lab_inf_aug_0",
		"wh2_dlc16_throt_flesh_lab_inf_aug_1",
		"wh2_dlc16_throt_flesh_lab_inf_aug_2",
		"wh2_dlc16_throt_flesh_lab_inf_aug_3",
		"wh2_dlc16_throt_flesh_lab_inf_aug_6",
		"wh2_dlc16_throt_flesh_lab_inf_aug_7",
		"wh2_dlc16_throt_flesh_lab_inf_aug_8",
		"wh2_dlc16_throt_flesh_lab_inf_aug_9",
		"wh2_dlc16_throt_flesh_lab_inf_aug_10",
		"wh2_dlc16_throt_flesh_lab_inf_aug_11",
		"wh2_dlc16_throt_flesh_lab_inf_aug_12",
		"wh2_dlc16_throt_flesh_lab_inf_aug_13"
	};
	-- 1 guaranteed Augment
	local num_augments = 1;
	--The upgrade gives Skavenslaves between 1 and 5 Augments so we set max_augments to be 4 since 1 is guaranteed
	for i = 1, 4 do
		local rnd = cm:random_number(2);
		if rnd == 1 then
			num_augments = num_augments + 1;
		end
	end
	random_mutation_application(unit, num_augments, list_of_possible_augments);
	
	--Apply the augment to make the units no longer provide Growth Juice when Recycled
	local all_possible_augments = unit:get_unit_purchasable_effects();
	for i = 0, all_possible_augments:num_items() - 1  do
		local effect_interface = all_possible_augments:item_at(i);
		local effect = effect_interface:record_key();
		if effect == "wh2_dlc16_throt_flesh_lab_hidden_augment_refund_cancel" then				
			cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
			break;
		end	
	end

end
--Need to pass this function a unit, and the current instability level of the unit
function upkeep_upgrade_augment_application(unit, instability_level)

	--table of the 4 levels of upkeep reduction based on instability level
	local upkeep_reduction_table = {
		"wh2_dlc16_throt_flesh_lab_hidden_augment_upkeep_reduction",
		"wh2_dlc16_throt_flesh_lab_hidden_augment_upkeep_reduction_2",
		"wh2_dlc16_throt_flesh_lab_hidden_augment_upkeep_reduction_3",
		"wh2_dlc16_throt_flesh_lab_hidden_augment_upkeep_removal"
	};
	
	--Apply the augment to make the units upkeep reduced if it is instable
	local all_possible_augments = unit:get_unit_purchasable_effects();
	for j = 1, instability_level do
		for i = 0, all_possible_augments:num_items() - 1  do
		
			local effect_interface = all_possible_augments:item_at(i);
			local effect = effect_interface:record_key();
			if effect == upkeep_reduction_table[j] then				
				cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
				break;
			end	
		end
	end

end
--Need to pass this function a unit
function ward_save_upgrade_augment_application(unit)
	--Apply the augment to make the units weith 5+ Augments gain Ward save
	local all_possible_augments = unit:get_unit_purchasable_effects();
	for i = 0, all_possible_augments:num_items() - 1  do
		local effect_interface = all_possible_augments:item_at(i);
		local effect = effect_interface:record_key();
		if effect == "wh2_dlc16_throt_flesh_lab_hidden_augment_ward_save" then				
			cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
			break;
		end	
	end
	

end

function random_mutation_application(unit, number_of_augments, list_of_augments)
	
	--Create interface for all possible Augments and already applied Augments
	local all_possible_augments = unit:get_unit_purchasable_effects();
	local all_existing_augments = unit:get_unit_purchased_effects();

	--Apply a hidden augment that makes all other Augments free
	for i = 0, all_possible_augments:num_items() - 1  do
		local effect_interface = all_possible_augments:item_at(i);
		local effect = effect_interface:record_key();
		if effect == "wh2_dlc16_throt_flesh_lab_hidden_augment_cost_reduction" then				
			cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
		end	
	end
	
	local existing_augments = {};
	local num_augments_applied = 0;
	--Loop through the list of possible Augments and create a list of Augments to apply

	--Check what Augments already applied
	for j = 0, all_existing_augments:num_items() - 1  do
		local effect_interface = all_existing_augments:item_at(j);
		local effect = effect_interface:record_key();
		for k = 1, #list_of_augments  do
			if effect == list_of_augments[k] then				
				table.insert(existing_augments, list_of_augments[k]);
			end	
		end	
	end

	--Remove the Augments already applied
	if next(existing_augments) ~= nil then
		for y = 1, #existing_augments do
			local augment_to_remove = existing_augments[y];
			for z = 1, #list_of_augments  do
				if augment_to_remove == list_of_augments[z] then				
					table.remove(list_of_augments, z);
				end	
			end	
		end
	end

	--If list of possible Augments is not empty then loop through possible Augments to randomly apply
	--Loop until number of augments applied is same as number of augments to apply
	while (number_of_augments > num_augments_applied) do
		if next(list_of_augments) ~= nil then
			local rnd = cm:random_number(#list_of_augments);
			local augment = list_of_augments[rnd];

			--Attempt to apply an Augment from the list
			for l = 0, all_possible_augments:num_items() - 1  do
				local effect_interface = all_possible_augments:item_at(l);
				local effect = effect_interface:record_key();
				if effect == augment then				
					cm:faction_purchase_unit_effect(unit:faction(), unit, effect_interface);
					break;
				end	
			end
			--Updatet all existing augments now after attempting to apply another
			all_existing_augments = unit:get_unit_purchased_effects();

			--Check if Augment was applied
			for m = 0, all_existing_augments:num_items() - 1  do
				local effect_interface = all_existing_augments:item_at(m);
				local effect = effect_interface:record_key();
				if effect == augment then				
					num_augments_applied = num_augments_applied + 1;
					break;
				end	
			end
			table.remove(list_of_augments, rnd);
		else
			out.design("\nNo more possible Augments to apply\n")
			num_augments_applied = number_of_augments;
		end
	end

	--Remove the hidden augment that makes all other Augments free
	for n = 0, all_possible_augments:num_items() - 1  do
		local effect_interface = all_possible_augments:item_at(n);
		local effect = effect_interface:record_key();
		if effect == "wh2_dlc16_throt_flesh_lab_hidden_augment_cost_reduction" then				
			cm:faction_unpurchase_unit_effect(unit, effect_interface);
			break;
		end	
	end


	--count how many mutations has already been purchased on the unit
	--we do this here as well because if the unit goes above 4 via a random augment upgrade it does not go through the count check in the Instability_CheckingAndApplying listener since the augment_cost_reduction is still present on unit
	local counter = 0; 
			
	--Count the number of Mutations
	for i = 0, all_existing_augments:num_items() - 1 do
		local effect = all_existing_augments:item_at(i):record_key();

		if flesh_lab_mutation_list["inf"][effect] or flesh_lab_mutation_list["mon"][effect] then
			counter = counter + 1;
		end
	end

	if counter >= 4 then
		--Lab Upgrade Steroid Infusions = wh2_dlc16_throt_flesh_lab_upgrade_7, this gives units a ward save buff if they have 4+ Augments
		if flesh_lab_upgrade_purchased["wh2_dlc16_throt_flesh_lab_upgrade_7"] then
			ward_save_upgrade_augment_application(unit);
		end	
	end


end

--Need to pass function a unit, returns the current instability level of the unit
function get_instability_level(unit)

	local effect_list = unit:get_unit_purchased_effects();

	--Find out what the current highest level of Instability applied to the unit is
	local instability_level = 1;
	for x = 0, effect_list:num_items() - 1 do
		local effect = effect_list:item_at(x):record_key();
		if effect == flesh_lab_negative_mutation_list[1] then
			if instability_level < 2 then
				instability_level = 2;
			end
		elseif effect == flesh_lab_negative_mutation_list[2] then
			if instability_level < 3 then
				instability_level = 3;
			end
		elseif effect == flesh_lab_negative_mutation_list[3] then
			instability_level = 4;
			break;
		end

	end
	return instability_level;
end


--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("flesh_lab_upgrade_purchased", flesh_lab_upgrade_purchased, context);
		cm:save_named_value("flesh_lab_growth_monster_key", flesh_lab_growth_monster_key, context);
		cm:save_named_value("flesh_lab_upgrade_counter", flesh_lab_upgrade_counter, context);
		cm:save_named_value("flesh_lab_mutagen_capacity", flesh_lab_mutagen_capacity, context);	
	end
);
cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			flesh_lab_upgrade_purchased = cm:load_named_value("flesh_lab_upgrade_purchased", flesh_lab_upgrade_purchased, context);
			flesh_lab_growth_monster_key = cm:load_named_value("flesh_lab_growth_monster_key", flesh_lab_growth_monster_key, context);
			flesh_lab_upgrade_counter = cm:load_named_value("flesh_lab_upgrade_counter", flesh_lab_upgrade_counter, context);
			flesh_lab_mutagen_capacity = cm:load_named_value("flesh_lab_mutagen_capacity", flesh_lab_mutagen_capacity, context);
		end
	end
);