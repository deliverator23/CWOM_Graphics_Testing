function GetValidPlotsFromPlotIndexTable(tTable)
    local tNewTable = {}
    local iCount = 1
    for i, iPlotIndex in ipairs(tTable) do
        local pPlot = Map.GetPlotByIndex(iPlotIndex);
        if (pPlot ~= nil) then
            local iPlotX, iPlotY = pPlot:GetX(), pPlot:GetY()
            --print("Continent Plot found at X" .. iPlotX .. ", Y" .. iPlotY)
            if (pPlot:GetOwner() == -1) and (pPlot:IsMountain() == false) and (pPlot:IsWater() == false) and (pPlot:IsNaturalWonder() == false) and (pPlot:IsImpassable() == false) then
                local bPlotHasUnit = false
                local unitList :table = Units.GetUnitsInPlotLayerID(iPlotX, iPlotY, MapLayers.ANY);
                if unitList ~= nil then
                    for i, pUnit in ipairs(unitList) do
                        local tUnitDetails = GameInfo.Units[pUnit:GetType()]
                        if tUnitDetails ~= nil then
                            if not pUnit:IsDead() and not pUnit:IsDelayedDeath() then
                                bPlotHasUnit = true
                                break
                            end
                        end
                    end
                end
                if (bPlotHasUnit == false) then
                    tNewTable[iCount] = pPlot
                    iCount = iCount + 1
                end
            end
        end
    end
    return tNewTable
end

local tBaseContinents = {
    "CONTINENT_AFRICA",
    "CONTINENT_EUROPE",
    "CONTINENT_NORTH_AMERICA",
    "CONTINENT_SOUTH_AMERICA",
    "CONTINENT_ASIA",
    "CONTINENT_OCEANIA"
}

local m_ContinentToBaseContinent;

function WildPredators(iPlayer)

    local tContinents = Map.GetContinentsInUse()

    if m_ContinentToBaseContinent == nil then
        m_ContinentToBaseContinent = {}
        for ci, iContinent in ipairs(tContinents) do
            for bi, baseContinent in ipairs(tBaseContinents) do
                print("iContinent: " .. iContinent .. "; baseContinent: " .. baseContinent)
                if (GameInfo.Continents[iContinent].ContinentType == baseContinent) then
                    m_ContinentToBaseContinent[iContinent] = baseContinent
                end
            end

            if m_ContinentToBaseContinent[iContinent] == nil then
                m_ContinentToBaseContinent[iContinent] = tBaseContinents[math.random(#tBaseContinents)]
            end
            print(GameInfo.Continents[iContinent].ContinentType .. " assigned to " .. m_ContinentToBaseContinent[iContinent])
        end
    end

    if (PlayerConfigurations[iPlayer]:GetCivilizationTypeName() == "CIVILIZATION_BARBARIAN") then

        local pPlayer = Players[iPlayer];
        math.randomseed(os.time()) --set seed for rng
        for i = 1, 4 do math.random() end --extra math.randoms to progress the seed and provide a greater degree of randomness

        for ci, iContinent in ipairs(tContinents) do

            local eligiblePlots = GetValidPlotsFromPlotIndexTable(Map.GetContinentPlots(iContinent))
            local spawningRuleContinent = m_ContinentToBaseContinent[iContinent]
            local spawnedPlots = {}

            for unitSpawnContinent in GameInfo.UnitSpawnContinents() do

                if (eligiblePlots ~= nil and #eligiblePlots > 0 and unitSpawnContinent.ContinentType == spawningRuleContinent) then

                    if (math.random(unitSpawnContinent.RandomSize) == 1) then

                        -- Remove ineligible plots
                        for ci, currentPlot in ipairs(eligiblePlots) do

                            local canSpawn = false;

                            for unitSpawnTerrain in GameInfo.UnitSpawnTerrains() do
                                if currentPlot:GetTerrainType() == GameInfo.Terrains[unitSpawnTerrain.TerrainType].Index and unitSpawnContinent.UnitType == unitSpawnTerrain.UnitType then
                                    canSpawn = true;
                                end
                            end

                            for unitSpawnFeature in GameInfo.UnitSpawnFeatures() do
                                print(currentPlot:GetFeatureType() .. "; " .. unitSpawnFeature.FeatureType .. "; " .. unitSpawnContinent.UnitType .. "; " .. unitSpawnFeature.UnitType)
                                if unitSpawnFeature.FeatureType > -1 then
                                    if currentPlot:GetFeatureType() == GameInfo.Features[unitSpawnFeature.FeatureType].Index and unitSpawnContinent.UnitType == unitSpawnFeature.UnitType then
                                        canSpawn = true;
                                    end
                                end
                            end

                            for si, spawnedPlot in ipairs(spawnedPlots) do
                                if spawnedPlot == currentPlot then
                                    canSpawn = false;
                                end
                            end

                            if (not canSpawn) then
                                local removePlotTerrain = currentPlot:GetTerrainType()
                                local removePlotFeature = currentPlot:GetFeatureType()
                                print(spawningRuleContinent .. " " .. unitSpawnContinent.UnitType .. "  removing tile: " .. currentPlot .. " " .. removePlotTerrain .. " " .. removePlotFeature .. "  #eligiblePlots:" .. #eligiblePlots .. " #spawnedPlots:" .. #spawnedPlots)
                                table.remove(eligiblePlots, currentPlot)
                            end
                        end

                        -- Randomly select from eligible plots and spawn unit
                        if (#eligiblePlots > 0) then
                            local spawnPlotIndex = math.random(#eligiblePlots);
                            local spawnPlot = eligiblePlots[spawnPlotIndex];

                            local spawnPlotTerrain = spawnPlot:GetTerrainType()
                            local spawnPlotFeature = spawnPlot:GetFeatureType()

                            print("spawning...")
                            print(unitSpawnContinent.UnitType .. " " .. GameInfo.Continents[iContinent].ContinentType .. " " .. unitSpawnContinent.ContinentType .. " " .. unitSpawnContinent.RandomSize .. " " .. spawnPlotTerrain .. " " .. spawnPlotFeature)
                            local pUnits = pPlayer:GetUnits()
                            pUnits:Create(GameInfo.Units[unitSpawnContinent.UnitType].Index, spawnPlot:GetX(), spawnPlot:GetY());
                            table.insert(spawnedPlots, spawnPlot)
                        end

                    end
                end
            end
        end
    end
end

GameEvents.PlayerTurnStarted.Add(WildPredators)

local iNumberUnitsToSpawnPerTurn = 1
-- specify the basic target number of ocean units to spawn each turn
-- this will be the number spawned each turn until the limit of alive animals is reached
local iTargetNumberOceanPlotsPerAnimal = 140
--this is the target number of ocean plots needed per sea animal
--adjust as needed for enough but not too many ocean animals
local tOceanPlots, iNumberOceanPlots, bNoMoreSeaUnitsCanBeSpawned = {}, 1, true
local iOceanTile = GameInfo.Terrains["TERRAIN_OCEAN"].Index
local tSpawnableOceanUnits = {
    GameInfo.Units["UNIT_ANIMAL_MANTA"].Index,
    GameInfo.Units["UNIT_ANIMAL_KRAKEN"].Index,
    GameInfo.Units["UNIT_ANIMAL_HUMPBACK_WHALE"].Index,
    GameInfo.Units["UNIT_ANIMAL_ORCA"].Index,
    GameInfo.Units["UNIT_ANIMAL_TIGERSHARK"].Index,
    GameInfo.Units["UNIT_ANIMAL_BULLSHARK"].Index,
    GameInfo.Units["UNIT_ANIMAL_HAMMERHEAD"].Index,
    GameInfo.Units["UNIT_ANIMAL_WHITESHARK"].Index
}


for i = 0, Map.GetPlotCount() - 1, 1 do
    local pPlot = Map.GetPlotByIndex(i);
    if (pPlot ~= nil) and (pPlot:GetTerrainType() == iOceanTile) and (pPlot:GetOwner() == -1) and (pPlot:IsNaturalWonder() == false) then
        tOceanPlots[iNumberOceanPlots] = i
        iNumberOceanPlots = iNumberOceanPlots + 1
        bNoMoreSeaUnitsCanBeSpawned = false
    end
end

local tBarbOceanUnitTypes = {}
for k, v in ipairs(tSpawnableOceanUnits) do
    tBarbOceanUnitTypes[v] = "true"
end

function GetNumberAllowedOceanPredators(iPlayer)
    local pPlayer = Players[iPlayer];
    local pUnits = pPlayer:GetUnits()
    local iNumberAliveUnits = 0
    for i, pUnit in pUnits:Members() do
        if tBarbOceanUnitTypes[pUnit:GetType()] and not pUnit:IsDead() and not pUnit:IsDelayedDeath() then
            iNumberAliveUnits = iNumberAliveUnits + 1
        end
    end
    local iCurrentAllowedNumberUnits = (math.floor(iNumberOceanPlots / iTargetNumberOceanPlotsPerAnimal) - iNumberAliveUnits)
    if (iCurrentAllowedNumberUnits >= 1) then
        return iCurrentAllowedNumberUnits
    else
        return 0
    end
end

function SpawnOceanPredators(iPlayer)
    if (bNoMoreSeaUnitsCanBeSpawned == true) then return end
    if (PlayerConfigurations[iPlayer]:GetCivilizationTypeName() == "CIVILIZATION_BARBARIAN") then
        local pPlayer = Players[iPlayer];
        local iNumberToSpawnThisTurn = ((GetNumberAllowedOceanPredators(iPlayer) >= 1) and iNumberUnitsToSpawnPerTurn or 0)
        if (iNumberToSpawnThisTurn == 0) then return end
        local iAttemptsThisTurn = 0 -- safety valve "counter" to keep the code from doing an infinite unending loop
        while iNumberToSpawnThisTurn > 0 do
            local iSelectedTableKey = math.random(iNumberOceanPlots)
            local iPlotIndex = tOceanPlots[iSelectedTableKey]
            local pPlot = Map.GetPlotByIndex(iPlotIndex);
            if (pPlot ~= nil) then
                if (pPlot:GetOwner() == -1) then
                    local iPlotX, iPlotY = pPlot:GetX(), pPlot:GetY()
                    local bPlotHasUnit = false
                    local unitList :table = Units.GetUnitsInPlotLayerID(iPlotX, iPlotY, MapLayers.ANY);
                    if unitList ~= nil then
                        for i, pUnit in ipairs(unitList) do
                            local tUnitDetails = GameInfo.Units[pUnit:GetType()]
                            if tUnitDetails ~= nil then
                                if not pUnit:IsDead() and not pUnit:IsDelayedDeath() then
                                    bPlotHasUnit = true
                                    break
                                end
                            end
                        end
                    end
                    if (bPlotHasUnit == false) then
                        local iUnitToSpawn = tSpawnableOceanUnits[math.random(table.count(tSpawnableOceanUnits))]
                        local pUnits = pPlayer:GetUnits()
                        pUnits:Create(iUnitToSpawn, iPlotX, iPlotY); -- Create Unit
                        iNumberToSpawnThisTurn = iNumberToSpawnThisTurn - 1
                    end
                else
                    table.remove(tOceanPlots, iSelectedTableKey)
                    iNumberOceanPlots = iNumberOceanPlots - 1
                    if (iNumberOceanPlots == 0) then
                        bNoMoreSeaUnitsCanBeSpawned = true
                        return
                    end
                end
            end
            -- satefy valve check and routine end when the number of total attempts is at 21 for this turn
            iAttemptsThisTurn = iAttemptsThisTurn + 1
            if (iAttemptsThisTurn > 40) then return end
        end
    end
end

if (bNoMoreSeaUnitsCanBeSpawned == false) then
    GameEvents.PlayerTurnStarted.Add(SpawnOceanPredators)
end