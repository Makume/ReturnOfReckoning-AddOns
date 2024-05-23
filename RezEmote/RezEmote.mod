<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="RezEmote" version="1.0.0" date="05/09/2024" >
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="Send the Rez emote on player death" />
		<VersionSettings gameVersion="1.4.8"/>
		<WARInfo>
			<Categories>
				<Category name="COMBAT" />
				<Category name="RVR" />
				<Category name="GROUPING" />
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
				<Career name="MARAUDER" />
				<Career name="ZEALOT" />
				<Career name="MAGUS" />
				<Career name="SWORDMASTER" />
				<Career name="SHADOW_WARRIOR" />
				<Career name="WHITE_LION" />
				<Career name="ARCHMAGE" />
			</Careers>
		</WARInfo>
		<Dependencies>
			<Dependency name="EA_TacticsWindow" />
		</Dependencies>
		<Files>
			<File name="RezEmote.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="RezEmote.Initialize" />
		</OnInitialize>     
		<OnUpdate/>      
		<OnShutdown>  
			<CallFunction name="RezEmote.Shutdown" /> 
		</OnShutdown>   
	</UiMod>
</ModuleFile>