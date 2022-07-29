local vlad_forename = "names_name_2147345130";
local isabella_forename = "names_name_2147345124";
local schwartzhafen_faction_name = "wh_main_vmp_schwartzhafen";
local bundle_name = "wh_pro02_undying_love_bundle";

function add_vlad_isabella_listeners()	
	-- lock the conderation options for rival vampire counts
	cm:force_diplomacy("faction:wh_main_vmp_rival_sylvanian_vamps", "faction:wh_main_vmp_vampire_counts", "form confederation", false, false, true);
	cm:force_diplomacy("faction:wh_main_vmp_rival_sylvanian_vamps", "faction:wh_main_vmp_schwartzhafen", "form confederation", false, false, true);
	
	-- apply the effect bundle
	core:add_listener(
		"apply_couple_bundle_on_pending_battle",
		"PendingBattle",
		function(context)
			local pb = context:pending_battle();
			
			return pb:attacker():faction():name() == schwartzhafen_faction_name or pb:defender():faction():name() == schwartzhafen_faction_name;
		end,
		function(context)
			--reset any previous battles
			remove_undying_love_bundle();
			add_undying_love_bundle(context);
		end,
		true
	);
	
	-- remove the effect bundle
	core:add_listener(
		"remove_bundle_post_battle",
		"BattleCompleted",
		function()
			local pb = cm:model():pending_battle();
			
			return (pb:has_attacker() and pb:attacker():faction():name() == schwartzhafen_faction_name) or (pb:has_defender() and pb:defender():faction():name() == schwartzhafen_faction_name);
		end,
		function()
			remove_undying_love_bundle();
		end,
		true
	);
	
	cm:add_faction_turn_start_listener_by_name(
		"remove_bundle_start_turn",
		schwartzhafen_faction_name,
		function(context)
			remove_undying_love_bundle();
		end,
		true
	);
end;

function add_undying_love_bundle(context)
	local pb = context:pending_battle();
	local all_attackers = {pb:attacker()};
	local all_defenders = {pb:defender()};
	local reinforce_attackers = pb:secondary_attackers();
	local reinforce_defenders = pb:secondary_defenders();
	local couple_cqi = {};
	
	if reinforce_attackers:num_items() >= 1 then
		for i = 0, reinforce_attackers:num_items() - 1 do
			table.insert(all_attackers, reinforce_attackers:item_at(i));
		end;
	end;
	
	if reinforce_defenders:num_items() >= 1 then
		for i = 0, reinforce_defenders:num_items() - 1 do
			table.insert(all_defenders, reinforce_defenders:item_at(i));
		end;
	end;
	
	for i = 1, #all_attackers do
		local current_attacker = all_attackers[i];
		
		if current_attacker:get_forename() == vlad_forename or current_attacker:get_forename() == isabella_forename then
			table.insert(couple_cqi, current_attacker:military_force():command_queue_index());
		end;
	end;
	
	for i = 1, #all_defenders do
		local current_defender = all_defenders[i];
		
		if current_defender:get_forename() == vlad_forename or current_defender:get_forename() == isabella_forename then
			table.insert(couple_cqi, current_defender:military_force():command_queue_index());
		end;
	end;
	
	if #couple_cqi >= 2 then
		for i = 1, 2 do
			cm:apply_effect_bundle_to_force(bundle_name, couple_cqi[i], 0);
		end;
	end;
end;

function remove_undying_love_bundle()
	local faction = cm:get_faction(schwartzhafen_faction_name);
	local char_list = faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		if (current_char:get_forename() == vlad_forename or current_char:get_forename() == isabella_forename) and current_char:has_military_force() then
			local mf = current_char:military_force();
			
			if mf:has_effect_bundle(bundle_name) then
				cm:remove_effect_bundle_from_force(bundle_name, mf:command_queue_index());
			end;
		end;
	end;
end;