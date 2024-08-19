----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowTabSearch = {}
SocialWindowTabSearch.playerListData = {}
SocialWindowTabSearch.playerListOrder = {}

-- Sorting Parameters for the Player List
SocialWindowTabSearch.SORT_TYPE_NAME	 		= 1
SocialWindowTabSearch.SORT_TYPE_RANK			= 2
SocialWindowTabSearch.SORT_TYPE_CAREER	        = 3
SocialWindowTabSearch.SORT_TYPE_LOCATION        = 4
SocialWindowTabSearch.SORT_TYPE_MAX_NUMBER		= 4

SocialWindowTabSearch.FILTER_MEMBERS_ALL	    = 1
SocialWindowTabSearch.FILTER_MAX_NUMBER			= 1

SocialWindowTabSearch.SORT_ORDER_UP				= 1
SocialWindowTabSearch.SORT_ORDER_DOWN	        = 2

SocialWindowTabSearch.sortButtons = {  "SocialWindowTabSearchSortButtonBarNameButton",		-- Order List Header 
                                    "SocialWindowTabSearchSortButtonBarRankButton", 
                                    "SocialWindowTabSearchSortButtonBarCareerButton", 
                                    "SocialWindowTabSearchSortButtonBarLocationButton" }
                                    
-- Make sure these match the ID numbers in the XML definition 
--    For example,  <Button name="$parentNameButton" inherits="SocialHeaderButton" id="1"> 
SocialWindowTabSearch.sortKeys = {"name",
                               "rankString", 
                               "career", 
                               "location"  }

SocialWindowTabSearch.sortColumns = { "Name", 
                                   "Rank", 
                                   "Career", 
                                   "location"  }
                                   
SocialWindowTabSearch.display = { type=SocialWindowTabSearch.SORT_TYPE_NAME, 
                                order=SocialWindowTabSearch.SORT_ORDER_UP, 
                                filter=SocialWindowTabSearch.FILTER_MEMBERS_ALL }
SocialWindowTabSearch.ColumnHeaders = {   
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) }
                                      
SocialWindowTabSearch.SelectedSearchDataIndex    = 0
SocialWindowTabSearch.SelectedSearchName         = L""
SocialWindowTabSearch.SelectedSearchZoneList = {} -- we are going to need to sort this so it will have .name and .index
SocialWindowTabSearch.ZoneID = {}
SocialWindowTabSearch.ZoneID[1] = -1 -- this is set to -1 when all the zones should be searched

local function InitPlayerListData()
    SocialWindowTabSearch.playerListData = {}
    local numberFound = 0

    local SearchListData = GetSearchList()
    
    if ( SearchListData ~= nil ) then
		numberFound = #SearchListData
        for key, value in ipairs( SearchListData ) do
            -- These should match the data that was retrived from war_interface::LuaGetSearchList
            SocialWindowTabSearch.playerListData[key] = {}
            SocialWindowTabSearch.playerListData[key].name = value.name
            SocialWindowTabSearch.playerListData[key].career = value.career
            if ( value.zoneID ~= 0 ) then
                SocialWindowTabSearch.playerListData[key].rankString = L""..value.rank
                SocialWindowTabSearch.playerListData[key].location = GetZoneName( value.zoneID )
            else
                SocialWindowTabSearch.playerListData[key].rankString = L""	-- If the person is offline, rank is 0, so don't display it.
                SocialWindowTabSearch.playerListData[key].guildName  = L""	-- If the player has hidden their details, no Guildname exists.
                SocialWindowTabSearch.playerListData[key].location = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
            end

            SocialWindowTabSearch.playerListData[key].guildName = value.guildName
        end
    end

    if numberFound <= 0 then
		SocialWindowTabSearch.playerListData[1] = {}
		SocialWindowTabSearch.playerListData[1].name = GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_NO_RESULTS)
    end


end

-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local player1 = SocialWindowTabSearch.playerListData[index1]
    local player2 = SocialWindowTabSearch.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end

    local type = SocialWindowTabSearch.display.type
    local order = SocialWindowTabSearch.display.order
    
    local compareResult
-- Check for sorting by all the the string fields first
    
    -- Sorting by Name
    if( type == SocialWindowTabSearch.SORT_TYPE_NAME )then
        if( order == SocialWindowTabSearch.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            return ( WStringsCompare(player1.name, player2.name) > 0 )
        end
    end
    
    --Sorting By Career (And if they match, then sort alphabetically)
    if( type == SocialWindowTabSearch.SORT_TYPE_CAREER ) then
        compareResult = WStringsCompare(player1.career, player2.career)
        
        if (compareResult == 0) then
            compareResult = WStringsCompare(player1.name, player2.name)
        end
        
        if( order == SocialWindowTabSearch.SORT_ORDER_UP ) then
            return ( compareResult < 0 )
        else
            return ( compareResult > 0 )
        end		
    end

    -- Sorting By Location (And if they match, then sort alphabetically)
    if( type == SocialWindowTabSearch.SORT_TYPE_LOCATION ) then
        compareResult = WStringsCompare(player1.location, player2.location)
        
        if (compareResult == 0) then
            compareResult = WStringsCompare(player1.name, player2.name)
        end	
        
        if( order == SocialWindowTabSearch.SORT_ORDER_UP ) then
            return ( compareResult < 0)
        else
            return ( compareResult > 0)
        end
    end

-- Otherwise assume we're sorting by a number, not a string.
    local key = SocialWindowTabSearch.sortKeys[type]
    
    if (player1[key] == player2[key]) then
        compareResult = WStringsCompare(player1.name, player2.name)	-- In the case of a tie, sort by player name
    else
        if (tonumber(player1[key]) < tonumber(player2[key])) then
            compareResult = -1
        else
            compareResult = 1
        end
    end

    if( order == SocialWindowTabSearch.SORT_ORDER_UP ) then
        return ( compareResult < 0)
    else
        return ( compareResult > 0)
    end
end

local function SortPlayerList()	
    table.sort( SocialWindowTabSearch.playerListOrder, ComparePlayers )
end

local function FilterPlayerList()	
    
    local filter = SocialWindowTabSearch.display.filter

    SocialWindowTabSearch.playerListOrder = {}
    for dataIndex, data in ipairs( SocialWindowTabSearch.playerListData ) do
        table.insert(SocialWindowTabSearch.playerListOrder, dataIndex)
    end
end

local function UpdatePlayerList()
    -- Filter, Sort, and Update
    InitPlayerListData()
    SocialWindowTabSearch.display.filter = SocialWindowTabSearch.FILTER_MEMBERS_ALL
    FilterPlayerList()
    SortPlayerList()
    ListBoxSetDisplayOrder( "SocialWindowTabSearchList", SocialWindowTabSearch.playerListOrder )
end

-- OnInitialize Handler
function SocialWindowTabSearch.Initialize()

    -- Set all the header labels
    LabelSetText( "SocialWindowTabSearchEditBoxPlayerNameHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_PLAYER_HEADER) )
    LabelSetText( "SocialWindowTabSearchEditBoxGuildNameHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_GUILD_HEADER) )
    LabelSetText( "SocialWindowTabSearchEditBoxCareerNameHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_CAREER_HEADER) )
    LabelSetText( "SocialWindowTabSearchComboBoxZoneNamesHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_ZONE_HEADER) )
    LabelSetText( "SocialWindowTabSearchEditBoxMinRankHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_MIN_RANK_HEADER) )
    LabelSetText( "SocialWindowTabSearchEditBoxMaxRankHeader", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_MAX_RANK_HEADER) )
    LabelSetText( "SocialWindowTabSearchIncludeAdvisorsOnlyLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_CHECKBOX_ADVISORS_ONLY) )
    
    WindowSetTintColor("SocialWindowTabSearchOptionsBackground", 0, 0, 0 )

    -- Set the text for all the buttons
    ButtonSetText("SocialWindowTabSearchFindButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_FIND_BUTTON) )
    
    -- Setup the listbox
    ButtonSetText( "SocialWindowTabSearchSortButtonBarNameButton",  GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME) )
    ButtonSetText( "SocialWindowTabSearchSortButtonBarRankButton",	GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK) )
    ButtonSetText( "SocialWindowTabSearchSortButtonBarCareerButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER) )
    ButtonSetText( "SocialWindowTabSearchSortButtonBarLocationButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) )
    SocialWindowTabSearch.SetListRowTints()
    SocialWindowTabSearch.OnSearchUpdated()
    SocialWindowTabSearch.UpdateSortButtons()
    SocialWindowTabSearch.UpdateZoneList()

    -- Register all the Events for this Tab
    WindowRegisterEventHandler( "SocialWindowTabSearch", SystemData.Events.SOCIAL_SEARCH_UPDATED, "SocialWindowTabSearch.OnSearchUpdated")

    -- Set default Editbox Values
    TextEditBoxSetText("SocialWindowTabSearchEditBoxMinRank", L"1")
    TextEditBoxSetText("SocialWindowTabSearchEditBoxMaxRank", L"40")

end

function SocialWindowTabSearch.Shutdown()

end

function SocialWindowTabSearch.OnPressSetSearchButton()
    if SocialWindowTabSearch.OptionsLocked == 0 then
        SocialWindowTabSearch.OptionsLocked = 1
        ButtonSetText("SocialWindowTabSearchSetButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_Search_UNSET_BUTTON) )
        WindowSetTintColor("SocialWindowTabSearchOptionsBackground", 64, 64, 64 )
    else
        SocialWindowTabSearch.OptionsLocked = 0
        ButtonSetText("SocialWindowTabSearchSetButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_Search_SET_BUTTON) )
        WindowSetTintColor("SocialWindowTabSearchOptionsBackground", 0, 0, 0 )
    end
end

function SocialWindowTabSearch.OnKeyEscape()
    SocialWindowTabSearch.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabSearch.UpdateSelectedPlayerData( dataIndex )
    -- Set the label values
    if (dataIndex ~= nil and dataIndex~=0) then
        SocialWindowTabSearch.SelectedSearchDataIndex = dataIndex
        SocialWindowTabSearch.SelectedSearchName = SocialWindowTabSearch.playerListData[dataIndex].name
    else
        SocialWindowTabSearch.SelectedSearchDataIndex = 0
        SocialWindowTabSearch.SelectedSearchName = L""
    end

    SocialWindowTabSearch.UpdateSelectedRow()
end

function SocialWindowTabSearch.SetListRowTints()
    for row = 1, SocialWindowTabSearchList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "SocialWindowTabSearchListRow"..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
    
end



-- Callback from the <List> that updates a single row.
function SocialWindowTabSearch.UpdatePlayerRow()

    if (SocialWindowTabSearchList.PopulatorIndices == nil) 
    then
        return
    end

    for rowIndex, dataIndex in ipairs (SocialWindowTabSearchList.PopulatorIndices) 
    do
        local rowName = "SocialWindowTabSearchListRow"..rowIndex

        -- Change colors based on if the guild member is selected/unselected, or offline            
        local labelColor = DefaultColor.WHITE           -- Default Online Memebers are white            
        
        local labelOnlineText = LabelGetText(rowName.."Online")
        if ( WStringsCompare( labelOnlineText, GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE) ) == 0 ) 
        then
            labelColor = DefaultColor.MEDIUM_LIGHT_GRAY		-- Offline Members are grey
        end                       
        
        LabelSetTextColor( rowName.."Name", labelColor.r, labelColor.g, labelColor.b)
        LabelSetTextColor( rowName.."Rank", labelColor.r, labelColor.g, labelColor.b)
        LabelSetTextColor( rowName.."Career", labelColor.r, labelColor.g, labelColor.b)
        LabelSetTextColor( rowName.."Online", labelColor.r, labelColor.g, labelColor.b)
            
    end
    
    SocialWindowTabSearch.SetListRowTints()
    SocialWindowTabSearch.UpdateSelectedRow()
end

function SocialWindowTabSearch.UpdateSelectedRow()

    if( nil == SocialWindowTabSearchList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for rowIndex, dataIndex in ipairs( SocialWindowTabSearchList.PopulatorIndices ) 
    do    
        local selected = SocialWindowTabSearch.SelectedPlayerDataIndex == dataIndex
        
        local rowName   = "SocialWindowTabSearchListRow"..rowIndex

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
    end
    
end

function SocialWindowTabSearch.OnSearchUpdated()
    SocialWindowTabSearch.playerListNeedsUpdate = true
    UpdatePlayerList()

    -- Set sort button flags
    for index = 2, SocialWindowTabSearch.SORT_TYPE_MAX_NUMBER do
        local window = SocialWindowTabSearch.sortButtons[index]
        ButtonSetStayDownFlag( window, true )
    end
    
    SocialWindowTabSearch.UpdateSortButtons()
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function SocialWindowTabSearch.UpdateSortButtons()
    
    local type = SocialWindowTabSearch.display.type
    local order = SocialWindowTabSearch.display.order

    for index = 2, SocialWindowTabSearch.SORT_TYPE_MAX_NUMBER 
    do
        local window = SocialWindowTabSearch.sortButtons[index]
        ButtonSetPressedFlag( window, index == SocialWindowTabSearch.display.type )
    end
    
    -- Update the Arrows
    WindowSetShowing( "SocialWindowTabSearchSortButtonBarUpArrow", order == SocialWindowTabSearch.SORT_ORDER_UP )
    WindowSetShowing( "SocialWindowTabSearchSortButtonBarDownArrow", order == SocialWindowTabSearch.SORT_ORDER_DOWN )

    local window = SocialWindowTabSearch.sortButtons[type]

    if( order == SocialWindowTabSearch.SORT_ORDER_UP ) 
    then		
        WindowClearAnchors( "SocialWindowTabSearchSortButtonBarUpArrow" )
        WindowAddAnchor("SocialWindowTabSearchSortButtonBarUpArrow", "left", window, "left", 0, 0 )
    else
        WindowClearAnchors( "SocialWindowTabSearchSortButtonBarDownArrow" )
        WindowAddAnchor("SocialWindowTabSearchSortButtonBarDownArrow", "right", window, "right", 0, 0 )
    end

end

function SocialWindowTabSearch.OnMouseOverPlayerRow()

    local windowIndex	= WindowGetId (SystemData.ActiveWindow.name)
    local windowParent	= WindowGetParent (SystemData.ActiveWindow.name)
    local dataIndex     = ListBoxGetDataIndex(windowParent, windowIndex)

    -- Early out to avoid any mouse events for empty rows
    if (SocialWindowTabSearch.playerListData[dataIndex].name == L"") then
        return
    end

    local targetRowWindow = "SocialWindowTabSearchListRow"..windowIndex

end

function SocialWindowTabSearch.OnMouseOverPlayerRowEnd()
    -- Do nothing for now
end

function SocialWindowTabSearch.ResetEditBoxes()
    TextEditBoxSetText("SocialWindowTabSearchEditBoxPlayerName", L"")
    WindowAssignFocus("SocialWindowTabSearchEditBoxPlayerName", false)

    TextEditBoxSetText("SocialWindowTabSearchEditBoxGuildName", L"")
    WindowAssignFocus("SocialWindowTabSearchEditBoxGuildName", false)

    TextEditBoxSetText("SocialWindowTabSearchEditBoxCareerName", L"")
    WindowAssignFocus("SocialWindowTabSearchEditBoxCareerName", false)

    SocialWindowTabSearch.SelectedSearchDataIndex    = 0
    SocialWindowTabSearch.SelectedSearchName         = L""
end


-- Handles the Left Button click on a player row
function SocialWindowTabSearch.OnLButtonUpPlayerRow()
    
     -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowTabSearchList.PopulatorIndices[ rowNum ]
	
    SocialWindowTabSearch.UpdateSelectedPlayerData(dataIndex)
end

-- Handles the Right Button click on a player row
function SocialWindowTabSearch.OnRButtonUpPlayerRow()

     -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowTabSearchList.PopulatorIndices[ rowNum ]
	
    SocialWindowTabSearch.UpdateSelectedPlayerData(dataIndex)
    
    if( SocialWindowTabSearch.SelectedSearchName ~= L"" ) then
        PlayerMenuWindow.ShowMenu( SocialWindowTabSearch.SelectedSearchName, 0, true ) 
    end
end

-- Displays a tooltip with information on the type of sort being hovered over
function SocialWindowTabSearch.OnMouseOverSortButton()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, SocialWindowTabSearch.ColumnHeaders[windowIndex])
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="center", XOffset=0, YOffset=-32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

-- Button Callback for the Sort Buttons
function SocialWindowTabSearch.OnSortPlayerList()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    -- If we are already using this sort type, toggle the order.
    if( type == SocialWindowTabSearch.display.type ) then
        if( SocialWindowTabSearch.display.order == SocialWindowTabSearch.SORT_ORDER_UP ) then
            SocialWindowTabSearch.display.order = SocialWindowTabSearch.SORT_ORDER_DOWN
        else
            SocialWindowTabSearch.display.order = SocialWindowTabSearch.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        SocialWindowTabSearch.display.type = type
        SocialWindowTabSearch.display.order = SocialWindowTabSearch.SORT_ORDER_UP
    end

    SocialWindowTabSearch.playerListNeedsUpdate = true
    UpdatePlayerList()
    SocialWindowTabSearch.UpdateSortButtons()
end

function SocialWindowTabSearch.OnPressSearchToggleButton()
end

function SocialWindowTabSearch.OnPressSetSearchButton()
    SendSearchOptions(1, 2, L"My Notes")	
end

function SocialWindowTabSearch.OnPressSearchPlayerButton()
    local minRank = tonumber(SocialWindowTabSearchEditBoxMinRank.Text)
    local maxRank = tonumber(SocialWindowTabSearchEditBoxMaxRank.Text)

    if (minRank <= 0 or minRank > 40) then
        TextEditBoxSetText("SocialWindowTabSearchEditBoxMinRank", L"1")
        minRank = 1			-- If the textbox has no text in it, it returns 0. But the server only ignores -1 values.
    end

    if (maxRank <= 0 or maxRank > 40) then
        TextEditBoxSetText("SocialWindowTabSearchEditBoxMaxRank", L"40")
        maxRank = 40			-- If the textbox has no text in it, it returns 0. But the server only ignores -1 values.
    end

    if (maxRank < minRank) then
        TextEditBoxSetText("SocialWindowTabSearchEditBoxMaxRank", L""..minRank)
        maxRank = minRank
    end
    
    local includeAdvisorsOnly = ButtonGetPressedFlag( "SocialWindowTabSearchIncludeAdvisorsOnlyButton" )

    SendPlayerSearchRequest(SocialWindowTabSearchEditBoxPlayerName.Text, 
                            SocialWindowTabSearchEditBoxGuildName.Text,
                            SocialWindowTabSearchEditBoxCareerName.Text,
                            SocialWindowTabSearch.ZoneID,
                            minRank, maxRank,
                            includeAdvisorsOnly)
end

function SocialWindowTabSearch.UpdateZoneList()
    -- Clear ComboBox before populating to avoid duplicates
    ComboBoxClearMenuItems("SocialWindowTabSearchComboBoxZoneNames")

    -- add the all zones option
    ComboBoxAddMenuItem("SocialWindowTabSearchComboBoxZoneNames", GetString( StringTables.Default.TEXT_ALL_ZONES ))

    local tempZoneNameRef = {} -- we will use this to make sure we don't have duplicate names in the list
    -- start the count at 2 so that it will skip over the all zones option
    local iCount = 2

    local zoneIDs = GetZoneIDList()
    -- loop over all the zone names, some are blank, some are "Dangerous Territory"
    for index, zoneID in ipairs( zoneIDs )
    do
        -- get the zone name for this zoneID
        zoneName = GetZoneName(zoneID)
        if tempZoneNameRef[zoneName] == nil
        then
            tempZoneNameRef[zoneName] = iCount
            -- we need to sort this so we will add it to the list
            SocialWindowTabSearch.SelectedSearchZoneList[iCount] = {}
            SocialWindowTabSearch.SelectedSearchZoneList[iCount].index = {}
            table.insert(SocialWindowTabSearch.SelectedSearchZoneList[iCount].index, zoneID)
            SocialWindowTabSearch.SelectedSearchZoneList[iCount].name = zoneName
            -- increment the count
            iCount = iCount + 1
        else
            table.insert(SocialWindowTabSearch.SelectedSearchZoneList[tempZoneNameRef[zoneName]].index, zoneID)
        end
    end

    table.sort( SocialWindowTabSearch.SelectedSearchZoneList, DataUtils.AlphabetizeByNames )
    -- loop over the sorted zone list
    for index, zoneData in pairs( SocialWindowTabSearch.SelectedSearchZoneList )
    do
        -- and put the name into the combo box
        ComboBoxAddMenuItem("SocialWindowTabSearchComboBoxZoneNames", zoneData.name)
    end

    ComboBoxSetSelectedMenuItem("SocialWindowTabSearchComboBoxZoneNames", 1)
end

function SocialWindowTabSearch.OnFilterSelChanged( curSel )
    -- clear out the array
    SocialWindowTabSearch.ZoneID = {}
    -- if we are on the first selection or for some reason we are past the zone list index we will search all the zones
    if (((curSel - 1) == 0) or (curSel > #SocialWindowTabSearch.SelectedSearchZoneList))
    then
        -- this is set to -1 when all the zones should be searched
        SocialWindowTabSearch.ZoneID[1] = -1
    -- otherwise we will only search the zone selected
    else
        for row = 1, #SocialWindowTabSearch.SelectedSearchZoneList[curSel].index
        do
            SocialWindowTabSearch.ZoneID[row] = SocialWindowTabSearch.SelectedSearchZoneList[curSel].index[row]
        end
    end
end
