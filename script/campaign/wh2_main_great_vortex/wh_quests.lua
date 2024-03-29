
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	QUESTS
--	This script kicks off character quests when they rank up to the required level
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

local alt_quests = {};

function q_setup()	

	----------------------
	----- HIGH ELVES -----
	----------------------	
	
	local tyrion_setup = {
		subtype = "wh2_main_hef_tyrion", 
		faction = "wh2_main_hef_eataine", 
		quests = {
			{"mission", "wh2_main_anc_armour_dragon_armour_of_aenarion", "wh2_main_great_vortex_hef_tyrion_dragon_armour_of_aenarion_stage_1", 6, "wh2_main_great_vortex_hef_tyrion_dragon_armour_of_aenarion_stage_4_mpc", "war.camp.advice.quest.tyrion.dragon_armour_of_aenarion.001"},
			{"mission", "wh2_main_anc_weapon_sunfang", "wh2_main_great_vortex_hef_tyrion_sunfang_stage_1", 10, "wh2_main_great_vortex_hef_tyrion_sunfang_stage_4_mpc", "war.camp.advice.quest.tyrion.sunfang.001"},
			{"ai_only", "wh2_main_anc_enchanted_item_heart_of_avelorn", nil, 14},
			{"mission", "wh2_main_anc_enchanted_item_heart_of_avelorn", "wh2_main_vortex_narrative_hef_the_phoenix_gate", 2}
		}		
	};
	set_up_rank_up_listener(tyrion_setup.quests, tyrion_setup.subtype, nil, tyrion_setup.faction);
	add_to_alt_quests("wh2_main_anc_enchanted_item_heart_of_avelorn", "wh2_main_vortex_narrative_hef_the_phoenix_gate", tyrion_setup.subtype);
	
	local teclis_setup = {
		subtype = "wh2_main_hef_teclis", 
		faction = "wh2_main_hef_order_of_loremasters", 
		quests = {
			{"mission", "wh2_main_anc_arcane_item_war_crown_of_saphery", "wh2_main_great_vortex_hef_teclis_war_crown_of_saphery_stage_1", 6, "wh2_main_great_vortex_hef_teclis_war_crown_of_saphery_stage_3_mpc", "war.camp.advice.quest.teclis.war_crown_of_saphery.001"},
			{"mission", "wh2_main_anc_weapon_sword_of_teclis", "wh2_main_great_vortex_hef_teclis_sword_of_teclis_stage_1", 10, "wh2_main_great_vortex_hef_teclis_sword_of_teclis_stage_3_mpc", "war.camp.advice.quest.teclis.sword_of_teclis.001"},
			{"ai_only", "wh2_main_anc_arcane_item_moon_staff_of_lileath", nil, 14},
			{"ai_only", "wh2_main_anc_arcane_item_scroll_of_hoeth", nil, 18},
			{"mission", "wh2_main_anc_arcane_item_scroll_of_hoeth", "wh2_main_vortex_narrative_hef_the_lies_of_the_druchii", 2},
			{"mission", "wh2_main_anc_arcane_item_moon_staff_of_lileath", "wh2_main_vortex_narrative_hef_the_vermin_of_hruddithi", 4}
		}		
	};
	set_up_rank_up_listener(teclis_setup.quests, teclis_setup.subtype, nil, teclis_setup.faction);
	add_to_alt_quests("wh2_main_anc_arcane_item_scroll_of_hoeth", "wh2_main_vortex_narrative_hef_the_lies_of_the_druchii", teclis_setup.subtype);
	add_to_alt_quests("wh2_main_anc_arcane_item_moon_staff_of_lileath", "wh2_main_vortex_narrative_hef_the_vermin_of_hruddithi", teclis_setup.subtype);

	local alarielle_setup = {
		subtype = "wh2_dlc10_hef_alarielle", 
		faction = "wh2_main_hef_avelorn", 
		quests = {
			{"mission", "wh2_dlc10_anc_talisman_shieldstone_of_isha", "wh2_dlc10_vortex_alarielle_shieldstone_of_isha_1", 2},
			{"mission", "wh2_dlc10_anc_enchanted_item_star_of_avelorn", "wh2_dlc10_great_vortex_hef_alarielle_star_of_avelorn_stage_1", 15, "wh2_dlc10_great_vortex_hef_alarielle_star_of_avelorn_stage_5_mpc"}
		}		
	};
	set_up_rank_up_listener(alarielle_setup.quests, alarielle_setup.subtype, nil, alarielle_setup.faction);
	add_to_alt_quests("wh2_dlc10_anc_talisman_shieldstone_of_isha", "wh2_dlc10_vortex_alarielle_shieldstone_of_isha_1", alarielle_setup.subtype);

	local alith_anar_setup = {
		subtype = "wh2_dlc10_hef_alith_anar", 
		faction = "wh2_main_hef_nagarythe", 
		quests = {
			{"mission", "wh2_dlc10_anc_enchanted_item_the_shadow_crown", "wh2_dlc10_great_vortex_hef_alith_anar_the_shadow_crown", 2},
			{"mission", "wh2_dlc10_anc_weapon_moonbow", "wh2_dlc10_great_vortex_hef_alith_anar_the_moonbow_stage_1", 5, "wh2_dlc10_great_vortex_hef_alith_anar_the_moonbow_stage_4_mpc"}
		}		
	};
	set_up_rank_up_listener(alith_anar_setup.quests, alith_anar_setup.subtype, nil, alith_anar_setup.faction);
	add_to_alt_quests("wh2_dlc10_anc_enchanted_item_the_shadow_crown", "wh2_dlc10_great_vortex_hef_alith_anar_the_shadow_crown", alith_anar_setup.subtype);

	local eltharion_setup = {
		subtype = "wh2_dlc15_hef_eltharion", 
		faction = "wh2_main_hef_yvresse", 
		quests = {
			{"mission","wh2_dlc15_anc_talisman_talisman_of_hoeth","wh2_dlc15_vortex_hef_eltharion_talisman_of_hoeth_stage_1",5,"wh2_dlc15_vortex_hef_eltharion_talisman_of_hoeth_stage_3_mpc"},
			{"mission","wh2_dlc15_anc_armour_helm_of_yvresse","wh2_dlc15_vortex_hef_eltharion_helm_of_yvresse_stage_1",7},
			{"mission","wh2_dlc15_anc_weapon_fangsword_of_eltharion","wh2_dlc15_vortex_hef_eltharion_fangsword_of_eltharion_stage_1",10}
		}		
	};
	set_up_rank_up_listener(eltharion_setup.quests, eltharion_setup.subtype, nil, eltharion_setup.faction);
	add_to_alt_quests("wh2_dlc15_anc_weapon_fangsword_of_eltharion","wh2_dlc15_vortex_hef_eltharion_fangsword_of_eltharion_stage_1", eltharion_setup.subtype);
	add_to_alt_quests("wh2_dlc15_anc_armour_helm_of_yvresse","wh2_dlc15_vortex_hef_eltharion_helm_of_yvresse_stage_1", eltharion_setup.subtype);

	local imrik_setup = {
		subtype = "wh2_dlc15_hef_imrik", 
		faction = "wh2_dlc15_hef_imrik", 
		quests = {
			{"mission","wh2_dlc15_anc_armour_armour_of_caledor","wh2_dlc15_vortex_hef_imrik_armour_of_caledor_stage_1",5,"wh2_dlc15_vortex_hef_imrik_armour_of_caledor_stage_3_mpc"}
		}		
	};
	set_up_rank_up_listener(imrik_setup.quests, imrik_setup.subtype, nil, imrik_setup.faction);

	----------------------
	----- DARK ELVES -----
	----------------------	

	local malekith_setup = {
		subtype = "wh2_main_def_malekith", 
		faction = "wh2_main_def_naggarond", 
		quests = {
			{"mission", "wh2_main_anc_arcane_item_circlet_of_iron", "wh2_main_great_vortex_def_malekith_circlet_of_iron_stage_1", 6, "wh2_main_great_vortex_def_malekith_circlet_of_iron_stage_3_mpc", "war.camp.advice.quest.malekith.circlet_of_iron.001"},
			{"mission", "wh2_main_anc_weapon_destroyer", "wh2_main_great_vortex_def_malekith_destroyer_stage_1", 10, "wh2_main_great_vortex_def_malekith_destroyer_stage_3_mpc", "war.camp.advice.quest.malekith.destroyer.001"},
			{"mission", "wh2_main_anc_armour_supreme_spellshield", "wh2_main_great_vortex_def_malekith_supreme_spellshield_stage_1", 14, "wh2_main_great_vortex_def_malekith_supreme_spellshield_stage_3_mpc", "war.camp.advice.quest.malekith.supreme_spellshield.001"},
			{"ai_only", "wh2_main_anc_armour_armour_of_midnight", nil, 18},
			{"mission", "wh2_main_anc_armour_armour_of_midnight", "wh2_main_vortex_narrative_def_hoteks_levy", 2}
		}
	};
	set_up_rank_up_listener(malekith_setup.quests, malekith_setup.subtype, nil, malekith_setup.faction);
	add_to_alt_quests("wh2_main_anc_armour_armour_of_midnight", "wh2_main_vortex_narrative_def_hoteks_levy", malekith_setup.subtype);

	local morathi_setup = {
		subtype = "wh2_main_def_morathi", 
		faction = "wh2_main_def_cult_of_pleasure", 
		quests = {
			{"mission", "wh2_main_anc_weapon_heartrender_and_the_darksword", "wh2_main_great_vortex_def_morathi_heartrender_and_the_darksword_stage_1", 6, "wh2_main_great_vortex_def_morathi_heartrender_and_the_darksword_stage_6_mpc", "war.camp.advice.quest.morathi.heartrender_and_the_darksword.001"},
			{"mission", "wh2_main_anc_arcane_item_wand_of_the_kharaidon", "wh2_dlc14_def_wand_of_kharaidon", 4},
			{"mission", "wh2_main_anc_talisman_amber_amulet", "wh2_dlc14_def_amber_amulet", 2}
		}
	};
	set_up_rank_up_listener(morathi_setup.quests, morathi_setup.subtype, nil, morathi_setup.faction);
	add_to_alt_quests("wh2_main_anc_arcane_item_wand_of_the_kharaidon", "wh2_dlc14_def_wand_of_kharaidon", morathi_setup.subtype);
	add_to_alt_quests("wh2_main_anc_talisman_amber_amulet", "wh2_dlc14_def_amber_amulet", morathi_setup.subtype);

	local hellebron_setup = {
		subtype = "wh2_dlc10_def_crone_hellebron", 
		faction = "wh2_main_def_har_ganeth", 
		quests = {
			{"mission", "wh2_dlc10_anc_weapon_deathsword_and_the_cursed_blade", "wh2_dlc10_great_vortex_def_hellebron_deathsword_and_the_cursed_blade_stage_1", 8, "wh2_dlc10_great_vortex_def_hellebron_deathsword_and_the_cursed_blade_stage_4_mpc"},
			{"mission", "wh2_dlc10_anc_talisman_amulet_of_dark_fire", "wh2_dlc10_great_vortex_def_hellebron_amulet_of_dark_fire_stage_1", 2}
		}
	};
	set_up_rank_up_listener(hellebron_setup.quests, hellebron_setup.subtype, nil, hellebron_setup.faction);
	add_to_alt_quests("wh2_dlc10_anc_talisman_amulet_of_dark_fire", "wh2_dlc10_great_vortex_def_hellebron_amulet_of_dark_fire_stage_1", hellebron_setup.subtype);
	
	local lokhir_setup = {
		subtype = "wh2_dlc11_def_lokhir", 
		faction = "wh2_dlc11_def_the_blessed_dread", 
		quests = {
			{"mission", "wh2_main_anc_armour_helm_of_the_kraken", "wh2_dlc11_great_vortex_lokhir_helm_of_the_kraken_stage_1", 11, "wh2_dlc11_great_vortex_lokhir_fellheart_helm_of_the_kraken_mp", "wh2_dlc11.camp.advice.quest.lokhir.001"},
			{"mission", "wh2_dlc11_anc_weapon_red_blades", "wh2_dlc11_great_vortex_def_lokhir_red_blades_stage_1", 2}
		}
	};
	set_up_rank_up_listener(lokhir_setup.quests, lokhir_setup.subtype, nil, lokhir_setup.faction);
	add_to_alt_quests("wh2_dlc11_anc_weapon_red_blades", "wh2_dlc11_great_vortex_def_lokhir_red_blades_stage_1", lokhir_setup.subtype);

	local malus_setup = {
		subtype = "wh2_dlc14_def_malus_darkblade", 
		faction = "wh2_main_def_hag_graef", 
		quests = {
			{"mission", "wh2_dlc14_anc_weapon_warpsword_of_khaine", "wh2_dlc14_vortex_def_malus_warpsword_of_khaine_stage_1", 5, "wh2_dlc14_vortex_def_malus_warpsword_of_khaine_stage_4_mpc"}
		}
	};
	set_up_rank_up_listener(malus_setup.quests, malus_setup.subtype, nil, malus_setup.faction);

	local rakarth_setup = {
		subtype = "wh2_twa03_def_rakarth", 
		faction = "wh2_twa03_def_rakarth", 
		quests = {
			{"mission", "wh2_twa03_anc_weapon_whip_of_agony", "wh2_twa03_great_vortex_def_rakarth_whip_of_agony_stage_1", 2, "wh2_twa03_great_vortex_def_rakarth_whip_of_agony_stage_2_mpc"}
		}
	};
	set_up_rank_up_listener(rakarth_setup.quests, rakarth_setup.subtype, nil, rakarth_setup.faction);

	----------------------
	------ LIZARDMEN -----
	----------------------	

	local mazdamundi_setup = {
		subtype = "wh2_main_lzd_lord_mazdamundi", 
		faction = "wh2_main_lzd_hexoatl", 
		quests = {
			{"mission", "wh2_main_anc_magic_standard_sunburst_standard_of_hexoatl", "wh2_main_great_vortex_lzd_mazdamundi_sunburst_standard_of_hexoatl_stage_1", 6, "wh2_main_great_vortex_lzd_mazdamundi_sunburst_standard_of_hexoatl_stage_4_mpc", "war.camp.advice.quest.mazdamundi.sunburst_standard_of_hexoatl.001"},
			{"mission", "wh2_main_anc_weapon_cobra_mace_of_mazdamundi", "wh2_main_great_vortex_lzd_mazdamundi_cobra_mace_of_mazdamundi_stage_1", 10, "wh2_main_great_vortex_lzd_mazdamundi_cobra_mace_of_mazdamundi_stage_3_mpc", "war.camp.advice.quest.mazdamundi.cobra_mace_of_mazdamundi.001"}
		}
	};
	set_up_rank_up_listener(mazdamundi_setup.quests, mazdamundi_setup.subtype, nil, mazdamundi_setup.faction);

	local kroq_gar_setup = {
		subtype = "wh2_main_lzd_kroq_gar", 
		faction = "wh2_main_lzd_last_defenders", 
		quests = {
			{"mission", "wh2_main_anc_weapon_revered_spear_of_tlanxla", "wh2_main_great_vortex_liz_kroq_gar_revered_spear_of_tlanxla_stage_1", 6, "wh2_main_great_vortex_liz_kroq_gar_revered_spear_of_tlanxla_stage_3_mpc", "war.camp.advice.quest.kroqgar.revered_spear_of_tlanxla.001"},
			{"mission", "wh2_main_anc_enchanted_item_hand_of_gods", "wh2_main_great_vortex_liz_kroq_gar_hand_of_gods_stage_1", 10, "wh2_main_great_vortex_liz_kroq_gar_hand_of_gods_stage_3_mpc", "war.camp.advice.quest.kroqgar.hand_of_gods.001"}
			}
	};
	set_up_rank_up_listener(kroq_gar_setup.quests, kroq_gar_setup.subtype, nil, kroq_gar_setup.faction);
	
	local tehenhauin_setup = {
		subtype = "wh2_dlc12_lzd_tehenhauin", 
		faction = "wh2_dlc12_lzd_cult_of_sotek", 
		quests = {
			{"mission", "wh2_dlc12_anc_enchanted_item_plaque_of_sotek", "wh2_dlc12_great_vortex_lzd_tehenhauin_plaque_of_sotek_stage_1", 8, "wh2_dlc12_great_vortex_lzd_tehenhauin_plaque_of_sotek_mp"}
		}
	};
	set_up_rank_up_listener(tehenhauin_setup.quests, tehenhauin_setup.subtype, nil, tehenhauin_setup.faction);
	
	local tiktaqto_setup = {
		subtype = "wh2_dlc12_lzd_tiktaqto", 
		faction = "wh2_main_lzd_tlaqua", 
		quests = {
			{"mission", "wh2_dlc12_anc_enchanted_item_mask_of_heavens", "wh2_dlc12_great_vortex_lzd_tiktaqto_mask_of_heavens_stage_1", 8, "wh2_dlc12_great_vortex_lzd_tiktaqto_mask_of_heavens_mp"}
		}
	};
	set_up_rank_up_listener(tiktaqto_setup.quests, tiktaqto_setup.subtype, nil, tiktaqto_setup.faction);
	
	local nakai_setup = {
		subtype = "wh2_dlc13_lzd_nakai", 
		faction = "wh2_dlc13_lzd_spirits_of_the_jungle", 
		quests = {
			{"mission", "wh2_dlc13_anc_enchanted_item_golden_tributes", "wh2_dlc13_vortex_lzd_nakai_golden_tributes_stage_1", 8, "wh2_dlc13_vortex_lzd_nakai_golden_tributes_stage_3"},
			{"mission", "wh2_dlc13_talisman_the_ogham_shard", "wh2_dlc13_vortex_lzd_nakai_the_ogham_shard_stage_1", 8, "wh2_dlc13_vortex_lzd_nakai_the_ogham_shard_stage_2"}
		}
	};
	set_up_rank_up_listener(nakai_setup.quests, nakai_setup.subtype, nil, nakai_setup.faction);
	
	local gor_rok_setup = {
		subtype = "wh2_dlc13_lzd_gor_rok", 
		faction = "wh2_main_lzd_itza", 
		quests = {
			{"mission", "wh2_dlc13_anc_armour_the_shield_of_aeons", "wh2_dlc13_vortex_gorrok_the_shield_of_aeons_stage_1", 8, "wh2_dlc13_vortex_gorrok_the_shield_of_aeons_stage_3"},
			{"mission", "wh2_dlc13_anc_weapon_mace_of_ulumak", "wh2_dlc14_lzd_the_mace_of_ulumak", 2}
		}
	};
	set_up_rank_up_listener(gor_rok_setup.quests, gor_rok_setup.subtype, nil, gor_rok_setup.faction);
	add_to_alt_quests("wh2_dlc13_anc_weapon_mace_of_ulumak", "wh2_dlc14_lzd_the_mace_of_ulumak", gor_rok_setup.subtype);
	
	local oxyotl_setup = {
		subtype = "wh2_dlc17_lzd_oxyotl", 
		faction = "wh2_dlc17_lzd_oxyotl", 
		quests = {
			{"mission", "wh2_dlc17_anc_weapon_the_golden_blowpipe_of_ptoohee", "wh2_dlc17_great_vortex_lzd_oxyotl_the_golden_blowpipe_of_ptoohee_stage_1", 5, "wh2_dlc17_great_vortex_lzd_oxyotl_the_golden_blowpipe_of_ptoohee_stage_4b_mpc"}
		}
	};
	set_up_rank_up_listener(oxyotl_setup.quests, oxyotl_setup.subtype, nil, oxyotl_setup.faction);

	----------------------
	------- SKAVEN -------
	----------------------	

	local queek_setup = {
		subtype = "wh2_main_skv_queek_headtaker", 
		faction = "wh2_main_skv_clan_mors", 
		quests = {
			{"mission", "wh2_main_anc_armour_warp_shard_armour", "wh2_main_great_vortex_skv_queek_headtaker_warp_shard_armour_stage_1", 6, "wh2_main_great_vortex_skv_queek_headtaker_warp_shard_armour_stage_6_mpc", "war.camp.advice.quest.queek.warp_shard_armour.001"},
			{"mission", "wh2_main_anc_weapon_dwarf_gouger", "wh2_main_great_vortex_skv_queek_headtaker_dwarfgouger_stage_1", 10, "wh2_main_great_vortex_skv_queek_headtaker_dwarfgouger_stage_4_mpc", "war.camp.advice.quest.queek.dwarfgouger.001"}
		}
	};
	set_up_rank_up_listener(queek_setup.quests, queek_setup.subtype, nil, queek_setup.faction);

	local skrolk_setup = {
		subtype = "wh2_main_skv_lord_skrolk", 
		faction = "wh2_main_skv_clan_pestilens", 
		quests = {
			{"mission", "wh2_main_anc_arcane_item_the_liber_bubonicus", "wh2_main_great_vortex_skv_skrolk_liber_bubonicus_stage_1", 6, "wh2_main_great_vortex_skv_skrolk_liber_bubonicus_stage_3_mpc", "war.camp.advice.quest.skrolk.liber_bubonicus.001"},
		{"mission", "wh2_main_anc_weapon_rod_of_corruption", "wh2_main_great_vortex_skv_skrolk_rod_of_corruption_stage_1", 10, "wh2_main_great_vortex_skv_skrolk_rod_of_corruption_stage_3_mpc", "war.camp.advice.quest.skrolk.rod_of_corruption.001"}
		}
	};
	set_up_rank_up_listener(skrolk_setup.quests, skrolk_setup.subtype, nil, skrolk_setup.faction);
	
	local tretch_setup = {
		subtype = "wh2_dlc09_skv_tretch_craventail", 
		faction = "wh2_dlc09_skv_clan_rictus", 
		quests = {
			{"mission", "wh2_dlc09_anc_enchanted_item_lucky_skullhelm", "wh2_dlc09_great_vortex_skv_tretch_lucky_skullhelm_stage_1", 8, "wh2_dlc09_great_vortex_skv_tretch_lucky_skullhelm_stage_5_mpc", "dlc09.camp.advice.quest.tretch.lucky_skullhelm.001"}
		}
	};
	set_up_rank_up_listener(tretch_setup.quests, tretch_setup.subtype, nil, tretch_setup.faction);
	
	local ikit_setup = {
		subtype = "wh2_dlc12_skv_ikit_claw", 
		faction = "wh2_main_skv_clan_skyre", 
		quests = {
			{"mission", "wh2_dlc12_anc_weapon_storm_daemon", "wh2_dlc12_great_vortex_ikit_claw_storm_daemon_stage_1", 8, "wh2_dlc12_great_vortex_ikit_claw_storm_daemon_mp"}
		}
	};
	set_up_rank_up_listener(ikit_setup.quests, ikit_setup.subtype, nil, ikit_setup.faction);
	
	local snikch_setup = {
		subtype = "wh2_dlc14_skv_deathmaster_snikch", 
		faction = "wh2_main_skv_clan_eshin", 
		quests = {
			{"mission", "wh2_dlc14_anc_armour_the_cloak_of_shadows", "wh2_dlc14_vortex_skv_snikch_the_cloak_of_shadows_stage_1", 5, "wh2_dlc14_vortex_skv_snikch_the_cloak_of_shadows_stage_4_mpc"},
			{"mission", "wh2_dlc14_anc_weapon_whirl_of_weeping_blades", "wh2_dlc14_vortex_skv_snikch_whirl_of_weeping_blades_stage_1", 3}
		}
	};
	set_up_rank_up_listener(snikch_setup.quests, snikch_setup.subtype, nil, snikch_setup.faction);
	add_to_alt_quests("wh2_dlc14_anc_weapon_whirl_of_weeping_blades", "wh2_dlc14_vortex_skv_snikch_whirl_of_weeping_blades_stage_1", snikch_setup.subtype);

	local throt_setup = {
		subtype = "wh2_dlc16_skv_throt_the_unclean", 
		faction = "wh2_main_skv_clan_moulder", 
		quests = {
			{"mission", "wh2_dlc16_anc_enchanted_item_whip_of_domination", "wh2_dlc16_skv_throt_vortex_whip_of_domination_stage_1", 5, "wh2_dlc16_skv_throt_vortex_whip_of_domination_stage_4_mpc"},
			{"mission", "wh2_dlc16_anc_weapon_creature_killer", "wh2_dlc16_skv_throt_vortex_creature_killer_stage_1", 3}
		}
	};
	set_up_rank_up_listener(throt_setup.quests, throt_setup.subtype, nil, throt_setup.faction);
	add_to_alt_quests("wh2_dlc16_anc_weapon_creature_killer", "wh2_dlc16_skv_throt_vortex_creature_killer_stage_1", throt_setup.subtype);

	----------------------
	----- TOMB KINGS -----
	----------------------	

	local settra_setup = {
		subtype = "wh2_dlc09_tmb_settra", 
		faction = "wh2_dlc09_tmb_khemri", 
		quests = {
			{"mission", "wh2_dlc09_anc_enchanted_item_the_crown_of_nehekhara", "wh2_dlc09_great_vortex_tmb_settra_the_crown_of_nehekhara_stage_1", 6, "wh2_dlc09_great_vortex_tmb_settra_the_crown_of_nehekhara_stage_5_mpc", "dlc09.camp.advice.quest.settra.the_crown_of_nehekhara.001"},
			{"mission", "wh2_dlc09_anc_weapon_the_blessed_blade_of_ptra", "wh2_dlc09_great_vortex_tmb_settra_the_blessed_blade_of_ptra_stage_1", 13, "wh2_dlc09_great_vortex_tmb_settra_the_blessed_blade_of_ptra_stage_3_mpc", "dlc09.camp.advice.quest.settra.the_blessed_blade_of_ptra.001"}
		}
	};
	set_up_rank_up_listener(settra_setup.quests, settra_setup.subtype, nil, settra_setup.faction);
	
	local arkhan_setup = {
		subtype = "wh2_dlc09_tmb_arkhan", 
		faction = "wh2_dlc09_tmb_followers_of_nagash", 
		quests = {
			{"mission", "wh2_dlc09_anc_weapon_the_tomb_blade_of_arkhan", "wh2_dlc09_great_vortex_tmb_arkhan_the_tomb_blade_of_arkhan_stage_1", 6, "wh2_dlc09_great_vortex_tmb_arkhan_the_tomb_blade_of_arkhan_stage_4_mpc", "dlc09.camp.advice.quest.arkhan.the_tomb_blade_of_arkhan.001"}
		}
	};
	set_up_rank_up_listener(arkhan_setup.quests, arkhan_setup.subtype, nil, arkhan_setup.faction);
	
	local khatep_setup = {
		subtype = "wh2_dlc09_tmb_khatep", 
		faction = "wh2_dlc09_tmb_exiles_of_nehek", 
		quests = {
			{"mission", "wh2_dlc09_anc_arcane_item_the_liche_staff", "wh2_dlc09_vortex_tmb_khatep_the_liche_staff_1", 6, "wh2_dlc09_great_vortex_tmb_khatep_the_liche_staff_stage_5_mpc", "dlc09.camp.advice.quest.khatep.the_liche_staff.001"}
		}
	};
	set_up_rank_up_listener(khatep_setup.quests, khatep_setup.subtype, nil, khatep_setup.faction);
	
	local khalida_setup = {
		subtype = "wh2_dlc09_tmb_khalida", 
		faction = "wh2_dlc09_tmb_lybaras", 
		quests = {
			{"mission", "wh2_dlc09_anc_weapon_the_venom_staff", "wh2_dlc09_great_vortex_tmb_khalida_venom_staff_stage_1", 12, "wh2_dlc09_great_vortex_tmb_khalida_venom_staff_stage_3_mpc", "dlc09.camp.advice.quest.khalida.venom_staff.001"}
		}
	};
	set_up_rank_up_listener(khalida_setup.quests, khalida_setup.subtype, nil, khalida_setup.faction);
	
	----------------------
	---- VAMPIRE COAST ---
	----------------------	

	local harkon_setup = {
		subtype = "wh2_dlc11_cst_harkon", 
		faction = "wh2_dlc11_cst_vampire_coast", 
		quests = {
			{"mission", "wh2_dlc11_anc_enchanted_item_slann_gold", "wh2_dlc11_cst_vortex_harkon_quest_for_slann_gold_stage_1", 15, "wh2_dlc11_great_vortex_qb_cst_luthor_harkon_slann_gold_MP", "wh2_dlc11.camp.advice.quest.harkon.001"}
		}
	};
	set_up_rank_up_listener(harkon_setup.quests, harkon_setup.subtype, nil, harkon_setup.faction);
	
	local noctilus_setup = {
		subtype = "wh2_dlc11_cst_noctilus", 
		faction = "wh2_dlc11_cst_noctilus", 
		quests = {
			{"mission", "wh2_dlc11_anc_enchanted_item_captain_roths_moondial", "wh2_dlc11_cst_vortex_noctilus_captain_roths_moondial_stage_1", 15, "wh2_dlc11_great_vortex_qb_cst_noctilus_captain_roths_moondial_MP", "wh2_dlc11.camp.advice.quest.noctilus.001"}
		}
	};
	set_up_rank_up_listener(noctilus_setup.quests, noctilus_setup.subtype, nil, noctilus_setup.faction);
	
	local aranessa_setup = {
		subtype = "wh2_dlc11_cst_aranessa", 
		faction = "wh2_dlc11_cst_pirates_of_sartosa", 
		quests = {
			{"mission", "wh2_dlc11_anc_weapon_krakens_bane", "wh2_dlc11_great_vortex_cst_aranessa_krakens_bane_stage_1", 15, "wh2_dlc11_great_vortex_qb_cst_aranessa_saltspite_krakens_bane_MP", "wh2_dlc11.camp.advice.quest.aranessa.001"}
		}
	};
	set_up_rank_up_listener(aranessa_setup.quests, aranessa_setup.subtype, nil, aranessa_setup.faction);
	
	local cylostra_setup = {
		subtype = "wh2_dlc11_cst_cylostra", 
		faction = "wh2_dlc11_cst_the_drowned", 
		quests = {
			{"mission", "wh2_dlc11_anc_arcane_item_the_bordeleaux_flabellum", "wh2_dlc11_great_vortex_cst_cylostra_the_bordeleaux_flabellum_stage_1", 9, "wh2_dlc11_great_vortex_cylostra_the_bordeleaux_flabellum_mp", "wh2_dlc11.camp.advice.quest.cylostra.001"}
		}
	};
	set_up_rank_up_listener(cylostra_setup.quests, cylostra_setup.subtype, nil, cylostra_setup.faction);
	
	----------------------
	------- EMPIRE -------
	----------------------	

	local wulfhart_setup = {
		subtype = "wh2_dlc13_emp_cha_markus_wulfhart_0", 
		faction = "wh2_dlc13_emp_the_huntmarshals_expedition", 
		quests = {
			{"mission", "wh2_dlc13_anc_weapon_amber_bow", "wh2_dlc13_emp_wulfhart_vor_amber_bow_stage_1", 8,"wh2_dlc13_vortex_emp_wulfhart_amber_bow_stage_4"}
		}	
	};
	set_up_rank_up_listener(wulfhart_setup.quests, wulfhart_setup.subtype, nil, wulfhart_setup.faction);

	----------------------
	------ BRETONNIA -----
	----------------------	

	local repanse_setup = {
		subtype = "wh2_dlc14_brt_repanse", 
		faction = "wh2_dlc14_brt_chevaliers_de_lyonesse", 
		quests = {
			{"mission", "wh2_dlc14_anc_weapon_sword_of_lyonesse", "wh2_dlc14_vortex_brt_repanse_sword_of_lyonesse_stage_1", 5, "wh2_dlc14_vortex_brt_repanse_sword_of_lyonesse_stage_4_mpc"}
		}
	};
	set_up_rank_up_listener(repanse_setup.quests, repanse_setup.subtype, nil, repanse_setup.faction);


	----------------------
	----- GREENSKINS -----
	----------------------	

	local grom_setup = {
		subtype = "wh2_dlc15_grn_grom_the_paunch", 
		faction = "wh2_dlc15_grn_broken_axe", 
		quests = {
			{"mission", "wh2_dlc15_anc_weapon_axe_of_grom", "wh2_dlc15_vortex_grn_grom_axe_of_grom_stage_1", 5,"wh2_dlc15_vortex_grn_grom_axe_of_grom_stage_4_mpc"},
			{"mission", "wh2_dlc15_anc_enchanted_item_lucky_banner", "wh2_dlc15_main_grn_grom_lucky_banner_stage_1", 2}
		}
	};
	set_up_rank_up_listener(grom_setup.quests, grom_setup.subtype, nil, grom_setup.faction);
	add_to_alt_quests("wh2_dlc15_anc_enchanted_item_lucky_banner", "wh2_dlc15_main_grn_grom_lucky_banner_stage_1", grom_setup.subtype);

	----------------------
	----- WOOD ELVES -----
	----------------------	

	local sisters_setup = {
		subtype = "wh2_dlc16_wef_sisters_of_twilight", 
		faction = "wh2_dlc16_wef_sisters_of_twilight", 
		quests = {
			{"mission", "wh2_dlc16_anc_mount_wef_cha_sisters_of_twilight_forest_dragon", "wh2_dlc16_great_vortex_wef_sisters_dragon_stage_1", 12,"wh2_dlc16_great_vortex_wef_sisters_dragon_stage_4_mpc"}
		}		
	};
	set_up_rank_up_listener(sisters_setup.quests, sisters_setup.subtype, nil, sisters_setup.faction);

	----------------------
	------ BEASTMEN ------
	----------------------	
	
	local taurox_setup = {
		subtype = "wh2_dlc17_bst_taurox", 
		faction = "wh2_dlc17_bst_taurox", 
		quests = {
			{"mission", "wh2_dlc17_anc_weapon_rune_tortured_axes", "wh2_dlc17_great_vortex_bst_taurox_rune_tortured_axes_stage_1", 5,"wh2_dlc17_great_vortex_bst_taurox_rune_tortured_axes_stage_3_mpc"}
		}
	};
	set_up_rank_up_listener(taurox_setup.quests, taurox_setup.subtype, nil, taurox_setup.faction);
	
	local malagor_setup = {
		subtype = "dlc03_bst_malagor",
		faction = "wh2_dlc17_bst_malagor", 
		quests = {
			{"mission", "wh_dlc03_anc_talisman_icon_of_vilification", "wh_dlc03_bst_malagor_the_dark_omen_the_icons_of_vilification_stage_6_vortex", 5,"wh_dlc03_bst_malagor_the_dark_omen_the_icons_of_vilification_stage_6_vortex"}
		}
	};
	set_up_rank_up_listener(malagor_setup.quests, malagor_setup.subtype, nil, malagor_setup.faction);
	
	local khazrak_setup = {
		subtype = "dlc03_bst_khazrak", 
		faction = "wh_dlc03_bst_beastmen", 
		quests = {
			{"mission", "wh_dlc03_anc_weapon_scourge", "wh_dlc03_qb_bst_khazrak_one_eye_scourge_stage_4_slaughter_at_grimminhagen_vortex", 5,"wh_dlc03_qb_bst_khazrak_one_eye_scourge_stage_4_slaughter_at_grimminhagen_vortex"},
			{"mission", "wh_dlc03_anc_armour_the_dark_mail", "wh_dlc03_qb_bst_khazrak_one_eye_the_dark_mail_stage_5_ashes_of_kelp_and_koldust_vortex", 10,"wh_dlc03_qb_bst_khazrak_one_eye_the_dark_mail_stage_5_ashes_of_kelp_and_koldust_vortex"}
		}		
	};
	set_up_rank_up_listener(khazrak_setup.quests, khazrak_setup.subtype, nil, khazrak_setup.faction);
	
	local morghur_setup = {
		subtype = "dlc05_bst_morghur", 
		faction = "wh_dlc05_bst_morghur_herd", 
		quests = {
			{"mission", "wh_main_anc_weapon_stave_of_ruinous_corruption", "wh_dlc05_qb_bst_morghur_stave_of_ruinous_corruption_stage_4_morghur_lair_vortex", 5,"wh_dlc05_qb_bst_morghur_stave_of_ruinous_corruption_stage_4_morghur_lair_vortex"}
		}		
	};
	set_up_rank_up_listener(morghur_setup.quests, morghur_setup.subtype, nil, morghur_setup.faction);

	----------------------
	------- DWARFS -------
	----------------------	

	local thorek_setup = {
		subtype = "wh2_dlc17_dwf_thorek", 
		faction = "wh2_dlc17_dwf_thorek_ironbrow", 
		quests = {
			{"mission", "wh2_dlc17_anc_weapon_klad_brakak", "wh2_dlc17_great_vortex_dwf_thorek_klad_brakak_stage_1", 5,"wh2_dlc17_great_vortex_dwf_thorek_klad_brakak_stage_4_mp"},
			{"mission", "wh2_dlc17_anc_armour_thoreks_rune_armour", "wh2_dlc17_great_vortex_dwf_thorek_rune_armour_quest", 3, "wh2_dlc17_great_vortex_dwf_thorek_rune_armour_quest"}
		}
	};
	set_up_rank_up_listener(thorek_setup.quests, thorek_setup.subtype, nil, thorek_setup.faction);

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
	
	-- assemble infotext about quests
	local infotext = {
		1,
		"wh2.camp.advice.quests.info_001",
		"wh2.camp.advice.quests.info_002",
		"wh2.camp.advice.quests.info_003"
	};
	
	core:add_listener(
		"quest_item_listerner",
		"MissionSucceeded",
		true,
		function(context) 
			for i = 1, #alt_quests do
				if context:mission():mission_record_key() == alt_quests[i].mis then
					local character_list = context:faction():character_list();
					for j = 0, character_list:num_items() -1 do
						if character_list:item_at(j):character_subtype_key() == alt_quests[i].cha then
							cm:callback(
								function() 
									cm:force_add_ancillary(character_list:item_at(j), alt_quests[i].anc, true, true);
								end, 
								0.5);
							return true;
						end
					end
				end
			end
		end,
		true	
	);
	core:add_listener(
		"quest_item_listerner",
		"MissionCancelled",
		true,
		function(context) 
			for i = 1, #alt_quests do
				if context:mission():mission_record_key() == alt_quests[i].mis then
					local character_list = context:faction():character_list();
					for j = 0, character_list:num_items() -1 do
						if character_list:item_at(j):character_subtype_key() == alt_quests[i].cha then
							cm:force_add_ancillary(character_list:item_at(j), alt_quests[i].anc, true, false);
							return true;
						end
					end
				end
			end
		end,
		true	
	);
end;

--adds quest chains that do not end in a quest battle to a list, the chains final mission is listened for and upon completion the reward ancillary is forced upon the target character
function add_to_alt_quests(ancillary_key, final_mission_key, character_subtype)
	local alt_quest_entry = {mis = final_mission_key, anc = ancillary_key, cha = character_subtype};
	table.insert(alt_quests, alt_quest_entry);
end