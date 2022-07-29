MOON_HERD_PRIMARY = false;
MOON_HERDS = {};
MOON_INIT = false;
MOON_PHASE = 1;
MOON_MAX_PHASE = 8;
MOON_FULLMOON_PHASE = 8;
MOON_DILEMMA_PHASE = 8;
MOON_DILEMMA_PREFIX = "wh_dlc03_full_moon_preparations";
MOON_OUTCOME = "";
MOON_TIMES_TRIGGERED = 0;
MOON_LAST_DILEMMA = -1;
MOON_DILEMMA_ACTIVE = "";
MOON_LAST_EFFECT = "wh_dlc03_bundle_moon_1";
MOON_HIDE_LOG = false;

-- The percentage chances of each of the 3 moon types, equalling 100% in total.
MOON_OUTCOME_FULL_MOON_CHANCE = 35;
MOON_OUTCOME_LUNAR_ECLIPSE_CHANCE = 35;
MOON_OUTCOME_SOLAR_ECLIPSE_CHANCE = 30;
-- Sort out the ranges
MOON_OUTCOME_LUNAR_ECLIPSE_CHANCE = MOON_OUTCOME_FULL_MOON_CHANCE + MOON_OUTCOME_LUNAR_ECLIPSE_CHANCE;
MOON_OUTCOME_SOLAR_ECLIPSE_CHANCE = MOON_OUTCOME_FULL_MOON_CHANCE + MOON_OUTCOME_LUNAR_ECLIPSE_CHANCE + MOON_OUTCOME_SOLAR_ECLIPSE_CHANCE;
--Create a guaranteed Solar Eclipse for Tuarox's Rampage reward
MOON_SOLAR_ECLIPSE_GUARANTEED = false;

function Add_Moon_Phase_Listeners()	

	for i = 1, #Bloodgrounds.beastmen_factions do
		local faction_key = Bloodgrounds.beastmen_factions[i]
		local faction_interface =  cm:get_faction(faction_key)

		
		if faction_interface and faction_interface:is_human() then
			MOON_HERDS[faction_key] = true
			--- choose a 'primary' herd - moon will progress on their turn only so all the players are in sync
			if not MOON_HERD_PRIMARY then
				MOON_HERD_PRIMARY = faction_key
			end
		end

	end

	if not MOON_HERD_PRIMARY then
		return
	end

	out("#### Adding Moon Phase Listeners ####");
	out("\tSelected Herd as primary: "..MOON_HERD_PRIMARY, MOON_HIDE_LOG);


	core:add_listener(
		"MOON_DilemmaChoiceMadeEvent",
		"DilemmaChoiceMadeEvent",
		true,
		function(context) MoonDilemmaChoice(context) end,
		true
	);
	core:add_listener(
		"MOON_FactionTurnStart",
		"ScriptEventHumanFactionTurnStart",
		true,
		function(context) MoonTurnStart(context) end,
		true
	);

	--this listener is for Taurox Rampage Moon reward
	core:add_listener(
		"TauroxMoon_RitualCompletedEvent",
		"RitualCompletedEvent", 
		function(context)
			return context:performing_faction():name() == "wh2_dlc17_bst_taurox" and context:ritual():ritual_key():find("wh2_dlc17_taurox_bst_rampage_tier_2_option_3");
		end,
		function(context) 
			--this guarantees next turn a moon dilemma will trigger
			MOON_PHASE = MOON_MAX_PHASE - 1;
			ApplyMoonEffect("wh_dlc03_bundle_moon_"..MOON_PHASE, 0)
			MOON_SOLAR_ECLIPSE_GUARANTEED = true
		end,
		true
	);

	if MOON_INIT == false then
		ApplyMoonEffect("wh_dlc03_bundle_moon_"..MOON_PHASE, 0);
		MOON_INIT = true;
	end	

end

function MoonTurnStart(context)
	local faction_key = context:faction():name()

	if faction_key == MOON_HERD_PRIMARY then
		MOON_PHASE = MOON_PHASE + 1;
		if MOON_PHASE > MOON_MAX_PHASE then
			MOON_PHASE = 1;
		end
	
		if MOON_PHASE < 8 then
			-- Apply the current Moon Phase effect
			ApplyMoonEffect("wh_dlc03_bundle_moon_"..MOON_PHASE, 0);
		else
			-- Select a random moon type
			local random_chance = cm:random_number(100);
			local random_moon = cm:random_number(20);
			local moon_type = "full_moon";
			
			if cm:model():turn_number() > 8 then
				if MOON_SOLAR_ECLIPSE_GUARANTEED == true then
					ApplyMoonEffect("wh_dlc03_bundle_moon_event_solar_eclipse", 0);
					moon_type = "solar_eclipse";
				elseif random_chance <= MOON_OUTCOME_FULL_MOON_CHANCE then
					ApplyMoonEffect("wh_dlc03_bundle_moon_event_full_moon_success", 0);
					moon_type = "full_moon";
				elseif random_chance <= MOON_OUTCOME_LUNAR_ECLIPSE_CHANCE then
					ApplyMoonEffect("wh_dlc03_bundle_moon_event_lunar_eclipse", 0);
					moon_type = "lunar_eclipse";
				elseif random_chance <= MOON_OUTCOME_SOLAR_ECLIPSE_CHANCE then
					ApplyMoonEffect("wh_dlc03_bundle_moon_event_solar_eclipse", 0);
					moon_type = "solar_eclipse";
				else
					script_error("ERROR: Moon type could not be ascertained from random weighting");
				end
			else
				-- THIS WILL ALWAYS BE THE FIRST MOON
				ApplyMoonEffect("wh_dlc03_bundle_moon_event_solar_eclipse", 0);
				moon_type = "solar_eclipse";
			end
			
			MOON_OUTCOME = MOON_DILEMMA_PREFIX.."_"..moon_type.."_"..random_moon;
		end
	end
	
	if MOON_HERDS[faction_key] then
		if MOON_PHASE == MOON_FULLMOON_PHASE then
			out("Triggering Moon Dilemma Intervention", MOON_HIDE_LOG);
			Trigger_Moon_Dilemma(faction_key);
		end
	end
end

function Trigger_Moon_Dilemma(faction_key)
	-- If this is the phase we need to give the dilemma then trigger it
	if MOON_PHASE == MOON_DILEMMA_PHASE then
		MOON_TIMES_TRIGGERED = MOON_TIMES_TRIGGERED + 1;
		
		if MOON_TIMES_TRIGGERED > 8 then
			MOON_TIMES_TRIGGERED = 1;
		end
		
		out("Triggering Moon Dilemma: "..MOON_OUTCOME, MOON_HIDE_LOG);
		cm:trigger_dilemma(faction_key, MOON_OUTCOME);
	end
end

function MoonDilemmaChoice(context)
	if Is_Moon_Dilemma(context:dilemma()) then
		out("Moon Choice: "..context:choice(), MOON_HIDE_LOG);
	end
end

function ApplyMoonEffect(moon_effect, length)
	for k,v in pairs(MOON_HERDS) do
		out("Applying effect ".."wh_dlc03_bundle_moon_"..MOON_PHASE.." for "..k, MOON_HIDE_LOG);
		cm:remove_effect_bundle(MOON_LAST_EFFECT, k);
		cm:apply_effect_bundle(moon_effect, k, length);
	end
	MOON_LAST_EFFECT = moon_effect;
end

function Is_Moon_Dilemma(dilemma_key)
	if dilemma_key == nil then
		return false;
	end
	return string.sub(dilemma_key, 0, 31) == MOON_DILEMMA_PREFIX;
end

--------------------------------------------------------------
----------------------- SAVING / LOADING ---------------------
--------------------------------------------------------------
cm:add_saving_game_callback(
	function(context)
		cm:save_named_value("MOON_INIT", MOON_INIT, context);
		cm:save_named_value("MOON_SOLAR_ECLIPSE_GUARANTEED", MOON_SOLAR_ECLIPSE_GUARANTEED, context);
		cm:save_named_value("MOON_PHASE", MOON_PHASE, context);
		cm:save_named_value("MOON_OUTCOME", MOON_OUTCOME, context);
		cm:save_named_value("MOON_TIMES_TRIGGERED", MOON_TIMES_TRIGGERED, context);
		cm:save_named_value("MOON_DILEMMA_ACTIVE", MOON_DILEMMA_ACTIVE, context);
		cm:save_named_value("MOON_LAST_EFFECT", MOON_LAST_EFFECT, context);
	end
);

cm:add_loading_game_callback(
	function(context)
		MOON_INIT = cm:load_named_value("MOON_INIT", false, context);
		MOON_SOLAR_ECLIPSE_GUARANTEED = cm:load_named_value("MOON_SOLAR_ECLIPSE_GUARANTEED", MOON_SOLAR_ECLIPSE_GUARANTEED, context);
		MOON_PHASE = cm:load_named_value("MOON_PHASE", 1, context);
		MOON_OUTCOME = cm:load_named_value("MOON_OUTCOME", "", context);
		MOON_TIMES_TRIGGERED = cm:load_named_value("MOON_TIMES_TRIGGERED", 0, context);
		MOON_DILEMMA_ACTIVE = cm:load_named_value("MOON_DILEMMA_ACTIVE", "", context);
		MOON_LAST_EFFECT = cm:load_named_value("MOON_LAST_EFFECT", "wh_dlc03_bundle_moon_1", context);
	end
);

MoonMovementChoices = {
	{"wh_dlc03_full_moon_preparations_full_moon_1", 2},
	{"wh_dlc03_full_moon_preparations_full_moon_11", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_12", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_13", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_14", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_15", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_16", 1},
	{"wh_dlc03_full_moon_preparations_full_moon_2", 2},
	{"wh_dlc03_full_moon_preparations_full_moon_3", 2},
	{"wh_dlc03_full_moon_preparations_full_moon_4", 2},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_1", 2},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_11", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_12", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_13", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_14", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_15", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_16", 1},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_2", 2},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_3", 2},
	{"wh_dlc03_full_moon_preparations_lunar_eclipse_4", 2},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_1", 2},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_11", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_12", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_13", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_14", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_15", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_16", 1},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_2", 2},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_3", 2},
	{"wh_dlc03_full_moon_preparations_solar_eclipse_4", 2}
};