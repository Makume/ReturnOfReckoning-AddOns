if not SellPrice then 
	SellPrice = {} 
end

function SellPrice.Initialize() 
	RegisterEventHandler(SystemData.Events.AUCTION_SEARCH_RESULT_RECEIVED, "SellPrice.AuctionSearchResultReceived")
	SellPrice.OldCreateItemTooltip = Tooltips.CreateItemTooltip
	Tooltips.CreateItemTooltip = SellPrice.CreateItemTooltip
end

function SellPrice.Shutdown()
	UnRegisterEventHandler(SystemData.Events.AUCTION_SEARCH_RESULT_RECEIVED, "SellPrice.AuctionSearchResultReceived")
	Tooltips.CreateItemTooltip = SellPrice.OldCreateItemTooltip
end

function SellPrice.CreateItemTooltip(itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
	SellPrice.OldCreateItemTooltip(itemData, mouseoverWindow, anchor, disableComparison, extraText, extraTextColor, ignoreBroken)
	local atStore = EA_Window_InteractionStore.InteractingWithStore() or EA_Window_InteractionLibrarianStore.InteractingWithLibrarianStore()
	if not atStore then
		Tooltips.ShowSellPrice(itemData)
	end
    SellPrice.DestroyWindows(Tooltips.curTooltipWindow.."SellPrice")
    if (not SellPrice.IsShowing()) then
        local searchQuery = AuctionWindowListDataManager.CreateEmptyQuery()
        searchQuery.itemName = itemData.name
        AuctionWindowListDataManager.SendAuctionSearch(searchQuery)
    end
end

function SellPrice.AuctionSearchResultReceived(searchResultsTable)
    if (searchResultsTable == nil) then
        return
    end
	local ipairs = ipairs
	local itemData
    local Min = 0
    local Max = 0
    local Avg = 0
    local StackCount = 0
    local SumPrice = 0
	for _, v in ipairs(searchResultsTable) do
		itemData = v.itemData
        StackCount = StackCount + v.itemData.stackCount
        SumPrice = SumPrice + v.buyOutPrice
        if (Min == 0) then
            Min = v.buyOutPrice / v.itemData.stackCount
        else
            if ((v.buyOutPrice / v.itemData.stackCount) < Min) then
                Min = v.buyOutPrice / v.itemData.stackCount
            end
        end
        if (Max == 0) then
            Max = v.buyOutPrice / v.itemData.stackCount
        else
            if ((v.buyOutPrice / v.itemData.stackCount) > Max) then
                Max = v.buyOutPrice / v.itemData.stackCount
            end
        end
	end
    if StackCount > 0 then
        Avg = SumPrice / StackCount
    end
	SellPrice.ShowAuctionHousePrices(itemData, Min, Max, Avg)
end

function SellPrice.ShowAuctionHousePrices(itemData, min, max, avg)
    if(itemData == nil) then
        return
    end
    local priceWindow, repairableItemWindow
    if itemData.broken then
        if itemData.repairedName ~= nil and itemData.repairedName ~= L"" then
            priceWindow = "BrokenItemTooltipRepairedItemSellPrice"
            repairableItemWindow = "BrokenItemTooltipRepairedItem"
        else
            priceWindow = "BrokenItemTooltipSellPrice"
        end
    else
        priceWindow = Tooltips.curTooltipWindow.."SellPrice";
    end    
    local w, h = WindowGetDimensions(Tooltips.curTooltipWindow)
    local x = 0
    local y = 0
    if (not DoesWindowExist(priceWindow)) then
        return
    end
    x, y = WindowGetDimensions(priceWindow)
    local padding = 70
    h =(h + y + padding)
    WindowSetDimensions(Tooltips.curTooltipWindow, w, h)
    if repairableItemWindow ~= nil then
        w, h = WindowGetDimensions(repairableItemWindow)
        h =(h + y + padding)  
        WindowSetDimensions(repairableItemWindow, w, h)
    end
    local moneyWindow = Tooltips.curTooltipWindow.."SellPrice"
    SellPrice.SetAuctionHouseMoneyText(moneyWindow, L"Auctionhouse", 0, 30) 
    SellPrice.SetAuctionHouseMoneyText(moneyWindow, L"Min", min, 50) 
    SellPrice.SetAuctionHouseMoneyText(moneyWindow, L"Max", max, 70)
    SellPrice.SetAuctionHouseMoneyText(moneyWindow, L"Avg", avg, 90)
end

function SellPrice.SetAuctionHouseMoneyText(moneyWindow, label, value, y)
    local newmoneyWindow = moneyWindow..tostring(label)
    if (not DoesWindowExist(newmoneyWindow)) then
        CreateWindowFromTemplate(newmoneyWindow, "GlyphTooltipInfo", moneyWindow) 
    end
    if (label == L"Auctionhouse") then
        LabelSetText(newmoneyWindow, towstring(GetStringFromTable("AuctionHouseStrings", StringTables.AuctionHouse.MAIN_TITLE)) .. L" (per piece): ")
    else
        LabelSetText(newmoneyWindow, label .. L": " .. MoneyFrame.FormatMoneyString(math.floor(value), true, nil))
    end
    WindowAddAnchor(newmoneyWindow, "left", moneyWindow, "left", 0, y)
	WindowSetShowing(newmoneyWindow, true)
end

function SellPrice.DestroyWindows(moneyWindow)
    SellPrice.DestroyWindow(moneyWindow.."", "Auctionhouse")
    SellPrice.DestroyWindow(moneyWindow.."", "Min")
    SellPrice.DestroyWindow(moneyWindow.."", "Max")
    SellPrice.DestroyWindow(moneyWindow.."", "Avg")
end

function SellPrice.DestroyWindow(moneyWindow, label)
    local newmoneyWindow = moneyWindow..label
    if (DoesWindowExist(newmoneyWindow)) then
        DestroyWindow(newmoneyWindow)
    end 
end

function SellPrice.IsShowing()
    return WindowGetShowing("AuctionWindow")
end