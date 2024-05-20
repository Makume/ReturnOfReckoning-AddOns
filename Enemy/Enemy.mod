<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Enemy" version="2.8.6" date="20/05/2024" autoenabled="true">

		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

		<Author name="LM" email="logutov@gmail.com" />
		<Description text="A set of tools for a premade group play. Intercom adapted for Return of Reckoning purposes." />

		<WARInfo>
		    <Categories>
		        <Category name="RVR" />
			<Category name="GROUPING" />
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

		<Files>
			<File name="Code\Core\TargetInfoFix.lua" />

			<File name="Code\Core\DefaultSettings.lua" />
			<File name="Code\Core\Constants.lua" />
			<File name="Code\Core\Main.lua" />
			<File name="Code\Core\LinkedList.lua" />
			<File name="Code\Core\LogicalExpression.lua" />
			<File name="Code\Core\TableSerializator.lua" />
			<File name="Code\Core\Utils.lua" />
			<File name="Code\Core\Events.lua" />
			<File name="Code\Core\Localization.lua" />
			<File name="Code\Core\StateMachine.lua" />
			<File name="Code\Core\ObjectWindows.lua" />
			<File name="Code\Core\Communication.lua" />

			<File name="Code\Core\ConfigurationWindow.lua" />
			<File name="Code\Core\ConfigurationWindow.xml" />

			<File name="Code\Core\Groups\EnemyPlayer.lua" />
			<File name="Code\Core\Groups\EnemyEffectFilter.lua" />
			<File name="Code\Core\Groups\Groups.lua" />
			<File name="Code\Core\Groups\EffectFilterDialog.xml" />

			<File name="Code\Core\Common.xml" />
			<File name="Code\Core\Icon.xml" />
			<File name="Code\Core\ConfigDialog.xml" />
			<File name="Code\Core\Debug.xml" />
			<File name="Code\Core\ChooseIconDialog.xml" />

			<File name="Code\Intercom\Intercom.lua" />
			<File name="Code\Intercom\ChooseChannelDialog.xml" />
			<File name="Code\Intercom\IntercomDialog.xml" />
			<File name="Code\Intercom\IntercomJoinDialog.xml" />
			<File name="Code\Intercom\IntercomConfigDialog.xml" />

			<File name="Code\Assist\Assist.lua" />
			<File name="Code\Assist\Assist.xml" />
			<File name="Code\Assist\AssistConfiguration.xml" />

			<File name="Code\KillSpam\KillSpam.lua" />
			<File name="Code\KillSpam\KillSpam.xml" />
			<File name="Code\KillSpam\PlayerKDR.xml" />
			<File name="Code\KillSpam\KilledBy.xml" />
			<File name="Code\KillSpam\KillSpamConfiguration.xml" />

			<File name="Code\Marks\MarkTemplate.lua" />
			<File name="Code\Marks\MarkTemplate.xml" />
			<File name="Code\Marks\Marks.lua" />
			<File name="Code\Marks\Marks.xml" />
			<File name="Code\Marks\MarksEditTemplate.lua" />
			<File name="Code\Marks\MarksEditTemplate.xml" />

			<File name="Code\UnitFrames\UnitFrames.lua" />
			<File name="Code\UnitFrames\UnitFramePart.lua" />
			<File name="Code\UnitFrames\Parts\HpBar.lua" />
			<File name="Code\UnitFrames\Parts\ApBar.lua" />
			<File name="Code\UnitFrames\Parts\CareerIcon.lua" />
			<File name="Code\UnitFrames\Parts\SelectionFrame.lua" />
			<File name="Code\UnitFrames\Parts\Panel.lua" />
			<File name="Code\UnitFrames\Parts\NameText.lua" />
			<File name="Code\UnitFrames\Parts\LevelText.lua" />
			<File name="Code\UnitFrames\Parts\HpPercentText.lua" />
			<File name="Code\UnitFrames\Parts\MoraleText.lua" />
			<File name="Code\UnitFrames\Parts\HpArchetypeColoredBar.lua" />
			<File name="Code\UnitFrames\Parts\HpLevelColoredBar.lua" />
			<File name="Code\UnitFrames\Parts\HpCareerColoredBar.lua" />
			<File name="Code\UnitFrames\Parts\GroupLeaderIcon.lua" />
			<File name="Code\UnitFrames\Parts\DistanceText.lua" />
			<File name="Code\UnitFrames\Parts\MoraleBar.lua" />
			<File name="Code\UnitFrames\Parts\DistanceBar.lua" />
			<File name="Code\UnitFrames\UnitFrame.lua" />
			<File name="Code\UnitFrames\EffectsIndicator.lua" />
			<File name="Code\UnitFrames\ClickCasting.lua" />
			<File name="Code\UnitFrames\UnitFramesAnchor.xml" />
			<File name="Code\UnitFrames\UnitFramePartDialog.xml" />
			<File name="Code\UnitFrames\UnitFrame.xml" />
			<File name="Code\UnitFrames\UnitFramesConfiguration.xml" />
			<File name="Code\UnitFrames\EffectsIndicatorDialog.xml" />
			<File name="Code\UnitFrames\ClickCastingDialog.xml" />

			<File name="Code\GroupIcons\GroupIcon.lua" />
			<File name="Code\GroupIcons\GroupIcons.lua" />
			<File name="Code\GroupIcons\GroupIcons.xml" />
			<File name="Code\GroupIcons\GroupIconsConfiguration.xml" />

			<File name="Code\Guard\Guard.lua" />
			<File name="Code\Guard\GuardConfiguration.xml" />
			<File name="Code\Guard\GuardDistanceIndicator.xml" />

			<File name="Code\ScenarioAlerter\ScenarioAlerter.lua" />
			<File name="Code\ScenarioAlerter\ScenarioAlerterConfiguration.xml" />

			<File name="Code\ScenarioInfo\ScenarioInfo.lua" />
			<File name="Code\ScenarioInfo\TestData.lua" />
			<File name="Code\ScenarioInfo\ScenarioInfo.xml" />
			<File name="Code\ScenarioInfo\ScenarioInfoConfiguration.xml" />

			<File name="Code\TalismanAlerter\TalismanAlerter.lua" />
			<File name="Code\TalismanAlerter\TalismanAlerterConfiguration.xml" />
			<File name="Code\TalismanAlerter\TalismanAlerterIndicator.xml" />

			<File name="Code\Timer\Timer.lua" />
			<File name="Code\Timer\TimerConfiguration.xml" />
			<File name="Code\Timer\Timer.xml" />

			<File name="Code\CombatLog\CombatLogLocalization.lua" />
			<File name="Code\CombatLog\CombatLog.lua" />
			<File name="Code\CombatLog\CombatLogConfiguration.xml" />
			<File name="Code\CombatLog\CombatLogStatsWindow.lua" />
			<File name="Code\CombatLog\CombatLogStatsWindow.xml" />
			<File name="Code\CombatLog\CombatLogSnapshotWindow.lua" />
			<File name="Code\CombatLog\CombatLogSnapshotWindow.xml" />
			<File name="Code\CombatLog\CombatLogIDS.lua" />
			<File name="Code\CombatLog\CombatLogIDS.xml" />
			<File name="Code\CombatLog\CombatLogEpsWindow.lua" />
			<File name="Code\CombatLog\CombatLogEpsWindow.xml" />
			<File name="Code\CombatLog\CombatLogTargetDefenseWindow.lua" />
			<File name="Code\CombatLog\CombatLogTargetDefenseWindow.xml" />
		</Files>

		<OnInitialize>
			<CallFunction name="Enemy.Initialize" />
		</OnInitialize>

		<SavedVariables>
			<SavedVariable name="Enemy.Settings" global="false" />
		</SavedVariables>

        <OnUpdate>
			<CallFunction name="Enemy.Update" />
        </OnUpdate>

        <OnShutdown>
            <CallFunction name="Enemy.Shutdown" />
        </OnShutdown>

	</UiMod>
</ModuleFile>
