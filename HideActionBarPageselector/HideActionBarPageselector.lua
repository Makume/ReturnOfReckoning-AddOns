if not HideActionBarPageselector then 
	HideActionBarPageselector = {} 
end

function HideActionBarPageselector.Initialize()
	local oldActionBarPageSelectorCreate = ActionBarPageSelector.Create
	ActionBarPageSelector.Create = function(self, ...)
        --oldActionBarPageSelectorCreate(self, ...)
    end
end