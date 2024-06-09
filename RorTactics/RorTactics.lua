if not RorTactics then 
	RorTactics = {} 
end

function RorTactics.Initialize()
	RegisterEventHandler(SystemData.Events.PLAYER_NUM_TACTIC_SLOTS_UPDATED, "RorTactics.UpdateTacticButtons")
	RorTactics.UpdateTacticButtons()
end

function RorTactics.UpdateTacticButtons()
	for _,v in ipairs(ModulesGetData()) do
		if v.name == "EA_TacticsWindow_WifNamez" then
			if v.isEnabled and not v.isLoaded then
				ModuleInitialize("EA_TacticsWindow_WifNamez");
			end
			break
		end
	end
	local hookCreateBar = TacticsEditor.CreateBar
	TacticsEditor.CreateBar = function(...)
		hookCreateBar(...)
		RorTactics.AnchorTacticButtons()
	end
	local hookUpdateTactics = TacticsEditor.UpdateTactics
	TacticsEditor.UpdateTactics = function()
		hookUpdateTactics()
		RorTactics.AnchorTacticButtons()
	end
	local hookTacticShutdown = TacticsEditor.Shutdown
	TacticsEditor.Shutdown = function()
		RorTactics.Shutdown()
		hookTacticShutdown()
	end
end

function RorTactics.Shutdown()
	if DoesWindowExist("EA_TacticsEditor") then
		local x, y = WindowGetDimensions("EA_TacticsEditor")
		if y > x then
			WindowSetDimensions("EA_TacticsEditor", y, x)
		end
	end
end

function RorTactics.AnchorTacticButtons()
	if not DoesWindowExist("EA_TacticsEditor") then
		return
	end
	local windowName
	local MaxTacticSlots = GameData.MAX_TACTICS_SLOTS
	local PlayerLevel = GameData.Player.level
	if PlayerLevel >= 1 and PlayerLevel <= 7 then
		MaxTacticSlots = 0
	elseif PlayerLevel >= 8 and PlayerLevel <= 15 then	
		MaxTacticSlots = 1
	elseif PlayerLevel >= 16 and PlayerLevel <= 23 then	
		MaxTacticSlots = 2
	elseif PlayerLevel >= 24 and PlayerLevel <= 31 then	
		MaxTacticSlots = 3
	elseif PlayerLevel >= 32 then
		MaxTacticSlots = 4
	end
	for buttonId = 1, GameData.MAX_TACTICS_SLOTS do
		windowName = "TacticButton"..buttonId
		if not DoesWindowExist(windowName) then
			break
		end
		if buttonId > MaxTacticSlots then
			DestroyWindow(windowName)
		end
	end
	for slotType = GameData.TacticType.FIRST, GameData.TacticType.NUM_TYPES do
		windowName = "Spacer"..slotType
		if DoesWindowExist(windowName) then
			DestroyWindow(windowName)
		end
	end
end