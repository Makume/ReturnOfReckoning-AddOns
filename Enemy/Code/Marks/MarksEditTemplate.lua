if not Enemy.MarksEditListData then 
	Enemy.MarksEditListData = {} 
end

local _index = 0
local ConfigData = {}
local WindowName = "EnemyMarkEntryDialog"
local AddWindowName = "AddMarkPlayer"
local EditWindowName = "EditMarkPlayer"

function Enemy.MarksUI_MarkEditEntryDialog_Open(template, onOkCallback)
	if (DoesWindowExist(WindowName)) then
		DestroyWindow(WindowName)
	end
	CreateWindow(WindowName, false)
	LabelSetText(WindowName.."TitleBarText", L"Edit mark entries ("..towstring(template.name)..L")")
	ButtonSetText(WindowName.."AddButton", L"Add Entry")
	ButtonSetText(WindowName.."OkButton", L"OK")
	ButtonSetText(WindowName.."CancelButton", L"Cancel")
	ConfigData = Enemy.clone(template)
	ConfigData.onOkCallback = onOkCallback
	Enemy.InitMarksEditListData()
	WindowSetShowing(WindowName, true)
end

function Enemy.OnLButtonUpMarkEntry()	
	_index = ListBoxGetDataIndex(WindowName.."List", WindowGetId(SystemData.MouseOverWindow.name))
	if _index ~= nil then
		Enemy.ColorMarkEntry()
		EA_Window_ContextMenu.CreateContextMenu(SystemData.MouseOverWindow.name, EA_Window_ContextMenu.CONTEXT_MENU_1, towstring(Enemy.MarksEditListData[_index].name))
		EA_Window_ContextMenu.AddMenuDivider()
		EA_Window_ContextMenu.AddMenuItem(L"Edit", Enemy.MarksUI_MarkEditEntryDialog_Edit, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1)
		EA_Window_ContextMenu.AddMenuItem(L"Delete", Enemy.MarksUI_MarkEditEntryDialog_Delete, false, true, EA_Window_ContextMenu.CONTEXT_MENU_1)
		EA_Window_ContextMenu.Finalize()
	end
end

function Enemy.OnMouseOverMarkEntry()
	Enemy.ColorMarkEntry()
end

function Enemy.ColorMarkEntry()
	ColorIndex = ListBoxGetDataIndex(WindowName.."List", WindowGetId(SystemData.MouseOverWindow.name))
	local i = 1
	local row_window_name = L""
	for k,v in pairs(ConfigData.permanentTargets) do
		row_window_name = towstring(WindowName)..L"ListRow"..towstring(i)
		if (i == ColorIndex) then
			WindowSetShowing(tostring(row_window_name..L"Background"), true)
			WindowSetAlpha(tostring(row_window_name..L"Background"), 0.5)
			WindowSetTintColor(tostring(row_window_name..L"Background"), 200, 200, 100)			
		else
			WindowSetShowing(tostring(row_window_name..L"Background"), false)
		end
		i = i + 1
	end
end

function Enemy.MarksUI_MarkEntryDialog_Ok()
	if (ConfigData.onOkCallback) then
		ConfigData.onOkCallback(ConfigData)
	end
	Enemy.MarksUI_MarkEntryDialog_Hide()
end

function Enemy.MarksUI_MarkEditEntryDialog_Edit()
	if (ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true) then
		return
	end
	if (_index == 0) then 
		return
	end
	CreateWindow(EditWindowName, false)
    LabelSetText(EditWindowName.."Label", L"Edit Playername")
	TextEditBoxSetText(EditWindowName.."Text", towstring(Enemy.MarksEditListData[_index].name))
    ButtonSetText(EditWindowName.."OKButton", L"OK")
    ButtonSetText(EditWindowName.."CancelButton", L"Cancel")
	WindowSetShowing(EditWindowName, true)
end

function Enemy.MarksUI_MarkEditEntryDialog_Delete()
	if (ButtonGetDisabledFlag(SystemData.ActiveWindow.name) == true) then
		return
	end
	if (_index == 0) then 
		return
	end
	ConfigData.permanentTargets = Enemy.clone(Enemy.MakePermanentTargetsCopy())
	Enemy.InitMarksEditListData()
end

function Enemy.MarksUI_MarkEntryDialog_Hide()
	WindowSetShowing(WindowName, false)
end

function EnemyMarkTemplate:EditEntry(onOkCallback)
	Enemy.MarksUI_MarkEditEntryDialog_Open(self, onOkCallback)
end

function Enemy.MarksUI_MarkEntryDialog_Add()
	CreateWindow(AddWindowName, false)
    LabelSetText(AddWindowName.."Label", L"Set Playername")
    ButtonSetText(AddWindowName.."OKButton", L"OK")
    ButtonSetText(AddWindowName.."CancelButton", L"Cancel")
	WindowSetShowing(AddWindowName, true)
end

function Enemy.InitMarksEditListData()
	_DisplayOrder = {}
	local shtcount = 1
	Enemy.MarksEditListData = {}
	local i = 1
	local row_window_name = L""
	if ConfigData.permanentTargets ~= nil then
		for k,v in pairs(ConfigData.permanentTargets) do
			table.insert(_DisplayOrder, i)
			table.insert(Enemy.MarksEditListData, { name = towstring(k)})
			row_window_name = towstring(WindowName)..L"ListRow"..towstring(i)
			WindowSetShowing(tostring(row_window_name..L"Background"), false)		
			i = i + 1
		end
	end
	table.sort(Enemy.MarksEditListData, Enemy.SortTable)
	ListBoxSetDisplayOrder(WindowName.."List", _DisplayOrder)
end	

function Enemy.SortTable(a, b)
	return string.lower(tostring(a.name)) < string.lower(tostring(b.name))
end

function Enemy.OnAddMarkPlayerAccept()
	local NewPlayerName = TextEditBoxGetText(AddWindowName.."Text")
    if (NewPlayerName == nil) then
        return
    end
	Enemy.OnCancelAddMarkPlayer()
	ConfigData.permanentTargets[towstring(NewPlayerName)] = false   
	Enemy.InitMarksEditListData()
end

function Enemy.OnCancelAddMarkPlayer()
    WindowSetShowing(AddWindowName, false)
    TextEditBoxSetText(AddWindowName.."Text", L"")       
end

function Enemy.OnCancelEditMarkPlayer()
    WindowSetShowing(EditWindowName, false)
    TextEditBoxSetText(EditWindowName.."Text", L"")        
end

function Enemy.OnEditMarkPlayerAccept()
	local NewPlayerName = TextEditBoxGetText(EditWindowName.."Text")
    if (NewPlayerName == nil) then
        return
    end
	if (NewPlayerName == towstring(Enemy.MarksEditListData[_index].name)) then
		return
	end
    Enemy.OnCancelEditMarkPlayer()
	ConfigData.permanentTargets = Enemy.clone(Enemy.MakePermanentTargetsCopy())
	ConfigData.permanentTargets[towstring(NewPlayerName)] = false
	Enemy.InitMarksEditListData()
end

function Enemy.MakePermanentTargetsCopy()
	local permanentTargetsCopy = {}
	for k,v in pairs(ConfigData.permanentTargets) do
		if (towstring(k) ~= towstring(Enemy.MarksEditListData[_index].name)) then
			permanentTargetsCopy[towstring(k)] = false
		end	
	end
	return permanentTargetsCopy
end