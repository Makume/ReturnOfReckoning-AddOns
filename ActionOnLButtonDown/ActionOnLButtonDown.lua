if not ActionOnLButtonDown then 
	ActionOnLButtonDown = {} 
end

ActionOnLButtonDown.Defaults = {
	CompareValue = false, 
	DefaultOnLButtonDown = ActionButton.OnLButtonDown,
	DefaultOnLButtonUp = ActionButton.OnLButtonUp
}

function ActionOnLButtonDown.OnInitialize()
	ActionOnLButtonDown.Defaults.CompareValue = SystemData.Settings.Interface.lockActionBars
	ActionOnLButtonDown.ChecklockActionBars()
	ActionOnLButtonDown.OldFrameManagerOnLButtonUp = FrameManager.OnLButtonUp
	FrameManager.OnLButtonUp = ActionOnLButtonDown.OnLButtonUp
end

function ActionOnLButtonDown.OnLButtonUp(...)
	ActionOnLButtonDown.OldFrameManagerOnLButtonUp(...)
	if SystemData.Settings.Interface.lockActionBars ~= ActionOnLButtonDown.Defaults.CompareValue then
		ActionOnLButtonDown.Defaults.CompareValue = SystemData.Settings.Interface.lockActionBars
		ActionOnLButtonDown.ChecklockActionBars()
	end
end

function ActionOnLButtonDown.ChecklockActionBars()
	if SystemData.Settings.Interface.lockActionBars then
		ActionButton.OnLButtonDown = ActionButton.OnLButtonUp
		ActionButton.OnLButtonUp = nil
	else
		ActionButton.OnLButtonDown = ActionOnLButtonDown.Defaults.DefaultOnLButtonDown
		ActionButton.OnLButtonUp = ActionOnLButtonDown.Defaults.DefaultOnLButtonUp
	end
end