--Test framework
function OutputLogMessage(...)
	print("Log : ".. ...)
end
function ClearLog()
	print("Log cleaared")
end
function Sleep(arg)
	print("Sleep "..arg.." ms")
end
function PressKey(arg)
	print("Key "..arg.." is pressed")
end
function ReleaseKey(arg)
	print("Key "..arg.." is released")
end
function PressAndReleaseKey(arg)
	print("Key "..arg.." is pressed and released")
end
function PressMouseButton(arg)
	print("Mouse button "..arg.." is pressed")
end
function ReleaseMouseButton(arg)
	print("Mouse button "..arg.." is released")
end
function PressAndReleaseMouseButton(arg)
	print("Mouse button "..arg.." is pressed and released")
end
function MoveMouseWheel(arg)
	print("Mouse wheel is moved "..arg.." clicks")
end
function MoveMouseRelative(x,y)
	print("Cursor is moved "..x..","..y.." relatively")
end
function MoveMouseTo(x,y)
	print("Cursor is moved to "..x..","..y)
end
function AbortMacro()
	print("All playing macros are aborted")
end
function PlayMacro(name)
	print("Macro \""..name.."\" is played")
end
function EnablePrimaryMouseButtonEvents(arg)
	if arg==true then
		print("Primary mouse button events are enabled")
	else
		print("Primary mouse button events are disabled")
	end
end
OnEvent(Event.Activated)
while true do
	local line=io.read()
	local space=line:find(" ")
	local event,arg
	if space==nil then
		event=line
		arg=nil
	else
		event=line:sub(1,space-1):lower()
		arg=line:sub(space+1)
	end
	if event=="press" then
		OnEvent(Event.Pressed,MouseButton[arg])
	elseif event=="release" then
		OnEvent(Event.Released,MouseButton[arg])
	elseif event=="deactive" then
		OnEvent(Event.Deactivated)
		break
	end
end