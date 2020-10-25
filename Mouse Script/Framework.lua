--A collection of actions provided by G-series Lua API
CommonAction={
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
	Keyboard={
		Press=function (self,...)
			local keys={...}
			return function()
				for index,value in ipairs(keys) do
					PressKey(value)
				end
			end
		end,
		Release=function (self,...)
			local keys={...}
			return function()
				for index,value in ipairs(keys) do
					ReleaseKey(value)
				end
			end
		end,
		ClickNestedly=function (self,...)
			local keys={...}
			return function()
				local length=#keys
				for i=1,length do
					PressKey(keys[i])
				end
				for i=length,1,-1 do
					ReleaseKey(keys[i])
				end
			end
		end,
		ClickParallelly=function (self,...)
			local keys={...}
			return function()
				for index,value in ipairs(keys) do
					PressAndReleaseKey(value)
				end
			end
		end,
	},
	Mouse={
		Button={
			Press=function (self,...)
				local keys={...}
				return function()
					for index,value in ipairs(keys) do
						PressMouseButton(value)
					end
				end
			end,
			Release=function (self,...)
				local keys={...}
				return function()
					for index,value in ipairs(keys) do
						ReleaseMouseButton(value)
					end
				end
			end,
			ClickNestedly=function (self,...)
				local keys={...}
				return function()
					local length=#keys
					for i=1,length do
						PressMouseButton(keys[i])
					end
					for i=length,1,-1 do
						ReleaseMouseButton(keys[i])
					end
				end
			end,
			ClickParallelly=function (self,...)
				local keys={...}
				return function()
					for index,value in ipairs(keys) do
						PressAndReleaseMouseButton(value)
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
		Location={
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
		DPI={
			CurrentDPI=3000,
			SetTo=function(self,dpi)
				return function()
					self.CurrentDPI=dpi
					SetMouseDPITable({self.CurrentDPI})
				end
			end,
			Increase=function(self,delta)
				return function()
					self.CurrentDPI=self.CurrentDPI+delta
					SetMouseDPITable({self.CurrentDPI})
				end
			end,
			Decrease=function(self,delta)
				return function()
					self.CurrentDPI=self.CurrentDPI-delta
					SetMouseDPITable({self.CurrentDPI})
				end
			end,
		}
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
CombinedEventHandler={
	EventList={},
	PressedButtons="",
	CurrentEvent="",
	EncodeButtonCode=function(button)
		if button<10 then
			return string.char(button+48)
		else
			return string.char(button+55)
		end
	end,
	RegisterEvent=function(self,action,...)
		--Get identifier
		local keys={...}
		local length=#keys
		if length==0 then
			return false
		end
		local identifier=""
		for i=1,length do
			identifier=identifier..self.EncodeButtonCode(keys[i])
		end
		--Event already exists
		if not self.EventList[identifier]==nil then
			self.EventList[identifier].Action=action
			return true
		end
		--Check whether current event is a leaf event
		local isLeaf=true
		for name in pairs(self.EventList) do
			if string.sub(name,1,#identifier)==identifier then
				isLeaf=false
				break
			end
		end
		--Update prefixs if being a leaf event
		if isLeaf then
			for i=1,#identifier-1 do
				local prefix=string.sub(identifier,1,i)
				if self.EventList[prefix] then
					self.EventList[prefix].IsLeaf=false
				end
			end
		end
		--Add event to EventList
		self.EventList[identifier]={IsLeaf=isLeaf,Action=action}
		return true
	end,
	PressButton=function(self,button)
		self.PressedButtons=self.PressedButtons..self.EncodeButtonCode(button)
        self.CurrentEvent=self.PressedButtons
        local event=self.EventList[self.CurrentEvent]
		if event and event.IsLeaf and event.Action.Pressed then
			event.Action.Pressed()
		end
	end,
    ReleaseButton=function(self,button)
        local event=self.EventList[self.CurrentEvent]
		if not (self.CurrentEvent=="") and event and event.Action.Released then
			event.Action.Released()
			self.CurrentEvent=nil
		end
		local buttonCode=self.EncodeButtonCode(button)
		local startIndex=string.find(self.PressedButtons,buttonCode)
		if startIndex then
			self.PressedButtons=string.sub(self.PressedButtons,1,startIndex-1)
		end
	end
}
--Basic Event handler provided by G-series Lua API
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
		CommonAction.Mouse.DPI.CurrentDPI=Settings.DefaultDPI
		CommonAction.Mouse.Location.Resolution={Width=Settings.ScreenResolution[1],Height=Settings.ScreenResolution[2]}
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
BasicMouseFunction={
	PrimaryClick=1,
	MiddleClick=2,
	SecondaryClick=3,
	Forward=4,
	Back=5
}
--Customize combined key actions here
Settings={
	DefaultDPI=3000,
	ScreenResolution={1920,1080}
}
CombinedEventHandler:RegisterEvent({
	Release=CommonAction.Mouse.Button:ClickNestedly(BasicMouseFunction.SecondaryClick),
},MouseButton.Secondary)
CombinedEventHandler:RegisterEvent({
	Released=CommonAction.Keyboard:ClickNestedly("lctrl","c"),
},MouseButton.SideFront,MouseButton.Primary)
CombinedEventHandler:RegisterEvent({
	Pressed=CommonAction.Keyboard:Press("lctrl","v"),
	Released=CommonAction.Keyboard:Release("v","lctrl"),
},MouseButton.SideFront,MouseButton.Secondary)