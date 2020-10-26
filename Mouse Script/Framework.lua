--Extent methods for standard libraries
string.at=function(self,index)
	return self:sub(index,index)
end
string.isdigit=function(char)
	return char>="0" and char<="9"
end
--A collection of actions provided by G-series Lua API
Action={
	Debug={
		Print=function(self,...)
			local args={...}
			return function()
				local content=""
				for index,value in ipairs(args) do
					content=content..value
				end
				OutputLogMessage(content.."\n")
			end
		end,
		Clear=function()
			return function()
				ClearLog()
			end
		end,
	},
	KeysAndButtons={
		Press=function (self,keysAndButtons)
			return function()
				for index,value in ipairs(keysAndButtons) do
					if type(value)=="string" then
						PressKey(value)
					elseif type(value)=="number" then
						PressMouseButton(value)
					end
				end
			end
		end,
		Release=function (self,keysAndButtons)
			return function()
				for index,value in ipairs(keysAndButtons) do
					if type(value)=="string" then
						ReleaseKey(value)
					elseif type(value)=="number" then
						ReleaseMouseButton(value)
					end
				end
			end
		end,
		ClickNestedly=function (self,keysAndButtons)
			return function()
				local length=#keysAndButtons
				for i=1,length do
					local value=keysAndButtons[i]
					if type(value)=="string" then
						PressKey(value)
					elseif type(value)=="number" then
						PressMouseButton(value)
					end
				end
				for i=length,1,-1 do
					local value=keysAndButtons[i]
					if type(value)=="string" then
						ReleaseKey(value)
					elseif type(value)=="number" then
						ReleaseMouseButton(value)
					end
				end
			end
		end,
		Click=function (self,keysAndButtons)
			return function()
				for index,value in ipairs(keysAndButtons) do
					if type(value)=="string" then
						PressAndReleaseKey(value)
					elseif type(value)=="number" then
						PressAndReleaseMouseButton(value)
					end
				end
			end
		end,
	},
	Wheel={
		MoveUp=function(self,count)
			return function()
				MoveMouseWheel(count)
			end
		end,
		MoveDown=function(self,count)
			return function()
				MoveMouseWheel(-count)
			end
		end,
	},
	Cursor={
		Resolution={Width=1920,Height=1080},
		Move=function(self,x,y)
			return function()
				MoveMouseRelative(x*self.Resolution.Width/65535,y*self.Resolution.Height/65535)
			end
		end,
		MoveTo=function(self,x,y)
			return function()
				MoveMouseTo(x*self.Resolution.Width/65535,y*self.Resolution.Height/65535)
			end
		end,
	},
	Macro={
		AbortOtherMacrosBeforePlay=false,
		Play=function(self,macroName)
			return function()
				if self.AbortOtherMacrosBeforePlay then
					AbortMacro()
				end
				PlayMacro(macroName)
			end
		end
	},
}
--Event handler for combined key event
function EncodeButton(button)
	if button<10 then
		return string.char(button+48)
	else
		return string.char(button+55)
	end
end
function DecodeButton(buttonCode)
	if string.isdigit(buttonCode) then
		return string.byte(buttonCode)-48
	else
		return string.byte(buttonCode)-55
	end
end
CombinedEventHandler={
	PressedButtons="",
	Event={
		List={},
		Current="",
		Register=function(self,combination,action)
			--Get identifier
			local length=#combination
			if length==0 then
				return false
			end
			local identifier=""
			for i=1,length do
				identifier=identifier..EncodeButton(combination[i])
			end
			--Event already exists
			if self.List[identifier] then
				self.List[identifier].Action=action
				return true
			end
			--Check whether current event is a leaf event
			local isLeaf=true
			for name in pairs(self.List) do
				if name:sub(1,#identifier)==identifier then
					isLeaf=false
					break
				end
			end
			--Update prefixs if being a leaf event
			if isLeaf then
				for i=1,#identifier-1 do
					local prefix=identifier:sub(1,i)
					if self.List[prefix] then
						self.List[prefix].IsLeaf=false
					end
				end
			end
			--Add event to EventList
			self.List[identifier]={IsLeaf=isLeaf,Action=action}
			return true
		end,
		RegisterPressed=function(self,combination,pAction)
			self:Register(combination,{Pressed=pAction})
		end,
		RegisterReleased=function(self,combination,rAction)
			self:Register(combination,{Released=rAction})
		end,
		RegisterPressedAndReleassed=function(self,combination,pAction,rAction)
			self:Register(combination,{Pressed=pAction,Released=rAction})
		end,
		RegisterBind=function(self,srcCombination,dstCombination)
			local reversedDstCombination={}
			for i=1,#dstCombination do
				reversedDstCombination[i]=dstCombination[#dstCombination-i+1]
			end
			self:Register(srcCombination,{
				Pressed=Action.KeysAndButtons:Press(dstCombination),
				Released=Action.KeysAndButtons:Release(reversedDstCombination),
			})
		end,
		RegisterReleasedBind=function(self,srcCombination,dstCombination)
			self:Register(srcCombination,{
				Released=Action.KeysAndButtons:ClickNestedly(dstCombination),
			})
		end,
		RegisterReleasedMacro=function(self,srcCombination,macroName)
			self:Register(srcCombination,{
				Released=Action.Macro:Play(macroName),
			})
		end
	},
	SpecialHandlers={},
	AddSpecialHandler=function(self,handle,auxiliary)
		self.SpecialHandlers[#self.SpecialHandlers+1] = {
			Handle=handle,
			Auxiliary=auxiliary,
		}
	end,
	PressButton=function(self,button)
		for i=1,#self.SpecialHandlers do
			self.SpecialHandlers[i]:Handle("press",button,self.PressedButtons)
		end
		self.PressedButtons=self.PressedButtons..EncodeButton(button)
        self.Event.Current=self.PressedButtons
		local event=self.Event.List[self.Event.Current]
		if event and event.Action.Pressed then
			event.Action.Pressed()
		end
	end,
	ReleaseButton=function(self,button)
		for i=1,#self.SpecialHandlers do
			self.SpecialHandlers[i]:Handle("release",button,self.PressedButtons)
		end
		local event=self.Event.List[self.Event.Current]
		if event and event.Action.Released then
			event.Action.Released()
		end
		self.Event.Current=""
		local position=self.PressedButtons:find(EncodeButton(button))
		if position then
			self.PressedButtons=self.PressedButtons:sub(1,position-1)..self.PressedButtons:sub(position+1)
		end
	end
}
--Basic event handler provided by G-series Lua API
Event={
	Pressed="MOUSE_BUTTON_PRESSED",
	Released="MOUSE_BUTTON_RELEASED",
	Activated="PROFILE_ACTIVATED",
	Deactivated="PROFILE_DEACTIVATED",
}
EnablePrimaryMouseButtonEvents(true)
function OnEvent(event, arg)
	if event==Event.Pressed then
		CombinedEventHandler:PressButton(arg)
	elseif event==Event.Released then
		CombinedEventHandler:ReleaseButton(arg)
	elseif event==Event.Activated then
		Action.Cursor.Resolution={Width=Settings.ScreenResolution[1],Height=Settings.ScreenResolution[2]}
	end
end
--Enums for some mouse action parameters
MouseButton={
	Primary=1,
	Secondary=2,
	Middle=3,
	SideBack=4,
	SideMiddle=5,
	SideFront=6,
	AuxiliaryBack=7,
	AuxiliaryFront=8,
	Back=9,
	WheelRight=10,
	WheelLeft=11,
}
MouseFunction={
	PrimaryClick=1,
	MiddleClick=2,
	SecondaryClick=3,
	Forward=4,
	Back=5
}
function RegisterBasicFunctions()
	CombinedEventHandler.Event:RegisterBind({MouseButton.Primary},{MouseFunction.PrimaryClick})
	CombinedEventHandler.Event:RegisterBind({MouseButton.Secondary},{MouseFunction.SecondaryClick})
	CombinedEventHandler.Event:RegisterBind({MouseButton.Middle},{MouseFunction.MiddleClick})
	CombinedEventHandler.Event:RegisterBind({MouseButton.SideMiddle},{MouseFunction.Forward})
	CombinedEventHandler.Event:RegisterBind({MouseButton.SideBack},{MouseFunction.Back})
end
--Customize combined key actions here
Settings={
	ScreenResolution={1920,1080},
}
CombinedEvent=CombinedEventHandler.Event