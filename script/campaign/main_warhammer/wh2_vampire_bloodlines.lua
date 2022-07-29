local vampire_bloodlines_bloodline_details = {
	["bloodline_von_carstein"] =	{subtype = "wh2_dlc11_vmp_bloodline_von_carstein",	artset = "",	male_lords = true,	forced_surname = "2147343895",	unit_reward = "wh2_dlc11_vmp_inf_crossbowmen",	max_level_reward = "wh2_dlc11_vmp_inf_handgunners"},
	["bloodline_blood_dragon"] =	{subtype = "wh2_dlc11_vmp_bloodline_blood_dragon",	artset = "",	male_lords = true,	forced_surname = "",			unit_reward = "",								max_level_reward = ""},
	["bloodline_lahmian"] =			{subtype = "wh2_dlc11_vmp_bloodline_lahmian",		artset = "",	male_lords = false,	forced_surname = "",			unit_reward = "",								max_level_reward = ""},
	["bloodline_necrarch"] =		{subtype = "wh2_dlc11_vmp_bloodline_necrarch",		artset = "",	male_lords = true,	forced_surname = "",			unit_reward = "",								max_level_reward = ""},
	["bloodline_strigoi"] =			{subtype = "wh2_dlc11_vmp_bloodline_strigoi",		artset = "",	male_lords = true,	forced_surname = "",			unit_reward = "",								max_level_reward = ""}
};

local vampire_bloodlines_ritual_to_bloodline = {
	["wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein"] = "bloodline_von_carstein",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian"] = "bloodline_lahmian",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch"] = "bloodline_necrach",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi"] = "bloodline_strigoi",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon"] = "bloodline_blood_dragon",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_01"] = "bloodline_blood_dragon",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_02"] = "bloodline_blood_dragon",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_03"] = "bloodline_blood_dragon",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_01"] = "bloodline_lahmian",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_02"] = "bloodline_lahmian",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_03"] = "bloodline_lahmian",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_01"] = "bloodline_necrarch",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_02"] = "bloodline_necrarch",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_03"] = "bloodline_necrarch",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_01"] = "bloodline_strigoi",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_02"] = "bloodline_strigoi",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_03"] = "bloodline_strigoi",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_01"] = "bloodline_von_carstein",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_02"] = "bloodline_von_carstein",
	["wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_03"] = "bloodline_von_carstein"
};

local vampire_bloodlines_assassination_actions = {
	["wh2_main_agent_action_champion_hinder_agent_assassinate"] = true,
	["wh2_main_agent_action_spy_hinder_agent_assassinate"] = true,
	["wh2_main_agent_action_champion_hinder_agent_wound"] = true,
	["wh2_main_agent_action_dignitary_hinder_agent_wound"] = true,
	["wh2_main_agent_action_engineer_hinder_agent_wound"] = true,
	["wh2_main_agent_action_runesmith_hinder_agent_wound"] = true,
	["wh2_main_agent_action_wizard_hinder_agent_wound"] = true
};

local vampire_bloodlines_technologies = {
	["tech_vmp_blood_01"] = 1
};

local vampire_bloodlines_bloodline_to_effects = {
	["bloodline_von_carstein"] = "wh2_dlc11_vmp_ritual_bloodline_awaken_von_carstein_bundle_0",
	["bloodline_blood_dragon"] = "wh2_dlc11_vmp_ritual_bloodline_awaken_blood_dragon_bundle_0",
	["bloodline_lahmian"] =	"wh2_dlc11_vmp_ritual_bloodline_awaken_lahmian_bundle_0",
	["bloodline_necrarch"] = "wh2_dlc11_vmp_ritual_bloodline_awaken_necrarch_bundle_0",
	["bloodline_strigoi"] = "wh2_dlc11_vmp_ritual_bloodline_awaken_strigoi_bundle_0"
};

local vampire_bloodlines_levels = {};
local vampire_bloodlines_unit_caps = {};
local vampire_bloodlines_vassals = {};

local vampire_bloodlines_names = {
	["forename"] = {
		["both"] = {},
		["male"] = {
			"1406951171",
			"1768171990",
			"1880091843",
			"1966785637",
			"2147345100",
			"2147345109",
			"2147345117",
			"2147345149",
			"2147345161",
			"2147345165",
			"2147345166",
			"2147345180",
			"2147345200",
			"2147345209",
			"2147345217",
			"2147345230",
			"2147345239",
			"2147345257",
			"2147345260",
			"2147345266",
			"2147345279",
			"2147345281",
			"2147345303",
			"2147345862",
			"2147345872",
			"2147357264",
			"2147357272",
			"2147357278",
			"2147357284",
			"2147357289",
			"2147357295",
			"2147357301",
			"2147357304",
			"2147357306",
			"2147357315",
			"2147357322",
			"2147357330",
			"2147357531",
			"2147357577",
			"2147357583",
			"2147357593",
			"2147357595",
			"2147357596",
			"2147357905",
			"2147357909",
			"2147357911",
			"2147357919",
			"2147357925",
			"2147357928",
			"2147357935",
			"2147357949",
			"2147357952",
			"2147357970",
			"2147357974",
			"2147357977",
			"2147357980",
			"2147357990",
			"2147357991",
			"2147357994",
			"2147358006",
			"2147358011",
			"2147358022",
			"2147358030",
			"2147358038",
			"2147358047",
			"2147358057",
			"2147358063",
			"2147358070",
			"2147358072",
			"2147358074",
			"2147358076",
			"2147358083",
			"2147358089",
			"2147358096",
			"2147358103",
			"2147358110",
			"2147358113",
			"2147358121",
			"2147358122",
			"2147358126",
			"2147358136",
			"2147358140",
			"2147358143",
			"2147358144",
			"2147358148",
			"2147358157",
			"2147358165",
			"2147358170",
			"2147358174",
			"2147358184",
			"2147358193",
			"2147358194",
			"2147358199",
			"2147358201",
			"2147358210",
			"2147358220",
			"2147358224",
			"2147358230",
			"2147358234",
			"2147358241",
			"2147358243",
			"2147358244",
			"2147358248",
			"2147358254",
			"2147358259",
			"2147358260",
			"2147358265",
			"2147358275",
			"2147358279",
			"2147358289",
			"2147358298",
			"2147358299",
			"2147358304",
			"2147358305",
			"2147358308",
			"2147358310",
			"2147358319",
			"2147358324",
			"677402052",
			"79061478"
		},
		["female"] = {
			"1032919940",
			"1045238283",
			"1053838354",
			"1075820337",
			"1260872876",
			"1267502686",
			"1275357021",
			"1283357347",
			"1308257256",
			"1322939898",
			"136149811",
			"1433200101",
			"1475920156",
			"1482316743",
			"1484072244",
			"1506564500",
			"1535814355",
			"168439276",
			"1693576160",
			"1805039873",
			"1832184260",
			"1869318615",
			"191253015",
			"199808719",
			"2028607742",
			"2051207878",
			"2079852552",
			"2095474597",
			"2146943899",
			"2147345198",
			"2147352376",
			"2147352380",
			"2147352389",
			"2147352394",
			"2147352398",
			"2147352400",
			"2147352404",
			"2147352407",
			"2147352412",
			"2147352920",
			"2147352924",
			"2147352926",
			"2147357187",
			"2147357193",
			"2147357203",
			"2147357204",
			"2147357208",
			"2147357213",
			"2147357223",
			"2147357233",
			"2147357242",
			"2147357248",
			"2147357250",
			"2147357251",
			"2147357254",
			"2147357578",
			"2147357611",
			"2147358323",
			"2147358331",
			"258815742",
			"261021798",
			"319312278",
			"333218806",
			"343763360",
			"359390357",
			"359731385",
			"377289142",
			"393387363",
			"408664792",
			"410971846",
			"417272770",
			"446414846",
			"483601268",
			"484373953",
			"511748619",
			"565928968",
			"58789375",
			"719816900",
			"729332466",
			"736105285",
			"766247689",
			"781404442",
			"822026735",
			"846892544",
			"885922815",
			"886981325",
			"955981470",
			"961034532",
			"998480053"
		}
	},
	["surname"] = {
		["both"] = {
			"1003038241",
			"1041741800",
			"1064541212",
			"1090640497",
			"1139217754",
			"1199231259",
			"1227554475",
			"1238864252",
			"1305581408",
			"1323396643",
			"168545332",
			"1702107794",
			"1777692413",
			"2012155459",
			"2051685651",
			"2147345093",
			"2147345151",
			"2147345172",
			"2147345188",
			"2147345224",
			"2147345237",
			"2147345247",
			"2147345271",
			"2147345290",
			"2147345294",
			"2147352928",
			"2147357525",
			"26926004",
			"378511030",
			"463976820",
			"522579314",
			"680207862",
			"693999515",
			"722999650",
			"817148109",
			"86899705",
			"943406012"
		},
		["male"] = {},
		["female"] = {}
	}
};

local mousillon_names = {
	["forename"] = {
		"2147353257",
		"2147353254",
		"2147353247",
		"2147353242",
		"2147353238",
		"2147353237",
		"2147353232",
		"2147353230",
		"2147353228",
		"2147353218",
		"2147353215",
		"2147353206",
		"2147353196",
		"2147353194",
		"2147353186",
		"2147353181",
		"2147353177",
		"2147353175",
		"2147353170",
		"2147353160",
		"2147353158",
		"2147353155",
		"2147353149",
		"2147353142",
		"2147353135",
		"2147353133",
		"2147353132",
		"2147353129",
		"2147353125",
		"2147353122",
		"2147353121",
		"2147353114",
		"2147353105",
		"2147352806",
		"2147352794",
		"2147352771",
		"2147352751",
		"2147345899",
		"2147345890",
		"2147345888",
		"2147345885",
		"2147345878",
		"2147345456",
		"2147345451",
		"2147345441",
		"2147345432",
		"2147345429",
		"2147345423",
		"2147345417",
		"2147345415",
		"2147345411",
		"2147345403",
		"2147345395",
		"2147345389",
		"2147345384",
		"2147345383",
		"2147345378",
		"2147345374",
		"2147345365",
		"2147345355",
		"2147345346",
		"2147345338",
		"2147345335",
		"2147345332",
		"2147345326",
		"2122085685",
		"2040526366",
		"1967862676",
		"1926409052",
		"1920369071",
		"1911353529",
		"1871984850",
		"1867151486",
		"1858401522",
		"1684985505",
		"1669336690",
		"1537514730",
		"1488861844",
		"1480696171",
		"1457069942",
		"1456394959",
		"1412580874",
		"1371005350",
		"1291131263",
		"1237536125",
		"1197344450",
		"1176502723",
		"1152202501",
		"1069020046",
		"1050537203",
		"1017721779",
		"945424066",
		"906987082",
		"905752484",
		"867875663",
		"836402559",
		"645426472",
		"621043075",
		"614466636",
		"564794739",
		"405563508",
		"399356529",
		"398147214",
		"379568650",
		"278969524",
		"238215718",
		"226056593",
		"92401285",
		"84580907",
		"66547030",
		"49957317",
		"47540902"
	},
	["surname"] = {
		"2147353052",
		"2147353045",
		"2147353036",
		"2147353035",
		"2147353031",
		"2147353021",
		"2147353010",
		"2147353006",
		"2147353000",
		"2147352997",
		"2147352990",
		"2147352974",
		"2147352964",
		"2147352947",
		"2147352946",
		"2147352937",
		"2147352932",
		"2147352930",
		"2147352780",
		"2147345584",
		"2147345578",
		"2147345570",
		"2147345569",
		"2147345562",
		"2147345547",
		"2147345541",
		"2147345539",
		"2147345533",
		"2147345530",
		"2147345528",
		"2147345517",
		"1486457407",
		"1310121907",
		"1024438729",
		"656634704",
		"268561507"
	}
};

function add_vampire_bloodlines_listeners()
	out("#### Adding Vampire Bloodlines Listeners ####");
	if cm:is_new_game() == true then
		local vampire_counts = cm:get_faction("wh_main_vmp_vampire_counts");
		local von_carsteins = cm:get_faction("wh_main_vmp_schwartzhafen");
		
		if vampire_counts and vampire_counts:is_human() and vampire_counts:has_effect_bundle("wh_main_lord_trait_vmp_mannfred_von_carstein") then
			cm:faction_add_pooled_resource("wh_main_vmp_vampire_counts", "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_other", 1);
		end
		
		if von_carsteins and von_carsteins:is_human() then
			cm:faction_add_pooled_resource("wh_main_vmp_schwartzhafen", "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_other", 1);
		end
	end
	
	core:add_listener(
		"vampire_bloodlines_ritual",
		"RitualCompletedEvent",
		function(context) return context:succeeded() end,
		function(context)
			local ritual = context:ritual():ritual_key();
			
			if vampire_bloodlines_ritual_to_bloodline[ritual] ~= nil then
				local faction = context:performing_faction();
				local bloodline = vampire_bloodlines_ritual_to_bloodline[ritual];
				vampire_bloodline_triggered(bloodline, faction);
			end
		end,
		true
	);
	core:add_listener(
		"vampire_bloodlines_skill",
		"CharacterSkillPointAllocated",
		function(context) return context:skill_point_spent_on() == "wh2_dlc11_skill_vmp_bloodline_von_carstein_unique_cattle_herder" end,
		function(context)
			local faction = context:character():faction();
			local faction_key = faction:name();
			local unit_key = vampire_bloodlines_bloodline_details["bloodline_von_carstein"].unit_reward;
			
			cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), unit_key, 1);
			
			vampire_bloodlines_unit_caps[faction_key] = vampire_bloodlines_unit_caps[faction_key] or {};
			vampire_bloodlines_unit_caps[faction_key][unit_key] = vampire_bloodlines_unit_caps[faction_key][unit_key] or {};
			vampire_bloodlines_unit_caps[faction_key][unit_key].capacity = (vampire_bloodlines_unit_caps[faction_key][unit_key].capacity or 0) + 1;
			vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool = (vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool or 0) + 1;
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_unit_trained",
		"UnitTrained",
		function(context) return context:unit():unit_key() == "wh2_dlc11_vmp_inf_crossbowmen" or context:unit():unit_key() == "wh2_dlc11_vmp_inf_handgunners" end,
		function(context)
			local faction_key = context:unit():faction():name();
			local unit_key = context:unit():unit_key();
			vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool = vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool - 1;
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_faction_leader_killed",
		"CharacterConvalescedOrKilled",
		true,
		function(context)
			vampire_bloodline_faction_leader_killed(context);
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_vassalage",
		"PositiveDiplomaticEvent",
		function(context) return context:is_vassalage() end,
		function(context)
			vampire_bloodline_vassalage(context);
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_vassalage_battle",
		"FactionBecomesLiberationVassal",
		true,
		function(context)
			vampire_bloodline_vassalage_battle(context);
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_assassination",
		"CharacterCharacterTargetAction",
		function(context) return context:mission_result_critial_success() or context:mission_result_success() end,
		function(context)
			vampire_bloodline_assassination(context);
		end,
		true
	);
	core:add_listener(
		"vampire_bloodline_technology",
		"ResearchCompleted",
		true,
		function(context)
			vampire_bloodline_technology(context);
		end,
		true
	);

	cm:add_faction_turn_start_listener_by_culture(
		"vampire_bloodline_unit_respawn",
		"wh_main_vmp_vampire_counts",
		vampire_bloodline_unit_respawn,
		true
	);
	
	-- If there are human vampires then we let AI get bloodline characters after players get them
	-- If there are NOT human vampires then we let the AI have a per turn chance of getting them
	local faction_list = cm:model():world():faction_list();
	local human_vampire = false;
	
	for i = 0, faction_list:num_items() - 1 do
		local fac = faction_list:item_at(i);
		
		if fac:is_human() == true and fac:culture() == "wh_main_vmp_vampire_counts" then
			human_vampire = true;
			break;
		end
	end
	if human_vampire == false then

		cm:add_faction_turn_start_listener_by_culture(
			"vampire_bloodline_ai_characters",
			"wh_main_vmp_vampire_counts",
			function(context)
				local faction = context:faction();
				
				if faction:is_human() == false then
					local turn = cm:model():turn_number();
					local chance = 0;
					
					if turn == 1 then
						chance = 100;
					elseif turn > 10 then
						chance = 5;
					end
					
					if cm:model():random_percent(chance) then
						vampire_bloodline_give_ai_character(faction);
					end
				end
			end,
			true
		);
	end
	
	-- Put all the names that work for both genders in both gender tables
	for key, value in pairs( vampire_bloodlines_names["forename"]["both"] ) do
		table.insert(vampire_bloodlines_names["forename"]["male"], value);
		table.insert(vampire_bloodlines_names["forename"]["female"], value);
	end
	for key, value in pairs( vampire_bloodlines_names["surname"]["both"] ) do
		table.insert(vampire_bloodlines_names["surname"]["male"], value);
		table.insert(vampire_bloodlines_names["surname"]["female"], value);
	end
	-- Allow tables to be garbage collected
	vampire_bloodlines_names["forename"]["both"] = nil;
	vampire_bloodlines_names["surname"]["both"] = nil;
end

function vampire_bloodline_triggered(bloodline, faction)
	local faction_key = faction:name();
	out.design("BLOODLINES: vampire_bloodline_triggered - Bloodline: "..bloodline.." - Faction: "..faction_key);
	vampire_bloodlines_levels[faction_key] = vampire_bloodlines_levels[faction_key] or {};
	
	if vampire_bloodlines_bloodline_details[bloodline] ~= nil then
		out.design("\tFound bloodline");
		local forename = "names_name_";
		local surname = "names_name_";
		local gender = "male";
		
		if vampire_bloodlines_bloodline_details[bloodline].male_lords == false then
			gender = "female";
		end
		
		vampire_bloodlines_levels[faction_key][bloodline] = vampire_bloodlines_levels[faction_key][bloodline] or 0;

		-- Randomly select their forename and surname
		-- mousillon use bretonnia nameset, so special case here
		if faction_key == "wh_main_vmp_mousillon" then
			forename = forename .. mousillon_names["forename"][cm:random_number(#mousillon_names["forename"])];
			
			surname = surname .. mousillon_names["surname"][cm:random_number(#mousillon_names["surname"])];
		else
			local rand_forename = cm:random_number(#vampire_bloodlines_names["forename"][gender]);
			forename = forename .. vampire_bloodlines_names["forename"][gender][rand_forename];
			
			if vampire_bloodlines_bloodline_details[bloodline].forced_surname ~= "" then
				surname = surname .. vampire_bloodlines_bloodline_details[bloodline].forced_surname;
			else
				local rand_surname = cm:random_number(#vampire_bloodlines_names["surname"][gender]);
				surname = surname .. vampire_bloodlines_names["surname"][gender][rand_surname];
			end
		end
		
		-- Give unit reward if necessary
		if vampire_bloodlines_bloodline_details[bloodline].unit_reward ~= "" then
			local unit_key = vampire_bloodlines_bloodline_details[bloodline].unit_reward;
			cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), unit_key, 1);
			
			vampire_bloodlines_unit_caps[faction_key] = vampire_bloodlines_unit_caps[faction_key] or {};
			vampire_bloodlines_unit_caps[faction_key][unit_key] = vampire_bloodlines_unit_caps[faction_key][unit_key] or {};
			vampire_bloodlines_unit_caps[faction_key][unit_key].capacity = (vampire_bloodlines_unit_caps[faction_key][unit_key].capacity or 0) + 1;
			vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool = (vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool or 0) + 1;
		end
		-- Give final level reward if necessary
		if vampire_bloodlines_bloodline_details[bloodline].max_level_reward ~= "" then
			if vampire_bloodlines_levels[faction_key][bloodline] == 2 then
				local unit_key = vampire_bloodlines_bloodline_details[bloodline].max_level_reward;
				cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), unit_key, 1);
				
				vampire_bloodlines_unit_caps[faction_key] = vampire_bloodlines_unit_caps[faction_key] or {};
				vampire_bloodlines_unit_caps[faction_key][unit_key] = vampire_bloodlines_unit_caps[faction_key][unit_key] or {};
				vampire_bloodlines_unit_caps[faction_key][unit_key].capacity = (vampire_bloodlines_unit_caps[faction_key][unit_key].capacity or 0) + 1;
				vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool = (vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool or 0) + 1;
			end
		end
		
		local subtype = vampire_bloodlines_bloodline_details[bloodline].subtype;
		local artset = vampire_bloodlines_bloodline_details[bloodline].artset;
		
		-- Add the character to the character pool
		cm:spawn_character_to_pool(faction_key, forename, surname, "", "", 21, true, "general", subtype, false, artset);
		out.design("\tAdded character to pool: "..faction_key..", "..forename..", "..surname..", "..subtype..", "..artset);
		
		-- Give A.I chance to gain character too
		local other_vampires = faction:factions_of_same_culture();
		
		for i = 0, other_vampires:num_items() - 1 do
			local vamp = other_vampires:item_at(i);
			vampire_bloodline_give_ai_character(vamp);
		end
		
		-- Move camera
		if not cm:get_saved_value("bloodline_first_use") then
			cm:set_saved_value("bloodline_first_use", true);
		end
		
		-- Effect Level
		local effect_key = vampire_bloodlines_bloodline_to_effects[bloodline];
		
		if vampire_bloodlines_levels[faction_key][bloodline] < 3 then
			vampire_bloodlines_levels[faction_key][bloodline] = vampire_bloodlines_levels[faction_key][bloodline] + 1;
		end
		
		if vampire_bloodlines_levels[faction_key][bloodline] == 2 then
			cm:remove_effect_bundle(effect_key..1, faction_key);
		elseif vampire_bloodlines_levels[faction_key][bloodline] == 3 then
			cm:remove_effect_bundle(effect_key..1, faction_key);
			cm:remove_effect_bundle(effect_key..2, faction_key);
		end
	end
end

function vampire_bloodline_give_ai_character(vamp)
	if vamp:is_human() == false and vamp:is_quest_battle_faction() == false then
		local faction_key = vamp:name();
		local bloodline = "bloodline_von_carstein";
		
		if faction_key == "wh_main_vmp_mousillon" then
			bloodline = "bloodline_blood_dragon";
		elseif faction_key == "wh2_main_vmp_necrarch_brotherhood" then
			bloodline = "bloodline_necrarch";
		elseif faction_key == "wh2_main_vmp_strygos_empire" then
			bloodline = "bloodline_strigoi";
		elseif faction_key == "wh2_main_vmp_the_silver_host" then
			bloodline = "bloodline_lahmian";
		else
			local roll = cm:random_number(100);
			
			if roll <= 20 then
				bloodline = "bloodline_blood_dragon";
			elseif roll <= 40 then
				bloodline = "bloodline_lahmian";
			elseif roll <= 60 then
				bloodline = "bloodline_necrarch";
			elseif roll <= 80 then
				bloodline = "bloodline_strigoi";
			end
		end
		
		local forename = "names_name_";
		local surname = "names_name_";
		local gender = "male";
		
		if vampire_bloodlines_bloodline_details[bloodline].male_lords == false then
			gender = "female";
		end
		
		-- mousillon use bretonnia nameset, so special case here
		if faction_key == "wh_main_vmp_mousillon" then
			forename = forename .. mousillon_names["forename"][cm:random_number(#mousillon_names["forename"])];
			
			surname = surname .. mousillon_names["surname"][cm:random_number(#mousillon_names["surname"])];
		else
			local rand_forename = cm:random_number(#vampire_bloodlines_names["forename"][gender]);
			forename = forename .. vampire_bloodlines_names["forename"][gender][rand_forename];
			
			if vampire_bloodlines_bloodline_details[bloodline].forced_surname ~= "" then
				surname = surname .. vampire_bloodlines_bloodline_details[bloodline].forced_surname;
			else
				local rand_surname = cm:random_number(#vampire_bloodlines_names["surname"][gender]);
				surname = surname .. vampire_bloodlines_names["surname"][gender][rand_surname];
			end
		end
		
		local subtype = vampire_bloodlines_bloodline_details[bloodline].subtype;
		local artset = vampire_bloodlines_bloodline_details[bloodline].artset;
		
		cm:spawn_character_to_pool(faction_key, forename, surname, "", "", 21, true, "general", subtype, false, artset);
		out.design("\tAdded A.I character to pool: "..faction_key..", "..forename..", "..surname..", "..subtype..", "..artset);
	end
end

function vampire_bloodline_unit_respawn(context)
	local faction = context:faction();
	local faction_key = faction:name();
	local unit_caps = vampire_bloodlines_unit_caps[faction_key];
	
	if unit_caps ~= nil then
		for unit_key, unit_cap_table in pairs(unit_caps) do
			local current_count = vampire_bloodline_count_unit(faction, unit_key);
			local missing = unit_cap_table.capacity - unit_cap_table.in_pool - current_count;
			out.design("BLOODLINES: "..missing.." "..unit_key.." are missing ("..unit_cap_table.capacity.." / "..unit_cap_table.in_pool.." / "..current_count..")");
			
			if missing > 0 then
				cm:add_units_to_faction_mercenary_pool(faction:command_queue_index(), unit_key, missing);
				vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool = vampire_bloodlines_unit_caps[faction_key][unit_key].in_pool + 1;
			end
		end
	end
end

function vampire_bloodline_count_unit(faction, unit_key)
	local mf_list = faction:military_force_list();
	local count = 0;
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		
		if current_mf:is_armed_citizenry() == false then
			local unit_list = current_mf:unit_list();
			
			for j = 0, unit_list:num_items() - 1 do
				local unit = unit_list:item_at(j);
				local key = unit:unit_key();
				
				if key == unit_key then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

function first_blood_kiss_gained(faction)
	if faction:is_human() and not cm:get_saved_value("blood_kiss_gained") and cm:is_multiplayer() == false then
		cm:set_saved_value("blood_kiss_gained", true);
	end
end

-- Blood Kiss from defeating Faction Leaders
function vampire_bloodline_faction_leader_killed(context)
	local pending_battle = cm:model():pending_battle();
	
	if pending_battle:is_active() == true then
		local attacker = pending_battle:attacker();
		local defender = pending_battle:defender();
		local attacker_result = pending_battle:attacker_battle_result();
		local defender_result = pending_battle:defender_battle_result();
		local attacker_won = (attacker_result == "heroic_victory") or (attacker_result == "decisive_victory") or (attacker_result == "close_victory") or (attacker_result == "pyrrhic_victory");
		local defender_won = (defender_result == "heroic_victory") or (defender_result == "decisive_victory") or (defender_result == "close_victory") or (defender_result == "pyrrhic_victory");
		
		local attacker_died = false;
		local attacker_leader = false;
		local defender_died = false;
		local defender_leader = false;
		
		if attacker:is_null_interface() == false then
			attacker_died = attacker:command_queue_index() == context:character():command_queue_index();
			attacker_leader = attacker:is_faction_leader();
		end
		if defender:is_null_interface() == false then
			defender_died = defender:command_queue_index() == context:character():command_queue_index();
			defender_leader = defender:is_faction_leader();
		end
		
		if attacker_won == true and defender_died == true and defender_leader == true and attacker:is_null_interface() == false and attacker:faction():subculture() == "wh_main_sc_vmp_vampire_counts" then
			cm:faction_add_pooled_resource(attacker:faction():name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_enemy_general_killed", 1);
			first_blood_kiss_gained(attacker:faction());
		elseif defender_won == true and attacker_died == true and attacker_leader == true and defender:is_null_interface() == false and defender:faction():subculture() == "wh_main_sc_vmp_vampire_counts" then
			cm:faction_add_pooled_resource(defender:faction():name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_enemy_general_killed", 1);
			first_blood_kiss_gained(defender:faction());
		end	
	end
end

-- Blood Kiss from gaining a vassal
function vampire_bloodline_vassalage(context)
	if context:proposer_is_vassal() == true then
		local vassal = context:proposer():name();
		
		if vampire_bloodlines_vassals[vassal] == nil then
			if context:recipient():subculture() == "wh_main_sc_vmp_vampire_counts" then
				cm:faction_add_pooled_resource(context:recipient():name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_vassal", 1);
				vampire_bloodlines_vassals[vassal] = true;
				first_blood_kiss_gained(context:recipient());
			end
		end
	else
		local vassal = context:recipient():name();
		
		if vampire_bloodlines_vassals[vassal] == nil then
			if context:proposer():subculture() == "wh_main_sc_vmp_vampire_counts" then
				cm:faction_add_pooled_resource(context:proposer():name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_vassal", 1);
				vampire_bloodlines_vassals[vassal] = true;
				first_blood_kiss_gained(context:proposer());
			end
		end
	end
end
function vampire_bloodline_vassalage_battle(context)
	local vassal = context:faction():name();
	
	if vampire_bloodlines_vassals[vassal] == nil then
		if context:liberating_character():faction():subculture() == "wh_main_sc_vmp_vampire_counts" then
			cm:faction_add_pooled_resource(context:liberating_character():faction():name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_vassal", 1);
			vampire_bloodlines_vassals[vassal] = true;
		end
	end
end

-- Blood Kiss from assassination
function vampire_bloodline_assassination(context)
	if vampire_bloodlines_assassination_actions[context:agent_action_key()] then
		local faction = context:character():faction();
		
		if faction:subculture() == "wh_main_sc_vmp_vampire_counts" then
			cm:faction_add_pooled_resource(faction:name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_enemy_character_assassinated", 1);
			first_blood_kiss_gained(faction);
		end
	end
end

-- Blood Kiss from technology
function vampire_bloodline_technology(context)
	if vampire_bloodlines_technologies[context:technology()] then
		local faction = context:faction();
		local amount = vampire_bloodlines_technologies[context:technology()];
		
		if faction:subculture() == "wh_main_sc_vmp_vampire_counts" then
			cm:faction_add_pooled_resource(faction:name(), "vmp_blood_kiss", "wh2_dlc11_vmp_resource_factor_other", amount);
			first_blood_kiss_gained(faction);
		end	
	end
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("vampire_bloodlines_levels", vampire_bloodlines_levels, context);
		cm:save_named_value("vampire_bloodlines_unit_caps", vampire_bloodlines_unit_caps, context);
		cm:save_named_value("vampire_bloodlines_vassals", vampire_bloodlines_vassals, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		if cm:is_new_game() == false then
			vampire_bloodlines_levels = cm:load_named_value("vampire_bloodlines_levels", vampire_bloodlines_levels, context);
			vampire_bloodlines_unit_caps = cm:load_named_value("vampire_bloodlines_unit_caps", vampire_bloodlines_unit_caps, context);
			vampire_bloodlines_vassals = cm:load_named_value("vampire_bloodlines_vassals", vampire_bloodlines_vassals, context);
		end
	end
);