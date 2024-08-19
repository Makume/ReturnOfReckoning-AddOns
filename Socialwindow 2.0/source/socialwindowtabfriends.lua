----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowTabFriends = {}
SocialWindowTabFriends.playerListData = {} -- NOTE: Not guaranteed to be up-to-date. Use SocialWindowTabFriends.GetFriendsDataTable() instead to access.
SocialWindowTabFriends.playerListOrder = {}
SocialWindowTabFriends.lastAdded = nil

-- Sorting Parameters for the Player List
SocialWindowTabFriends.SORT_TYPE_NAME	 		= 1
SocialWindowTabFriends.SORT_TYPE_DESCRIPTION    = 2
SocialWindowTabFriends.SORT_TYPE_RANK			= 3
SocialWindowTabFriends.SORT_TYPE_CAREER	        = 4
SocialWindowTabFriends.SORT_TYPE_TYPE	        = 5
SocialWindowTabFriends.SORT_TYPE_ONLINE         = 6
SocialWindowTabFriends.SORT_TYPE_MAX_NUMBER     = 5

SocialWindowTabFriends.SORT_ORDER_UP	        = 1
SocialWindowTabFriends.SORT_ORDER_DOWN	        = 2

SocialWindowTabFriends.sortButtons = {  "SocialWindowTabFriendsSortButtonBarNameButton",
                                    "SocialWindowTabFriendsSortButtonBarDescriptionButton",		-- Order List Header 
                                    "SocialWindowTabFriendsSortButtonBarRankButton", 
                                    "SocialWindowTabFriendsSortButtonBarCareerButton",
                                    "SocialWindowTabFriendsSortButtonBarTypeButton",  
                                    "SocialWindowTabFriendsSortButtonBarOnlineButton" }
-- Make sure these match the ID numbers in the XML definition 
--    For example,  <Button name="$parentNameButton" inherits="SocialHeaderButton" id="1"> 
SocialWindowTabFriends.sortKeys = {"name",
                                "description",
                               "rankString", 
                               "career", 
                               "type",
                               "onlineString"  }

SocialWindowTabFriends.sortColumns = { "Name",
                                    "Description", 
                                   "Rank", 
                                   "Career",
                                   "Type", 
                                   "Online"  }
                                   
SocialWindowTabFriends.display = { type=SocialWindowTabFriends.SORT_TYPE_ONLINE, 
                                  order=SocialWindowTabFriends.SORT_ORDER_UP }
                                
SocialWindowTabFriends.ColumnHeaders = {   
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME),
                                L"Discription",
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK),
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER),
                                L"Type",
                                GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) }
                                      
SocialWindowTabFriends.SelectedPlayerDataIndex    = 0
SocialWindowTabFriends.SelectedFriendsName        = L""
SocialWindowTabFriends.NumberOfFriends			  = 0

-- the minimum suggest score a player needs to have to be presented as a friend suggestion
SocialWindowTabFriends.SUGGEST_SCORE_THRESHOLD = 15

-- for filtering / sorting
SocialWindowTabFriends.FRIENDTYPE = {}
SocialWindowTabFriends.FRIENDTYPE.FRIENDED = 1
SocialWindowTabFriends.FRIENDTYPE.SUGGESTED = 2
SocialWindowTabFriends.FRIENDTYPE.COUNT = 2

local FRIENDTYPE = SocialWindowTabFriends.FRIENDTYPE

SocialWindowTabFriends.FILTERTYPE = {}
SocialWindowTabFriends.FILTERTYPE.ONLINE = 1
SocialWindowTabFriends.FILTERTYPE.OFFLINE = 2
SocialWindowTabFriends.FILTERTYPE.SUGGESTED = 3

local FILTERTYPE = SocialWindowTabFriends.FILTERTYPE

local lastSelectedSuggestedFriendName = nil

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
SocialWindowTabFriends.Settings = {}
-- Global Variables

SocialWindowTabFriends.EmptyAdvancedFriendsList = {
    destro = {
        accountFriends = {},
        accountFriendsDel = {},
        localFriends = {}
    },
    order = {
        accountFriends = {},
        accountFriendsDel = {},
        localFriends = {}
    }    
}

SocialWindowTabFriends.Settings.filters =
{
    [ FILTERTYPE.ONLINE ] = { enabled=true  },
    [ FILTERTYPE.OFFLINE ] = { enabled=true  },
    [ FILTERTYPE.SUGGESTED ] = { enabled=true  },
}

local dataDirty = true
local uiDirty = true

local function InitPlayerListData()
    dataDirty = false
    SocialWindowTabFriends.playerListData = {}

    local FriendsListData = GetFriendsList()
    UpdateFriendsLists()
    
    SocialWindowTabFriends.NumberOfFriends = 0

     if ( FriendsListData ~= nil ) then
        for key, value in ipairs( FriendsListData ) do
            -- These should match the data that was retrived from war_interface::LuaGetFriendsList
            SocialWindowTabFriends.playerListData[key] = {}
			SocialWindowTabFriends.NumberOfFriends = SocialWindowTabFriends.NumberOfFriends +1
            SocialWindowTabFriends.playerListData[key].name = value.name
            SocialWindowTabFriends.playerListData[key].friendType = FRIENDTYPE.FRIENDED
            SocialWindowTabFriends.playerListData[key].career = value.careerName
            if (value.careerName == L"") then
                SocialWindowTabFriends.playerListData[key].rankString = L""
            else
                SocialWindowTabFriends.playerListData[key].rankString = L""..value.rank
                -- if the person is offline the Rank is invalid, so don't display anything in the list
            end
            if ( value.zoneID ~= 0 ) then
                SocialWindowTabFriends.playerListData[key].onlineString = GetZoneName( value.zoneID )
            else
                SocialWindowTabFriends.playerListData[key].onlineString = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
            end
            SocialWindowTabFriends.playerListData[key].isOnline = ( value.zoneID ~= 0 )
            if (value.guildName == nil) then
                SocialWindowTabFriends.playerListData[key].guildName = L""
            else
                SocialWindowTabFriends.playerListData[key].guildName = value.guildName
            end
            
            if FriendSuggester.HasDataForPlayer( value.name )
            then
                -- friend must have recently been added who was a suggestion before
                FriendSuggester.OnFriendAdded( value.name )
            end

            -- Add to local friends list
            AddLocalFriendInit( value.name )

            local listFriend = GetFriend( value.name )
            if listFriend == nil or listFriend.description == L"" then
                SocialWindowTabFriends.playerListData[key].description = L""
            else
                SocialWindowTabFriends.playerListData[key].description = listFriend.description
            end

            if GetLocalList()[value.name] ~= nil then
                SocialWindowTabFriends.playerListData[key].type = L"L"
            else
                SocialWindowTabFriends.playerListData[key].type = L"A"
            end           
        end
    end

    --table.insert( SocialWindowTabFriends.playerListData, {name = L"Test", friendType=FRIENDTYPE.FRIENDED, career=L"", rankString=L"", onlineString=L"", isOnline=true, guildName=L""})

    AddGlobalFriendsToChar( FriendsListData )
    
end
-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local player1 = SocialWindowTabFriends.playerListData[index1]
    local player2 = SocialWindowTabFriends.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end
    
    local type = SocialWindowTabFriends.display.type
    local order = SocialWindowTabFriends.display.order
    
    local compareResult
-- Check for sorting by all the the string fields first
    
    -- Sorting by Name
    if( type == SocialWindowTabFriends.SORT_TYPE_NAME )then
        if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.name, player2.name) < 0 )
        else
            return ( WStringsCompare(player1.name, player2.name) > 0 )
        end
    end

     -- Sorting by Description
    if( type == SocialWindowTabFriends.SORT_TYPE_DESCRIPTION )then
        if player1.description == nil then
            player1.description = L""
        end

        if player2.description == nil then
            player2.description = L""
        end

        if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.description, player2.description) < 0 )
        else
            return ( WStringsCompare(player1.description, player2.description) > 0 )
        end
    end
    
    --Sorting By Career (And if they match, then sort alphabetically)
    if( type == SocialWindowTabFriends.SORT_TYPE_CAREER ) then
        compareResult = WStringsCompare(player1.career, player2.career)
        
        if (compareResult == 0) then
            if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
                compareResult = WStringsCompare(player1.name, player2.name)
            end
        end
        
        if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            return ( compareResult < 0 )
        else
            return ( compareResult > 0 )
        end		
    end

     -- Sorting by Type
    if( type == SocialWindowTabFriends.SORT_TYPE_TYPE )then
         if player1.type == nil then
            player1.type = L""
        end

        if player2.type == nil then
            player2.type = L""
        end

        if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            return ( WStringsCompare(player1.type, player2.type) < 0 )
        else
            return ( WStringsCompare(player1.type, player2.type) > 0 )
        end
    end

    -- Sorting By Online (And if they match, then sort alphabetically)
    if( type == SocialWindowTabFriends.SORT_TYPE_ONLINE ) then
        if player1.friendType ~= player2.friendType
        then
            return player1.friendType < player2.friendType
        elseif player1.friendType == FRIENDTYPE.SUGGESTED
        then
            if player1.suggestScore ~= player2.suggestScore
            then
                return player1.suggestScore > player2.suggestScore
            end
        end
        if player1.isOnline and player2.isOnline
        then
            compareResult = WStringsCompare(player1.onlineString, player2.onlineString)
        elseif (player1.isOnline or player2.isOnline) -- do not sort by the text "Offline" as if it were a location
        then
            if player1.isOnline
            then
                compareResult = -1
            else
                compareResult = 1
            end
        else -- both offline
            compareResult = 0
        end
        
        if (compareResult == 0) -- sorts by name when both are offline, or both in the same location
        then
            compareResult = WStringsCompare(player1.name, player2.name)
        end
        
        if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            return ( compareResult < 0)
        else
            return ( compareResult > 0)
        end
    end

    -- Otherwise assume we're sorting by a number, not a string.
    -- Sorting By A Numerical Value - When tied, sort by name
    local key = SocialWindowTabFriends.sortKeys[type]
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

local function MergeSuggestedFriends()
    local currentId = #SocialWindowTabFriends.playerListData + 1
    
    for name, friendData in pairs(FriendSuggester.Data)
    do
        if friendData.value < SocialWindowTabFriends.SUGGEST_SCORE_THRESHOLD 
        then
            continue
        end
        SocialWindowTabFriends.playerListData[currentId] = {}
        SocialWindowTabFriends.playerListData[currentId].name = name
        SocialWindowTabFriends.playerListData[currentId].friendType = FRIENDTYPE.SUGGESTED
        SocialWindowTabFriends.playerListData[currentId].suggestScore = friendData.value
        
        -- these fields unavailable for suggested friends
        SocialWindowTabFriends.playerListData[currentId].career = L""
        SocialWindowTabFriends.playerListData[currentId].rankString = L""
        SocialWindowTabFriends.playerListData[currentId].onlineString = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_SUGGESTED)
        SocialWindowTabFriends.playerListData[currentId].guildName = L""
        
        currentId = currentId + 1
    end
    
end

local function SortPlayerList()	
    table.sort( SocialWindowTabFriends.playerListOrder, ComparePlayers )
end

local function FilterPlayerList()	
    SocialWindowTabFriends.playerListOrder = {}
    for dataIndex, data in ipairs( SocialWindowTabFriends.playerListData ) 
    do
        if (data.friendType == FRIENDTYPE.SUGGESTED) and (not SocialWindowTabFriends.Settings.filters[FILTERTYPE.SUGGESTED].enabled)
        then
            continue
        end
        if (data.isOnline == false) and (not SocialWindowTabFriends.Settings.filters[FILTERTYPE.OFFLINE].enabled)
        then
            continue
        elseif (data.isOnline == true) and (not SocialWindowTabFriends.Settings.filters[FILTERTYPE.ONLINE].enabled)
        then
            continue
        end
        table.insert(SocialWindowTabFriends.playerListOrder, dataIndex)
    end
end

local function UpdatePlayerList()
    -- Filter, Sort, and Update
    InitPlayerListData()
    MergeSuggestedFriends()
    FilterPlayerList()
    SortPlayerList()

    ListBoxSetDisplayOrder( "SocialWindowTabFriendsList", SocialWindowTabFriends.playerListOrder )
end

-- OnInitialize Handler
function SocialWindowTabFriends.Initialize()
    RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "SocialWindowTabFriends.OnChatLogUpdated") -- runs the function when Chatlog gets a new text


    -- Set all the header labels    
    LabelSetText( "SocialWindowTabFriendsPlayerSearchLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SEARCH_EDITBOX_PLAYER_HEADER) )
    ButtonSetText( "SocialWindowTabFriendsCommandAddFriendButton",  GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_ADDFRIEND) )
    ButtonSetText( "SocialWindowTabFriendsCommandRemoveFriendButton",  GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_REMOVEFRIEND) )
    ButtonSetText( "SocialWindowTabFriendsCommandSwitchFriendButton",  L"Switch Type" )
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarNameButton",  GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_NAME) )
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarDescriptionButton", L"Description")
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarRankButton",	GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_RANK) )
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarCareerButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_CAREER) )
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarTypeButton", L"Type")
    ButtonSetText( "SocialWindowTabFriendsSortButtonBarOnlineButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_SORT_BUTTON_LOCATION) )
    LabelSetText( "SocialWindowTabFriendsFilterLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_FILTERS) )
    WindowSetId( "SocialWindowTabFriendsFilterMenuButton", StringTables.Social.TOOLTIP_BUDDY_LIST_FILTER_MENU_BUTTON )
    
    WindowRegisterEventHandler( "SocialWindow", SystemData.Events.SOCIAL_FRIENDS_UPDATED, "SocialWindowTabFriends.OnFriendsUpdated")
    
    CreateWindow( "AddFriendDescription", false )
    LabelSetText( "AddFriendDescriptionLabel", L"Set Discription")
    ButtonSetText( "AddFriendDescriptionOKButton", L"Accept")
    ButtonSetText( "AddFriendDescriptionCancelButton", L"Cancel")


    if not SocialWindowTabFriends.AddvancedFriends then
        SocialWindowTabFriends.AddvancedFriends = SocialWindowTabFriends.EmptyAdvancedFriendsList
    end

    if FriendSuggester
    then
        FriendSuggester.RegisterCallback( SocialWindowTabFriends.OnSuggestedFriendsUpdated )
    end
    
    WindowSetTintColor("SocialWindowTabFriendsSearchBackground", 0, 0, 0 )
    
    SocialWindowTabFriends.UpdateUIOnDirty()
    SocialWindowTabFriends.UpdateSortButtons()
end

function SocialWindowTabFriends.Shutdown()
    UnregisterEventHandler(TextLogGetUpdateEventId("Chat"), "SocialWindowTabFriends.OnChatLogUpdated")
end

function SocialWindowTabFriends.OnClose()
    SocialWindowTabFriends.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabFriends.OnKeyEscape()
    SocialWindowTabFriends.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabFriends.OnShown()
    if uiDirty
    then
        SocialWindowTabFriends.UpdateUIOnDirty()
    end
end

function SocialWindowTabFriends.OnHidden()
    WindowSetShowing( "SocialWindowTabFriendsFilterMenu", false)
end

function SocialWindowTabFriends.UpdateSelectedPlayerData( dataIndex )

    -- Set the label values
    if (dataIndex ~= nil and dataIndex ~= 0) 
    then
        SocialWindowTabFriends.SelectedPlayerDataIndex = dataIndex
        SocialWindowTabFriends.SelectedFriendsName = SocialWindowTabFriends.playerListData[dataIndex].name
    else
        SocialWindowTabFriends.SelectedPlayerDataIndex = 0
        SocialWindowTabFriends.SelectedFriendsName = L""
    end
   
    SocialWindowTabFriends.UpdateSelectedRow()
end

function SocialWindowTabFriends.SetListRowTints(list, windowName, bAlternate)
	local targetRowWindow = L""

    for row = 1, list.numVisibleRows 
    do
        local row_mod = 0
        if bAlternate
        then
            row_mod = math.mod(row, 2)
        end
        
        color = DataUtils.GetAlternatingRowColor( row_mod )
        
        targetRowWindow = windowName..row
        WindowSetTintColor(targetRowWindow.."Background", color.r, color.g, color.b )
        WindowSetAlpha(targetRowWindow.."Background", color.a )
    end
end


-- Callback from the <List> that updates a single row.
function SocialWindowTabFriends.UpdatePlayerRow()

    if (SocialWindowTabFriendsList.PopulatorIndices == nil) 
    then
        return
    end

    for rowIndex, dataIndex in ipairs (SocialWindowTabFriendsList.PopulatorIndices) 
    do
        local rowName = "SocialWindowTabFriendsListRow"..rowIndex

        -- Change colors based on if the guild member is selected/unselected, or offline            
        local labelColor = DefaultColor.GREEN           -- Default Online Memebers are green            
        
        if ( not SocialWindowTabFriends.playerListData[dataIndex].isOnline ) 
        then
            labelColor = DefaultColor.MEDIUM_LIGHT_GRAY		-- Offline Members are grey
        end                       
        if SocialWindowTabFriends.playerListData[dataIndex].friendType == FRIENDTYPE.SUGGESTED
        then
            labelColor = DefaultColor.TEAL
        end
        
        DefaultColor.LabelSetTextColor( rowName.."Name", labelColor)
        DefaultColor.LabelSetTextColor( rowName.."Description", labelColor)
        DefaultColor.LabelSetTextColor( rowName.."Rank", labelColor)
        DefaultColor.LabelSetTextColor( rowName.."Career", labelColor)
        DefaultColor.LabelSetTextColor( rowName.."Online", labelColor)

        if GetLocalList()[SocialWindowTabFriends.playerListData[dataIndex].name] ~= nil then
            DefaultColor.LabelSetTextColor( rowName.."Type", DefaultColor.MEDIUM_LIGHT_GRAY) 
        else
            DefaultColor.LabelSetTextColor( rowName.."Type", DefaultColor.GREEN )
        end
            
    end
    
    SocialWindowTabFriends.SetListRowTints(SocialWindowTabFriendsList, "SocialWindowTabFriendsListRow", true)
    SocialWindowTabFriends.UpdateSelectedRow()
end

function SocialWindowTabFriends.UpdateSelectedRow()

    if( nil == SocialWindowTabFriendsList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for rowIndex, dataIndex in ipairs( SocialWindowTabFriendsList.PopulatorIndices ) 
    do    
        local selected = SocialWindowTabFriends.SelectedPlayerDataIndex == dataIndex
        
        local rowName   = "SocialWindowTabFriendsListRow"..rowIndex

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
        
        -- if they clicked a suggested friend, populate the Add Friend edit box with the name
        if selected
        then
            if SocialWindowTabFriends.playerListData[dataIndex].friendType == FRIENDTYPE.SUGGESTED
            then
                TextEditBoxSetText("SocialWindowTabFriendsPlayerSearchEditBox", SocialWindowTabFriends.playerListData[dataIndex].name)
                lastSelectedSuggestedFriendName = SocialWindowTabFriends.playerListData[dataIndex].name
            elseif TextEditBoxGetText("SocialWindowTabFriendsPlayerSearchEditBox") == lastSelectedSuggestedFriendName
            then
                TextEditBoxSetText("SocialWindowTabFriendsPlayerSearchEditBox", L"")
                lastSelectedSuggestedFriendName = nil
            end
        end
    end
    
end

function SocialWindowTabFriends.OnFriendsUpdated()
    dataDirty = true
    uiDirty = true
    
    if WindowGetShowing("SocialWindowTabFriends")
    then
        SocialWindowTabFriends.UpdateUIOnDirty()
    end
end

function SocialWindowTabFriends.OnSuggestedFriendsUpdated()
    SocialWindowTabFriends.OnFriendsUpdated() -- do the same behavior for now
end

function SocialWindowTabFriends.UpdateUIOnDirty()
    uiDirty = false
    UpdatePlayerList()

    -- Set sort button flags
    for index = 2, SocialWindowTabFriends.SORT_TYPE_MAX_NUMBER do
        local window = SocialWindowTabFriends.sortButtons[index]
        ButtonSetStayDownFlag( window, true )
    end
    
    SocialWindowTabFriends.UpdateSortButtons()
end

function SocialWindowTabFriends.GetFriendsDataTable()
    if dataDirty
    then
        InitPlayerListData()
    end
    return SocialWindowTabFriends.playerListData
end

-- Displays the clicked sort button as pressed down and positions an arrow above it
function SocialWindowTabFriends.UpdateSortButtons()
    
    local type = SocialWindowTabFriends.display.type
    local order = SocialWindowTabFriends.display.order

    for index = 2, SocialWindowTabFriends.SORT_TYPE_MAX_NUMBER do
        local window = SocialWindowTabFriends.sortButtons[index]
        ButtonSetPressedFlag( window, index == SocialWindowTabFriends.display.type )
    end
    
    -- Update the Arrow
     WindowSetShowing( "SocialWindowTabFriendsSortButtonBarUpArrow", order == SocialWindowTabFriends.SORT_ORDER_UP )
    WindowSetShowing( "SocialWindowTabFriendsSortButtonBarDownArrow", order == SocialWindowTabFriends.SORT_ORDER_DOWN )

    local window = SocialWindowTabFriends.sortButtons[type]

    if( order == SocialWindowTabFriends.SORT_ORDER_UP ) then		
        WindowClearAnchors( "SocialWindowTabFriendsSortButtonBarUpArrow" )
        WindowAddAnchor("SocialWindowTabFriendsSortButtonBarUpArrow", "left", window, "left", 0, 0 )
    else
        WindowClearAnchors( "SocialWindowTabFriendsSortButtonBarDownArrow" )
        WindowAddAnchor("SocialWindowTabFriendsSortButtonBarDownArrow", "right", window, "right", 0, 0 )
    end

end

function SocialWindowTabFriends.OnMouseOverPlayerRow()
    -- Do nothing for now
end

function SocialWindowTabFriends.OnMouseOverPlayerRowEnd()
    -- Do nothing for now
end

function SocialWindowTabFriends.ResetEditBoxes()
    TextEditBoxSetText("SocialWindowTabFriendsPlayerSearchEditBox", L"")	-- Clear the Text from the Player Search Edit Box
    WindowAssignFocus("SocialWindowTabFriendsPlayerSearchEditBox", false)
    
	SocialWindowTabFriends.UpdateSelectedPlayerData()
	SocialWindowTabFriends.UpdatePlayerRow()
end

-- Handles the Left Button click on a player row
function SocialWindowTabFriends.OnLButtonUpPlayerRow()

    -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowTabFriendsList.PopulatorIndices[ rowNum ]
	
    SocialWindowTabFriends.UpdateSelectedPlayerData(dataIndex)
end

-- Handles the Right Button click on a player row
function SocialWindowTabFriends.OnRButtonUpPlayerRow()
    --DEBUG(L"EnteredGuildWindowTabRoster.OnRButtonUpPlayerRow")
    
    -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowTabFriendsList.PopulatorIndices[ rowNum ]
	
    SocialWindowTabFriends.UpdateSelectedPlayerData(dataIndex)
    
    if( SocialWindowTabFriends.SelectedFriendsName ~= L"" ) then

        local customItem = PlayerMenuWindow.NewCustomItem(L"Add Description", SocialWindowTabFriends.OnAddDescription, false)

        PlayerMenuWindow.ShowMenu( SocialWindowTabFriends.SelectedFriendsName, 0, {customItem} ) 
    end
end

function SocialWindowTabFriends.OnAddDescription()
    WindowSetShowing( "AddFriendDescription", true )
end

-- Displays a tooltip with information on the type of sort being hovered over
function SocialWindowTabFriends.OnMouseOverSortButton()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, SocialWindowTabFriends.ColumnHeaders[windowIndex])
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="top", RelativeTo=windowName, RelativePoint="center", XOffset=0, YOffset=-32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

-- Button Callback for the Sort Buttons
function SocialWindowTabFriends.OnSortPlayerList()
    local type = WindowGetId( SystemData.ActiveWindow.name )
    -- If we are already using this sort type, toggle the order.
    if( type == SocialWindowTabFriends.display.type ) then
        if( SocialWindowTabFriends.display.order == SocialWindowTabFriends.SORT_ORDER_UP ) then
            SocialWindowTabFriends.display.order = SocialWindowTabFriends.SORT_ORDER_DOWN
        else
            SocialWindowTabFriends.display.order = SocialWindowTabFriends.SORT_ORDER_UP
        end
        
    -- Otherwise change the type and use the up order.	
    else
        SocialWindowTabFriends.display.type = type
        SocialWindowTabFriends.display.order = SocialWindowTabFriends.SORT_ORDER_UP
    end

    UpdatePlayerList()
    SocialWindowTabFriends.UpdateSortButtons()
end
function SocialWindowTabFriends.AddFriend()
    if (SocialWindowTabFriendsPlayerSearchEditBox.Text == nil or SocialWindowTabFriendsPlayerSearchEditBox.Text == L"") then
        return
    end
    SendChatText( L"/friendadd "..SocialWindowTabFriendsPlayerSearchEditBox.Text, L"" )
    SocialWindowTabFriends.ResetEditBoxes()
end

function SocialWindowTabFriends.RemoveFriend()
    if (SocialWindowTabFriends.SelectedPlayerDataIndex == 0) then
        return
    end
    
    local selectPlayerName = SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].name
    SendChatText( L"/friendremove "..selectPlayerName, L"" )
    DelFriend(selectPlayerName)
    SocialWindowTabFriends.ResetEditBoxes()
end

----------------------------------------------------------------
-- Friends Tab Filter Menu
----------------------------------------------------------------
function SocialWindowTabFriends.RefreshFilterMenu()
    -- Display everything
    local displayOrder = {}
    for index, _ in ipairs( SocialWindowTabFriends.Settings.filters )
    do
        table.insert(displayOrder, index)
    end
    if DoesWindowExist("SocialWindowTabFriendsFilterMenuList")
    then
        ListBoxSetDisplayOrder("SocialWindowTabFriendsFilterMenuList", displayOrder)
    end
end

function SocialWindowTabFriends.PopulateFilterList()
    for row, data in ipairs(SocialWindowTabFriendsFilterMenuList.PopulatorIndices)
    do
        local filterData  = SocialWindowTabFriends.Settings.filters[data]
        local rowFrame    = "SocialWindowTabFriendsFilterMenuListRow"..row
        local buttonFrame = rowFrame.."Button"
        local labelFrame  = rowFrame.."Label"

        -- Label the button
        LabelSetText(labelFrame, GetStringFromTable("SocialStrings", SocialWindowBuddyListTabFriends.filterLabels[data] ))
        
        -- Set up the check button state
        ButtonSetCheckButtonFlag(buttonFrame, true)
        
        ButtonSetPressedFlag(buttonFrame, filterData.enabled)   
    end
end

function SocialWindowTabFriends.ToggleFilterMenu()
    WindowUtils.ToggleShowing( "SocialWindowTabFriendsFilterMenu" )
end

function SocialWindowTabFriends.ToggleFilter()
    local filterIndex      = WindowGetId(SystemData.ActiveWindow.name)
    local enableFilter     = ButtonGetPressedFlag("SocialWindowTabFriendsFilterMenuListRow"..filterIndex.."Button")
    
    local filterTypeIndex = ListBoxGetDataIndex("SocialWindowTabFriendsFilterMenuList", filterIndex)
    local filter          = SocialWindowTabFriends.Settings.filters[filterTypeIndex]
    
    filter.enabled = enableFilter
    
    UpdatePlayerList()
end

---------------------------------------
-- Util Functions
---------------------------------------
function SocialWindowTabFriends.IsPlayerFriend( playerName )
    for _, friendData in ipairs( SocialWindowTabFriends.GetFriendsDataTable() )
    do
        if( friendData.friendType ~= SocialWindowTabFriends.FRIENDTYPE.SUGGESTED and 
                WStringsCompareIgnoreGrammer( playerName, friendData.name ) == 0 )
        then
            return true
        end
    end

    return false
end

function GetFactionList()
    if( GameData.Player.realm == GameData.Realm.DESTRUCTION ) then 
       return SocialWindowTabFriends.AddvancedFriends.destro
    else
        return SocialWindowTabFriends.AddvancedFriends.order
    end
end

function GetAccountList()
    return GetFactionList().accountFriends
end

function GetAccountListDel()
    return GetFactionList().accountFriendsDel
end

function GetLocalList()
    return GetFactionList().localFriends[GameData.Player.name]
end

function InitLocalList()
    GetFactionList().localFriends[GameData.Player.name] = {}
end

function SocialWindowTabFriends.SwitchFriendType()
    local selectPlayerName = SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].name
    local accType = SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].type

    if accType == L"L" then
        GetAccountList()[selectPlayerName] = GetLocalList()[selectPlayerName]
        GetLocalList()[selectPlayerName] = nil
        GetAccountListDel()[selectPlayerName] = nil
        SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].type = L"A"
        UpdatePlayerList()
    else
        for _,temp in pairs(GetFactionList().localFriends) do
            temp[selectPlayerName] = GetAccountList()[selectPlayerName]
        end

        GetAccountList()[selectPlayerName] = nil
        SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].type = L"L"
        UpdatePlayerList()
    end
end

function DelFriend(playerName)
    if GetAccountList()[playerName] ~= nil then
        GetAccountListDel()[playerName] = GetAccountList()[playerName]
        GetAccountList()[playerName] = nil
    else
        GetLocalList()[playerName] = nil
    end
end

function UpdateFriendsLists(friendListData)
     if GetLocalList() == nil then
        InitLocalList()
    end
    for key,_ in pairs(GetAccountList()) do
        if GetLocalList()[key] ~= nil then
            GetLocalList()[key] = nil
        end
    end

    tempLocalFriends = {}
    if ( friendListData ~= nil ) then
        for _, value in ipairs( friendListData ) do
            tempLocalFriends[value.name] = value.name
        end
    end

    for key,_ in pairs(GetAccountListDel()) do
        if tempLocalFriends[key] ~= nil and GetLocalList()[key] == nil then
            SendChatText( L"/friendremove "..key, L"" )
            SocialWindowTabFriends.ResetEditBoxes()
        end
    end
end

function AddLocalFriendInit(playerName)
   

    --wenn schon in localer liste dann können wir es ignorieren
    if GetLocalList()[playerName] ~= nil then
        return
    end

    if GetAccountList()[playerName] == nil then
        if GetAccountListDel()[playerName] == nil then
            GetLocalList()[playerName] = {name=playerName, description=L""}
            DEBUG(GetLocalList()[playerName].name)
        end
    end
end

function GetFriend(playerName)
    if GetLocalList()[playerName] ~= nil then
        return GetLocalList()[playerName]
    end

    if GetAccountList()[playerName] ~= nil then
        return GetAccountList()[playerName]
    end

    return nil
end

function SocialWindowTabFriends.GetDescription(playerName)
    local friend = GetFriend(playerName)
    if friend ~= nil then
        return friend.description
    else
        return nil
    end
end

function AddGlobalFriendsToChar( friendListData )
    tempLocalFriends = {}
    FriendsToAdd = {}
    if ( friendListData ~= nil ) then
        for _, value in ipairs( friendListData ) do
            tempLocalFriends[value.name] = value.name
        end
    end

    for _, value in pairs(GetAccountList()) do
        if (tempLocalFriends[value.name] == nil) then 
            FriendsToAdd[value.name] = value
        end
    end

    for _,value in pairs(FriendsToAdd) do
        if value.name ~= GameData.Player.name then
            SocialWindowTabFriends.lastAdded = value.name
            SendChatText(L"/friendadd "..value.name, L"" )
        end
    end
end

function SocialWindowTabFriends.OnDescriptionAccept()
    if (TextEditBoxGetText("AddFriendDescriptionText") == nil) then
        return
    end

    if (SocialWindowTabFriends.SelectedPlayerDataIndex == 0) then
        return
    end
    
    local selectPlayerName = SocialWindowTabFriends.playerListData[SocialWindowTabFriends.SelectedPlayerDataIndex].name
    if GetAccountList()[selectPlayerName] ~= nil then
        GetAccountList()[selectPlayerName] = {name=selectPlayerName, description=TextEditBoxGetText("AddFriendDescriptionText")}
    else
        GetLocalList()[selectPlayerName] = {name=selectPlayerName, description=TextEditBoxGetText("AddFriendDescriptionText")}
    end

    WindowSetShowing( "AddFriendDescription", false )
    TextEditBoxSetText("AddFriendDescriptionText", L"")
    UpdatePlayerList()
end

function SocialWindowTabFriends.OnCancelDescription()
    WindowSetShowing( "AddFriendDescription", false )
    TextEditBoxSetText("AddFriendDescriptionText", L"")        
end

function SocialWindowTabFriends.OnAddDescription()
    WindowSetShowing( "AddFriendDescription", true )
end

function SocialWindowTabFriends.OnChatLogUpdated(updateType, filterType)
    if filterType == SystemData.ChatLogFilters.USER_ERROR then 
        if( updateType == SystemData.TextLogUpdate.ADDED ) then
            local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 ) 
            if text:find(L"That player could not be found") then 
                GetAccountList()[SocialWindowTabFriends.lastAdded] = nil
                GetLocalList()[SocialWindowTabFriends.lastAdded] = nil
            end
        end
    end   
end