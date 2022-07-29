local chaos_player_personality_swap_turn = 30;

core:add_listener(
	"Chaos_FactionBecomesLiberationVassal",
	"FactionBecomesLiberationVassal",
	function(context)
		return context:liberating_character():faction():name() == "wh_main_chs_chaos";
	end,
	function(context)
		local faction_name = context:faction():name();
		cm:force_make_vassal("wh_main_chs_chaos", faction_name);
		cm:force_diplomacy("faction:" .. faction_name, "faction:wh_main_chs_chaos", "war", false, false, false);
	end,
	true
);


core:add_listener(
	"character_completed_battle_chaos_personality_change",
	"CharacterCompletedBattle",
	true,
	function (context)
		local character = context:character();
		local faction = character:faction();
		
		if cm:char_is_general_with_army(character) and character:won_battle() and faction:is_human() and faction:subculture() == "wh_main_sc_chs_chaos" then
			local enemies = cm:pending_battle_cache_get_enemies_of_char(character);
			
			for i = 1, #enemies do
				local enemy = enemies[i];
				
				if enemy ~= nil and enemy:is_null_interface() == false then
					local enemy_faction = enemy:faction();
					
					if enemy:is_faction_leader() and enemy_faction:subculture() == "wh_main_sc_nor_norsca" then
						out("Changing Norscan personality after faction leader defeated (by Chaos): "..enemy_faction:name());
						cm:force_change_cai_faction_personality(enemy_faction:name(), "wh_dlc08_norsca_vassalized");
					end
				end
			end
		end
	end,
	true
);

core:add_listener(
	"chaos_player_turn_number",
	"FactionTurnStart",
	function(context)
		local turn_number = cm:model():turn_number();

		if turn_number == chaos_player_personality_swap_turn then
			local faction_key = context:faction():name();

			if faction_key == "wh_main_chs_chaos" then
				return true;
			end
		end
		return false;
	end,
	function()
		local faction_list = cm:model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			
			if faction:is_human() == false then
				if faction:subculture() == "wh_main_sc_nor_norsca" then
					break;
				end
				
				local faction_name = faction:name();
				cm:cai_force_personality_change(faction_name);
			end
		end
	end,
	true
);