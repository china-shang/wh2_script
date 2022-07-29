local deadtharion = false;

function add_eltharion_yvresse_defence_listeners()
    out("#### Adding Eltharion Tor Yvresse Siege Defence Level Listeners ####");

    -- apply effects based on current Tor Yvresse defence level
    core:add_listener(
        "yvresse_defence_level_monitor",
        "PendingBattle",
        function(context)
            local pb = cm:model():pending_battle();
            local defender = pb:defender();

            return pb:seige_battle() == true and (defender:region():name() == "wh2_main_yvresse_tor_yvresse" or defender:region():name() == "wh2_main_vor_northern_yvresse_tor_yvresse");
        end,
        function (context)
            local pb = cm:model():pending_battle();
            local defender = pb:defender();
            local defender_cqi = defender:military_force():command_queue_index();
			local faction = defender:faction();
			local region = defender:region():name();

            if faction:name() == "wh2_main_hef_yvresse" then
                if faction:has_pooled_resource("yvresse_defence") == true then
                    local yvresse_defence = faction:pooled_resource("yvresse_defence"):value();
                    --out(value"####### yvresse defence value found")
                    if yvresse_defence <= 24 then
						cm:pending_battle_add_scripted_tile_upgrade_tag("settlement_level_1")
						out("Tor Yvresse defence level 1 map being loaded!")
					elseif yvresse_defence >= 25 and yvresse_defence <= 49 then
						cm:pending_battle_add_scripted_tile_upgrade_tag("settlement_level_1")
						cm:apply_effect_bundle_to_region("wh2_dlc15_hef_army_abilities_defence_level_1", region, 0)
                        out("Tor Yvresse defence level 1 map being loaded!")
                    elseif yvresse_defence >= 50 and yvresse_defence <= 74 then
						cm:pending_battle_add_scripted_tile_upgrade_tag("settlement_level_2")
						cm:apply_effect_bundle_to_region("wh2_dlc15_hef_army_abilities_defence_level_2", region, 0)
                        out("Tor Yvresse defence level 2 map being loaded!")
                    elseif yvresse_defence >= 75 then
						cm:pending_battle_add_scripted_tile_upgrade_tag("settlement_level_3")
						cm:apply_effect_bundle_to_region("wh2_dlc15_hef_army_abilities_defence_level_3", region, 0)
                        out("Tor Yvresse defence level 3 map being loaded!")
                    end
                end
            else 
                cm:pending_battle_add_scripted_tile_upgrade_tag("settlement_level_3")   -- to ensure a settlement level is still used on this siege map with any other faction
            end
        end,
        true
	);
	-- Apply correct army abilities to Eltharion specific to the level 3 version of the final battle
	core:add_listener(
		"FinalBattleEltharion_ArmyAbilities_deflvl_3",
		"PendingBattle",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key() == "wh2_dlc15_qb_hef_final_battle_eltharion";
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local defender = pb:defender();
			local defender_cqi = defender:military_force():command_queue_index();
				
			out.design("Granting defence level 3 army abilities to defender belonging to " .. defender:faction():name());
				
			cm:apply_effect_bundle_to_force("wh2_dlc15_hef_army_abilities_defence_level_3", defender_cqi, 0);
			
		end,
		true
	);
	-- Apply correct army abilities to Eltharion specific to the level 2 version of the final battle
	core:add_listener(
		"FinalBattleEltharion_ArmyAbilities_deflvl_2",
		"PendingBattle",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key() == "wh2_dlc15_qb_hef_final_battle_eltharion_2";
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local defender = pb:defender();
			local defender_cqi = defender:military_force():command_queue_index();
				
			out.design("Granting defence level 2 army abilities to defender belonging to " .. defender:faction():name());
				
			cm:apply_effect_bundle_to_force("wh2_dlc15_hef_army_abilities_defence_level_2", defender_cqi, 0);
			
		end,
		true
	);
	-- Apply correct army abilities to Eltharion specific to the level 1 version of the final battle
	core:add_listener(
		"FinalBattleEltharion_ArmyAbilities_deflvl_1",
		"PendingBattle",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key() == "wh2_dlc15_qb_hef_final_battle_eltharion_1";
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local defender = pb:defender();
			local defender_cqi = defender:military_force():command_queue_index();
			local faction = defender:faction();
			local yvresse_defence = faction:pooled_resource("yvresse_defence"):value();
			
			if yvresse_defence <= 24 then
				out("Tor Yvresse defence level 0 being loaded! No abilities granted!")
			elseif yvresse_defence >= 25 and yvresse_defence <= 49 then
				out("Tor Yvresse defence level 1 abilities being granted!")
				out.design("Granting defence level 1 army abilities to defender belonging to " .. defender:faction():name());
				cm:apply_effect_bundle_to_force("wh2_dlc15_hef_army_abilities_defence_level_1", defender_cqi, 0);
			end
		end,
		true
	);
	-- player completes the quest battle
	core:add_listener(
		"FinalBattleEltharion_BattleCompleted",
		"BattleCompleted",
		function()
			local pb = cm:model():pending_battle();
			return pb:set_piece_battle_key():find("wh2_dlc15_qb_hef_final_battle_eltharion");
		end,
		function()
			local pb = cm:model():pending_battle();
			
			local defender = pb:defender();
			local char_cqi = false;
			local mf_cqi = false;
			local faction_name = false;
			local has_been_fought = pb:has_been_fought();
			
			if has_been_fought then
				-- if the battle was fought, the defender may have died, so get them from the pending battle cache
				char_cqi, mf_cqi, faction_name = cm:pending_battle_cache_get_defender(1);
			else
				-- if the player retreated, the pending battle cache won't have stored the defender, so get it from the defender character (who should still be alive as they retreated!)
				faction_name = defender:faction():name();
			end;

			-- player has completed Grom Final Battle QB
			if defender then
				-- remove army ability effect bundle
				cm:remove_effect_bundle_from_force("wh2_dlc15_hef_army_abilities_defence_level_3", defender:military_force():command_queue_index());
				cm:remove_effect_bundle_from_force("wh2_dlc15_hef_army_abilities_defence_level_2", defender:military_force():command_queue_index());
				cm:remove_effect_bundle_from_force("wh2_dlc15_hef_army_abilities_defence_level_1", defender:military_force():command_queue_index());
			end;
		end,
		true
	);
	-- add scene surrounding Tor Yvresse based on current defence level
    core:add_listener(
        "yvresse_scenery_monitor",
        "FactionTurnStart",
		true,
		function(context)
			local faction = context:faction();
			if cm:get_faction("wh2_main_hef_yvresse"):is_dead() then
				--return to ruins if Eltharion is dead
				if not deadtharion then
					deadtharion = true;
					cm:remove_scripted_composite_scene("yvresse_scenery");
				end
			elseif faction:name() == "wh2_main_hef_yvresse" then
				deadtharion = false;
				if faction:has_pooled_resource("yvresse_defence") == true then
					update_tor_yvresse_scenery(faction)
				end
			end
		end,
		true
	);
end

-- function for updating the scenery around Tor Yvresse based on current yvresse defence level
function update_tor_yvresse_scenery(faction)
	local yvresse_defence = faction:pooled_resource("yvresse_defence"):value();

	local current_yvresse_cs_level = cm:get_saved_value("current_yvresse_cs_level");
	local should_change = false;

	if yvresse_defence <= 49 and current_yvresse_cs_level ~= 1 then
		should_change = true;
		current_yvresse_cs_level = 1;
	elseif yvresse_defence >= 50 and yvresse_defence <= 74 and current_yvresse_cs_level ~= 2 then
		should_change = true;
		current_yvresse_cs_level = 2;
	elseif yvresse_defence >= 75 and current_yvresse_cs_level ~= 3 then
		should_change = true;
		current_yvresse_cs_level = 3;
	end;

	if should_change then
		cm:set_saved_value("current_yvresse_cs_level", current_yvresse_cs_level);
		cm:remove_scripted_composite_scene("yvresse_scenery");

		local cs_name;
		local settlement_key;

		if cm:model():campaign_name("main_warhammer") then
			cs_name = "hef_tor_yvresse_me_0" .. current_yvresse_cs_level;
			settlement_key = "settlement:wh2_main_yvresse_tor_yvresse";
		else
			cs_name = "hef_tor_yvresse_0" .. current_yvresse_cs_level;
			settlement_key = "settlement:wh2_main_vor_northern_yvresse_tor_yvresse";
		end;

		out("* update_tor_yvresse_scenery is updating scenery of " .. settlement_key .. " with composite scene " .. cs_name);
		cm:add_scripted_composite_scene_to_settlement("yvresse_scenery", cs_name, settlement_key, 0, 0, false, true, false);
	end;
end