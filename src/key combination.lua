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
---Collection of actions provided by G-series Lua API
Action = {
	Debug = {
		---Print message to GHUB script console
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
		---Clear GHUB script console
		Clear = function()
			return function()
				ClearLog()
			end
		end,
	},
	KeysAndButtons = {
		---Press buttons and keys in a sequence
		--@param keysAndButtons Array consisting of numbers and strings. Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay.
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
		---Release buttons and keys in a sequence
		--@param keysAndButtons Array consisting of numbers and strings. Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay.
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
		---Press or release buttons and keys in a sequence
		--@param keysAndButtons Array consisting of numbers and strings. Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay. Keys or buttons will be pressed when they first appear, and will be released the second time they appear.
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
		---Click buttons and keys sequentially or nestedly
		--@param keysAndButtons Array consisting of numbers, strings and tables. Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay. Numbers and strings within tables will be pressed and released in a different way.
		Click = function(self, keysAndButtons)
			local function ClickRecursively(target, depth)
				if depth % 2 == 1 then
					for _, value in ipairs(target) do
						if type(value) == "table" then
							ClickRecursively(value, depth + 1)
						elseif type(value) == "number" then
							PressMouseButton(value)
						elseif type(value) == "string" then
							if value:at(1) == "#" then
								Sleep(value:sub(2):tonumber())
							else
								PressKey(value)
							end
						end
					end
					for i = #target, 1,-1 do
						local value = target[i]
						if type(value) == "number" then
							ReleaseMouseButton(value)
						elseif type(value) == "string" then
							if value:at(1) == "#" then
								Sleep(value:sub(2):tonumber())
							else
								ReleaseKey(value)
							end
						end
					end
				else
					for _, value in ipairs(target) do
						if type(value) == "table" then
							ClickRecursively(value, depth + 1)
						elseif type(value) == "number" then
							PressAndReleaseMouseButton(value)
						elseif type(value) == "string" then
							if value:at(1) == "#" then
								Sleep(value:sub(2):tonumber())
							else
								PressAndReleaseKey(value)
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
		---Scroll mouse wheel up
		--@param count Number of clicks
		ScrollUp = function(self, count)
			return function()
				MoveMouseWheel(count)
			end
		end,
		---Scroll mouse wheel down
		--@param count Number of clicks
		ScrollDown = function(self, count)
			return function()
				MoveMouseWheel(-count)
			end
		end,
	},
	Cursor = {
		---Resolution of the screen
		Resolution = { Width = 1920, Height = 1080 },
		---Move cursor by some pixels
		--@param x Number of pixels horizontally
		--@param y Number of pixels vertically
		Move = function(self, x, y)
			return function()
				MoveMouseRelative(x*self.Resolution.Width/65535, y*self.Resolution.Height/65535)
			end
		end,
		---Move cursor to certian position
		--@param x Abscissa of the position
		--@param y Ordinate of the positoin
		MoveTo = function(self, x, y)
			return function()
				MoveMouseTo(x*self.Resolution.Width/65535, y*self.Resolution.Height/65535)
			end
		end,
	},
	Macro = {
		AbortOtherMacrosBeforePlay = false,
		---Play macroName
		--@param macroName Name of the macro
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
		---Sleep for some time
		--@param duration Number of millisecond to sleep
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
	---Keys and buttons currently pressed
	PressedButtons = "",
	Event = {
		---Collection of all registered events
		List = {},
		---Events currently on effect
		Current = {Length = 0},
		---Register an event
		--@param sequence Sequence of mouse buttons
		--@param action Action to be taken when the event fires
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		Register = function(self, sequence, action, unorderedGroups)
			local unorderedGroupsIndex
			if unorderedGroups == "all" then
				unorderedGroups = { sequence }
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
				for i = 1,#sequence do
					indexTable[sequence[i]] = i
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
			local initialTable = table.copy(sequence)
			local identifier = ""
			for i, v in ipairs(sequence) do
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
		---Register an event firing when pressed
		--@param sequence Sequence of mouse buttons
		--@param pAction Action to be taken when the event fires
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterPressed = function(self, sequence, pAction, unorderedGroup)
			self:Register(sequence,{Pressed = pAction},unorderedGroup)
		end,
		---Register an event firing when released
		--@param sequence Sequence of mouse buttons
		--@param rAction Action to be taken when the event fires
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterReleased = function(self, sequence, rAction, unorderedGroup)
			self:Register(sequence,{Released = rAction},unorderedGroup)
		end,
		---Register both pressed and released events
		--@param sequence Sequence of mouse buttons
		--@param pAction Action to be taken when pressed
		--@param rAction Action to be taken when released
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterPressedAndReleassed = function(self, sequence, pAction, rAction, unorderedGroup)
			self:Register(sequence,{Pressed = pAction, Released = rAction},unorderedGroup)
		end,
		---Register a mapping from a mouse buttons sequence to a sequence of keys and buttons actions. Pressing actions will be registered to pressed event, and so is releasing.
		--@param srcSequence Array of numbers, representing mouse buttons
		--@param dstSequence Array consisting of numbers, strings. Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay.
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterBind = function(self, srcSequence, dstSequence, unorderedGroup)
			local reversedDstCombination = {}
			for i = 1,#dstSequence do
				reversedDstCombination[i] = dstSequence[#dstSequence - i + 1]
			end
			self:Register(srcSequence,{
				Pressed = Action.KeysAndButtons:Press(dstSequence),
				Released = Action.KeysAndButtons:Release(reversedDstCombination)
			},unorderedGroup)
		end,
		---Register a mapping from a mouse buttons sequence to a sequence of keys and buttons actions. Clicking actions will be registered to released event.
		--@param srcSequence Array of numbers, representing mouse buttons
		--@param dstSequence Array consisting of numbers, strings and tables. Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay. Numbers and strings within tables will be pressed and released in a different way.
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterReleasedBind = function(self, srcSequence, srcCombination, unorderedGroup)
			self:Register(srcSequence,{
				Released = Action.KeysAndButtons:Click(srcCombination),
			},unorderedGroup)
		end,
		---Register a macro playing action to released event
		--@param srcSequence Array of numbers, representing mouse buttons
		--@param macroName Name of the macro
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterReleasedMacro = function(self, srcSequence, macroName, unorderedGroup)
			self:Register(srcSequence,{
				Released = Action.Macro:Play(macroName),
			},unorderedGroup)
		end,
		---Register a sequence of actions to released event
		--@param srcSequence Array of numbers, representing mouse buttons
		--@param actionSequence Array of actions
		--@param unorderedGroups Order of the buttons within the table will be ignored.
		RegisterReleasedSequence = function(self, srcSequence, actionSequence, unorderedGroup)
			self:Register(srcSequence,{
				Released = function()
					for _, action in ipairs(actionSequence) do
						action()
					end
				end
			},unorderedGroup)
		end,
	},
	---Collection of special handlers
	SpecialHandlers = {},
	---Add special handlers
	--@param handle The handling function
	--@param auxilary Auxiliary variables for handler to use
	AddSpecialHandler = function(self, handle, auxiliary)
		self.SpecialHandlers[#self.SpecialHandlers + 1] = {
			Handle = handle,
			Auxiliary = auxiliary,
		}
	end,
	---Function to be called when a mouse button is pressed
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
	---Function to be called when a mouse button is released
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
---Raw events provided by G-series API
RawEvent = {
	Pressed = "MOUSE_BUTTON_PRESSED",
	Released = "MOUSE_BUTTON_RELEASED",
	Activated = "PROFILE_ACTIVATED",
	Deactivated = "PROFILE_DEACTIVATED",
}
EnablePrimaryMouseButtonEvents(true)
---Handling function to be called when a raw event fires
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
