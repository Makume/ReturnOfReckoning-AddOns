if not ActionOnLButtonDown then 
    ActionOnLButtonDown = {} 
end

function ActionOnLButtonDown.OnInitialize()
    ActionButton.OnRButtonDown = ActionButton.OnLButtonDown
    ActionButton.OnLButtonDown = ActionButton.OnLButtonUp
    ActionButton.OnLButtonUp = nil    
end