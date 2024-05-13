<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WarBoard_Clock" version="0.3" date="08/05/2022" >
		<Author name="Ramshackles, Zomega" email="Ramshackles@live.dk" />
		<Description text="A Clock module for WarBoard." />
		<VersionSettings gameVersion="1.3.5" windowsVersion="1.1" savedVariablesVersion="1.0" />
		<Dependencies>
				<Dependency name="WarBoard" />
				<Dependency name="EA_ChatWindow" />
		</Dependencies>
		<SavedVariables>
			<SavedVariable name="WarBoard_ClockSettings" />
		</SavedVariables>
		<Files>
			<File name="WarBoard_Clock.lua" />
			<File name="WarBoard_Clock.xml" />
			<File name="WarBoard_ClockOptions.xml" />
			<File name="WarBoard_ClockOptions.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="WarBoard_Clock.Initialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="WarBoard_Clock.OnUpdate" />
		</OnUpdate>

		<WARInfo>
	<Categories>
		<Category name="SYSTEM" />
		<Category name="OTHER" />
	</Categories>
	<Careers>
		<Career name="BLACKGUARD" />
		<Career name="WITCH_ELF" />
		<Career name="DISCIPLE" />
		<Career name="SORCERER" />
		<Career name="IRON_BREAKER" />
		<Career name="SLAYER" />
		<Career name="RUNE_PRIEST" />
		<Career name="ENGINEER" />
		<Career name="BLACK_ORC" />
		<Career name="CHOPPA" />
		<Career name="SHAMAN" />
		<Career name="SQUIG_HERDER" />
		<Career name="WITCH_HUNTER" />
		<Career name="KNIGHT" />
		<Career name="BRIGHT_WIZARD" />
		<Career name="WARRIOR_PRIEST" />
		<Career name="CHOSEN" />
		<Career name= "MARAUDER" />
		<Career name="ZEALOT" />
		<Career name="MAGUS" />
		<Career name="SWORDMASTER" />
		<Career name="SHADOW_WARRIOR" />
		<Career name="WHITE_LION" />
		<Career name="ARCHMAGE" />
	</Careers>
</WARInfo>
	</UiMod>
</ModuleFile>