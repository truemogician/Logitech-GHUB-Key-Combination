--#region Framework

--#region Class Definations

---@alias numstr number|string
---@alias Keyboard "escape"|"f1"|"f1"|"f2"|"f3"|"f4"|"f5"|"f6"|"f7"|"f8"|"f9"|"f10"|"f11"|"f12"|"f13"|"f14"|"f15"|"f16"|"f17"|"f18"|"f19"|"f20"|"f21"|"f22"|"f23"|"f24"|"printscreen"|"scrolllock"|"pause"|"tilde"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"|"0"|"minus"|"equal"|"backspace"|"tab"|"q"|"w"|"e"|"r"|"t"|"y"|"u"|"i"|"o"|"p"|"lbracket"|"rbracket"|"backslash"|"capslock"|"a"|"s"|"d"|"f"|"g"|"h"|"j"|"k"|"l"|"semicolon"|"quote"|"enter"|"lshift"|"non_us_slash"|"z"|"x"|"c"|"v"|"b"|"n"|"m"|"comma"|"period"|"slash"|"rshift"|"lctrl"|"lgui"|"lalt"|"spacebar"|"ralt"|"rgui"|"appkey"|"rctrl"|"insert"|"home"|"pageup"|"delete"|"end"|"pagedown"|"up"|"left"|"down"|"right"|"numlock"|"numslash"|"numminus"|"num7"|"num8"|"num9"|"numplus"|"num4"|"num5"|"num6"|"num1"|"num2"|"num3"|"numenter"|"num0"|"numperiod"
---@alias Delay "#10"|"#15"|"#25"|"#50"|"#100"|"#200"|"#500"|"#1000"
---@alias MouseKeyboard integer|Keyboard
---@alias ActionSequence (MouseKeyboard|Delay|ActionSequence)[]
---@alias Handler fun(self:ConfiguredHandler, event:"press"|"release", button:integer, pressedButtons:integer[])

---@alias char string @string whose length is 1

---@class EventAction
---@field Pressed fun() @Function to be called when key combination is pressed
---@field Released fun() @Function to be called when key combination is released

---@class Event
---@field Action EventAction
---@field IsLeaf boolean @Indicate whether this event is a leaf event

---@class ConfiguredHandler
---@field TriggerTime "pre"|"post"
---@field Handle Handler
---@field Instrument any @Contains instrumental variable

--#endregion

--#region Extend Methods

---Get the character at given position, starting with 1
---@param index integer position of the character
---@return char
function string:at(index)
	return self:sub(index, index)
end

---Indicate whether the character represents a digit
---@param self char character to be checked
---@return boolean
function string.isdigit(self)
	return self >= "0" and self <= "9"
end

---Indicate whether the string represents a number
---@return boolean
function string:isnumber()
	return self:find("^[+-]?%d+%.?%d*$") ~= nil
end

---Convert a string with number format to a number
---@return number
function string:tonumber()
	local function parseInteger(...)
		local params = { ... }
		local result = 0
		for _, v in ipairs(params) do
			result = result * 10 + v - 48
		end
		return result
	end

	local _, _, sign, integerString, decimalString = self:find("^([+-]?)(%d+)%.?(%d*)$")
	local result = parseInteger(integerString:byte(1, integerString:len())) +
		parseInteger(decimalString:byte(1, decimalString:len())) / 10 ^ decimalString:len()
	if (sign == "-") then
		result = -result
	end
	return result
end

---Convert a string to an character array
---@return char[]
function string:toarray()
	local result = {}
	for i = 1, self:len() do
		result[i] = self:at(i)
	end
	return result
end

---Reverse the table from i to j
---@param i? integer
---@param j? integer
---@return table
function table:reverse(i, j)
	i = i or 1
	j = j or #self
	local tmp = nil
	for index = i, i + (j - i) / 2 do
		tmp = self[index]
		self[index] = self[j - index + i]
		self[j - index + i] = tmp
	end
	return self
end

---Create a copy of a table recursively
---@return table
function table:copy()
	local list = {}
	for key, value in pairs(self) do
		if type(value) == "table" then
			list[key] = table.copy(value)
		else
			list[key] = value
		end
	end
	return list
end

---Convert table to string by directly concat all values
---@param self any[]
---@return string
function table.tostring(self)
	local result = ""
	for _, v in ipairs(self) do
		result = result .. v
	end
	return result
end

---Get the length of any table
---@return integer
function table:length()
	local count = 0
	for _ in pairs(self) do
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
		---@vararg any @messages to be printed
		---@return function
		Print = function(self, ...)
			local args = { ... }
			return function()
				local content = ""
				for _, value in ipairs(args) do
					content = content .. value
				end
				OutputLogMessage(content .. "\n")
			end
		end,
		---Clear GHUB script console
		---@return function
		Clear = function(self)
			return function()
				ClearLog()
			end
		end,
	},
	KeysAndButtons = {
		---Press buttons and keys in a sequence
		---@param keysAndButtons (MouseKeyboard|Delay)[] @Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay.
		---@return function
		Press = function(self, keysAndButtons)
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
		---@param keysAndButtons (MouseKeyboard|Delay)[] @Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay.
		---@return function
		Release = function(self, keysAndButtons)
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
		---@param keysAndButtons (MouseKeyboard|Delay)[] @Number represents mouse buttons, string for keyboard keys, and string starting with "#" for delay. Keys or buttons will be pressed when they first appear, and will be released the second time they appear.
		---@return function
		PressAndRelease = function(self, keysAndButtons)
			return function()
				local pressed = {}
				for index, value in ipairs(keysAndButtons) do
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
		---@param keysAndButtons ActionSequence @Array consisting of numbers, strings and tables. Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay. Numbers and strings within tables will be pressed and released in a different way.
		---@return function
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
					for i = #target, 1, -1 do
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
		---@param count integer @Number of clicks
		---@return function
		ScrollUp = function(self, count)
			return function()
				MoveMouseWheel(count)
			end
		end,
		---Scroll mouse wheel down
		---@param count integer @Number of clicks
		---@return function
		ScrollDown = function(self, count)
			return function()
				MoveMouseWheel(-count)
			end
		end,
	},
	Cursor = {
		---Whether multiple monitors is connected
		MultiMonitor = false,
		---Resolution of the screen
		Resolution = { Width = 1920, Height = 1080 },
		---Move cursor by some pixels
		---@param x integer @Number of pixels horizontally
		---@param y integer @Number of pixels vertically
		---@return function
		Move = function(self, x, y)
			return function()
				local curx, cury = GetMousePosition()
				if (self.MultiMonitor) then
					MoveMouseToVirtual(curx + math.floor(x * 65535 / self.Resolution.Width),
						cury + math.floor(y * 65535 / self.Resolution.Height))
				else
					MoveMouseTo(curx + math.floor(x * 65535 / self.Resolution.Width),
						cury + math.floor(y * 65535 / self.Resolution.Height))
				end
			end
		end,
		---Move cursor to certian position
		---@param x integer @Abscissa of the position
		---@param y integer @Ordinate of the positoin
		---@return function
		MoveTo = function(self, x, y)
			return function()
				if (self.MultiMonitor) then
					MoveMouseToVirtual(math.floor(x * 65535 / self.Resolution.Width),
						math.floor(y * 65535 / self.Resolution.Height))
				else
					MoveMouseTo(math.floor(x * 65535 / self.Resolution.Width),
						math.floor(y * 65535 / self.Resolution.Height))
				end
			end
		end,
	},
	Macro = {
		---Other playing macros will be aborted if this is set to true
		---@type boolean
		AbortBeforePlay = false,
		---Play macro
		---@param macroName string @Name of the macro
		---@return function
		Play = function(self, macroName)
			return function()
				if self.AboutBeforePlay then
					AbortMacro()
				end
				PlayMacro(macroName)
			end
		end
	},
	Delay = {
		---Sleep for some time
		---@param duration integer @Number of millisecond to sleep
		---@return function
		Sleep = function(self, duration)
			return function()
				Sleep(duration)
			end
		end
	}
}

--#endregion

--#region Key Combination Core

---@param button integer
---@return char
function EncodeButton(button)
	if button < 10 then
		return string.char(button + 48)
	else
		return string.char(button + 55)
	end
end

---@param buttonCode char
---@return integer
function DecodeButton(buttonCode)
	if string.isdigit(buttonCode) then
		return string.byte(buttonCode) - 48
	else
		return string.byte(buttonCode) - 55
	end
end

---@param list any[]
---@return boolean @Return false if list is currently the last permutation
local function NextPermutation(list)
	local length = #list
	local k, l = 0, 0
	for i = length - 1, 1, -1 do
		if list[i] < list[i + 1] then
			k = i
			break
		end
	end
	if k == 0 then
		return false
	end
	for i = length, k + 1, -1 do
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

---
KeyCombination = {
	---Keys and buttons currently pressed
	---@type string
	PressedButtons = "",

	Event = {
		---Collection of all registered events
		---@type table<string, Event>
		List = {},

		---Events currently on effect
		---@type string[]
		Current = {},

		---Register an event
		---@param sequence integer[] @Sequence of mouse buttons
		---@param action EventAction @Action to be performed when the event fires
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		Register = function(self, sequence, action, unorderedGroups)
			local unorderedGroupsIndex
			if unorderedGroups == "all" then
				unorderedGroups = { table.copy(sequence) }
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
				local indexTable = {}
				for i = 1, #sequence do
					indexTable[sequence[i]] = i
				end
				for i = 1, #unorderedGroups do
					for j = 1, #unorderedGroups[i] do
						unorderedGroups[i][j] = indexTable[unorderedGroups[i][j]]
					end
				end
				for i = 1, #unorderedGroups do
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
						if name:sub(1, #identifier) == identifier then
							isLeaf = false
							break
						end
					end
					--Update prefixs if being a leaf event
					if isLeaf then
						for i = 1, #identifier - 1 do
							local prefix = identifier:sub(1, i)
							if self.List[prefix] then
								self.List[prefix].IsLeaf = false
							end
						end
					end
					--Add event to EventList
					self.List[identifier] = { IsLeaf = isLeaf, Action = action }
				end
				if unorderedGroups == nil then
					break
				end
				local finished = true
				for i = #unorderedGroups, 1, -1 do
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
				for i = 1, #unorderedGroups do
					for j = 1, #unorderedGroups[i] do
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
		---@param combination integer|integer[] @Sequence of mouse buttons
		---@param action fun()|fun()[] @An action or a list of actions to be performed when the event fires
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterPressed = function(self, combination, action, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			self:Register(
				combination,
				{
					Pressed = type(action) == "function" and action or function()
						for _, act in ipairs(action) do
							act()
						end
					end
				},
				unorderedGroups
			)
		end,

		---Register an event firing when released
		---@param combination integer|integer[] @Sequence of mouse buttons
		---@param action fun()|fun()[] @An action or a list of actions to be performed when the event fires
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterReleased = function(self, combination, action, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			self:Register(
				combination,
				{
					Released = type(action) == "function" and action or function()
						for _, act in ipairs(action) do
							act()
						end
					end
				},
				unorderedGroups
			)
		end,

		---Register both pressed and released events
		---@param combination integer|integer[] @Sequence of mouse buttons
		---@param pAction fun()|fun()[] @An action or a list of actions to be performed on pressed
		---@param rAction fun()|fun()[] @An action or a list of actions to be performed on released
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterPressedAndReleased = function(self, combination, pAction, rAction, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			---@type EventAction
			local eventAction = {
				Pressed = type(pAction) == "function" and pAction or function()
					for _, act in ipairs(pAction) do
						act()
					end
				end,
				Released = type(rAction) == "function" and rAction or function()
					for _, act in ipairs(rAction) do
						act()
					end
				end,
			}
			self:Register(combination, eventAction, unorderedGroups)
		end,

		---Register a mapping from a mouse buttons sequence to a sequence of keys and buttons actions. Pressing actions will be registered to pressed event, and so is releasing.
		---@param combination integer|integer[] @Mouse buttons combinations
		---@param sequence MouseKeyboard|ActionSequence @Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay.
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterBind = function(self, combination, sequence, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			if (type(sequence) ~= "table") then
				sequence = { sequence }
			end
			local reversedDstCombination = {}
			for i = 1, #sequence do
				reversedDstCombination[i] = sequence[#sequence - i + 1]
			end

			self:Register(combination, {
				Pressed = Action.KeysAndButtons:Press(sequence),
				Released = Action.KeysAndButtons:Release(reversedDstCombination)
			}, unorderedGroups)
		end,

		---Register a mapping from a mouse buttons sequence to a sequence of keys and buttons actions. Clicking actions will be registered to released event.
		---@param combination integer|integer[] @Mouse buttons combinations
		---@param sequence MouseKeyboard|ActionSequence @Number represents mouse buttons, string for keyboard keys and string starting with "#" for delay.
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterReleasedBind = function(self, combination, sequence, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			if (type(sequence) ~= "table") then
				sequence = { sequence }
			end
			self:Register(combination, {
				Released = Action.KeysAndButtons:Click(sequence),
			}, unorderedGroups)
		end,

		---Register a macro playing action to released event
		---@param combination integer|integer[] @Mouse buttons combinations
		---@param macroName string @Name of the macro
		---@param unorderedGroups? integer[]|integer[][]|"all" @Order of the buttons within the table will be ignored.
		RegisterReleasedMacro = function(self, combination, macroName, unorderedGroups)
			if (type(combination) == "number") then
				combination = { combination }
			end
			self:Register(combination, {
				Released = Action.Macro:Play(macroName),
			}, unorderedGroups)
		end,
	},

	---Collection of custom handlers
	---@type ConfiguredHandler[]
	CustomHandlers = {},

	---Add handlers to be triggered before the main handler
	---@param handler Handler @The handling function
	---@param instrument? any @Instrumental variables for handler to use
	AddPreHandler = function(self, handler, instrument)
		self.CustomHandlers[#self.CustomHandlers + 1] = {
			TriggerTime = "pre",
			Handle = handler,
			Instrument = instrument,
		}
	end,

	---Add handlers to be triggered after the main handler
	---@param handler Handler @The handling function
	---@param instrument? any @Instrumental variables for handler to use
	AddPostHandler = function(self, handler, instrument)
		self.CustomHandlers[#self.CustomHandlers + 1] = {
			TriggerTime = "post",
			Handle = handler,
			Instrument = instrument,
		}
	end,

	---Function to be called when a mouse button is pressed
	---@param button integer
	PressButton = function(self, button)
		for i = 1, #self.CustomHandlers do
			if self.CustomHandlers[i].TriggerTime == "pre" then
				self.CustomHandlers[i]:Handle("press", button, self.PressedButtons)
			end
		end
		self.PressedButtons = self.PressedButtons .. EncodeButton(button)
		local current = self.Event.Current
		local eventButtons = self.PressedButtons
		local event = self.Event.List[eventButtons]
		if event == nil and #current > 0 then
			local finish
			_, finish = self.PressedButtons:find(current[#current])
			eventButtons = self.PressedButtons:sub(finish + 1)
			event = self.Event.List[eventButtons]
		end
		if event then
			local index = #current + 1
			if #current > 0 then
				local lastEventButtons = current[#current]
				if eventButtons:find(lastEventButtons) == 1 and not self.Event.List[lastEventButtons].Action.Pressed then
					index = index - 1
				end
			end
			current[index] = eventButtons
			if event.Action.Pressed then
				event.Action.Pressed()
			end
		end
		for i = 1, #self.CustomHandlers do
			if self.CustomHandlers[i].TriggerTime == "post" then
				self.CustomHandlers[i]:Handle("press", button, self.PressedButtons)
			end
		end
	end,

	---Function to be called when a mouse button is released
	---@param button integer
	ReleaseButton = function(self, button)
		for i = 1, #self.CustomHandlers do
			if self.CustomHandlers[i].TriggerTime == "pre" then
				self.CustomHandlers[i]:Handle("release", button, self.PressedButtons)
			end
		end
		local btn = EncodeButton(button)
		local current = self.Event.Current
		for i, cur in ipairs(current) do
			local event = self.Event.List[cur]
			if event and cur:find(btn) then
				if event.Action.Released then
					event.Action.Released()
				end
				current[i] = ""
			end
		end
		local cursor = 1
		local length = #current
		for i = 1, length do
			if (current[i] == "") then
				current[i] = nil
			else
				if cursor ~= i then
					current[cursor] = current[i]
					current[i] = nil
				end
				cursor = cursor + 1
			end
		end
		local position = self.PressedButtons:find(btn)
		if position then
			self.PressedButtons = self.PressedButtons:sub(1, position - 1) .. self.PressedButtons:sub(position + 1)
		end
		for i = 1, #self.CustomHandlers do
			if self.CustomHandlers[i].TriggerTime == "post" then
				self.CustomHandlers[i]:Handle("release", button, self.PressedButtons)
			end
		end
	end
}
--#endregion

--#region Activation & Deactivation Handlers
---@type fun()[]
ActivationHandlers = {
	Add = function(self, handler)
		self[#self + 1] = handler
	end
}

---@type fun()[]
DeactivationHandlers = {
	Add = function(self, handler)
		self[#self + 1] = handler
	end
}
--#endregion

--#region API Event Handling

---Raw events provided by G-series API
---@type table<string,string>
RawEvent = {
	Pressed = "MOUSE_BUTTON_PRESSED",
	Released = "MOUSE_BUTTON_RELEASED",
	Activated = "PROFILE_ACTIVATED",
	Deactivated = "PROFILE_DEACTIVATED",
}

EnablePrimaryMouseButtonEvents(true)

---Handling function to be called by GHUB when a raw event fires
---@param event string
---@param arg integer
function OnEvent(event, arg)
	if event == RawEvent.Activated then
		for _, handler in ipairs(ActivationHandlers) do
			handler()
		end
	elseif event == RawEvent.Deactivated then
		for _, handler in ipairs(DeactivationHandlers) do
			handler()
		end
	elseif event == RawEvent.Pressed then
		KeyCombination:PressButton(arg)
	elseif event == RawEvent.Released then
		KeyCombination:ReleaseButton(arg)
	end
end

--#endregion

--#region Mouse Enums

---Mouse functions
---@type table<string,number>
Mouse = {
	PrimaryClick = 1,
	MiddleClick = 2,
	SecondaryClick = 3,
	Forward = 4,
	Back = 5
}

---Collection of mouse button code mappings of common Logitech mouse models
---@type table<string,table<string,number>>
MouseModel = {
	G502Hero = {
		Primary = 1,
		Secondary = 2,
		Middle = 3,
		SideBack = 4,
		SideMiddle = 5,
		SideFront = 6,
		AuxiliaryBack = 7,
		AuxiliaryFront = 8,
		Top = 9,
		WheelRight = 10,
		WheelLeft = 11
	},
	G502X = {
		Primary = 1,
		Secondary = 2,
		Middle = 3,
		SideBack = 4,
		SideFront = 5,
		SideMiddle = 6,
		WheelLeft = 7,
		WheelRight = 8,
		Top = 9,
		AuxiliaryFront = 10,
		AuxiliaryBack = 11
	},
	G604LightSpeed = {
		Primary = 1,
		Secondary = 2,
		Middle = 3,
		SideBackDown = 4,
		SideMiddleDown = 5,
		SideFrontDown = 6,
		SideBackUp = 7,
		SideMiddleUp = 8,
		SideFrontUp = 9,
		AuxiliaryBack = 10,
		AuxiliaryFront = 11,
		WheelLeft = 12,
		WheelRight = 13
	},
	G903Hero = {
		Primary = 1,
		Secondary = 2,
		Middle = 3,
		LeftSideBack = 4,
		LeftSideFront = 5,
		RightSideBack = 6,
		RightSideFront = 7,
		TopLeft = 8,
		TopRight = 9,
		WheelLeft = 10,
		WheelRight = 11
	}
}

--#endregion

--#endregion

--#region Configurations

--Set your scrren resolution here
Action.Cursor.Resolution = {
	Width = 1920,
	Height = 1080
}
--Set your mouse model here
Button = MouseModel.G604LightSpeed

--#endregion

Event = KeyCombination.Event
--Register key combinations below
Event:RegisterBind(Button.Primary, Mouse.PrimaryClick)
Event:RegisterBind(Button.Secondary, Mouse.SecondaryClick)
