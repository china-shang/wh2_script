
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	LEGENDARY LORDS
--	This script unlocks legendary lords on bespoke triggers
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- unlock starting generals for the AI - ensure that these are in the start pos but NOT on the map!
-- note: we unlock Chaos legendary lords through the Chaos Invasion script
-- this gets called in wh_start
function unlock_ai_starting_generals()
	out.design("Legendary Lords -- Turn number reached, unlocking non-faction leader legendary lords for the AI");
	out.design("###############################################");
	
	local ai_starting_generals = {
		{["id"] = "2140783648",	["forename"] = "names_name_2147343922",	["faction"] = "wh_main_emp_empire"},			-- Balthasar Gelt
		{["id"] = "2140783608",	["forename"] = "names_name_2147344414",	["faction"] = "wh_main_dwf_dwarfs"},			-- Ungrim Ironfist
		{["id"] = "2140784160",	["forename"] = "names_name_2147358917",	["faction"] = "wh_main_dwf_dwarfs"},			-- Grombrindal
		{["id"] = "2140783606",	["forename"] = "names_name_2147345906",	["faction"] = "wh_main_grn_greenskins"},		-- Azhag the Slaughterer
		{["id"] = "2140783651",	["forename"] = "names_name_2147345320",	["faction"] = "wh_main_vmp_vampire_counts"},	-- Heinrich Kemmler
		{["id"] = "2140784127",	["forename"] = "names_name_2147357619",	["faction"] = "wh_dlc03_bst_beastmen"},			-- Malagor
		{["id"] = "2140784189",	["forename"] = "names_name_2147352897",	["faction"] = "wh_dlc03_bst_beastmen"},			-- Morghur
		{["id"] = "2140784136",	["forename"] = "names_name_2147358013",	["faction"] = "wh_main_emp_empire"},			-- Volkmar the Grim
		{["id"] = "2140784138",	["forename"] = "names_name_2147345130",	["faction"] = "wh_main_vmp_vampire_counts"},	-- Vlad von Carstein
		{["id"] = "2140784146",	["forename"] = "names_name_2147358044",	["faction"] = "wh_main_vmp_vampire_counts"},	-- Helman Ghorst
		{["id"] = "2140784202",	["forename"] = "names_name_2147345124",	["faction"] = "wh_main_vmp_schwartzhafen"}		-- Isabella von Carstein
	};
	
	for i = 1, #ai_starting_generals do
		local faction = cm:get_faction(ai_starting_generals[i].faction);
		
		if not faction:is_human() then
			out.design("Unlocking legendary lord with forename [" .. ai_starting_generals[i].forename .. "] for AI faction [" .. ai_starting_generals[i].faction .. "]");
			cm:unlock_starting_general_recruitment(ai_starting_generals[i].id, ai_starting_generals[i].faction);
		end;
	end;
	
	out.design("###############################################");
end;

-- load the listeners for every human faction
function ll_setup()
	local emp = cm:get_faction("wh_main_emp_empire")
	
	if emp:is_human() then
		for i = 1, #ll_empire do
			ll_empire[i]:start();
		end;
	end;
	
	local dwf = cm:get_faction("wh_main_dwf_dwarfs")
	
	if dwf:is_human() then
		for i = 1, #ll_dwarfs do
			ll_dwarfs[i]:start();
		end;
	end;
	
	local grn = cm:get_faction("wh_main_grn_greenskins")
	
	if grn:is_human() then
		for i = 1, #ll_greenskins do
			ll_greenskins[i]:start();
		end;
	end;
	
	local vmp = cm:get_faction("wh_main_vmp_vampire_counts")
	
	if vmp:is_human() then
		for i = 1, #ll_vampire_counts do
			ll_vampire_counts[i]:start();
		end;
	end;
	
	local chs = cm:get_faction("wh_main_chs_chaos")
	
	if chs:is_human() then
		for i = 1, #ll_chaos do
			ll_chaos[i]:start();
		end;
	end;
	
	local bst = cm:get_faction("wh_dlc03_bst_beastmen")
	
	if bst and bst:is_human() then
		for i = 1, #ll_beastmen do
			ll_beastmen[i]:start();
		end;
	end;
	
	local schwartzhafen = cm:get_faction("wh_main_vmp_schwartzhafen")
	
	if schwartzhafen and schwartzhafen:is_human() then
		for i = 1, #ll_schwartzhafen do
			ll_schwartzhafen[i]:start();
		end;
	end;
end;


-------------------------------------------------------
--	Vampire Counts
-------------------------------------------------------

ll_vampire_counts = {
	-- Mannfred von Carstein
	ll_unlock:new(
		"wh_main_vmp_vampire_counts",
		"2140782847",
		"names_name_2147343886",
		"FactionRoundStart",
		function(context)
			local faction = context:faction();
			if cm:model():is_multiplayer() then
				return faction:holds_entire_province("wh_main_eastern_sylvania", true);
			else
				return faction:holds_entire_province("wh_main_eastern_sylvania", true) and faction:holds_entire_province("wh_main_western_sylvania", true);
			end
		end
	),

	-- Heinrich Kemmler
	ll_unlock:new(
		"wh_main_vmp_vampire_counts",
		"2140783651",
		"names_name_2147345320",
		"BuildingCompleted",
		function(context)
			local building = context:building();
			return building:name() == "wh_main_vmp_necromancers_1" and building:faction():name() == "wh_main_vmp_vampire_counts";
		end
	),

	-- Heinrich Kemmler - alternate method
	ll_unlock:new(
		"wh_main_vmp_vampire_counts",
		"2140783651",
		"names_name_2147345320",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_vmp_vampire_counts" and (context:garrison_residence():region():building_exists("wh_main_vmp_necromancers_1") or context:garrison_residence():region():building_exists("wh_main_vmp_necromancers_2"));
		end
	),

	
	
	-- Helman Ghorst
	ll_unlock:new(
		"wh_main_vmp_vampire_counts",
		"2140784146",
		"names_name_2147358044",
		"CharacterPostBattleEnslave",
		function(context)
			if context:character():faction():name() == "wh_main_vmp_vampire_counts" then
				local enslave_count = cm:get_saved_value("ll_vampire_counts_helman_enslave_count");
				if enslave_count == nil then enslave_count = 0 end;
				
				enslave_count = enslave_count + 1;
				
				cm:set_saved_value("ll_vampire_counts_helman_enslave_count", enslave_count);
				
				return enslave_count > 9;
			end;
		end
	)
};

ll_schwartzhafen = {
	-- Vlad von Carstein
	ll_unlock:new(
		"wh_main_vmp_schwartzhafen",
		"2140784138",
		"names_name_2147345130",
		"FactionTurnStart",
		function(context)
			return context:faction():name() == "wh_main_vmp_schwartzhafen" and cm:model():turn_number()==1;
		end
	),
	
	-- Isabella von Carstein
	ll_unlock:new(
		"wh_main_vmp_schwartzhafen",
		"2140784202",
		"names_name_2147345124",
		"FactionTurnStart",
		function(context)
			return context:faction():name() == "wh_main_vmp_schwartzhafen" and cm:model():turn_number()==1;
		end
	)
	
};


-------------------------------------------------------
--	Greenskins
-------------------------------------------------------

ll_greenskins = {
	-- Grimgor Ironhide
	ll_unlock:new(
		"wh_main_grn_greenskins",
		"2140782841",
		"names_name_2147343863",
		"CharacterPostBattleSlaughter",
		function(context)
			if context:character():faction():name() == "wh_main_grn_greenskins" then
				local slaughter_count = cm:get_saved_value("ll_greenskins_grimgor_slaughter_count");
				if slaughter_count == nil then slaughter_count = 0 end;
				
				slaughter_count = slaughter_count + 1;
				
				cm:set_saved_value("ll_greenskins_grimgor_slaughter_count", slaughter_count);
				
				return slaughter_count > 9;
			end;
		end
	),

	-- Azhag the Slaughterer
	ll_unlock:new(
		"wh_main_grn_greenskins",
		"2140783606",
		"names_name_2147345906",
		"BuildingCompleted",
		function(context)
			local building = context:building();
			return building:name() == "wh_main_grn_shaman_1" and building:faction():name() == "wh_main_grn_greenskins";
		end
	),

	-- Azhag the Slaughterer - alternate method
	ll_unlock:new(
		"wh_main_grn_greenskins",
		"2140783606",
		"names_name_2147345906",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_grn_greenskins" and (context:garrison_residence():region():building_exists("wh_main_grn_shaman_1") or context:garrison_residence():region():building_exists("wh_main_grn_shaman_2"));
		end
	)
};



-------------------------------------------------------
--	Empire
-------------------------------------------------------

ll_empire = {
	-- Karl Franz
	ll_unlock:new(
		"wh_main_emp_empire",
		"2140783388",
		"names_name_2147343849",
		"FactionJoinsConfederation",
		function(context)
			return context:confederation():name() == "wh_main_emp_empire";
		end
	),

	-- Balthasar Gelt
	ll_unlock:new(
		"wh_main_emp_empire",
		"2140783648",
		"names_name_2147343922",
		"BuildingCompleted",
		function(context)
			local building = context:building();
			return building:name() == "wh_main_special_conclave_of_magic" and building:faction():name() == "wh_main_emp_empire";
		end
	),

	-- Balthasar Gelt - alternate method
	ll_unlock:new(
		"wh_main_emp_empire",
		"2140783648",
		"names_name_2147343922",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_emp_empire" and context:garrison_residence():region():building_exists("wh_main_special_conclave_of_magic");
		end
	),

	-- Volkmar the Grim
	ll_unlock:new(
		"wh_main_emp_empire",
		"2140784136",
		"names_name_2147358013",
		"BuildingCompleted",
		function(context)
			local building = context:building();
			return building:name() == "wh_main_emp_worship_2" and building:faction():name() == "wh_main_emp_empire";
		end
	),

	-- Volkmar the Grim - alternate method
	ll_unlock:new(
		"wh_main_emp_empire",
		"2140784136",
		"names_name_2147358013",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_emp_empire" and context:garrison_residence():region():building_exists("wh_main_emp_worship_2");
		end
	)
};



-------------------------------------------------------
--	Dwarfs
-------------------------------------------------------

ll_dwarfs = {
	-- Thorgrim Grudgebearer
	ll_unlock:new(
		"wh_main_dwf_dwarfs",
		"2140782828",
		"names_name_2147343883",
		"MissionSucceeded",
		function(context)
			if context:faction():name() == "wh_main_dwf_dwarfs" then
				local grudge_count = cm:get_saved_value("ll_dwarfs_thorgrim_grudge_count");
				if grudge_count == nil then grudge_count = 0 end;
				
				local mission = context:mission():mission_record_key();
				
				if string.find(mission, "_grudge_") or string.find(mission, "_prelude_") then
					grudge_count = grudge_count + 1;
					
					cm:set_saved_value("ll_dwarfs_thorgrim_grudge_count", grudge_count);
				end;
				
				return grudge_count > 7;
			end;
		end
	),

	-- Ungrim Ironfist
	ll_unlock:new(
		"wh_main_dwf_dwarfs",
		"2140783608",
		"names_name_2147344414",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_dwf_dwarfs" and context:garrison_residence():region():name() == "wh_main_peak_pass_karak_kadrin";
		end
	),

	-- Ungrim Ironfist - alternate method
	ll_unlock:new(
		"wh_main_dwf_dwarfs",
		"2140783608",
		"names_name_2147344414",
		"FactionJoinsConfederation",
		function(context)
			local region = cm:get_region("wh_main_peak_pass_karak_kadrin");
			return region:owning_faction() == context:confederation();
		end
	),

	-- Grombrindal
	ll_unlock:new(
		"wh_main_dwf_dwarfs",
		"2140784160",
		"names_name_2147358917",
		"BuildingCompleted",
		function(context)
			local building = context:building();
			return building:name() == "wh_main_dwf_slayer_2" and building:faction():name() == "wh_main_dwf_dwarfs";
		end
	),

	-- Grombrindal - alternate method
	ll_unlock:new(
		"wh_main_dwf_dwarfs",
		"2140784160",
		"names_name_2147358917",
		"GarrisonOccupiedEvent",
		function(context)
			return context:character():faction():name() == "wh_main_dwf_dwarfs" and context:garrison_residence():region():building_exists("wh_main_dwf_slayer_2");
		end
	)
};


-------------------------------------------------------
--	Chaos
-------------------------------------------------------

ll_chaos = {
	-- Archaon the Everchosen
	ll_unlock:new(
		"wh_main_chs_chaos",
		"2140782858",
		"names_name_2147343903",
		"CharacterPostBattleRelease",
		function(context)
			if context:character():faction():name() == "wh_main_chs_chaos" then
				local release_count = cm:get_saved_value("ll_chaos_archaon_release_count");
				if release_count == nil then release_count = 0 end;
				
				release_count = release_count + 1;
				
				cm:set_saved_value("ll_chaos_archaon_release_count", release_count);
				
				return release_count > 9;
			end;
		end
	),

	-- Prince Sigvald the Magnificent
	ll_unlock:new(
		"wh_main_chs_chaos",
		"2140783662",
		"names_name_2147345922",
		"FactionLiberated",
		function(context)
			if context:liberating_character():faction():name() == "wh_main_chs_chaos" then
				local tribe_count = cm:get_saved_value("ll_chaos_sigvald_tribe_count");
				if tribe_count == nil then tribe_count = 0 end;
				
				tribe_count = tribe_count + 1;
				
				cm:set_saved_value("ll_chaos_sigvald_tribe_count", tribe_count);
				
				return tribe_count > 3;
			end;
		end
	),

	-- Kholek Suneater
	ll_unlock:new(
		"wh_main_chs_chaos",
		"2140783672",
		"names_name_2147345931",
		"MilitaryForceBuildingCompleteEvent",
		function(context)
			return context:building() == "wh_main_horde_chaos_dragon_ogres_1" and context:character():faction():name() == "wh_main_chs_chaos";
		end
	)
};



-------------------------------------------------------
--	Beastmen
-------------------------------------------------------

ll_beastmen = {
	-- Khazrak
	ll_unlock:new(
		"wh_dlc03_bst_beastmen",
		"2140784064",
		"names_name_2147352487",
		"CharacterPostBattleRelease",
		function(context)
			if context:character():faction():name() == "wh_dlc03_bst_beastmen" then
				local release_count = cm:get_saved_value("ll_beastmen_khazrak_release_count");
				if release_count == nil then release_count = 0 end;
				
				release_count = release_count + 1;
				
				cm:set_saved_value("ll_beastmen_khazrak_release_count", release_count);
				
				return release_count > 9;
			end
		end
	),

	-- Malagor
	ll_unlock:new(
		"wh_dlc03_bst_beastmen",
		"2140784127",
		"names_name_2147357619",
		"MilitaryForceBuildingCompleteEvent",
		function(context)
			return context:building() == "wh_dlc03_horde_beastmen_arcane_1" and context:character():faction():name() == "wh_dlc03_bst_beastmen";
		end
	),

	-- Morghur
	ll_unlock:new(
		"wh_dlc03_bst_beastmen",
		"2140784189",
		"names_name_2147352897",
		"UnitCreated",
		function(context)
			return context:unit():unit_key() == "wh_dlc03_bst_mon_chaos_spawn_0" and context:unit():faction():name() == "wh_dlc03_bst_beastmen";
		end
	)
};