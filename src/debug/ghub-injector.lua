--#region API

function ClearLog()
	OutputLogMessage("Clear log" .. "\n")
end

---@param arg integer Millisecond
function Sleep(arg)
	OutputLogMessage("Sleep for " .. arg .. " ms" .. "\n")
end

---@param arg string Keyboard key code
function PressKey(arg)
	OutputLogMessage("Press keyboard key " .. arg .. "\n")
end

---@param arg string Keyboard key code
function ReleaseKey(arg)
	OutputLogMessage("Release keyboard key " .. arg .. "\n")
end

---@param arg string Keyboard key code
function PressAndReleaseKey(arg)
	OutputLogMessage("Press and release keyboard key " .. arg .. "\n")
end

---@param arg string Mouse function code
function PressMouseButton(arg)
	OutputLogMessage("Press mouse button " .. arg .. "\n")
end

---@param arg string Mouse function code
function ReleaseMouseButton(arg)
	OutputLogMessage("Release mouse button " .. arg .. "\n")
end

---@param arg string Mouse function code
function PressAndReleaseMouseButton(arg)
	OutputLogMessage("Press and release mouse button " .. arg .. "\n")
end

---@param arg integer Number of clicks
function MoveMouseWheel(arg)
	OutputLogMessage("Scroll mouse wheel " .. ((arg > 0) and "up " or "down ") .. arg .. " clicks" .. "\n")
end

---@param x integer Number of horizontal pixels to move
---@param y integer Number of vertical pixels to move
function MoveMouseRelative(x, y)
	OutputLogMessage("Move cursor by (" .. x .. "," .. y .. ") relatively" .. "\n")
end

---@param x integer @Abscissa
---@param y integer @Ordinate
function MoveMouseTo(x, y)
	OutputLogMessage("Move cursor to (" .. x .. "," .. y .. ")" .. "\n")
end

function AbortMacro()
	OutputLogMessage("Aborted playing macro" .. "\n")
end

---@param name string Name of the macro
function PlayMacro(name)
	OutputLogMessage("Play macro \"" .. name .. "\"" .. "\n")
end

---@param arg boolean
function EnablePrimaryMouseButtonEvents(arg)
	OutputLogMessage((arg and "Enable" or "Disable") .. " primary mouse button events" .. "\n")
end

--#endregion
