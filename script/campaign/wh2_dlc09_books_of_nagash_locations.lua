-----------------------------------------------------------------------------------------------------
------------------------------------------ VORTEX CAMPAIGN ------------------------------------------
-----------------------------------------------------------------------------------------------------
patrol_path_vortex_ulthuan = {{x = 655, y = 499}, {x = 574, y = 395}, {x = 456, y = 385}, {x = 367, y = 478}, {x = 389, y = 569}, {x = 472, y = 628}, {x = 598, y = 624}};
patrol_eyes_of_jungle_path_1 = {{x = 580, y = 78}, {x = 574, y = 127}, {x = 535, y = 75}};
patrol_eyes_of_jungle_path_2 = {{x = 126, y = 246}, {x = 87, y = 286}, {x = 75, y = 226}};
patrol_black_creek_raiders = {{x = 239, y = 256}, {x = 229, y = 204}, {x = 264, y = 217}};
patrol_dwellers_of_zardok_1 = {{x = 504, y = 109}, {x = 564, y = 93}, {x = 514, y = 163}};
patrol_dwellers_of_zardok_2 = {{x = 188, y = 124}, {x = 217, y = 88}, {x = 160, y = 102}};
patrol_dwellers_of_zardok_3 = {{x = 114, y = 650}, {x = 61, y = 663}, {x = 75, y = 610}};

book_objective_list_faction = {
	----------------------------
	---------- SETTRA ----------
	----------------------------
	["wh2_dlc09_tmb_khemri"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_southlands_world_edge_mountains_lost_plateau"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_cobra_pass_vulture_mountain"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_the_vampire_coast_the_awakening"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_saphery_tower_of_hoeth"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 264, y = 217}, patrol = patrol_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 580, y = 78}, patrol = patrol_eyes_of_jungle_path_1},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 514, y = 163}, patrol = patrol_dwellers_of_zardok_1},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 598, y = 624}, patrol = patrol_path_vortex_ulthuan}
	},
	----------------------------
	---------- ARKHAN ----------
	----------------------------
	["wh2_dlc09_tmb_followers_of_nagash"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_southlands_world_edge_mountains_lost_plateau"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_cobra_pass_vulture_mountain"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_mosquito_swamps_xlanhuapec"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_caledor_vauls_anvil"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 264, y = 217}, patrol = patrol_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 580, y = 78}, patrol = patrol_eyes_of_jungle_path_1},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 514, y = 163}, patrol = patrol_dwellers_of_zardok_1},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 598, y = 624}, patrol = patrol_path_vortex_ulthuan}
	},
	-----------------------------
	---------- KHALIDA ----------
	-----------------------------
	["wh2_dlc09_tmb_lybaras"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_southlands_world_edge_mountains_lost_plateau"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_cobra_pass_vulture_mountain"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_the_capes_citadel_of_dusk"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_the_vampire_coast_the_awakening"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 264, y = 217}, patrol = patrol_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 580, y = 78}, patrol = patrol_eyes_of_jungle_path_1},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 160, y = 102}, patrol = patrol_dwellers_of_zardok_2},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 598, y = 624}, patrol = patrol_path_vortex_ulthuan}
	},
	----------------------------
	---------- KHATEP ----------
	----------------------------
	["wh2_dlc09_tmb_exiles_of_nehek"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_cobra_pass_vulture_mountain"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_the_vampire_coast_the_awakening"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_isthmus_of_lustria_hexoatl"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_iron_peaks_ancient_city_of_quintex"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 264, y = 217}, patrol = patrol_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 75, y = 226}, patrol = patrol_eyes_of_jungle_path_2},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 75, y = 610}, patrol = patrol_dwellers_of_zardok_3},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 598, y = 624}, patrol = patrol_path_vortex_ulthuan}
	}
};

---------------------------------
---------- MULTIPLAYER ----------
---------------------------------
book_objective_list = {
	{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_southlands_world_edge_mountains_lost_plateau"},
	{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_headhunters_jungle_altar_of_the_horned_rat"},
	{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_obsidian_peaks_keshta_vault"},
	{objective = "CAPTURE_REGIONS", target = "wh2_main_vor_saphery_tower_of_hoeth"},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 264, y = 217}, patrol = patrol_black_creek_raiders},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 580, y = 78}, patrol = patrol_eyes_of_jungle_path_1},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 75, y = 610}, patrol = patrol_dwellers_of_zardok_3},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 598, y = 624}, patrol = patrol_path_vortex_ulthuan}
};

-----------------------------------------------------------------------------------------------------
-------------------------------------- MORTAL EMPIRES CAMPAIGN --------------------------------------
-----------------------------------------------------------------------------------------------------
patrol_me_black_creek_raiders = {{x = 117, y = 122}, {x = 153, y = 144}, {x = 149, y = 113}};
patrol_me_eyes_of_the_jungle = {{x = 625, y = 68}, {x = 574, y = 105}, {x = 543, y = 18}};
patrol_me_dwellers_of_zardok = {{x = 84, y = 610}, {x = 59, y = 653}, {x = 35, y = 610}};
patrol_me_dwellers_of_zardok_settra = {{x = 647, y = 465}, {x = 594, y = 422}, {x = 630, y = 384}};
patrol_me_dwellers_of_zardok_khalida = {{x = 612, y = 249}, {x = 660, y = 231}};
patrol_me_pilgrims_of_myrmidia = {{x = 339, y = 350}, {x = 228, y = 220}, {x = 108, y = 348}, {x = 239, y = 472}};

book_objective_list_faction_grand = {
	----------------------------
	---------- SETTRA ----------
	----------------------------
	["wh2_dlc09_tmb_khemri"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_devils_backbone_lahmia"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_skavenblight_skavenblight"},
		{objective = "CAPTURE_REGIONS", target = "wh_main_eastern_badlands_karak_eight_peaks"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_saphery_tower_of_hoeth"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 149, y = 113}, patrol = patrol_me_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 543, y = 18}, patrol = patrol_me_eyes_of_the_jungle},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 669, y = 421}, patrol = patrol_me_dwellers_of_zardok_settra},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 239, y = 472}, patrol = patrol_me_pilgrims_of_myrmidia}
	},
	----------------------------
	---------- ARKHAN ----------
	----------------------------
	["wh2_dlc09_tmb_followers_of_nagash"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_kingdom_of_beasts_temple_of_skulls"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_skavenblight_skavenblight"},
		{objective = "CAPTURE_REGIONS", target = "wh_main_eastern_badlands_karak_eight_peaks"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_saphery_tower_of_hoeth"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 149, y = 113}, patrol = patrol_me_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 543, y = 18}, patrol = patrol_me_eyes_of_the_jungle},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 669, y = 421}, patrol = patrol_me_dwellers_of_zardok_settra},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 239, y = 472}, patrol = patrol_me_pilgrims_of_myrmidia}
	},
	-----------------------------
	---------- KHALIDA ----------
	-----------------------------
	["wh2_dlc09_tmb_lybaras"] = {
		{objective = "CAPTURE_REGIONS", target = "wh2_main_southlands_worlds_edge_mountains_lost_plateau"},
		{objective = "CAPTURE_REGIONS", target = "wh_main_lyonesse_mousillon"},
		{objective = "CAPTURE_REGIONS", target = "wh_main_eastern_sylvania_castle_drakenhof"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_saphery_tower_of_hoeth"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 149, y = 113}, patrol = patrol_me_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 543, y = 18}, patrol = patrol_me_eyes_of_the_jungle},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 711, y = 268}, patrol = patrol_me_dwellers_of_zardok_khalida},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 239, y = 472}, patrol = patrol_me_pilgrims_of_myrmidia}
	},
	----------------------------
	---------- KHATEP ----------
	----------------------------
	["wh2_dlc09_tmb_exiles_of_nehek"] = {
		{objective = "CAPTURE_REGIONS", target = "wh_main_couronne_et_languille_couronne"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_isthmus_of_lustria_hexoatl"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_titan_peaks_ancient_city_of_quintex"},
		{objective = "CAPTURE_REGIONS", target = "wh2_main_saphery_tower_of_hoeth"},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 149, y = 113}, patrol = patrol_me_black_creek_raiders},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 543, y = 18}, patrol = patrol_me_eyes_of_the_jungle},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 79, y = 606}, patrol = patrol_me_dwellers_of_zardok},
		{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 239, y = 472}, patrol = patrol_me_pilgrims_of_myrmidia}
	}
};

---------------------------------
---------- MULTIPLAYER ----------
---------------------------------
book_objective_list_grand = {
	{objective = "CAPTURE_REGIONS", target = "wh_main_reikland_altdorf"},
	{objective = "CAPTURE_REGIONS", target = "wh2_main_isthmus_of_lustria_hexoatl"},
	{objective = "CAPTURE_REGIONS", target = "wh_main_the_silver_road_karaz_a_karak"},
	{objective = "CAPTURE_REGIONS", target = "wh2_main_saphery_tower_of_hoeth"},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_black_creek_raiders", pos = {x = 149, y = 113}, patrol = patrol_me_black_creek_raiders},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_eyes_of_the_jungle", pos = {x = 543, y = 18}, patrol = patrol_me_eyes_of_the_jungle},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_dwellers_of_zardok", pos = {x = 79, y = 606}, patrol = patrol_me_dwellers_of_zardok},
	{objective = "ENGAGE_FORCE", target = "wh2_dlc09_rogue_pilgrims_of_myrmidia", pos = {x = 239, y = 472}, patrol = patrol_me_pilgrims_of_myrmidia}
};