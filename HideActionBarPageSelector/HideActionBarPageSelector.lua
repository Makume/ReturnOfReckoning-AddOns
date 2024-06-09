if not HideActionBarPageSelector then 
	HideActionBarPageSelector = {} 
end

function HideActionBarPageSelector.Initialize()
	ActionBarPageSelector.Create = function(self, ...)
	end
end