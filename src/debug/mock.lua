--#region API

function ClearLog()
	OutputLogMessage("Clear log\n")
end

---@param arg integer Millisecond
function Sleep(arg)
	OutputLogMessage("Sleep for %d ms\n", arg)
end

---@param arg string Keyboard key code
function PressKey(arg)
	OutputLogMessage("Press keyboard key %s\n", arg)
end

---@param arg string Keyboard key code
function ReleaseKey(arg)
	OutputLogMessage("Release keyboard key %s\n", arg)
end

---@param arg string Keyboard key code
function PressAndReleaseKey(arg)
	OutputLogMessage("Press and release keyboard key %s\n", arg)
end

---@param arg integer Mouse function code
function PressMouseButton(arg)
	OutputLogMessage("Press mouse button %d\n", arg)
end

---@param arg integer Mouse function code
function ReleaseMouseButton(arg)
	OutputLogMessage("Release mouse button %d\n", arg)
end

---@param arg integer Mouse function code
function PressAndReleaseMouseButton(arg)
	OutputLogMessage("Press and release mouse button %d\n", arg)
end

---@param arg integer Number of clicks
function MoveMouseWheel(arg)
	OutputLogMessage("Scroll mouse wheel %s %d clicks\n", arg > 0 and "up" or "down", arg)
end

---@param x integer Number of horizontal pixels to move
---@param y integer Number of vertical pixels to move
function MoveMouseRelative(x, y)
	OutputLogMessage("Move cursor by (%d, %d) relatively\n", x, y)
end

---@param x integer Abscissa
---@param y integer Ordinate
function MoveMouseTo(x, y)
	OutputLogMessage("Move cursor to (%d, %d)\n", x, y)
end

---@param x integer Abscissa
---@param y integer Ordinate
function MoveMouseToVirtual(x, y)
	OutputLogMessage("Move cursor to (%d, %d) in virtual desktop\n", x, y)
end

function AbortMacro()
	OutputLogMessage("Abort playing macro\n")
end

---@param name string Name of the macro
function PlayMacro(name)
	OutputLogMessage("Play macro \"%s\"\n", name)
end

---@param arg boolean
function EnablePrimaryMouseButtonEvents(arg)
	OutputLogMessage("%s primary mouse button events\n", arg and "Enable" or "Disable")
end

--#endregion
