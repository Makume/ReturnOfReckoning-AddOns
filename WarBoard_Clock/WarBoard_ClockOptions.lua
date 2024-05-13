if not WarBoard_ClockOptions then WarBoard_ClockOptions = {} end
local WarBoard_ClockOptions = WarBoard_ClockOptions
local LabelSetText, TextEditBoxSetText, ComboBoxClearMenuItems, ComboBoxAddMenuItem, ComboBoxButtonSetPressedFlag, SliderBarSetCurrentPosition,
	  ComboBoxGetSelectedMenuItem, WindowSetDimensions, SliderBarGetCurrentPosition, TextEditBoxSetText, Tooltips, floor =
	  LabelSetText, TextEditBoxSetText, ComboBoxClearMenuItems, ComboBoxAddMenuItem, ComboBoxButtonSetPressedFlag, SliderBarSetCurrentPosition,
	  ComboBoxGetSelectedMenuItem, WindowSetDimensions, SliderBarGetCurrentPosition, TextEditBoxSetText, Tooltips, math.floor
local COWindowName = "WarBoard_ClockOptions"

local function UpdateLabels()
	LabelSetText(COWindowName.."_lblRed", StringToWString("R: "..WarBoard_ClockSettings.R))
	LabelSetText(COWindowName.."_lblGreen", StringToWString("G: "..WarBoard_ClockSettings.G))
	LabelSetText(COWindowName.."_lblBlue", StringToWString("B: "..WarBoard_ClockSettings.B))
	TextEditBoxSetText(COWindowName.."_edtStringFormat", WarBoard_ClockSettings.Format)
	TextEditBoxSetText(COWindowName.."_OffsetSeconds", WarBoard_ClockSettings.Offset)
end

local function GetOption()
	if WarBoard_ClockSettings.Hours == 24 then
		return 2
	else
		return 1
	end
end

local function ReturnHour(option)
	if option == 2 then
		return 24
	else
		return 12
	end
end

local function SetClockWindowDims()
	local windowWidth = 75
	if WarBoard_ClockSettings.Format == L"%02d:%02d:%02d" then windowWidth = windowWidth + 35 end
	if WarBoard_ClockSettings.AmPm then windowWidth = windowWidth + 25 end
	WindowSetDimensions("WarBoard_Clock", windowWidth, 30)
end

function WarBoard_ClockOptions.Initialize()
	CreateWindow("WarBoard_ClockOptions", false)

	LabelSetText("WarBoard_ClockOptionsTitleBarText", L"WarBoard Clock Options")
	LabelSetText(COWindowName.."FootNote", L"Fluke")
	LabelSetText(COWindowName.."_lblHourFormat", L"Format:")
	LabelSetText(COWindowName.."_lblDisplaySettings", L"Display Settings")
	LabelSetText(COWindowName.."_lblServerTimeOffsetSettings", L"Servertime Settings")
	LabelSetText(COWindowName.."_lblOffsetSeconds", L"Offset:")
	LabelSetText(COWindowName.."_lblColor", L"Text Color")
	LabelSetText(COWindowName.."_lblUseAMPM", L"Show AM/PM:")
	LabelSetText(COWindowName.."_lblStringFormat", L"String Format:")

	ComboBoxClearMenuItems(COWindowName.."_cmbHourFormat")
	ComboBoxAddMenuItem(COWindowName.."_cmbHourFormat", L"12")
	ComboBoxAddMenuItem(COWindowName.."_cmbHourFormat", L"24")
	ComboBoxSetSelectedMenuItem(COWindowName.."_cmbHourFormat", GetOption())

	ButtonSetPressedFlag(COWindowName.."_chkUseAMPM", WarBoard_ClockSettings.AmPm)

	SliderBarSetCurrentPosition(COWindowName.."_slbRed", WarBoard_ClockSettings.R / 255)
	SliderBarSetCurrentPosition(COWindowName.."_slbGreen", WarBoard_ClockSettings.G / 255)
	SliderBarSetCurrentPosition(COWindowName.."_slbBlue", WarBoard_ClockSettings.B / 255)
	UpdateLabels()
	SetClockWindowDims()
end

function WarBoard_ClockOptions.OnHourFormatSelected(choiceIndex)
	WarBoard_ClockSettings.Hours = ReturnHour(ComboBoxGetSelectedMenuItem(COWindowName.."_cmbHourFormat"))
end

function WarBoard_ClockOptions.OnToggleAmPm()
	WarBoard_ClockSettings.AmPm = not WarBoard_ClockSettings.AmPm
	SetClockWindowDims()
	ButtonSetPressedFlag(COWindowName.."_chkUseAMPM", WarBoard_ClockSettings.AmPm)
end

function WarBoard_ClockOptions.OnSliderChange()
	WarBoard_ClockSettings.R = floor(SliderBarGetCurrentPosition(COWindowName.."_slbRed")*255)
	WarBoard_ClockSettings.G = floor(SliderBarGetCurrentPosition(COWindowName.."_slbGreen")*255)
	WarBoard_ClockSettings.B = floor(SliderBarGetCurrentPosition(COWindowName.."_slbBlue")*255)
	LabelSetTextColor("WarBoard_ClockText", WarBoard_ClockSettings.R, WarBoard_ClockSettings.G, WarBoard_ClockSettings.B)
	UpdateLabels()
end

function WarBoard_ClockOptions.OnEnterKeyPressed()
	if COWindowName == WindowGetParent(SystemData.ActiveWindow.name) then
		WarBoard_ClockSettings.Format = TextEditBoxGetText(COWindowName.."_edtStringFormat")
		WarBoard_ClockSettings.Offset = TextEditBoxGetText(COWindowName.."_OffsetSeconds")
		SetClockWindowDims()
	end
end

function WarBoard_ClockOptions.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name)
	Tooltips.SetTooltipText (1, 1,  L"Format String")
	Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
	Tooltips.SetTooltipText (2, 1,  L"With seconds:")
	Tooltips.SetTooltipText (2, 2,  L"")
	Tooltips.SetTooltipText (2, 3,  L"%02d:%02d:%02d")
	Tooltips.SetTooltipText (3, 1,  L"Without seconds:")
	Tooltips.SetTooltipText (3, 2,  L"")
	Tooltips.SetTooltipText (3, 3,  L"%02d:%02d")
	Tooltips.SetTooltipText (5, 1,  L"Press Enter in the field when done.")
	Tooltips.Finalize()
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end

function WarBoard_ClockOptions.OnMouseOverOffset()
	Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name)
	--WarBoard_ClockSettings.Offset = TextEditBoxGetText(COWindowName.."_OffsetSeconds")
	Tooltips.SetTooltipText (1, 1,  L"Offset Format")
	Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
	Tooltips.SetTooltipText (2, 1,  L"Must be given in seconds")
	Tooltips.SetTooltipText (2, 2,  L"")
	Tooltips.SetTooltipText (2, 3,  L"")
	Tooltips.SetTooltipText (3, 1,  L"Example:")
	Tooltips.SetTooltipText (3, 2,  L"1 Hour")
	Tooltips.SetTooltipText (3, 3,  L"3600")	
	Tooltips.SetTooltipText (5, 1,  L"Press Enter in the field when done.")
	Tooltips.Finalize()
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP)
end

function WarBoard_ClockOptions.Hide()
	WindowSetShowing(COWindowName, false)
end

function WarBoard_ClockOptions.OnShown()
	UpdateLabels()
end