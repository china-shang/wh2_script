-- Reference API: http://totalwar-confluence:8090/pages/viewpage.action?pageId=23268632

require "data.script.gsat.lib.all"


function uicomponent_to_string(uicomponent)
	
	if uicomponent:Id() == "root" then
		return "root";
	else
		local parent = uicomponent:Parent();
		
		if parent then
			return uicomponent_to_string(UIComponent(parent)) .. ">" .. uicomponent:Id();
		else
			return uic:Id();
		end
	end
end


function ATMain.component_clicked(context)
	Utilities.print("GSAT_Record:ComponentClicked:" .. uicomponent_to_string(UIComponent(context.component)))
end

function ATMain.component_mouseon(context)
	Utilities.print("GSAT_Record:MouseOn:" .. context.string)
end

function ATMain.key_pressed(context)
	Utilities.print("GSAT_Record:KeyPressed:" .. context.string)
end

function ATMain.shortcut_triggered(context)
	Utilities.print("GSAT_Record:ShortcutTriggered:" .. context.string)
end

add_frontend_event_callback("ComponentLClickUp", 	ATMain.component_clicked)
add_frontend_event_callback("ComponentMouseOn",		ATMain.component_mouseon)
add_frontend_event_callback("ShortcutTriggered", 	ATMain.shortcut_triggered)