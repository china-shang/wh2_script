local retreat_bundle_name = "wh2_dlc09_bundle_tretch_retreat";
local tretch_name = "names_name_421856293";
local tretch_faction_name = "wh2_dlc09_skv_clan_rictus";

-- apply an effect bundle to tretch's force when he retreats from a defensive battle
core:add_listener(
	"apply_tretch_retreat_bundle",
	"CharacterWithdrewFromBattle",
	function(context)
		local pb = cm:model():pending_battle();
		local character = context:character();
		
		return character:faction():name() == tretch_faction_name and character:get_forename() == tretch_name and pb:has_defender() and pb:defender():get_forename() == tretch_name;
	end,
	function(context)
		cm:apply_effect_bundle_to_characters_force(retreat_bundle_name, context:character():command_queue_index(), 0, true);
	end,
	true
);

-- the effect bundle is removed after a fought battle
core:add_listener(
	"remove_tretch_retreat_bundle",
	"BattleCompleted",
	function()
		return cm:model():pending_battle():has_been_fought();
	end,
	function(context)
		local pb = cm:model():pending_battle();
		
		if pb:has_attacker() then
			local attacker = pb:attacker();
			
			if attacker:get_forename() == tretch_name then
				remove_tretch_retreat_bundle(attacker);
			end;
		elseif pb:has_defender() then
			local defender = pb:defender();
			
			if defender:get_forename() == tretch_name then
				remove_tretch_retreat_bundle(defender);
			end;
		end;
	end,
	true
);

function remove_tretch_retreat_bundle(character)
	if character:has_military_force() and character:military_force():has_effect_bundle(retreat_bundle_name) then
		cm:remove_effect_bundle_from_characters_force(retreat_bundle_name, character:command_queue_index());
	end;
end;

-- apply an effect bundle to tretch's faction when breaking a diplomatic treaty
core:add_listener(
	"apply_tretch_diplomatic_bundle",
	"NegativeDiplomaticEvent",
	function(context)
		local proposer = context:proposer();
		
		return proposer:is_human() and proposer:name() == tretch_faction_name and (context:was_alliance() or context:was_military_alliance() or context:was_defensive_alliance() or context:was_military_access() or context:was_trade_agreement() or context:was_non_aggression_pact());
	end,
	function(context)
		cm:apply_effect_bundle("wh2_dlc09_bundle_tretch_treaty_broken", tretch_faction_name, 5);
	end,
	true
);