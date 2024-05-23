if not LogOutWindow then 
	LogOutWindow = {} 
end

if not LogOutWindow.settings then
	LogOutWindow.settings = {}
	LogOutWindow.settings.sounds = {enable = true, start = 500, cancel = 220}
end

local TimeDelay = .1
local Time = TimeDelay
local NewTime = 0
local WindowName = "LogOutWindow"

function LogOutWindow.OnInitialize()
	RegisterEventHandler(SystemData.Events.LOG_OUT, "LogOutWindow.LogOut")
	RegisterEventHandler(SystemData.Events.EXIT_GAME, "LogOutWindow.ExitGame")
	CreateWindow(WindowName, true)
	LabelSetText(WindowName.."TimerText", L"")
	ButtonSetText(WindowName.."Button", GetString(StringTables.Default.LABEL_CANCEL))
	ButtonSetDisabledFlag(WindowName.."Button", disabled)
	WindowSetShowing(WindowName, false)
end 

function LogOutWindow.Shutdown()
	UnRegisterEventHandler(SystemData.Events.LOG_OUT, "LogOutWindow.LogOut")
	UnRegisterEventHandler(SystemData.Events.EXIT_GAME, "LogOutWindow.ExitGame")	
end

function LogOutWindow.LogOut()
	LogOutWindow.SetType(0)
end

function LogOutWindow.ExitGame()
	LogOutWindow.SetType(1)	
end

function LogOutWindow.SetType(Type)
	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "LogOutWindow.UpdateProcess")
	local Text = L""
	if Type == 1 then
		Text = GetString(StringTables.Default.LABEL_EXIT_GAME)
	else
		Text = GetString(StringTables.Default.LABEL_LOG_OUT)
	end	
	LabelSetText(WindowName.."Type", Text)
end

function LogOutWindow.UpdateProcess(elapsed)
	Time = Time - elapsed
	NewTime = NewTime + elapsed
	if Time > 0 then 
		return 
	end
	Time = TimeDelay
	LogOutWindow.Tick()
end

function LogOutWindow.Cancel()
	-- TODO: No active API at the moment - Just hide the window
	WindowSetShowing(WindowName, false)
end 

function LogOutWindow.Tick()
	local Range = 0
	local _, filterId, msg = TextLogGetEntry("System", TextLogGetNumEntries("System")-1) 
	if msg ~= PO_Msg then
		PO_Msg = msg
		if msg == GetFormatStringFromTable("Hardcoded", 456, {20}) then	
			NewTime = .5
			Range = 0
			LogOutWindow.UpdateLabel()
			LabelSetTextColor(WindowName.."TimerText", 255, 255, 255)
			WindowSetShowing(WindowName, true)
			if LogOutWindow.settings.sounds.enable then
				PlaySound(LogOutWindow.settings.sounds.start)
			end					
		elseif msg == GetFormatStringFromTable("Hardcoded", 456, {15}) then	
			NewTime = 5
			Range = 5
			LogOutWindow.UpdateLabel()
		elseif msg == GetFormatStringFromTable("Hardcoded", 456, {10}) then	
			NewTime = 10
			Range = 10
			LogOutWindow.UpdateLabel()
		elseif msg == GetFormatStringFromTable("Hardcoded", 456, {5}) then		
			NewTime = 15
			Range = 15
			LogOutWindow.UpdateLabel()
			LabelSetTextColor(WindowName.."TimerText", 255, 0, 0)			
		elseif msg == GetStringFromTable("Hardcoded", 457) then	
			if LogOutWindow.settings.sounds.enable then
				PlaySound(LogOutWindow.settings.sounds.cancel)
			end
			WindowSetShowing(WindowName, false)
			UnRegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "LogOutWindow.UpdateProcess")
			return
		end
	end
	--if math.floor(NewTime) ~= Range and math.floor(NewTime) < Range + 5 then
		LogOutWindow.UpdateLabel()
	--end
end

function LogOutWindow.UpdateLabel()
	LabelSetText(WindowName.."TimerText", towstring("" .. 20 - math.floor(NewTime) .. "s"))
end