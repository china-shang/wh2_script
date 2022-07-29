




out("qa_functions.lua loaded");

function qa_functions()
	if core:is_campaign() then
		out("qa_functions() is exposing the following functions - press CTRL+F3 (or SHIFT+CTRL+F3 sometimes) and enter one of the following commands:")
		out.inc_tab();

		-- heal() -
		out("heal() - heal alls armies for the local player. You can optionally supply a unary health value (0 - 1), the default is 1.");
		function heal(unary_value)
			if unary_value then
				if not is_number(unary_value) or unary_value < 0 or unary_value > 1 then
					out("heal() not being called as it was supplied a health value of [".. tostring(unary_value) .. "] - this should be a unary value (0 - 1)");
					return;
				end;
			else
				unary_value = 1;
			end;

			local faction = cm:get_local_faction(true);
			if not faction then
				out("heal() called but no local faction could be found - is this an autotest?");
				return;
			end;

			out("heal() is healing all units in faction [" .. faction:name() .. "] to unary health [" .. unary_value .. "]:"); 
			cm:heal_all_units_for_faction(faction, unary_value);
		end

	end;
end;