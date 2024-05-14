-- Most of this is taken from EA_TacticsEditor.
if not MoraleSet then 
	MoraleSet = {} 
end
MoraleSet.isDisabled = false;	-- can't change morales in combat
MoraleSet.switchingSet = false;	-- so we don't update sets when we're changing them ourselves
MoraleSet.charName = "default";	-- used to save sets per character
MoraleSet.charData = nil;		-- shortcut
MoraleSet.allowLinking = false;	-- whether or not linking to tactics is possible

local MAX_SETS					= GameData.MAX_TACTICS_SETS;
local CLICK_TO_CHANGE_SET		= L"Click to view alternative morale sets.\nRight-click to link morale sets to tactic sets.";

local BORDER_SIZE               = 15;
local HORIZONTAL_BUTTON_SPACING = 4;
local VERTICAL_BUTTON_SPACING   = 4;
local ANCHOR_ABILITY_TOOLTIP    = { Point = "topleft", RelativeTo = "", RelativePoint = "bottomleft",  XOffset = 5, YOffset = -38 }
local SPACER_WIDTH = 5;

local tacticHook;	-- declared here so we can unhook later

local MoraleSetMenu =
{
	windowName					= "MoraleEditorSetMenu",
	[0]							= { displayString = L"1", },
	[1]							= { displayString = L"2", },
	[2]							= { displayString = L"3", },
	[3]							= { displayString = L"4", },
	[4]							= { displayString = L"5", },
}

function MoraleSetMenu:Initialize ()
	for i = 0, (MAX_SETS - 1) do
		ComboBoxAddMenuItem (self.windowName, self[i].displayString);
	end
	ButtonSetText ("MoraleEditorSetMenuSelectedButton", L""..(MoraleSet.charData.currentSet+1));
end

local MoraleSetTooltip =
{
	numButtons				= 0,
	moraleButtons			= {},
	moraleSlots				= {},
	currentSet				= 0,
	windowName				= "MoraleSetTooltip",
	lineWindowName			= "MoraleSetTooltipButton",
	mouseoverButtonName		= "MoraleEditorSetMenuMenuButton",
};


function MoraleSetTooltip:CreateTooltip(desiredSet)
	if (nil ~= desiredSet) then
		self.currentSet = desiredSet;
	end

	local moraleSet = MoraleSet.charData.set[desiredSet];

	local tooltipWidth		= 0;
	local tooltipHeight		= 0;
	local numInSet			= 0;
	local currentButtonId	= 1;
	local emptySetLabel		= self.windowName.."EmptySetText";

	if (nil ~= moraleSet) then
		numInSet = table.getn (moraleSet);
	end

	self:UnUseAll (true);

	if (numInSet > 0) then
		for key, abilityId in pairs (moraleSet) do

			local abilityData = Player.GetAbilityData (abilityId, GameData.AbilityType.MORALE);
			local abilityName = L"";

			if (nil ~= abilityData and nil ~= abilityData.name) then
				abilityName = abilityData.name;
			end

			local button = self:GetUnusedButton ();

			if (button ~= nil) then
				local buttonName = button:GetName ();

				LabelSetText (buttonName.."MoraleName", abilityName);
				button:SetId (abilityData);

				local imgWidth, imgHeight = WindowGetDimensions (buttonName);
				local txtWidth, txtHeight = LabelGetTextDimensions (buttonName.."MoraleName");

				local totalWidth    = imgWidth + txtWidth + HORIZONTAL_BUTTON_SPACING;
				local totalHeight   = math.max (imgHeight, txtHeight) + VERTICAL_BUTTON_SPACING;

				if (totalWidth > tooltipWidth) then
					tooltipWidth = totalWidth;
				end

				tooltipHeight = totalHeight + tooltipHeight;
				WindowSetShowing (buttonName, true);
			end
		end

	else
		tooltipWidth, tooltipHeight = LabelGetTextDimensions (emptySetLabel);
	end

	WindowSetShowing (emptySetLabel, numInSet == 0);

	local actionWidth, actionHeight = LabelGetTextDimensions (self.windowName.."ActionText");

	local c_ACTION_SPACING = 10; -- give it some spacing...let the tooltip breathe!

	if (actionWidth > tooltipWidth) then
		tooltipWidth = actionWidth;
	end

	tooltipWidth    = tooltipWidth + (BORDER_SIZE * 2);
	tooltipHeight   = tooltipHeight + actionHeight + c_ACTION_SPACING + (BORDER_SIZE * 2);

	WindowSetDimensions (self.windowName, tooltipWidth, tooltipHeight);
end

function MoraleSetTooltip:Initialize()
	self:Shutdown ();

	self.moraleSlots = GameData.NUM_MORALE_LEVELS;

	for i = 1, self.moraleSlots do
		local button = self:CreateButton ();

		if (button ~= nil) then
			self:AnchorButton (button);
		end
	end

	WindowSetTintColor(self.windowName.."BackgroundInner", 0, 0, 0);
	WindowSetAlpha(self.windowName.."BackgroundInner", .7);

	LabelSetText (self.windowName.."EmptySetText", L"Empty Morale Set");
	LabelSetText (self.windowName.."ActionText", L"Click to change morale sets");
end

function MoraleSetTooltip:CreateButton()
	local buttonId = self.numButtons + 1;

	if (buttonId > GameData.NUM_MORALE_LEVELS) then
		return nil;
	end

	local buttonName = self.lineWindowName..buttonId;

	if (DoesWindowExist (buttonName) == true) then
		return nil;
	end

	CreateWindowFromTemplate (buttonName, self.lineWindowName, self.windowName);

	if (DoesWindowExist (buttonName) == false) then
		return nil;
	end

	return (self:AddButton (buttonId, buttonName));
end

function MoraleSetTooltip:AddButton(id, name)
	self.numButtons = self.numButtons + 1;

	WindowSetId (name, id);

	local function ButtonGetName (self)
		return (self.name);
	end

	local function ButtonGetMoraleId (self)
		return (self.moraleId);
	end

	local function ButtonGetWindowId (self)
		return (WindowGetId (self.name));
	end

	local function ButtonSetMorale (self, abilityData)
		if (nil ~= abilityData) then
			self.moraleId = abilityData.id;
		else
			self.moraleId = 0;
		end

		self.isUsed = (abilityData ~= 0);

		local texture, textureX, textureY;

		if (nil == abilityData) then
			--texture, textureX, textureY = GetIconData (4);
			--CircleImageSetTexture (self:GetName (), texture, textureX + 32, textureY + 32);
			WindowSetShowing(self:GetName(), false);
		else
			texture, textureX, textureY = GetIconData (abilityData.iconNum);
			-- apparently CircleImages expect x,y to be the center of the texture.
			CircleImageSetTexture (self:GetName(), texture, textureX + 32, textureY + 32);
			WindowSetShowing(self:GetName(), true);
		end

		
	end

	local function ButtonGetUsed (self)
		return (self.isUsed);
	end

	local function ButtonSetUsed (self, isUsed)
		self.isUsed = isUsed;
	end

	local button =
	{
		name        = name,
		moraleId    = 0,
		isUsed      = false,

		GetName     = ButtonGetName,
		GetId       = ButtonGetMoraleId,
		SetId       = ButtonSetMorale,
		GetUsed     = ButtonGetUsed,
		SetUsed     = ButtonSetUsed,
		GetWindowId = ButtonGetWindowId,
	};

	self.moraleButtons[id] = button;

	return (button);
end

function MoraleSetTooltip:AnchorButton(button)
	local previousButtonId = self.numButtons - 1;

	if (previousButtonId < 0) then
		return;
	end

	local anchorToWindow	= self.windowName
	local offsetX			= BORDER_SIZE;
	local offsetY			= BORDER_SIZE;
	local relativePoint		= "topleft";
	local point				= "topleft";

	if (previousButtonId > 0) then
		anchorToWindow	= self.lineWindowName..previousButtonId;
		offsetX			= 0;
		offsetY			= VERTICAL_BUTTON_SPACING;
		relativePoint	= "top";
		point			= "bottom";
	end

	WindowClearAnchors (button.name);
	WindowAddAnchor (button.name, point, anchorToWindow, relativePoint, offsetX, offsetY);
end

function MoraleSetTooltip:GetUnusedButton ()
	for i = 1, self.numButtons do
		local currentButton = self.moraleButtons[i];

		if (nil ~= currentButton) and (currentButton:GetUsed () == false) then
		   return (currentButton);
		end
	end

	return (nil);
end

function MoraleSetTooltip:UnUseAll(optionallyHideWindowAsWell)
	for buttonId, button in pairs (self.moraleButtons) do
		button:SetUsed (false);

		if (optionallyHideWindowAsWell ~= nil and optionallyHideWindowAsWell == true) then
			WindowSetShowing (button:GetName (), false);
		end
	end
end

function MoraleSetTooltip:Shutdown()
	self.numButtons = 0;

	if (self.moraleButtons == nil) then
		return;
	end

	for k, v in pairs (self.moraleButtons) do
		if (nil ~= v.name) then
			DestroyWindow (v.name);
		end
	end

	self.moraleButtons = {};
	self.moraleSlots   = {};
end

function MoraleSet.NewAbilityLearned ()
	if DoesWindowExist(MoraleSetMenu.windowName) then
		return;
	end
	MoraleSet.Update()
end

function MoraleSet.Initialize ()
	-- register with layour editor
	if LayoutEditor then
		LayoutEditor.RegisterWindow("MoraleEditor", L"Morale Set", L"Displays your current morale ability set.", true, true, true);
	end
		
	-- register events
	WindowRegisterEventHandler("MoraleEditor", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "MoraleSet.UpdateCombatFlag");
	WindowRegisterEventHandler("MoraleEditor", SystemData.Events.PLAYER_MORALE_BAR_UPDATED, "MoraleSet.UpdateSet"); 
	WindowRegisterEventHandler("MoraleEditor", SystemData.Events.PLAYER_NEW_ABILITY_LEARNED, "MoraleSet.NewAbilityLearned");

	-- initialize settings
	if not MoraleSetData then
		MoraleSetData = {};
	end

	MoraleSet.Update()
end


function MoraleSet.Update()
	local Abilities = 0;
	for n in pairs(GetAbilityTable(GameData.AbilityType.MORALE)) do 
		Abilities = Abilities + 1 
	end
	if (Abilities == 0) then
		WindowSetShowing(MoraleSetMenu.windowName,false);
		return;
	end

	local serverName = WStringToString(SystemData.Server.Name);
	local characterName = WStringToString(GameData.Player.name)
	MoraleSet.charName = serverName.."/"..characterName;

	if MoraleSetData[MoraleSet.charName] then
		d("Loading data for "..MoraleSet.charName);
		MoraleSet.charData = MoraleSetData[MoraleSet.charName];
	else
		d("Creating new table for "..MoraleSet.charName);
		MoraleSetData[MoraleSet.charName] = {
			set = { },
			currentSet = 0,
			linkedToTactics = false,
		};
		for i = 0, (MAX_SETS-1) do
			MoraleSetData[MoraleSet.charName].set[i] = { };
		end
		MoraleSet.charData = MoraleSetData[MoraleSet.charName];
		MoraleSet.UpdateSet();
	end

	-- hook into OnSelChanged of EA_TacticsEditorSetMenu
	if(TacticsEditor) then
		MoraleSet.allowLinking = true;
		if(tacticHook == nil) then -- only hook once
			tacticHook = TacticsEditor.OnSetMenuSelectionChanged;
			TacticsEditor.OnSetMenuSelectionChanged = function(currentSelection)
				-- call original method
				tacticHook(currentSelection);
				-- change morales if needed
				if MoraleSet.charData.linkedToTactics then
					if currentSelection > 0 and (currentSelection - 1) ~= MoraleSet.charData.currentSet then
						ComboBoxSetSelectedMenuItem (MoraleSetMenu.windowName, currentSelection);
						MoraleSet.OnSetMenuSelectionChanged(currentSelection);
					end
				end
			end
		end;
		CLICK_TO_CHANGE_SET = L"Click to view alternative morale sets.\nRight-click to link morale sets to tactic sets.";
	else
		MoraleSet.allowLinking = false;
		-- reset linkedToTactics since it won't work, and change tooltip to avoid confusion
		MoraleSet.charData.linkedToTactics = false;
		CLICK_TO_CHANGE_SET = L"Click to view alternative morale sets.";
	end

	MoraleSetMenu:Initialize ();

	CreateWindow (MoraleSetTooltip.windowName, false);
	MoraleSetTooltip:Initialize ();

	MoraleSet.UpdateCombatFlag();
end

function MoraleSet.Shutdown ()
	--this could break mods that hook the same method
	if tacticHook then
		TacticsEditor.OnSetMenuSelectionChanged = tacticHook;
		tacticHook = nil;
	end

	MoraleSetTooltip:Shutdown ();

	WindowUnregisterEventHandler( "MoraleEditor", SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED);
	WindowUnregisterEventHandler( "MoraleEditor", SystemData.Events.PLAYER_MORALE_BAR_UPDATED);
	WindowUnregisterEventHandler("MoraleEditor", SystemData.Events.PLAYER_NEW_ABILITY_LEARNED, "MoraleSet.NewAbilityLearned");
	if LayoutEditor then
		LayoutEditor.UnregisterWindow("MoraleEditor");
	end
end

local function GetMousedOverSetMenuItem()
	local windowName = SystemData.ActiveWindow.name;
	if (windowName == MoraleSetTooltip.mouseoverButtonName.."1") then
		return 0;
	elseif (windowName == MoraleSetTooltip.mouseoverButtonName.."2") then
		return 1;
	elseif (windowName == MoraleSetTooltip.mouseoverButtonName.."3") then
		return 2;
	elseif (windowName == MoraleSetTooltip.mouseoverButtonName.."4") then
		return 3;
	else
		return 4;
	end
end

-- called when the player mouses over the combo box
function MoraleSet.MenuTooltip ()
	if (GameData.Player.inCombat) then
		Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, L"Cannot edit morales while in combat.");
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
	elseif (MoraleSet.charData.linkedToTactics) then
		Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, L"Right-click to unlink morale and tactic sets.");
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
	elseif (not ComboBoxIsMenuOpen("MoraleEditorSetMenu")) then
		Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name, CLICK_TO_CHANGE_SET);
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_TOP);
	else
		MoraleSetTooltip:CreateTooltip(GetMousedOverSetMenuItem());
		Tooltips.CreateCustomTooltip (SystemData.ActiveWindow.name, MoraleSetTooltip.windowName);
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_WINDOW_RIGHT);
	end
end

function MoraleSet.UpdateCombatFlag ()
	MoraleSet.isDisabled = GameData.Player.inCombat;
	ComboBoxSetDisabledFlag ("MoraleEditorSetMenu", MoraleSet.charData.linkedToTactics or MoraleSet.isDisabled);
end

function MoraleSet.OnSetMenuSelectionChanged (currentSelection)
	-- sets are 0-based, combo box selection 1-based
	if (MoraleSet.charData.currentSet == currentSelection - 1) then
		return;
	end
	MoraleSet.charData.currentSet = currentSelection - 1;
	
	-- temporarily prevent updating of sets
	MoraleSet.switchingSet = true;
	local abilityId;
	for i = 1, GameData.NUM_MORALE_LEVELS do
		abilityId = MoraleSet.charData.set[MoraleSet.charData.currentSet][i];
		-- do not remove morales/do not leave empty slots
		if(abilityId and abilityId > 0) then
			SetMoraleBarData(i, abilityId)
		end
	end
	MoraleSet.switchingSet = false;

	ButtonSetText ("MoraleEditorSetMenuSelectedButton", L""..(MoraleSet.charData.currentSet+1));
end

function MoraleSet.OnMouseOverSetMenu (flags, x, y)
end

function MoraleSet.OnLButtonUpSetMenu (flags, x, y)
	if (MoraleSet.charData.linkedToTactics or MoraleSet.isDisabled) then
		return;
	end
end

function MoraleSet.OnRButtonUpSetMenu (flags, x, y)
	if (MoraleSet.isDisabled or not MoraleSet.allowLinking) then
		return;    
	end
	if (not MoraleSet.charData.linkedToTactics) then
		MoraleSet.charData.linkedToTactics = true;
		ComboBoxSetDisabledFlag ("MoraleEditorSetMenu", true);
		local currentSelection = ComboBoxGetSelectedMenuItem("EA_TacticsEditorSetMenu");
		-- after login / UI reload currentSelection is 0 until the player changes sets. The tactic editor guesses which set is active and displays the number, so let's use that.
		if currentSelection == 0 then
			currentSelection = tonumber( ButtonGetText("EA_TacticsEditorSetMenuSelectedButton") ) or 1;
		end
		if currentSelection > 0 and (currentSelection - 1) ~= MoraleSet.charData.currentSet then
			ComboBoxSetSelectedMenuItem (MoraleSetMenu.windowName, currentSelection);
			MoraleSet.OnSetMenuSelectionChanged(currentSelection);
		end

	else
		MoraleSet.charData.linkedToTactics = false;
		-- we can do this because we won't get here if MoraleSet.isDisabled
		ComboBoxSetDisabledFlag ("MoraleEditorSetMenu", false);
	end
	-- update tooltip
	--Tooltips.ClearTooltip();
	MoraleSet.MenuTooltip();	-- meh, doesn't work
end

function MoraleSet.UpdateSet()
	-- we're changing sets right now, ignore this
	if MoraleSet.switchingSet then
		return;
	end
	local _, abilityId;
	for i = 1, GameData.NUM_MORALE_LEVELS do
		_, abilityId = GetMoraleBarData(i);
		if abilityId == 0 then
			-- we do this so we won't have empty buttons in the tooltip
			MoraleSet.charData.set[MoraleSet.charData.currentSet][i] = nil;
		else
			MoraleSet.charData.set[MoraleSet.charData.currentSet][i] = abilityId;
		end
	end
end

