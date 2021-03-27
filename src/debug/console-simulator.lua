--#region API

---@vararg any Messages to log
function OutputLogMessage(...)
	print("Log : " .. ...)
end

function ClearLog()
	print("Clear log")
end

---@param arg integer Millisecond
function Sleep(arg)
	print("Sleep for " .. arg .. " ms")
end

---@param arg string Keyboard key code
function PressKey(arg)
	print("Press keyboard key " .. arg)
end

---@param arg string Keyboard key code
function ReleaseKey(arg)
	print("Release keyboard key " .. arg)
end

---@param arg string Keyboard key code
function PressAndReleaseKey(arg)
	print("Press and release keyboard key " .. arg)
end

---@param arg string Mouse function code
function PressMouseButton(arg)
	print("Press mouse button " .. arg)
end

---@param arg string Mouse function code
function ReleaseMouseButton(arg)
	print("Release mouse button " .. arg)
end

---@param arg string Mouse function code
function PressAndReleaseMouseButton(arg)
	print("Press and release mouse button " .. arg)
end

---@param arg integer Number of clicks
function MoveMouseWheel(arg)
	print("Scroll mouse wheel " .. ((arg > 0) and "up " or "down ") .. arg .. " clicks")
end

---@param x integer Number of horizontal pixels to move
---@param y integer Number of vertical pixels to move
function MoveMouseRelative(x, y)
	print("Move cursor by (" .. x .. "," .. y .. ") relatively")
end

---@param x integer @Abscissa
---@param y integer @Ordinate
function MoveMouseTo(x, y)
	print("Move cursor to (" .. x .. "," .. y .. ")")
end

function AbortMacro()
	print("Aborted playing macro")
end

---@param name string Name of the macro
function PlayMacro(name)
	print("Play macro \"" .. name .. "\"")
end

---@param arg boolean
function EnablePrimaryMouseButtonEvents(arg)
	print((arg and "Enable" or "Disable") .. " primary mouse button events")
end

--#endregion

Simulator = {
	---In file mode, script will read from file first and switch to console at EOF
	---@type boolean
	FileMode = false,

	---Path of file to read in file mode
	---@type string
	FilePath = "src\\test\\operations.txt",

	---Start the test
	---@param fileMode? boolean
	---@param filePath? string
	Start = function(self, fileMode, filePath)
		self.FileMode = fileMode or self.FileMode
		self.FilePath = filePath or self.FilePath
		local file
		if self.FileMode then
			file = io.open(self.FilePath,"r")
			io.input(file)
		end
		local onFile = self.FileMode
		while true do
			local line = io.read()
			if onFile and line == nil then
				file:close()
				io.input(io.stdin)
				onFile = false
				line = io.read()
			end
			if onFile then
				print(line)
			end
			local _, _, event, arg = line:find("([^%s]+)%s?([^%s]*)")
			event = event:lower()
			if arg:isnumber() then
				arg = arg:tonumber()
			else
				arg = Button[arg]
			end
			if event == "activate" or event == "a" then
				OnEvent(RawEvent.Activated)
			elseif event == "press" or event == "p" then
				OnEvent(RawEvent.Pressed, arg)
			elseif event == "release" or event == "r" then
				OnEvent(RawEvent.Released, arg)
			elseif event == "deactive" or event == "d" then
				OnEvent(RawEvent.Deactivated)
				break
			end
		end
	end,
}