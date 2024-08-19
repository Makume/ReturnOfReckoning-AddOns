----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

SocialWindowTabOptions = {}

SocialWindowTabOptions.AFK                          = 0

-- These must also match the enum ESocialNetworkFlag in WHConsts.h.
SocialWindowTabOptions.FLAG_ANONYMOUS               = 0
SocialWindowTabOptions.FLAG_HIDDEN	                = 1
SocialWindowTabOptions.FLAG_ALWAYSFORMPRIVATEGRP    = 7
SocialWindowTabOptions.PREFERENCES_MAX_NUMBER       = 2 -- Make 5 when tradeskills go live

----------------------------------------------------------------
-- Saved Variables
----------------------------------------------------------------
SocialWindowTabOptions.Settings = {}
SocialWindowTabOptions.Settings.disableBuddyList = false

if( SystemData.Territory.KOREA )
then
    SocialWindowTabOptions.Settings.disableBuddyList = true
end



-- OnInitialize Handler
function SocialWindowTabOptions.Initialize()
    	
    -- Set label text
	LabelSetText("SocialWindowTabOptionsOptionsLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_OPTIONS) )
	LabelSetText("SocialWindowTabOptionsAnonymousLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_ANONYMOUS) )
	LabelSetText("SocialWindowTabOptionsAnonymousDescLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_ANONYMOUS) )			
	LabelSetText("SocialWindowTabOptionsHiddenLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_HIDDEN) )
	LabelSetText("SocialWindowTabOptionsHiddenDescLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_HIDDEN) )				
	LabelSetText("SocialWindowTabOptionsPrivatePartyLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_PRIVATE) )
	LabelSetText("SocialWindowTabOptionsPrivatePartyDescLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_PRIVATE) )	
    LabelSetText("SocialWindowTabOptionsDisableBuddyListLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_DISABLE_BUDDYLIST) )	
    LabelSetText("SocialWindowTabOptionsDisableBuddyListDescLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_DISABLE_BUDDYLIST) )	
    LabelSetText("SocialWindowTabOptionsAdvisorLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_ADVISOR) )
    LabelSetText("SocialWindowTabOptionsAdvisorDescLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_ADVISOR) )

	LabelSetText("SocialWindowTabOptionsAFKLabel", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_AFK) )
	LabelSetText("SocialWindowTabOptionsAFKNoteLabel", GetStringFromTable("SocialStrings", StringTables.Social.TEXT_SOCIAL_OPTIONS_AFK) )
	
	-- Set button text
	ButtonSetText("SocialWindowTabOptionsAFKButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_BUTTON_AFK_ON) )		
	
	-- All flags off by default
	ButtonSetCheckButtonFlag("SocialWindowTabOptionsAnonymousPreference", true ) -- Anonymous
	ButtonSetCheckButtonFlag("SocialWindowTabOptionsHiddenPreference", true ) -- Hidden
	ButtonSetCheckButtonFlag("SocialWindowTabOptionsPrivatePartyPreference", false ) -- Private Party
    ButtonSetCheckButtonFlag("SocialWindowTabOptionsDisableBuddyListPreference", true ) -- disable buddy list?
    ButtonSetCheckButtonFlag("SocialWindowTabOptionsAdvisorPreference", true ) -- Advisor
	
	
    -- Register all the Events for this Tab
    WindowRegisterEventHandler( "SocialWindowTabOptions", SystemData.Events.SOCIAL_OPTIONS_UPDATED, "SocialWindowTabOptions.OnOptionsUpdated")
	
	
	-- Initialize the options settings
	SocialWindowTabOptions.OnOptionsUpdated()
	
end

function SocialWindowTabOptions.Shutdown()

end

function SocialWindowTabOptions.OnOptionsUpdated()
        
    -- Update the main preferences flags    
	local socialPreferenceData = GetSocialPreferenceData()	
	if( socialPreferenceData ~= nil ) then
	    -- Set the Anonymous Flag
	    ButtonSetPressedFlag( "SocialWindowTabOptionsAnonymousPreference", socialPreferenceData[SocialWindowTabOptions.FLAG_ANONYMOUS])
	    -- Set the Hidden Flag
	    ButtonSetPressedFlag( "SocialWindowTabOptionsHiddenPreference", socialPreferenceData[SocialWindowTabOptions.FLAG_HIDDEN])    
	    -- Set the Private Party Flag
        ButtonSetPressedFlag( "SocialWindowTabOptionsPrivatePartyPreference", socialPreferenceData[SocialWindowTabOptions.FLAG_ALWAYSFORMPRIVATEGRP])    
	end
    
    -- Set the Advisor Flag
    ButtonSetPressedFlag( "SocialWindowTabOptionsAdvisorPreference", GetAdvisorFlag() )

    -- Update: AFK Flag
    local isAFK = GetAFKFlag()
    if ( isAFK == true ) then
        ButtonSetText("SocialWindowTabOptionsAFKButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_BUTTON_AFK_OFF) )
    else
        ButtonSetText("SocialWindowTabOptionsAFKButton", GetStringFromTable("SocialStrings", StringTables.Social.LABEL_SOCIAL_OPTIONS_BUTTON_AFK_ON) )        
    end
    
    ButtonSetPressedFlag( "SocialWindowTabOptionsDisableBuddyListPreference", SocialWindowTabOptions.Settings.disableBuddyList)
end

function SocialWindowTabOptions.ResetEditBoxes()
    TextEditBoxSetText("SocialWindowTabOptionsAFKNoteEditBox", L"")
    WindowAssignFocus("SocialWindowTabOptionsAFKNoteEditBox", false)
end

function SocialWindowTabOptions.OnKeyEscape()
    SocialWindowTabOptions.ResetEditBoxes()	-- Clear the edit box texts and any focus these edit boxes may have
end

function SocialWindowTabOptions.OnPressAnonymousButton()
    SendChatText( L"/anonymous", L"" )
end

function SocialWindowTabOptions.OnPressHiddenButton()
    SendChatText( L"/hide", L"" )
end

function SocialWindowTabOptions.OnPressShowEquipButton()
    SendChatText( L"/inspectable", L"" )
end

function SocialWindowTabOptions.OnPressShowBragButton()
    SendChatText( L"/inspectablebraggingrights", L"" )
end

function SocialWindowTabOptions.OnPressAFKButton()

    local afkNote = L""
    if GetAFKFlag() == false
    then
        afkNote = TextEditBoxGetText("SocialWindowTabOptionsAFKNoteEditBox")
    end

    SendChatText(  L"/afk "..afkNote, L"" )
end

function SocialWindowTabOptions.OnPressPrivatePartyButton()
    SendChatText( L"/togglealwaysformprivate", L"" )
end

function SocialWindowTabOptions.OnPressDisableBuddyListButton()
    SocialWindowTabOptions.Settings.disableBuddyList = not SocialWindowTabOptions.Settings.disableBuddyList
    ButtonSetPressedFlag("SocialWindowTabOptionsDisableBuddyListPreference", SocialWindowTabOptions.Settings.disableBuddyList )
end

function SocialWindowTabOptions.OnPressAdvisorButton()
    local buttonState = ButtonGetPressedFlag( "SocialWindowTabOptionsAdvisorPreference" )
    SetAdvisorFlag(buttonState)
end
