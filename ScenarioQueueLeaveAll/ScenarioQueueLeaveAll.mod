<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="ScenarioQueueLeaveAll" version="1.0.0" date="08/06/2024">
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="Add a leave all on the R-CLick for the Scneario Queue" />
		<Files>
			<File name="ScenarioQueueLeaveAll.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="ScenarioQueueLeaveAll.OnInitialize" />
		</OnInitialize>
		<OnUpdate>
			<CallFunction name="ScenarioQueueLeaveAll.OnUpdate" />
		</OnUpdate>
		<OnShutdown>  
			<CallFunction name="ScenarioQueueLeaveAll.Shutdown" /> 
		</OnShutdown>  
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" />  
		<WARInfo>
			<Categories>           
				<Category name="COMBAT" />
				<Category name="SYSTEM" />
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
				<Career name="MARAUDER" />
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