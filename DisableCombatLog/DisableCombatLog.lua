if not DisableCombatLog then
	DisableCombatLog = {}
end

function DisableCombatLog.OnInitialize()
	TextLogSetEnabled ("Combat", false)
end