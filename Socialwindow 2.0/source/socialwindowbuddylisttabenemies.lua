----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowBuddyListTabEnemies = {}

SocialWindowBuddyListTabEnemies.playerListData = {}
SocialWindowBuddyListTabEnemies.playerListOrder = {} -- values are keys into playerListData, table is ordered based on sorting

-- move this to Nemesis system client code later, may take another form too
SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL = 1
SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_ARCH = 2
SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_COUNT = 2

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local PARENT_WINDOW = "SocialWindowBuddyListTabEnemies"

-- color nemesis names in each row differently based on what kind of nemesis they are
-- could also consider coloring based on your record kills vs deaths against them too
local rowColorLookupByNemesisLevel = {
            [SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL] = DefaultColor.ORANGE,
            [SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_ARCH] = DefaultColor.RED,
}

local OFFLINE_COLOR = DefaultColor.MEDIUM_LIGHT_GRAY

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------

-- this may need to be modified later
local function GetLocalizedNemesisStringByLevel( nemesisLevel )
    if nemesisLevel == nil or nemesisLevel < SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL or nemesisLevel > SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_COUNT
    then
        return L""
    end
    
    return GetStringFromTable( "SocialStrings", StringTables.Social.NEMESIS_LEVEL_NORMAL + (nemesisLevel - 1) )
    
end

-- local function InitPlayerListData()
    -- SocialWindowBuddyListTabEnemies.playerListData = {}
        
    -- local FriendsListData = GetFriendsList()
    
    -- SocialWindowBuddyListTabEnemies.NumberOfFriends = 0

     -- if ( FriendsListData ~= nil ) then
        -- for key, value in ipairs( FriendsListData ) do
            -- -- These should match the data that was retrived from war_interface::LuaGetFriendsList
            -- SocialWindowBuddyListTabEnemies.playerListData[key] = {}
			-- SocialWindowBuddyListTabEnemies.NumberOfFriends = SocialWindowBuddyListTabEnemies.NumberOfFriends +1
            -- SocialWindowBuddyListTabEnemies.playerListData[key].name = value.name
            -- SocialWindowBuddyListTabEnemies.playerListData[key].career = value.careerName
            -- if (value.careerName == L"") then
                -- SocialWindowBuddyListTabEnemies.playerListData[key].rankString = L""
            -- else
                -- SocialWindowBuddyListTabEnemies.playerListData[key].rankString = L""..value.rank
                -- -- if the person is offline the Rank is invalid, so don't display anything in the list
            -- end
            -- if ( value.zoneID ~= 0 ) then
                -- SocialWindowBuddyListTabEnemies.playerListData[key].onlineString = GetZoneName( value.zoneID )
            -- else
                -- SocialWindowBuddyListTabEnemies.playerListData[key].onlineString = GetStringFromTable( "SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE)
            -- end
            -- SocialWindowBuddyListTabEnemies.playerListData[key].isOnline = ( value.zoneID ~= 0 )
            -- if (value.guildName == nil) then
                -- SocialWindowBuddyListTabEnemies.playerListData[key].guildName = L""
            -- else
                -- SocialWindowBuddyListTabEnemies.playerListData[key].guildName = value.guildName
            -- end
        -- end
    -- end
    
-- end

-- This function is used as the comparison function for 
-- table.sort() on the player display order
local function ComparePlayers( index1, index2 )

    if( index2 == nil ) then
        return false
    end

    local player1 = SocialWindowBuddyListTabEnemies.playerListData[index1]
    local player2 = SocialWindowBuddyListTabEnemies.playerListData[index2]
    
    if (player1 == nil or player1.name == nil or player1.name == L"") then
        return false
    end
    
    if (player2 == nil or player2.name == nil or player2.name == L"") then
        return true
    end
    
    local compareResult
    
    -- for now there is no choice for sorting Nemeses
    -- sort first by online vs offline, then Nemesis level (normal, arch), then by name alphabetic ascending
    if player1.isOnline and player2.isOnline
    then
        compareResult = 0
        if player1.nemesisLevel == player2.nemesisLevel 
        then
            compareResult = WStringsCompare(player1.name, player2.name)
        else
            if player1.nemesisLevel < player2.nemesisLevel 
            then
                compareResult = 1
            else
                compareResult = -1
            end
        end

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
    
    if (compareResult == 0) -- sorts by name when both are offline, or both of the same nemesis level
    then
        compareResult = WStringsCompare(player1.name, player2.name)
    end

    return ( compareResult < 0 )
end

local function SortPlayerList()	
    table.sort( SocialWindowBuddyListTabEnemies.playerListOrder, ComparePlayers )
end

-- for now we aren't really filtering out players, so this just puts indices in playerListOrder for sorting later
local function FilterPlayerList()	
    SocialWindowBuddyListTabEnemies.playerListOrder = {}
    for dataIndex, data in ipairs( SocialWindowBuddyListTabEnemies.playerListData ) do
        table.insert(SocialWindowBuddyListTabEnemies.playerListOrder, dataIndex)
    end
end

local function SetupDummyData()

    SocialWindowBuddyListTabEnemies.playerListData = {}
    
    local iCurIndex = 1
    
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex] = {}
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].name = L"Leeroy"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].rankString = L"38"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].nemesisLevel = SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].locationString = L"Candy Mountain"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].career = L"Black Orc"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].isOnline = true
    
    iCurIndex = iCurIndex + 1
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex] = {}
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].name = L"Stewie"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].rankString = L"40"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].nemesisLevel = SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_ARCH
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].locationString = L"Quahog"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].career = L"Sorcerer"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].isOnline = true
    
    iCurIndex = iCurIndex + 1
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex] = {}
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].name = L"Frylock"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].rankString = L"40"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].nemesisLevel = SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].locationString = L"New Jersey"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].career = L"Marauder"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].isOnline = true
    
    iCurIndex = iCurIndex + 1
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex] = {}
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].name = L"Barney"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].rankString = L"40"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].nemesisLevel = SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_NORMAL
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].locationString = L"Moe's Tavern"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].career = L"Chaos Dwarf Slaver"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].isOnline = true
    
    iCurIndex = iCurIndex + 1
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex] = {}
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].name = L"Bender"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].rankString = L"39"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].nemesisLevel = SocialWindowBuddyListTabEnemies.NEMESIS_LEVEL_ARCH
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].locationString = L"New New York"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].career = L"Unscrupulous Robot"
    SocialWindowBuddyListTabEnemies.playerListData[iCurIndex].isOnline = true
end


local function UpdatePlayerList()
    -- Filter, Sort, and Update
    -- InitPlayerListData() -- coming soon, this will retrieve data from the client
    SetupDummyData()
    FilterPlayerList()
    SortPlayerList()
    
    ListBoxSetDisplayOrder( PARENT_WINDOW.."List", SocialWindowBuddyListTabEnemies.playerListOrder )

end

----------------------------------------------------------------
-- SocialWindowBuddyListTabEnemies Functions
----------------------------------------------------------------
function SocialWindowBuddyListTabEnemies.Initialize()



    SocialWindowBuddyListTabEnemies.OnNemesesUpdated()
    
    
end

function SocialWindowBuddyListTabEnemies.OnNemesesUpdated()
    UpdatePlayerList()
    
end

function SocialWindowBuddyListTabEnemies.UpdatePlayerRow()
    if (SocialWindowBuddyListTabEnemiesList.PopulatorIndices == nil) 
    then
        return
    end

    for rowIndex, dataIndex in ipairs (SocialWindowBuddyListTabEnemiesList.PopulatorIndices) 
    do
        local rowName = PARENT_WINDOW.."ListRow"..rowIndex

            -- Change colors based on if the guild member is selected/unselected, or offline            
        local labelColor = DefaultColor.WHITE           -- Default Online Memebers are white            
        
        local nemesisData = SocialWindowBuddyListTabEnemies.playerListData[dataIndex]
        if ( not nemesisData.isOnline ) 
        then
            labelColor = OFFLINE_COLOR		-- Offline Members are grey
        else
            labelColor = rowColorLookupByNemesisLevel[ nemesisData.nemesisLevel ]
        end
        
        if not labelColor
        then
            labelColor = DefaultColor.WHITE  
        end
        
        LabelSetTextColor( rowName.."Name", labelColor.r, labelColor.g, labelColor.b)
            
    end

    SocialWindowTabFriends.SetListRowTints(SocialWindowBuddyListTabEnemiesList, PARENT_WINDOW.."ListRow")
end

function SocialWindowBuddyListTabEnemies.OnMouseOverPlayerRow()
    -- Create a tooltip detailing the information from the columns that were in the old Social Window friends tab
    -- Nemeses will also have a custom tooltip

    -- determine which player we are mousing over
	local rowNum = WindowGetId( SystemData.ActiveWindow.name )	
	local dataIndex = SocialWindowBuddyListTabEnemiesList.PopulatorIndices[ rowNum ]
    local nemesisData = SocialWindowBuddyListTabEnemies.playerListData[dataIndex]
    
    if nemesisData
    then
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        
        --name
        local iRow = 1
        Tooltips.SetTooltipText( iRow, 1,  nemesisData.name )
        if nemesisData.isOnline
        then
            Tooltips.SetTooltipColorDef( iRow, 1, rowColorLookupByNemesisLevel[nemesisData.nemesisLevel]  )
        else
            Tooltips.SetTooltipColorDef( iRow, 1, OFFLINE_COLOR  )
        end
        
        -- nemesis level
        if nemesisData.isOnline
        then
            iRow = iRow + 1
            local nemesisString = GetLocalizedNemesisStringByLevel( nemesisData.nemesisLevel )
            Tooltips.SetTooltipText( iRow, 1,  nemesisString )
            Tooltips.SetTooltipColorDef( iRow, 1, rowColorLookupByNemesisLevel[nemesisData.nemesisLevel]  )
        end
        
        -- location / online status
        iRow = iRow + 1
        if nemesisData.isOnline
        then
            Tooltips.SetTooltipText( iRow, 1,  GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_LOCATION, {nemesisData.locationString} ) )
        else
            Tooltips.SetTooltipText( iRow, 1,  nemesisData.locationString )
            Tooltips.SetTooltipColorDef( iRow, 1, OFFLINE_COLOR  )
        end
        
        if nemesisData.isOnline -- more info is available for online players
        then
            -- class
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_CAREER, {nemesisData.career} ) )
            
            -- rank
            iRow = iRow + 1
            Tooltips.SetTooltipText( iRow, 1, GetStringFormatFromTable( "SocialStrings", StringTables.Social.TOOLTIP_BUDDY_LIST_RANK, {nemesisData.rankString} ) )
        end
        
        Tooltips.Finalize()
        
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_VARIABLE )
    end
    
end
