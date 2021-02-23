--#region API
function OutputLogMessage(...)
	print("Log : " .. ...)
end
function ClearLog()
	print("Log cleaared")
end
function Sleep(arg)
	print("Sleep " .. arg .. " ms")
end
function PressKey(arg)
	print("Key " .. arg .. " is pressed")
end
function ReleaseKey(arg)
	print("Key " .. arg .. " is released")
end
function PressAndReleaseKey(arg)
	print("Key " .. arg .. " is pressed and released")
end
function PressMouseButton(arg)
	print("Mouse button " .. arg .. " is pressed")
end
function ReleaseMouseButton(arg)
	print("Mouse button " .. arg .. " is released")
end
function PressAndReleaseMouseButton(arg)
	print("Mouse button " .. arg .. " is pressed and released")
end
function MoveMouseWheel(arg)
	print("Mouse wheel is moved " .. arg .. " clicks")
end
function MoveMouseRelative(x,y)
	print("Cursor is moved " .. x .. "," .. y .. " relatively")
end
function MoveMouseTo(x,y)
	print("Cursor is moved to " .. x .. "," .. y)
end
function AbortMacro()
	print("All playing macros are aborted")
end
function PlayMacro(name)
	print("Macro \"" .. name .. "\" is played")
end
function EnablePrimaryMouseButtonEvents(arg)
	if arg == true then
		print("Primary mouse button events are enabled")
	else
		print("Primary mouse button events are disabled")
	end
end
--#endregion

Test = {
	FileMode = false,
	FilePath = "src\\test\\operations.txt",
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