RawEvent = {
	Pressed = "MOUSE_BUTTON_PRESSED",
	Released = "MOUSE_BUTTON_RELEASED",
	Activated = "PROFILE_ACTIVATED",
	Deactivated = "PROFILE_DEACTIVATED",
}

---@param event string
---@param arg integer
function OnEvent(event, arg)
	if event == RawEvent.Pressed then
		OutputLogMessage("button " .. arg .. " pressed\n")
	elseif event == RawEvent.Released then
		OutputLogMessage("button " .. arg .. " released\n")
	end
end