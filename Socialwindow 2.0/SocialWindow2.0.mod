<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
    <UiMod name="SocialWindow 2.0" version="1.0.3" date="6/6/2024" >
        <Author name="EAMythic" email="" />
        <Description text="Tweaked by Elabas" />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_TargetInfo" />            
            <Dependency name="EA_LegacyTemplates" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EA_GroupWindow" />
            <Dependency name="EA_ContextMenu" />
        </Dependencies>
        <Files>
            <File name="Source/SocialWindowTemplates.xml" /> 
            <File name="Source/SocialWindowTabSearch.xml" />
            <File name="Source/SocialWindowTabFriends.xml" />
            <File name="Source/SocialWindowTabIgnore.xml" />
            <File name="Source/SocialWindowTabOptions.xml" />
            <File name="Source/SocialWindow.xml" />
            <File name="Source/SocialWindowBuddyListTabFriends.xml" />
            <File name="Source/SocialWindowBuddyList.xml" />
        </Files>
        <OnInitialize>
            <CreateWindow name="SocialWindow" show="false" />
            <CreateWindow name="SocialWindowBuddyList" show="false" />
            <CreateWindow name="SocialWindowBuddyListFilterMenu" show="false" />
            <CreateWindow name="SocialWindowTabFriendsFilterMenu" show="false" />
        </OnInitialize>  
        <SavedVariables>
            <SavedVariable name="SocialWindowBuddyListTabFriends.Settings" />
            <SavedVariable name="SocialWindowTabFriends.Settings" />
            <SavedVariable name="SocialWindowTabFriends.AddvancedFriends" global="true" />
            <SavedVariable name="SocialWindowTabOptions.Settings" />
        </SavedVariables>
	<Replaces name="EA_SocialWindow" />
    </UiMod>
</ModuleFile>