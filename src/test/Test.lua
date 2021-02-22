package.path = package.path .. ";?.lua"
require "src/test/test framework"
require "src/key combination"

--Add special handlers and register events here
local auxilary = { count = 0 }
CombinedEventHandler:AddSpecialHandler(
	function (self, event, btn, pressed)
		print("pressed : " .. pressed, "count : " .. self.Auxiliary.count, "btn : " .. btn)
		if event == "press" then
			self.Auxiliary.count = self.Auxiliary.count + 1
		elseif event == "release" then
			self.Auxiliary.count = self.Auxiliary.count - 1
		end
	end,
	auxilary
)
Event:RegisterBind({ Button.Primary }, { Mouse.PrimaryClick })
Event:RegisterBind({ Button.Secondary}, { Mouse.SecondaryClick })

Test:Start(true)