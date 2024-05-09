if not SellPrice then 
	SellPrice = {} 
end

function SellPrice.Initialize()
	SellPrice.OldDisplayItemTooltip = EA_Window_Backpack.DisplayItemTooltip
	EA_Window_Backpack.DisplayItemTooltip = SellPrice.DisplayItemTooltip
end

function SellPrice.DisplayItemTooltip(...)
	SellPrice.OldDisplayItemTooltip(...)
	SellPrice.ShowSellPrice(...)
end

function SellPrice.ShowSellPrice(itemData, mouseOverWindowName)
	local atStore = EA_Window_InteractionStore.InteractingWithStore() or EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore()
	if not atStore then
		Tooltips.ShowSellPrice(itemData)
	end
end