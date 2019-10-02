INSERT INTO Types (Type, Kind) VALUES ('BUILDING_TOWER_BRIDGE', 'KIND_BUILDING');

INSERT INTO Buildings (BuildingType, Name, Description, PrereqTech, Cost, AdvisorType, MaxWorldInstances, IsWonder, RequiresPlacement, MustNotBeLake, MustBeAdjacentLand, Entertainment, Quote, QuoteAudio)
VALUES ('BUILDING_TOWER_BRIDGE', 'LOC_BUILDING_TOWER_BRIDGE_NAME', 'LOC_BUILDING_TOWER_BRIDGE_DESCRIPTION', 'TECH_COMBUSTION', '1620', 'ADVISOR_GENERIC', '1', '1', '1', '1', '1', '3', 'LOC_BUILDING_TOWER_BRIDGE_QUOTE', 'Play_LOC_BUILDING_TOWER_BRIDGE_QUOTE');

INSERT INTO Buildings_XP2 (BuildingType, Bridge) VALUES ('BUILDING_TOWER_BRIDGE', '1');

INSERT INTO Building_ValidTerrains (BuildingType, TerrainType) VALUES ('BUILDING_TOWER_BRIDGE', 'TERRAIN_COAST');

--<Row>
--  <RequirementId>REQUIRES_CITY_IS_NOT_OWNER_CAPITAL_CONTINENT</RequirementId>
--  <RequirementType>REQUIREMENT_CITY_IS_OWNER_CAPITAL_CONTINENT</RequirementType>
--  <Inverse>true</Inverse>
--</Row>
