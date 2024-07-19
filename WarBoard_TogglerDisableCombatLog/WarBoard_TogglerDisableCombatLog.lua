if not WarBoard_TogglerDisableCombatLog then 
	WarBoard_TogglerDisableCombatLog = {} 
end

WarBoard_TogglerDisableCombatLog.Defaults = {
	Enabled = true
}

local WarBoard_TogglerDisableCombatLog = WarBoard_TogglerDisableCombatLog
local ModName = "WarBoard_TogglerDisableCombatLog"
local LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips = LabelSetTextColor, LabelSetText, WindowSetAlpha, Tooltips

function WarBoard_TogglerDisableCombatLog.Initialize()
	if DisableCombatLog then
		if WarBoard.AddMod(ModName) then
			WindowSetAlpha(ModName.."Background",0.25)
			LabelSetTextColor(ModName.."Title",255,200,0)
			LabelSetText(ModName.."Title", L"Combat Log")
			WarBoard_TogglerDisableCombatLog.OnClick()
		end
	end
end

function WarBoard_TogglerDisableCombatLog.OnClick()
	if WarBoard_TogglerDisableCombatLog.Defaults.Enabled then
		DisableCombatLog.OnInitialize()
		TextLogAddEntry("Chat",SystemData.ChatLogFilters.SHOUT,L"[DisableCombatLog]: Disabled")
		LabelSetTextColor(ModName.."Title2",255,0,0)		
		LabelSetText(ModName.."Title2",L"Disabled")
		WarBoard_TogglerDisableCombatLog.Defaults.Enabled = false
	else
		DisableCombatLog.Shutdown()
		TextLogAddEntry("Chat",SystemData.ChatLogFilters.SHOUT,L"[DisableCombatLog]: Enabled")
		LabelSetTextColor(ModName.."Title2", 0, 255, 0)
		LabelSetText(ModName.."Title2",L"Enabled")
		WarBoard_TogglerDisableCombatLog.Defaults.Enabled = true
	end
end

function WarBoard_TogglerDisableCombatLog.OnMouseOver()
	Tooltips.CreateTextOnlyTooltip(ModName, nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor(ModName))
	Tooltips.SetTooltipText(1,1,L"Combat Log")
	Tooltips.SetTooltipText(2,1,L"Left Mouse to enable/disable the Combat Log");
	Tooltips.Finalize()
end