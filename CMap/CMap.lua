----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

CMapWindow = {}
CMapWindow.ZoneControlData = { }
CMapWindow.activateZoom    = true
----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------

--local CMapWindow.VisSettings[CFG_ZOOM].zoomlevel = 0.5

local updCoord = false
local TIME_DELAY = 0.1
local timeLeft = TIME_DELAY
                  

local WindowName = "CMapWindow"


local MAP = "MapDisplay"
local WMAP = "WMap"
local ZOOMSLD = "ZoomSlider"
local INFLUENCE = "Digitinf"
local PINFILTER = "FilterMenuButton"
local WMPBUTTON = "MapWorldMapButton"
local CITYRATE = "CityRating"
local AREANAME = "AreaNameText"
local MAILBTN = "MapMailNotificationIcon"
local SCNSUMM = "ScenarioSummaryButton"
local SCNQUEUE = "MapScenarioQueue"
local SCNGRP = "ScenarioGroupButton"
local BACKGROUND = "Background"
local RVRINDICATOR = "RvRFlagIndicator"
local RALLYCALL = "MapRallyCall"
local EVENT = "OverheadCurrentEvents"
-- added ranked Bset
local RANKED = "RoR_RankedLeaderboard"



local AWName = WindowName..MAP
local BWName = WindowName..WMAP

local TYPEBGWINDOW = 5
local TYPEMAINWINDOW = 4
local TYPEWINDOW = 1
local TYPESETTING = 2
local TYPEPIN = 3
local TYPEEXTERN = 44
local TYPESTATICSETTING;


----------------------------------------------------------------
-- settingvars
----------------------------------------------------------------
local CFG_AREA = "showonlyareaname"
local CFG_MAIL = "showmailicon"
local CFG_WINDOWS = "showwindowconfig"
local CFG_INF = "showinfluence"
local CFG_DEBUG = "debug"
local CFG_ZOOM ="showzoombuttons"
local CFG_CITY = "showcityrating"
local CFG_BORDER = "bordersize"
local CFG_RESET = "reset"
local CFG_VERSATZ = "offset"
local CFG_EVENT = "eventnote"

local CFG_RVRINDI = "showrvrindicator"

local PINFILTERS = "Pinfilter"
local PINGUTTERS = "Pingutter"


local dbg = false


----------------------------------------------------------------
-- Default Settings
----------------------------------------------------------------

function CMapWindow.CMapGetSettings()

	CMapWindow.VisSettings = {}
	CMapWindow.VisSettings[MAP] = {visible=true,point="topleft",rpoint="topleft",rto=WindowName,x=0,y=0,type=TYPEMAINWINDOW}
	CMapWindow.VisSettings[BACKGROUND] = {visible=true,alpha=0.8,red=20,green=20,blue=20,point="topleft",rpoint="topleft",rto=WindowName,x=0,y=0,type=TYPEBGWINDOW}
	CMapWindow.VisSettings[WMAP] = {visible=false,point="topleft",rpoint="topleft",rto=WindowName,x=0,y=0,type=TYPEMAINWINDOW}
	CMapWindow.VisSettings[RVRINDICATOR] = {visible=false,point="bottomleft",rpoint="bottomleft",rto=AWName,x=-1,y=-30,type=TYPEWINDOW}
	CMapWindow.VisSettings[RALLYCALL] = {visible=true,point="topleft",rpoint="topleft",rto=AWName,x=-1,y=30,type=TYPEWINDOW}
	CMapWindow.VisSettings[ZOOMSLD] = {visible=false,point="bottomleft",rpoint="bottomleft",rto=AWName,x=20,y=-2,type=TYPEWINDOW}
	CMapWindow.VisSettings[INFLUENCE] = {visible=true,point="bottom",rpoint="bottom",rto=AWName,x=0,y=0,type=TYPEWINDOW}
	CMapWindow.VisSettings[PINFILTER] = {visible=true,point="bottomleft",rpoint="bottomleft",rto=AWName,x=0,y=0,type=TYPEWINDOW}
	CMapWindow.VisSettings[WMPBUTTON] = {visible=true,point="bottomright",rpoint="bottomright",rto=AWName,x=0,y=0,type=TYPEWINDOW}
	CMapWindow.VisSettings[CITYRATE] = {visible=false,point="top",rpoint="top",rto=AWName,x=0,y=0,type=TYPEWINDOW}
	CMapWindow.VisSettings[AREANAME] = {visible=true,point="top",rpoint="top",rto=AWName,x=0,y=-30,type=TYPEWINDOW}
	CMapWindow.VisSettings[MAILBTN] = {visible=false,point="topright",rpoint="topright",rto=AWName,x=-5,y=5,type=TYPEWINDOW}
	CMapWindow.VisSettings[SCNSUMM] = {visible=false,point="topleft",rpoint="topleft",rto=AWName,x=-1,y=-1,type=TYPEWINDOW}
	CMapWindow.VisSettings[SCNQUEUE] = {visible=true,point="topleft",rpoint="topleft",rto=AWName,x=-1,y=-1,type=TYPEWINDOW}
	CMapWindow.VisSettings[SCNGRP] = {visible=false,point="left",rpoint="left",rto=AWName,x=0,y=0,type=TYPEWINDOW}
    CMapWindow.VisSettings[EVENT] = {visible=true,point="topleft",rpoint="topleft",rto=AWName,x=-1,y=60,type=TYPEWINDOW}
	CMapWindow.VisSettings[CFG_BORDER] = {value=5,descr="Number defines the bordersize",type=TYPESETTING,dtype="number"}
	CMapWindow.VisSettings[CFG_AREA] = {value=3,descr="True shows only the Zonename [1] the Areaname[2] or both [3] or off[4]",type=TYPESETTING,dtype="number"}
	CMapWindow.VisSettings[CFG_DEBUG] = {value=false,descr="Switches the debug output [true] or [false]",type=TYPESETTING,dtype="boolean"}
	CMapWindow.VisSettings[CFG_WINDOWS] = {value=false,descr="Shows or hide the windowconfiguration [true] or [false]",type=TYPESETTING,dtype="boolean"}
	CMapWindow.VisSettings[CFG_MAIL] = {value=true,descr="Switches the MailIcon visibility [true] or [false]",type=TYPESETTING,dtype="boolean"}
	CMapWindow.VisSettings[CFG_INF] = {value=true,descr="Switches the InfluenceArea visibility [true] or [false]",type=TYPESETTING,dtype="boolean"}
	CMapWindow.VisSettings[CFG_ZOOM] = {value=false,zoomlevel=0.5,descr="Switches the Zoombuttons visibility [true] or [false]",type=TYPESETTING,dtype="boolean"}
	CMapWindow.VisSettings[CFG_CITY] = {value=true,descr="Switches the Cityratings visibility [true] or [false]",type=TYPESETTING,dtype="boolean"}          
	CMapWindow.VisSettings[CFG_RESET] = {value=true,descr="resets all settings",type=TYPESETTING,dtype="boolean"} 
	CMapWindow.VisSettings[CFG_RVRINDI] = {value=false,descr="false hide the rvr indicator permanently",type=TYPESETTING,dtype="boolean"} 
	CMapWindow.VisSettings[CFG_EVENT] = {value=true,descr="false hide the event sheet permanently",type=TYPESETTING,dtype="boolean"} 
	
	         
	CMapWindow.VisSettings[CFG_VERSATZ] = {value=30,descr="general offset",type=TYPESETTING,dtype="number"}          
	
	CMapWindow.VisSettings[PINFILTERS] ={type=TYPEPIN}

    if ( CMapWindow.VisSettings[PINGUTTERS] == nil )
    then
        CMapWindow.VisSettings[PINGUTTERS] = {}
    end

	for index, pipType in pairs( SystemData.MapPips ) do
	    if CMapWindow.VisSettings[PINFILTERS][pipType] == nil then
	        CMapWindow.VisSettings[PINFILTERS][pipType] = true
	        CMapWindow.VisSettings[PINGUTTERS][pipType] = true
	    end
	end
 
	dbg = CMapWindow.VisSettings[CFG_DEBUG].value 
	x=dbg and d("dosettings")
end

CMapWindow.CMapGetSettings()
----------------------------------------------------------------
-- Bad Ideas
----------------------------------------------------------------
CMapWindow.INSTANCETYPE_SCENARIO = 3
CMapWindow.INSTANCETYPE_CITY = 4

----------------------------------------------------------------
-- Map Pin Filter to Map Pin lookup table
----------------------------------------------------------------
CMapWindow.NUM_PIN_FILTER_COLUMNS = 2
CMapWindow.mapPinFilters =
{
   { label=StringTables.MapPinFilterNames.FILTER_TYPE_WAYPOINT,           slice="Waypoint-Large",              scale=1.0,  pins={ SystemData.MapPips.QUEST_AREA, SystemData.MapPips.LIVE_EVENT_WAYPOINT }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_PUBLIC_QUEST,       slice="PQ-Large",                    scale=1.0,  pins={ SystemData.MapPips.PUBLIC_QUEST }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_QUESTS,             slice="QuestCompleted-Gold",         scale=1.0,  pins={ SystemData.MapPips.QUEST_OFFER_NPC, SystemData.MapPips.REPEATABLE_QUEST_OFFER_NPC, SystemData.MapPips.LIVE_EVENT_QUEST_OFFER_NPC, SystemData.MapPips.QUEST_PENDING_NPC, SystemData.MapPips.QUEST_COMPLETE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_KILL_COLLECTOR,     slice="KillCollector",               scale=1.0,  pins={ SystemData.MapPips.KILL_COLLECTOR_QUEST_PENDING_NPC, SystemData.MapPips.KILL_COLLECTOR_QUEST_COMPLETE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_MERCHANT,           slice="NPC-Merchant",                scale=1.0,  pins={ SystemData.MapPips.STORE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_TRAINERS,           slice="NPC-TrainerActive",           scale=1.0,  pins={ SystemData.MapPips.TRAINER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_BINDER,             slice="NPC-Binder",                  scale=1.1,  pins={ SystemData.MapPips.BINDER_NPC, SystemData.MapPips.INFLUENCE_REWARDS_NPC, SystemData.MapPips.INFLUENCE_REWARDS_PENDING_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_MAILBOX,            slice="Mail-Large",                  scale=1.0,  pins={ SystemData.MapPips.MAILBOX }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_TRAVEL,             slice="NPC-Travel",                  scale=1.0,  pins={ SystemData.MapPips.TRAVEL_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_HEALER,             slice="NPC-Healer-Large",            scale=1.0,  pins={ SystemData.MapPips.HEALER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_VAULT,              slice="Vault",                       scale=1.0,  pins={ SystemData.MapPips.VAULT_KEEPER_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_AUCTION,            slice="Auctioneer",                  scale=1.0,  pins={ SystemData.MapPips.AUCTION_HOUSE_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_GUILD_REGISTRATION, slice="NPC-GuildRegistrar-Large",    scale=1.0,  pins={ SystemData.MapPips.GUILD_REGISTRAR_NPC }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_LASTNAME,           slice="LastNames-Large",             scale=1.0,  pins={ SystemData.MapPips.MERCHANT_LASTNAME }, },

}

CMapWindow.mapPinGutters =
{
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_OBJECTIVE,          slice="FlagNeutral",                 scale=1.0,  pins={ SystemData.MapPips.OBJECTIVE }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_KEEP,               slice="Keep-Grayed",                 scale=0.75, pins={ SystemData.MapPips.KEEP }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_GROUP_MEMBER,       slice="PlayerCircleGroupmate",       scale=1.75, pins={ SystemData.MapPips.GROUP_MEMBER }, },
    { label=StringTables.MapPinFilterNames.FILTER_TYPE_IMPORTANT_MONSTER,  slice="BombNeutral",                 scale=1.0,  pins={ SystemData.MapPips.IMPORTANT_MONSTER }, },
}

 ----------------------------------------------------------------
-- Setting Functions
----------------------------------------------------------------



local function print(txt)
	 TextLogAddEntry("Chat", 0, towstring(txt))
end

local function bts(bool,art)

    if (bool == nil) then return "nil" end
    if (art == "string" and type(bool)~="string") then return tostring(bool) end
    if (art == "number" and type(bool)~="number") then return tonumber(bool) end
    if (art == "boolean" and bool == "true") then return true end
    if (art == "boolean" and bool == "false") then return false end
    return bool

end


function CMapWindow.ResetSettings()
   CMapWindow.Settings = nil
   CMapWindow.CMapGetSettings()
   CMapWindow.CMapUseSettings()
end

function CMapWindow.ResetVisSettings()
   CMapWindow.VisSettings = nil
   CMapWindow.CMapGetSettings()
   CMapWindow.CMapUseSettings()
   return "done"
end



function CMapWindow.CMapUseSettings()
         
        
        dbg = CMapWindow.VisSettings[CFG_DEBUG].value
        x=dbg and d("UseSettings")

        for index, pipType in pairs( CMapWindow.VisSettings[PINFILTERS] ) do
			if index ~= "type" then 
            	MapSetPinFilter("CMapWindowMapDisplay", index, pipType )
			end
        end
        for index, pipType in pairs( CMapWindow.VisSettings[PINGUTTERS] ) do
			if index ~= "type" then 
            	MapSetPinGutter("CMapWindowMapDisplay", index, pipType )
			end
        end

        for k,v in pairs(CMapWindow.VisSettings) do
            local border = 0
            local versatz = 0

            if v.type == TYPEWINDOW or  v.type == TYPEMAINWINDOW or  v.type == TYPEBGWINDOW or  v.type == TYPEEXTERN then
                    local window = WindowName..k
                    if v.type == TYPEEXTERN then 
						window = k 
						WindowSetParent(window,WindowName)
						WindowSetScale(window, 0.4)
						WindowSetLayer(window,4)
					end
                    x=dbg and d("window",k,v)
                    
                    
                    if v.type == TYPEBGWINDOW then 
                        border = CMapWindow.VisSettings[CFG_BORDER].value
                        WindowSetTintColor( window, v.red, v.green, v.blue ); 
                        WindowSetAlpha( window, v.alpha ); 
                    end
                    if v.type == TYPEBGWINDOW or v.type == TYPEMAINWINDOW then versatz = CMapWindow.VisSettings[CFG_VERSATZ].value end 

                    WindowClearAnchors(window)
                    x=dbg and d("anchor1",(v.x-border),(v.y-border+versatz))
                    WindowAddAnchor(window, v.point, v.rto, v.rpoint, (v.x-border),(v.y-border+versatz) )
                    
                    if v.type == TYPEMAINWINDOW or v.type == TYPEBGWINDOW then
                      x=dbg and d("anchor2 --> border",v.x+border,v.y-30+border+versatz)
                      WindowAddAnchor(window, "bottomright", v.rto, "bottomright", (v.x+border),(v.y-30+border+versatz) ) 

                    end 



                WindowSetShowing(window, v.visible )

            end


        end
        CMapWindow.OnAreaNameChange()
        CMapWindow.SlideZoom()
        CMapWindow.UpdateZoomButtons()


end
----------------------------------------------------------------
-- Standard Window Functions
----------------------------------------------------------------



-- OnInitialize Handler
function CMapWindow.Initialize()
    x=dbg and d("initialise")
    
    -- Register this window for movement with the Layout Editor
    LayoutEditor.RegisterWindow( "CMapWindow",L"CustomMap", L"Nephrath s Custom Map Addon", false, false, true, nil )
    --WindowRegisterEventHandler( "CMapWindow", SystemData.Events.WORLD_MAP_POINTS_UPDATED,           "CMapWindow.UpdatePoints")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.TOGGLE_WORLD_MAP_WINDOW,            "CMapWindow.ToggleWorldMapWindow")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.LOADING_END,                        "CMapWindow.UpdateMap" )
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.TOGGLE_SCENARIO_SUMMARY_WINDOW,     "CMapWindow.ToggleScenarioSummaryWindow")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.SCENARIO_BEGIN,                     "CMapWindow.UpdateScenarioButtons")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.SCENARIO_END,                       "CMapWindow.UpdateScenarioButtons")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PLAYER_RVR_FLAG_UPDATED,            "CMapWindow.OnRvRFlagUpdated")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED,      "CMapWindow.UpdateScenarioQueueButton")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PLAYER_AREA_NAME_CHANGED,           "CMapWindow.OnAreaNameChange" )
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PLAYER_ZONE_CHANGED,                "CMapWindow.OnZoneChange" )
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PLAYER_CHAPTER_UPDATED  ,           "CMapWindow.UpdateInfluenceBar" )
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.INTERFACE_RELOADED,                 "CMapWindow.UpdateMailIcon")
    --WindowRegisterEventHandler( "CMapWindow", SystemData.Events.WORLD_RVR_STATUS_UPDATED,         "CMapWindow.UpdateZoneControl")

    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PLAYER_INFLUENCE_UPDATED,           "CMapWindow.UpdateInfluenceBar" )
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PUBLIC_QUEST_ADDED,                 "CMapWindow.UpdateInfluenceBar")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PUBLIC_QUEST_UPDATED,               "CMapWindow.UpdateInfluenceBar")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.PUBLIC_QUEST_REMOVED,               "CMapWindow.UpdateInfluenceBar")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.MAILBOX_UNREAD_COUNT_CHANGED,       "CMapWindow.UpdateMailIcon")
    WindowRegisterEventHandler( "CMapWindow", SystemData.Events.CURRENT_EVENTS_LIST_UPDATED, "CMapWindow.OnEventsUpdated" )
    CMapWindow.OnEventsUpdated( CurrentEventsGetList() )

    --WindowRegisterEventHandler( "EA_Window_WorldMap", EA_Window_WorldMap.OnLButtonUp, "EA_Window_WorldMap.Hide")

    ButtonSetStayDownFlag( "CMapWindowMapWorldMapButton", true )

    CreateMapInstance( "CMapWindowMapDisplay", SystemData.MapTypes.OVERHEAD )
    CreateMapInstance("CMapWindowWMap", SystemData.MapTypes.NORMAL)
    CMapWindow.UpdateMap()

    EA_Window_OverheadMap.ToggleWorldMapWindow = function() return end
	EA_Window_OverheadMap.ToggleScenarioSummaryWindow = function() return end

    WindowUtils.AddWindowStateButton( "CMapWindowMapWorldMapButton", "CmapWindow_WorldMap" )
    WindowUtils.AddWindowStateButton( "CMapWindowScenarioSummaryButton", "ScenarioSummaryWindow" )

    WindowSetShowing("CMapWindow", true )
    WindowSetShowing("CMapWindowResize", true )
    CMapWindow.CMapUseSettings()
    CMapWindow.UpdateScenarioButtons()
    CMapWindow.OnZoneChange()
    CMapWindow.UpdateScenarioQueueButton()
    CMapWindow.UpdateZoomButtons()
    CMapWindow.RefreshMapPointFilterMenu()
    CMapWindow.UpdateInfluenceBar()
    CMapWindow.UpdateMailIcon()
    CMapWindow.OnRvRFlagUpdated()
        	-- Register slash handlers
	if LibSlash.IsSlashCmdRegistered("cmap") then
		print(L"".."Warning: something else seems to be using /cmap - CustomMap won't be able to. Use /custommap instead.")
	else
		LibSlash.RegisterSlashCmd("cmap", function(input) CMapWindow.SlashHandler(input) end)
    end

    LibSlash.RegisterSlashCmd("custommap", function(input) CMapWindow.SlashHandler(input) end)

    print("[CustomMap] loaded. use /cmap or /custommap  to configure. ")


   if DoesWindowExist("RoR_RankedLeaderboard_Toggler") then WindowSetShowing("RoR_RankedLeaderboard_Toggler", false) end
   --WindowSetShowing("RoR_RankedLeaderboard_Toggler", false)

    if not Enemy then
        DestroyWindow("CMapWindowMapEnemy") 
    end
end

function CMapWindow.UpdateMap()
    MapSetMapView( "CMapWindowMapDisplay", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
    MapSetMapView( "CMapWindowWMap", GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
    if DoesWindowExist("RoR_RankedLeaderboard_Toggler") then WindowSetShowing("RoR_RankedLeaderboard_Toggler", false) end
end

-- OnShutdown Handler
function CMapWindow.Shutdown()
    RemoveMapInstance( "CMapWindowMapDisplay" )
    RemoveMapInstance( "CMapWindowWMap" )
end



function CMapWindow.WmapOver()
         updCoordWMap = true
         --WindowRegisterEventHandler( BWName, "OnUpdate",           "CMapWindow.UpdateCoordinates")
end

function CMapWindow.WmapOverEnd()
         updCoordWMap = false
         CMapWindow.OnAreaNameChange()
         --WindowUnregisterEventHandler( BWName, "OnUpdate",           "CMapWindow.UpdateCoordinates")
end

function CMapWindow.MapOver()
         updCoordMap = true
         --WindowRegisterEventHandler( BWName, "OnUpdate",           "CMapWindow.UpdateCoordinates")
end

function CMapWindow.MapOverEnd()
         updCoordMap = false
         CMapWindow.OnAreaNameChange()
         --WindowUnregisterEventHandler( BWName, "OnUpdate",           "CMapWindow.UpdateCoordinates")
end


function CMapWindow.OnRvRFlagUpdated()

    WindowSetShowing( "CMapWindowRvRFlagIndicator", (GameData.Player.rvrPermaFlagged or GameData.Player.rvrZoneFlagged) and CMapWindow.VisSettings[CFG_RVRINDI].value)
    d("OnRvRFlagUpdated",CFG_RVRINDI)
    if (bUnflagCountdownStarted == true) then
        if (GameData.Player.rvrPermaFlagged == false) then
            WindowStopAlphaAnimation( "CMapWindowRvRFlagIndicator" )
            bUnflagCountdownStarted = false
        end
    else
        WindowStopAlphaAnimation( "CMapWindowRvRFlagIndicator" )
    end
    WindowSetShowing( "PlayerWindowRvRFlagCountDown", false )
    CMapWindow.UpdateScenarioButtons()
end

function CMapWindow.OnRallyCallLButtonUp()
-- If button is active > put up popup -> wanna join?
    if( WindowGetShowing( "CMapWindowMapRallyCallGlowAnim" ) )
    then
        --DEBUG(L"Joining Rally CAll")
        BroadcastEvent( SystemData.Events.RALLY_CALL_JOIN )
    else
        -- do nothing
    end
end

function CMapWindow.OnMouseoverRallyCall()
-- make tooltip
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    local row = 1
    local column = 1
    if( WindowGetShowing( "CMapWindowMapRallyCallGlowAnim" ) )
    then
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TOOLTIP_RALLY_CALL_ACTIVE ) )
    else
        Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.TOOLTIP_RALLY_CALL_INACTIVE ) )
    end   
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)   
    
end

function CMapWindow.ActivateRallyCall()
-- start it animating
    WindowSetShowing( "CMapWindowMapRallyCallGlowAnim", true )
    AnimatedImageStartAnimation( "CMapWindowMapRallyCallGlowAnim", 0, true, false, 0.0 )
    CMapWindow.currentTimerTime = CMapWindow.RALLY_CALL_TIMER
end

function CMapWindow.DeactivateRallyCall()
-- stop animating
    --DEBUG(L"DEACTIVATING RALLY CALL")
    WindowSetShowing( "CMapWindowMapRallyCallGlowAnim", false )
    AnimatedImageStopAnimation( "CMapWindowMapRallyCallGlowAnim")
end

function CMapWindow.UpdateRallyTimer( timePassed )
    if( CMapWindow.currentTimerTime > 0 )
    then
        CMapWindow.currentTimerTime = CMapWindow.currentTimerTime - timePassed
        if( CMapWindow.currentTimerTime <= 0 )
        then
            CMapWindow.currentTimerTime = 0
            CMapWindow.DeactivateRallyCall()
        end
    end
end

function CMapWindow.OnMouseoverRvRIndicator()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetString( StringTables.Default.TOOLTIP_RVR_INDICATOR  ) )    
    Tooltips.AnchorTooltip( PLAYERWINDOW_TOOLTIP_ANCHOR )
end

function CMapWindow.OnLButtonDown()
    -- Handle L Button Down so clicks don't go through to the world..
end


function CMapWindow.OnMouseOverPoint( )
    Tooltips.CreateMapPointTooltip( "CMapWindowMapDisplay", CMapWindowMapDisplay.MouseoverPoints, Tooltips.ANCHOR_CURSOR_LEFT )
end

function CMapWindow.OnClickMap( )
    MapUtils.ClickMap( "CMapWindowMapDisplay", CMapWindowMapDisplay.MouseoverPoints )
end


function CMapWindow.ToggleWorldMapWindowX()
    WindowUtils.ToggleShowing( BWName )
end

function CMapWindow.ToggleWorldMapWindow()
    WindowUtils.ToggleShowing("EA_Window_WorldMap")
end

function CMapWindow.OnMouseoverWorldMapBtn()
    WindowUtils.OnMouseOverButton( GetString( StringTables.Default.LABEL_WORLD_MAP ), KeyUtils.GetFirstBindingNameForAction( "TOGGLE_WORLD_MAP_WINDOW" ) )

    --Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )

    --local row = 1
    --local column = 1
    --Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_WORLD_MAP ) )

    --column = column + 1
    --Tooltips.SetTooltipColor( row, column, 140, 100, 0 )
    --Tooltips.SetTooltipText( row, column, L"("..SystemData.Settings.Keybindings.TOGGLE_WORLD_MAP_WINDOW.bindings[1]..L")" )

    --Tooltips.Finalize()
    -- Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end


----------------------------------------------------------------
-- Zoom
----------------------------------------------------------------
function CMapWindow.UpdateZoomButtons()
x=dbg and d(L"UpdateZoomButtons"..L"  "..CMapWindow.VisSettings[CFG_ZOOM].zoomlevel)

    WindowSetShowing(WindowName..ZOOMSLD, CMapWindow.VisSettings[CFG_ZOOM].value )
    local zoomLevel = GetOverheadMapZoomLevel()
   x=dbg and d(SystemData.OverheadMap.MAX_ZOOM_LEVEL,SystemData.OverheadMap.MIN_ZOOM_LEVEL)
    ButtonSetDisabledFlag("CMapWindowZoomSliderInButton",  zoomLevel == SystemData.OverheadMap.MAX_ZOOM_LEVEL )
    ButtonSetDisabledFlag("CMapWindowZoomSliderOutButton", zoomLevel == SystemData.OverheadMap.MIN_ZOOM_LEVEL )
end


function CMapWindow.MWheelWholeZoom(x, y, delta, flags)
x=dbg and d(L"MWheel")
  if (delta < 0) then
        CMapWindow.zoomUP()
    elseif (delta > 0) then
		CMapWindow.zoomDOWN()
    end

    CMapWindow.UpdateMap()
end



function CMapWindow.MWheel(x, y, delta, flags)
x=dbg and d(L"MWheel")
  if (delta < 0) then
        CMapWindow.ZoomOut()
    elseif (delta > 0) then
		CMapWindow.ZoomIn()
    end
    CMapWindow.UpdateMap()

end

function CMapWindow.ZoomIn()

x=dbg and d(L"ZoomIn") 

    if CMapWindow.VisSettings[CFG_ZOOM].zoomlevel == 2 then     
        CMapWindow.VisSettings[CFG_ZOOM].zoomlevel = 1 
    else
        local sliderFraction = CMapWindow.VisSettings[CFG_ZOOM].zoomlevel --SliderBarGetCurrentPosition( "CMapWindowZoomSliderBar" )
        local oneTickAmount = (1 / (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL))
    
        if ((sliderFraction - oneTickAmount) >= 0)
        then
            sliderFraction = sliderFraction - oneTickAmount
        else
            sliderFraction = 0
        end
    
        CMapWindow.activateZoom = true
        CMapWindow.VisSettings[CFG_ZOOM].zoomlevel = sliderFraction
    end
    CMapWindow.SlideZoom()
end

function CMapWindow.OnMouseoverZoomInBtn()

x=dbg and d(L"OnMouseoverZoomInBtn")

    local text = GetString( StringTables.Default.LABEL_ZOOM_IN )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function CMapWindow.ZoomOut()

x=dbg and d(L"ZoomOut") 

    local sliderFraction = CMapWindow.VisSettings[CFG_ZOOM].zoomlevel
    local oneTickAmount = (1 / (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL))

    if ((sliderFraction + oneTickAmount) <= 1) then
        sliderFraction = sliderFraction + oneTickAmount
    else
        sliderFraction = 2
    end

    CMapWindow.activateZoom = true
    CMapWindow.VisSettings[CFG_ZOOM].zoomlevel = sliderFraction
    
    CMapWindow.SlideZoom()

end

function CMapWindow.OnMouseoverZoomOutBtn()
x=dbg and d(L"OnMouseoverZoomOutBtn")
    local text = GetString( StringTables.Default.LABEL_ZOOM_OUT )
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, text )
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end


function CMapWindow.SlideZoom()

x=dbg and d(L"SlideZoom")

    if (not CMapWindow.activateZoom)
    then
        CMapWindow.activateZoom = true
        return
    end

    if CMapWindow.VisSettings[CFG_ZOOM].zoomlevel <= 1 then
        local sliderFraction = 1.0 - CMapWindow.VisSettings[CFG_ZOOM].zoomlevel
        local newZoomLevel   = (sliderFraction * (SystemData.OverheadMap.MAX_ZOOM_LEVEL - SystemData.OverheadMap.MIN_ZOOM_LEVEL)) + SystemData.OverheadMap.MIN_ZOOM_LEVEL
        x=dbg and d(L"zoom "..sliderFraction..L"  :   "..newZoomLevel)    
        SetOverheadMapZoomLevel( newZoomLevel )
        WindowSetShowing( BWName, false )
    else
        WindowSetShowing( BWName, true )
    end
    x=dbg and d(CMapWindow.VisSettings[CFG_ZOOM].zoomlevel)
    CMapWindow.UpdateZoomButtons()
end

----------------------------------------------------------------
-- Ranked Leaderboard
----------------------------------------------------------------

function CMapWindow.ToggleRankedLeaderboard()
    RoR_RankedLeaderboard.ToggleShowing()
end

function CMapWindow.OnMouseoverRankedLeaderboard()
-- make tooltip
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, L"Ranked Leaderboard")  
    
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)   
    
end

----------------------------------------------------------------
-- Scenario Summary
----------------------------------------------------------------

function CMapWindow.ToggleScenarioSummaryWindow()
    if( GameData.Player.isInScenario or GameData.Player.isInSiege or WindowGetShowing("ScenarioSummaryWindow") == true) then
        WindowUtils.ToggleShowing( "ScenarioSummaryWindow"  )
    end
end

function CMapWindow.ToggleScenarioGroupWindow()
    if( GameData.Player.isInScenario or GameData.Player.isInSiege ) then        
        if( WindowGetShowing("ScenarioGroupWindow") == true ) then
            WindowSetShowing( "ScenarioGroupWindow", false )
        else
            WindowSetShowing( "ScenarioGroupWindow", true )
        end
    end
end

function CMapWindow.OnMouseoverScenarioSummaryBtn()
	ScenarioSummaryWindow.OnPlayerListStatsUpdated()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )

    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_SUMMARY ) )

    column = column + 1
    row = row + 1
    Tooltips.SetTooltipColor( row, column, 140, 100, 0 )

	for k,v in pairs(ScenarioSummaryWindow.playersData) do
	    if v.name == GameData.Player.name then
	    	local dd = v.damagedealt
	    	local rr = v.rank
	    	local hd = v.healingdealt
	    	local ob = v.objectivescore
	    	local gs = v.groupkills
	    	local dbs = v.deathblows
	    	local dth = v.deaths

	        Tooltips.SetTooltipText( 2, column, (v.name))
	        Tooltips.SetTooltipText( 3, column, (v.career))
	        Tooltips.SetTooltipText( 4, column, L"Damage Dealt: "..dd..L"")
	        if hd > 0 then
	        	Tooltips.SetTooltipText( 5, column, L"Healing Done: "..hd..L"")
	        	Tooltips.SetTooltipText( 6, column, L"Group Kills: "..gs..L"")
	        	Tooltips.SetTooltipText( 7, column, L"Killing Blows: "..dbs..L"")
	        	Tooltips.SetTooltipText( 8, column, L"Deaths: "..dth..L"")
	        else
	        	Tooltips.SetTooltipText( 5, column, L"Group Kills: "..gs..L"")
	        	Tooltips.SetTooltipText( 6, column, L"Killing Blows: "..dbs..L"")
	        	Tooltips.SetTooltipText( 7, column, L"Deaths: "..dth..L"")
	        end
	    end
	end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function CMapWindow.OnMouseoverScenarioGroupBtn()

    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )

    local row = 1
    local column = 1
    Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_GROUPS ) )

    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function CMapWindow.UpdateScenarioButtons()
    -- Only show the buttons when map is available
    local isInScenarioOrCity = GameData.Player.isInScenario or GameData.Player.isInSiege or GameData.Player.zone == 168 or GameData.Player.zone == 167
	WindowSetShowing("CMapWindowScenarioSummaryButton", isInScenarioOrCity )
	WindowSetShowing("CMapWindowMapScenarioQueue", not isInScenarioOrCity )
	WindowSetShowing("CMapWindowScenarioGroupButton", isInScenarioOrCity )
    
end

function CMapWindow.ToggleScenarioButtons()
    -- Only show the buttons when map is available
    local isInScenarioOrCity = WindowGetShowing( "CMapWindowScenarioSummaryButton" ) == false
	WindowSetShowing("CMapWindowScenarioSummaryButton", isInScenarioOrCity )
	WindowSetShowing("CMapWindowMapScenarioQueue", not isInScenarioOrCity )
	WindowSetShowing("CMapWindowScenarioGroupButton", isInScenarioOrCity )
    
end


function CMapWindow.OnZoneChange()
    CMapWindow.UpdateMap()
    CMapWindow.OnAreaNameChange()
    CMapWindow.UpdateCityRating()
	CMapWindow.UpdateScenarioButtons()
    --CMapWindow.UpdateZoneControl()
end

function CMapWindow.OnAreaNameChange()
-- When the player moves to a different area, we need to update the area Text
    local text
    local znr = GameData.Player.zone
    local zoneName = L"" 
    if znr~=nil and (GetZoneName(znr)) then zoneName = GetZoneName(znr) end
    
    if( GameData.Player.isInSiege )
    then
      
        local instanceIdData = GetCityInstanceId()
        text = GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_LABEL, { zoneName, instanceIdData.instanceId } )
        -- DEBUG( instanceId )
    else
        text = GameData.Player.area.name
        if( text == L"")
        then
            text = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.LABEL_ZONE_NAME, {zoneName} )
        end

        if( text == L"")
        then
            text = GetStringFormatFromTable( "MapSystem", StringTables.MapSystem.LABEL_ZONE_NAME, {L"Zone "..GameData.Player.zone} )
        end
    end

    local zw = L""
	if MapGetPlayerLocationMaps()[2] ~= nil then
	  zw = zw .. GetZoneName(MapGetPlayerLocationMaps()[2])
	end 
    
    if CMapWindow.VisSettings[CFG_AREA].value == 1 then text = zw 
    elseif CMapWindow.VisSettings[CFG_AREA].value == 3 then text = text..L" ("..zw..L")" 
    elseif CMapWindow.VisSettings[CFG_AREA].value == 4 then text = L"" end

    LabelSetText("CMapWindowAreaNameText", text )
end



function CMapWindow.UpdateInfluenceBar()
x=dbg and d(L"UpdateInfluenceBar") 

    local influenceData = DataUtils.GetInfluenceData( CMapWindow.GetLocalAreaInfluenceID() )
    -- Show or hide the influence bar depending on whether we're in an influence area.

    WindowSetShowing("CMapWindowDigitinf", (influenceData ~= nil) and CMapWindow.VisSettings[CFG_INF].value)

    if( influenceData ~= nil ) then

        -- We want to show each 1/3 of the status bar as the status for each reward level.. but each
        -- level has a different reward amount. So, compute the percents and add them.
        local statusBarPercent = 0
        local lastLevelInf = 0
        local inftxt = L""
        local inftogo = 0

        statusBarPercent = influenceData.curValue / influenceData.rewardLevel[TomeWindow.NUM_REWARD_LEVELS].amountNeeded

        for level = 1, TomeWindow.NUM_REWARD_LEVELS do

            local levelPercent = ( influenceData.curValue - lastLevelInf ) / ( influenceData.rewardLevel[level].amountNeeded - lastLevelInf )

            inftogo = influenceData.rewardLevel[level].amountNeeded-influenceData.curValue

            if (inftogo > -1 and level < 4 and inftxt == L"") then

              --DEBUG(L""..inftogo)
              inftxt = L""..inftogo..L" @ "..level..L"  "

            end

            lastLevelInf =  influenceData.rewardLevel[level].amountNeeded

        end
            -- Show the fill bar in case it was hidden.
            WindowSetShowing("CMapWindowDigitinf", true and CMapWindow.VisSettings[CFG_INF].value)

            if( statusBarPercent > 1 ) then
                -- Clamp fill to 100%.
                statusBarPercent = 1
            end

            if (statusBarPercent==1) then
              inftxt = L""
            end

            inftxt = inftxt..math.floor(statusBarPercent * 100)..L"%"
            LabelSetText("CMapWindowDigitinf", inftxt )

    else
        -- DEBUG(L"Invalid influenceData")
    end

end

function CMapWindow.GetLocalAreaInfluenceID()
x=dbg and d(L"GetLocalAreaInfluenceID") 

    local areaData = GetAreaData()

    if( areaData == nil )
    then
        -- DEBUG(L"[OverheadMapWindow.GetLocalAreaInfluenceID] AreaData returned nil")
        return
    end

    for key, value in ipairs( areaData )
    do
        -- These should match the data that was retrived from war_interface::LuaGetAreaData
        if (value.influenceID ~= 0) then
            return value.influenceID
        end
    end

end


----------------------------------------------------------------
-- Map Point Filter Menu
----------------------------------------------------------------
function CMapWindow.RefreshMapPointFilterMenu()

    local numFilters = #CMapWindow.mapPinFilters
    local numFilterRows = math.ceil(numFilters / CMapWindow.NUM_PIN_FILTER_COLUMNS)
    
    local filterDisplayOrder = {}
    for index = 1, numFilterRows
    do
        table.insert(filterDisplayOrder, index)
    end
    ListBoxSetDisplayOrder("CMapWindowPinFilterMenuFiltersList", filterDisplayOrder)
    
    local numGutters = #CMapWindow.mapPinGutters
    local numGutterRows = math.ceil(numFilters / CMapWindow.NUM_PIN_FILTER_COLUMNS)
    
    local gutterDisplayOrder = {}
    for index = 1, numGutterRows
    do
        table.insert(gutterDisplayOrder, index)
    end
    ListBoxSetDisplayOrder("CMapWindowPinFilterMenuGuttersList", gutterDisplayOrder)
    
    LabelSetText("CMapWindowPinFilterMenuFiltersHeading", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_FILTERS))
    LabelSetText("CMapWindowPinFilterMenuGuttersHeading", GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_GUTTERS))

end

-- Post process the list.
function CMapWindow.Populate()



    for row, data in ipairs(CMapWindowPinFilterMenuList.PopulatorIndices)
    do
        local filterData  = CMapWindow.mapPinFilters[data]
        local rowFrame    = "CMapWindowPinFilterMenuListRow"..row
        local buttonFrame = rowFrame.."Button"
        local iconFrame   = rowFrame.."Icon"
        local labelFrame  = rowFrame.."Label"

        -- Label the button
        LabelSetText(labelFrame, GetStringFromTable("MapPointFilterNames", filterData.label))

        -- Set up the check button state
        ButtonSetCheckButtonFlag(buttonFrame, true)

        local enableButton = false

        for _, pinType in ipairs(filterData.pins)
        do
            if CMapWindow.VisSettings.Pinfilter[ pinType ]
            then
                enableButton = true
                break
            end
        end

        ButtonSetPressedFlag(buttonFrame, enableButton)

        -- Add the appropriate map icon
        DynamicImageSetTextureSlice(iconFrame, filterData.slice)
    end
end

function CMapWindow.PopulateFilterCell(listBoxWindowName, rowIndex, colIndex, pinTypeIndex, filterList, settingsList)
    local filterData  = filterList[pinTypeIndex]
    local rowFrame    = listBoxWindowName.."Row"..rowIndex
    local buttonFrame = rowFrame.."Button"..colIndex
    local iconFrame   = rowFrame.."Icon"..colIndex
    local labelFrame  = rowFrame.."Label"..colIndex
        
    if (filterData ~= nil)
    then
        WindowSetShowing(buttonFrame, true)
        WindowSetShowing(iconFrame, true)
        WindowSetShowing(labelFrame, true)
            
        LabelSetText(labelFrame, GetStringFromTable("MapPointFilterNames", filterData.label))
        WindowSetId(buttonFrame, pinTypeIndex)
        ButtonSetCheckButtonFlag(buttonFrame, true)
            
        local enableButton = false
        for _, pinType in ipairs(filterData.pins)
        do
            if ( settingsList and settingsList[ pinType ] )
            then
                enableButton = true
                break
            end
        end
        
        ButtonSetPressedFlag(buttonFrame, enableButton)
        DynamicImageSetTextureScale(iconFrame, filterData.scale)
        DynamicImageSetTextureSlice(iconFrame, filterData.slice)
    else
        WindowSetShowing(buttonFrame, false)
        WindowSetShowing(iconFrame, false)
        WindowSetShowing(labelFrame, false)
    end
end

function CMapWindow.PopulateFilters()
    for rowIndex, baseIndex in ipairs(CMapWindowPinFilterMenuFiltersList.PopulatorIndices)
    do
        for colIndex = 1, EA_Window_OverheadMap.NUM_PIN_FILTER_COLUMNS
        do
            local pinTypeIndex = ((baseIndex - 1) * CMapWindow.NUM_PIN_FILTER_COLUMNS) + colIndex
            CMapWindow.PopulateFilterCell("CMapWindowPinFilterMenuFiltersList", rowIndex, colIndex, pinTypeIndex, CMapWindow.mapPinFilters, CMapWindow.VisSettings.Pinfilter)
        end
    end
end

function CMapWindow.PopulateGutters()
    for rowIndex, baseIndex in ipairs(CMapWindowPinFilterMenuGuttersList.PopulatorIndices)
    do
        for colIndex = 1, CMapWindow.NUM_PIN_FILTER_COLUMNS
        do
            local pinTypeIndex = ((baseIndex - 1) * CMapWindow.NUM_PIN_FILTER_COLUMNS) + colIndex
            CMapWindow.PopulateFilterCell("CMapWindowPinFilterMenuGuttersList", rowIndex, colIndex, pinTypeIndex, CMapWindow.mapPinGutters, CMapWindow.VisSettings.Pingutter)
        end
    end
end


function CMapWindow.ToggleFilterMenu()
    WindowUtils.ToggleShowing( "CMapWindowPinFilterMenu" )
end


function CMapWindow.ToggleMapPinFilter()
    local showPin      = ButtonGetPressedFlag(SystemData.ActiveWindow.name)
    local pinTypeIndex = WindowGetId(SystemData.ActiveWindow.name)
    local pinTypes     = CMapWindow.mapPinFilters[pinTypeIndex].pins
    d(pinTypes)
    for _, pinType in ipairs(pinTypes)
    do
        -- Update the Settings
        MapSetPinFilter("CMapWindowMapDisplay", pinType, showPin)    
        CMapWindow.VisSettings.Pinfilter[ pinType ] = showPin    
    end
end

function CMapWindow.ToggleMapPinGutter()
    local gutterPin    = ButtonGetPressedFlag(SystemData.ActiveWindow.name)
    local pinTypeIndex = WindowGetId(SystemData.ActiveWindow.name)
    local pinTypes     = CMapWindow.mapPinGutters[pinTypeIndex].pins
    
    for _, pinType in ipairs(pinTypes)
    do
        -- Update the Settings
        MapSetPinGutter("CMapWindowMapDisplay", pinType, gutterPin)    
        CMapWindow.VisSettings.Pingutter[ pinType ] = gutterPin    
    end
    
    -- The map border automatically switches between new and old style depending on whether any gutters are enabled
    -- (Unless the appropriate setting in User Settings is checked to always force the old border.)
    --CMapWindow.UpdateMinimapBorder()
end


function CMapWindow.OnMouseOverFilterMenuButton()
    Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, GetStringFromTable("MapSystem", StringTables.MapSystem.LABEL_MAP_FILTERS_BUTTON)  )
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

----------------------------------------------------------------
-- Zoom Whole Window
----------------------------------------------------------------

function CMapWindow.OnResizeBeginLO( flags, x, y )

    CMapWindow.isResizing = true

    WindowUtils.BeginResize( "CMapWindow", "bottomright", 100, 110, CMapWindow.OnResizeEnd )

end

function CMapWindow.OnResizeBeginRO( flags, x, y )

    CMapWindow.isResizing = true

    WindowUtils.BeginResize( "CMapWindow", "bottomleft", 100, 110, CMapWindow.OnResizeEnd )

end

function CMapWindow.OnResizeBeginLU( flags, x, y )

    CMapWindow.isResizing = true

    WindowUtils.BeginResize( "CMapWindow", "topright", 100, 110, CMapWindow.OnResizeEnd )

end

function CMapWindow.OnResizeBeginRU( flags, x, y )

    CMapWindow.isResizing = true

    WindowUtils.BeginResize( "CMapWindow", "topleft", 100, 110, CMapWindow.OnResizeEnd )

end

function CMapWindow.OnResizeEnd()


    CMapWindow.isResizing = false


end


function CMapWindow.zoomDOWN()
    local multi = 1.1
    local breadth, height = WindowGetDimensions( "CMapWindow" )
    local rbreadth, rheight = GetScreenResolution()
    local wscale = WindowGetScale("CMapWindow")
    --local uiScale                   = (rheight/InterfaceCore.GetScale())
    local uiScale =  rheight/wscale
    if  (height/multi) >= 255 or (breadth/multi) >= 225
    then
    --WindowSetShowing("CMapWindow",true)
    end
    if  (height*multi) > (uiScale)
    then
        WindowSetDimensions( "CMapWindow", uiScale*0.88235294, uiScale )
        --WindowSetDimensions( "CMapWindowAreaNameText", uiScale*0.88235294, 30 )
    else
        WindowSetDimensions( "CMapWindow", breadth*multi, height*multi )
        --WindowSetDimensions( "CMapWindowAreaNameText", breadth*multi, 30 )
    end
    MapSetMapView( BWName, GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
end

function CMapWindow.zoomUP()
    local multi = 1.1
    local breadth, height = WindowGetDimensions( "CMapWindow" )

    if  (height/multi) < 255 or (breadth/multi) < 225
    then
        --WindowSetShowing("CMapWindow",false)
        --WindowSetShowing("CMapWindowMapWorldMapButton",true)
        WindowSetDimensions( "CMapWindow", 225, 255 )
        --WindowSetDimensions( "CMapWindowAreaNameText", 225, 30 )
    else
        WindowSetDimensions( "CMapWindow", breadth/multi, height/multi )
        --WindowSetDimensions( "CMapWindowAreaNameText", breadth/multi, 30 )
    end
    MapSetMapView( BWName, GameDefs.MapLevel.ZONE_MAP, GameData.Player.zone  )
end

function CMapWindow.ModsCheck()
    local mods = ModulesGetData();
    for k,v in ipairs(mods) do
        if v.name == "Queue Queuer" then
            if v.isEnabled then
                d("queuequeuer debug: yes find")
            return true
            else
                d("queuequeuer debug: no find")
            return false
            end
            break
        end
    end
end

----------------------------------------------------------------
-- Scenario Queue
----------------------------------------------------------------

function CMapWindow.OnScenarioQueueLButtonUp()
    --[[
    local mods = ModulesGetData();
    for k,v in ipairs(mods) do
        if v.name == "Queue Queuer" then
            if v.isEnabled then
                --WndName = WndName.."Vertical"
                --found it
                d("queuequeuer debug: yes find")
                QueueQueuer_GUI.MapButton_OnLButtonUp()
            else
                --WndName = WndName.."Contents"
                --didn't find queuequeuer
                d("queuequeuer debug: no find")
            end
            break
        end
    end
    ]]--

    if CMapWindow.ModsCheck() == true then
        QueueQueuer_GUI.MapButton_OnLButtonUp()
    else
        CMapWindow.OnJoinAScenario()
    end
end

function CMapWindow.OnScenarioQueueRButtonUp()
    if CMapWindow.ModsCheck() == true then
        QueueQueuer_GUI.MapButton_OnRButtonUp()
    else
        local queuedScenarioData = GetScenarioQueueData()

            if( queuedScenarioData ~= nil ) then

                local totalScenarios = queuedScenarioData.totalQueuedScenarios

                local text = ""

                EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name)

                    for index = 1, totalScenarios do

                        if( queuedScenarioData[index].type == CMapWindow.INSTANCETYPE_SCENARIO) then
                            local scenarioName = GetScenarioName(queuedScenarioData[index].id)
                            text = GetStringFormat( StringTables.Default.TEXT_LEAVE_SCENARIO, { scenarioName } )
                        else
                        -- city instance
                            local scenarioName = GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_QUEUE, { queuedScenarioData[index].id } )
                               text = GetStringFormat( StringTables.Default.TEXT_LEAVE_SCENARIO, { scenarioName } )
                        end
                        EA_Window_ContextMenu.AddMenuItem( text, CMapWindow.LeaveScenario, false, true )
                    end
                    if JSS then
                                EA_Window_ContextMenu.AddMenuItem(L"Leave: ALL scenarios", JSS.LeaveAllScenarios, false, true)
                    end

                  EA_Window_ContextMenu.Finalize()
            end
    end
end

function CMapWindow.JoinAllQueues()

    EA_Window_ScenarioLobby.Initialize()
    EA_Window_ScenarioLobby.OnJoinAllQueues()
    --BroadcastEvent(SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE_ALL )

    DEBUG(L"JOINALL")

end

function CMapWindow.OnJoinAScenario()
    GameData.ScenarioQueueData.selectedId = 0
    BroadcastEvent( SystemData.Events.INTERACT_SHOW_SCENARIO_QUEUE_LIST )
end

function CMapWindow.OnMouseoverScenarioQueue()
    if CMapWindow.ModsCheck() == true then
        QueueQueuer_GUI.MapButton_OnMouseOver()
    else
        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )

        local scenarioQueueData = GetScenarioQueueData()
        local row = 1
        local column = 1
        --if( GameData.ScenarioData.activeQueue ~= 0 and GameData.ScenarioData.activeQueue ~= nil and scenarioQueueData ~= nil) then
        if( scenarioQueueData ~= nil) then
            Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_QUEUE_CURRENT_QUEUE ) )

            local numberOfScenarios = scenarioQueueData.totalQueuedScenarios
            -- Place this in a loop to indicate all the active scenarios
            for index = 1, numberOfScenarios do
                if( scenarioQueueData[index].type == CMapWindow.INSTANCETYPE_SCENARIO) then
                    Tooltips.SetTooltipText( index+1, column, GetScenarioName(scenarioQueueData[index].id) )
                    Tooltips.SetTooltipColor( index+1, column, 255, 255, 255 )
                else
                -- city instance
                    Tooltips.SetTooltipText( index+1, column, ( GetStringFormat( StringTables.Default.TEXT_CITY_INSTANCE_QUEUE, { scenarioQueueData[index].id } ) )  )
                    Tooltips.SetTooltipColor( index+1, column, 255, 255, 255 )
                end
            end
            -- end loop

            Tooltips.SetTooltipText( numberOfScenarios+2, column, GetString( StringTables.Default.TEXT_SCENARIO_QUEUE_MORE ) )
            Tooltips.SetTooltipText( numberOfScenarios+3, column, GetString( StringTables.Default.TEXT_SCENARIO_QUEUE_LESS ) )

            --setup the colors
            Tooltips.SetTooltipColor( row, column, 255, 204, 102 )
            --Tooltips.SetTooltipColor( row+1, column, 255, 255, 255 )
            Tooltips.SetTooltipColor( numberOfScenarios+2, column, 175, 175, 175 )
            Tooltips.SetTooltipColor( numberOfScenarios+3, column, 175, 175, 175 )
        else
            Tooltips.SetTooltipText( row, column, GetString( StringTables.Default.LABEL_SCENARIO_QUEUE ) )
        end

        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
    end
end

function CMapWindow.UpdateScenarioQueueButton()
    local queuedScenarioData = GetScenarioQueueData()
    --DEBUG( queuedScenarioData )
    --if( GameData.ScenarioData.activeQueue ~= 0 and GameData.ScenarioData.activeQueue ~= nil and queuedScenarioData ~= nil) then
    if( queuedScenarioData ~= nil) then
        --DEBUG(L"In Queue")
        WindowSetShowing( "CMapWindowMapScenarioQueueGlowAnim", true )
        AnimatedImageStartAnimation( "CMapWindowMapScenarioQueueGlowAnim", 0, true, false, 0.0 )
    else
        --DEBUG(L"NOT in Queue")
        WindowSetShowing( "CMapWindowMapScenarioQueueGlowAnim", false )
        AnimatedImageStopAnimation( "CMapWindowMapScenarioQueueGlowAnim")

        --The scenario window may not exist yet...
        if( DoesWindowExist("EA_Window_InScenarioQueue") ) then
            WindowSetShowing( "EA_Window_InScenarioQueue", false )
        end
    end
end


----------------------------------------------------------------
-- More Scenario Functions
----------------------------------------------------------------

function CMapWindow.LeaveScenario(  )
    local scenrioQueueData = GetScenarioQueueData()
    local clickedWindowName = SystemData.ActiveWindow.name
    local windowId = WindowGetId(clickedWindowName)

    if( scenrioQueueData[windowId].type == CMapWindow.INSTANCETYPE_SCENARIO )
    then
        GameData.ScenarioQueueData.selectedId = scenrioQueueData[windowId].id
        BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
    else
    -- leave city instance queue
        --GameData.CityQueueData.selectedId = scenrioQueueData[windowId].id
        GameData.CityQueueData.selectedId = 1
        BroadcastEvent( SystemData.Events.CITY_CAPTURE_LEAVE )
    end
end

---------------------------------------------------------------------
-- City Rating Functions: Only relelvent for the Peaceful city zones.
---------------------------------------------------------------------

function CMapWindow.UpdateCityRating()

    local cityId =  GameDefs.ZoneCityIds[ GameData.Player.zone ]

    -- Is nil if the zone is not a city zone
    if( cityId == nil )
    then
        x = CMapWindow.VisSettings[CFG_CITY].value and WindowSetShowing( "CMapWindowCityRating", false )
        return
    end

    MapUtils.UpdateCityRatingWindow( cityId, "CMapWindowCityRating" )
    x = CMapWindow.VisSettings[CFG_CITY].value and WindowSetShowing( "CMapWindowCityRating", true )
end

function CMapWindow.OnMouseOverCityRating()

    local cityId =  GameDefs.ZoneCityIds[ GameData.Player.zone ]
    if( cityId == nil )
    then
        return
    end

    local cityRating = GetCityRatingForCityId( cityId )

    -- Get the Strings for the Title
    local titleText = GetStringFromTable("RvRCityStrings", StringTables.RvRCity.LABEL_CITY_RANK )

    -- Determine Rating Text
    local ratingText = L""
    local descStringId = StringTables.RvRCity[ "CITY_"..cityId.."_RATING_"..cityRating.."_DESC" ]
    if( descStringId ~= nil )
    then
        ratingText = GetStringFromTable( "RvRCityStrings", descStringId )
    end


    -- Build the List of Items
    local itemsText = {}


    for rating = Tooltips.NUM_CITY_RANKS, 1, -1
    do
        if( rating <= cityRating )
        then

            -- Set the Rank Descriptions
            local activityRankIndex = 1
            local descItemStringId  = StringTables.RvRCity[ "CITY_"..cityId.."_RATING_"..rating.."_ACTIVITY_"..activityRankIndex ]
            while( descItemStringId )
            do

                local text = GetStringFromTable( "RvRCityStrings", descItemStringId )
                table.insert( itemsText, text )

                activityRankIndex = activityRankIndex + 1
                descItemStringId  = StringTables.RvRCity[ "CITY_"..cityId.."_RATING_"..rating.."_ACTIVITY_"..activityRankIndex ]
            end
        end
    end

    -- Quest & PQ Text is added last so that it is at the bottom of the window.
    local text = GetStringFormatFromTable( "RvRCityStrings", StringTables.RvRCity.RANK_X_CITY_AND_PQ_AVAIL, { L""..cityRating } )
    table.insert( itemsText, text )


    Tooltips.CreateListTooltip( titleText, ratingText, itemsText, SystemData.ActiveWindow.name, Tooltips.ANCHOR_WINDOW_LEFT )

end


function CMapWindow.OnMouseOverDigitinf()
x=dbg and d(L"OnMouseOverInfluenceBar") 

    local influenceData = DataUtils.GetInfluenceData( CMapWindow.GetLocalAreaInfluenceID())

    if( influenceData ~= nil ) then



        local zoneName  = L""
        --if GetZoneName( influenceData.zoneNum ) then
        --d(influenceData.zoneNum)
		if influenceData.zoneNum ~= nil then
			zoneName =  GetZoneName( influenceData.zoneNum )
		end
        local areaName = GetZoneAreaName(  influenceData.zoneNum, influenceData.zoneAreaNum )

        local line1 = GetString( StringTables.Default.LABEL_AREA_INFLUENCE )
        local line2 = GetStringFormat( StringTables.Default.TEXT_PQ_TRACKER_INFLUENCE_BAR, { influenceData.npcName, areaName, zoneName, influenceData.npcName } )
        local actionText = GetString( StringTables.Default.TEXT_CLICK_VIEW_REWARDS )

        Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
        Tooltips.SetTooltipText( 1, 1, line1)
        Tooltips.SetTooltipColorDef( 1, 1, Tooltips.COLOR_HEADING )
        Tooltips.SetTooltipText( 2, 1, line2)
        Tooltips.SetTooltipText( 3, 1, L"Current Influence:  "..influenceData.curValue)

        for level = 1, TomeWindow.NUM_REWARD_LEVELS do

          Tooltips.SetTooltipText( level + 3 , 1, L"Influence for Stage"..level..L":  "..influenceData.rewardLevel[level].amountNeeded)

        end

        Tooltips.SetTooltipActionText( actionText)

        Tooltips.Finalize()
        Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
    end
end

function CMapWindow.OnClickDigitinf()
x=dbg and d(L"OnClickInfluenceBar") 

    local influenceData = DataUtils.GetInfluenceData( CMapWindow.GetLocalAreaInfluenceID() )

    if( influenceData ~= nil ) then
        -- Open the tome to the link
        TomeWindow.OpenTomeToEntry( influenceData.tomeSection, influenceData.tomeEntry )
    end

end

---------------------------------------------------------------------
-- Pending Mail notification icon
---------------------------------------------------------------------

function CMapWindow.UpdateMailIcon()
    x=dbg and d("MAILUPD:------------",CMapWindow.VisSettings[CFG_MAIL].value,showIcon,WindowGetShowing("CMapWindowMapMailNotificationIcon"),"------------MAILUPD:")
    
    local showIcon = (GameData.Mailbox.PLAYER.unreadCount + GameData.Mailbox.AUCTION.unreadCount) > 0
    
    if showIcon ~= nil then
        
        if CMapWindow.VisSettings[CFG_MAIL].value and (showIcon ~= WindowGetShowing("CMapWindowMapMailNotificationIcon")) then 
            x=dbg and d("SETWINDOW TO ",showIcon)
            WindowSetShowing("CMapWindowMapMailNotificationIcon", showIcon) 
        end
    else
        x=dbg and d(" else SETWINDOW TO ",false)
        WindowSetShowing("CMapWindowMapMailNotificationIcon", false)
    end
end

function CMapWindow.MouseoverMail()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil )

	Tooltips.SetTooltipText( 1, 1, L"Mail: "..GameData.Mailbox.PLAYER.unreadCount )
	Tooltips.SetTooltipText( 2, 2, L"Auctions: "..GameData.Mailbox.AUCTION.unreadCount )

	Tooltips.Finalize()
    Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end


---------------------------------------------------------------------
-- Map
---------------------------------------------------------------------


function CMapWindow.WmapOnMouseOverPoint()
    Tooltips.CreateMapPointTooltip( "CMapWindowWMap", CMapWindowWMap.MouseoverPoints, Tooltips.ANCHOR_CURSOR )
end

function CMapWindow.WmapOnClickMap()
    if CMapWindow.ClickMap( "CMapWindowWMap", CMapWindowWMap.MouseoverPoints ) ~= "tt" then
            CMapWindow.ToggleWorldMapWindow()
    end


end


function CMapWindow.OnEventsUpdated( eventsData )
   -- Hide the Button when no events exist
   local countEV = #eventsData
   d(CMapWindow.VisSettings[CFG_EVENT].value,"OnEventsUpdated")
	if not CMapWindow.VisSettings[CFG_EVENT].value then 
	countEV = 0 
	
	end
   WindowSetShowing( "CMapWindowOverheadCurrentEvents", countEV > 0 )
end

function CMapWindow.UpdateCoordinatesWMap(elapsed)
    if updCoordWMap then
        timeLeft = timeLeft - elapsed
        if timeLeft > 0 then return end

        local mapPositionX, mapPositionY = WindowGetScreenPosition(BWName)
        local xc, yc = MapGetCoordinatesForPoint(BWName,
                                               SystemData.MousePosition.x - mapPositionX,
                                               SystemData.MousePosition.y - mapPositionY)
         
        x=dbg and d(xc,yc)
          
        if (xc == nil) then
            xc = L"-"
        else
            xc=math.ceil(xc/1000)
        end
        
        if (yc == nil) then
            yc = L"-"
        else
           yc=math.ceil(yc/1000) 
        end
        
        LabelSetText("CMapWindowAreaNameText", L""..xc..L"k, "..yc..L"k")
        timeLeft = TIME_DELAY
    end
end

function CMapWindow.UpdateCoordinatesMap(elapsed)
    if updCoordMap then
        timeLeft = timeLeft - elapsed
        if timeLeft > 0 then return end

        local mapPositionX, mapPositionY = WindowGetScreenPosition(AWName)
        local xc, yc = MapGetCoordinatesForPoint(AWName,
                                               SystemData.MousePosition.x - mapPositionX,
                                               SystemData.MousePosition.y - mapPositionY)
          
         
        x=dbg and d(xc,yc)
          
        if (xc == nil) then
            xc = L"-"
        else
            --xc=math.ceil(xc/1000)
        end
        
        if (yc == nil) then
            yc = L"-"
        else
           --yc=math.ceil(yc/1000) 
        end
        
        LabelSetText("CMapWindowAreaNameText", L""..xc..L"k, "..yc..L"k")
        timeLeft = TIME_DELAY
    end
end

function CMapWindow.ClickMap( mapDisplay, points )

    if MapUtils.openTomeCallback ~= nil then


        for index, ptIndex in ipairs( points ) do

            local pointType, pointId, pointIcon, pointName, pointText, cntrl = GetMapPointData( mapDisplay, ptIndex )

            if( pointType == SystemData.MapPips.QUEST_AREA) then

                if( WindowGetShowing( "TomeWindow" ) == false  ) then
                    MapUtils.toggleTomeCallback()
                else
                    --bring to front even if it's behind something now
                    MapUtils.toggleTomeCallback()
                    MapUtils.toggleTomeCallback()
                end
                MapUtils.openTomeCallback( pointId )

                return "tt"

            end

        end



    end

end

function CMapWindow.SlashHandler(input)
   x=dbg and d(input)
    local opt,res=nil
    opt = input  --:match("([a-z0-9]+)[ ]?(.*)")
    res = input:match("([a-z0-9]+)")

    if res == "reset" then

        CMapWindow.ResetSettings()
        CMapWindow.ResetVisSettings()
        return

    end


    local cmdset = {
    	["visible"]={"Sets the starting visibility of the Element"," [true] or [false]","boolean"},
        ["x"]={"Sets the Y-position of the Element"," [#]","number"},
        ["y"]={"Sets the Y-position of the Element"," [#]","number"},
        ["rpoint"]={"Sets the anchor-point of the Element"," [right|left|top|bottom and combinations eg topright|bottomleft|..  etc]","string"} ,
        ["point"]={"Sets the anchor-point on the relative-object"," [right|left|top|bottom and combinations eg topright|bottomleft|..  etc]","string"},
        ["rto"]={"Sets the Object to anchor on"," [objectname]","string"} ,
        ["alpha"]={"Sets the Object alpha"," [objectname]","number"} ,
        ["red"]={"Sets the Object red color"," [objectname]","number"} ,
        ["green"]={"Sets the Object green color"," [objectname]","number"} ,
        ["blue"]={"Sets the Object blue color"," [objectname]","number"} 
    }

    -- NO OPTION SPECIFIED


   x=dbg and d("---",opt)
    opt = StringSplit(opt," ")
   x=dbg and d(opt,"---")

    local function SetSetting(op1,op2,val)

                x=dbg and type(val)
                print("/cmap "..op1.." ")
                print("old value= "..bts(CMapWindow.VisSettings[op1][op2],"string"))
                CMapWindow.VisSettings[op1][op2]= val
                print("new value= "..bts(CMapWindow.VisSettings[op1][op2],"string"))
                CMapWindow.CMapUseSettings()

    end
    local function PrintSetting(op1,op2)

                if CMapWindow.VisSettings[op1].type==TYPESETTING then

                print("use /cmap "..op1.." ")
                print("current value= "..bts(CMapWindow.VisSettings[op1][op2],"string") )
                print(CMapWindow.VisSettings[op1].descr)

                else
                print("use /cmap "..op1.." "..op2.." ")
                print("current value= "..bts(CMapWindow.VisSettings[op1][op2],"string") )
                x=dbg and print(type(CMapWindow.VisSettings[op1][op2]))
                print(cmdset[op2][2])
                end
    end


    if CMapWindow.VisSettings[opt[1]]  then
            x=dbg and d(#opt,"if  CMapWindow.VisSettings[opt[1]] ",CMapWindow.VisSettings[opt[1]][opt[2]])

            if #opt > 2 and CMapWindow.VisSettings[opt[1]][opt[2]] ~= nil then
                x=dbg and d("--settingNORMAL  #opt > 2")

                SetSetting(opt[1],opt[2],bts(opt[3],cmdset[opt[2]][3]))


            elseif #opt > 1 then

                x=dbg and d("--#opt > 1",CMapWindow.VisSettings[opt[1]])

                if CMapWindow.VisSettings[opt[1]].type == TYPESETTING then
                    x=dbg and d("--settinTYPESETTING",CMapWindow.VisSettings[opt[1]].dtype)
                    SetSetting(opt[1],"value",bts(opt[2],CMapWindow.VisSettings[opt[1]].dtype))

                elseif CMapWindow.VisSettings[opt[1]][opt[2]]~=nil then

                x=dbg and d("--option")

                    PrintSetting(opt[1],opt[2])


                end

            else
                x=dbg and d("--object   ELSE")
                if CMapWindow.VisSettings[opt[1]].type == TYPESETTING  then

                    PrintSetting(opt[1],"value")

                else



                print("use /cmap "..opt[1].." [0ption]")
                print("Options: ")
                for k,v in pairs(CMapWindow.VisSettings[opt[1]]) do

                    if k ~= "type" then
                        --x=dbg and d("###",k,v,cmdset[k])
                        --optt = optt.."["..tostring(k).."]  "
                        print("["..tostring(k).."]  "..cmdset[k][1])
                    end
                end

                end
                --print(optt)


            end
   else
           x=dbg and d("--nüscht")

            print("use /cmap [0ption]")
            local optt = "Options: "
            for k,v in pairs(CMapWindow.VisSettings) do
                x=dbg and d(type(v.type),type(v.type ~= TYPEPIN),type(CMapWindow.VisSettings[CFG_WINDOWS].value),type(v.type ~= TYPEWINDOW))
                kack = v.type ~= TYPEPIN and (CMapWindow.VisSettings[CFG_WINDOWS].value or ((v.type ~= TYPEWINDOW) and (v.type ~= TYPEMAINWINDOW) and (v.type ~= TYPEEXTERN)))
                x=dbg and d("###",type(kack),kack,"###") 
                if kack then
                    
                    optt = optt.."["..tostring(k).."]  "
                end
            end

            print(optt)

   end
end

function CMapWindow.OnMouseOverEnemy()
	Tooltips.CreateTextOnlyTooltip ("CMapWindowMapEnemy")
	Tooltips.SetTooltipText (1, 1, L"Enemy Addon")
	local data = {}
	Enemy.TriggerEvent("IconCreateTooltip", data)
	table.insert(data, L"Right-click to open menu.")
	local k = 2
	for _, d in pairs(data)
	do
		Tooltips.SetTooltipText (k, 1, d)
		k = k + 1
	end
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end