<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="WarBoard_Session" version="0.7.0" date="15/05/2024" >

        <Author name="Lyb" email="lybe86@gmail.com" />
        <Description text="A session stats mod for WarBoard, borrowed heavily from waaghbar ranktimer. Thanks Computerpunk for all the tips so far" />
          <VersionSettings gameVersion="1.4.8" />

        <Dependencies>
	    	<Dependency name="WarBoard" />
		<Dependency name="EA_BackpackWindow" />
        </Dependencies>

        <Files>
            <File name="WarBoard_Session.lua" />
			<File name="WarBoard_Session.xml" />
        </Files>

        <OnInitialize>
			<CallFunction name="WarBoard_Session.Initialize" />
        </OnInitialize>

		<OnUpdate/>
        <OnShutdown/>
	<Categories>
		<Category name="ITEMS_INVENTORY" />
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
    </UiMod>
</ModuleFile>
