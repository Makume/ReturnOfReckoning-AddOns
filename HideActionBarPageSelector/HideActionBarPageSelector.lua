if not HideActionBarPageSelector then 
	HideActionBarPageSelector = {} 
end

function HideActionBarPageSelector.Initialize()
	local oldActionBarPageSelectorCreate = ActionBarPageSelector.Create
	ActionBarPageSelector.Create = function(self, ...)
        --oldActionBarPageSelectorCreate(self, ...)
    end
end