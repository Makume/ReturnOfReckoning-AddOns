<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="SellPrice" version="1.1.0" date="05/09/2024" >
		<Author name="Psychoxell (Adeptha)" email="" />
		<Description text="Show always sell price on item tooltip" />
		<VersionSettings gameVersion="1.4.8"/>
		<WARInfo>
			<Categories>
				<Category name="ITEMS_INVENTORY" />
				<Category name="CHAT" />
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
		<Dependencies/>
		<Files>
			<File name="SellPrice.lua" />
		</Files>
		<OnInitialize>
			<CallFunction name="SellPrice.Initialize" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown> 
			<CallFunction name="SellPrice.Shutdown" /> 
		</OnShutdown>
	</UiMod>
</ModuleFile>