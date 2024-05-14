local Enemy = Enemy
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs
local InterfaceCore = InterfaceCore

local Icons =
{
	effect =
	{
		key = "effect",
		name = L"effect",
		texture = "enemy_unitframe_effect",
		x = 0, y = 0,
		width = 6, height = 9
	},

	effect2 =
	{
		key = "effect2",
		name = L"effect2",
		texture = "enemy_unitframe_effect2",
		x = 0, y = 0,
		width = 32, height = 32
	},

	guard =
	{
		key = "guard",
		name = L"guard",
		texture = "enemy_unitframe_guard",
		x = 0, y = 0,
		width = 16, height = 16
	},

	question =
	{
		key = "question",
		name = L"question",
		texture = "enemy_unitframe_question",
		x = 0, y = 0,
		width = 32, height = 32
	},

	stagger =
	{
		key = "stagger",
		name = L"stagger",
		texture = "enemy_unitframe_stagger",
		x = 0, y = 0,
		width = 32, height = 32
	},

	heal  =
	{
		key = "heal",
		name = L"heal debuff",
		texture = "enemy_unitframe_healdebuff",
		x = 0, y = 0,
		width = 32, height = 32
	},

	disabled =
	{
		key = "disabled",
		name = L"disabled",
		texture = "enemy_unitframe_disabled",
		x = 0, y = 0,
		width = 32, height = 32
	},

	dot =
	{
		key = "dot",
		name = L"dot",
		texture = "enemy_1dot",
		x = 0, y = 0,
		width = 10, height = 10
	}
}

Enemy.EffectsIndicatorIcons = Icons		-- for other addons

--------------------------------------------------------------- EnemyEffectsIndicator class
EnemyEffectsIndicator = {}
EnemyEffectsIndicator.__index = EnemyEffectsIndicator

function EnemyEffectsIndicator.New (data)
	local obj = {}
	setmetatable (obj, EnemyEffectsIndicator)

	-- defaults
	obj.id = tostring (Enemy.NewId ())
	obj.isEnabled = true
	obj.name = nil
	obj.logic = nil
	obj.canDispell = 1
	obj.playerTypeMatch = 1
	obj.playerType = 3
	obj.exceptMe = false
	obj.archetypeMatch = 1
	obj.archetypes = { false, false, false }

	obj.effectFilters = {}

	obj.icon = "effect"
	obj.customIcon = nil
	obj.isCircleIcon = false
	obj.isTimer = false
	obj.color = { r = 255, g = 255, b = 255 }
	obj.alpha = 1
	obj.scale = 1

	obj.labelScale = 1


	obj.anchorFrom = 5
	obj.anchorTo = 5
	obj.offsetX = 20
	obj.offsetY = nil
	obj.width = nil

	obj.height = nil

	obj.ticked = 0
	obj.left = 0
	
	obj.PlayerHPMin = 0
	obj.PlayerHPMax = 100

	if (data)
	then
		obj:Load (data)
	end

	return obj
end


function EnemyEffectsIndicator:Load (data)

	self.name = data.name
	self.isEnabled = data.isEnabled
	self.logic = data.logic
	self.canDispell = data.canDispell
	self.playerTypeMatch = data.playerTypeMatch
	self.playerType = data.playerType
	self.exceptMe = data.exceptMe
	self.archetypeMatch = data.archetypeMatch

	if (data.archetypes)
	then
		self.archetypes =
		{
			data.archetypes[1] or false,
			data.archetypes[2] or false,
			data.archetypes[3] or false
		}
	end

	self.PlayerHPMin = data.PlayerHPMin
	self.PlayerHPMax = data.PlayerHPMax
	
	if (data.effectFilters)
	then
		self.effectFilters = {}

		for _, effect_filter in pairs (data.effectFilters)
		do
			tinsert (self.effectFilters, EnemyEffectFilter.New (effect_filter))
		end
	end

	self.icon = data.icon
	self.customIcon = data.customIcon
	self.isCircleIcon = data.isCircleIcon
	self.isTimer = data.isTimer


	if (data.color)
	then
		self.color =
		{
			r = data.color.r or 0,
			g = data.color.g or 0,
			b = data.color.b or 0
		}
	end

	self.alpha = data.alpha
	self.labelScale = data.labelScale

	self.scale = data.scale
	self.anchorFrom = data.anchorFrom
	self.anchorTo = data.anchorTo
	self.offsetX = data.offsetX
	self.offsetY = data.offsetY
	self.width = data.width
	self.height = data.height

	self._archetypesFilterPresent = (self.archetypes[1] or self.archetypes[2] or self.archetypes[3])

	self.ticked = 0
	self.left = 0

	-- prepare logic data and functions
	if (self.logic)
	then
		self._logicExpression = Enemy.LogicalExpressionParse (Enemy.toString (self.logic))

		self._effectFiltersByNames = {}
		for _, effect_filter in pairs (self.effectFilters)
		do
			self._effectFiltersByNames[Enemy.toString (effect_filter.filterName)] = effect_filter
		end
	else
		self._logicExpression = nil
	end

	-- prepare can dispell check function
	if (self.canDispell ~= 1)
	then
		if (not Enemy.groups.canCleanse)
		then
			self._checkDispell = function (player, effect)
				return (self.canDispell == 3)
			end

		else
			if (Enemy.groups.canCleanse == "self")
			then
				self._checkDispell = function (player, effect)

					return (
								player.isSelf
								and
								(
									(
										(effect.isHex and Enemy.groups.canCleanseHex)
										or
										(effect.isAilment and Enemy.groups.canCleanseAilment)
										or
										(effect.isCurse and Enemy.groups.canCleanseCurse)

									) == (self.canDispell == 2)
								)
							)
				end
			else
				self._checkDispell = function (player, effect)

					return (
								(effect.isHex and Enemy.groups.canCleanseHex)
								or
								(effect.isAilment and Enemy.groups.canCleanseAilment)
								or
								(effect.isCurse and Enemy.groups.canCleanseCurse)

							) == (self.canDispell == 2)
				end
			end
		end
	end
end


function EnemyEffectsIndicator:Hide ()
	if (not self.windowName) then return end
	WindowSetShowing (self.windowName, false)

--	if (self.recheckTimer)
--	then
--		self.recheckTimer:Remove ()
--		self.recheckTimer = nil
--	end
end


function EnemyEffectsIndicator:Show ()
	if (not self.windowName) then return end
	WindowSetShowing (self.windowName, true)
end


function EnemyEffectsIndicator:Edit (settings, onOkCallback)

	Enemy.UnitFramesUI_EffectsIndicatorDialog_Open (self, settings, self.id, function (old, new)

		old:Load (new)

		if (onOkCallback)
		then
			onOkCallback (self)
		end
	end)
end


function EnemyEffectsIndicator:Remove ()

--	if (self.recheckTimer)
--	then
--		self.recheckTimer:Remove ()
--		self.recheckTimer = nil
--	end

	if (self.windowName)
	then
		if (DoesWindowExist (self.windowName)) then DestroyWindow (self.windowName) end
		self.windowName = nil
	end

	self:BoundingBoxSetShowing (false)
end


function EnemyEffectsIndicator:BoundingBoxSetShowing (show)

	if (self._boundingBoxWindowName)
	then
		if (DoesWindowExist (self._boundingBoxWindowName)) then DestroyWindow (self._boundingBoxWindowName) end
		self._boundingBoxWindowName = nil
	end

	if (show and self.windowName)
	then
		self._boundingBoxWindowName = "BoundingBox"..Enemy.NewId ()
		CreateWindowFromTemplate (self._boundingBoxWindowName, "EnemyRectangleTemplate", self.windowName)
		WindowSetLayer (self._boundingBoxWindowName, Window.Layers.OVERLAY)
		WindowAddAnchor (self._boundingBoxWindowName, "topleft", self.windowName, "topleft", 0, 0)
		WindowAddAnchor (self._boundingBoxWindowName, "bottomright", self.windowName, "bottomright", 0, 0)
	end
end


function EnemyEffectsIndicator:Update (frame)

	if (not frame) then return end

	if (not self.windowName)
	then
		self.windowName = "EnemyEffectsIndicator"..self.id

		if (self.isCircleIcon)
		then
			CreateWindowFromTemplate (self.windowName, "EnemyCircleImageTemplate", frame.windowName)
		else
			CreateWindowFromTemplate (self.windowName, "EnemyDynamicImageTemplate", frame.windowName)
		end

		WindowSetShowing (self.windowName, false)

		self.isCircleIconCurrent = self.isCircleIcon
		WindowSetLayer (self.windowName, Window.Layers.POPUP)

	elseif (self.isCircleIcon ~= self.isCircleIconCurrent)
	then
		self:Remove ()
		self:Update (frame)
		return
	end

	local texture = nil
	local texture_x = 0
	local texture_y = 0
	local dx, dy

	local icon = Icons[self.icon]
	if (icon)
	then
		texture = icon.texture
		texture_x = icon.x
		texture_y = icon.y
		dx = icon.width
		dy = icon.height
	else
		texture, texture_x, texture_y = GetIconData (self.customIcon or 1)
		dx, dy = 64, 64
	end

	if (self.width ~= nil) then dx = self.width end
	if (self.height ~= nil) then dy = self.height end

	local global_scale = InterfaceCore.GetScale ()

	WindowSetDimensions (self.windowName, dx, dy)
	WindowSetScale (self.windowName, self.scale * frame.settings.unitFramesScale * global_scale)
	if (self.labelScale == nil) then
		self.labelScale = 1
	end
	if (self.isTimer == nil) then
		self.isTimer = false
	end
	WindowSetScale (self.windowName.."TLabel", self.labelScale * frame.settings.unitFramesScale * global_scale)
	WindowSetShowing(self.windowName.."TLabel", self.isTimer)


	WindowClearAnchors (self.windowName)
	WindowAddAnchor (self.windowName, Enemy.Anchors[self.anchorFrom], frame.windowName, Enemy.Anchors[self.anchorTo], self.offsetX or 0, self.offsetY or 0)

	if (self.isCircleIcon)
	then
		CircleImageSetTexture (self.windowName, texture, texture_x + dx / 2, texture_y + dy / 2)
	else
		DynamicImageSetTexture (self.windowName, texture, texture_x, texture_y)
	end

	WindowSetTintColor (self.windowName, self.color.r, self.color.g, self.color.b)
	WindowSetAlpha (self.windowName, self.alpha)
end


--
-- Check wherever any effect on specified player can possibly light up this effect indicator
--
function EnemyEffectsIndicator:CanMatch (player)

	return not
		(
			-- player type filter
			(
				(
					self.playerType == 2
					and not (player.isSelf == (self.playerTypeMatch == 1))
				)
				or
				(
					self.playerType == 3
					and not (player.isInPlayerGroup == (self.playerTypeMatch == 1))
				)
			)

			or

			-- except me
			(
				self.exceptMe and player.isSelf
			)

			or

			-- archetypes filter
			(
				self._archetypesFilterPresent
				and
				(self.archetypes[Enemy.careerArchetypes[player.career]] ~= (self.archetypeMatch == 1))
			)

			or

			-- can dispell filter
			(
				self.canDispell == 2
				and
				(
					not Enemy.groups.canCleanse
					or
					(Enemy.groups.canCleanse == "self" and not player.isSelf)
				)
			)
		)
end


function EnemyEffectsIndicator:EffectsUpdated (player, testMode)

	local show
	--      d("indicator effects updated")
	--	looking for timer
	-- SCarfaXX
		local show
		local wd, hg
	-- !!

	-- GameData
	-- d(Enemy.groups.players[L"Yoursoul"].effects[1280])
		if (self.recheckTimer)
		then
			--d(self)
			self.recheckTimer:Remove ()
			self.recheckTimer = nil
			local str_time = L""
			if (self.left > 0) then
				str_time = str_time..(self.left+1)
			end
	                if (not(self.windowName == nil)) then
				wd, hg = WindowGetDimensions(self.windowName)
				if ((wd > 20) and (hg > 20)) then
					LabelSetText (self.windowName.."TLabel", str_time)
				end
			end
		end
	-- !!
	if (testMode)
	then
		show = true
	else
		show = false

		-- filter effects
		for _, effect in pairs (player.effects)
		do
			if (self._checkDispell and not self._checkDispell (player, effect)) then continue end

			local match = false

			if (self._logicExpression == nil)
			then
				-- simple 'or' logic
				for _, effect_filter in ipairs (self.effectFilters)
				do
					if (effect_filter:IsMatch (effect))
					then
						match = true
						break
					end
				end
			else
				-- custom logic expression
				match = Enemy.LogicalExpressionEvaluate (self._logicExpression, function (f)
					return self._effectFiltersByNames[f]:IsMatch (effect)
				end)
			end

			--d (tostring (effect.abilityId).." "..tostring (match)..", "..tostring (effect_filter.filterName)..":IsMatch () = "..tostring (effect_filter:IsMatch (effect)))

			if (match)
			then
			--!!				-- put up a recheck timer if needed
							if (effect.duration > 0)

							then
								if ((self.ticked == nil) or (self.ticked == 0)) then
									self.ticked = Enemy.time + effect.duration
								end
								self.recheckTimer = EnemyTimer.New ("ei_check"..self.id, 0.1, function ()
									--d (Enemy._GroupsDebugGetEffectsNames (Enemy.groups.players[name].effects))
									self.left = math.floor(self.ticked - Enemy.time)
									self:EffectsUpdated (player, testMode)
									--d(self.effects)
									return true
								end)

							end
				local PlayerHPMin = tonumber(Enemy.isNil(self.PlayerHPMin, L"0"))
				local PlayerHPMax = tonumber(Enemy.isNil(self.PlayerHPMax, L"100"))
				if (player.hp >= PlayerHPMin) and (player.hp <= PlayerHPMax) then
					show = true
					break
				end
			--!!
			end
		end
	end
	if (not show) then self.ticked = 0 end
	if (self.windowName) then
		WindowSetShowing (self.windowName, show)
	end
end


----------------------------------------------------------------- UI: Effect indicator dialog
local dlg =
{
	isInitialized = false,
	effectFiltersListSelectedIndex = nil,
	exampleConfigParameters =
	{
		exampleShowBoundingBox =
		{
			key = "exampleShowBoundingBox",
			order = 10,
			name = L"Show bounding box",
			type = "bool",
			default = false,
			windowWidth = 300
		},
		exampleShowUnitFrameBoundingBox =
		{
			key = "exampleShowUnitFrameBoundingBox",
			order = 20,
			name = L"Show unit frame bounding box",
			type = "bool",
			default = false,
			windowWidth = 300
		},
		exampleHideOthers =
		{
			key = "exampleHideOthers",
			order = 30,
			name = L"Hide other effects indicators",
			type = "bool",
			default = true,
			windowWidth = 300
		},
		exampleNew =
		{
			key = "exampleNew",
			order = 40,
			name = L"New example",
			type = "button",
			windowWidth = 150
		}
	}
}


function Enemy.UnitFramesUI_EffectsIndicatorDialog_IsOpen ()
	return WindowGetShowing ("EnemyEffectsIndicatorDialog")
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_Hide ()

	dlg.example:Remove ()
	dlg.data:Remove ()
	if (dlg.wnExampleCfg and DoesWindowExist (dlg.wnExampleCfg)) then DestroyWindow (dlg.wnExampleCfg) end

	WindowSetShowing ("EnemyEffectsIndicatorDialog", false)
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_Open (data, settings, ignoreId, onOkCallback)

	dlg.isLoading = true

	if (not dlg.isInitialized)
	then
		-- initialize dialog UI
		CreateWindow ("EnemyEffectsIndicatorDialog", false)

		LabelSetText ("EnemyEffectsIndicatorDialogTitleBarText", L"Effects indicator")
		ButtonSetText ("EnemyEffectsIndicatorDialogOkButton", L"OK")
		ButtonSetText ("EnemyEffectsIndicatorDialogCancelButton", L"Cancel")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildNameLabel", L"Name")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersLabel", L"Effect filters")
		WindowSetTintColor ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersListBackground", 100, 100, 100)
		WindowSetAlpha ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersListBackground", 0.5)
		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersAddButton", L"Add")
		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersEditButton", L"Edit")
		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDeleteButton", L"Delete")
		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersUpButton", L"Up")
		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDownButton", L"Down")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildLogicLabel", L"Logic")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildCanDispellLabel", L"I can dispell it")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildCanDispell", L"doesn't matter")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildCanDispell", L"yes")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildCanDispell", L"no")

		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerTypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerTypeMatch", L"Except for")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerType", L"all")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerType", L"me")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerType", L"my group")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildExceptMeLabel", L"except me")

		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildArchetypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildArchetypeMatch", L"Except for")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildArchetype1Label", L"tanks")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildArchetype2Label", L"dps")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildArchetype3Label", L"healers")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildIconLabel", L"Icon")

		dlg.iconsData = {}
		for _, v in pairs(Icons)
		do
			tinsert (dlg.iconsData, v)
		end

		tsort (dlg.iconsData, function (a, b)
			return a.name < b.name
		end)

		tinsert (dlg.iconsData,
		{
			key = "other",
			name = L"other"
		})

		for _, v in ipairs (dlg.iconsData)
		do
			ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildIcon", v.name)
		end

		ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildIcon", L"other")

		ButtonSetText ("EnemyEffectsIndicatorDialogContentScrollChildChooseIconButton", L"choose")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildCircleIconLabel", L"circle")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildSizeLabel", L"Size override (XY)")

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildColorLabel", L"Color (RGB)")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildAlphaLabel", L"Alpha")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildScaleLabel", L"Scale")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildLScaleLabel", L"Text Scale")
                LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildLScaleCheckLabel", L"enabled")


		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildAnchorLabel", L"Anchor")
		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildAnchorLabel2", L"to")

		for _, v in pairs (Enemy.Anchors)
		do
			ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorFrom", Enemy.toWString (v))
			ComboBoxAddMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorTo", Enemy.toWString (v))
		end

		LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildOffsetLabel", L"Offset (XY)")

		dlg.isInitialized = true
	end

	-- proceed parameters
	dlg.oldData = data
	dlg.onOkCallback = onOkCallback

	dlg.data = EnemyEffectsIndicator.New (data)

	dlg.settings =
	{
		effectsIndicators = {},
		clickCastings = {}
	}

	if (settings)
	then
		for k, v in pairs (settings)
		do
			if (not k:match("^unitFrames.*")) then continue end
			dlg.settings[k] = v
		end

		if (settings.effectsIndicators)
		then
			for _, effect_indicator in pairs (settings.effectsIndicators)
			do
				if (effect_indicator.id == ignoreId or not effect_indicator.isEnabled) then continue end
				tinsert (dlg.settings.effectsIndicators, Enemy.clone (effect_indicator))
			end
		end
	end

	dlg.settings.unitFramesTestMode = true

	-- example
	dlg.example = EnemyUnitFrame.New (100 + Enemy.NewId (), 100 + Enemy.NewId ())
	dlg.example:ApplySettings (dlg.settings)
	dlg.example:Enable ()

	dlg.examplePlayer = EnemyPlayer.GetRandomExample ()
	dlg.example:Update (dlg.examplePlayer)

	WindowClearAnchors (dlg.example.windowName)
	WindowAddAnchor (dlg.example.windowName, "topright", "EnemyEffectsIndicatorDialog", "topleft", 50, 200)
	WindowSetLayer (dlg.example.windowName, Window.Layers.OVERLAY)

	dlg.wnExampleCfg = "EnemyEffectsIndicatorDialogExampleCfg"
	dlg.exampleConfigParameters.exampleNew.onClick = Enemy.UnitFramesUI_EffectsIndicatorDialog_OnNewExampleClick
	Enemy.CreateConfigurationWindow (dlg.wnExampleCfg, "Root", dlg.exampleConfigParameters, Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample)
	WindowClearAnchors (dlg.wnExampleCfg)
	WindowAddAnchor (dlg.wnExampleCfg, "bottomleft", dlg.example.windowName, "topleft", 0, 50)

	-- fill form

	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildName", Enemy.isNil (dlg.data.name, L""))

	dlg.effectFiltersListSelectedIndex = nil

	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildLogic", Enemy.isNil (dlg.data.logic, L""))

	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildCanDispell", dlg.data.canDispell)
	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerTypeMatch", dlg.data.playerTypeMatch)
	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerType", dlg.data.playerType)
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildExceptMe", dlg.data.exceptMe)

	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildArchetypeMatch", dlg.data.archetypeMatch)
	for k, a in pairs(dlg.data.archetypes)
	do
		ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildArchetype"..k, a)
	end

	for k, v in pairs (dlg.iconsData)
	do
		if (v.key == dlg.data.icon)
		then
			ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildIcon", k)
		end
	end

	LabelSetText ("EnemyEffectsIndicatorDialogContentScrollChildPlayerHPLabel", L"On player hp (in %)")
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildPlayerHPMin", Enemy.toWStringOrEmpty (dlg.data.PlayerHPMin))
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildPlayerHPMax", Enemy.toWStringOrEmpty (dlg.data.PlayerHPMax))	
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildCircleIcon", dlg.data.isCircleIcon)
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildLScaleCheckBox", dlg.data.isTimer)
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildSizeX", Enemy.toWStringOrEmpty (dlg.data.width))
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildSizeY", Enemy.toWStringOrEmpty (dlg.data.height))
	SliderBarSetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorR", dlg.data.color.r / 255.0)
	SliderBarSetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorG", dlg.data.color.g / 255.0)
	SliderBarSetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorB", dlg.data.color.b / 255.0)
	SliderBarSetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildAlpha", dlg.data.alpha)
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildScale", Enemy.toWString (dlg.data.scale))
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildLScale", Enemy.toWString (dlg.data.labelScale))
	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorFrom", dlg.data.anchorFrom)

	ComboBoxSetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorTo", dlg.data.anchorTo)
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildOffsetX", Enemy.toWStringOrEmpty (dlg.data.offsetX))
	TextEditBoxSetText ("EnemyEffectsIndicatorDialogContentScrollChildOffsetY", Enemy.toWStringOrEmpty (dlg.data.offsetY))

	Enemy.ConfigurationWindowReset (dlg.wnExampleCfg)

	dlg.isLoading = false
	WindowSetShowing ("EnemyEffectsIndicatorDialog", true)

	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()
	Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
	Enemy.UnitFramesUI_EffectsIndicatorDialog_OnIconSelChanged ()

	ScrollWindowSetOffset ("EnemyEffectsIndicatorDialogContent", 0)
	ScrollWindowUpdateScrollRect ("EnemyEffectsIndicatorDialogContent")
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListPopulate ()

	if (dlg.isLoading or not EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersList.PopulatorIndices) then return end

	local row_window_name
	local data

	for k, v in ipairs (EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersList.PopulatorIndices)
	do
		row_window_name = "EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersListRow"..k
		data = Enemy.effectsIndicatorEffectsListData[v]

		if (v == dlg.effectFiltersListSelectedIndex)
		then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 200, 200, 100)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end
	end
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateEffectFiltersList ()

	if (dlg.isLoading) then return end

	Enemy.effectsIndicatorEffectsListData = {}
	Enemy.effectsIndicatorEffectsListIndexes = {}

	for k, data in ipairs(dlg.data.effectFilters)
	do
		tinsert (Enemy.effectsIndicatorEffectsListData, data)
		tinsert (Enemy.effectsIndicatorEffectsListIndexes, k)
	end

	ListBoxSetDisplayOrder ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersList", Enemy.effectsIndicatorEffectsListIndexes)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListLButtonUp ()

	if (dlg.isLoading) then return end

	local data_index = ListBoxGetDataIndex ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersList", WindowGetId (SystemData.MouseOverWindow.name))

	if (data_index == nil)
	then
		dlg.effectFiltersListSelectedIndex = nil
	else
		dlg.effectFiltersListSelectedIndex = Enemy.effectsIndicatorEffectsListIndexes[data_index]
	end

	Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()

	if (dlg.isLoading) then return end

	if (not dlg.data.effectFilters[dlg.effectFiltersListSelectedIndex])
	then
		dlg.effectFiltersListSelectedIndex = nil
	end

	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateEffectFiltersList ()
	ButtonSetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersEditButton", dlg.effectFiltersListSelectedIndex == nil)
	ButtonSetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDeleteButton", dlg.effectFiltersListSelectedIndex == nil)
	ButtonSetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersUpButton", dlg.effectFiltersListSelectedIndex == nil or dlg.effectFiltersListSelectedIndex == 1)
	ButtonSetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDownButton", dlg.effectFiltersListSelectedIndex == nil or dlg.effectFiltersListSelectedIndex == #dlg.data.effectFilters)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_EffectFiltersAdd ()

	if (dlg.isLoading) then return end

	local effect_filter = EnemyEffectFilter.New ()
	effect_filter:Edit (function (effectFilter)

		tinsert (dlg.data.effectFilters, effectFilter)

		dlg.effectFiltersListSelectedIndex = #dlg.data.effectFilters
		Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
	end)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_EffectFiltersEdit ()

	if (dlg.isLoading
		or not dlg.effectFiltersListSelectedIndex
		or ButtonGetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersEditButton")) then return end

	local effect_filter = dlg.data.effectFilters[dlg.effectFiltersListSelectedIndex]
	effect_filter:Edit (function (effectFilter)
		Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateEffectFiltersList ()
	end)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_EffectFiltersDelete ()

	if (dlg.isLoading
		or not dlg.effectFiltersListSelectedIndex
		or ButtonGetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Delete effect filter '"..Enemy.isNil (dlg.data.effectFilters[dlg.effectFiltersListSelectedIndex].filterName, L"")..L"' ?",
                                       L"Yes", function ()

                                       		table.remove (dlg.data.effectFilters, dlg.effectFiltersListSelectedIndex)
                                       		dlg.effectFiltersListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
                                       end,
                                       L"No")
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_EffectFiltersUp ()

	if (not dlg.effectFiltersListSelectedIndex
		or ButtonGetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersUpButton")) then return end

	local index = dlg.effectFiltersListSelectedIndex

	local tmp = dlg.data.effectFilters[index - 1]
	dlg.data.effectFilters[index - 1] = dlg.data.effectFilters[index]
	dlg.data.effectFilters[index] = tmp

	dlg.effectFiltersListSelectedIndex = index - 1
	Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_EffectFiltersDown ()

	if (not dlg.effectFiltersListSelectedIndex
		or ButtonGetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildEffectFiltersDownButton")) then return end

	local index = dlg.effectFiltersListSelectedIndex

	local tmp = dlg.data.effectFilters[index + 1]
	dlg.data.effectFilters[index + 1] = dlg.data.effectFilters[index]
	dlg.data.effectFilters[index] = tmp

	dlg.effectFiltersListSelectedIndex = index + 1
	Enemy.UnitFramesUI_EffectsIndicatorDialog_OnEffectFiltersListSelChanged ()
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnExceptMeChanged ()

	if (dlg.isLoading) then return end

	dlg.data.exceptMe = not dlg.data.exceptMe
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildExceptMe", dlg.data.exceptMe)
end


local function _OnArchetypeChanged (n)

	if (dlg.isLoading) then return end

	dlg.data.archetypes[n] = not dlg.data.archetypes[n]
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildArchetype"..n, dlg.data.archetypes[n])
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnArchetype1Changed ()
	_OnArchetypeChanged (1)
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnArchetype2Changed ()
	_OnArchetypeChanged (2)
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnArchetype3Changed ()
	_OnArchetypeChanged (3)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnIconSelChanged ()

	if (dlg.isLoading) then return end

	local value = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildIcon")
	ButtonSetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildChooseIconButton", value <= #Icons)
	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_ChooseIcon ()

	if (dlg.isLoading or ButtonGetDisabledFlag ("EnemyEffectsIndicatorDialogContentScrollChildChooseIconButton")) then return end

	Enemy.UI_ChooseIconDialog_Open (function (iconId)
		dlg.data.customIcon = iconId
		Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()
	end)
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnCircleIconChanged ()

	if (dlg.isLoading) then return end

	dlg.data.isCircleIcon = not dlg.data.isCircleIcon
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildCircleIcon", dlg.data.isCircleIcon)
	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()
end

function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnLScaleCheckBoxChanged()

	if (dlg.isLoading) then return end

	dlg.data.isTimer = not dlg.data.isTimer
	ButtonSetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildLScaleCheckBox", dlg.data.isTimer)
	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()

	if (dlg.isLoading) then return end

	-- get data from form
	dlg.data.name = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildName"), nil)
	dlg.data.logic = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildLogic"), nil)
	dlg.data.canDispell = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildCanDispell")

	dlg.data.playerTypeMatch = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerTypeMatch")
	dlg.data.playerType = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildPlayerType")

	dlg.data.archetypeMatch = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildArchetypeMatch")
	dlg.data.archetypes =
	{
		ButtonGetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildArchetype1"),
		ButtonGetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildArchetype2"),
		ButtonGetPressedFlag ("EnemyEffectsIndicatorDialogContentScrollChildArchetype3")
	}

	dlg.data.icon = dlg.iconsData[ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildIcon")].key
	dlg.data.width = Enemy.clamp (1, 1000, Enemy.ConvertToInteger (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildSizeX")))
	dlg.data.height = Enemy.clamp (1, 1000, Enemy.ConvertToInteger (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildSizeY")))
	dlg.data.color.r = math.floor (SliderBarGetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorR") * 255.0 + 0.5)
	dlg.data.color.g = math.floor (SliderBarGetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorG") * 255.0 + 0.5)
	dlg.data.color.b = math.floor (SliderBarGetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildColorB") * 255.0 + 0.5)
	dlg.data.alpha = SliderBarGetCurrentPosition ("EnemyEffectsIndicatorDialogContentScrollChildAlpha")
	dlg.data.scale = Enemy.clamp (0, 10, Enemy.isNil (Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildScale")), 0))
	dlg.data.labelScale = Enemy.clamp (0, 10, Enemy.isNil (Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildLScale")), 0))
	dlg.data.labelScale = Enemy.clamp (0, 10, Enemy.isNil (Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildLScale")), 0))
	dlg.data.anchorFrom = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorFrom")
	dlg.data.anchorTo = ComboBoxGetSelectedMenuItem ("EnemyEffectsIndicatorDialogContentScrollChildAnchorTo")
	dlg.data.offsetX = Enemy.clamp (-5000, 5000, Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildOffsetX")))
	dlg.data.offsetY = Enemy.clamp (-5000, 5000, Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectsIndicatorDialogContentScrollChildOffsetY")))
	dlg.data.PlayerHPMin = Enemy.clamp (0, 100, Enemy.isNil (Enemy.ConvertToFloat(TextEditBoxGetText("EnemyEffectsIndicatorDialogContentScrollChildPlayerHPMin")), 0))
	dlg.data.PlayerHPMax = Enemy.clamp (0, 100, Enemy.isNil (Enemy.ConvertToFloat(TextEditBoxGetText("EnemyEffectsIndicatorDialogContentScrollChildPlayerHPMax")), 0))

	Enemy.ConfigurationWindowSaveData (dlg.wnExampleCfg, dlg)

	for _, v in pairs (dlg.settings.effectsIndicators)
	do
		v.isEnabled = not dlg.exampleHideOthers
	end

	dlg.example.forcePlayerChanged = true
	dlg.example:Update (dlg.examplePlayer)
	dlg.example:UpdateEffects (dlg.examplePlayer)
	dlg.example:BoundingBoxSetShowing (dlg.exampleShowUnitFrameBoundingBox)

	dlg.data:Update (dlg.example)
	dlg.data:EffectsUpdated (dlg.examplePlayer, true)
	dlg.data:BoundingBoxSetShowing (dlg.exampleShowBoundingBox)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_OnNewExampleClick ()

	dlg.data:Remove ()

	for _, v in pairs (dlg.settings.effectsIndicators)
	do
		v.isEnabled = not dlg.exampleHideOthers
	end

	dlg.examplePlayer = EnemyPlayer.GetRandomExample ()
	dlg.example.forcePlayerChanged = true
	dlg.example:Update (dlg.examplePlayer)
	dlg.example:UpdateEffects (dlg.examplePlayer)
	dlg.example:BoundingBoxSetShowing (dlg.exampleShowUnitFrameBoundingBox)

	dlg.data:Update (dlg.example)
	dlg.data:EffectsUpdated (dlg.examplePlayer, true)
	dlg.data:BoundingBoxSetShowing (dlg.exampleShowBoundingBox)
end


function Enemy.UnitFramesUI_EffectsIndicatorDialog_Ok ()

	if (dlg.isLoading or not Enemy.UnitFramesUI_EffectsIndicatorDialog_IsOpen ()) then return end

	Enemy.UnitFramesUI_EffectsIndicatorDialog_UpdateExample ()

	if (#dlg.data.effectFilters < 1)
	then
		DialogManager.MakeOneButtonDialog (L"You should add at least one effect filter", L"Ok")
		return
	end

	if (dlg.data.logic)
	then
		local expr = Enemy.LogicalExpressionParse (Enemy.toString (dlg.data.logic))
		local effect_filters_names = {}

		for _, v in ipairs (dlg.data.effectFilters)
		do
			local name = Enemy.toString (v.filterName)
			if (effect_filters_names[name])
			then
				DialogManager.MakeOneButtonDialog (L"Dublicate filter name: "..Enemy.toWString (name), L"Ok")
				return
			end

			effect_filters_names[name] = true
		end

		local functions = Enemy.LogicalExpressionGetFunctions (expr)

		for f, _ in pairs (functions)
		do
			if (effect_filters_names[f] == nil)
			then
				DialogManager.MakeOneButtonDialog (L"Error in logic expression: function '"..Enemy.toWString (f)..L"' not found.", L"Ok")
				return
			end
		end
	end

	if (dlg.onOkCallback)
	then
		dlg.onOkCallback (dlg.oldData, dlg.data)
	end

	Enemy.UnitFramesUI_EffectsIndicatorDialog_Hide ()
end
