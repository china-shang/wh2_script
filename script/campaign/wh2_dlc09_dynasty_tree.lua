local dynasty_tree_tomb_kings = {
	["tech_dlc09_tmb_tomb_king_1"] = {forename = "names_name_586036692", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_wakhaf"},			-- Wakhaf
	["tech_dlc09_tmb_tomb_king_2"] = {forename = "names_name_684097886", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_rakhash"},		-- Rakhash
	["tech_dlc09_tmb_tomb_king_3"] = {forename = "names_name_1216967341", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_thutep"},		-- Thutep
	["tech_dlc09_tmb_tomb_king_4"] = {forename = "names_name_380641190", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_lahmizzash"},		-- Lahmizzash
	["tech_dlc09_tmb_tomb_king_5"] = {forename = "names_name_118554284", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_setep"},			-- Setep
	["tech_dlc09_tmb_tomb_king_6"] = {forename = "names_name_293842310", surname = "", subtype = "wh2_dlc09_tmb_tomb_king_alkhazzar_ii"}	-- Alkhazzar II
};

local dynasty_tree_heralds = {
	["tech_dlc09_tmb_extra_army_1"] = "wh2_dlc09_anc_follower_tmb_herald_of_raestra",
	["tech_dlc09_tmb_extra_army_2"] = "wh2_dlc09_anc_follower_tmb_herald_of_djaf",
	["tech_dlc09_tmb_extra_army_3"] = "wh2_dlc09_anc_follower_tmb_herald_of_mahrak",
	["tech_dlc09_tmb_extra_army_4"] = "wh2_dlc09_anc_follower_tmb_herald_of_sphinx",
	["tech_dlc09_tmb_extra_army_5"] = "wh2_dlc09_anc_follower_tmb_herald_of_zandri",
	["tech_dlc09_tmb_extra_army_6"] = "wh2_dlc09_anc_follower_tmb_herald_of_khemri",
	["tech_dlc09_tmb_extra_army_7"] = "wh2_dlc09_anc_follower_tmb_herald_of_scorpion"
};

function add_dynasty_tree_listeners()
	out("#### Adding Dynasty Tree Listeners ####");
	core:add_listener(
		"DynastyTree_ResearchCompleted",
		"ResearchCompleted",
		true,
		function(context)
			DynastyTree_ResearchCompleted(context);
		end,
		true
	);
end

function DynastyTree_ResearchCompleted(context)
	local faction = context:faction();
	local tech_key = context:technology();
	
	if faction:is_human() == true and faction:culture() == "wh2_dlc09_tmb_tomb_kings" then
		-- SPAWN TOMB KINGS
		if tech_key:starts_with("tech_dlc09_tmb_tomb_king_") then
			local tomb_king = dynasty_tree_tomb_kings[tech_key];
			
			if tomb_king ~= nil then
				create_tomb_king(faction:name(), tomb_king);
			end
		-- GIVE ANCILLARIES
		elseif tech_key:starts_with("tech_dlc09_tmb_extra_army_") then
			local ancillary = dynasty_tree_heralds[tech_key];
			
			if ancillary ~= nil then
				cm:add_ancillary_to_faction(faction, ancillary, false);
			end
		end
	end
end

function create_tomb_king(faction_key, tomb_king)
	cm:spawn_character_to_pool(faction_key, tomb_king.forename, tomb_king.surname, "", "", 18, true, "general", tomb_king.subtype, true, "");
end