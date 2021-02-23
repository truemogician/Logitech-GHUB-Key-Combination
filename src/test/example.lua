package.path = package.path .. ";?.lua"
require "src/test/test framework"
require "src/key combination"

local auxilary = { count = 0 }
KeyCombination:AddPostHandler(
	function (self, event, button, pressed)
		if event == "press" then
			self.Instrument.count = self.Instrument.count + 1
		elseif event == "release" then
			self.Instrument.count = self.Instrument.count - 1
			if self.Instrument.count == 0 then
				print()
			end
		end
	end,
	auxilary
)
Event:RegisterBind({ Button.Primary }, { Mouse.PrimaryClick })
Event:RegisterBind({ Button.Secondary}, { Mouse.SecondaryClick })
Event:RegisterReleasedBind(
	{ Button.SideMiddle, Button.Primary },
	{ "a", "b", { "c", "d", { "e", "f" } }, "g" }
)
Event:RegisterReleasedMacro(
	{ Button.SideBack, Button.Secondary, Button.Primary },
	"MACRO",
	{ Button.Secondary, Button.Primary }
)

Test:Start(true)