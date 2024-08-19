----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

local PARENT_WINDOW = "SocialWindowBuddyList"

local TAB_FRIENDS		= 1
local TABS_MAX_NUMBER	= 1
local SelectedTab		= 0

local CurrentlyShownList = 0
local FRIENDS_MENU  = 1

local tabs = 
{
    [TAB_FRIENDS] = { windowName=PARENT_WINDOW.."TabFriends",   buttonName=PARENT_WINDOW.."ViewMode1", listId=FRIENDS_MENU,
                      tooltip=StringTables.Social.TOOLTIP_SOCIAL_TAB_FRIENDS,   title=StringTables.Social.LABEL_BUDDY_LIST_FRIENDS_TITLE,
                      tabClass=SocialWindowBuddyListTabFriends},
}
                      
                      
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowBuddyList = {}

SocialWindowBuddyList.filters = {}

SocialWindowBuddyList.ICON_FRIEND     = 66

----------------------------------------------------------------
-- SocialWindowBuddyList Functions
----------------------------------------------------------------
-- OnInitialize Handler
function SocialWindowBuddyList.Initialize()
    WindowRegisterEventHandler( PARENT_WINDOW, SystemData.Events.TOGGLE_SOCIAL_WINDOW, "SocialWindowBuddyList.ToggleSocialWindows")
    for index = 1, TABS_MAX_NUMBER 
    do
        ButtonSetStayDownFlag( PARENT_WINDOW.."ViewMode"..index, true )
    end
    
    local texture, x, y = GetIconData( SocialWindowBuddyList.ICON_FRIEND )
    DynamicImageSetTexture( PARENT_WINDOW.."ViewMode1Image", texture, x, y )
    
    -- bottom buttons
    ButtonSetText (PARENT_WINDOW.."SearchButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_BUDDY_LIST_SEARCH_BUTTON) )
    WindowSetId(PARENT_WINDOW.."SearchButton", StringTables.Social.TOOLTIP_BUDDY_LIST_SEARCH_BUTTON)
    
    WindowSetId(PARENT_WINDOW.."FilterMenuButton", StringTables.Social.TOOLTIP_BUDDY_LIST_FILTER_MENU_BUTTON)
  
    SocialWindowBuddyList.ShowTab(TAB_FRIENDS)
end


-- OnShutdown Handler
function SocialWindowBuddyList.Shutdown()
    
end

function SocialWindowBuddyList.ToggleSocialWindows() 
    local bAnyShowing = WindowGetShowing( PARENT_WINDOW ) or WindowGetShowing( "SocialWindow" )
    
    if ( bAnyShowing )
    then
        WindowSetShowing( "SocialWindow", false )
        WindowSetShowing( PARENT_WINDOW, false )
    else
        local windowToShow = PARENT_WINDOW
        if SocialWindowTabOptions.Settings.disableBuddyList
        then
            windowToShow = "SocialWindow" -- if they've set a preference to not use the buddy list, go back to just showing the old window on toggle
        end
        WindowSetShowing( windowToShow, true )
    end
end

function SocialWindowBuddyList.Hide()
    WindowSetShowing( PARENT_WINDOW, false)
end

function SocialWindowBuddyList.OnHidden()
    WindowSetShowing( "SocialWindowBuddyListFilterMenu", false)
end

---------------------------------------
-- Tab Controls
---------------------------------------

function SocialWindowBuddyList.ShowTab( tabIndex )

    SelectedTab = tabIndex
    
    for index, tabData in ipairs( tabs )
    do        
        ButtonSetPressedFlag( tabData.buttonName, index == tabIndex )
        WindowSetShowing( tabData.windowName, index == tabIndex )
    end
    
    LabelSetText(PARENT_WINDOW.."SectionTitle", GetStringFromTable( "SocialStrings", tabs[tabIndex].title) )
    
    SocialWindowBuddyList.filters = {}
    if tabs[SelectedTab].tabClass.Settings and tabs[SelectedTab].tabClass.Settings.filters
    then
        SocialWindowBuddyList.filters = tabs[SelectedTab].tabClass.Settings.filters
    end
    SocialWindowBuddyList.RefreshFilterMenu()
end

function SocialWindowBuddyList.OnMouseOverTab()
    local windowName	= SystemData.ActiveWindow.name
    local windowIndex	= WindowGetId (windowName)

    Tooltips.CreateTextOnlyTooltip(windowName, nil)
    Tooltips.SetTooltipText (1, 1, GetStringFromTable( "SocialStrings", tabs[windowIndex].tooltip) )
    Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)	
    Tooltips.Finalize()
    
    local anchor = { Point="bottom", RelativeTo=windowName, RelativePoint="top", XOffset=0, YOffset=32 }
    Tooltips.AnchorTooltip(anchor)
    Tooltips.SetTooltipAlpha (1)
end

function SocialWindowBuddyList.OnLButtonUpTab()
    WindowSetMoving( PARENT_WINDOW , false )
end

function SocialWindowBuddyList.OnLButtonDownTab()
    WindowSetMoving( PARENT_WINDOW , true )
    local tabNumber	= WindowGetId(SystemData.ActiveWindow.name)
    SocialWindowBuddyList.ShowTab(tabNumber)
end

function SocialWindowBuddyList.OnKeyEscape()
    -- do not close the buddy list on escape
end

function SocialWindowBuddyList.ShowSocial()
    WindowUtils.ToggleShowing( "SocialWindow" )
end



-- EventHandler for when the user mouses over an element that has an ID set to a tooltip for easy lookup
function SocialWindowBuddyList.OnMouseOverTooltipElement()
    local windowName	= SystemData.ActiveWindow.name
    local windowID	= WindowGetId(windowName)
    
    if windowID ~= 0
    then
        SocialWindowBuddyList.CreateAutoTooltip(windowID, windowName)
    end
end

-- Creates the default automatic tooltip for Settings window elements that have a 
-- tooltip string ID set
function SocialWindowBuddyList.CreateAutoTooltip(stringID, windowName)
    if stringID ~= nil and stringID ~= 0 and windowName ~= nil
    then
        Tooltips.CreateTextOnlyTooltip( windowName, GetStringFromTable( "SocialStrings", stringID ) )
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_TOP)
    end
end
    
function SocialWindowBuddyList.OnRButtonUp()
    EA_Window_ContextMenu.CreateDefaultContextMenu( PARENT_WINDOW )
end

----------------------------------------------------------------
-- Buddy List Filter Menu
----------------------------------------------------------------
function SocialWindowBuddyList.RefreshFilterMenu()
    -- Display everything
    local displayOrder = {}
    for index, _ in ipairs( SocialWindowBuddyList.filters )
    do
        table.insert(displayOrder, index)
    end
    if DoesWindowExist("SocialWindowBuddyListFilterMenuList")
    then
        ListBoxSetDisplayOrder("SocialWindowBuddyListFilterMenuList", displayOrder)
    end
end

-- Post process the list.
function SocialWindowBuddyList.PopulateFilterList()
    for row, data in ipairs(SocialWindowBuddyListFilterMenuList.PopulatorIndices)
    do
        local filterData  = SocialWindowBuddyList.filters[data]
        local rowFrame    = "SocialWindowBuddyListFilterMenuListRow"..row
        local buttonFrame = rowFrame.."Button"
        local labelFrame  = rowFrame.."Label"

        -- Label the button
        LabelSetText(labelFrame, GetStringFromTable("SocialStrings", SocialWindowBuddyListTabFriends.filterLabels[data] ))
        
        -- Set up the check button state
        ButtonSetCheckButtonFlag(buttonFrame, true)
        
        ButtonSetPressedFlag(buttonFrame, filterData.enabled)   
    end
end

function SocialWindowBuddyList.ToggleFilterMenu()
    WindowUtils.ToggleShowing( "SocialWindowBuddyListFilterMenu" )
end

function SocialWindowBuddyList.ToggleFilter()
    if tabs[SelectedTab] and tabs[SelectedTab].tabClass.ToggleFilter
    then
        tabs[SelectedTab].tabClass.ToggleFilter()
    end
end
