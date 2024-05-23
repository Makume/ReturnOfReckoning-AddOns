<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LogOutWindow" date="20/05/2024">
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="A logout dialog to give more direct feel to the logoff/exit process"/>
		<Dependencies />
		<Files>
			<File name="LogOutWindow.lua" />
			<File name="LogOutWindow.xml" />
		</Files>
		<OnInitialize>
			<CallFunction name="LogOutWindow.OnInitialize" />
		</OnInitialize>
		<OnShutdown>  
			<CallFunction name="LogOutWindow.Shutdown" /> 
		</OnShutdown>  
		<SavedVariables>
			<SavedVariable name="LogOutWindow.settings"/>
		</SavedVariables> 
	</UiMod>
</ModuleFile>