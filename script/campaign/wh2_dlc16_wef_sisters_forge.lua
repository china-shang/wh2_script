local m_sisters_faction_key = "wh2_dlc16_wef_sisters_of_twilight"
local m_sisters_forge_skill_key = "wh2_dlc16_wef_sisters_unique_6"
local m_sisters_forename = "names_name_786577931"
local m_forge_resource_key = "wef_forge_daiths_favour"
local m_forge_resource_factor_key = "wh2_dlc13_resource_factor_battles"

local m_reforge_duration = 5

local m_forge_skill_owned = false

local m_forge_button_active = false

local m_daiths_favour = 0
local m_daiths_favour_additional_chance = 1
local m_current_favour_cooldown = 0
local m_favour_cooldown = 1

local m_forge_items = {
    -- item_table_keys
    "dragon_cuirass",
    "eagle_vambraces",
    "dreaming_boots",
    "twilight_helm",
    "dragon_pendant",
    "dreaming_cloak",
    "eagle_quiver",
    "twilight_standard",
    "dragon_mask",
    "dreaming_ring",
    "eagle_mask",
    "twilight_horn",
    "dragon_spear",
    "dreaming_bow",
    "eagle_bow",
    "twilight_spear",

    -- level 0 = unowned
    ["dragon_cuirass"] = {level = 0, upgrade_level = 0, type = "armour", key = "wh2_dlc16_anc_armour_dragon_cuirass_", reforge_timer = 0},
    ["eagle_vambraces"] = {level = 0, upgrade_level = 0, type = "armour", key = "wh2_dlc16_anc_armour_eagle_vambraces_", reforge_timer = 0},
    ["dreaming_boots"] = {level = 0, upgrade_level = 0, type = "armour", key = "wh2_dlc16_anc_armour_dreaming_boots_", reforge_timer = 0},
    ["twilight_helm"] = {level = 0, upgrade_level = 0, type = "armour", key = "wh2_dlc16_anc_armour_twilight_helm_", reforge_timer = 0},

    ["dragon_pendant"] = {level = 0, upgrade_level = 0, type = "enchanted_item", key = "wh2_dlc16_anc_enchanted_item_dragon_pendant_", reforge_timer = 0},
    ["dreaming_cloak"] = {level = 0, upgrade_level = 0, type = "enchanted_item", key = "wh2_dlc16_anc_enchanted_item_dreaming_cloak_", reforge_timer = 0},
    ["eagle_quiver"] = {level = 0, upgrade_level = 0, type = "enchanted_item", key = "wh2_dlc16_anc_enchanted_item_eagle_quiver_", reforge_timer = 0},
    ["twilight_standard"] = {level = 0, upgrade_level = 0, type = "enchanted_item", key = "wh2_dlc16_anc_enchanted_item_twilight_standard_", reforge_timer = 0},

    ["dragon_mask"] = {level = 0, upgrade_level = 0, type = "talisman", key = "wh2_dlc16_anc_talisman_dragon_mask_", reforge_timer = 0},
    ["dreaming_ring"] = {level = 0, upgrade_level = 0, type = "talisman", key = "wh2_dlc16_anc_talisman_dreaming_ring_", reforge_timer = 0},
    ["eagle_mask"] = {level = 0, upgrade_level = 0, type = "talisman", key = "wh2_dlc16_anc_talisman_eagle_mask_", reforge_timer = 0},
    ["twilight_horn"] = {level = 0, upgrade_level = 0, type = "talisman", key = "wh2_dlc16_anc_talisman_twilight_horn_", reforge_timer = 0},

    ["dragon_spear"] = {level = 0, upgrade_level = 0, type = "weapon", key = "wh2_dlc16_anc_weapon_dragon_spear_", reforge_timer = 0},
    ["dreaming_bow"] = {level = 0, upgrade_level = 0, type = "weapon", key = "wh2_dlc16_anc_weapon_dreaming_bow_", reforge_timer = 0},
    ["eagle_bow"] = {level = 0, upgrade_level = 0, type = "weapon", key = "wh2_dlc16_anc_weapon_eagle_bow_", reforge_timer = 0},
    ["twilight_spear"] = {level = 0, upgrade_level = 0, type = "weapon", key = "wh2_dlc16_anc_weapon_twilight_spear_", reforge_timer = 0}
}

local function update_daiths_favour()
    if(m_daiths_favour < 0) then
        m_daiths_favour = 0
    end
    
    --effect.set_context_value("forge_of_daith_turns", m_daiths_favour)
end

local function update_reforge_icons()
    -- Items need to be cleared each time, then sorted based on remaining cooldown so they display in a consistent order.
    local temp = {}
    local uic_root = core:get_ui_root()
    local uic_forge_button = UIComponent(uic_root:Find("forge_of_daith"))

    for k, v in ipairs(m_forge_items) do
        local val = m_forge_items[v]
        
		if(val.reforge_timer > 0) then
			local temp_values = {v, val.reforge_timer}
			table.insert(temp, temp_values)
		end
	end
	
	-- Sorts temp based off the remaining forge timer of each item.
	table.sort(temp, 
		function(a, b)
			return a[2] < b[2]
		end
	)

    uic_forge_button:InterfaceFunction("ClearItems")

	for k, v in ipairs(temp) do
		local table_key = v[1]
        local item_key = m_forge_items[table_key].key..m_forge_items[table_key].level
        local reforge_timer = m_forge_items[table_key].reforge_timer

        uic_forge_button:InterfaceFunction("AddItem", item_key, reforge_timer)
    end
end

local function sisters_in_game_check()
    if(cm:is_new_game()) then
        if(cm:general_with_forename_exists_in_faction_with_force(m_sisters_faction_key, m_sisters_forename)) then
			local is_human = cm:get_faction(m_sisters_faction_key):is_human()
			
            cm:set_saved_value("sisters_starting_lord", true)
            update_daiths_favour()

            return true, is_human
        else
            cm:set_saved_value("sisters_starting_lord", false)
        end
    elseif(cm:get_saved_value("sisters_starting_lord")) then
		local is_human = cm:get_faction(m_sisters_faction_key):is_human()
		
		update_daiths_favour()
		
        update_reforge_icons()

        return true, is_human
    end

    return false
end

local function check_if_forge_item_owned(item_table_key)
    if(m_forge_items[item_table_key] ~= nil and m_forge_items[item_table_key].level > 0) then
        return true
    else
        return falsessa
    end
end

local function adjust_daiths_favour(amount)
    m_daiths_favour = m_daiths_favour + amount
    
	cm:faction_add_pooled_resource(m_sisters_faction_key, m_forge_resource_key, m_forge_resource_factor_key, amount)
	
	out("daiths favour: "..m_daiths_favour)

    update_daiths_favour()
end

local function remove_forge_item(item_key)
    -- remove item from faction/character, if removed from a character it returns that characters cqi
    local character
    local character_cqi
    local item_found = false
    local faction = cm:get_faction(m_sisters_faction_key)
    local character_list = faction:character_list()

    for i = 0, (character_list:num_items() - 1) do
        character = character_list:item_at(i)
		if(character:has_ancillary(item_key)) then
            item_found = true
            break
        end
    end

    cm:force_remove_ancillary_from_faction(faction, item_key)

    if(item_found) then
        return character
    else
        return false
    end
end

local function replace_forge_item(item_key, new_item_key)
    -- removes an item, and replaces it back onto the character it was on, or back to the item pool if unequipped.
	local character = remove_forge_item(item_key)
	
	-- remove the version of the item that was added from the dilemma.
	remove_forge_item(new_item_key)

	if(character and character:is_wounded() == false) then
        cm:force_add_ancillary(character, new_item_key, false, true)
	else
        local sister_faction = cm:get_faction(m_sisters_faction_key)
        cm:add_ancillary_to_faction(sister_faction, new_item_key, true)
    end
end

local function remove_reforge_status_from_item(item_table_id)
    local item = m_forge_items[item_table_id]

	if(item.level == 4 and item.reforge_timer == 0) then
		if(item.upgrade_level == 0) then
			-- This checks for games with older saves from before the 1st patch which didn't have this set yet. 
			-- Will revert the item back to lvl 1, which isn't ideal but at least the item isn't deleted.
			item.upgrade_level = 1
		end
        item.level = item.upgrade_level
        replace_forge_item(item.key.."4", item.key..item.level)
    end
end

local function reforge_forge_item(item_table_id)
    local item = m_forge_items[item_table_id]

    if(item.level ~= 4) then
        replace_forge_item(item.key..item.level, item.key.."4")
        item.upgrade_level = item.level
        item.level = 4
    end

    item.reforge_timer = m_reforge_duration

    update_reforge_icons()
end

local function upgrade_forge_item(item_table_id)
    local item = m_forge_items[item_table_id]
    if(item.level == 0 or item.level == 1 or item.level == 2) then
        replace_forge_item(item.key..item.level, item.key..(item.level + 1))
		item.level = item.level + 1
		item.upgrade_level = item.level
    end
end

local function grant_favour_after_sister_battle_listener()
    core:add_listener(
        "Sisters_BattleFavourGain",
        "CharacterCompletedBattle",
		function(context)
			local character = context:character()
			local character_forename = character:get_forename()
			local battle_won = character:won_battle()

            if(character_forename == m_sisters_forename and battle_won == true and m_current_favour_cooldown <= 0 and m_forge_button_active == false) then
                return true
            end
            return false
        end,
		function(context)
			local additional_chance = cm:random_number(m_daiths_favour_additional_chance, 1)
			m_current_favour_cooldown = 1
            if(additional_chance == 3) then
                adjust_daiths_favour(2)
            else
                adjust_daiths_favour(1)
            end
        end,
        true
    )
end

local function grant_favour_after_sister_reinforcement_battle_listener()
    core:add_listener(
        "Sisters_ReinforcementFavourGain",
        "CharacterParticipatedAsSecondaryGeneralInBattle",
        function(context)
            local character = context:character()
			local character_forename = character:get_forename()
			local battle_won = character:won_battle()

            if(character_forename == m_sisters_forename and battle_won == true and m_current_favour_cooldown <= 0 and m_forge_button_active == false) then
                return true
            end
            return false
        end,
        function(context)
			local additional_chance = cm:random_number(m_daiths_favour_additional_chance, 1)
			m_current_favour_cooldown = 1
            if(additional_chance == 3) then
                adjust_daiths_favour(2)
			else
                adjust_daiths_favour(1)
            end
        end,
        true
    )
end

local function unlock_favour_gain_listener()
    -- Unlock forge at the end of each turn, so that if the sisters are attacked during the turn cycle the forge can be active as the new turn starts.
    core:add_listener(
        "Sisters_FavourGainUnlock",
        "FactionTurnEnd",
        function(context)
            local faction_name = context:faction():name()
            if(faction_name == m_sisters_faction_key) then
                return true
            end
            return false
        end,
		function(context)
			if(m_current_favour_cooldown > 0) then
				m_current_favour_cooldown = m_current_favour_cooldown - 1
			end
        end,
        true
    )
end

local function reforge_timer_listener()
    core:add_listener(
        "Sisters_ReforgeTimer",
        "FactionTurnStart",
        function(context)
            local faction_name = context:faction():name()
            if(faction_name == m_sisters_faction_key) then
                return true
            end
            return false
        end,
        function(context)
            for k, v in ipairs(m_forge_items) do
                local val = m_forge_items[v]
                -- checks if item is currently reforged & timed out before removing status
                if(val.reforge_timer > 0) then
                    val.reforge_timer = val.reforge_timer - 1
				end
				
                remove_reforge_status_from_item(v)
            end

            update_reforge_icons()
        end,
        true
    )
end

local function forge_skill_upgrade_listener()
    core:add_listener(
        "Sisters_ForgeSkillUpgrade",
        "CharacterSkillPointAllocated",
        function(context)
            return context:skill_point_spent_on() == m_sisters_forge_skill_key
        end,
        function(context)
            m_daiths_favour_additional_chance = 3
            m_forge_skill_owned = true
        end,
        false
    )
end

local function forge_ritual_completed_listener()
    core:add_listener(
        "Sisters_ForgeRitualCompleted",
        "RitualCompletedEvent",
        function(context)
            local ritual_key = context:ritual():ritual_key()

            if(string.match(ritual_key, "wh2_dlc16_ritual_wef_forge")) then
                return true
            end

            return false
        end,
        function(context)
            local ritual_key = context:ritual():ritual_key()
            local item_table_key = string.match(ritual_key, "forge_(.*)_level")
            local ritual_level = string.match(ritual_key, "level_(.*)")

            cm:callback(function()
                if(ritual_level == "2" or ritual_level == "3") then
                    upgrade_forge_item(item_table_key)
                elseif(ritual_level == "4") then
                    reforge_forge_item(item_table_key)
				elseif(ritual_level == "1") then
					local reforge_ritual_key = "wh2_dlc16_ritual_wef_forge_"..item_table_key.."_level_4"
					local faction = cm:get_faction(m_sisters_faction_key)
                    cm:unlock_ritual(faction, reforge_ritual_key, 0)
					m_forge_items[item_table_key].level = 1
				end
            end, 0.5)
        end,
        true
    )
end

local function forge_ai_behaviour_listener()
    core:add_listener(
        "Sisters_AiBehaviour",
        "FactionTurnStart",
        function(context)
            local faction_name = context:faction():name()
            if(faction_name == m_sisters_faction_key) then
                return true
            end
        end,
        function(context)
			local turn_number = context:faction():model():turn_number()
			
			if(turn_number == 10) then
				-- gives AI all the base level forge items
				for k, v in ipairs(m_forge_items) do
					upgrade_forge_item(v)
				end
			elseif(turn_number == 50) then
				-- Upgrades all forge items to lvl 2
				for k, v in ipairs(m_forge_items) do
					upgrade_forge_item(v)
				end
			elseif(turn_number == 100) then
				-- Upgrades all forge items to lvl 3
				for k, v in ipairs(m_forge_items) do
					upgrade_forge_item(v)
				end
			end
        end,
        true
    )
end

function add_sisters_forge_listeners()
    local sisters_in_game, is_human = sisters_in_game_check()

    if(sisters_in_game == true and is_human == true) then
        -- Player behaviour
        grant_favour_after_sister_battle_listener()
        grant_favour_after_sister_reinforcement_battle_listener()
        forge_ritual_completed_listener()
        forge_skill_upgrade_listener()
        unlock_favour_gain_listener()
        reforge_timer_listener()
    elseif(sisters_in_game == true and is_human == false) then
		-- AI behaviour
        forge_ai_behaviour_listener()
    end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------

cm:add_saving_game_callback(
    function(context)
		cm:save_named_value("sisters_forge_items", m_forge_items, context)
        cm:save_named_value("sisters_reforge_duration", m_reforge_duration, context)
		cm:save_named_value("sisters_forge_button_active", m_forge_button_active, context)
		cm:save_named_value("sisters_forge_skill_owned", m_forge_skill_owned, context)
        cm:save_named_value("sisters_current_forge_cooldown", m_current_favour_cooldown, context)
        cm:save_named_value("sisters_daiths_favour", m_daiths_favour, context)
        cm:save_named_value("sisters_daiths_favour_earn_limit", m_daiths_favour_additional_chance, context)
	end
)

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
            m_forge_items = cm:load_named_value("sisters_forge_items", m_forge_items, context)
            m_reforge_duration = cm:load_named_value("sisters_reforge_duration", m_reforge_duration, context)
			m_forge_button_active = cm:load_named_value("sisters_forge_button_active", m_forge_button_active, context)
			m_forge_skill_owned = cm:load_named_value("sisters_forge_skill_owned", m_forge_skill_owned, context)
            m_current_favour_cooldown = cm:load_named_value("sisters_current_forge_cooldown", m_current_favour_cooldown, context)
            m_daiths_favour = cm:load_named_value("sisters_daiths_favour", m_daiths_favour, context)
            m_daiths_favour_additional_chance = cm:load_named_value("sisters_daiths_favour_earn_limit", m_daiths_favour_additional_chance, context)
		end
	end
)