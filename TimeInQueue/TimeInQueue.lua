if not TimeInQueue then
	TimeInQueue = {}
end

TimeInQueue.Scenarios = {}

local oldOnMouseoverScenarioQueue
local GetGameTime, FormatClock = GetGameTime, TimeUtils.FormatClock

function TimeInQueue.OnInitialize()
	oldOnMouseoverScenarioQueue = EA_Window_OverheadMap.OnMouseoverScenarioQueue
	EA_Window_OverheadMap.OnMouseoverScenarioQueue = TimeInQueue.OnMouseoverScenarioQueue
	RegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_CANCEL, "TimeInQueue.OnJoinLeaveCancel")
	RegisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "TimeInQueue.OnJoinLeaveCancel")
	RegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "TimeInQueue.OnJoinLeaveCancel")
	RegisterEventHandler(SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE, "TimeInQueue.OnJoinScenarioQueue")
	RegisterEventHandler(SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE, "TimeInQueue.OnJoinScenarioQueue")
	RegisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "TimeInQueue.OnLeaveScenarioQueue")
end

function TimeInQueue.OnJoinLeaveCancel()
	TimeInQueue.Scenarios = {}
end

function TimeInQueue.OnJoinScenarioQueue()
	TimeInQueue.Scenarios[GameData.ScenarioQueueData.selectedId] = { Time = GetGameTime() }
end

function TimeInQueue.OnLeaveScenarioQueue()
	if TimeInQueue.Scenarios[GameData.ScenarioQueueData.selectedId] ~= nil then
		TimeInQueue.Scenarios[GameData.ScenarioQueueData.selectedId].Time = 0
	end
end

function TimeInQueue.OnMouseoverScenarioQueue()
	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil) 
	local queueData = GetScenarioQueueData()
	local row = 1
	local column = 1
	if(queueData ~= nil) then
		Tooltips.SetTooltipText(row, column, GetString(StringTables.Default.LABEL_SCENARIO_QUEUE_CURRENT_QUEUE))
		local queueCount = queueData.totalQueuedScenarios
		for index = 1, queueCount do
			local timeDiff = GetGameTime() - TimeInQueue.Scenarios[queueData[index].id].Time
			local ltime, _, _ = FormatClock(timeDiff);
			local queueName = EA_Window_OverheadMap.GetQueueName(queueData[index].type, queueData[index].id)..L" ("..towstring(ltime)..L")"
			Tooltips.SetTooltipText(index+1, column, queueName) 
			Tooltips.SetTooltipColor(index+1, column, 255, 255, 255)
		end		
		Tooltips.SetTooltipText(queueCount+2, column, GetString(StringTables.Default.TEXT_SCENARIO_QUEUE_MORE))
		Tooltips.SetTooltipText(queueCount+3, column, GetString(StringTables.Default.TEXT_SCENARIO_QUEUE_LESS))		
		Tooltips.SetTooltipColor(row, column, 255, 204, 102)
		Tooltips.SetTooltipColor(queueCount+2, column, 175, 175, 175)
		Tooltips.SetTooltipColor(queueCount+3, column, 175, 175, 175)
	else
		if (GameData.ScenarioQueueData[1].id == 0) then
			Tooltips.SetTooltipText(row, column, GetString(StringTables.Default.LABEL_SCENARIO_QUEUE_NONE_AVAILABLE))
		else
			Tooltips.SetTooltipText(row, column, GetString(StringTables.Default.LABEL_SCENARIO_QUEUE))
		end
	end	
	Tooltips.Finalize()
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_LEFT)
end

function TimeInQueue.Shutdown()
	EA_Window_OverheadMap.OnMouseoverScenarioQueue = oldOnMouseoverScenarioQueue
	UnRegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_CANCEL, "TimeInQueue.OnJoinLeaveCancel")
	UnRegisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "TimeInQueue.OnJoinLeaveCancel")
	UnRegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "TimeInQueue.OnJoinLeaveCancel")
	UnRegisterEventHandler(SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE, "TimeInQueue.OnJoinScenarioQueue")
	UnRegisterEventHandler(SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE, "TimeInQueue.OnJoinScenarioQueue")
	UnRegisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "TimeInQueue.OnLeaveScenarioQueue")
end