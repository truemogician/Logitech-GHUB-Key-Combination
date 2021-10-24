function OutputLogMessage(message, ...)
	print(message:sub(1, #message - 1), ...)
end

package.path = package.path .. ";?.lua"
require "src/debug/mock"

---@alias SimulatorMode "file"|"console"|"argument"

Simulator = {
	---Start the simulator
	---@param mode SimulatorMode
	---@param param? string|string[] File path in file mode, commands in argument mode
	Start = function(self, mode, param)
		function Trigger(cmd)
			local _, _, event, arg = cmd:find("([^%s]+)%s?([^%s]*)")
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
				return false
			end
			return true
		end
		if mode == "argument" then
			for _, line in ipairs(param) do
				print(line)
				if not Trigger(line) then
					return
				end
			end
			io.input(io.stdin)
			while true do
				local line = io.read()
				if not Trigger(line) then
					break
				end
			end
		else
			local file
			if mode == "file" then
				file = io.open(param,"r")
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
				if not Trigger(line) then
					break
				end
			end
		end
	end,
}