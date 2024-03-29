--[[
Automatically generated via export from C:/Users/build\DaVE_local\branches/warhammer2/silence_12_2_ms_clockwork/warhammer/raw_data/db
Edit manually at your own risk
--]]

module(..., package.seeall)

-- Event tables

AdviceCleared = {}
AdviceDismissed = {}
AdviceFinishedTrigger = {}
AdviceIssued = {}
AdviceLevelChanged = {}
AdviceNavigated = {}
AdviceSuperseded = {}
AreaCameraEntered = {}
AreaEntered = {}
AreaExited = {}
ArmyBribeAttemptFailure = {}
ArmySabotageAttemptFailure = {}
ArmySabotageAttemptSuccess = {}
BattleAideDeCampEvent = {}
BattleBoardingActionCommenced = {}
BattleCommandingShipRouts = {}
BattleCommandingUnitRouts = {}
BattleCompleted = {}
BattleCompletedCameraMove = {}
BattleConflictPhaseCommenced = {}
BattleDeploymentPhaseCommenced = {}
BattleFortPlazaCaptureCommenced = {}
BattleSessionEnded = {}
BattleShipAttacksEnemyShip = {}
BattleShipCaughtFire = {}
BattleShipMagazineExplosion = {}
BattleShipRouts = {}
BattleShipRunAground = {}
BattleShipSailingIntoWind = {}
BattleShipSurrendered = {}
BattleTimeTrigger = {}
BattleUnitAttacksBuilding = {}
BattleUnitAttacksEnemyUnit = {}
BattleUnitAttacksWalls = {}
BattleUnitCapturesBuilding = {}
BattleUnitDestroysBuilding = {}
BattleUnitRouts = {}
BattleUnitUsingBuilding = {}
BattleUnitUsingWall = {}
BuildingCardSelected = {}
BuildingCompleted = {}
BuildingConstructionIssuedByPlayer = {}
BuildingInfoPanelOpenedCampaign = {}
CameraMoverCancelled = {}
CameraMoverFinished = {}
CampaignArmiesMerge = {}
CampaignBuildingDamaged = {}
CampaignCoastalAssaultOnCharacter = {}
CampaignCoastalAssaultOnGarrison = {}
CampaignEffectsBundleAwarded = {}
CampaignSessionEnded = {}
CampaignSettlementAttacked = {}
CampaignTimeTrigger = {}
CharacterAncillaryGained = {}
CharacterAssignedToPost = {}
CharacterAttacksAlly = {}
CharacterBecomesFactionLeader = {}
CharacterBesiegesSettlement = {}
CharacterBlockadedPort = {}
CharacterBrokePortBlockade = {}
CharacterBuildingCompleted = {}
CharacterCanLiberate = {}
CharacterCandidateBecomesMinister = {}
CharacterCapturedSettlementUnopposed = {}
CharacterCharacterTargetAction = {}
CharacterComesOfAge = {}
CharacterCompletedBattle = {}
CharacterConvalescedOrKilled = {}
CharacterCreated = {}
CharacterDamagedByDisaster = {}
CharacterDeselected = {}
CharacterDiscovered = {}
CharacterDisembarksNavy = {}
CharacterEmbarksNavy = {}
CharacterEntersAttritionalArea = {}
CharacterEntersGarrison = {}
CharacterFactionCompletesResearch = {}
CharacterFamilyRelationDied = {}
CharacterFinishedMovingEvent = {}
CharacterGarrisonTargetAction = {}
CharacterInfoPanelOpened = {}
CharacterLeavesGarrison = {}
CharacterLootedSettlement = {}
CharacterMarriage = {}
CharacterMilitaryForceTraditionPointAllocated = {}
CharacterMilitaryForceTraditionPointAvailable = {}
CharacterParticipatedAsSecondaryGeneralInBattle = {}
CharacterPerformsActionAgainstFriendlyTarget = {}
CharacterPerformsSettlementOccupationDecision = {}
CharacterPostBattleEnslave = {}
CharacterPostBattleRelease = {}
CharacterPostBattleSlaughter = {}
CharacterPromoted = {}
CharacterRankUp = {}
CharacterRankUpNeedsAncillary = {}
CharacterRazedSettlement = {}
CharacterRelativeKilled = {}
CharacterReplacingGeneral = {}
CharacterSackedSettlement = {}
CharacterSelected = {}
CharacterSettlementBesieged = {}
CharacterSettlementBlockaded = {}
CharacterSkillPointAllocated = {}
CharacterSkillPointAvailable = {}
CharacterSuccessfulArmyBribe = {}
CharacterSuccessfulConvert = {}
CharacterSuccessfulDemoralise = {}
CharacterSuccessfulInciteRevolt = {}
CharacterTurnEnd = {}
CharacterTurnStart = {}
CharacterWaaaghOccurred = {}
CharacterWithdrewFromBattle = {}
ClanBecomesVassal = {}
ClimatePhaseChange = {}
ComponentCreated = {}
ComponentLClickUp = {}
ComponentLinkClicked = {}
ComponentLinkMouseOver = {}
ComponentMouseOn = {}
ComponentMoved = {}
ComponentRClickUp = {}
ConvertAttemptFailure = {}
CustomLoadingScreenCreated = {}
DebugCharacterEvent = {}
DebugFactionEvent = {}
DebugRegionEvent = {}
DemoraliseAttemptFailure = {}
DilemmaChoiceMadeEvent = {}
DilemmaIssuedEvent = {}
DilemmaOrIncidentStarted = {}
DillemaOrIncidentStarted = {}
DiplomacyNegotiationStarted = {}
DiplomaticOfferRejected = {}
DuelDemanded = {}
DummyEvent = {}
EncylopediaEntryRequested = {}
EventMessageOpenedBattle = {}
EventMessageOpenedCampaign = {}
FactionAboutToEndTurn = {}
FactionBecomesLiberationProtectorate = {}
FactionBecomesLiberationVassal = {}
FactionBecomesWorldLeader = {}
FactionBeginTurnPhaseNormal = {}
FactionCapturesWorldCapital = {}
FactionCivilWarOccured = {}
FactionCookedDish = {}
FactionEncountersOtherFaction = {}
FactionFameLevelUp = {}
FactionGovernmentTypeChanged = {}
FactionHordeStatusChange = {}
FactionJoinsConfederation = {}
FactionLeaderDeclaresWar = {}
FactionLeaderIssuesEdict = {}
FactionLeaderSignsPeaceTreaty = {}
FactionLiberated = {}
FactionRoundStart = {}
FactionSubjugatesOtherFaction = {}
FactionTurnEnd = {}
FactionTurnStart = {}
FirstTickAfterNewCampaignStarted = {}
FirstTickAfterWorldCreated = {}
ForceAdoptsStance = {}
ForcePlagueStateChanged = {}
ForeignSlotBuildingCompleteEvent = {}
ForeignSlotBuildingDamagedEvent = {}
ForeignSlotManagerDiscoveredEvent = {}
ForeignSlotManagerRemovedEvent = {}
FortSelected = {}
FrontendScreenTransition = {}
GarrisonAttackedEvent = {}
GarrisonOccupiedEvent = {}
GarrisonResidenceCaptured = {}
GarrisonResidenceExposedToFaction = {}
GovernorAssignedCharacterEvent = {}
GovernorshipTaxRateChanged = {}
HaveCharacterWithinRangeOfPositionMissionEvaluationResultEvent = {}
HelpPageIndexGenerated = {}
HeroCharacterParticipatedInBattle = {}
HistoricBattleEvent = {}
HistoricalCharacters = {}
HistoricalEvents = {}
HudRefresh = {}
ImprisonmenRejectiontEvent = {}
ImprisonmentEvent = {}
IncidentEvent = {}
IncidentFailedEvent = {}
IncidentOccuredEvent = {}
InciteRevoltAttemptFailure = {}
IncomingMessage = {}
LandTradeRouteRaided = {}
LoadingGame = {}
LoadingScreenAfterEnvCreated = {}
LoadingScreenDismissed = {}
LocationEntered = {}
LocationUnveiled = {}
MPLobbyChatCreated = {}
MapIconMoved = {}
MilitaryForceBuildingCompleteEvent = {}
MilitaryForceCreated = {}
MilitaryForceDevelopmentPointChange = {}
MissionCancelled = {}
MissionFailed = {}
MissionGenerationFailed = {}
MissionIssued = {}
MissionNearingExpiry = {}
MissionSucceeded = {}
ModelCreated = {}
MovementPointsExhausted = {}
MultiTurnMove = {}
NegativeDiplomaticEvent = {}
NewCampaignStarted = {}
NewCharacterEnteredRecruitmentPool = {}
NewSession = {}
NominalDifficultyLevelChangedEvent = {}
PanelAdviceRequestedBattle = {}
PanelAdviceRequestedCampaign = {}
PanelClosedBattle = {}
PanelClosedCampaign = {}
PanelOpenedBattle = {}
PanelOpenedCampaign = {}
PendingActionsMaskReset = {}
PendingBankruptcy = {}
PendingBattle = {}
PooledResourceEffectChangedEvent = {}
PositiveDiplomaticEvent = {}
PreBattle = {}
PrisonActionTakenEvent = {}
RealTimeTrigger = {}
RecruitmentItemIssuedByPlayer = {}
RegionAbandonedWithBuildingEvent = {}
RegionFactionChangeEvent = {}
RegionGainedDevlopmentPoint = {}
RegionIssuesDemands = {}
RegionPlagueStateChanged = {}
RegionRebels = {}
RegionRiots = {}
RegionSelected = {}
RegionStrikes = {}
RegionTurnEnd = {}
RegionTurnStart = {}
RegionWindsOfMagicChanged = {}
ResearchCompleted = {}
ResearchStarted = {}
RitualCancelledEvent = {}
RitualCompletedEvent = {}
RitualEvent = {}
RitualStartedEvent = {}
RitualsCompletedAndDelayedEvent = {}
SabotageAttemptFailure = {}
SabotageAttemptSuccess = {}
SavingGame = {}
ScriptedAgentCreated = {}
ScriptedAgentCreationFailed = {}
ScriptedCharacterUnhidden = {}
ScriptedCharacterUnhiddenFailed = {}
ScriptedForceCreated = {}
SeaTradeRouteRaided = {}
SettlementDeselected = {}
SettlementOccupied = {}
SettlementSelected = {}
SharedStatesFinishedLoadingScriptEvent = {}
ShortcutPressed = {}
ShortcutTriggered = {}
SiegeLifted = {}
SlotOpens = {}
SlotRoundStart = {}
SlotSelected = {}
SlotTurnStart = {}
StartRegionPopupVisible = {}
StartRegionSelected = {}
TechnologyInfoPanelOpenedCampaign = {}
TestEvent = {}
TooltipAdvice = {}
TradeLinkEstablished = {}
TradeNodeConnected = {}
TradeRouteEstablished = {}
TriggerPostBattleAncillaries = {}
UICreated = {}
UIDestroyed = {}
UITriggerScriptEvent = {}
UngarrisonedFort = {}
UniqueAgentDespawned = {}
UniqueAgentSpawned = {}
UnitCompletedBattle = {}
UnitCreated = {}
UnitDisbanded = {}
UnitDisembarkCompleted = {}
UnitEffectPurchased = {}
UnitMergedAndDestroyed = {}
UnitSelectedCampaign = {}
UnitTrained = {}
UnitTurnEnd = {}
VictoryConditionFailed = {}
VictoryConditionMet = {}
WorldCreated = {}
historical_events = {}
