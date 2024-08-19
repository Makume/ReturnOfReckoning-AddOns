-- Buddy List view
SocialWindowBuddyListTabFriends = {}


local SelectedPlayerDataIndex    = 0
local SelectedFriendsName        = L""
local playerListOrder = {}
SocialWindowBuddyListTabFriends.playerListData = {}
local friendsDirty = true

local FRIENDTYPE = SocialWindowTabFriends.FRIENDTYPE

local FILTERTYPE = SocialWindowTabFriends.FILTERTYPE

SocialWindowBuddyListTabFriends.filterLabels = 
{
    [ FILTERTYPE.ONLINE ] = StringTables.Social.FILTER_TYPE_ONLINE_FRIENDS,
    [ FILTERTYPE.OFFLINE ] = StringTables.Social.FILTER_TYPE_OFFLINE_FRIENDS,
    [ FILTERTYPE.SUGGESTED ] = StringTables.Social.FILTER_TYPE_SUGGESTED_FRIENDS,
}

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
SocialWindowBuddyListTabFriends.Settings = {}

SocialWindowBuddyListTabFriends.Settings.filters =
{
    [ FILTERTYPE.ONLINE ] = { enabled=true  },
    [ FILTERTYPE.OFFLINE ] = { enabled=true  },
    [ FILTERTYPE.SUGGESTED ] = { enabled=true  },
}



-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local player1 = SocialWindowBuddyListTabFriends.playerListData[index1]
    local player2 = SocialWindowBuddyListTabFriends.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end
    
    local compareResult = 0
    
    -- if suggested friends weren't filtered out, show them at the bottom
    if player1.friendType ~= player2.friendType
    then
        return player1.friendType < player2.friendType
    end
    
    if player1.friendType == FRIENDTYPE.FRIENDED
    then
        if player1.isOnline and player2.isOnline
        then
            compareResult = WStringsCompare(player1.name, player2.name)
        elseif (player1.isOnline or player2.isOnline)
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
    elseif player1.friendType == FRIENDTYPE.SUGGESTED
    then
        if player1.suggestScore > player2.suggestScore
        then
            compareResult = -1
        elseif player1.suggestScore < player2.suggestScore
        then
            compareResult = 1
        end
    end

    
    if (compareResult == 0) -- sorts by name when both are offline or otherwise were not sorted
    then
        compareResult = WStringsCompare(player1.name, player2.name)
    end

    return ( compareResult < 0 )
end

local function InitPlayerListData()
    SocialWindowBuddyListTabFriends.playerListData = {}
    local FriendsListData = GetFriendsList()
    

     if ( FriendsListData ~= nil ) then
        for key, value in ipairs( FriendsListData ) do
            -- These should match the data that was retrived from war_interface::LuaGetFriendsList
            SocialWindowBuddyListTabFriends.playerListData[key] = {}
            SocialWindowBuddyListTabFriends.playerListData[key].name = value.name
            SocialWindowBuddyListTabFriends.playerListData[key].friendType = FRIENDTYPE.FRIENDED
            SocialWindowBuddyListTabFriends.playerListData[key].isOnline = ( value.zoneID ~= 0 )
            if ( value.zoneID ~= 0 )
            then
                SocialWindowBuddyListTabFriends.playerListData[key].onlineString = GetZoneName( value.zoneID )
                SocialWindowBuddyListTabFriends.playerListData[key].rankString = towstring( value.rank )
                SocialWindowBuddyListTabFriends.playerListData[key].career = value.careerName
            else
                SocialWindowBuddyListTabFriends.playerListData[key].onlineString = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
                SocialWindowBuddyListTabFriends.playerListData[key].rankString = L""
                SocialWindowBuddyListTabFriends.playerListData[key].career = L""
            end
            if (value.guildName == nil) then
                SocialWindowBuddyListTabFriends.playerListData[key].guildName = L""
            else
                SocialWindowBuddyListTabFriends.playerListData[key].guildName = value.guildName
            end
            
            if FriendSuggester.HasDataForPlayer( value.name )
            then
                -- friend must have recently been added who was a suggestion before
                FriendSuggester.OnFriendAdded( value.name )
            end
        end
    end
end

-- there's only one data table, and the design is to be able to show/hide Suggested friends via filter checkboxes
local function MergeSuggestedFriends()
    local currentId = #SocialWindowBuddyListTabFriends.playerListData + 1
    
    for name, friendData in pairs(FriendSuggester.Data)
    do
        if friendData.value < SocialWindowTabFriends.SUGGEST_SCORE_THRESHOLD
        then
            continue
        end
        SocialWindowBuddyListTabFriends.playerListData[currentId] = {}
        SocialWindowBuddyListTabFriends.playerListData[currentId].name = name
        SocialWindowBuddyListTabFriends.playerListData[currentId].friendType = FRIENDTYPE.SUGGESTED
        SocialWindowBuddyListTabFriends.playerListData[currentId].suggestScore = friendData.value
        -- later we could show people why we are suggesting the player. 
        -- ex) "You grouped with this player. You sent tells to this player. "
        
        currentId = currentId + 1
    end
    
end

local function FilterPlayerList()	
    playerListOrder = {}
    for dataIndex, data in ipairs( SocialWindowBuddyListTabFriends.playerListData ) 
    do
        if (data.friendType == FRIENDTYPE.SUGGESTED) and (not SocialWindowBuddyListTabFriends.Settings.filters[FILTERTYPE.SUGGESTED].enabled)
        then
            continue
        end
        if (data.isOnline == false) and (not SocialWindowBuddyListTabFriends.Settings.filters[FILTERTYPE.OFFLINE].enabled)
        then
            continue
        elseif (data.isOnline == true) and (not SocialWindowBuddyListTabFriends.Settings.filters[FILTERTYPE.ONLINE].enabled)
        then
            continue
        end
        table.insert(playerListOrder, dataIndex)
    end
end

-- sort buddy list always by 1) Online/Offline, 2) Name
local function SortPlayerList()	
    table.sort( playerListOrder, ComparePlayers )
end

local function UpdatePlayerList()
    InitPlayerListData()
    MergeSuggestedFriends()
    friendsDirty = false
    FilterPlayerList()
    SortPlayerList()
    
    
    ListBoxSetDisplayOrder( "SocialWindowBuddyListTabFriendsList", playerListOrder )
end

---------------------------------------
-- Buddy List (Friends) Functions
---------------------------------------
function SocialWindowBuddyListTabFriends.Initialize()
    ListBoxSetDisplayOrder( "SocialWindowBuddyListTabFriendsList", playerListOrder )
    
    WindowRegisterEventHandler( "SocialWindowBuddyListTabFriendsList", SystemData.Events.SOCIAL_FRIENDS_UPDATED, "SocialWindowBuddyListTabFriends.OnFriendsUpdated")
    
    if FriendSuggester
    then
        FriendSuggester.RegisterCallback( SocialWindowBuddyListTabFriends.OnSuggestedFriendsUpdated )
    end
    
    SocialWindowBuddyListTabFriends.OnFriendsUpdated()
end

function SocialWindowBuddyListTabFriends.OnSuggestedFriendsUpdated()
    if SocialWindowBuddyListTabFriends.Settings.filters[FILTERTYPE.SUGGESTED].enabled
    then
        friendsDirty = true
        if WindowGetShowing("SocialWindowBuddyList")
        then
            UpdatePlayerList()
        end
    end
end

function SocialWindowBuddyListTabFriends.OnFriendsUpdated()
    friendsDirty = true
    if WindowGetShowing("SocialWindowBuddyList")
    then
        UpdatePlayerList()
    end
end

function SocialWindowBuddyListTabFriends.OnShown()
    if friendsDirty
    then
        UpdatePlayerList()
    end
end

function SocialWindowBuddyListTabFriends.OnMouseOverPlayerRow()
    -- Create a tooltip detailing the information from the columns that were in the old Social Window friends tab

    -- determine which player we are mousing over
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowBuddyListTabFriendsList.PopulatorIndices[ rowNum ]
    local friendData = SocialWindowBuddyListTabFriends.playerListData[dataIndex]
    
    if friendData
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        
        --name
        local iRow = 1
        Tooltips.SetTooltipText( iRow, 1, friendData.name )
        
        if friendData.friendType == FRIENDTYPE.FRIENDED
        then
            -- description
            local description = SocialWindowTabFriends.GetDescription(friendData.name)
            if description ~= nil then
                iRow = iRow + 1
                Tooltips.SetTooltipText( iRow, 1,  description )
                Tooltips.SetTooltipColorDef( iRow, 1, DefaultColor.MEDIUM_LIGHT_GRAY  )
            end

            -- location / online status
            iRow = iRow + 1
            if friendData.isOnline
            then
                Tooltips.SetTooltipColorDef( 1, 1, DefaultColor.GREEN  )
                
                Tooltips.SetTooltipText( iRow, 1,  GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_LOCATION, {friendData.onlineString} ) )
            else
                Tooltips.SetTooltipColorDef( 1, 1, DefaultColor.MEDIUM_LIGHT_GRAY  )
                
                Tooltips.SetTooltipText( iRow, 1,  friendData.onlineString )
                Tooltips.SetTooltipColorDef( iRow, 1, DefaultColor.MEDIUM_LIGHT_GRAY  )
            end

            if friendData.isOnline -- more info is available for online players
            then
                -- class
                iRow = iRow + 1
                Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_CAREER, {friendData.career} ) )
                
                -- rank
                iRow = iRow + 1
                Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_RANK, {friendData.rankString} ) )
            end
        elseif friendData.friendType == FRIENDTYPE.SUGGESTED
        then
            Tooltips.SetTooltipColorDef( iRow, 1, DefaultColor.TEAL  )
            
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1,  GetStringFromTable("SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_SUGGESTED_FRIEND1) )
            
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_SUGGESTED_FRIEND2, {friendData.name} ) )
        end

        
        Tooltips.Finalize()
        
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
    end
    
end

-- Handles the Left Button click on a player row (on the Buddy List)
function SocialWindowBuddyListTabFriends.OnLButtonUpPlayerRow()
    -- let's just show the context menu.
    -- there's no point on the buddy list of only selecting a player as there's no remove button
    SocialWindowBuddyListTabFriends.OnRButtonUpPlayerRow()
end

function SocialWindowBuddyListTabFriends.OnRButtonUpPlayerRow()
    -- Convert the Row index to the data index
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowBuddyListTabFriendsList.PopulatorIndices[ rowNum ]
	
    SocialWindowBuddyListTabFriends.UpdateSelectedPlayerData(dataIndex)
    
    if( SelectedFriendsName ~= L"" ) then
        PlayerMenuWindow.ShowMenu( SelectedFriendsName, 0, false, true ) 
    end
end

function SocialWindowBuddyListTabFriends.UpdateSelectedPlayerData( dataIndex )

    -- Set the label values
    if (dataIndex ~= nil and dataIndex ~= 0) 
    then
        SelectedPlayerDataIndex = dataIndex
        SelectedFriendsName = SocialWindowBuddyListTabFriends.playerListData[dataIndex].name
    else
        SelectedPlayerDataIndex = 0
        SelectedFriendsName = L""
    end
   
    SocialWindowBuddyListTabFriends.UpdateSelectedRow()
end

function SocialWindowBuddyListTabFriends.UpdateSelectedRow()

    if( nil == SocialWindowBuddyListTabFriendsList.PopulatorIndices )
    then
        return
    end
    
    -- Setup the Custom formating for each row
    for rowIndex, dataIndex in ipairs( SocialWindowBuddyListTabFriendsList.PopulatorIndices ) 
    do    
        local selected = SelectedPlayerDataIndex == dataIndex
        
        local rowName   = "SocialWindowBuddyListTabFriendsListRow"..rowIndex

        ButtonSetPressedFlag(rowName, selected )
        ButtonSetStayDownFlag(rowName, selected )
    end
    
end

function SocialWindowBuddyListTabFriends.UpdatePlayerRowBuddyList()

    if (SocialWindowBuddyListTabFriendsList.PopulatorIndices == nil) 
    then
        return
    end

    for rowIndex, dataIndex in ipairs (SocialWindowBuddyListTabFriendsList.PopulatorIndices) 
    do
        local rowName = "SocialWindowBuddyListTabFriendsListRow"..rowIndex

            -- Change colors based on if the guild member is selected/unselected, or offline            
        local labelColor = DefaultColor.GREEN           -- Default Online Memebers are green            
        
        if ( not SocialWindowBuddyListTabFriends.playerListData[dataIndex].isOnline ) 
        then
            labelColor = DefaultColor.MEDIUM_LIGHT_GRAY		-- Offline Members are grey
        end
        if SocialWindowBuddyListTabFriends.playerListData[dataIndex].friendType == FRIENDTYPE.SUGGESTED
        then
            labelColor = DefaultColor.TEAL
        end
        
        LabelSetTextColor( rowName.."Name", labelColor.r, labelColor.g, labelColor.b)
            
    end
    
    SocialWindowTabFriends.SetListRowTints(SocialWindowBuddyListTabFriendsList, "SocialWindowBuddyListTabFriendsListRow")
end

function SocialWindowBuddyListTabFriends.ToggleFilter()
    local filterIndex      = WindowGetId(SystemData.ActiveWindow.name)
    local enableFilter     = ButtonGetPressedFlag("SocialWindowBuddyListFilterMenuListRow"..filterIndex.."Button")
    
    local filterTypeIndex = ListBoxGetDataIndex("SocialWindowBuddyListFilterMenuList", filterIndex)
    local filter          = SocialWindowBuddyListTabFriends.Settings.filters[filterTypeIndex]
    
    filter.enabled = enableFilter
    
    UpdatePlayerList()
end
