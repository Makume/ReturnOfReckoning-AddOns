----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowTabIgnore = {}
SocialWindowTabIgnore.playerListData = {}
SocialWindowTabIgnore.playerListOrder = {}

-- Sorting Parameters for the Player List
SocialWindowTabIgnore.SORT_TYPE_NAME	 		= 1
SocialWindowTabIgnore.SORT_TYPE_RANK			= 2
SocialWindowTabIgnore.SORT_TYPE_CAREER	        = 3
SocialWindowTabIgnore.SORT_TYPE_ONLINE	        = 4
SocialWindowTabIgnore.SORT_TYPE_MAX_NUMBER      = 4

SocialWindowTabIgnore.FILTER_MEMBERS_ALL	    = 1
SocialWindowTabIgnore.FILTER_MAX_NUMBER		    = 1

SocialWindowTabIgnore.SORT_ORDER_UP	            = 1
SocialWindowTabIgnore.SORT_ORDER_DOWN	        = 2

SocialWindowTabIgnore.sortButtons = {  "SocialWindowTabIgnoreSortButtonBarNameButton",		-- Order List Header 
                                    "SocialWindowTabIgnoreSortButtonBarRankButton", 
                                    "SocialWindowTabIgnoreSortButtonBarCareerButton", 
                                    "SocialWindowTabIgnoreSortButtonBarOnlineButton" }
-- Make sure these match the ID numbers in the XML definition 
--    For example,  <Button name="$parentNameButton" inherits="SocialHeaderButton" id="1"> 
SocialWindowTabIgnore.sortKeys = {"name",
                               "rankString", 
                               "career", 
                               "onlineString"  }

SocialWindowTabIgnore.sortColumns = { "Name", 
                                   "Rank", 
                                   "Career", 
                                   "Online"  }
SocialWindowTabIgnore.display = { type=SocialWindowTabIgnore.SORT_TYPE_NAME, 
                                order=SocialWindowTabIgnore.SORT_ORDER_UP, 
                                filter=SocialWindowTabIgnore.FILTER_MEMBERS_ALL }

SocialWindowTabIgnore.ColumnHeaders = { 
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) }

SocialWindowTabIgnore.SelectedPlayerDataIndex    = 0
SocialWindowTabIgnore.SelectedIgnoreName        = L""

local function InitPlayerListData()
    SocialWindowTabIgnore.playerListData = {}
        
    local IgnoreListData = GetIgnoreList()
    
     if ( IgnoreListData ~= nil ) then
        for key, value in ipairs( IgnoreListData ) 
        do
            
            SocialWindowTabIgnore.playerListData[key] = {}
            SocialWindowTabIgnore.playerListData[key].name = value.name
            SocialWindowTabIgnore.playerListData[key].career = value.careerName
            if (value.careerName == L"") then
                SocialWindowTabIgnore.playerListData[key].rankString = L""
            else
                SocialWindowTabIgnore.playerListData[key].rankString = L""..value.rank
                -- if the person is offline the Rank is invalid, so don't display anything in the list
            end
            if ( value.zoneID ~= 0 ) then
                SocialWindowTabIgnore.playerListData[key].onlineString = GetZoneName( value.zoneID )
            else
                SocialWindowTabIgnore.playerListData[key].onlineString = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
            end
        end
    end
    
end

-- This function is used as the comparison function for 
-- table.sort() on the player display order
-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local player1 = SocialWindowTabIgnore.playerListData[index1]
    local player2 = SocialWindowTabIgnore.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end

    local type = SocialWindowTabIgnore.display.type
    local order = SocialWindowTabIgnore.display.order
    
    local compareResult
-- Check for sorting by all the the string fields first
    
    -- Sorting by Name
    if( type == SocialWindowTabIgnore.SORT_TYPE_NAME )then
        if( order == SocialWindowTabIgnore.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            return ( WStringsCompare(player1.name, player2.name) > 0 )
        end
    end
    
    --Sorting By Career (And if they match, then sort alphabetically)
    if( type == SocialWindowTabIgnore.SORT_TYPE_CAREER ) then
        compareResult = WStringsCompare(player1.career, player2.career)
        
        if (compareResult == 0) then
            compareResult = WStringsCompare(player1.name, player2.name)
        end
        
        if( order == SocialWindowTabIgnore.SORT_ORDER_UP ) then
            return ( compareResult < 0 )
        else
            return ( compareResult > 0 )
        end		
    end

    -- Sorting By Online (And if they match, then sort alphabetically)
    if( type == SocialWindowTabIgnore.SORT_TYPE_ONLINE ) then
        compareResult = WStringsCompare(player1.onlineString, player2.onlineString)
        if (compareResult == 0) then
            compareResult = WStringsCompare(player1.name, player2.name)
        end	
        
        if( order == SocialWindowTabIgnore.SORT_ORDER_UP ) then
            return ( compareResult < 0)
        else
            return ( compareResult > 0)
        end
    end

-- Otherwise assume we're sorting by a number, not a string.
    -- Sorting By A Numerical Value - When tied, sort by name
    local key = SocialWindowTabIgnore.sortKeys[type]
    if( tonumber(player1[key]) == tonumber(player2[key]) ) then
        compareResult = WStringsCompare(player1.name, player2.name)
    else		
        if ( tonumber(player1[key]) < tonumber(player2[key]) ) then
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
    table.sort( SocialWindowTabIgnore.playerListOrder, ComparePlayers )
end

local function FilterPlayerList()	
    
    local filter = SocialWindowTabIgnore.display.filter

    SocialWindowTabIgnore.playerListOrder = {}
    for dataIndex, data in ipairs( SocialWindowTabIgnore.playerListData ) do
        table.insert(SocialWindowTabIgnore.playerListOrder, dataIndex)
    end
end

local function UpdatePlayerList()
    -- Filter, Sort, and Update
    InitPlayerListData()
    SocialWindowTabIgnore.display.filter = SocialWindowTabIgnore.FILTER_MEMBERS_ALL
    FilterPlayerList()
    SortPlayerList()
    ListBoxSetDisplayOrder( "SocialWindowTabIgnoreList", SocialWindowTabIgnore.playerListOrder )
end

-- OnInitialize Handler
function SocialWindowTabIgnore.Initialize()

    -- Set all the header labels
    LabelSetText( "SocialWindowTabIgnorePlayerSearchLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_PLAYER_HEADER))
    
    ButtonSetText( "SocialWindowTabIgnoreCommandAddIgnoreButton",  GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_ADDIGNORE) )
    ButtonSetText( "SocialWindowTabIgnoreCommandRemoveIgnoreButton",  GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_REMOVEIGNORE) )
    ButtonSetText( "SocialWindowTabIgnoreSortButtonBarNameButton",  GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME) )
    ButtonSetText( "SocialWindowTabIgnoreSortButtonBarRankButton",	 GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK) )
    ButtonSetText( "SocialWindowTabIgnoreSortButtonBarCareerButton", GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER) )
    ButtonSetText( "SocialWindowTabIgnoreSortButtonBarOnlineButton", GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) )
    
    WindowSetTintColor("SocialWindowTabIgnoreSearchBackground", 0, 0, 0 )
        
    -- Register all the Events for this Tab
    WindowRegisterEventHandler( "SocialWindowTabIgnore", SystemData.Events.SOCIAL_IGNORE_UPDATED, "SocialWindowTabIgnore.OnIgnoreUpdated")
    
    SocialWindowTabIgnore.SetListRowTints()
    SocialWindowTabIgnore.OnIgnoreUpdated()
    SocialWindowTabIgnore.UpdateSortButtons() 
end

function SocialWindowTabIgnore.Shutdown()

end

function SocialWindowTabIgnore.OnClose()
    SocialWindowTabIgnore.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabIgnore.OnKeyEscape()
    SocialWindowTabIgnore.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabIgnore.UpdateSelectedPlayerData( dataIndex )
    -- Set the label values
    if (dataIndex ~= nil) then
        SocialWindowTabIgnore.SelectedPlayerDataIndex = dataIndex
    else
        SocialWindowTabIgnore.SelectedPlayerDataIndex = 0
        SocialWindowTabIgnore.SelectedIgnoreName = L""
    end
    
    SocialWindowTabIgnore.UpdateSelectedRow()
end

function SocialWindowTabIgnore.OnIgnoreUpdated()

    SocialWindowTabIgnore.playerListNeedsUpdate = true
    UpdatePlayerList()

    -- Set sort button flags
    for index = 2, SocialWindowTabIgnore.SORT_TYPE_MAX_NUMBER do
        local window = SocialWindowTabIgnore.sortButtons[index]
        ButtonSetStayDownFlag( window, true )
    end
    
    SocialWindowTabIgnore.UpdateSortButtons()
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function SocialWindowTabIgnore.UpdateSortButtons()
    
    local type = SocialWindowTabIgnore.display.type
    local order = SocialWindowTabIgnore.display.order

    for index = 2, SocialWindowTabIgnore.SORT_TYPE_MAX_NUMBER do
        local window = SocialWindowTabIgnore.sortButtons[index]
        ButtonSetPressedFlag( window, index == SocialWindowTabIgnore.display.type )
    end
    
    -- Update the Arrows
    WindowSetShowing( "SocialWindowTabIgnoreSortButtonBarUpArrow", order == SocialWindowTabIgnore.SORT_ORDER_UP )
    WindowSetShowing( "SocialWindowTabIgnoreSortButtonBarDownArrow", order == SocialWindowTabIgnore.SORT_ORDER_DOWN )

    local window = SocialWindowTabIgnore.sortButtons[type]

    if( order == SocialWindowTabIgnore.SORT_ORDER_UP ) then		
        WindowClearAnchors( "SocialWindowTabIgnoreSortButtonBarUpArrow" )
        WindowAddAnchor("SocialWindowTabIgnoreSortButtonBarUpArrow", "left", window, "left", 0, 0 )
    else
        WindowClearAnchors( "SocialWindowTabIgnoreSortButtonBarDownArrow" )
        WindowAddAnchor("SocialWindowTabIgnoreSortButtonBarDownArrow", "right", window, "right", 0, 0 )
    end
end


function SocialWindowTabIgnore.OnMouseOverPlayerRow()
    -- Do nothing for now
end

function SocialWindowTabIgnore.OnMouseOverPlayerRowEnd()
    -- Do nothing for now
end

function SocialWindowTabIgnore.ResetEditBoxes()
    TextEditBoxSetText("SocialWindowTabIgnorePlayerSearchEditBox", L"")	-- Clear the Text from the Player Search Edit Box
    WindowAssignFocus("SocialWindowTabIgnorePlayerSearchEditBox", false)
    SocialWindowTabIgnore.SelectedPlayerDataIndex    = 0
    SocialWindowTabIgnore.SelectedIgnoreName        = L""
end

---------------------------------------------------------------------------
-- Sorting Functions
---------------------------------------------------------------------------

-- Displays a tooltip with information on the type of sort being hovered over
function SocialWindowTabIgnore.OnMouseOverSortButton()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, SocialWindowTabIgnore.ColumnHeaders[windowIndex])
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="center", XOffset=0, YOffset=-32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function SocialWindowTabIgnore.SetListRowTints()
    for row = 1, SocialWindowTabIgnoreList.numVisibleRows do
        local row_mod = math.mod(row, 2)
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        local targetRowWindow = "SocialWindowTabIgnoreListRow"..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
end

---------------------------------------------------------------------------
-- List Box Functions
---------------------------------------------------------------------------


-- Callback from the <List> that updates a single row.
function SocialWindowTabIgnore.UpdatePlayerRow()
    
    if (SocialWindowTabIgnoreList.PopulatorIndices == nil) 
    then
        return
    end

    for rowIndex, dataIndex in ipairs (SocialWindowTabIgnoreList.PopulatorIndices) 
    do
        local rowName = "SocialWindowTabIgnoreListRow"..rowIndex

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
    
    SocialWindowTabIgnore.SetListRowTints()
    SocialWindowTabIgnore.UpdateSelectedRow()
end


function SocialWindowTabIgnore.UpdateSelectedRow()

    if( nil == SocialWindowTabIgnoreList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for rowIndex, dataIndex in ipairs( SocialWindowTabIgnoreList.PopulatorIndices ) 
    do    
        local selected = SocialWindowTabIgnore.SelectedPlayerDataIndex == dataIndex
        
        local rowName   = "SocialWindowTabIgnoreListRow"..rowIndex

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
    end
    
end

-- Handles the Left Button click on a player row
function SocialWindowTabIgnore.OnLButtonUpPlayerRow()
    
    -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowTabIgnoreList.PopulatorIndices[ rowNum ]
	
    SocialWindowTabIgnore.UpdateSelectedPlayerData(dataIndex)
end

-- Button Callback for the Sort Buttons
function SocialWindowTabIgnore.OnSortPlayerList()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    -- If we are already using this sort type, toggle the order.
    if( type == SocialWindowTabIgnore.display.type ) then
        if( SocialWindowTabIgnore.display.order == SocialWindowTabIgnore.SORT_ORDER_UP ) then
            SocialWindowTabIgnore.display.order = SocialWindowTabIgnore.SORT_ORDER_DOWN
        else
            SocialWindowTabIgnore.display.order = SocialWindowTabIgnore.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        SocialWindowTabIgnore.display.type = type
        SocialWindowTabIgnore.display.order = SocialWindowTabIgnore.SORT_ORDER_UP
    end

    SocialWindowTabIgnore.playerListNeedsUpdate = true
    UpdatePlayerList()
    SocialWindowTabIgnore.UpdateSortButtons()
end

function SocialWindowTabIgnore.AddIgnore()
    if (SocialWindowTabIgnorePlayerSearchEditBox.Text == nil or SocialWindowTabIgnorePlayerSearchEditBox.Text == L"") then
        return
    end
    
    SendChatText( L"/ignore "..SocialWindowTabIgnorePlayerSearchEditBox.Text, L"" )
    SocialWindowTabIgnore.ResetEditBoxes()
end

function SocialWindowTabIgnore.RemoveIgnore()
    if (SocialWindowTabIgnore.SelectedPlayerDataIndex == 0) then
        return
    end
     
    -- Need to ensure the player name does not have a gender tag appended to it before sending it off to the server  
    local selectPlayerName = wstring.gsub( SocialWindowTabIgnore.playerListData[SocialWindowTabIgnore.SelectedPlayerDataIndex].name, L"(^.)", L"" )
    
    SendChatText( L"/ignore "..selectPlayerName, L"" )
    SocialWindowTabIgnore.ResetEditBoxes()
end

---------------------------------------
-- Util Functions
---------------------------------------
function SocialWindowTabIgnore.IsPlayerIgnored( playerName )

    for _, ignoreData in ipairs( SocialWindowTabIgnore.playerListData )
    do
        if( WStringsCompareIgnoreGrammer( playerName, ignoreData.name ) == 0 )
        then
            return true
        end
    end

    return false
end