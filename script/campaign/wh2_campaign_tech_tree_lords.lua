local tech_tree_lords = {
	-- Raknik Spiderclaw
	["tech_grn_mid_1_1"] = {forename = "names_name_385074324", surname = "names_name_464146333", subtype = "wh2_dlc15_grn_goblin_great_shaman_raknik", immortal = true},
	-- Oglok the 'Orrible
	["tech_grn_mid_2_1"] = {forename = "names_name_340548085", surname = "names_name_1551329109", subtype = "wh2_dlc15_grn_orc_warboss_oglok", immortal = true}
};

function add_tech_tree_lords_listeners()
	out("#### Adding Tech Tree Lords Listeners ####");
	core:add_listener(
		"TechTreeLords_ResearchCompleted",
		"ResearchCompleted",
		true,
		function(context)
			TechTreeLords_ResearchCompleted(context);
		end,
		true
	);
end

function TechTreeLords_ResearchCompleted(context)
	local faction = context:faction();
	local tech_key = context:technology();
	
	if faction:is_human() == true then
		local lord = tech_tree_lords[tech_key];
		
		if lord ~= nil then
			local faction_key = faction:name();
			cm:spawn_character_to_pool(faction_key, lord.forename, lord.surname, "", "", 30, true, "general", lord.subtype, lord.immortal, "");
		end
	end
end