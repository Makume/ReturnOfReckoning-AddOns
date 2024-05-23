if not RezEmote then 
	RezEmote = {} 
end

function RezEmote.Initialize()
	RegisterEventHandler(SystemData.Events.PLAYER_DEATH, "RezEmote.Rez")
end

function RezEmote.Rez()
	if GameData.Player.rvrZoneFlagged and (not RezEmote.isScenario()) then
		EA_ChatWindow.Print(GameData.Player.name..towstring(L" request a rez"), SystemData.ChatLogFilters.EMOTE)
	end
end

function RezEmote.isScenario()
	if GameData.Player.isInScenario then
		return true
	end
	if GameData.Player.isInSiege then
		return true
	end
	if GameData.Player.zone == 167 then -- IC Siege
		return true
	end
	if GameData.Player.zone == 168 then -- Altdorf Siege
		return true
	end
	return false
end

function RezEmote.Shutdown()
	UnregisterEventHandler(SystemData.Events.PLAYER_DEATH, "RezEmote.Rez");
end