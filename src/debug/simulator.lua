OutputLogMessage = print;

package.path = package.path .. ";?.lua"
require "src/debug/mock"

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