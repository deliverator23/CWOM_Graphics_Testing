function GetValidPlotsFromPlotIndexTable(tTable)
	local tNewTable = {}
	local iCount = 1
	for i,iPlotIndex in ipairs(tTable) do
		local pPlot = Map.GetPlotByIndex(iPlotIndex);
		if (pPlot ~= nil) then
			local iPlotX, iPlotY = pPlot:GetX(), pPlot:GetY()
			print("Continent Plot found at X" .. iPlotX .. ", Y" .. iPlotY)
			if (pPlot:GetOwner() == -1) and (pPlot:IsMountain() == false) and (pPlot:IsWater() == false) and (pPlot:IsNaturalWonder() == false) and (pPlot:IsImpassable() == false) then
				local bPlotHasUnit = false
				local unitList:table = Units.GetUnitsInPlotLayerID( iPlotX, iPlotY, MapLayers.ANY );
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

local baseContinents = {
	"CONTINENT_AFRICA",
    "CONTINENT_EUROPE",
    "CONTINENT_NORTH_AMERICA",
    "CONTINENT_SOUTH_AMERICA",
    "CONTINENT_ASIA",
    "CONTINENT_OCEANIA"
}

function WildPredators(iPlayer)

	if (PlayerConfigurations[iPlayer]:GetCivilizationTypeName() == "CIVILIZATION_BARBARIAN") then
    
		local pPlayer = Players[iPlayer];
		math.randomseed(os.time()) --set seed for rng
        for i=1,4 do math.random() end --extra math.randoms to progress the seed and provide a greater degree of randomness
        
		local tContinents = Map.GetContinentsInUse()
        
		for i, iContinent in ipairs(tContinents) do
		
            for unitSpawnContinent in GameInfo.UnitSpawnContinents() do

                local matchingContinent = false;
            
                if (GameInfo.Continents[iContinent].ContinentType == unitSpawnContinent.ContinentType) then
                    matchingContinent = true;
                else
                    local baseContinentId = i % table.getn(baseContinents)
                    if (baseContinents[baseContinentId] == unitSpawnContinent.ContinentType) then
                        matchingContinent = true;
                    end
                end
                
                if (matchingContinent) then
                    
                    local pPlots = GetValidPlotsFromPlotIndexTable(Map.GetContinentPlots(iContinent))
                    if (pPlots ~= nil) and (table.count(pPlots) > 0) then
                    
                        if (math.random(unitSpawnContinent.RandomSize) == 0) then 
                            local myplotIndex = math.random(table.count(pPlots)); 
                            local pPlot = pPlots[myplotIndex]; 
                            local canSpawn = false;
                            
                            for unitSpawnTerrain in GameInfo.UnitSpawnTerrains() do
                                if pPlot:GetTerrainType() == GameInfo.Terrains[unitSpawnTerrain].Index then
                                    canSpawn = true;
                                end
                            end
                            
                            for unitSpawnFeature in GameInfo.UnitSpawnFeatures() do
                                if pPlot:GetFeatureType() == GameInfo.Features[unitSpawnFeature].Index then
                                    canSpawn = true;
                                end
                            end
                            
                            if (canSpawn) then
                                local iX, iY = pPlot:GetX(), pPlot:GetY() 
                                local pUnits = pPlayer:GetUnits()
                                pUnits:Create(GameInfo.Units[unitSpawnContinent.UnitType].Index, iX, iY); 
                                table.remove(pPlots, myplotIndex)
                            end
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
	if (pPlot ~= nil) and (pPlot:GetTerrainType() == iOceanTile) and (pPlot:GetOwner() == -1) and (pPlot:IsNaturalWonder() == false)  then
		tOceanPlots[iNumberOceanPlots] = i
		iNumberOceanPlots = iNumberOceanPlots + 1
		bNoMoreSeaUnitsCanBeSpawned = false
	end
end

local tBarbOceanUnitTypes = {}
for k,v in ipairs(tSpawnableOceanUnits) do
	tBarbOceanUnitTypes[v] = "true"
end

function GetNumberAllowedOceanPredators(iPlayer)
	local pPlayer = Players[iPlayer];
	local pUnits = pPlayer:GetUnits()
	local iNumberAliveUnits = 0
	for i,pUnit in pUnits:Members() do
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
		local iAttemptsThisTurn = 0		-- safety valve "counter" to keep the code from doing an infinite unending loop
		while iNumberToSpawnThisTurn > 0 do
			local iSelectedTableKey = math.random(iNumberOceanPlots)
			local iPlotIndex = tOceanPlots[iSelectedTableKey]
			local pPlot = Map.GetPlotByIndex(iPlotIndex);
			if (pPlot ~= nil) then
				if (pPlot:GetOwner() == -1) then
					local iPlotX, iPlotY = pPlot:GetX(), pPlot:GetY()
					local bPlotHasUnit = false
					local unitList:table = Units.GetUnitsInPlotLayerID( iPlotX, iPlotY, MapLayers.ANY );
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