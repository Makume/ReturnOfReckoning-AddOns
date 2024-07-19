if not ScenarioQueueLeaveAll then
	ScenarioQueueLeaveAll = {}
end

local oldOnScenarioQueueRButtonUp
local leaveStep = 0
local timeLeft = 1

function ScenarioQueueLeaveAll.OnInitialize()
	oldOnScenarioQueueRButtonUp = EA_Window_OverheadMap.OnScenarioQueueRButtonUp
	EA_Window_OverheadMap.OnScenarioQueueRButtonUp = ScenarioQueueLeaveAll.OnScenarioQueueRButtonUp
end

function ScenarioQueueLeaveAll.OnScenarioQueueRButtonUp()
	local queueData = GetScenarioQueueData()
	if(queueData ~= nil) then
		EA_Window_ContextMenu.CreateContextMenu(SystemData.ActiveWindow.name)
		local queueCount = queueData.totalQueuedScenarios
		for index = 1, queueCount do
			local queueName = EA_Window_OverheadMap.GetQueueName(queueData[index].type, queueData[index].id)
			local menuText = GetStringFormat(StringTables.Default.TEXT_LEAVE_SCENARIO, { queueName })
			EA_Window_ContextMenu.AddMenuItem(menuText, EA_Window_OverheadMap.LeaveScenario, false, true)
		end
		EA_Window_ContextMenu.AddMenuDivider()		
		EA_Window_ContextMenu.AddMenuItem(L"Leave: All Scenarios", ScenarioQueueLeaveAll.LeaveScenarioAll, false, true)
		EA_Window_ContextMenu.Finalize()
	end	
end

function ScenarioQueueLeaveAll.LeaveScenarioAll()
	leaveStep = 1
end

-- leaveStep muss auf 0 gesetzt werden wenn alle Queues durch sind mit abmelden

function ScenarioQueueLeaveAll.OnUpdate(elapsed)
	if SystemData.LoadingData.isLoading then
		return
	end
	timeLeft = timeLeft - elapsed
	if timeLeft > 0 then
		return
	end
	timeLeft = 1
	if leaveStep == 0 then
		return
	end
	ScenarioQueueLeaveAll.LeaveScenario()
end

function ScenarioQueueLeaveAll.LeaveScenario()
	local queueData = GetScenarioQueueData()
	if queueData == nil then
		return
	end
	if GameData.ScenarioQueueData[leaveStep] ~= nil then
		GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[leaveStep].id
		BroadcastEvent(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE)
		timeLeft = 0
		leaveStep = leaveStep + 1
	else
		leaveStep = EA_Window_ScenarioLobby.MAX_SCENARIOS
	end	
	if GameData.ScenarioQueueData.selectedId == 0 then
		leaveStep = 0
	end
end

function ScenarioQueueLeaveAll.Shutdown()
	EA_Window_OverheadMap.OnScenarioQueueRButtonUp = oldOnScenarioQueueRButtonUp
end