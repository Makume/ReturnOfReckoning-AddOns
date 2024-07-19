if not OnKeyPress then 
	OnKeyPress = {} 
end

OnKeyPress.Defaults = {
	CompareValue = false, 
	DefaultOnLButtonDown = ActionButton.OnLButtonDown,
	DefaultOnLButtonUp = ActionButton.OnLButtonUp
}

function OnKeyPress.OnInitialize()
	OnKeyPress.Defaults.CompareValue = SystemData.Settings.Interface.lockActionBars
	OnKeyPress.ChecklockActionBars()
	OnKeyPress.OldFrameManagerOnLButtonUp = FrameManager.OnLButtonUp
	FrameManager.OnLButtonUp = OnKeyPress.OnLButtonUp
end

function OnKeyPress.OnLButtonUp(...)
	OnKeyPress.OldFrameManagerOnLButtonUp(...)
	if SystemData.Settings.Interface.lockActionBars ~= OnKeyPress.Defaults.CompareValue then
		OnKeyPress.Defaults.CompareValue = SystemData.Settings.Interface.lockActionBars
		OnKeyPress.ChecklockActionBars()
	end
end

function OnKeyPress.ChecklockActionBars()
	if SystemData.Settings.Interface.lockActionBars then
		ActionButton.OnLButtonDown = ActionButton.OnLButtonUp
		ActionButton.OnLButtonUp = nil
	else
		ActionButton.OnLButtonDown = OnKeyPress.Defaults.DefaultOnLButtonDown
		ActionButton.OnLButtonUp = OnKeyPress.Defaults.DefaultOnLButtonUp
	end
end