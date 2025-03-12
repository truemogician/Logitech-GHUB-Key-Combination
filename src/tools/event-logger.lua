EnablePrimaryMouseButtonEvents(true)

---Handling function to be called by GHUB when a raw event fires
---@param event string String containing the event identifier.
---@param arg integer? Argument correlating to the appropriate identifier.
---@param family string?  Family of device creating the hardware event. Empty if event is not hardware specific. Use this if you need to distinguish input from multiple devices.
function OnEvent(event, arg, family)
	local msg = event
	if arg then
		msg = msg .. " " .. arg
	end
	if family then
		msg = "[" .. family .. "] " .. msg
	end
	OutputLogMessage(msg .. "\n")
end
