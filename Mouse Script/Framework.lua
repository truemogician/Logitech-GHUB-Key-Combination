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
	Keyboard={
		Press=function (self,keys)
			return function()
				for index,value in ipairs(keys) do
					PressKey(value)
				end
			end
		end,
		Release=function (self,keys)
			return function()
				for index,value in ipairs(keys) do
					ReleaseKey(value)
				end
			end
		end,
		ClickNestedly=function (self,keys)
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
		ClickParallelly=function (self,keys)
			return function()
				for index,value in ipairs(keys) do
					PressAndReleaseKey(value)
				end
			end
		end,
	},
	Mouse={
		Button={
			Press=function (self,keys)
				return function()
					for index,value in ipairs(keys) do
						PressMouseButton(value)
					end
				end
			end,
			Release=function (self,keys)
				return function()
					for index,value in ipairs(keys) do
						ReleaseMouseButton(value)
					end
				end
			end,
			ClickNestedly=function (self,keys)
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
			ClickParallelly=function (self,keys)
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
				if string.sub(name,1,#identifier)==identifier then
					isLeaf=false
					break
				end
			end
			--Update prefixs if being a leaf event
			if isLeaf then
				for i=1,#identifier-1 do
					local prefix=string.sub(identifier,1,i)
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
		RegisterKeyboradBind=function(self,srcCombination,dstCombination)
			local reversedDstCombination={}
			for i=1,#dstCombination do
				reversedDstCombination[i]=dstCombination[#dstCombination-i+1]
			end
			self:Register(srcCombination,{
				Pressed=Action.Keyboard:Press(dstCombination),
				Released=Action.Keyboard:Release(reversedDstCombination),
			})
		end,
		RegisterMouseBind=function(self,srcCombination,dstCombination)
			local reversedDstCombination={}
			for i=1,#dstCombination do
				reversedDstCombination[i]=dstCombination[#dstCombination-i+1]
			end
			self:Register(srcCombination,{
				Pressed=Action.Mouse.Button:Press(dstCombination),
				Released=Action.Mouse.Button:Release(reversedDstCombination),
			})
		end,
	},
	PressButton=function(self,button)
		self.PressedButtons=self.PressedButtons..EncodeButton(button)
        self.Event.Current=self.PressedButtons
		local event=self.Event.List[self.Event.Current]
		if event and event.IsLeaf and event.Action.Pressed then
			event.Action.Pressed()
		end
	end,
	ReleaseButton=function(self,button)
		local event=self.Event.List[self.Event.Current]
		if not (self.Event.Current=="") and event and event.Action.Released then
			event.Action.Released()
			self.Event.Current=nil
		end
		local buttonCode=EncodeButton(button)
		local startIndex=string.find(self.PressedButtons,buttonCode)
		if startIndex then
			self.PressedButtons=string.sub(self.PressedButtons,1,startIndex-1)
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
		Action.Mouse.Location.Resolution={Width=Settings.ScreenResolution[1],Height=Settings.ScreenResolution[2]}
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
	CombinedEventHandler.Event:RegisterMouseBind({MouseButton.Primary},{MouseFunction.PrimaryClick})
	CombinedEventHandler.Event:RegisterMouseBind({MouseButton.Secondary},{MouseFunction.SecondaryClick})
	CombinedEventHandler.Event:RegisterMouseBind({MouseButton.Middle},{MouseFunction.MiddleClick})
	CombinedEventHandler.Event:RegisterMouseBind({MouseButton.SideMiddle},{MouseFunction.Forward})
	CombinedEventHandler.Event:RegisterMouseBind({MouseButton.SideBack},{MouseFunction.Back})
end
--Customize combined key actions here
Settings={
	ScreenResolution={1920,1080},
}
CombinedEvent=CombinedEventHandler.Event