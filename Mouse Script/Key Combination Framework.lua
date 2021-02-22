--#region Extend Methods
string.at = function(self, index)
	return self:sub(index, index)
end
string.isdigit = function(char)
	return char >= "0" and char <= "9"
end
string.isnumber = function(self, i, j)
	i = i or 1
	j = j or self:len()
	return not (self:sub(i, j):find("^[+-]?%d+%.?%d*$") == nil)
end
string.tonumber = function(self)
	local function parseInteger(...)
		local params = {...}
		local result = 0
		for _, v in ipairs(params) do
			result = result*10 + v - 48
		end
		return result
	end
	local _, _, sign, integerString, decimalString = self:find("^([+-]?)(%d+)%.?(%d*)$")
	local result = parseInteger(integerString:byte(1, integerString:len())) + parseInteger(decimalString:byte(1, decimalString:len())) / 10 ^ decimalString:len()
	if (sign == "-") then
		result = -result
	end
	return result
end
string.totable = function(self)
	local result = {}
	for i = 1, self:len() do
		result[i] = self:at(i)
	end
	return result
end
table.reverse = function(list, i, j)
	i = i or 1
	j = j or #list
	local tmp = nil
	for index = i, i + (j - i) / 2 do
		tmp = list[index]
		list[index] = list[j - index + i]
		list[j - index + i] = tmp
	end
	return list
end
table.print = function(list)
	local result = ""
	for i, v in ipairs(list) do
		result = result .. " " .. v
	end
	print(result)
end
table.copy = function(src)
	local list = {}
	for key, value in pairs(src) do
		if type(value) == "table" then
			list[key] = table.copy(value)
		else
			list[key] = value
		end
	end
	return list
end
table.tostring = function(list)
	local result = ""
	for i, v in ipairs(list) do
		result = result .. v
	end
	return result
end
table.length = function(list)
	local count = 0
	for _ in pairs(list) do
		count = count + 1
	end
	return count
end
--#endregion

--#region Actions
--A collection of actions provided by G-series Lua API
Action = {
	Debug = {
		Print = function(self,...)
			local args = {...}
			return function()
				local content = ""
				for index, value in ipairs(args) do
					content = content .. value
				end
				OutputLogMessage(content .. "\n")
			end
		end,
		Clear = function()
			return function()
				ClearLog()
			end
		end,
	},
	KeysAndButtons = {
		Press = function (self, keysAndButtons)
			return function()
				for index, value in ipairs(keysAndButtons) do
					if type(value) == "string" then
						if value:at(1) == "#" then
							Sleep(value:sub(2):tonumber())
						else
							PressKey(value)
						end
					elseif type(value) == "number" then
						PressMouseButton(value)
					end
				end
			end
		end,
		Release = function (self, keysAndButtons)
			return function()
				for index, value in ipairs(keysAndButtons) do
					if type(value) == "string" then
						if value:at(1) == "#" then
							Sleep(value:sub(2):tonumber())
						else
							ReleaseKey(value)
						end
					elseif type(value) == "number" then
						ReleaseMouseButton(value)
					end
				end
			end
		end,
		PressAndRelease = function(self, sequence)
			return function()
				local pressed = {}
				for index, value in ipairs(sequence) do
					if pressed[value] then
						if type(value) == "string" then
							if value:at(1) == "#" then
								Sleep(value:sub(2):tonumber())
							else
								ReleaseKey(value)
							end
						elseif type(value) == "number" then
							ReleaseMouseButton(value)
						end
						pressed[value] = false
					else
						if type(value) == "string" then
							if value:at(1) == "#" then
								Sleep(value:sub(2):tonumber())
							else
								PressKey(value)
							end
						elseif type(value) == "number" then
							PressMouseButton(value)
						end
						pressed[value] = true
					end
				end
			end
		end,
		Click = function(self, keysAndButtons)
			local function ClickRecursively(t, depth)
				if depth % 2 == 1 then
					for i, v in ipairs(t) do
						if type(v) == "table" then
							ClickRecursively(v, depth + 1)
						elseif type(v) == "number" then
							PressMouseButton(v)
						elseif type(v) == "string" then
							if v:at(1) == "#" then
								Sleep(v:sub(2):tonumber())
							else
								PressKey(v)
							end
						end
					end
					for i=#t, 1,-1 do
						local v = t[i]
						if type(v) == "number" then
							ReleaseMouseButton(v)
						elseif type(v) == "string" then
							if v:at(1) == "#" then
								Sleep(v:sub(2):tonumber())
							else
								ReleaseKey(v)
							end
						end
					end
				else
					for i, v in ipairs(t) do
						if type(v) == "table" then
							ClickRecursively(v, depth + 1)
						elseif type(v) == "number" then
							PressAndReleaseMouseButton(v)
						elseif type(v) == "string" then
							if v:at(1) == "#" then
								Sleep(v:sub(2):tonumber())
							else
								PressAndReleaseKey(v)
							end
						end
					end
				end
			end
			return function()
				ClickRecursively(keysAndButtons, 1)
			end
		end,
	},
	Wheel = {
		MoveUp = function(self, count)
			return function()
				MoveMouseWheel(count)
			end
		end,
		MoveDown = function(self, count)
			return function()
				MoveMouseWheel(-count)
			end
		end,
	},
	Cursor = {
		Resolution = {Width = 1920, Height = 1080},
		Move = function(self, x, y)
			return function()
				MoveMouseRelative(x*self.Resolution.Width/65535, y*self.Resolution.Height/65535)
			end
		end,
		MoveTo = function(self, x, y)
			return function()
				MoveMouseTo(x*self.Resolution.Width/65535, y*self.Resolution.Height/65535)
			end
		end,
	},
	Macro = {
		AbortOtherMacrosBeforePlay = false,
		Play = function(self, macroName)
			return function()
				if self.AbortOtherMacrosBeforePlay then
					AbortMacro()
				end
				PlayMacro(macroName)
			end
		end
	},
	Delay = {
		Sleep = function(duration)
			return function()
				Sleep(duration)
			end
		end
	}
}
--#endregion

--#region Combined Event Handler
function EncodeButton(button)
	if button < 10 then
		return string.char(button + 48)
	else
		return string.char(button + 55)
	end
end
function DecodeButton(buttonCode)
	if string.isdigit(buttonCode) then
		return string.byte(buttonCode) - 48
	else
		return string.byte(buttonCode) - 55
	end
end
local function NextPermutation(list)
	local length=#list
	local k, l = 0, 0
	for i = length - 1, 1,-1 do
		if list[i] < list[i + 1] then
			k = i
			break
		end
	end
	if k == 0 then
		return false
	end
	for i = length, k + 1,-1 do
		if list[k] < list[i] then
			l = i
			break
		end
	end
	local tmp = list[k]
	list[k] = list[l]
	list[l] = tmp
	table.reverse(list, k + 1, length)
	return true
end
CombinedEventHandler = {
	PressedButtons = "",
	Event = {
		List = {},
		Current = {Length = 0},
		Register = function(self, combination, action, unorderedGroups)
			local unorderedGroupsIndex
			if unorderedGroups == "all" then
				unorderedGroups = { combination }
			elseif type(unorderedGroups) == "table" then
				if type(unorderedGroups[1]) == "number" then
					unorderedGroups = { unorderedGroups }
				elseif type(unorderedGroups[1]) ~= "table" then
					unorderedGroups = nil
				end
			else
				unorderedGroups = nil
			end
			if unorderedGroups then
				local indexTable = { }
				for i = 1,#combination do
					indexTable[combination[i]] = i
				end
				for i = 1,#unorderedGroups do
					for j = 1,#unorderedGroups[i] do
						unorderedGroups[i][j] = indexTable[unorderedGroups[i][j]]
					end
				end
				for i = 1,#unorderedGroups do
					table.sort(unorderedGroups[i])
				end
				unorderedGroupsIndex = table.copy(unorderedGroups)
			end
			--Get identifier
			local initialTable = table.copy(combination)
			local identifier = ""
			for i, v in ipairs(combination) do
				identifier = identifier .. EncodeButton(v)
			end
			while true do
				--Event already exists
				if self.List[identifier] then
					self.List[identifier].Action = action
				else
					--Check whether current event is a leaf event
					local isLeaf = true
					for name in pairs(self.List) do
						if name:sub(1,#identifier) == identifier then
							isLeaf = false
							break
						end
					end
					--Update prefixs if being a leaf event
					if isLeaf then
						for i = 1,#identifier - 1 do
							local prefix = identifier:sub(1, i)
							if self.List[prefix] then
								self.List[prefix].IsLeaf = false
							end
						end
					end
					--Add event to EventList
					self.List[identifier]={IsLeaf = isLeaf, Action = action}
				end
				if unorderedGroups == nil then
					break
				end
				local finished = true
				for i=#unorderedGroups, 1,-1 do
					if NextPermutation(unorderedGroups[i]) then
						finished = false
						break
					else
						table.reverse(unorderedGroups[i])
					end
				end
				if finished then
					break
				end
				local identifierTable = table.copy(initialTable)
				for i = 1,#unorderedGroups do
					for j = 1,#unorderedGroups[i] do
						identifierTable[unorderedGroupsIndex[i][j]] = initialTable[unorderedGroups[i][j]]
					end
				end
				identifier = ""
				for i, v in ipairs(identifierTable) do
					identifier = identifier .. EncodeButton(v)
				end
			end
		end,
		RegisterPressed = function(self, combination, pAction, unorderedGroup)
			self:Register(combination,{Pressed = pAction},unorderedGroup)
		end,
		RegisterReleased = function(self, combination, rAction, unorderedGroup)
			self:Register(combination,{Released = rAction},unorderedGroup)
		end,
		RegisterPressedAndReleassed = function(self, combination, pAction, rAction, unorderedGroup)
			self:Register(combination,{Pressed = pAction, Released = rAction},unorderedGroup)
		end,
		RegisterBind = function(self, srcCombination, dstCombination, unorderedGroup)
			local reversedDstCombination = {}
			for i = 1,#dstCombination do
				reversedDstCombination[i] = dstCombination[#dstCombination - i + 1]
			end
			self:Register(srcCombination,{
				Pressed = Action.KeysAndButtons:Press(dstCombination),
				Released = Action.KeysAndButtons:Release(reversedDstCombination)
			},unorderedGroup)
		end,
		RegisterReleasedBind = function(self, srcCombination, dstCombination, unorderedGroup)
			self:Register(srcCombination,{
				Released = Action.KeysAndButtons:Click(dstCombination),
			},unorderedGroup)
		end,
		RegisterReleasedMacro = function(self, srcCombination, macroName, unorderedGroup)
			self:Register(srcCombination,{
				Released = Action.Macro:Play(macroName),
			},unorderedGroup)
		end,
		RegisterReleasedSequence = function(self, srcCombination, funcTable, unorderedGroup)
			self:Register(srcCombination,{
				Released = function()
					for _, func in ipairs(funcTable) do
						func()
					end
				end
			},unorderedGroup)
		end,
	},
	SpecialHandlers = {},
	AddSpecialHandler = function(self, handle, auxiliary)
		self.SpecialHandlers[#self.SpecialHandlers + 1] = {
			Handle = handle,
			Auxiliary = auxiliary,
		}
	end,
	PressButton = function(self, button)
		for i = 1,#self.SpecialHandlers do
			self.SpecialHandlers[i]:Handle("press",button, self.PressedButtons)
		end
		self.PressedButtons = self.PressedButtons .. EncodeButton(button)
		local current = self.Event.Current;
		local eventButtons = self.PressedButtons
		local event = self.Event.List[eventButtons]
		if event == nil and current.Length > 0 then
			local _, pos = self.PressedButtons:find(current[current.Length])
			eventButtons = self.PressedButtons:sub(pos + 1)
			event = self.Event.List[eventButtons]
		end
		if event then
			current.Length = current.Length + 1
			current[current.Length] = eventButtons
			if event.Action.Pressed then
				event.Action.Pressed()
			end
		end
	end,
	ReleaseButton = function(self, button)
		for i = 1,#self.SpecialHandlers do
			self.SpecialHandlers[i]:Handle("release",button, self.PressedButtons)
		end
		local current = self.Event.Current
		for index, cur in ipairs(current) do
			local event = self.Event.List[cur]
			if event and cur:find(EncodeButton(button)) then
				if event.Action.Released then
					event.Action.Released()
				end
				for i = index, current.Length - 1 do
					current[i] = current[i + 1]
				end
				current[current.Length] = nil
				current.Length = current.Length - 1
			end
		end
		local position = self.PressedButtons:find(EncodeButton(button))
		if position then
			self.PressedButtons = self.PressedButtons:sub(1, position - 1) .. self.PressedButtons:sub(position + 1)
		end
	end
}
--#endregion

--#region API Event Handling
RawEvent = {
	Pressed = "MOUSE_BUTTON_PRESSED",
	Released = "MOUSE_BUTTON_RELEASED",
	Activated = "PROFILE_ACTIVATED",
	Deactivated = "PROFILE_DEACTIVATED",
}
EnablePrimaryMouseButtonEvents(true)
function OnEvent(event, arg)
	if event == RawEvent.Pressed then
		CombinedEventHandler:PressButton(arg)
	elseif event == RawEvent.Released then
		CombinedEventHandler:ReleaseButton(arg)
	end
end
--#endregion

--#region Mouse Enums
MouseFunction = {
	PrimaryClick = 1,
	MiddleClick = 2,
	SecondaryClick = 3,
	Forward = 4,
	Back = 5
}
local MouseModel = {
	G502Hero = {
		Primary = 1,
		Secondary = 2,
		Middle = 3,
		SideBack = 4,
		SideMiddle = 5,
		SideFront = 6,
		AuxiliaryBack = 7,
		AuxiliaryFront = 8,
		Back = 9,
		WheelRight = 10,
		WheelLeft = 11,
	}
}
--#endregion

--#region Initialize Settings
Settings = {
	ScreenResolution = { 1920, 1080 },
	MouseModel = "G502Hero"
}
Action.Cursor.Resolution = {
	Width = Settings.ScreenResolution[1],
	Height = Settings.ScreenResolution[2]
}
Button = MouseModel[Settings.MouseModel]
Mouse = MouseFunction
Event = CombinedEventHandler.Event
--#endregion
