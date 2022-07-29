
function StartPlagueNearPosition(plague_key, owner, effect, x, y)
	out("StartPlagueNearPosition("..plague_key..", "..owner..", "..effect..", "..x..", "..y..")");
	
	local region_list = cm:model():world():region_manager():region_list();
	local shortest_distance = 999999;
	local closest_region = "";
	local closest_pos = {x = 0, y = 0};

	for i = 0, region_list:num_items() - 1 do
		local region = region_list:item_at(i);
		if region:is_null_interface() == false and region:settlement():is_null_interface() == false and region:is_abandoned() == false then
			local region_key = region:name();
			local distance = distance_squared(x, y, region:settlement():logical_position_x(), region:settlement():logical_position_y());

			if distance < shortest_distance then
				shortest_distance = distance;
				closest_region = region_key;
				closest_pos = {x = x, y = y};
			end
		end
	end

	Show_Plague_Event(owner, closest_pos.x, closest_pos.y, true);

	GiveRegionPlague(plague_key, closest_region, false);	
end


function GiveRegionPlague(plague_key, region_key, is_abandoned_check)

	is_abandoned_check = is_abandoned_check or false;
	local region = cm:model():world():region_manager():region_by_key(region_key);


	if region:is_null_interface() == false then
		if not (is_abandoned_check == true and region:is_abandoned() == true) then
			cm:spawn_plague_at_region(region, plague_key)
		end
	end
end

function Show_Plague_Event(faction_key, x, y, is_start)
	if is_start == true then
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_start_title",
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_start_primary_detail",
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_start_secondary_detail",
			x,
			y,
			true,
			881
		);
	else
		cm:show_message_event_located(
			faction_key,
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_title",
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_primary_detail",
			"event_feed_strings_text_wh_dlc08_event_feed_string_scripted_event_nurgle_plague_secondary_detail",
			x,
			y,
			true,
			882
		);
	end
end
