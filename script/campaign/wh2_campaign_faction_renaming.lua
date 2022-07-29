local name_updates = {
	{
		-- THE EMPIRE
		factions = {
			"wh_main_emp_empire",
			"wh2_dlc13_emp_golden_order",
			"wh2_dlc13_emp_the_huntmarshals_expedition"
		},
		new_name = "faction_name_empire",
		requirements = {
			["main_warhammer"] = {
				count = 12,
				provinces = {
					"wh_main_reikland",
					"wh_main_middenland",
					"wh_main_stirland",
					"wh_main_wissenland",
					"wh_main_hochland",
					"wh_main_nordland",
					"wh_main_talabecland",
					"wh_main_ostermark",
					"wh_main_ostland",
					"wh2_main_solland",
					"wh_main_averland",
					"wh2_main_the_moot"
				},
				only_lord = false
			}
		}
	},
	{
		-- BRETONNIA
		factions = {
			"wh_main_brt_bretonnia",
			"wh_main_brt_bordeleaux",
			"wh_main_brt_carcassonne",
			"wh2_dlc14_brt_chevaliers_de_lyonesse"
		},
		new_name = "faction_name_bretonnia",
		requirements = {
			["main_warhammer"] = {
				count = 6,
				provinces = {
					"wh_main_couronne_et_languille",
					"wh_main_forest_of_arden",
					"wh_main_lyonesse",
					"wh_main_bordeleaux_et_aquitaine",
					"wh_main_bastonne_et_montfort",
					"wh_main_carcassone_et_brionne"
				},
				only_lord = false
			}
		}
	},
	{
		-- WOOD ELVES
		factions = {
			"wh_dlc05_wef_wood_elves",
			"wh_dlc05_wef_argwylon"
		},
		new_name = "faction_name_wood_elves",
		requirements = {
			["main_warhammer"] = {
				count = 5,
				provinces = {
					"wh_main_argwylon",
					"wh_main_wydrioth",
					"wh_main_talsyn",
					"wh_main_torgovann",
					"wh_main_yn_edri_eternos"
				},
				only_lord = false
			}
		}
	},
	{
		-- HIGH ELVES
		factions = {
			"wh2_main_hef_eataine",
			"wh2_main_hef_avelorn",
			"wh2_main_hef_nagarythe",
			"wh2_main_hef_order_of_loremasters"
		},
		new_name = "faction_name_high_elves",
		requirements = {
			["wh2_main_great_vortex"] = {
				count = 16,
				provinces = {
					"wh2_main_vor_straits_of_lothern",
					"wh2_main_vor_eataine",
					"wh2_main_vor_caledor",
					"wh2_main_vor_cothique",
					"wh2_main_vor_ellyrion",
					"wh2_main_vor_tiranoc",
					"wh2_main_vor_eagle_gate",
					"wh2_main_vor_griffon_gate",
					"wh2_main_vor_unicorn_gate",
					"wh2_main_vor_phoenix_gate",
					"wh2_main_vor_nagarythe",
					"wh2_main_vor_avelorn",
					"wh2_main_vor_chrace",
					"wh2_main_vor_saphery",
					"wh2_main_vor_southern_yvresse",
					"wh2_main_vor_northern_yvresse"
				},
				only_lord = false
			},
			["main_warhammer"] = {
				count = 14,
				provinces = {
					"wh2_main_caledor",
					"wh2_main_chrace",
					"wh2_main_cothique",
					"wh2_main_nagarythe",
					"wh2_main_tiranoc",
					"wh2_main_yvresse",
					"wh2_main_avelorn",
					"wh2_main_eagle_gate",
					"wh2_main_eataine",
					"wh2_main_ellyrion",
					"wh2_main_griffon_gate",
					"wh2_main_phoenix_gate",
					"wh2_main_saphery",
					"wh2_main_unicorn_gate"
				},
				only_lord = false
			}
		}
	},
	{
		-- VAMPIRE COUNTS
		factions = {
			"wh_main_vmp_vampire_counts",
			"wh_main_vmp_schwartzhafen"
			--"wh2_dlc11_vmp_the_barrow_legion"
		},
		new_name = "faction_name_vampire_counts",
		requirements = {
			["main_warhammer"] = {
				count = 2,
				provinces = {
					"wh_main_eastern_sylvania",
					"wh_main_western_sylvania"
				},
				only_lord = true
			}
		}
	},
	{
		-- DWARFS
		factions = {
			"wh_main_dwf_dwarfs",
			"wh_main_dwf_karak_izor",
			"wh_main_dwf_karak_kadrin"
		},
		new_name = "faction_name_dwarfs",
		requirements = {
			["main_warhammer"] = {
				count = 12,
				provinces = {
					"wh_main_the_silver_road",
					"wh_main_death_pass",
					"wh_main_peak_pass",
					"wh_main_rib_peaks",
					"wh2_main_southlands_worlds_edge_mountains",
					"wh_main_northern_worlds_edge_mountains",
					"wh_main_zhufbar",
					"wh_main_the_vaults",
					"wh_main_black_mountains",
					"wh_main_northern_grey_mountains",
					"wh_main_southern_grey_mountains",
					"wh_main_blightwater"
				},
				only_lord = false
			}
		}
	},
	{
		-- GREENSKINS
		factions = {
			"wh_main_grn_greenskins",
			"wh_main_grn_crooked_moon",
			"wh_main_grn_orcs_of_the_bloody_hand",
			"wh2_dlc15_grn_bonerattlaz",
			"wh2_dlc15_grn_broken_axe"
		},
		new_name = "faction_name_greenskins",
		requirements = {
			["main_warhammer"] = {
				count = 0,
				provinces = {
				},
				only_lord = true
			}
		}
	}
};

function add_faction_renaming_listeners()
	out("#### Adding Faction Renaming Listeners ####");
	core:add_listener(
		"renaming_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context)
			update_faction_renaming(context:faction());
		end,
		true
	);
	core:add_listener(
		"renaming_RegionFactionChangeEvent",
		"RegionFactionChangeEvent",
		true,
		function(context)
			update_faction_renaming(context:region():owning_faction());
		end,
		true
	);
end

function update_faction_renaming(faction)
	if faction:is_null_interface() == false and faction:is_dead() == false and faction:is_human() == true then
		local faction_key = faction:name();
		local campaign_key = "";
		
		if cm:model():campaign_name("main_warhammer") then
			campaign_key = "main_warhammer";
		elseif cm:model():campaign_name("wh2_main_great_vortex") then
			campaign_key = "wh2_main_great_vortex";
		end

		for i = 1, #name_updates do
			local name_update = name_updates[i];

			for j = 1, #name_update.factions do
				if name_update.factions[j] == faction_key then
					local should_rename = false;
					
					if name_update.requirements ~= nil and name_update.requirements[campaign_key] ~= nil then
						should_rename = false;
						local region_list = faction:region_list();
						local requirements = unique_table:new();

						for k = 0, region_list:num_items() - 1 do
							local region = region_list:item_at(k);
							local province = region:province_name();

							if faction:holds_entire_province(province, false) == true then
								requirements:insert(province);
							end
						end

						if #requirements.items >= name_update.requirements[campaign_key].count then
							if #name_update.requirements[campaign_key].provinces > 0 then
								if #requirements.items >= #name_update.requirements[campaign_key].provinces then
									should_rename = true;

									for l = 1, #name_update.requirements[campaign_key].provinces do
										if requirements:contains(name_update.requirements[campaign_key].provinces[l]) == false then
											should_rename = false;
											break;
										end
									end
								end
							else
								should_rename = true;
							end
						end

						if should_rename == true and name_update.requirements[campaign_key].only_lord == true then
							for k = 1, #name_update.factions do
								if name_update.factions[k] ~= faction_key then
									local faction_obj = cm:model():world():faction_by_key(name_update.factions[k]);

									if faction_obj:is_dead() == false then
										should_rename = false;
										break;
									end
								end
							end
						end
					end

					if should_rename == true then
						cm:change_localised_faction_name(faction_key, "campaign_localised_strings_string_"..name_update.new_name);
					end
					break;
				end
			end
		end
	end
end