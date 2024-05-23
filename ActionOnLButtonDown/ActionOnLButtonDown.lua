if not ActionOnLButtonDown then 
    ActionOnLButtonDown = {} 
end

function ActionOnLButtonDown.OnInitialize()
    ActionButton.OnLButtonDown = ActionButton.OnLButtonUp
    ActionButton.OnLButtonUp = nil
end