if not WarBoard_Clock then
	WarBoard_Clock = {}
end

local LabelSetText = LabelSetText
local LabelSetTextColor = LabelSetTextColor
local WarBoard_Clock = WarBoard_Clock
local WindowGetShowing = WindowGetShowing
local WindowSetShowing = WindowSetShowing
local wstring_format = wstring.format
local Tooltips = Tooltips
local old_total_seconds = 0

function WarBoard_Clock.OnOptionsButton()
	WindowSetShowing("WarBoard_ClockOptions", not WindowGetShowing("WarBoard_ClockOptions"))
end

function WarBoard_Clock.Initialize()
	if not WarBoard.AddMod("WarBoard_Clock") then
		return
	end
	if not WarBoard_ClockSettings then
		WarBoard_ClockSettings =
		{
			Hours = 24,
			AmPm = false,
			Format = L"%02d:%02d:%02d",
			R = 255,
			G = 255,
			B = 255,
			Offset = 0,
		}
	end
	WarBoard_ClockOptions.Initialize()
	LabelSetTextColor("WarBoard_ClockText", WarBoard_ClockSettings.R, WarBoard_ClockSettings.G, WarBoard_ClockSettings.B)
end

function WarBoard_Clock.OnUpdate(elapsedTime)
	local total_seconds = GetComputerTime()
	if old_total_seconds == total_seconds then
		-- The time hasn't changed so exit the function.
		return
	else
		old_total_seconds = total_seconds
	end
	-- Display the new time.
	LabelSetText("WarBoard_ClockText", WarBoard_Clock.CalcTime(total_seconds, 0)) 
end

function WarBoard_Clock.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip("WarBoard_Clock", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Clock"))
	local total_seconds = GetComputerTime()
	local offset = WarBoard_ClockSettings.Offset
	Tooltips.SetTooltipText(1,1, L"Clock");
	Tooltips.SetTooltipText(2,1, L"Local Time: "..WarBoard_Clock.CalcTime(total_seconds, 0));
	Tooltips.SetTooltipText(3,1, L"Server Time: "..WarBoard_Clock.CalcTime(total_seconds, offset));
	Tooltips.Finalize()
end

function WarBoard_Clock.CalcTime(total_seconds, offset)
	total_seconds = total_seconds + offset
	local clock_seconds = total_seconds % 60
	local total_minutes =(total_seconds - clock_seconds) / 60
	local clock_minutes = total_minutes % 60
	local total_hours =(total_minutes - clock_minutes) / 60
	local clock_hours = total_hours	
	local format_string = WarBoard_ClockSettings.Format
	if WarBoard_ClockSettings.AmPm then
		if clock_hours < 12 then
			format_string = format_string .. L" AM"
		else
			format_string = format_string .. L" PM"
		end
	end
	clock_hours = clock_hours % WarBoard_ClockSettings.Hours
	if clock_hours == 0 and WarBoard_ClockSettings.Hours == 12 then
		clock_hours = 12
	end 
	return wstring_format(format_string, clock_hours, clock_minutes, clock_seconds)
end