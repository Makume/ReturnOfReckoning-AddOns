----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindow = {}

SocialWindow.TABS_SEARCH		= 1
SocialWindow.TABS_FRIENDS		= 2
SocialWindow.TABS_IGNORE		= 3
SocialWindow.TABS_OPTIONS		= 4
SocialWindow.TABS_MAX_NUMBER	= 4
SocialWindow.SelectedTab		= 0


SocialWindow.CurrentlyShownList = 0
SocialWindow.FRIENDS_MENU  = 1
SocialWindow.IGNORE_MENU   = 2
SocialWindow.GUILD_MENU    = 3
SocialWindow.SCENARIO_MENU = 4
SocialWindow.WARBAND_MENU  = 5

SocialWindow.tabs = 
{
    [SocialWindow.TABS_SEARCH]  = { windowName="SocialWindowTabSearch",    buttonName="SocialWindowViewMode1", listId=SocialWindow.FRIENDS_MENU },
    [SocialWindow.TABS_FRIENDS] = { windowName="SocialWindowTabFriends",   buttonName="SocialWindowViewMode2", listId=SocialWindow.FRIENDS_MENU  },
    [SocialWindow.TABS_IGNORE]  = { windowName="SocialWindowTabIgnore",    buttonName="SocialWindowViewMode3", listId=0 },
    [SocialWindow.TABS_OPTIONS] = { windowName="SocialWindowTabOptions",   buttonName="SocialWindowViewMode4", listId=0  },
}


SocialWindow.DEFAULT_SCROLLWINDOW_WIDTH = 400
SocialWindow.DEFAULT_SCROLLWINDOW_HEIGHT = 372
SocialWindow.COLUMN_SPACING     = 38
SocialWindow.ENDLINE_SCROLLBAR_SPACING  = 30
SocialWindow.ShowOfflineFriends = false
SocialWindow.ShowOfflineIgnores = false
SocialWindow.numWindowsCreated = 0
SocialWindow.currentSelectedPlayerName = nil
SocialWindow.currentSelectedPlayerId = 0
SocialWindow.numOnlineMembers = 0
SocialWindow.ContextMenuAnchor = {
            Point = "bottomright", 
            RelativePoint = "bottomleft", 
            RelativeTo = "ChatWindowSocialWindowButton", 
            XOffset = 5, 
            YOffset = 0 }
SocialWindow.ContextSubMenuAnchor = {
            Point = "bottomright", 
            RelativePoint = "bottomleft", 
            RelativeTo = "EA_Window_ContextMenu1", 
            XOffset = 5, 
            YOffset = 0 }
            
SocialWindow.TabTooltips = {
                            StringTables.Social.TOOLTIP_SOCIAL_TAB_SEARCH,
                            StringTables.Social.TOOLTIP_SOCIAL_TAB_FRIENDS,
                            StringTables.Social.TOOLTIP_SOCIAL_TAB_IGNORE,
                            StringTables.Social.TOOLTIP_SOCIAL_TAB_OPTIONS }

SocialWindow.MemberListTable = {}
----------------------------------------------------------------
-- SocialWindow Functions
----------------------------------------------------------------
-- OnInitialize Handler
function SocialWindow.Initialize()

    LabelSetText( "SocialWindowTitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_TITLE) )

    for index = 1, SocialWindow.TABS_MAX_NUMBER 
    do
        ButtonSetStayDownFlag( "SocialWindowViewMode"..index, true )
    end

    -- Set the text for the window tab buttons
    ButtonSetText ("SocialWindowViewMode1", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TAB_SEARCH) )
    ButtonSetText ("SocialWindowViewMode2", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TAB_FRIENDS) )
    ButtonSetText ("SocialWindowViewMode3", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TAB_IGNORE) )
    ButtonSetText ("SocialWindowViewMode4", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_TAB_OPTIONS) )
    
    CreateWindow("SocialWindowListWindow", false)
    CreateWindow("SocialWindowPlayerInformationTooltipWindow", false)
    CreateWindowFromTemplate ("SocialWindowAddMemberWindow", "SocialWindowAddMemberWindow", "Root")
    ButtonSetText("SocialWindowAddMemberWindowAcceptButton", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_ADD ) )
    ButtonSetText("SocialWindowAddMemberWindowCancelButton", GetString(StringTables.Default.LABEL_CANCEL) )
    WindowRegisterCoreEventHandler("SocialWindowAddMemberWindowAcceptButton", "OnLButtonUp", "SocialWindow.OnNewMember")
    WindowRegisterCoreEventHandler("SocialWindowAddMemberWindowCancelButton", "OnLButtonUp", "SocialWindow.OnCancelNewMember")
    WindowRegisterCoreEventHandler("SocialWindowAddMemberWindowText", "OnKeyEscape", "SocialWindow.OnCancelNewMember")
    WindowRegisterCoreEventHandler("SocialWindowAddMemberWindowText", "OnKeyEnter", "SocialWindow.OnNewMember")
    WindowSetShowing("SocialWindowAddMemberWindow", false)
    WindowSetShowing("SocialWindowListWindowSelection", false)
    ButtonSetText("SocialWindowListWindowAddFriendButton", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_ADD) )
    
    WindowSetShowing("SocialWindowListWindowAddMemberWindow", false)
    ButtonSetText("SocialWindowListWindowAddMemberWindowAcceptButton", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_ADD ) )
    ButtonSetText("SocialWindowListWindowAddMemberWindowCancelButton", GetString(StringTables.Default.LABEL_CANCEL) )
    WindowRegisterCoreEventHandler("SocialWindowListWindowAddMemberWindowAcceptButton", "OnLButtonUp", "SocialWindow.OnAddMember")
    WindowRegisterCoreEventHandler("SocialWindowListWindowAddMemberWindowCancelButton", "OnLButtonUp", "SocialWindow.OnCancelAddMember")
    WindowRegisterCoreEventHandler("SocialWindowListWindowAddMemberWindowText", "OnKeyEscape", "SocialWindow.OnCancelAddMember")
    WindowRegisterCoreEventHandler("SocialWindowListWindowAddMemberWindowText", "OnKeyEnter", "SocialWindow.OnAddMember")
    
    
    -- Initialize the ContextMenus
    CreateWindowFromTemplate ("SocialWindowContextFriends", "SocialContextMenuItemWithMenu", "Root")
    ButtonSetText( "SocialWindowContextFriends", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDSLIST ) )
    WindowRegisterCoreEventHandler("SocialWindowContextFriends", "OnMouseOver", "SocialWindow.ShowFriendsListContextWindow")
    WindowSetShowing("SocialWindowContextFriends", false)
    
    CreateWindowFromTemplate ("SocialWindowContextIgnore", "SocialContextMenuItemWithMenu", "Root")
    ButtonSetText( "SocialWindowContextIgnore", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORELIST ) )
    WindowRegisterCoreEventHandler("SocialWindowContextIgnore", "OnMouseOver", "SocialWindow.ShowIgnoreListContextWindow")
    WindowSetShowing("SocialWindowContextIgnore", false)
    
  
    SocialWindow.ShowTab(SocialWindow.TABS_SEARCH)
end


-- OnShutdown Handler
function SocialWindow.Shutdown()
end

function SocialWindow.ToggleShowing()
    --DEBUG(L"Entered SocialWindow.ToggleShowing")    
    WindowUtils.ToggleShowing( "SocialWindow" )
end

function SocialWindow.ToggleOfflineMembersShowing()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.CurrentlyShownList == SocialWindow.FRIENDS_MENU)
    then
        SocialWindow.ShowOfflineFriends = not SocialWindow.ShowOfflineFriends
        if (SocialWindow.ShowOfflineFriends == true)
        then
            WindowSetShowing("SocialWindowListWindowPlusButton", false)
            WindowSetShowing("SocialWindowListWindowMinusButton", true)
        else
            WindowSetShowing("SocialWindowListWindowPlusButton", true)
            WindowSetShowing("SocialWindowListWindowMinusButton", false)
        end
        local friendsAddedSuccess = SocialWindow.AddMembersToListWindow(GetFriendsList)
        if (friendsAddedSuccess == true)
        then
            SocialWindow.CurrentlyShownList = SocialWindow.FRIENDS_MENU
            
            LabelSetText("SocialWindowListWindowHeader", GetFormatStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_FRIENDS, {SocialWindow.numOnlineMembers, #SocialWindow.MemberListTable} ) )
            ScrollWindowUpdateScrollRect("SocialWindowListWindowScrollWindow")
            EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2, SocialWindow.ContextSubMenuAnchor)
        end
    end
    if (SocialWindow.CurrentlyShownList == SocialWindow.IGNORE_MENU)
    then
        SocialWindow.ShowOfflineIgnores = not SocialWindow.ShowOfflineIgnores
        if (SocialWindow.ShowOfflineIgnores == true)
        then
            WindowSetShowing("SocialWindowListWindowPlusButton", false)
            WindowSetShowing("SocialWindowListWindowMinusButton", true)
        else
            WindowSetShowing("SocialWindowListWindowPlusButton", true)
            WindowSetShowing("SocialWindowListWindowMinusButton", false)
        end
        local ignoresAddedSuccess = SocialWindow.AddMembersToListWindow(GetIgnoreList)
        if (ignoresAddedSuccess == true)
        then
            SocialWindow.CurrentlyShownList = SocialWindow.IGNORE_MENU
            
            LabelSetText("SocialWindowListWindowHeader", GetFormatStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_IGNORES, {SocialWindow.numOnlineMembers, #SocialWindow.MemberListTable} ) )
            ScrollWindowUpdateScrollRect("SocialWindowListWindowScrollWindow")
            EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2, SocialWindow.ContextSubMenuAnchor)
        end
    end
end

-- Context Menu Functions
function SocialWindow.OnListWindowHidden()
    SocialWindow.CurrentlyShownList = 0
end

function SocialWindow.ShowPlayerContextMenuWindow()
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_3)
    
    if (SocialWindow.CurrentlyShownList == SocialWindow.IGNORE_MENU)
    then
        EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_REMOVEIGNORE ), SocialWindow.IgnoreRemove, false, false, EA_Window_ContextMenu.CONTEXT_MENU_3)
    end
    
    if (SocialWindow.CurrentlyShownList == SocialWindow.FRIENDS_MENU)
    then
        EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_REMOVEFRIEND ), SocialWindow.FriendRemove, false, false, EA_Window_ContextMenu.CONTEXT_MENU_3)
    
        if (SocialWindow.MemberListTable[SocialWindow.currentSelectedPlayerId].zoneID ~= 0)
        then
            EA_Window_ContextMenu.AddMenuItem(GetString( StringTables.Default.LABEL_TELL ), SocialWindow.SendTell, false, true, EA_Window_ContextMenu.CONTEXT_MENU_3)
            if ( IsWarBandActive() )
            then
                inFullGroup = PartyUtils.IsWarbandFull()
                if (inFullGroup == false)
                then
                    EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_INVITETO_WB), SocialWindow.InviteMemberToParty, false, false, EA_Window_ContextMenu.CONTEXT_MENU_3)
                else
                end
            else
                inFullGroup = GroupWindow.groupData ~= nil and GroupWindow.groupData[GroupWindow.MAX_GROUP_MEMBERS].name ~= L""
                local isInPlayersGroup = false
                for idx=1, GroupWindow.MAX_GROUP_MEMBERS do
                    if (GroupWindow.groupData[idx].name ~= L"" and
                        GroupWindow.groupData[idx].name == SocialWindow.MemberListTable[SocialWindow.currentSelectedPlayerId].name)
                    then
                        isInPlayersGroup = true
                    end
                end
                if (inFullGroup == false and isInPlayersGroup == false)
                then
                    EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_INVITETO_PARTY), SocialWindow.InviteMemberToParty, false, false, EA_Window_ContextMenu.CONTEXT_MENU_3)
                else
                end
            end
            
            
            if (SocialWindow.MemberListTable[SocialWindow.currentSelectedPlayerId].guildName == nil or
                SocialWindow.MemberListTable[SocialWindow.currentSelectedPlayerId].guildName == L""
                and (GameData.Guild.m_GuildName ~= L""
                    and SocialWindow.MemberListTable[SocialWindow.currentSelectedPlayerId].guildName ~= GameData.Guild.m_GuildName) )
            then
                EA_Window_ContextMenu.AddMenuItem(GetString(StringTables.Default.LABEL_PLAYER_MENU_GUILD_INVITE), SocialWindow.InviteMemberToGuild, false, false, EA_Window_ContextMenu.CONTEXT_MENU_3)
            end
        end
    end
    
    x, y = WindowGetOffsetFromParent( "CursorWindow" )
    local anchor = {
            Point = "topleft", 
            RelativePoint = "topleft", 
            RelativeTo = "Root", 
            XOffset = x, 
            YOffset = y }
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_3, anchor )
end

function SocialWindow.MemberAdd()
    WindowSetShowing( "SocialWindowListWindowAddMemberWindow", true )
    TextEditBoxSetText( "SocialWindowListWindowAddMemberWindowText", L"" )
    WindowSetTintColor( "SocialWindowListWindowAddMemberWindowText", 255,255,255 )
    if (SocialWindow.CurrentlyShownList == SocialWindow.FRIENDS_MENU)
    then
        LabelSetText("SocialWindowListWindowAddMemberWindowTitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_ADDFRIEND) )
    elseif (SocialWindow.CurrentlyShownList == SocialWindow.IGNORE_MENU)
    then
        LabelSetText("SocialWindowListWindowAddMemberWindowTitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_ADDIGNORE) )
    end
end

function SocialWindow.FriendAdd()
    WindowSetShowing("SocialWindowAddMemberWindow", true)
    LabelSetText("SocialWindowAddMemberWindowTitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_ADDFRIEND) )
    WindowSetId("SocialWindowAddMemberWindow", SocialWindow.FRIENDS_MENU)
    TextEditBoxSetText( "SocialWindowAddMemberWindowText", L"" )
    WindowSetTintColor( "SocialWindowAddMemberWindowText", 255,255,255 )
end

function SocialWindow.IgnoreAdd()
    WindowSetShowing("SocialWindowAddMemberWindow", true)
    LabelSetText("SocialWindowAddMemberWindowTitleBarText", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_ADDIGNORE) )
    WindowSetId("SocialWindowAddMemberWindow", SocialWindow.IGNORE_MENU)
    TextEditBoxSetText( "SocialWindowAddMemberWindowText", L"" )
    WindowSetTintColor( "SocialWindowAddMemberWindowText", 255,255,255 )
end

function SocialWindow.OnNewMember()
    local newName = TextEditBoxGetText( "SocialWindowAddMemberWindowText" )
    WindowSetShowing( "SocialWindowAddMemberWindow", false )
    local listId = WindowGetId("SocialWindowAddMemberWindow")
    if (newName ~= nil and newName ~= L"")
    then
        local chatText = L""
        if (listId == SocialWindow.FRIENDS_MENU)
        then
            chatText = L"/friend "..newName
        elseif (listId == SocialWindow.IGNORE_MENU)
        then
            chatText = L"/ignore "..newName
        end
        
        SendChatText( chatText, L"" )
    end
end

function SocialWindow.OnCancelNewMember()
    WindowSetShowing( "SocialWindowAddMemberWindow", false )
end

function SocialWindow.OnAddMember()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    local newName = TextEditBoxGetText( "SocialWindowListWindowAddMemberWindowText" )
    WindowSetShowing( "SocialWindowListWindowAddMemberWindow", false )
    
    if (newName ~= nil and newName ~= L"")
    then
        local chatText = L""
        if (SocialWindow.CurrentlyShownList == SocialWindow.FRIENDS_MENU)
        then
            chatText = L"/friend "..newName
        elseif (SocialWindow.CurrentlyShownList == SocialWindow.IGNORE_MENU)
        then
            chatText = L"/ignore "..newName
        end
        SendChatText( chatText, L"" )
    end
end

function SocialWindow.OnCancelAddMember()
    WindowSetShowing( "SocialWindowListWindowAddMemberWindow", false )
end

function SocialWindow.FriendRemove()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.currentSelectedPlayerName ~= nil and SocialWindow.currentSelectedPlayerName ~= L"")
    then
        SendChatText( L"/friendremove "..SocialWindow.currentSelectedPlayerName, L"" )
        SocialWindow.currentSelectedPlayerName = nil
    end
end

function SocialWindow.IgnoreRemove()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.currentSelectedPlayerName ~= nil and SocialWindow.currentSelectedPlayerName ~= L"")
    then
        SendChatText( L"/ignoreremove "..SocialWindow.currentSelectedPlayerName, L"" )
        SocialWindow.currentSelectedPlayerName = nil
    end
end

function SocialWindow.SendTell()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.currentSelectedPlayerName ~= nil and SocialWindow.currentSelectedPlayerName ~= L"")
    then
        local playerName = wstring.gsub( SocialWindow.currentSelectedPlayerName, L"(^.)", L"" )
        local text = L"/tell "..playerName..L" "
        EA_ChatWindow.SwitchChannelWithExistingText(text)
    end
end
function SocialWindow.InviteMemberToParty()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.currentSelectedPlayerName ~= nil and SocialWindow.currentSelectedPlayerName ~= L"")
    then
        SendChatText( L"/invite "..SocialWindow.currentSelectedPlayerName, L"" )
        SocialWindow.currentSelectedPlayerName = nil
    end
end

function SocialWindow.InviteMemberToGuild()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
    if (SocialWindow.currentSelectedPlayerName ~= nil and SocialWindow.currentSelectedPlayerName ~= L"")
    then
        SendChatText( L"/guildinvite "..SocialWindow.currentSelectedPlayerName, L"" )
        SocialWindow.currentSelectedPlayerName = nil
    end
end

function SocialWindow.ShowFriendsListContextWindow()
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_2)
    SocialWindow.CurrentlyShownList = SocialWindow.FRIENDS_MENU
    local friendsAddedSuccess = SocialWindow.AddMembersToListWindow(GetFriendsList)
    if (SocialWindow.ShowOfflineFriends == true)
    then
        WindowSetShowing("SocialWindowListWindowPlusButton", false)
        WindowSetShowing("SocialWindowListWindowMinusButton", true)
    else
        WindowSetShowing("SocialWindowListWindowPlusButton", true)
        WindowSetShowing("SocialWindowListWindowMinusButton", false)
    end
    
    if (friendsAddedSuccess == true)
    then
        LabelSetText("SocialWindowListWindowHeader", GetFormatStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_FRIENDS, {SocialWindow.numOnlineMembers, #SocialWindow.MemberListTable} ) )
        EA_Window_ContextMenu.AddUserDefinedMenuItem("SocialWindowListWindow", EA_Window_ContextMenu.CONTEXT_MENU_2)
        ScrollWindowUpdateScrollRect("SocialWindowListWindowScrollWindow")
    else
        SocialWindow.CurrentlyShownList = 0
        EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_FRIENDS_BUTTON_ADDFRIEND), SocialWindow.FriendAdd, false, true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    end
    
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2, SocialWindow.ContextSubMenuAnchor)
    
end

function SocialWindow.ShowWarbandListContextWindow()
end

function SocialWindow.ShowIgnoreListContextWindow()
    EA_Window_ContextMenu.CreateContextMenu("", EA_Window_ContextMenu.CONTEXT_MENU_2)
    SocialWindow.CurrentlyShownList = SocialWindow.IGNORE_MENU
    local ignoreAddedSuccess = SocialWindow.AddMembersToListWindow(GetIgnoreList)
    if (SocialWindow.ShowOfflineIgnores == true)
    then
        WindowSetShowing("SocialWindowListWindowPlusButton", false)
        WindowSetShowing("SocialWindowListWindowMinusButton", true)
    else
        WindowSetShowing("SocialWindowListWindowPlusButton", true)
        WindowSetShowing("SocialWindowListWindowMinusButton", false)
    end
    
    if (ignoreAddedSuccess == true)
    then
        LabelSetText("SocialWindowListWindowHeader", GetFormatStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_HEADER_IGNORES, {SocialWindow.numOnlineMembers, #SocialWindow.MemberListTable} ) )
        EA_Window_ContextMenu.AddUserDefinedMenuItem("SocialWindowListWindow", EA_Window_ContextMenu.CONTEXT_MENU_2)
        ScrollWindowUpdateScrollRect("SocialWindowListWindowScrollWindow")
    else
        SocialWindow.CurrentlyShownList = 0
        EA_Window_ContextMenu.AddMenuItem(GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_IGNORE_BUTTON_ADDIGNORE), SocialWindow.IgnoreAdd, false, true, EA_Window_ContextMenu.CONTEXT_MENU_2)
    end
    
    EA_Window_ContextMenu.Finalize(EA_Window_ContextMenu.CONTEXT_MENU_2, SocialWindow.ContextSubMenuAnchor)
end

function SocialWindow.ShowGuildListContextWindow()
end

function SocialWindow.ShowScenarioListContextWindow()
end

function SocialWindow.AddMembersToListWindow(dataPropogationFunction)
    if (dataPropogationFunction == nil or dataPropogationFunction == L"")
    then
        return false
    end
    SocialWindow.MemberListTable = dataPropogationFunction()
    
    if (SocialWindow.MemberListTable == nil or #SocialWindow.MemberListTable == 0)
    then
        return false
    end

    local widthMax, tempWidth = 0
    local x,y
    local counter = 1
    local windowName = nil
    
    
    SocialWindow.numOnlineMembers = 0
    -- Hide all of the windows created.
    for idx=1,SocialWindow.numWindowsCreated do
        windowName = "MemberList"..idx
        if (DoesWindowExist(windowName) == true)
        then
            WindowSetShowing(windowName, false)
        end
    end 
    local size = #SocialWindow.MemberListTable
    for idx=1, size do
        windowName = "MemberList"..counter
        
        if (SocialWindow.MemberListTable[idx].zoneID ~= 0)
        then
            if (DoesWindowExist(windowName) == false)
            then
                SocialWindow.numWindowsCreated = SocialWindow.numWindowsCreated + 1
                CreateWindowFromTemplate(windowName, "SocialWindowLineTemplate", "SocialWindowListWindowDetail")
                if (counter == 1)
                then
                    WindowAddAnchor( windowName, "topleft", "SocialWindowListWindowDetail", "topleft", 0, 0 )
                else
                    WindowAddAnchor( windowName, "bottomleft", "MemberList"..counter-1, "topleft", 0, 0 )
                end
            end
            WindowSetId(windowName, idx)
            
            WindowSetShowing(windowName, true)
            LabelSetText(windowName.."ZoneName", GetZoneName( SocialWindow.MemberListTable[idx].zoneID ))
            SocialWindow.numOnlineMembers = SocialWindow.numOnlineMembers + 1
            
            LabelSetText(windowName.."Name", SocialWindow.MemberListTable[idx].name)
            counter = counter + 1
        end
    end
    
    if ( (SocialWindow.CurrentlyShownList == SocialWindow.FRIENDS_MENU and SocialWindow.ShowOfflineFriends == true)
            or (SocialWindow.CurrentlyShownList == SocialWindow.IGNORE_MENU and SocialWindow.ShowOfflineIgnores == true) )
    then
        for idx=1, size do
            if (SocialWindow.MemberListTable[idx].zoneID ~= 0)
            then
                continue
            end
           windowName = "MemberList"..counter
           if (DoesWindowExist(windowName) == false)
            then
                SocialWindow.numWindowsCreated = SocialWindow.numWindowsCreated + 1
                CreateWindowFromTemplate(windowName, "SocialWindowLineTemplate", "SocialWindowListWindowDetail")
                if (counter == 1)
                then
                    WindowAddAnchor( windowName, "topleft", "SocialWindowListWindowDetail", "topleft", 0, 0 )
                else
                    WindowAddAnchor( windowName, "bottomleft", "MemberList"..counter-1, "topleft", 0, 0 )
                end
            end
            WindowSetId(windowName, idx)
            
            WindowSetShowing(windowName, true)
            LabelSetText(windowName.."ZoneName", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_WINDOW_OFFLINE) )
            SocialWindow.numOnlineMembers = SocialWindow.numOnlineMembers + 1
            
            LabelSetText(windowName.."Name", SocialWindow.MemberListTable[idx].name) 
            counter = counter + 1
        end
    end
    
    SocialWindow.AdjustContextMenuColumns()
    return true
end

function SocialWindow.AdjustContextMenuColumns()
    local greatestWidth, windowMaxWidth, tempWidth = 0
    local x,y
    if (SocialWindow.numWindowsCreated > 0)
    then
        
        for idx=1, SocialWindow.numWindowsCreated do
            local windowName = "MemberList"..idx
            x,y = WindowGetOffsetFromParent(windowName.."Name")
            tempWidth,_ = LabelGetTextDimensions(windowName.."Name")
            if (tempWidth+x > greatestWidth)
            then
                greatestWidth = tempWidth+x
            end
        end
        
        windowMaxWidth = 0
        
        -- Loop over all Line Templates to ensure that the Zone and Names are spaced uniformly
        for idx=1, SocialWindow.numWindowsCreated do
            local windowName = "MemberList"..idx
            WindowClearAnchors(windowName.."ZoneName")
            WindowAddAnchor(windowName.."ZoneName", "topleft", windowName.."Name", "topleft", greatestWidth+SocialWindow.COLUMN_SPACING, 0)
            x,y = WindowGetOffsetFromParent(windowName.."ZoneName")
            tempWidth,_ = WindowGetDimensions(windowName.."ZoneName")
            if (tempWidth+x > windowMaxWidth)
            then
                windowMaxWidth = tempWidth+x
            end
        end
        
        WindowSetDimensions("SocialWindowListWindow", windowMaxWidth+SocialWindow.ENDLINE_SCROLLBAR_SPACING, 500)
    end
end


function SocialWindow.OnMouseOverListMember()
    local windowId = WindowGetId(SystemData.MouseOverWindow.name)
    
    WindowSetShowing("SocialWindowListWindowSelection", true)
    WindowClearAnchors("SocialWindowListWindowSelection")
    WindowAddAnchor("SocialWindowListWindowSelection", "topleft", SystemData.MouseOverWindow.name, "topleft", 0, -2)
    WindowAddAnchor("SocialWindowListWindowSelection", "bottomright", SystemData.MouseOverWindow.name.."ZoneName", "bottomright", 0, 2)
    
    -- Offline members do not have information
    if (SocialWindow.MemberListTable[windowId].zoneID ~= 0)
    then
        -- Show tooltip for this member as well
        LabelSetText("SocialWindowPlayerInformationTooltipWindowCareerNameText", SocialWindow.MemberListTable[windowId].careerName)
        LabelSetText("SocialWindowPlayerInformationTooltipWindowRankText", GetFormatStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_RANKTITLE, {SocialWindow.MemberListTable[windowId].rank}) )
        local iconId = Icons.GetCareerIconIDFromCareerNamesID(SocialWindow.MemberListTable[windowId].careerID)
        local texture, x, y = GetIconData(iconId)
        DynamicImageSetTexture("SocialWindowPlayerInformationTooltipWindowCareerIcon", texture, x, y)
        WindowClearAnchors("SocialWindowPlayerInformationTooltipWindow")
        WindowAddAnchor("SocialWindowPlayerInformationTooltipWindow", "topright", "SocialWindowListWindowSelection", "topleft", 10+SocialWindow.ENDLINE_SCROLLBAR_SPACING, 0)
        
        local tooltipWindow = "SocialWindowPlayerInformationTooltipWindow"
        local itemSetSizeData = {}
        local width = 0
        local height = 0
        itemSetSizeData[tooltipWindow.."CareerIcon"]         = { minHeight = 0 }
        itemSetSizeData[tooltipWindow.."CareerNameText"]     = { minHeight = 0 }
        itemSetSizeData[tooltipWindow.."RankText"]           = { minHeight = 0 }
        for labelName, sizeData in pairs (itemSetSizeData) do
            x, y = WindowGetOffsetFromParent(labelName)
            
            local sizeX, sizeY = WindowGetDimensions (labelName)
           
            if ((y+sizeY) > height) then
                height = (y+sizeY)
            end
            
            if ((x + sizeX) > width) then
                width = (x+sizeX)
            end
        end
        WindowSetDimensions("SocialWindowPlayerInformationTooltipWindow", width+10, height)
        WindowSetShowing("SocialWindowPlayerInformationTooltipWindow", true)
    end
    
end

function SocialWindow.OnMouseOverEndListMember()
    WindowSetShowing("SocialWindowListWindowSelection", false)
    -- Hide tooltip here as well
    WindowSetShowing("SocialWindowPlayerInformationTooltipWindow", false)
end

function SocialWindow.HideSelectionBorder()
    WindowSetShowing("SocialWindowListWindowSelection", false)
    -- Hide tooltip as well
    WindowSetShowing("SocialWindowPlayerInformationTooltipWindow", false)
end

function SocialWindow.OnLButtonUpListMember()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
end

function SocialWindow.OnRButtonUpListMember()
    -- Show context menu
    local windowId = WindowGetId(SystemData.ActiveWindow.name)
    SocialWindow.currentSelectedPlayerName = SocialWindow.MemberListTable[windowId].name
    SocialWindow.currentSelectedPlayerId = windowId
    SocialWindow.ShowPlayerContextMenuWindow()
end

function SocialWindow.OnListWindowLButtonUp()
    EA_Window_ContextMenu.Hide(EA_Window_ContextMenu.CONTEXT_MENU_3)
end
-- End Context Menu Functions


function SocialWindow.Hide()
    --BroadcastEvent( SystemData.Events.TOGGLE_SOCIAL_WINDOW )
    WindowSetShowing( "SocialWindow", false )
end

function SocialWindow.OnHidden()
    WindowUtils.OnHidden()
    SocialWindowTabFriends.ResetEditBoxes()
    SocialWindowTabIgnore.ResetEditBoxes()
    WindowAssignFocus("SocialWindow", false)
end

function SocialWindow.OnShown()
    WindowUtils.OnShown(SocialWindow.Hide, WindowUtils.Cascade.MODE_AUTOMATIC)
end

function SocialWindow.OnKeyEscape()
    SocialWindowTabSearch.OnKeyEscape()
    SocialWindowTabFriends.OnKeyEscape()
    SocialWindowTabIgnore.OnKeyEscape()
    SocialWindowTabOptions.OnKeyEscape()
    SocialWindow.Hide()
end

---------------------------------------
-- Tab Controls
---------------------------------------

function SocialWindow.ShowTab( tabIndex )

    SocialWindow.SelectedTab = tabIndex
    
    for index, tabData in ipairs( SocialWindow.tabs )
    do        
        ButtonSetPressedFlag( tabData.buttonName, index == tabIndex )
        WindowSetShowing( tabData.windowName, index == tabIndex )
    end
end


function SocialWindow.OnSearchUpdated()
    SocialWindowTabSearch.OnSearchUpdated()
end

function SocialWindow.OnOptionsUpdated()
    SocialWindowTabOptions.OnOptionsUpdated()
end


function SocialWindow.OnMouseOverTab()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip (windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetStringFromTable( "SocialStrings", SocialWindow.TabTooltips[windowIndex]) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize ()
    
    local anchor = { Point="bottom", RelativeTo=windowName, RelativePoint="top", XOffset=0, YOffset=32 }
    Tooltips.AnchorTooltip (anchor)
    Tooltips.SetTooltipAlpha (1)
end

function SocialWindow.OnMouseOverEndTab()

end

function SocialWindow.OnLButonTab()
    local tabNumber	= WindowGetId (SystemData.ActiveWindow.name)
    SocialWindow.ShowTab(tabNumber)
end



---------------------------------------
-- Util Functions
---------------------------------------
function SocialWindow.IsPlayerOnFriendsList( playerName )
    return SocialWindowTabFriends.IsPlayerFriend( playerName )
end

function SocialWindow.IsPlayerOnIgnoreList( playerName )

    for _, playerData in ipairs( SocialWindowTabIgnore.playerListData )
    do
        if( WStringsCompareIgnoreGrammer( playerName, playerData.name) == 0 )
        then
            return true  
        end
    end
    
    return false
end